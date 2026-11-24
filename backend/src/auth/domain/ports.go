package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/muhriddinnorqulov/skeleton/src/core/domain/entity"
	"github.com/muhriddinnorqulov/skeleton/src/core/domain/ports/unitofwork"
)

type UserStore interface {
	FindByID(ctx context.Context, id uint) (*entity.UserEntity, error)
	FindByPhone(ctx context.Context, phoneE164 string) (*entity.UserEntity, error)
	FindByEmail(ctx context.Context, email string) (*entity.UserEntity, error)
	CreateTx(ctx context.Context, tx unitofwork.Tx, user *entity.UserEntity) (*entity.UserEntity, error)
	UpdateProfile(ctx context.Context, user *entity.UserEntity) (*entity.UserEntity, error)
	MergeUsersTx(ctx context.Context, tx unitofwork.Tx, primaryID, secondaryID uint) (*entity.UserEntity, error)
}

type IdentityRepository interface {
	FindByProvider(ctx context.Context, provider AuthProvider, sub string) (*UserIdentity, error)
	ListByUserID(ctx context.Context, userID uint) ([]UserIdentity, error)
	UpsertTx(ctx context.Context, tx unitofwork.Tx, identity *UserIdentity) error
	DeleteByUserAndProvider(ctx context.Context, userID uint, provider AuthProvider) error
}

type OTPRepository interface {
	Create(ctx context.Context, c *OTPChallenge) error
	FindLatestActiveByPhone(ctx context.Context, phoneE164 string) (*OTPChallenge, error)
	CountSentSince(ctx context.Context, phoneE164 string, since time.Time) (int64, error)
	Update(ctx context.Context, c *OTPChallenge) error
}

type SessionRepository interface {
	Create(ctx context.Context, s *AuthSession) error
	CreateTx(ctx context.Context, tx unitofwork.Tx, s *AuthSession) error
	FindByID(ctx context.Context, id uuid.UUID) (*AuthSession, error)
	FindByRefreshHash(ctx context.Context, hash []byte) (*AuthSession, error)
	Update(ctx context.Context, s *AuthSession) error
	Revoke(ctx context.Context, id uuid.UUID, now time.Time) error
}

type TelegramContactRepository interface {
	FindByTelegramUserID(ctx context.Context, telegramUserID int64) (*TelegramContact, error)
	Upsert(ctx context.Context, contact *TelegramContact) error
}

type TelegramAttemptRepository interface {
	Create(ctx context.Context, a *TelegramLoginAttempt) error
	FindByID(ctx context.Context, id uuid.UUID) (*TelegramLoginAttempt, error)
	FindByTokenHash(ctx context.Context, tokenHash []byte) (*TelegramLoginAttempt, error)
	Update(ctx context.Context, a *TelegramLoginAttempt) error
}

type QRAttemptRepository interface {
	Create(ctx context.Context, a *QRLoginAttempt) error
	FindByID(ctx context.Context, id uuid.UUID) (*QRLoginAttempt, error)
	FindByTokenHash(ctx context.Context, tokenHash []byte) (*QRLoginAttempt, error)
	Update(ctx context.Context, a *QRLoginAttempt) error
}

type SMSSender interface {
	Send(ctx context.Context, phoneE164, text string) error
}

type GoogleOAuth interface {
	Enabled() bool
	Start() (*GoogleAuthStart, error)
	Exchange(ctx context.Context, code, codeVerifier string) (*GoogleProfile, error)
	VerifyIDToken(ctx context.Context, idToken string) (*GoogleProfile, error)
}

type OTPCodeService interface {
	Generate() (string, error)
	Hash(challengeID uuid.UUID, code string) string
	Verify(challengeID uuid.UUID, code, hash string) bool
}

type RegistrationTicketSealer interface {
	Seal(t *RegistrationTicket) (string, error)
	Open(token string) (*RegistrationTicket, error)
}

type TokenService interface {
	NewOpaqueToken() (plain string, hash []byte, err error)
	Hash(token string) []byte
	VerifyHash(token string, expectedHash []byte) bool
}

type RateThrottle interface {
	Check(ip, account string) error
	Failure(ip, account string)
	Success(ip, account string)
}

// AccessTokenVerifier decouples JwtAuthMiddleware from the concrete auth service.
type AccessTokenVerifier interface {
	VerifyAccessToken(ctx context.Context, token string) (*entity.UserEntity, error)
}
