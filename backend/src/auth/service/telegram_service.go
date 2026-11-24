package service

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/muhriddinnorqulov/skeleton/src/auth/domain"
)

type TelegramLoginPrompt struct {
	AttemptID   uuid.UUID
	PhoneMasked string
	IP          string
	UserAgent   string
	StartedAt   time.Time
}

type TelegramLoginStep struct {
	AttemptID   uuid.UUID
	NeedContact bool
	Prompt      *TelegramLoginPrompt
}

type TelegramBotService struct {
	attempts domain.TelegramAttemptRepository
	contacts domain.TelegramContactRepository
	tokens   domain.TokenService
	now      func() time.Time
}

// @inject
func NewTelegramBotService(
	attempts domain.TelegramAttemptRepository,
	contacts domain.TelegramContactRepository,
	tokens domain.TokenService,
) *TelegramBotService {
	return &TelegramBotService{
		attempts: attempts,
		contacts: contacts,
		tokens:   tokens,
		now:      time.Now,
	}
}

// OpenLogin handles `/start <token>` from a Telegram user.
func (s *TelegramBotService) OpenLogin(ctx context.Context, token string, tgUserID, chatID int64) (*TelegramLoginStep, error) {
	if token == "" || len(token) > 128 {
		return nil, domain.ErrTelegramNotFound
	}
	attempt, err := s.attempts.FindByTokenHash(ctx, s.tokens.Hash(token))
	if errors.Is(err, domain.ErrNotFound) {
		return nil, domain.ErrTelegramNotFound
	}
	if err != nil {
		return nil, err
	}

	now := s.now()
	if attempt.IsExpired(now) {
		return nil, domain.ErrTelegramExpired
	}
	if attempt.Status != domain.TelegramStatusPending {
		return nil, domain.ErrTelegramUsed
	}
	if attempt.TelegramUserID != nil && *attempt.TelegramUserID != tgUserID {
		return nil, domain.ErrTelegramUsed
	}

	attempt.TelegramUserID = &tgUserID
	attempt.ChatID = &chatID
	attempt.BotOpenedAt = &now
	if err := s.attempts.Update(ctx, attempt); err != nil {
		return nil, err
	}

	contact, err := s.contacts.FindByTelegramUserID(ctx, tgUserID)
	if errors.Is(err, domain.ErrNotFound) || (err == nil && contact.BlockedAt != nil) {
		return &TelegramLoginStep{AttemptID: attempt.ID, NeedContact: true}, nil
	}
	if err != nil {
		return nil, err
	}

	return &TelegramLoginStep{
		AttemptID: attempt.ID,
		Prompt:    buildPrompt(attempt, contact),
	}, nil
}

// ShareContact stores the user's own shared phone contact and optionally prepares
// a confirmation prompt if an attemptID is pending.
func (s *TelegramBotService) ShareContact(
	ctx context.Context,
	tgUserID, chatID, contactUserID int64,
	rawPhone, firstName, lastName, username string,
	pendingAttemptID *uuid.UUID,
) (*TelegramLoginPrompt, error) {
	if contactUserID != tgUserID {
		return nil, domain.ErrTelegramWrongContact
	}
	phone, err := domain.ParsePhoneNumber(rawPhone)
	if err != nil {
		return nil, err
	}
	contact := &domain.TelegramContact{
		TelegramUserID: tgUserID,
		ChatID:         chatID,
		PhoneE164:      phone.E164,
		FirstName:      firstName,
		LastName:       lastName,
		Username:       username,
		UpdatedAt:      s.now(),
	}
	if err := s.contacts.Upsert(ctx, contact); err != nil {
		return nil, err
	}
	if pendingAttemptID == nil {
		return nil, nil
	}
	attempt, err := s.attempts.FindByID(ctx, *pendingAttemptID)
	if err != nil {
		return nil, nil
	}
	if attempt.Status != domain.TelegramStatusPending || attempt.IsExpired(s.now()) {
		return nil, nil
	}
	if attempt.TelegramUserID == nil || *attempt.TelegramUserID != tgUserID {
		return nil, nil
	}
	return buildPrompt(attempt, contact), nil
}

// DecideLogin handles the "Tasdiqlash" / "Bu men emasman" inline button click.
func (s *TelegramBotService) DecideLogin(ctx context.Context, attemptID uuid.UUID, tgUserID int64, confirm bool) error {
	attempt, err := s.attempts.FindByID(ctx, attemptID)
	if errors.Is(err, domain.ErrNotFound) {
		return domain.ErrTelegramNotFound
	}
	if err != nil {
		return err
	}
	now := s.now()
	if attempt.IsExpired(now) {
		return domain.ErrTelegramExpired
	}
	if attempt.TelegramUserID == nil || *attempt.TelegramUserID != tgUserID {
		return domain.ErrTelegramNotFound
	}
	if attempt.Status != domain.TelegramStatusPending {
		return domain.ErrTelegramUsed
	}

	attempt.DecidedAt = &now
	if confirm {
		attempt.Status = domain.TelegramStatusConfirmed
	} else {
		attempt.Status = domain.TelegramStatusRejected
		attempt.RejectReason = "rejected_by_user"
	}
	return s.attempts.Update(ctx, attempt)
}

func buildPrompt(attempt *domain.TelegramLoginAttempt, contact *domain.TelegramContact) *TelegramLoginPrompt {
	masked := contact.PhoneE164
	if parsed, err := domain.ParsePhoneNumber(contact.PhoneE164); err == nil {
		masked = parsed.Masked()
	}
	return &TelegramLoginPrompt{
		AttemptID:   attempt.ID,
		PhoneMasked: masked,
		IP:          attempt.IP,
		UserAgent:   attempt.UserAgent,
		StartedAt:   attempt.CreatedAt,
	}
}
