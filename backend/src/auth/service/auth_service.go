package service

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/muhriddinnorqulov/skeleton/src/auth/domain"
	"github.com/muhriddinnorqulov/skeleton/src/core/domain/entity"
	coresec "github.com/muhriddinnorqulov/skeleton/src/core/domain/ports/security"
	"github.com/muhriddinnorqulov/skeleton/src/core/domain/ports/unitofwork"
	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/env"
)

const (
	LoginStatusAuthenticated        = "authenticated"
	LoginStatusRegistrationRequired = "registration_required"
	LoginStatusPending              = "pending"
)

type accessTokenPayload struct {
	UserID    uint   `json:"uid"`
	SessionID string `json:"sid"`
	Role      string `json:"role,omitempty"`
}

type SendSMSResult struct {
	PhoneMasked        string `json:"phone_masked"`
	ExpiresInSeconds   int    `json:"expires_in_seconds"`
	ResendAfterSeconds int    `json:"resend_after_seconds"`
}

type RegistrationPrompt struct {
	Token     string    `json:"token"`
	ExpiresAt time.Time `json:"expires_at"`
}

type LoginResult struct {
	Status       string              `json:"status"`
	Tokens       *domain.AuthTokens  `json:"tokens,omitempty"`
	User         *entity.UserEntity  `json:"user,omitempty"`
	Registration *RegistrationPrompt `json:"registration,omitempty"`
	BotOpened    *bool               `json:"bot_opened,omitempty"`
}

type StartTelegramResult struct {
	AttemptID   uuid.UUID `json:"attempt_id"`
	Secret      string    `json:"secret"`
	StartToken  string    `json:"start_token"`
	BotUsername string    `json:"bot_username"`
	DeepLink    string    `json:"deep_link"`
	ExpiresAt   time.Time `json:"expires_at"`
}

type InspectRegistrationResult struct {
	Method        domain.AuthProvider `json:"method"`
	Phone         string              `json:"phone,omitempty"`
	PhoneMasked   string              `json:"phone_masked,omitempty"`
	PhoneVerified bool                `json:"phone_verified"`
	Email         string              `json:"email,omitempty"`
	FirstName     string              `json:"first_name,omitempty"`
	LastName      string              `json:"last_name,omitempty"`
	AvatarURL     string              `json:"avatar_url,omitempty"`
	ExpiresAt     time.Time           `json:"expires_at"`
}

type CompleteRegistrationInput struct {
	RegistrationToken string
	Role              string
	FanIDs            []string
	FirstName         string
	LastName          string
	Phone             string
	BirthDate         string
	Region            string
	Gender            string
	AvatarURL         string
}

type UpdateProfileInput struct {
	FirstName string
	LastName  string
	Phone     string
	BirthDate string
	Region    string
	Gender    string
	AvatarURL string
}

type MeResult struct {
	User    *entity.UserEntity    `json:"user"`
	Methods []domain.UserIdentity `json:"methods"`
}

type AuthService struct {
	cfg        *env.Env
	atomic     unitofwork.Atomic
	users      domain.UserStore
	identities domain.IdentityRepository
	otps       domain.OTPRepository
	sessions   domain.SessionRepository
	tgContacts domain.TelegramContactRepository
	tgAttempts domain.TelegramAttemptRepository
	qrAttempts domain.QRAttemptRepository
	sms        domain.SMSSender
	google     domain.GoogleOAuth
	otpCodes   domain.OTPCodeService
	tickets    domain.RegistrationTicketSealer
	tokens     domain.TokenService
	jwt        coresec.JwtTokenProvider
	throttle   domain.RateThrottle
	now        func() time.Time
}

// @inject
func NewAuthService(
	cfg *env.Env,
	atomic unitofwork.Atomic,
	users domain.UserStore,
	identities domain.IdentityRepository,
	otps domain.OTPRepository,
	sessions domain.SessionRepository,
	tgContacts domain.TelegramContactRepository,
	tgAttempts domain.TelegramAttemptRepository,
	qrAttempts domain.QRAttemptRepository,
	sms domain.SMSSender,
	google domain.GoogleOAuth,
	otpCodes domain.OTPCodeService,
	tickets domain.RegistrationTicketSealer,
	tokens domain.TokenService,
	jwt coresec.JwtTokenProvider,
	throttle domain.RateThrottle,
) *AuthService {
	return &AuthService{
		cfg:        cfg,
		atomic:     atomic,
		users:      users,
		identities: identities,
		otps:       otps,
		sessions:   sessions,
		tgContacts: tgContacts,
		tgAttempts: tgAttempts,
		qrAttempts: qrAttempts,
		sms:        sms,
		google:     google,
		otpCodes:   otpCodes,
		tickets:    tickets,
		tokens:     tokens,
		jwt:        jwt,
		throttle:   throttle,
		now:        time.Now,
	}
}

// @inject
func NewAccessTokenVerifier(svc *AuthService) domain.AccessTokenVerifier {
	return svc
}

// --- Phone SMS OTP ---

func (s *AuthService) SendSMSOTP(ctx context.Context, rawPhone string, meta domain.ClientMeta) (*SendSMSResult, error) {
	phone, err := domain.ParsePhoneNumber(rawPhone)
	if err != nil {
		return nil, err
	}
	if err := s.throttle.Check(meta.IP, phone.E164); err != nil {
		return nil, err
	}

	now := s.now()
	sentCount, err := s.otps.CountSentSince(ctx, phone.E164, now.Add(-24*time.Hour))
	if err != nil {
		return nil, err
	}
	if sentCount >= domain.OTPDailyLimit {
		return nil, domain.ErrOTPDailyLimit
	}

	latest, err := s.otps.FindLatestActiveByPhone(ctx, phone.E164)
	if err != nil && !errors.Is(err, domain.ErrNotFound) {
		return nil, err
	}
	if latest != nil {
		elapsed := now.Sub(latest.CreatedAt)
		if elapsed < domain.OTPResendCooldown {
			retry := int((domain.OTPResendCooldown - elapsed).Seconds())
			if retry < 1 {
				retry = 1
			}
			return nil, domain.ErrOTPResendCooldown(retry)
		}
	}

	code, err := s.otpCodes.Generate()
	if err != nil {
		return nil, err
	}
	challengeID := uuid.New()
	challenge := &domain.OTPChallenge{
		ID:          challengeID,
		PhoneE164:   phone.E164,
		CodeHash:    s.otpCodes.Hash(challengeID, code),
		Attempts:    0,
		MaxAttempts: domain.OTPMaxAttempts,
		ExpiresAt:   now.Add(domain.OTPTTL),
		CreatedAt:   now,
	}
	if err := s.otps.Create(ctx, challenge); err != nil {
		return nil, err
	}

	existingUser, err := s.findUserByPhone(ctx, phone.E164)
	if err != nil {
		return nil, err
	}
	var text string
	if tmpl := strings.TrimSpace(s.cfg.SMSOTPTemplate); tmpl != "" {
		text = strings.ReplaceAll(tmpl, "{code}", code)
	} else {
		appDomain := strings.TrimSpace(s.cfg.SMSAppDomain)
		if appDomain == "" {
			appDomain = "sat-ilmfan.gvazar.uz"
		}
		if existingUser != nil {
			text = fmt.Sprintf("%s tizimiga kirish uchun tasdiqlash kod: %s", appDomain, code)
		} else {
			text = fmt.Sprintf("%s tizimida ro'yxatdan o'tish uchun tasdiqlash kod: %s", appDomain, code)
		}
	}
	if err := s.sms.Send(ctx, phone.E164, text); err != nil {
		return nil, err
	}

	return &SendSMSResult{
		PhoneMasked:        phone.Masked(),
		ExpiresInSeconds:   int(domain.OTPTTL.Seconds()),
		ResendAfterSeconds: int(domain.OTPResendCooldown.Seconds()),
	}, nil
}

func (s *AuthService) consumeSMSOTP(ctx context.Context, phone domain.PhoneNumber, code string, meta domain.ClientMeta) error {
	if err := s.throttle.Check(meta.IP, phone.E164); err != nil {
		return err
	}

	challenge, err := s.otps.FindLatestActiveByPhone(ctx, phone.E164)
	if errors.Is(err, domain.ErrNotFound) {
		s.throttle.Failure(meta.IP, phone.E164)
		return domain.ErrOTPNotFound
	}
	if err != nil {
		return err
	}

	now := s.now()
	if challenge.IsExpired(now) {
		return domain.ErrOTPExpired
	}
	if challenge.Attempts >= challenge.MaxAttempts {
		return domain.ErrOTPAttemptsExceeded
	}

	if !s.otpCodes.Verify(challenge.ID, strings.TrimSpace(code), challenge.CodeHash) {
		challenge.Attempts++
		_ = s.otps.Update(ctx, challenge)
		s.throttle.Failure(meta.IP, phone.E164)
		left := challenge.MaxAttempts - challenge.Attempts
		if left <= 0 {
			return domain.ErrOTPAttemptsExceeded
		}
		return domain.ErrOTPInvalid(left)
	}

	challenge.ConsumedAt = &now
	if err := s.otps.Update(ctx, challenge); err != nil {
		return err
	}
	s.throttle.Success(meta.IP, phone.E164)
	return nil
}

func (s *AuthService) VerifySMSOTP(ctx context.Context, rawPhone, code string, meta domain.ClientMeta) (*LoginResult, error) {
	phone, err := domain.ParsePhoneNumber(rawPhone)
	if err != nil {
		return nil, err
	}
	if err := s.consumeSMSOTP(ctx, phone, code, meta); err != nil {
		return nil, err
	}

	now := s.now()
	user, err := s.findUserByPhone(ctx, phone.E164)
	if err != nil {
		return nil, err
	}
	if user != nil {
		return s.issueAuthenticatedResult(ctx, user, domain.ProviderPhone, meta)
	}

	ticket := &domain.RegistrationTicket{
		Method:        domain.ProviderPhone,
		Phone:         &phone,
		PhoneVerified: true,
		ExpiresAt:     now.Add(domain.RegistrationTTL),
	}
	return s.issueRegistrationResult(ticket)
}

// --- Google OAuth (Web PKCE + Mobile ID Token; phone is NOT required) ---

func (s *AuthService) StartGoogleLogin() (*domain.GoogleAuthStart, error) {
	return s.google.Start()
}

func (s *AuthService) GoogleCallback(ctx context.Context, code, codeVerifier string, meta domain.ClientMeta) (*LoginResult, error) {
	profile, err := s.google.Exchange(ctx, code, codeVerifier)
	if err != nil {
		return nil, err
	}
	return s.finishGoogleLogin(ctx, profile, meta)
}

func (s *AuthService) GoogleIDTokenLogin(ctx context.Context, idToken string, meta domain.ClientMeta) (*LoginResult, error) {
	profile, err := s.google.VerifyIDToken(ctx, idToken)
	if err != nil {
		return nil, err
	}
	return s.finishGoogleLogin(ctx, profile, meta)
}

func (s *AuthService) finishGoogleLogin(ctx context.Context, profile *domain.GoogleProfile, meta domain.ClientMeta) (*LoginResult, error) {
	if !profile.EmailVerified {
		return nil, domain.ErrGoogleEmailUnverified
	}

	// 1. Existing Google identity
	identity, err := s.identities.FindByProvider(ctx, domain.ProviderGoogle, profile.Subject)
	if err != nil && !errors.Is(err, domain.ErrNotFound) {
		return nil, err
	}
	if identity != nil {
		user, err := s.users.FindByID(ctx, identity.UserID)
		if err != nil {
			return nil, err
		}
		return s.issueAuthenticatedResult(ctx, user, domain.ProviderGoogle, meta)
	}

	// 2. Existing user with matching verified email -> link Google automatically
	if profile.Email != "" {
		user, err := s.users.FindByEmail(ctx, profile.Email)
		if err != nil && !errors.Is(err, domain.ErrNotFound) {
			return nil, err
		}
		if user != nil {
			_ = s.identities.UpsertTx(ctx, nil, &domain.UserIdentity{
				UserID:      user.ID,
				Provider:    domain.ProviderGoogle,
				ProviderSub: profile.Subject,
				DisplayName: profile.Email,
			})
			return s.issueAuthenticatedResult(ctx, user, domain.ProviderGoogle, meta)
		}
	}

	// 3. New user -> registration ticket directly (NO phone required!)
	now := s.now()
	ticket := &domain.RegistrationTicket{
		Method: domain.ProviderGoogle,
		Google: &domain.GoogleClaim{
			Subject:    profile.Subject,
			Email:      profile.Email,
			GivenName:  profile.GivenName,
			FamilyName: profile.FamilyName,
			AvatarURL:  profile.AvatarURL,
		},
		ExpiresAt: now.Add(domain.RegistrationTTL),
	}
	return s.issueRegistrationResult(ticket)
}

// --- Telegram Bot Login ---

func (s *AuthService) StartTelegramLogin(ctx context.Context, meta domain.ClientMeta) (*StartTelegramResult, error) {
	botUsername := strings.TrimPrefix(strings.TrimSpace(s.cfg.TelegramBotUsername), "@")
	if botUsername == "" {
		return nil, domain.ErrTelegramNotConfigured
	}
	startToken, tokenHash, err := s.tokens.NewOpaqueToken()
	if err != nil {
		return nil, err
	}
	secret, secretHash, err := s.tokens.NewOpaqueToken()
	if err != nil {
		return nil, err
	}
	now := s.now()
	attempt := &domain.TelegramLoginAttempt{
		ID:         uuid.New(),
		TokenHash:  tokenHash,
		SecretHash: secretHash,
		Status:     domain.TelegramStatusPending,
		IP:         meta.IP,
		UserAgent:  meta.UserAgent,
		ExpiresAt:  now.Add(domain.TelegramAttemptTTL),
		CreatedAt:  now,
	}
	if err := s.tgAttempts.Create(ctx, attempt); err != nil {
		return nil, err
	}
	return &StartTelegramResult{
		AttemptID:   attempt.ID,
		Secret:      secret,
		StartToken:  startToken,
		BotUsername: botUsername,
		DeepLink:    fmt.Sprintf("https://t.me/%s?start=%s", botUsername, startToken),
		ExpiresAt:   attempt.ExpiresAt,
	}, nil
}

func (s *AuthService) PollTelegramLogin(ctx context.Context, attemptID uuid.UUID, secret string, meta domain.ClientMeta) (*LoginResult, error) {
	attempt, err := s.tgAttempts.FindByID(ctx, attemptID)
	if errors.Is(err, domain.ErrNotFound) {
		return nil, domain.ErrTelegramNotFound
	}
	if err != nil {
		return nil, err
	}
	if !s.tokens.VerifyHash(secret, attempt.SecretHash) {
		return nil, domain.ErrTelegramNotFound
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
		return &LoginResult{
			Status:    LoginStatusPending,
			BotOpened: &opened,
		}, nil
	case domain.TelegramStatusConfirmed:
		if attempt.IsExpired(now) {
			return nil, domain.ErrTelegramExpired
		}
	default:
		return nil, domain.ErrTelegramNotFound
	}

	return s.resolveConfirmedTelegramAttempt(ctx, attempt, meta)
}

func (s *AuthService) resolveConfirmedTelegramAttempt(ctx context.Context, attempt *domain.TelegramLoginAttempt, meta domain.ClientMeta) (*LoginResult, error) {
	now := s.now()
	if attempt.TelegramUserID == nil {
		return nil, domain.ErrTelegramNotFound
	}
	contact, err := s.tgContacts.FindByTelegramUserID(ctx, *attempt.TelegramUserID)
	if err != nil {
		return nil, domain.ErrTelegramNotFound
	}

	// Mark consumed once before returning credentials.
	attempt.Status = domain.TelegramStatusUsed
	attempt.ConsumedAt = &now
	if err := s.tgAttempts.Update(ctx, attempt); err != nil {
		return nil, err
	}

	tgSub := strconv.FormatInt(*attempt.TelegramUserID, 10)
	var user *entity.UserEntity
	if identity, err := s.identities.FindByProvider(ctx, domain.ProviderTelegram, tgSub); err == nil && identity != nil {
		user, err = s.users.FindByID(ctx, identity.UserID)
		if err != nil {
			return nil, err
		}
	} else if contact.PhoneE164 != "" {
		user, err = s.findUserByPhone(ctx, contact.PhoneE164)
		if err != nil {
			return nil, err
		}
		if user != nil {
			_ = s.identities.UpsertTx(ctx, nil, &domain.UserIdentity{
				UserID:      user.ID,
				Provider:    domain.ProviderTelegram,
				ProviderSub: tgSub,
				DisplayName: formatTelegramDisplay(contact),
			})
		}
	}

	if user != nil {
		return s.issueAuthenticatedResult(ctx, user, domain.ProviderTelegram, meta)
	}

	var phonePtr *domain.PhoneNumber
	if parsed, err := domain.ParsePhoneNumber(contact.PhoneE164); err == nil {
		phonePtr = &parsed
	}
	tgID := *attempt.TelegramUserID
	ticket := &domain.RegistrationTicket{
		Method:         domain.ProviderTelegram,
		Phone:          phonePtr,
		TelegramUserID: &tgID,
		TelegramName:   strings.TrimSpace(contact.FirstName + " " + contact.LastName),
		ExpiresAt:      now.Add(domain.RegistrationTTL),
	}
	return s.issueRegistrationResult(ticket)
}

// --- Registration Completion (Role + Fan + Profile) ---

func (s *AuthService) InspectRegistration(_ context.Context, registrationToken string) (*InspectRegistrationResult, error) {
	ticket, err := s.tickets.Open(registrationToken)
	if err != nil || ticket.IsExpired(s.now()) {
		return nil, domain.ErrRegistrationTicketInvalid
	}

	out := &InspectRegistrationResult{
		Method:        ticket.Method,
		PhoneVerified: ticket.PhoneVerified || ticket.Method == domain.ProviderPhone,
		ExpiresAt:     ticket.ExpiresAt,
	}
	if ticket.Phone != nil {
		out.Phone = ticket.Phone.E164
		out.PhoneMasked = ticket.Phone.Masked()
	}
	if ticket.Google != nil {
		out.Email = ticket.Google.Email
		out.FirstName = ticket.Google.GivenName
		out.LastName = ticket.Google.FamilyName
		out.AvatarURL = ticket.Google.AvatarURL
	} else if ticket.TelegramName != "" {
		parts := strings.Fields(ticket.TelegramName)
		if len(parts) > 0 {
			out.FirstName = parts[0]
		}
		if len(parts) > 1 {
			out.LastName = strings.Join(parts[1:], " ")
		}
	}
	return out, nil
}

func (s *AuthService) VerifyRegistrationPhone(ctx context.Context, registrationToken, rawPhone, code string, meta domain.ClientMeta) (*LoginResult, error) {
	ticket, err := s.tickets.Open(registrationToken)
	if err != nil || ticket.IsExpired(s.now()) {
		return nil, domain.ErrRegistrationTicketInvalid
	}
	phone, err := domain.ParsePhoneNumber(rawPhone)
	if err != nil {
		return nil, err
	}
	if err := s.consumeSMSOTP(ctx, phone, code, meta); err != nil {
		return nil, err
	}

	now := s.now()
	existingUser, err := s.findUserByPhone(ctx, phone.E164)
	if err != nil {
		return nil, err
	}
	if existingUser != nil {
		if existingUser.IsBlocked {
			return nil, domain.ErrUserBlocked
		}
		err = s.atomic.Transaction(func(tx unitofwork.Tx) error {
			if ticket.Google != nil {
				if err := s.identities.UpsertTx(ctx, tx, &domain.UserIdentity{
					UserID:      existingUser.ID,
					Provider:    domain.ProviderGoogle,
					ProviderSub: ticket.Google.Subject,
					DisplayName: ticket.Google.Email,
				}); err != nil {
					return err
				}
			}
			if ticket.TelegramUserID != nil {
				if err := s.identities.UpsertTx(ctx, tx, &domain.UserIdentity{
					UserID:      existingUser.ID,
					Provider:    domain.ProviderTelegram,
					ProviderSub: strconv.FormatInt(*ticket.TelegramUserID, 10),
					DisplayName: ticket.TelegramName,
				}); err != nil {
					return err
				}
			}
			return nil
		})
		if err != nil {
			return nil, err
		}
		return s.issueAuthenticatedResult(ctx, existingUser, ticket.Method, meta)
	}

	ticket.Phone = &phone
	ticket.PhoneVerified = true
	ticket.ExpiresAt = now.Add(domain.RegistrationTTL)
	return s.issueRegistrationResult(ticket)
}

func (s *AuthService) CompleteRegistration(ctx context.Context, in CompleteRegistrationInput, meta domain.ClientMeta) (*LoginResult, error) {
	ticket, err := s.tickets.Open(in.RegistrationToken)
	if err != nil || ticket.IsExpired(s.now()) {
		return nil, domain.ErrRegistrationTicketInvalid
	}
	if !(ticket.PhoneVerified || ticket.Method == domain.ProviderPhone) || ticket.Phone == nil || ticket.Phone.E164 == "" {
		return nil, domain.ErrPhoneVerificationRequired
	}

	role, ok := domain.NormalizeRole(in.Role)
	if !ok {
		return nil, domain.ErrInvalidRole
	}

	firstName := strings.TrimSpace(in.FirstName)
	if firstName == "" && ticket.Google != nil {
		firstName = ticket.Google.GivenName
	}
	if firstName == "" {
		return nil, domain.NewAuthError(domain.ErrInvalidRole.ResponseCode, "INVALID_FIRST_NAME", "Ism kiritilishi shart", nil)
	}

	lastNameVal := strings.TrimSpace(in.LastName)
	if lastNameVal == "" && ticket.Google != nil {
		lastNameVal = ticket.Google.FamilyName
	}
	var lastNamePtr *string
	if lastNameVal != "" {
		lastNamePtr = &lastNameVal
	}

	avatarVal := strings.TrimSpace(in.AvatarURL)
	if avatarVal == "" && ticket.Google != nil {
		avatarVal = ticket.Google.AvatarURL
	}
	var avatarPtr *string
	if avatarVal != "" {
		avatarPtr = &avatarVal
	}

	birthDate, err := domain.ValidateBirthDate(in.BirthDate, s.now())
	if err != nil {
		return nil, err
	}
	region, err := domain.ValidateRegion(in.Region)
	if err != nil {
		return nil, err
	}
	gender, err := domain.ValidateGender(in.Gender)
	if err != nil {
		return nil, err
	}

	var phonePtr *string
	var phoneMasked string
	if ticket.Phone != nil && ticket.Phone.E164 != "" {
		e164 := ticket.Phone.E164
		phonePtr = &e164
		phoneMasked = ticket.Phone.Masked()
	} else if strings.TrimSpace(in.Phone) != "" {
		parsed, err := domain.ParsePhoneNumber(in.Phone)
		if err != nil {
			return nil, err
		}
		e164 := parsed.E164
		phonePtr = &e164
		phoneMasked = parsed.Masked()
	}
	var emailPtr *string
	if ticket.Google != nil && ticket.Google.Email != "" {
		em := ticket.Google.Email
		emailPtr = &em
	}

	var createdUser *entity.UserEntity
	var issuedTokens *domain.AuthTokens

	err = s.atomic.Transaction(func(tx unitofwork.Tx) error {
		// Re-check uniqueness inside transaction.
		if phonePtr != nil {
			if existing, err := s.users.FindByPhone(ctx, *phonePtr); err == nil && existing != nil {
				return domain.ErrIdentityTaken
			}
		}
		if ticket.Google != nil {
			if existing, err := s.identities.FindByProvider(ctx, domain.ProviderGoogle, ticket.Google.Subject); err == nil && existing != nil {
				return domain.ErrIdentityTaken
			}
		}
		if ticket.TelegramUserID != nil {
			tgSub := strconv.FormatInt(*ticket.TelegramUserID, 10)
			if existing, err := s.identities.FindByProvider(ctx, domain.ProviderTelegram, tgSub); err == nil && existing != nil {
				return domain.ErrIdentityTaken
			}
		}

		user, err := s.users.CreateTx(ctx, tx, &entity.UserEntity{
			FirstName: firstName,
			LastName:  lastNamePtr,
			Role:      role,
			FanIDs:    in.FanIDs,
			AvatarURL: avatarPtr,
			Phone:     phonePtr,
			Email:     emailPtr,
			BirthDate: &birthDate,
			Region:    &region,
			Gender:    &gender,
		})
		if err != nil {
			return err
		}

		if phonePtr != nil && ticket.Phone != nil {
			if err := s.identities.UpsertTx(ctx, tx, &domain.UserIdentity{
				UserID:      user.ID,
				Provider:    domain.ProviderPhone,
				ProviderSub: *phonePtr,
				DisplayName: phoneMasked,
			}); err != nil {
				return err
			}
		}
		if ticket.Google != nil {
			if err := s.identities.UpsertTx(ctx, tx, &domain.UserIdentity{
				UserID:      user.ID,
				Provider:    domain.ProviderGoogle,
				ProviderSub: ticket.Google.Subject,
				DisplayName: ticket.Google.Email,
			}); err != nil {
				return err
			}
		}
		if ticket.TelegramUserID != nil {
			if err := s.identities.UpsertTx(ctx, tx, &domain.UserIdentity{
				UserID:      user.ID,
				Provider:    domain.ProviderTelegram,
				ProviderSub: strconv.FormatInt(*ticket.TelegramUserID, 10),
				DisplayName: ticket.TelegramName,
			}); err != nil {
				return err
			}
		}

		tokens, err := s.createSessionTx(ctx, tx, user, ticket.Method, meta)
		if err != nil {
			return err
		}
		createdUser = user
		issuedTokens = tokens
		return nil
	})
	if err != nil {
		return nil, err
	}

	return &LoginResult{
		Status: LoginStatusAuthenticated,
		Tokens: issuedTokens,
		User:   createdUser,
	}, nil
}

// --- Sessions & Access Token Verification ---

func (s *AuthService) RefreshTokens(ctx context.Context, refreshToken string) (*domain.AuthTokens, error) {
	hash := s.tokens.Hash(strings.TrimSpace(refreshToken))
	session, err := s.sessions.FindByRefreshHash(ctx, hash)
	if errors.Is(err, domain.ErrNotFound) {
		return nil, domain.ErrSessionInvalid
	}
	if err != nil {
		return nil, err
	}

	now := s.now()
	if !session.IsActive(now) {
		return nil, domain.ErrSessionInvalid
	}

	user, err := s.users.FindByID(ctx, session.UserID)
	if err != nil {
		return nil, domain.ErrSessionInvalid
	}
	if user.IsBlocked {
		return nil, domain.ErrUserBlocked
	}

	// Rotate refresh token on every use.
	newRefresh, newHash, err := s.tokens.NewOpaqueToken()
	if err != nil {
		return nil, err
	}
	session.RefreshTokenHash = newHash
	session.ExpiresAt = now.Add(time.Duration(s.cfg.RefreshTokenExpireMinutes) * time.Minute)
	if err := s.sessions.Update(ctx, session); err != nil {
		return nil, err
	}

	accessToken, accessExp, err := s.encodeAccessJWT(user, session.ID)
	if err != nil {
		return nil, err
	}
	return &domain.AuthTokens{
		AccessToken:  accessToken,
		RefreshToken: newRefresh,
		TokenType:    "Bearer",
		ExpiresAt:    accessExp,
		SessionID:    session.ID,
	}, nil
}

func (s *AuthService) Logout(ctx context.Context, userID uint, refreshToken string) error {
	trimmed := strings.TrimSpace(refreshToken)
	if trimmed == "" {
		return nil
	}
	session, err := s.sessions.FindByRefreshHash(ctx, s.tokens.Hash(trimmed))
	if errors.Is(err, domain.ErrNotFound) {
		return nil
	}
	if err != nil {
		return err
	}
	if session.UserID != userID {
		return domain.ErrSessionInvalid
	}
	return s.sessions.Revoke(ctx, session.ID, s.now())
}

func (s *AuthService) GetMe(ctx context.Context, user *entity.UserEntity) (*MeResult, error) {
	methods, err := s.identities.ListByUserID(ctx, user.ID)
	if err != nil {
		return nil, err
	}
	return &MeResult{
		User:    user,
		Methods: methods,
	}, nil
}

func (s *AuthService) UpdateProfile(ctx context.Context, current *entity.UserEntity, in UpdateProfileInput) (*entity.UserEntity, error) {
	firstName := strings.TrimSpace(in.FirstName)
	if firstName == "" {
		return nil, domain.NewAuthError(domain.ErrInvalidRole.ResponseCode, "INVALID_FIRST_NAME", "Ism kiritilishi shart", nil)
	}
	var lastNamePtr *string
	if ln := strings.TrimSpace(in.LastName); ln != "" {
		lastNamePtr = &ln
	}

	birthDate, err := domain.ValidateBirthDate(in.BirthDate, s.now())
	if err != nil {
		return nil, err
	}
	region, err := domain.ValidateRegion(in.Region)
	if err != nil {
		return nil, err
	}
	gender, err := domain.ValidateGender(in.Gender)
	if err != nil {
		return nil, err
	}

	phonePtr := current.Phone
	if rawPhone := strings.TrimSpace(in.Phone); rawPhone != "" {
		parsed, err := domain.ParsePhoneNumber(rawPhone)
		if err != nil {
			return nil, err
		}
		if existing, err := s.users.FindByPhone(ctx, parsed.E164); err == nil && existing != nil && existing.ID != current.ID {
			return nil, domain.ErrIdentityTaken
		}
		e164 := parsed.E164
		phonePtr = &e164
	}

	avatarPtr := current.AvatarURL
	if av := strings.TrimSpace(in.AvatarURL); av != "" {
		avatarPtr = &av
	}

	updated := *current
	updated.FirstName = firstName
	updated.LastName = lastNamePtr
	updated.Phone = phonePtr
	updated.BirthDate = &birthDate
	updated.Region = &region
	updated.Gender = &gender
	updated.AvatarURL = avatarPtr

	return s.users.UpdateProfile(ctx, &updated)
}

func (s *AuthService) VerifyAccessToken(ctx context.Context, accessToken string) (*entity.UserEntity, error) {
	decoded, err := s.jwt.Decode(accessToken)
	if err != nil {
		return nil, err
	}
	var payload accessTokenPayload
	if err := json.Unmarshal(decoded.Payload, &payload); err != nil || payload.UserID == 0 {
		return nil, domain.ErrSessionInvalid
	}
	if payload.SessionID != "" {
		sid, err := uuid.Parse(payload.SessionID)
		if err != nil {
			return nil, domain.ErrSessionInvalid
		}
		session, err := s.sessions.FindByID(ctx, sid)
		if err != nil || !session.IsActive(s.now()) || session.UserID != payload.UserID {
			return nil, domain.ErrSessionInvalid
		}
	}
	user, err := s.users.FindByID(ctx, payload.UserID)
	if err != nil {
		return nil, domain.ErrSessionInvalid
	}
	if user.IsBlocked {
		return nil, domain.ErrUserBlocked
	}
	return user, nil
}

// --- Helpers ---

func (s *AuthService) findUserByPhone(ctx context.Context, phoneE164 string) (*entity.UserEntity, error) {
	if identity, err := s.identities.FindByProvider(ctx, domain.ProviderPhone, phoneE164); err == nil && identity != nil {
		return s.users.FindByID(ctx, identity.UserID)
	}
	user, err := s.users.FindByPhone(ctx, phoneE164)
	if errors.Is(err, domain.ErrNotFound) {
		return nil, nil
	}
	return user, err
}

func (s *AuthService) issueAuthenticatedResult(ctx context.Context, user *entity.UserEntity, method domain.AuthProvider, meta domain.ClientMeta) (*LoginResult, error) {
	if user.IsBlocked {
		return nil, domain.ErrUserBlocked
	}
	tokens, err := s.createSessionTx(ctx, nil, user, method, meta)
	if err != nil {
		return nil, err
	}
	return &LoginResult{
		Status: LoginStatusAuthenticated,
		Tokens: tokens,
		User:   user,
	}, nil
}

func (s *AuthService) issueRegistrationResult(ticket *domain.RegistrationTicket) (*LoginResult, error) {
	sealed, err := s.tickets.Seal(ticket)
	if err != nil {
		return nil, err
	}
	return &LoginResult{
		Status: LoginStatusRegistrationRequired,
		Registration: &RegistrationPrompt{
			Token:     sealed,
			ExpiresAt: ticket.ExpiresAt,
		},
	}, nil
}

func (s *AuthService) createSessionTx(ctx context.Context, tx unitofwork.Tx, user *entity.UserEntity, method domain.AuthProvider, meta domain.ClientMeta) (*domain.AuthTokens, error) {
	refreshPlain, refreshHash, err := s.tokens.NewOpaqueToken()
	if err != nil {
		return nil, err
	}
	now := s.now()
	session := &domain.AuthSession{
		ID:               uuid.New(),
		UserID:           user.ID,
		RefreshTokenHash: refreshHash,
		AuthMethod:       method,
		IP:               meta.IP,
		UserAgent:        meta.UserAgent,
		ExpiresAt:        now.Add(time.Duration(s.cfg.RefreshTokenExpireMinutes) * time.Minute),
		CreatedAt:        now,
	}
	if err := s.sessions.CreateTx(ctx, tx, session); err != nil {
		return nil, err
	}
	accessToken, accessExp, err := s.encodeAccessJWT(user, session.ID)
	if err != nil {
		return nil, err
	}
	return &domain.AuthTokens{
		AccessToken:  accessToken,
		RefreshToken: refreshPlain,
		TokenType:    "Bearer",
		ExpiresAt:    accessExp,
		SessionID:    session.ID,
	}, nil
}

func (s *AuthService) encodeAccessJWT(user *entity.UserEntity, sessionID uuid.UUID) (string, time.Time, error) {
	exp := s.now().Add(time.Duration(s.cfg.AccessTimeExpireMinutes) * time.Minute)
	payloadBytes, err := json.Marshal(accessTokenPayload{
		UserID:    user.ID,
		SessionID: sessionID.String(),
		Role:      user.Role,
	})
	if err != nil {
		return "", time.Time{}, err
	}
	token := s.jwt.Encode(&coresec.JwtToken{
		Subject: strconv.FormatUint(uint64(user.ID), 10),
		Exp:     exp,
		Payload: payloadBytes,
	})
	if token == "" {
		return "", time.Time{}, errors.New("failed to sign access token")
	}
	return token, exp, nil
}

func formatTelegramDisplay(c *domain.TelegramContact) string {
	if c.Username != "" {
		return "@" + c.Username
	}
	return strings.TrimSpace(c.FirstName + " " + c.LastName)
}
