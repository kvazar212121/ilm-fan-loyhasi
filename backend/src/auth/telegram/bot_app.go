package telegram

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"sync"

	tgbot "github.com/go-telegram/bot"
	"github.com/go-telegram/bot/models"
	"github.com/google/uuid"
	"github.com/muhriddinnorqulov/skeleton/src/auth/domain"
	"github.com/muhriddinnorqulov/skeleton/src/auth/persistence"
	"github.com/muhriddinnorqulov/skeleton/src/auth/service"
	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/db"
	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/env"
	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/logger"
	"go.uber.org/zap"
)

const (
	cbConfirmPrefix = "confirm:"
	cbRejectPrefix  = "reject:"
)

type BotApp struct {
	cfg      *env.Env
	database *db.Database
	svc      *service.TelegramBotService
	lg       *logger.ConsoleLogger

	mu      sync.Mutex
	pending map[int64]uuid.UUID // telegramUserID -> pending attempt awaiting contact share
}

// @inject
func NewBotApp(
	cfg *env.Env,
	database *db.Database,
	svc *service.TelegramBotService,
	lg *logger.ConsoleLogger,
) *BotApp {
	return &BotApp{
		cfg:      cfg,
		database: database,
		svc:      svc,
		lg:       lg,
		pending:  map[int64]uuid.UUID{},
	}
}

func (a *BotApp) Run(ctx context.Context) error {
	if strings.TrimSpace(a.cfg.TelegramBotToken) == "" {
		return errors.New("TELEGRAM_BOT_TOKEN is required to run telegram-bot")
	}
	if err := persistence.AutoMigrate(a.database.DB); err != nil {
		return fmt.Errorf("auto-migrate auth tables: %w", err)
	}

	b, err := tgbot.New(
		a.cfg.TelegramBotToken,
		tgbot.WithDefaultHandler(a.handleUpdate),
		tgbot.WithErrorsHandler(func(err error) {
			a.lg.Error("telegram bot error", zap.Error(err))
		}),
	)
	if err != nil {
		return fmt.Errorf("init telegram bot: %w", err)
	}

	me, err := b.GetMe(ctx)
	if err != nil {
		return fmt.Errorf("telegram getMe failed: %w", err)
	}
	a.lg.Info("Telegram auth bot started", zap.String("username", me.Username))
	b.Start(ctx)
	return nil
}

func (a *BotApp) handleUpdate(ctx context.Context, b *tgbot.Bot, update *models.Update) {
	switch {
	case update.CallbackQuery != nil:
		a.handleCallback(ctx, b, update.CallbackQuery)
	case update.Message != nil && update.Message.Contact != nil:
		a.handleContact(ctx, b, update.Message)
	case update.Message != nil && strings.HasPrefix(strings.TrimSpace(update.Message.Text), "/start"):
		a.handleStart(ctx, b, update.Message)
	}
}

func (a *BotApp) handleStart(ctx context.Context, b *tgbot.Bot, msg *models.Message) {
	if msg.From == nil {
		return
	}
	parts := strings.Fields(strings.TrimSpace(msg.Text))
	if len(parts) < 2 {
		a.askContact(ctx, b, msg.Chat.ID, "Assalomu alaykum! Ilm Fan platformasiga kirish uchun telefon raqamingizni yuboring.")
		return
	}

	token := parts[1]
	step, err := a.svc.OpenLogin(ctx, token, msg.From.ID, msg.Chat.ID)
	if err != nil {
		a.replyText(ctx, b, msg.Chat.ID, userErrorText(err))
		return
	}
	if step.NeedContact {
		a.mu.Lock()
		a.pending[msg.From.ID] = step.AttemptID
		a.mu.Unlock()
		a.askContact(ctx, b, msg.Chat.ID, "Kirishni davom ettirish uchun quyidagi tugma orqali telefon raqamingizni yuboring:")
		return
	}
	if step.Prompt != nil {
		a.sendPrompt(ctx, b, msg.Chat.ID, step.Prompt)
	}
}

func (a *BotApp) handleContact(ctx context.Context, b *tgbot.Bot, msg *models.Message) {
	if msg.From == nil || msg.Contact == nil {
		return
	}
	a.mu.Lock()
	attemptID, hasPending := a.pending[msg.From.ID]
	delete(a.pending, msg.From.ID)
	a.mu.Unlock()

	var pendingPtr *uuid.UUID
	if hasPending {
		pendingPtr = &attemptID
	}

	prompt, err := a.svc.ShareContact(
		ctx,
		msg.From.ID,
		msg.Chat.ID,
		msg.Contact.UserID,
		msg.Contact.PhoneNumber,
		msg.From.FirstName,
		msg.From.LastName,
		msg.From.Username,
		pendingPtr,
	)
	if err != nil {
		a.replyText(ctx, b, msg.Chat.ID, userErrorText(err))
		return
	}
	if prompt != nil {
		a.sendPrompt(ctx, b, msg.Chat.ID, prompt)
		return
	}
	_, _ = b.SendMessage(ctx, &tgbot.SendMessageParams{
		ChatID:      msg.Chat.ID,
		Text:        "✅ Telefon raqamingiz saqlandi. Endi saytdan yoki ilovadan «Telegram orqali kirish» tugmasini bosing.",
		ReplyMarkup: &models.ReplyKeyboardRemove{RemoveKeyboard: true},
	})
}

func (a *BotApp) handleCallback(ctx context.Context, b *tgbot.Bot, cq *models.CallbackQuery) {
	_, _ = b.AnswerCallbackQuery(ctx, &tgbot.AnswerCallbackQueryParams{CallbackQueryID: cq.ID})

	var confirm bool
	var rawID string
	switch {
	case strings.HasPrefix(cq.Data, cbConfirmPrefix):
		confirm = true
		rawID = strings.TrimPrefix(cq.Data, cbConfirmPrefix)
	case strings.HasPrefix(cq.Data, cbRejectPrefix):
		confirm = false
		rawID = strings.TrimPrefix(cq.Data, cbRejectPrefix)
	default:
		return
	}

	attemptID, err := uuid.Parse(rawID)
	if err != nil {
		return
	}
	err = a.svc.DecideLogin(ctx, attemptID, cq.From.ID, confirm)
	reply := "✅ Kirish tasdiqlandi! Sayt yoki ilovaga qayting."
	if !confirm {
		reply = "❌ Kirish bekor qilindi."
	}
	if err != nil {
		reply = userErrorText(err)
	}

	if cq.Message.Message != nil {
		_, _ = b.EditMessageText(ctx, &tgbot.EditMessageTextParams{
			ChatID:    cq.Message.Message.Chat.ID,
			MessageID: cq.Message.Message.ID,
			Text:      reply,
		})
	}
}

func (a *BotApp) askContact(ctx context.Context, b *tgbot.Bot, chatID int64, text string) {
	_, _ = b.SendMessage(ctx, &tgbot.SendMessageParams{
		ChatID: chatID,
		Text:   text,
		ReplyMarkup: &models.ReplyKeyboardMarkup{
			ResizeKeyboard:  true,
			OneTimeKeyboard: true,
			Keyboard: [][]models.KeyboardButton{
				{
					{Text: "📱 Telefon raqamni yuborish", RequestContact: true},
				},
			},
		},
	})
}

func (a *BotApp) sendPrompt(ctx context.Context, b *tgbot.Bot, chatID int64, p *service.TelegramLoginPrompt) {
	text := fmt.Sprintf(
		"🔐 Ilm Fan platformasiga kirish so'rovi\n\n📱 Raqam: %s\n🌐 IP: %s\n🕒 Vaqt: %s\n\nKirishni tasdiqlaysizmi?",
		p.PhoneMasked,
		nonEmpty(p.IP, "noma'lum"),
		p.StartedAt.Format("2006-01-02 15:04"),
	)
	_, _ = b.SendMessage(ctx, &tgbot.SendMessageParams{
		ChatID: chatID,
		Text:   text,
		ReplyMarkup: &models.InlineKeyboardMarkup{
			InlineKeyboard: [][]models.InlineKeyboardButton{
				{
					{Text: "✅ Tasdiqlash", CallbackData: cbConfirmPrefix + p.AttemptID.String()},
					{Text: "❌ Bu men emasman", CallbackData: cbRejectPrefix + p.AttemptID.String()},
				},
			},
		},
	})
}

func (a *BotApp) replyText(ctx context.Context, b *tgbot.Bot, chatID int64, text string) {
	_, _ = b.SendMessage(ctx, &tgbot.SendMessageParams{
		ChatID: chatID,
		Text:   text,
	})
}

func userErrorText(err error) string {
	var authErr *domain.AuthError
	if errors.As(err, &authErr) {
		return "⚠️ " + authErr.Message
	}
	return "⚠️ Xatolik yuz berdi. Qayta urinib ko'ring."
}

func nonEmpty(v, fallback string) string {
	if strings.TrimSpace(v) == "" {
		return fallback
	}
	return v
}
