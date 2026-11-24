package persistence

import (
	"context"
	"encoding/json"
	"errors"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/muhriddinnorqulov/skeleton/src/auth/domain"
	"github.com/muhriddinnorqulov/skeleton/src/core/domain/entity"
	"github.com/muhriddinnorqulov/skeleton/src/core/domain/ports/unitofwork"
	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/db"
	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/persistence/models"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

func txDB(ctx context.Context, database *db.Database, tx unitofwork.Tx) *gorm.DB {
	if tx != nil {
		return tx.(*gorm.DB).WithContext(ctx)
	}
	return database.WithContext(ctx)
}

// --- UserStore ---

type UserStoreImpl struct {
	database *db.Database
}

// @inject
func NewUserStoreImpl(database *db.Database) domain.UserStore {
	return &UserStoreImpl{database: database}
}

func (r *UserStoreImpl) FindByID(ctx context.Context, id uint) (*entity.UserEntity, error) {
	var m models.UserModel
	if err := r.database.WithContext(ctx).First(&m, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return userModelToEntity(&m), nil
}

func (r *UserStoreImpl) FindByPhone(ctx context.Context, phoneE164 string) (*entity.UserEntity, error) {
	var m models.UserModel
	if err := r.database.WithContext(ctx).Where("phone = ?", phoneE164).First(&m).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return userModelToEntity(&m), nil
}

func (r *UserStoreImpl) FindByEmail(ctx context.Context, email string) (*entity.UserEntity, error) {
	normalized := strings.ToLower(strings.TrimSpace(email))
	if normalized == "" {
		return nil, domain.ErrNotFound
	}
	var m models.UserModel
	if err := r.database.WithContext(ctx).Where("LOWER(email) = ?", normalized).First(&m).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return userModelToEntity(&m), nil
}

func (r *UserStoreImpl) CreateTx(ctx context.Context, tx unitofwork.Tx, u *entity.UserEntity) (*entity.UserEntity, error) {
	fanJSON, _ := json.Marshal(u.FanIDs)
	m := &models.UserModel{
		FirstName: u.FirstName,
		LastName:  u.LastName,
		Role:      u.Role,
		FanIDs:    string(fanJSON),
		AvatarURL: u.AvatarURL,
		Phone:     u.Phone,
		Email:     u.Email,
		BirthDate: u.BirthDate,
		Region:    u.Region,
		Gender:    u.Gender,
		IsBlocked: u.IsBlocked,
	}
	if err := txDB(ctx, r.database, tx).Create(m).Error; err != nil {
		return nil, err
	}
	return userModelToEntity(m), nil
}

func (r *UserStoreImpl) UpdateProfile(ctx context.Context, u *entity.UserEntity) (*entity.UserEntity, error) {
	updates := map[string]any{
		"first_name": u.FirstName,
		"last_name":  u.LastName,
		"phone":      u.Phone,
		"email":      u.Email,
		"birth_date": u.BirthDate,
		"region":     u.Region,
		"gender":     u.Gender,
		"avatar_url": u.AvatarURL,
	}
	if err := r.database.WithContext(ctx).Model(&models.UserModel{}).Where("id = ?", u.ID).Updates(updates).Error; err != nil {
		return nil, err
	}
	return r.FindByID(ctx, u.ID)
}

// MergeUsersTx merges secondaryID into primaryID within a transaction:
// transfers identities and sessions, copies any missing profile fields to primary,
// clears unique columns on secondary, and soft-deletes secondary.
func (r *UserStoreImpl) MergeUsersTx(ctx context.Context, tx unitofwork.Tx, primaryID, secondaryID uint) (*entity.UserEntity, error) {
	gdb := txDB(ctx, r.database, tx)

	var primary, secondary models.UserModel
	if err := gdb.First(&primary, primaryID).Error; err != nil {
		return nil, err
	}
	if err := gdb.First(&secondary, secondaryID).Error; err != nil {
		return nil, err
	}

	// Move identities from secondary -> primary.
	if err := gdb.Model(&AuthUserIdentityModel{}).
		Where("user_id = ?", secondaryID).
		Update("user_id", primaryID).Error; err != nil {
		return nil, err
	}

	// Move active/historical sessions from secondary -> primary.
	if err := gdb.Model(&AuthSessionModel{}).
		Where("user_id = ?", secondaryID).
		Update("user_id", primaryID).Error; err != nil {
		return nil, err
	}

	// Capture missing fields before clearing unique columns on secondary.
	primaryUpdates := map[string]any{}
	if (primary.Phone == nil || *primary.Phone == "") && secondary.Phone != nil && *secondary.Phone != "" {
		primaryUpdates["phone"] = *secondary.Phone
	}
	if (primary.Email == nil || *primary.Email == "") && secondary.Email != nil && *secondary.Email != "" {
		primaryUpdates["email"] = *secondary.Email
	}
	if (primary.AvatarURL == nil || *primary.AvatarURL == "") && secondary.AvatarURL != nil && *secondary.AvatarURL != "" {
		primaryUpdates["avatar_url"] = *secondary.AvatarURL
	}
	if (primary.LastName == nil || *primary.LastName == "") && secondary.LastName != nil && *secondary.LastName != "" {
		primaryUpdates["last_name"] = *secondary.LastName
	}
	if (primary.BirthDate == nil || *primary.BirthDate == "") && secondary.BirthDate != nil && *secondary.BirthDate != "" {
		primaryUpdates["birth_date"] = *secondary.BirthDate
	}
	if (primary.Region == nil || *primary.Region == "") && secondary.Region != nil && *secondary.Region != "" {
		primaryUpdates["region"] = *secondary.Region
	}
	if (primary.Gender == nil || *primary.Gender == "") && secondary.Gender != nil && *secondary.Gender != "" {
		primaryUpdates["gender"] = *secondary.Gender
	}
	if primary.Role == "" && secondary.Role != "" {
		primaryUpdates["role"] = secondary.Role
	}
	if (primary.FanIDs == "" || primary.FanIDs == "[]" || primary.FanIDs == "null") && secondary.FanIDs != "" && secondary.FanIDs != "[]" && secondary.FanIDs != "null" {
		primaryUpdates["fan_ids"] = secondary.FanIDs
	}

	// Clear unique columns on secondary first so PostgreSQL unique indexes never collide.
	if err := gdb.Model(&models.UserModel{}).Where("id = ?", secondaryID).Updates(map[string]any{
		"phone": nil,
		"email": nil,
	}).Error; err != nil {
		return nil, err
	}
	if err := gdb.Delete(&models.UserModel{}, secondaryID).Error; err != nil {
		return nil, err
	}

	if len(primaryUpdates) > 0 {
		if err := gdb.Model(&models.UserModel{}).Where("id = ?", primaryID).Updates(primaryUpdates).Error; err != nil {
			return nil, err
		}
	}

	var refreshed models.UserModel
	if err := gdb.First(&refreshed, primaryID).Error; err != nil {
		return nil, err
	}
	return userModelToEntity(&refreshed), nil
}

func userModelToEntity(m *models.UserModel) *entity.UserEntity {
	var fanIDs []string
	if m.FanIDs != "" {
		_ = json.Unmarshal([]byte(m.FanIDs), &fanIDs)
	}
	return &entity.UserEntity{
		ID:        m.ID,
		FirstName: m.FirstName,
		LastName:  m.LastName,
		Role:      m.Role,
		FanIDs:    fanIDs,
		AvatarURL: m.AvatarURL,
		Phone:     m.Phone,
		Email:     m.Email,
		BirthDate: m.BirthDate,
		Region:    m.Region,
		Gender:    m.Gender,
		IsBlocked: m.IsBlocked,
	}
}

// --- IdentityRepository ---

type IdentityRepositoryImpl struct {
	database *db.Database
}

// @inject
func NewIdentityRepositoryImpl(database *db.Database) domain.IdentityRepository {
	return &IdentityRepositoryImpl{database: database}
}

func (r *IdentityRepositoryImpl) FindByProvider(ctx context.Context, provider domain.AuthProvider, sub string) (*domain.UserIdentity, error) {
	var m AuthUserIdentityModel
	err := r.database.WithContext(ctx).
		Where("provider = ? AND provider_sub = ?", string(provider), sub).
		First(&m).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return &domain.UserIdentity{
		ID:          m.ID,
		UserID:      m.UserID,
		Provider:    domain.AuthProvider(m.Provider),
		ProviderSub: m.ProviderSub,
		DisplayName: m.DisplayName,
		CreatedAt:   m.CreatedAt,
	}, nil
}

func (r *IdentityRepositoryImpl) ListByUserID(ctx context.Context, userID uint) ([]domain.UserIdentity, error) {
	var rows []AuthUserIdentityModel
	if err := r.database.WithContext(ctx).Where("user_id = ?", userID).Order("id ASC").Find(&rows).Error; err != nil {
		return nil, err
	}
	out := make([]domain.UserIdentity, 0, len(rows))
	for _, m := range rows {
		out = append(out, domain.UserIdentity{
			ID:          m.ID,
			UserID:      m.UserID,
			Provider:    domain.AuthProvider(m.Provider),
			ProviderSub: m.ProviderSub,
			DisplayName: m.DisplayName,
			CreatedAt:   m.CreatedAt,
		})
	}
	return out, nil
}

func (r *IdentityRepositoryImpl) UpsertTx(ctx context.Context, tx unitofwork.Tx, id *domain.UserIdentity) error {
	m := AuthUserIdentityModel{
		UserID:      id.UserID,
		Provider:    string(id.Provider),
		ProviderSub: id.ProviderSub,
		DisplayName: id.DisplayName,
	}
	return txDB(ctx, r.database, tx).
		Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "provider"}, {Name: "provider_sub"}},
			DoUpdates: clause.AssignmentColumns([]string{"display_name", "updated_at"}),
		}).
		Create(&m).Error
}

func (r *IdentityRepositoryImpl) DeleteByUserAndProvider(ctx context.Context, userID uint, provider domain.AuthProvider) error {
	return r.database.WithContext(ctx).
		Where("user_id = ? AND provider = ?", userID, string(provider)).
		Delete(&AuthUserIdentityModel{}).Error
}

// --- OTPRepository ---

type OTPRepositoryImpl struct {
	database *db.Database
}

// @inject
func NewOTPRepositoryImpl(database *db.Database) domain.OTPRepository {
	return &OTPRepositoryImpl{database: database}
}

func (r *OTPRepositoryImpl) Create(ctx context.Context, c *domain.OTPChallenge) error {
	m := &AuthOTPChallengeModel{
		ID:          c.ID,
		PhoneE164:   c.PhoneE164,
		CodeHash:    c.CodeHash,
		Attempts:    c.Attempts,
		MaxAttempts: c.MaxAttempts,
		ExpiresAt:   c.ExpiresAt,
		ConsumedAt:  c.ConsumedAt,
		CreatedAt:   c.CreatedAt,
	}
	return r.database.WithContext(ctx).Create(m).Error
}

func (r *OTPRepositoryImpl) FindLatestActiveByPhone(ctx context.Context, phoneE164 string) (*domain.OTPChallenge, error) {
	var m AuthOTPChallengeModel
	err := r.database.WithContext(ctx).
		Where("phone_e164 = ? AND consumed_at IS NULL", phoneE164).
		Order("created_at DESC").
		First(&m).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return &domain.OTPChallenge{
		ID:          m.ID,
		PhoneE164:   m.PhoneE164,
		CodeHash:    m.CodeHash,
		Attempts:    m.Attempts,
		MaxAttempts: m.MaxAttempts,
		ExpiresAt:   m.ExpiresAt,
		ConsumedAt:  m.ConsumedAt,
		CreatedAt:   m.CreatedAt,
	}, nil
}

func (r *OTPRepositoryImpl) CountSentSince(ctx context.Context, phoneE164 string, since time.Time) (int64, error) {
	var count int64
	err := r.database.WithContext(ctx).
		Model(&AuthOTPChallengeModel{}).
		Where("phone_e164 = ? AND created_at >= ?", phoneE164, since).
		Count(&count).Error
	return count, err
}

func (r *OTPRepositoryImpl) Update(ctx context.Context, c *domain.OTPChallenge) error {
	return r.database.WithContext(ctx).
		Model(&AuthOTPChallengeModel{}).
		Where("id = ?", c.ID).
		Updates(map[string]any{
			"attempts":    c.Attempts,
			"consumed_at": c.ConsumedAt,
		}).Error
}

// --- SessionRepository ---

type SessionRepositoryImpl struct {
	database *db.Database
}

// @inject
func NewSessionRepositoryImpl(database *db.Database) domain.SessionRepository {
	return &SessionRepositoryImpl{database: database}
}

func (r *SessionRepositoryImpl) Create(ctx context.Context, s *domain.AuthSession) error {
	return r.CreateTx(ctx, nil, s)
}

func (r *SessionRepositoryImpl) CreateTx(ctx context.Context, tx unitofwork.Tx, s *domain.AuthSession) error {
	m := &AuthSessionModel{
		ID:               s.ID,
		UserID:           s.UserID,
		RefreshTokenHash: s.RefreshTokenHash,
		AuthMethod:       string(s.AuthMethod),
		IP:               s.IP,
		UserAgent:        s.UserAgent,
		ExpiresAt:        s.ExpiresAt,
		RevokedAt:        s.RevokedAt,
	}
	return txDB(ctx, r.database, tx).Create(m).Error
}

func (r *SessionRepositoryImpl) FindByID(ctx context.Context, id uuid.UUID) (*domain.AuthSession, error) {
	var m AuthSessionModel
	if err := r.database.WithContext(ctx).Where("id = ?", id).First(&m).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return sessionModelToDomain(&m), nil
}

func (r *SessionRepositoryImpl) FindByRefreshHash(ctx context.Context, hash []byte) (*domain.AuthSession, error) {
	var m AuthSessionModel
	if err := r.database.WithContext(ctx).Where("refresh_token_hash = ?", hash).First(&m).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return sessionModelToDomain(&m), nil
}

func (r *SessionRepositoryImpl) Update(ctx context.Context, s *domain.AuthSession) error {
	return r.database.WithContext(ctx).
		Model(&AuthSessionModel{}).
		Where("id = ?", s.ID).
		Updates(map[string]any{
			"refresh_token_hash": s.RefreshTokenHash,
			"expires_at":         s.ExpiresAt,
			"revoked_at":         s.RevokedAt,
		}).Error
}

func (r *SessionRepositoryImpl) Revoke(ctx context.Context, id uuid.UUID, now time.Time) error {
	return r.database.WithContext(ctx).
		Model(&AuthSessionModel{}).
		Where("id = ? AND revoked_at IS NULL", id).
		Update("revoked_at", now).Error
}

func sessionModelToDomain(m *AuthSessionModel) *domain.AuthSession {
	return &domain.AuthSession{
		ID:               m.ID,
		UserID:           m.UserID,
		RefreshTokenHash: m.RefreshTokenHash,
		AuthMethod:       domain.AuthProvider(m.AuthMethod),
		IP:               m.IP,
		UserAgent:        m.UserAgent,
		ExpiresAt:        m.ExpiresAt,
		RevokedAt:        m.RevokedAt,
		CreatedAt:        m.CreatedAt,
	}
}

// --- TelegramContactRepository ---

type TelegramContactRepositoryImpl struct {
	database *db.Database
}

// @inject
func NewTelegramContactRepositoryImpl(database *db.Database) domain.TelegramContactRepository {
	return &TelegramContactRepositoryImpl{database: database}
}

func (r *TelegramContactRepositoryImpl) FindByTelegramUserID(ctx context.Context, telegramUserID int64) (*domain.TelegramContact, error) {
	var m AuthTelegramContactModel
	if err := r.database.WithContext(ctx).Where("telegram_user_id = ?", telegramUserID).First(&m).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return &domain.TelegramContact{
		TelegramUserID: m.TelegramUserID,
		ChatID:         m.ChatID,
		PhoneE164:      m.PhoneE164,
		FirstName:      m.FirstName,
		LastName:       m.LastName,
		Username:       m.Username,
		BlockedAt:      m.BlockedAt,
		UpdatedAt:      m.UpdatedAt,
	}, nil
}

func (r *TelegramContactRepositoryImpl) Upsert(ctx context.Context, c *domain.TelegramContact) error {
	m := AuthTelegramContactModel{
		TelegramUserID: c.TelegramUserID,
		ChatID:         c.ChatID,
		PhoneE164:      c.PhoneE164,
		FirstName:      c.FirstName,
		LastName:       c.LastName,
		Username:       c.Username,
		BlockedAt:      c.BlockedAt,
	}
	return r.database.WithContext(ctx).
		Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "telegram_user_id"}},
			DoUpdates: clause.AssignmentColumns([]string{"chat_id", "phone_e164", "first_name", "last_name", "username", "blocked_at", "updated_at"}),
		}).
		Create(&m).Error
}

// --- TelegramAttemptRepository ---

type TelegramAttemptRepositoryImpl struct {
	database *db.Database
}

// @inject
func NewTelegramAttemptRepositoryImpl(database *db.Database) domain.TelegramAttemptRepository {
	return &TelegramAttemptRepositoryImpl{database: database}
}

func (r *TelegramAttemptRepositoryImpl) Create(ctx context.Context, a *domain.TelegramLoginAttempt) error {
	m := &AuthTelegramLoginAttemptModel{
		ID:             a.ID,
		TokenHash:      a.TokenHash,
		SecretHash:     a.SecretHash,
		Status:         string(a.Status),
		RejectReason:   a.RejectReason,
		TelegramUserID: a.TelegramUserID,
		ChatID:         a.ChatID,
		IP:             a.IP,
		UserAgent:      a.UserAgent,
		BotOpenedAt:    a.BotOpenedAt,
		DecidedAt:      a.DecidedAt,
		ConsumedAt:     a.ConsumedAt,
		ExpiresAt:      a.ExpiresAt,
	}
	return r.database.WithContext(ctx).Create(m).Error
}

func (r *TelegramAttemptRepositoryImpl) FindByID(ctx context.Context, id uuid.UUID) (*domain.TelegramLoginAttempt, error) {
	var m AuthTelegramLoginAttemptModel
	if err := r.database.WithContext(ctx).Where("id = ?", id).First(&m).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return attemptModelToDomain(&m), nil
}

func (r *TelegramAttemptRepositoryImpl) FindByTokenHash(ctx context.Context, tokenHash []byte) (*domain.TelegramLoginAttempt, error) {
	var m AuthTelegramLoginAttemptModel
	if err := r.database.WithContext(ctx).Where("token_hash = ?", tokenHash).First(&m).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return attemptModelToDomain(&m), nil
}

func (r *TelegramAttemptRepositoryImpl) Update(ctx context.Context, a *domain.TelegramLoginAttempt) error {
	return r.database.WithContext(ctx).
		Model(&AuthTelegramLoginAttemptModel{}).
		Where("id = ?", a.ID).
		Updates(map[string]any{
			"status":           string(a.Status),
			"reject_reason":    a.RejectReason,
			"telegram_user_id": a.TelegramUserID,
			"chat_id":          a.ChatID,
			"bot_opened_at":    a.BotOpenedAt,
			"decided_at":       a.DecidedAt,
			"consumed_at":      a.ConsumedAt,
		}).Error
}

func attemptModelToDomain(m *AuthTelegramLoginAttemptModel) *domain.TelegramLoginAttempt {
	return &domain.TelegramLoginAttempt{
		ID:             m.ID,
		TokenHash:      m.TokenHash,
		SecretHash:     m.SecretHash,
		Status:         domain.TelegramAttemptStatus(m.Status),
		RejectReason:   m.RejectReason,
		TelegramUserID: m.TelegramUserID,
		ChatID:         m.ChatID,
		IP:             m.IP,
		UserAgent:      m.UserAgent,
		BotOpenedAt:    m.BotOpenedAt,
		DecidedAt:      m.DecidedAt,
		ConsumedAt:     m.ConsumedAt,
		ExpiresAt:      m.ExpiresAt,
		CreatedAt:      m.CreatedAt,
	}
}

// --- QRAttemptRepository ---

type QRAttemptRepositoryImpl struct {
	database *db.Database
}

// @inject
func NewQRAttemptRepositoryImpl(database *db.Database) domain.QRAttemptRepository {
	return &QRAttemptRepositoryImpl{database: database}
}

func (r *QRAttemptRepositoryImpl) Create(ctx context.Context, a *domain.QRLoginAttempt) error {
	m := &AuthQRLoginAttemptModel{
		ID:                a.ID,
		TokenHash:         a.TokenHash,
		SecretHash:        a.SecretHash,
		Status:            string(a.Status),
		TelegramAttemptID: a.TelegramAttemptID,
		ApprovedUserID:    a.ApprovedUserID,
		ApprovedRegToken:  a.ApprovedRegToken,
		ApprovedMethod:    string(a.ApprovedMethod),
		IP:                a.IP,
		UserAgent:         a.UserAgent,
		ScannedAt:         a.ScannedAt,
		DecidedAt:         a.DecidedAt,
		ConsumedAt:        a.ConsumedAt,
		ExpiresAt:         a.ExpiresAt,
	}
	return r.database.WithContext(ctx).Create(m).Error
}

func (r *QRAttemptRepositoryImpl) FindByID(ctx context.Context, id uuid.UUID) (*domain.QRLoginAttempt, error) {
	var m AuthQRLoginAttemptModel
	if err := r.database.WithContext(ctx).Where("id = ?", id).First(&m).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return qrAttemptModelToDomain(&m), nil
}

func (r *QRAttemptRepositoryImpl) FindByTokenHash(ctx context.Context, tokenHash []byte) (*domain.QRLoginAttempt, error) {
	var m AuthQRLoginAttemptModel
	if err := r.database.WithContext(ctx).Where("token_hash = ?", tokenHash).First(&m).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return qrAttemptModelToDomain(&m), nil
}

func (r *QRAttemptRepositoryImpl) Update(ctx context.Context, a *domain.QRLoginAttempt) error {
	return r.database.WithContext(ctx).
		Model(&AuthQRLoginAttemptModel{}).
		Where("id = ?", a.ID).
		Updates(map[string]any{
			"status":              string(a.Status),
			"telegram_attempt_id": a.TelegramAttemptID,
			"approved_user_id":    a.ApprovedUserID,
			"approved_reg_token":  a.ApprovedRegToken,
			"approved_method":     string(a.ApprovedMethod),
			"scanned_at":          a.ScannedAt,
			"decided_at":          a.DecidedAt,
			"consumed_at":         a.ConsumedAt,
		}).Error
}

func qrAttemptModelToDomain(m *AuthQRLoginAttemptModel) *domain.QRLoginAttempt {
	return &domain.QRLoginAttempt{
		ID:                m.ID,
		TokenHash:         m.TokenHash,
		SecretHash:        m.SecretHash,
		Status:            domain.QRAttemptStatus(m.Status),
		TelegramAttemptID: m.TelegramAttemptID,
		ApprovedUserID:    m.ApprovedUserID,
		ApprovedRegToken:  m.ApprovedRegToken,
		ApprovedMethod:    domain.AuthProvider(m.ApprovedMethod),
		IP:                m.IP,
		UserAgent:         m.UserAgent,
		ScannedAt:         m.ScannedAt,
		DecidedAt:         m.DecidedAt,
		ConsumedAt:        m.ConsumedAt,
		ExpiresAt:         m.ExpiresAt,
		CreatedAt:         m.CreatedAt,
	}
}
