package service

import (
	"context"
	"errors"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/muhriddinnorqulov/skeleton/src/auth/domain"
	"github.com/muhriddinnorqulov/skeleton/src/core/domain/entity"
)

type StartQRResult struct {
	AttemptID        uuid.UUID `json:"attempt_id"`
	Secret           string    `json:"secret"`
	QRToken          string    `json:"qr_token"`
	ExpiresAt        time.Time `json:"expires_at"`
	ExpiresInSeconds int       `json:"expires_in_seconds"`
}

type ScanQRResult struct {
	Status        domain.QRAttemptStatus `json:"status"`
	DesktopDevice string                 `json:"desktop_device"`
	DesktopIP     string                 `json:"desktop_ip,omitempty"`
	ExpiresAt     time.Time              `json:"expires_at"`
}

type PollQRResult struct {
	Status       string              `json:"status"`
	Scanned      bool                `json:"scanned,omitempty"`
	Tokens       *domain.AuthTokens  `json:"tokens,omitempty"`
	User         *entity.UserEntity  `json:"user,omitempty"`
	Registration *RegistrationPrompt `json:"registration,omitempty"`
}

func (s *AuthService) StartQRLogin(ctx context.Context, meta domain.ClientMeta) (*StartQRResult, error) {
	qrToken, tokenHash, err := s.tokens.NewOpaqueToken()
	if err != nil {
		return nil, err
	}
	secret, secretHash, err := s.tokens.NewOpaqueToken()
	if err != nil {
		return nil, err
	}
	now := s.now()
	expiresAt := now.Add(domain.QRLoginTTL)
	attempt := &domain.QRLoginAttempt{
		ID:         uuid.New(),
		TokenHash:  tokenHash,
		SecretHash: secretHash,
		Status:     domain.QRStatusPending,
		IP:         meta.IP,
		UserAgent:  meta.UserAgent,
		ExpiresAt:  expiresAt,
		CreatedAt:  now,
	}
	if err := s.qrAttempts.Create(ctx, attempt); err != nil {
		return nil, err
	}
	return &StartQRResult{
		AttemptID:        attempt.ID,
		Secret:           secret,
		QRToken:          qrToken,
		ExpiresAt:        expiresAt,
		ExpiresInSeconds: int(domain.QRLoginTTL.Seconds()),
	}, nil
}

func (s *AuthService) ScanQRLogin(ctx context.Context, qrToken string) (*ScanQRResult, error) {
	attempt, err := s.findQRAttemptByToken(ctx, qrToken)
	if err != nil {
		return nil, err
	}
	now := s.now()
	switch attempt.Status {
	case domain.QRStatusUsed:
		return nil, domain.ErrQRUsed
	case domain.QRStatusRejected:
		return nil, domain.ErrQRRejected
	}
	if attempt.IsExpired(now) {
		return nil, domain.ErrQRExpired
	}
	if attempt.Status == domain.QRStatusPending {
		attempt.Status = domain.QRStatusScanned
		attempt.ScannedAt = &now
		if err := s.qrAttempts.Update(ctx, attempt); err != nil {
			return nil, err
		}
	}
	return &ScanQRResult{
		Status:        attempt.Status,
		DesktopDevice: summarizeDesktopUA(attempt.UserAgent),
		DesktopIP:     attempt.IP,
		ExpiresAt:     attempt.ExpiresAt,
	}, nil
}

func (s *AuthService) ApproveQRWithUser(ctx context.Context, qrToken string, user *entity.UserEntity, method domain.AuthProvider) error {
	if user == nil {
		return domain.ErrSessionInvalid
	}
	if user.IsBlocked {
		return domain.ErrUserBlocked
	}
	attempt, err := s.findMutableQRAttempt(ctx, qrToken)
	if err != nil {
		return err
	}
	now := s.now()
	uid := user.ID
	if method == "" {
		method = domain.ProviderQR
	}
	attempt.Status = domain.QRStatusApproved
	attempt.ApprovedUserID = &uid
	attempt.ApprovedMethod = method
	attempt.DecidedAt = &now
	return s.qrAttempts.Update(ctx, attempt)
}

func (s *AuthService) ApproveQRWithRegistration(ctx context.Context, qrToken, regToken string) error {
	ticket, err := s.tickets.Open(strings.TrimSpace(regToken))
	if err != nil || ticket.IsExpired(s.now()) {
		return domain.ErrRegistrationTicketInvalid
	}
	attempt, err := s.findMutableQRAttempt(ctx, qrToken)
	if err != nil {
		return err
	}
	now := s.now()
	attempt.Status = domain.QRStatusApproved
	attempt.ApprovedRegToken = strings.TrimSpace(regToken)
	attempt.ApprovedMethod = ticket.Method
	attempt.DecidedAt = &now
	return s.qrAttempts.Update(ctx, attempt)
}

func (s *AuthService) StartQRTelegram(ctx context.Context, qrToken string, meta domain.ClientMeta) (*StartTelegramResult, error) {
	qrAttempt, err := s.findMutableQRAttempt(ctx, qrToken)
	if err != nil {
		return nil, err
	}
	tgRes, err := s.StartTelegramLogin(ctx, meta)
	if err != nil {
		return nil, err
	}
	now := s.now()
	tgID := tgRes.AttemptID
	qrAttempt.TelegramAttemptID = &tgID
	if qrAttempt.Status == domain.QRStatusPending {
		qrAttempt.Status = domain.QRStatusScanned
		qrAttempt.ScannedAt = &now
	}
	if err := s.qrAttempts.Update(ctx, qrAttempt); err != nil {
		return nil, err
	}
	return tgRes, nil
}

func (s *AuthService) RejectQRLogin(ctx context.Context, qrToken string) error {
	attempt, err := s.findMutableQRAttempt(ctx, qrToken)
	if err != nil {
		return err
	}
	now := s.now()
	attempt.Status = domain.QRStatusRejected
	attempt.DecidedAt = &now
	return s.qrAttempts.Update(ctx, attempt)
}

func (s *AuthService) PollQRLogin(ctx context.Context, attemptID uuid.UUID, secret string, meta domain.ClientMeta) (*PollQRResult, error) {
	attempt, err := s.qrAttempts.FindByID(ctx, attemptID)
	if err != nil {
		if errors.Is(err, domain.ErrNotFound) {
			return nil, domain.ErrQRNotFound
		}
		return nil, err
	}
	if !s.tokens.VerifyHash(secret, attempt.SecretHash) {
		return nil, domain.ErrQRNotFound
	}
	now := s.now()
	switch attempt.Status {
	case domain.QRStatusUsed:
		return nil, domain.ErrQRUsed
	case domain.QRStatusRejected:
		return nil, domain.ErrQRRejected
	}
	if attempt.IsExpired(now) {
		return nil, domain.ErrQRExpired
	}
	if attempt.Status == domain.QRStatusPending || attempt.Status == domain.QRStatusScanned {
		if attempt.TelegramAttemptID != nil {
			if tgAttempt, tgErr := s.tgAttempts.FindByID(ctx, *attempt.TelegramAttemptID); tgErr == nil && tgAttempt != nil {
				if tgAttempt.Status == domain.TelegramStatusRejected {
					attempt.Status = domain.QRStatusRejected
					attempt.DecidedAt = &now
					_ = s.qrAttempts.Update(ctx, attempt)
					return nil, domain.ErrQRRejected
				}
				if tgAttempt.Status == domain.TelegramStatusConfirmed && !tgAttempt.IsExpired(now) {
					res, err := s.resolveConfirmedTelegramAttempt(ctx, tgAttempt, meta)
					if err != nil {
						return nil, err
					}
					attempt.Status = domain.QRStatusUsed
					attempt.ApprovedMethod = domain.ProviderTelegram
					attempt.DecidedAt = &now
					attempt.ConsumedAt = &now
					if res.User != nil {
						uid := res.User.ID
						attempt.ApprovedUserID = &uid
					}
					if err := s.qrAttempts.Update(ctx, attempt); err != nil {
						return nil, err
					}
					return &PollQRResult{
						Status:       res.Status,
						Tokens:       res.Tokens,
						User:         res.User,
						Registration: res.Registration,
					}, nil
				}
			}
		}
		return &PollQRResult{
			Status:  LoginStatusPending,
			Scanned: attempt.Status == domain.QRStatusScanned,
		}, nil
	}

	attempt.Status = domain.QRStatusUsed
	attempt.ConsumedAt = &now
	if err := s.qrAttempts.Update(ctx, attempt); err != nil {
		return nil, err
	}

	if attempt.ApprovedUserID != nil {
		user, err := s.users.FindByID(ctx, *attempt.ApprovedUserID)
		if err != nil {
			return nil, domain.ErrSessionInvalid
		}
		method := attempt.ApprovedMethod
		if method == "" {
			method = domain.ProviderQR
		}
		res, err := s.issueAuthenticatedResult(ctx, user, method, meta)
		if err != nil {
			return nil, err
		}
		return &PollQRResult{
			Status: LoginStatusAuthenticated,
			Tokens: res.Tokens,
			User:   res.User,
		}, nil
	}

	if attempt.ApprovedRegToken != "" {
		ticket, err := s.tickets.Open(attempt.ApprovedRegToken)
		if err != nil || ticket.IsExpired(now) {
			return nil, domain.ErrRegistrationTicketInvalid
		}
		return &PollQRResult{
			Status: LoginStatusRegistrationRequired,
			Registration: &RegistrationPrompt{
				Token:     attempt.ApprovedRegToken,
				ExpiresAt: ticket.ExpiresAt,
			},
		}, nil
	}

	return nil, domain.ErrQRNotFound
}

func (s *AuthService) findQRAttemptByToken(ctx context.Context, qrToken string) (*domain.QRLoginAttempt, error) {
	trimmed := strings.TrimSpace(qrToken)
	if trimmed == "" {
		return nil, domain.ErrQRNotFound
	}
	attempt, err := s.qrAttempts.FindByTokenHash(ctx, s.tokens.Hash(trimmed))
	if err != nil {
		if errors.Is(err, domain.ErrNotFound) {
			return nil, domain.ErrQRNotFound
		}
		return nil, err
	}
	return attempt, nil
}

func (s *AuthService) findMutableQRAttempt(ctx context.Context, qrToken string) (*domain.QRLoginAttempt, error) {
	attempt, err := s.findQRAttemptByToken(ctx, qrToken)
	if err != nil {
		return nil, err
	}
	switch attempt.Status {
	case domain.QRStatusUsed, domain.QRStatusApproved:
		return nil, domain.ErrQRUsed
	case domain.QRStatusRejected:
		return nil, domain.ErrQRRejected
	}
	if attempt.IsExpired(s.now()) {
		return nil, domain.ErrQRExpired
	}
	return attempt, nil
}

func summarizeDesktopUA(ua string) string {
	low := strings.ToLower(ua)
	osName := "Kompyuter"
	switch {
	case strings.Contains(low, "windows"):
		osName = "Windows"
	case strings.Contains(low, "mac os") || strings.Contains(low, "macintosh"):
		osName = "macOS"
	case strings.Contains(low, "android"):
		osName = "Android"
	case strings.Contains(low, "iphone") || strings.Contains(low, "ipad"):
		osName = "iOS"
	case strings.Contains(low, "linux"):
		osName = "Linux"
	}
	browser := "Brauzer"
	switch {
	case strings.Contains(low, "edg/"):
		browser = "Edge"
	case strings.Contains(low, "opr/") || strings.Contains(low, "opera"):
		browser = "Opera"
	case strings.Contains(low, "firefox/"):
		browser = "Firefox"
	case strings.Contains(low, "chrome/") || strings.Contains(low, "crios"):
		browser = "Chrome"
	case strings.Contains(low, "safari/"):
		browser = "Safari"
	}
	return osName + " · " + browser
}
