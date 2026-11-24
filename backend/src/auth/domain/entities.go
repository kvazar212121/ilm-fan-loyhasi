package domain

import (
	"time"

	"github.com/google/uuid"
)

const (
	OTPCodeLength      = 5
	OTPTTL             = 2 * time.Minute
	OTPMaxAttempts     = 3
	OTPResendCooldown  = 60 * time.Second
	OTPDailyLimit      = 5
	RegistrationTTL    = 30 * time.Minute
	TelegramAttemptTTL = 5 * time.Minute
	QRLoginTTL         = 3 * time.Minute
)

type AuthProvider string

const (
	ProviderPhone    AuthProvider = "phone"
	ProviderGoogle   AuthProvider = "google"
	ProviderTelegram AuthProvider = "telegram"
	ProviderQR       AuthProvider = "qr"
)

type QRAttemptStatus string

const (
	QRStatusPending  QRAttemptStatus = "pending"
	QRStatusScanned  QRAttemptStatus = "scanned"
	QRStatusApproved QRAttemptStatus = "approved"
	QRStatusRejected QRAttemptStatus = "rejected"
	QRStatusUsed     QRAttemptStatus = "used"
)

type TelegramAttemptStatus string

const (
	TelegramStatusPending   TelegramAttemptStatus = "pending"
	TelegramStatusConfirmed TelegramAttemptStatus = "confirmed"
	TelegramStatusRejected  TelegramAttemptStatus = "rejected"
	TelegramStatusUsed      TelegramAttemptStatus = "used"
)

type ClientMeta struct {
	IP        string
	UserAgent string
}

type OTPChallenge struct {
	ID          uuid.UUID
	PhoneE164   string
	CodeHash    string
	Attempts    int
	MaxAttempts int
	ExpiresAt   time.Time
	ConsumedAt  *time.Time
	CreatedAt   time.Time
}

func (c *OTPChallenge) IsExpired(now time.Time) bool {
	return now.After(c.ExpiresAt)
}

func (c *OTPChallenge) IsConsumed() bool {
	return c.ConsumedAt != nil
}

type GoogleClaim struct {
	Subject    string `json:"sub"`
	Email      string `json:"email"`
	GivenName  string `json:"given_name,omitempty"`
	FamilyName string `json:"family_name,omitempty"`
	AvatarURL  string `json:"avatar_url,omitempty"`
}

type GoogleProfile struct {
	Subject       string
	Email         string
	EmailVerified bool
	GivenName     string
	FamilyName    string
	AvatarURL     string
}

type GoogleAuthStart struct {
	AuthorizationURL string `json:"authorization_url"`
	State            string `json:"state"`
	CodeVerifier     string `json:"code_verifier"`
}

// RegistrationTicket carries verified identity claims from step 1 (Google, Telegram, or SMS)
// into step 2-4 (Role -> Fan -> Profile -> POST /register).
type RegistrationTicket struct {
	Method         AuthProvider `json:"method"`
	Phone          *PhoneNumber `json:"phone,omitempty"`
	PhoneVerified  bool         `json:"phone_verified,omitempty"`
	TelegramUserID *int64       `json:"telegram_user_id,omitempty"`
	TelegramName   string       `json:"telegram_name,omitempty"`
	Google         *GoogleClaim `json:"google,omitempty"`
	ExpiresAt      time.Time    `json:"expires_at"`
}

func (t *RegistrationTicket) IsExpired(now time.Time) bool {
	return now.After(t.ExpiresAt)
}

type UserIdentity struct {
	ID          uint         `json:"id"`
	UserID      uint         `json:"user_id"`
	Provider    AuthProvider `json:"provider"`
	ProviderSub string       `json:"provider_sub"`
	DisplayName string       `json:"display_name,omitempty"`
	CreatedAt   time.Time    `json:"created_at"`
}

type AuthSession struct {
	ID               uuid.UUID
	UserID           uint
	RefreshTokenHash []byte
	AuthMethod       AuthProvider
	IP               string
	UserAgent        string
	ExpiresAt        time.Time
	RevokedAt        *time.Time
	CreatedAt        time.Time
}

func (s *AuthSession) IsActive(now time.Time) bool {
	return s.RevokedAt == nil && now.Before(s.ExpiresAt)
}

type TelegramContact struct {
	TelegramUserID int64
	ChatID         int64
	PhoneE164      string
	FirstName      string
	LastName       string
	Username       string
	BlockedAt      *time.Time
	UpdatedAt      time.Time
}

type TelegramLoginAttempt struct {
	ID             uuid.UUID
	TokenHash      []byte
	SecretHash     []byte
	Status         TelegramAttemptStatus
	RejectReason   string
	TelegramUserID *int64
	ChatID         *int64
	IP             string
	UserAgent      string
	BotOpenedAt    *time.Time
	DecidedAt      *time.Time
	ConsumedAt     *time.Time
	ExpiresAt      time.Time
	CreatedAt      time.Time
}

func (a *TelegramLoginAttempt) IsExpired(now time.Time) bool {
	return now.After(a.ExpiresAt)
}

type QRLoginAttempt struct {
	ID                uuid.UUID
	TokenHash         []byte
	SecretHash        []byte
	Status            QRAttemptStatus
	TelegramAttemptID *uuid.UUID
	ApprovedUserID    *uint
	ApprovedRegToken  string
	ApprovedMethod    AuthProvider
	IP                string
	UserAgent         string
	ScannedAt         *time.Time
	DecidedAt         *time.Time
	ConsumedAt        *time.Time
	ExpiresAt         time.Time
	CreatedAt         time.Time
}

func (a *QRLoginAttempt) IsExpired(now time.Time) bool {
	return now.After(a.ExpiresAt)
}

type AuthTokens struct {
	AccessToken  string    `json:"access_token"`
	RefreshToken string    `json:"refresh_token"`
	TokenType    string    `json:"token_type"`
	ExpiresAt    time.Time `json:"expires_at"`
	SessionID    uuid.UUID `json:"session_id"`
}
