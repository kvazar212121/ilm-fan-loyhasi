package persistence

import (
	"time"

	"github.com/google/uuid"
	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/persistence/models"
	"gorm.io/gorm"
)

type AuthUserIdentityModel struct {
	ID          uint      `gorm:"primaryKey"`
	UserID      uint      `gorm:"not null;index"`
	Provider    string    `gorm:"size:32;not null;uniqueIndex:idx_auth_provider_sub"`
	ProviderSub string    `gorm:"size:255;not null;uniqueIndex:idx_auth_provider_sub"`
	DisplayName string    `gorm:"size:255"`
	CreatedAt   time.Time `gorm:"autoCreateTime"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime"`
}

func (*AuthUserIdentityModel) TableName() string { return "auth_user_identities" }

type AuthOTPChallengeModel struct {
	ID          uuid.UUID `gorm:"type:uuid;primaryKey"`
	PhoneE164   string    `gorm:"size:32;not null;index:idx_auth_otp_phone_created"`
	CodeHash    string    `gorm:"size:128;not null"`
	Attempts    int       `gorm:"not null;default:0"`
	MaxAttempts int       `gorm:"not null;default:3"`
	ExpiresAt   time.Time `gorm:"not null;index"`
	ConsumedAt  *time.Time
	CreatedAt   time.Time `gorm:"autoCreateTime;index:idx_auth_otp_phone_created"`
}

func (*AuthOTPChallengeModel) TableName() string { return "auth_otp_challenges" }

type AuthSessionModel struct {
	ID               uuid.UUID `gorm:"type:uuid;primaryKey"`
	UserID           uint      `gorm:"not null;index"`
	RefreshTokenHash []byte    `gorm:"type:bytea;not null;uniqueIndex"`
	AuthMethod       string    `gorm:"size:32;not null"`
	IP               string    `gorm:"size:64"`
	UserAgent        string    `gorm:"size:512"`
	ExpiresAt        time.Time `gorm:"not null;index"`
	RevokedAt        *time.Time
	CreatedAt        time.Time `gorm:"autoCreateTime"`
	UpdatedAt        time.Time `gorm:"autoUpdateTime"`
}

func (*AuthSessionModel) TableName() string { return "auth_sessions" }

type AuthTelegramContactModel struct {
	TelegramUserID int64  `gorm:"primaryKey;autoIncrement:false"`
	ChatID         int64  `gorm:"not null"`
	PhoneE164      string `gorm:"size:32;not null;index"`
	FirstName      string `gorm:"size:128"`
	LastName       string `gorm:"size:128"`
	Username       string `gorm:"size:128"`
	BlockedAt      *time.Time
	CreatedAt      time.Time `gorm:"autoCreateTime"`
	UpdatedAt      time.Time `gorm:"autoUpdateTime"`
}

func (*AuthTelegramContactModel) TableName() string { return "auth_telegram_contacts" }

type AuthTelegramLoginAttemptModel struct {
	ID             uuid.UUID `gorm:"type:uuid;primaryKey"`
	TokenHash      []byte    `gorm:"type:bytea;not null;uniqueIndex"`
	SecretHash     []byte    `gorm:"type:bytea;not null"`
	Status         string    `gorm:"size:32;not null;default:'pending'"`
	RejectReason   string    `gorm:"size:64"`
	TelegramUserID *int64    `gorm:"index"`
	ChatID         *int64
	IP             string `gorm:"size:64"`
	UserAgent      string `gorm:"size:512"`
	BotOpenedAt    *time.Time
	DecidedAt      *time.Time
	ConsumedAt     *time.Time
	ExpiresAt      time.Time `gorm:"not null;index"`
	CreatedAt      time.Time `gorm:"autoCreateTime"`
	UpdatedAt      time.Time `gorm:"autoUpdateTime"`
}

func (*AuthTelegramLoginAttemptModel) TableName() string { return "auth_telegram_login_attempts" }

type AuthQRLoginAttemptModel struct {
	ID                uuid.UUID  `gorm:"type:uuid;primaryKey"`
	TokenHash         []byte     `gorm:"type:bytea;not null;uniqueIndex"`
	SecretHash        []byte     `gorm:"type:bytea;not null"`
	Status            string     `gorm:"size:32;not null;default:'pending'"`
	TelegramAttemptID *uuid.UUID `gorm:"type:uuid;index"`
	ApprovedUserID    *uint      `gorm:"index"`
	ApprovedRegToken  string     `gorm:"type:text"`
	ApprovedMethod    string     `gorm:"size:32"`
	IP                string     `gorm:"size:64"`
	UserAgent         string     `gorm:"size:512"`
	ScannedAt         *time.Time
	DecidedAt         *time.Time
	ConsumedAt        *time.Time
	ExpiresAt         time.Time `gorm:"not null;index"`
	CreatedAt         time.Time `gorm:"autoCreateTime"`
	UpdatedAt         time.Time `gorm:"autoUpdateTime"`
}

func (*AuthQRLoginAttemptModel) TableName() string { return "auth_qr_login_attempts" }

// AutoMigrate ensures users and all auth tables exist with required indexes.
func AutoMigrate(db *gorm.DB) error {
	return db.AutoMigrate(
		&models.UserModel{},
		&AuthUserIdentityModel{},
		&AuthOTPChallengeModel{},
		&AuthSessionModel{},
		&AuthTelegramContactModel{},
		&AuthTelegramLoginAttemptModel{},
		&AuthQRLoginAttemptModel{},
	)
}
