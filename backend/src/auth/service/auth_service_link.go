package service

import (
	"context"
	"errors"
	"strconv"
	"strings"

	"github.com/google/uuid"
	"github.com/muhriddinnorqulov/skeleton/src/auth/domain"
	"github.com/muhriddinnorqulov/skeleton/src/core/domain/entity"
	"github.com/muhriddinnorqulov/skeleton/src/core/domain/ports/unitofwork"
)

const LinkStatusLinked = "linked"

type LinkAccountResult struct {
	Merged  bool                  `json:"merged"`
	User    *entity.UserEntity    `json:"user"`
	Methods []domain.UserIdentity `json:"methods"`
	Tokens  *domain.AuthTokens    `json:"tokens,omitempty"`
}

type TelegramLinkPollResult struct {
	Status    string                `json:"status"`
	Merged    bool                  `json:"merged,omitempty"`
	BotOpened *bool                 `json:"bot_opened,omitempty"`
	User      *entity.UserEntity    `json:"user,omitempty"`
	Methods   []domain.UserIdentity `json:"methods,omitempty"`
	Tokens    *domain.AuthTokens    `json:"tokens,omitempty"`
}

// LinkGoogleCallback links a verified Google account to the currently signed-in user.
// If that Google account already belongs to another account, both accounts are merged into one.
func (s *AuthService) LinkGoogleCallback(ctx context.Context, current *entity.UserEntity, code, codeVerifier string, meta domain.ClientMeta) (*LinkAccountResult, error) {
	profile, err := s.google.Exchange(ctx, code, codeVerifier)
	if err != nil {
		return nil, err
	}
	return s.linkGoogleProfile(ctx, current, profile, meta)
}

// LinkGoogleIDToken links a Google account from native Flutter/mobile Google Sign-In.
func (s *AuthService) LinkGoogleIDToken(ctx context.Context, current *entity.UserEntity, idToken string, meta domain.ClientMeta) (*LinkAccountResult, error) {
	profile, err := s.google.VerifyIDToken(ctx, idToken)
	if err != nil {
		return nil, err
	}
	return s.linkGoogleProfile(ctx, current, profile, meta)
}

func (s *AuthService) linkGoogleProfile(ctx context.Context, current *entity.UserEntity, profile *domain.GoogleProfile, meta domain.ClientMeta) (*LinkAccountResult, error) {
	if !profile.EmailVerified {
		return nil, domain.ErrGoogleEmailUnverified
	}

	var otherUserID uint
	if existing, err := s.identities.FindByProvider(ctx, domain.ProviderGoogle, profile.Subject); err == nil && existing != nil && existing.UserID != current.ID {
		otherUserID = existing.UserID
	} else if profile.Email != "" {
		if existing, err := s.users.FindByEmail(ctx, profile.Email); err == nil && existing != nil && existing.ID != current.ID {
			otherUserID = existing.ID
		}
	}

	if otherUserID != 0 {
		return s.mergeAndLink(ctx, current, otherUserID, domain.ProviderGoogle, meta, func(tx unitofwork.Tx, primary *entity.UserEntity) error {
			return s.identities.UpsertTx(ctx, tx, &domain.UserIdentity{
				UserID:      primary.ID,
				Provider:    domain.ProviderGoogle,
				ProviderSub: profile.Subject,
				DisplayName: profile.Email,
			})
		})
	}

	if err := s.identities.UpsertTx(ctx, nil, &domain.UserIdentity{
		UserID:      current.ID,
		Provider:    domain.ProviderGoogle,
		ProviderSub: profile.Subject,
		DisplayName: profile.Email,
	}); err != nil {
		return nil, err
	}

	updated := *current
	changed := false
	if (updated.Email == nil || *updated.Email == "") && profile.Email != "" {
		em := profile.Email
		updated.Email = &em
		changed = true
	}
	if (updated.AvatarURL == nil || *updated.AvatarURL == "") && profile.AvatarURL != "" {
		av := profile.AvatarURL
		updated.AvatarURL = &av
		changed = true
	}
	if changed {
		if saved, err := s.users.UpdateProfile(ctx, &updated); err == nil && saved != nil {
			current = saved
		}
	}
	me, err := s.GetMe(ctx, current)
	if err != nil {
		return nil, err
	}
	return &LinkAccountResult{Merged: false, User: me.User, Methods: me.Methods}, nil
}

// StartTelegramLink creates a 5-minute Telegram bot deep link for linking Telegram to the current profile.
func (s *AuthService) StartTelegramLink(ctx context.Context, meta domain.ClientMeta) (*StartTelegramResult, error) {
	return s.StartTelegramLogin(ctx, meta)
}

// PollTelegramLink checks whether the user confirmed the link attempt in @ilmfan_auth_bot.
// If the Telegram account or its verified phone already belongs to another account, both accounts merge into one.
func (s *AuthService) PollTelegramLink(ctx context.Context, current *entity.UserEntity, attemptID uuid.UUID, secret string, meta domain.ClientMeta) (*TelegramLinkPollResult, error) {
	attempt, err := s.tgAttempts.FindByID(ctx, attemptID)
	if errors.Is(err, domain.ErrNotFound) || (err == nil && !s.tokens.VerifyHash(secret, attempt.SecretHash)) {
		return nil, domain.ErrTelegramNotFound
	}
	if err != nil {
		return nil, err
	}

	now := s.now()
	switch attempt.Status {
	case domain.TelegramStatusUsed:
		return nil, domain.ErrTelegramUsed
	case domain.TelegramStatusRejected:
		return nil, domain.ErrTelegramRejected
	case domain.TelegramStatusPending:
		if attempt.IsExpired(now) {
			return nil, domain.ErrTelegramExpired
		}
		opened := attempt.BotOpenedAt != nil
		return &TelegramLinkPollResult{Status: LoginStatusPending, BotOpened: &opened}, nil
	case domain.TelegramStatusConfirmed:
		if attempt.IsExpired(now) {
			return nil, domain.ErrTelegramExpired
		}
	default:
		return nil, domain.ErrTelegramNotFound
	}

	if attempt.TelegramUserID == nil {
		return nil, domain.ErrTelegramNotFound
	}
	contact, err := s.tgContacts.FindByTelegramUserID(ctx, *attempt.TelegramUserID)
	if err != nil {
		return nil, domain.ErrTelegramNotFound
	}

	attempt.Status = domain.TelegramStatusUsed
	attempt.ConsumedAt = &now
	if err := s.tgAttempts.Update(ctx, attempt); err != nil {
		return nil, err
	}

	tgSub := strconv.FormatInt(*attempt.TelegramUserID, 10)
	tgDisplay := formatTelegramDisplay(contact)

	var otherUserID uint
	if existing, err := s.identities.FindByProvider(ctx, domain.ProviderTelegram, tgSub); err == nil && existing != nil && existing.UserID != current.ID {
		otherUserID = existing.UserID
	} else if contact.PhoneE164 != "" {
		if existing, err := s.findUserByPhone(ctx, contact.PhoneE164); err == nil && existing != nil && existing.ID != current.ID {
			otherUserID = existing.ID
		}
	}

	if otherUserID != 0 {
		merged, err := s.mergeAndLink(ctx, current, otherUserID, domain.ProviderTelegram, meta, func(tx unitofwork.Tx, primary *entity.UserEntity) error {
			return s.identities.UpsertTx(ctx, tx, &domain.UserIdentity{
				UserID:      primary.ID,
				Provider:    domain.ProviderTelegram,
				ProviderSub: tgSub,
				DisplayName: tgDisplay,
			})
		})
		if err != nil {
			return nil, err
		}
		return &TelegramLinkPollResult{
			Status:  LinkStatusLinked,
			Merged:  true,
			User:    merged.User,
			Methods: merged.Methods,
			Tokens:  merged.Tokens,
		}, nil
	}

	if err := s.identities.UpsertTx(ctx, nil, &domain.UserIdentity{
		UserID:      current.ID,
		Provider:    domain.ProviderTelegram,
		ProviderSub: tgSub,
		DisplayName: tgDisplay,
	}); err != nil {
		return nil, err
	}

	if (current.Phone == nil || *current.Phone == "") && contact.PhoneE164 != "" {
		updated := *current
		ph := contact.PhoneE164
		updated.Phone = &ph
		if saved, err := s.users.UpdateProfile(ctx, &updated); err == nil && saved != nil {
			current = saved
		}
		masked := contact.PhoneE164
		if p, err := domain.ParsePhoneNumber(contact.PhoneE164); err == nil {
			masked = p.Masked()
		}
		_ = s.identities.UpsertTx(ctx, nil, &domain.UserIdentity{
			UserID:      current.ID,
			Provider:    domain.ProviderPhone,
			ProviderSub: contact.PhoneE164,
			DisplayName: masked,
		})
	}

	me, err := s.GetMe(ctx, current)
	if err != nil {
		return nil, err
	}
	return &TelegramLinkPollResult{
		Status:  LinkStatusLinked,
		Merged:  false,
		User:    me.User,
		Methods: me.Methods,
	}, nil
}

// VerifyAndLinkPhone verifies an SMS OTP code and attaches the verified phone to the signed-in user.
// If that phone already belongs to another account, both accounts are merged into one.
func (s *AuthService) VerifyAndLinkPhone(ctx context.Context, current *entity.UserEntity, rawPhone, code string, meta domain.ClientMeta) (*LinkAccountResult, error) {
	phone, err := domain.ParsePhoneNumber(rawPhone)
	if err != nil {
		return nil, err
	}
	if err := s.throttle.Check(meta.IP, phone.E164); err != nil {
		return nil, err
	}

	challenge, err := s.otps.FindLatestActiveByPhone(ctx, phone.E164)
	if errors.Is(err, domain.ErrNotFound) {
		s.throttle.Failure(meta.IP, phone.E164)
		return nil, domain.ErrOTPNotFound
	}
	if err != nil {
		return nil, err
	}

	now := s.now()
	if challenge.IsExpired(now) {
		return nil, domain.ErrOTPExpired
	}
	if challenge.Attempts >= challenge.MaxAttempts {
		return nil, domain.ErrOTPAttemptsExceeded
	}
	if !s.otpCodes.Verify(challenge.ID, strings.TrimSpace(code), challenge.CodeHash) {
		challenge.Attempts++
		_ = s.otps.Update(ctx, challenge)
		s.throttle.Failure(meta.IP, phone.E164)
		left := challenge.MaxAttempts - challenge.Attempts
		if left <= 0 {
			return nil, domain.ErrOTPAttemptsExceeded
		}
		return nil, domain.ErrOTPInvalid(left)
	}

	challenge.ConsumedAt = &now
	if err := s.otps.Update(ctx, challenge); err != nil {
		return nil, err
	}
	s.throttle.Success(meta.IP, phone.E164)

	var otherUserID uint
	if existing, err := s.findUserByPhone(ctx, phone.E164); err == nil && existing != nil && existing.ID != current.ID {
		otherUserID = existing.ID
	}

	if otherUserID != 0 {
		return s.mergeAndLink(ctx, current, otherUserID, domain.ProviderPhone, meta, func(tx unitofwork.Tx, primary *entity.UserEntity) error {
			return s.identities.UpsertTx(ctx, tx, &domain.UserIdentity{
				UserID:      primary.ID,
				Provider:    domain.ProviderPhone,
				ProviderSub: phone.E164,
				DisplayName: phone.Masked(),
			})
		})
	}

	_ = s.identities.DeleteByUserAndProvider(ctx, current.ID, domain.ProviderPhone)
	if err := s.identities.UpsertTx(ctx, nil, &domain.UserIdentity{
		UserID:      current.ID,
		Provider:    domain.ProviderPhone,
		ProviderSub: phone.E164,
		DisplayName: phone.Masked(),
	}); err != nil {
		return nil, err
	}

	updated := *current
	ph := phone.E164
	updated.Phone = &ph
	saved, err := s.users.UpdateProfile(ctx, &updated)
	if err != nil {
		return nil, err
	}
	me, err := s.GetMe(ctx, saved)
	if err != nil {
		return nil, err
	}
	return &LinkAccountResult{Merged: false, User: me.User, Methods: me.Methods}, nil
}

// UnlinkMethod removes a login method as long as at least one other method remains linked.
func (s *AuthService) UnlinkMethod(ctx context.Context, current *entity.UserEntity, providerRaw string) (*MeResult, error) {
	provider := domain.AuthProvider(strings.ToLower(strings.TrimSpace(providerRaw)))
	switch provider {
	case domain.ProviderGoogle, domain.ProviderTelegram, domain.ProviderPhone:
	default:
		return nil, domain.ErrInvalidProvider
	}

	methods, err := s.identities.ListByUserID(ctx, current.ID)
	if err != nil {
		return nil, err
	}
	hasTarget := false
	for _, m := range methods {
		if m.Provider == provider {
			hasTarget = true
			break
		}
	}
	if !hasTarget {
		return s.GetMe(ctx, current)
	}
	if len(methods) <= 1 {
		return nil, domain.ErrLastLoginMethod
	}

	if err := s.identities.DeleteByUserAndProvider(ctx, current.ID, provider); err != nil {
		return nil, err
	}
	return s.GetMe(ctx, current)
}

// mergeAndLink atomically merges current and otherUserID into the older (smaller ID) account,
// runs optional post-merge identity upsert, and issues fresh tokens for the surviving primary account.
func (s *AuthService) mergeAndLink(
	ctx context.Context,
	current *entity.UserEntity,
	otherUserID uint,
	method domain.AuthProvider,
	meta domain.ClientMeta,
	afterMerge func(tx unitofwork.Tx, primary *entity.UserEntity) error,
) (*LinkAccountResult, error) {
	other, err := s.users.FindByID(ctx, otherUserID)
	if err != nil {
		return nil, err
	}
	if other.IsBlocked || current.IsBlocked {
		return nil, domain.ErrUserBlocked
	}

	primaryID, secondaryID := otherUserID, current.ID
	if current.ID < otherUserID {
		primaryID, secondaryID = current.ID, otherUserID
	}

	var mergedUser *entity.UserEntity
	var freshTokens *domain.AuthTokens
	err = s.atomic.Transaction(func(tx unitofwork.Tx) error {
		u, err := s.users.MergeUsersTx(ctx, tx, primaryID, secondaryID)
		if err != nil {
			return err
		}
		if afterMerge != nil {
			if err := afterMerge(tx, u); err != nil {
				return err
			}
		}
		toks, err := s.createSessionTx(ctx, tx, u, method, meta)
		if err != nil {
			return err
		}
		mergedUser = u
		freshTokens = toks
		return nil
	})
	if err != nil {
		return nil, err
	}

	me, err := s.GetMe(ctx, mergedUser)
	if err != nil {
		return nil, err
	}
	return &LinkAccountResult{
		Merged:  true,
		User:    me.User,
		Methods: me.Methods,
		Tokens:  freshTokens,
	}, nil
}
