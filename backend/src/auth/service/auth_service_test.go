package service

import (
	"context"
	"errors"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/muhriddinnorqulov/skeleton/src/auth/domain"
	authsec "github.com/muhriddinnorqulov/skeleton/src/auth/security"
	"github.com/muhriddinnorqulov/skeleton/src/core/domain/entity"
	"github.com/muhriddinnorqulov/skeleton/src/core/domain/ports/unitofwork"
	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/env"
	coresec "github.com/muhriddinnorqulov/skeleton/src/infrastructure/security"
)

// --- In-memory test doubles ---

type memAtomic struct{}

func (memAtomic) Transaction(fn func(unitofwork.Tx) error) error { return fn(nil) }

type memUserStore struct {
	nextID  uint
	users   map[uint]*entity.UserEntity
	onMerge func(primaryID, secondaryID uint)
}

func newMemUserStore() *memUserStore {
	return &memUserStore{nextID: 1, users: map[uint]*entity.UserEntity{}}
}

func (s *memUserStore) FindByID(_ context.Context, id uint) (*entity.UserEntity, error) {
	u, ok := s.users[id]
	if !ok {
		return nil, domain.ErrNotFound
	}
	return u, nil
}

func (s *memUserStore) FindByPhone(_ context.Context, phoneE164 string) (*entity.UserEntity, error) {
	for _, u := range s.users {
		if u.Phone != nil && *u.Phone == phoneE164 {
			return u, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (s *memUserStore) FindByEmail(_ context.Context, email string) (*entity.UserEntity, error) {
	for _, u := range s.users {
		if u.Email != nil && strings.EqualFold(*u.Email, email) {
			return u, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (s *memUserStore) CreateTx(_ context.Context, _ unitofwork.Tx, u *entity.UserEntity) (*entity.UserEntity, error) {
	cp := *u
	cp.ID = s.nextID
	s.nextID++
	s.users[cp.ID] = &cp
	return &cp, nil
}

func (s *memUserStore) UpdateProfile(_ context.Context, u *entity.UserEntity) (*entity.UserEntity, error) {
	cp := *u
	s.users[cp.ID] = &cp
	return &cp, nil
}

type memStoreBundle struct {
	users      *memUserStore
	identities *memIdentityRepo
	sessions   *memSessionRepo
}

func (s *memUserStore) MergeUsersTx(_ context.Context, _ unitofwork.Tx, primaryID, secondaryID uint) (*entity.UserEntity, error) {
	p, ok := s.users[primaryID]
	if !ok {
		return nil, domain.ErrNotFound
	}
	sec, ok := s.users[secondaryID]
	if !ok {
		return nil, domain.ErrNotFound
	}
	if p.Phone == nil && sec.Phone != nil {
		v := *sec.Phone
		p.Phone = &v
	}
	if p.Email == nil && sec.Email != nil {
		v := *sec.Email
		p.Email = &v
	}
	if p.AvatarURL == nil && sec.AvatarURL != nil {
		v := *sec.AvatarURL
		p.AvatarURL = &v
	}
	if s.onMerge != nil {
		s.onMerge(primaryID, secondaryID)
	}
	delete(s.users, secondaryID)
	return p, nil
}

type memIdentityRepo struct {
	nextID uint
	items  []domain.UserIdentity
}

func (r *memIdentityRepo) FindByProvider(_ context.Context, p domain.AuthProvider, sub string) (*domain.UserIdentity, error) {
	for i := range r.items {
		if r.items[i].Provider == p && r.items[i].ProviderSub == sub {
			cp := r.items[i]
			return &cp, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (r *memIdentityRepo) ListByUserID(_ context.Context, userID uint) ([]domain.UserIdentity, error) {
	var out []domain.UserIdentity
	for _, it := range r.items {
		if it.UserID == userID {
			out = append(out, it)
		}
	}
	return out, nil
}

func (r *memIdentityRepo) UpsertTx(_ context.Context, _ unitofwork.Tx, id *domain.UserIdentity) error {
	for i := range r.items {
		if r.items[i].Provider == id.Provider && r.items[i].ProviderSub == id.ProviderSub {
			r.items[i].DisplayName = id.DisplayName
			return nil
		}
	}
	r.nextID++
	cp := *id
	cp.ID = r.nextID
	r.items = append(r.items, cp)
	return nil
}

func (r *memIdentityRepo) DeleteByUserAndProvider(_ context.Context, userID uint, p domain.AuthProvider) error {
	filtered := r.items[:0]
	for _, it := range r.items {
		if it.UserID == userID && it.Provider == p {
			continue
		}
		filtered = append(filtered, it)
	}
	r.items = filtered
	return nil
}

type memOTPRepo struct {
	items []*domain.OTPChallenge
}

func (r *memOTPRepo) Create(_ context.Context, c *domain.OTPChallenge) error {
	cp := *c
	r.items = append(r.items, &cp)
	return nil
}

func (r *memOTPRepo) FindLatestActiveByPhone(_ context.Context, phone string) (*domain.OTPChallenge, error) {
	for i := len(r.items) - 1; i >= 0; i-- {
		if r.items[i].PhoneE164 == phone && r.items[i].ConsumedAt == nil {
			cp := *r.items[i]
			return &cp, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (r *memOTPRepo) CountSentSince(_ context.Context, phone string, since time.Time) (int64, error) {
	var n int64
	for _, it := range r.items {
		if it.PhoneE164 == phone && !it.CreatedAt.Before(since) {
			n++
		}
	}
	return n, nil
}

func (r *memOTPRepo) Update(_ context.Context, c *domain.OTPChallenge) error {
	for i := range r.items {
		if r.items[i].ID == c.ID {
			cp := *c
			r.items[i] = &cp
			return nil
		}
	}
	return nil
}

type memSessionRepo struct {
	sessions map[uuid.UUID]*domain.AuthSession
}

func newMemSessionRepo() *memSessionRepo {
	return &memSessionRepo{sessions: map[uuid.UUID]*domain.AuthSession{}}
}

func (r *memSessionRepo) Create(_ context.Context, s *domain.AuthSession) error {
	cp := *s
	r.sessions[s.ID] = &cp
	return nil
}

func (r *memSessionRepo) CreateTx(ctx context.Context, _ unitofwork.Tx, s *domain.AuthSession) error {
	return r.Create(ctx, s)
}

func (r *memSessionRepo) FindByID(_ context.Context, id uuid.UUID) (*domain.AuthSession, error) {
	s, ok := r.sessions[id]
	if !ok {
		return nil, domain.ErrNotFound
	}
	cp := *s
	return &cp, nil
}

func (r *memSessionRepo) FindByRefreshHash(_ context.Context, hash []byte) (*domain.AuthSession, error) {
	for _, s := range r.sessions {
		if string(s.RefreshTokenHash) == string(hash) {
			cp := *s
			return &cp, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (r *memSessionRepo) Update(_ context.Context, s *domain.AuthSession) error {
	cp := *s
	r.sessions[s.ID] = &cp
	return nil
}

func (r *memSessionRepo) Revoke(_ context.Context, id uuid.UUID, now time.Time) error {
	if s, ok := r.sessions[id]; ok {
		s.RevokedAt = &now
	}
	return nil
}

type memTGContactRepo struct {
	items map[int64]*domain.TelegramContact
}

func (r *memTGContactRepo) FindByTelegramUserID(_ context.Context, id int64) (*domain.TelegramContact, error) {
	c, ok := r.items[id]
	if !ok {
		return nil, domain.ErrNotFound
	}
	cp := *c
	return &cp, nil
}

func (r *memTGContactRepo) Upsert(_ context.Context, c *domain.TelegramContact) error {
	cp := *c
	r.items[c.TelegramUserID] = &cp
	return nil
}

type memTGAttemptRepo struct {
	items map[uuid.UUID]*domain.TelegramLoginAttempt
}

func (r *memTGAttemptRepo) Create(_ context.Context, a *domain.TelegramLoginAttempt) error {
	cp := *a
	r.items[a.ID] = &cp
	return nil
}

func (r *memTGAttemptRepo) FindByID(_ context.Context, id uuid.UUID) (*domain.TelegramLoginAttempt, error) {
	a, ok := r.items[id]
	if !ok {
		return nil, domain.ErrNotFound
	}
	cp := *a
	return &cp, nil
}

func (r *memTGAttemptRepo) FindByTokenHash(_ context.Context, hash []byte) (*domain.TelegramLoginAttempt, error) {
	for _, a := range r.items {
		if string(a.TokenHash) == string(hash) {
			cp := *a
			return &cp, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (r *memTGAttemptRepo) Update(_ context.Context, a *domain.TelegramLoginAttempt) error {
	cp := *a
	r.items[a.ID] = &cp
	return nil
}

type memQRAttemptRepo struct {
	items map[uuid.UUID]*domain.QRLoginAttempt
}

func (r *memQRAttemptRepo) Create(_ context.Context, a *domain.QRLoginAttempt) error {
	cp := *a
	r.items[a.ID] = &cp
	return nil
}

func (r *memQRAttemptRepo) FindByID(_ context.Context, id uuid.UUID) (*domain.QRLoginAttempt, error) {
	a, ok := r.items[id]
	if !ok {
		return nil, domain.ErrNotFound
	}
	cp := *a
	return &cp, nil
}

func (r *memQRAttemptRepo) FindByTokenHash(_ context.Context, hash []byte) (*domain.QRLoginAttempt, error) {
	for _, a := range r.items {
		if string(a.TokenHash) == string(hash) {
			cp := *a
			return &cp, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (r *memQRAttemptRepo) Update(_ context.Context, a *domain.QRLoginAttempt) error {
	cp := *a
	r.items[a.ID] = &cp
	return nil
}

type captureSMS struct {
	lastPhone string
	lastText  string
}

func (s *captureSMS) Send(_ context.Context, phone, text string) error {
	s.lastPhone = phone
	s.lastText = text
	return nil
}

type fakeGoogle struct {
	profile *domain.GoogleProfile
}

func (g *fakeGoogle) Enabled() bool { return true }
func (g *fakeGoogle) Start() (*domain.GoogleAuthStart, error) {
	return &domain.GoogleAuthStart{
		AuthorizationURL: "https://accounts.google.com/o/oauth2/v2/auth?mock=1",
		State:            "st",
		CodeVerifier:     "ver",
	}, nil
}
func (g *fakeGoogle) Exchange(_ context.Context, _, _ string) (*domain.GoogleProfile, error) {
	return g.profile, nil
}
func (g *fakeGoogle) VerifyIDToken(_ context.Context, _ string) (*domain.GoogleProfile, error) {
	return g.profile, nil
}

type testHarness struct {
	svc    *AuthService
	tgSvc  *TelegramBotService
	sms    *captureSMS
	google *fakeGoogle
	now    time.Time
}

func newHarness() *testHarness {
	cfg := &env.Env{
		JwtSecret:                 "test-jwt-secret-32-bytes-minimum!!",
		HmacSecret:                "test-hmac-secret-32-bytes-minimum!",
		AccessTimeExpireMinutes:   60,
		RefreshTokenExpireMinutes: 10080,
		TelegramBotUsername:       "ilmfan_auth_bot",
	}
	users := newMemUserStore()
	identities := &memIdentityRepo{}
	otps := &memOTPRepo{}
	sessions := newMemSessionRepo()
	users.onMerge = func(primaryID, secondaryID uint) {
		for i := range identities.items {
			if identities.items[i].UserID == secondaryID {
				identities.items[i].UserID = primaryID
			}
		}
		for _, sess := range sessions.sessions {
			if sess.UserID == secondaryID {
				sess.UserID = primaryID
			}
		}
	}
	tgContacts := &memTGContactRepo{items: map[int64]*domain.TelegramContact{}}
	tgAttempts := &memTGAttemptRepo{items: map[uuid.UUID]*domain.TelegramLoginAttempt{}}
	qrAttempts := &memQRAttemptRepo{items: map[uuid.UUID]*domain.QRLoginAttempt{}}
	sms := &captureSMS{}
	google := &fakeGoogle{}
	tokens := authsec.NewTokenServiceImpl()

	h := &testHarness{
		sms:    sms,
		google: google,
		now:    time.Now().UTC(),
	}
	h.svc = NewAuthService(
		cfg, memAtomic{}, users, identities, otps, sessions, tgContacts, tgAttempts, qrAttempts,
		sms, google,
		authsec.NewOTPCodeServiceImpl(cfg),
		authsec.NewRegistrationTicketSealerImpl(cfg),
		tokens,
		coresec.NewJwtTokenAdapter(cfg),
		authsec.NewRateThrottleImpl(),
	)
	h.svc.now = func() time.Time { return h.now }

	h.tgSvc = NewTelegramBotService(tgAttempts, tgContacts, tokens)
	h.tgSvc.now = func() time.Time { return h.now }
	return h
}

func TestPhoneSMSFlow_RegisterLoginRefreshLogout(t *testing.T) {
	h := newHarness()
	ctx := context.Background()
	meta := domain.ClientMeta{IP: "127.0.0.1", UserAgent: "test-agent"}

	// 1. Send SMS OTP
	sent, err := h.svc.SendSMSOTP(ctx, "+998 90 123 45 67", meta)
	if err != nil {
		t.Fatalf("SendSMSOTP failed: %v", err)
	}
	if sent.ExpiresInSeconds != 120 {
		t.Fatalf("expected 120s TTL, got %d", sent.ExpiresInSeconds)
	}
	parts := strings.Fields(h.sms.lastText)
	code := parts[len(parts)-1]

	// 2. Resend immediately must hit cooldown
	if _, err := h.svc.SendSMSOTP(ctx, "+998901234567", meta); err == nil {
		t.Fatalf("expected resend cooldown error")
	}

	// 3. Wrong code decrements attempts
	if _, err := h.svc.VerifySMSOTP(ctx, "+998901234567", "00000", meta); err == nil && code != "00000" {
		t.Fatalf("expected invalid OTP error")
	}
	if !strings.HasPrefix(h.sms.lastText, "sat-ilmfan.gvazar.uz tizimida ro'yxatdan o'tish uchun tasdiqlash kod: ") || len(code) != 5 {
		t.Fatalf("unexpected registration SMS template: %q", h.sms.lastText)
	}

	// 4. Correct code -> registration_required
	res, err := h.svc.VerifySMSOTP(ctx, "+998901234567", code, meta)
	if err != nil {
		t.Fatalf("VerifySMSOTP failed: %v", err)
	}
	if res.Status != LoginStatusRegistrationRequired || res.Registration == nil {
		t.Fatalf("expected registration_required, got %+v", res)
	}

	// 5. Inspect & complete registration using Web role alias ("applicant" -> "student")
	inspected, err := h.svc.InspectRegistration(ctx, res.Registration.Token)
	if err != nil || inspected.Method != domain.ProviderPhone {
		t.Fatalf("InspectRegistration failed: %+v %v", inspected, err)
	}
	regRes, err := h.svc.CompleteRegistration(ctx, CompleteRegistrationInput{
		RegistrationToken: res.Registration.Token,
		Role:              "applicant",
		FanIDs:            []string{"math", "physics"},
		FirstName:         "Ali",
		LastName:          "Valiyev",
		BirthDate:         "2006-05-14",
		Region:            "Toshkent shahri",
		Gender:            "male",
	}, meta)
	if err != nil {
		t.Fatalf("CompleteRegistration failed: %v", err)
	}
	if regRes.Status != LoginStatusAuthenticated || regRes.User.Role != domain.RoleStudent {
		t.Fatalf("unexpected registration result: %+v", regRes)
	}

	// 6. Access token verifies & returns user
	u, err := h.svc.VerifyAccessToken(ctx, regRes.Tokens.AccessToken)
	if err != nil || u.ID != regRes.User.ID {
		t.Fatalf("VerifyAccessToken failed: %+v %v", u, err)
	}

	// 7. Refresh rotates refresh token
	refreshed, err := h.svc.RefreshTokens(ctx, regRes.Tokens.RefreshToken)
	if err != nil || refreshed.RefreshToken == regRes.Tokens.RefreshToken {
		t.Fatalf("RefreshTokens failed: %+v %v", refreshed, err)
	}
	if _, err := h.svc.RefreshTokens(ctx, regRes.Tokens.RefreshToken); !errors.Is(err, domain.ErrSessionInvalid) {
		t.Fatalf("old refresh token should be rejected, got %v", err)
	}

	// 8. Logout revokes session -> access token now fails
	if err := h.svc.Logout(ctx, regRes.User.ID, refreshed.RefreshToken); err != nil {
		t.Fatalf("Logout failed: %v", err)
	}
	if _, err := h.svc.VerifyAccessToken(ctx, refreshed.AccessToken); err == nil {
		t.Fatalf("access token must fail after session logout")
	}

	// 9. Next SMS login signs directly into existing user
	h.now = h.now.Add(2 * time.Minute)
	if _, err := h.svc.SendSMSOTP(ctx, "+998901234567", meta); err != nil {
		t.Fatalf("second SendSMSOTP failed: %v", err)
	}
	parts = strings.Fields(h.sms.lastText)
	code2 := parts[len(parts)-1]
	if !strings.HasPrefix(h.sms.lastText, "sat-ilmfan.gvazar.uz tizimiga kirish uchun tasdiqlash kod: ") || len(code2) != 5 {
		t.Fatalf("unexpected login SMS template: %q", h.sms.lastText)
	}
	login2, err := h.svc.VerifySMSOTP(ctx, "+998901234567", code2, meta)
	if err != nil || login2.Status != LoginStatusAuthenticated || login2.User.ID != regRes.User.ID {
		t.Fatalf("expected direct login for existing phone, got %+v %v", login2, err)
	}
}

func verifyRegPhone(t *testing.T, h *testHarness, regToken, phone string, meta domain.ClientMeta) string {
	t.Helper()
	ctx := context.Background()
	if _, err := h.svc.SendSMSOTP(ctx, phone, meta); err != nil {
		t.Fatalf("SendSMSOTP(%s) failed: %v", phone, err)
	}
	parts := strings.Fields(h.sms.lastText)
	code := parts[len(parts)-1]
	res, err := h.svc.VerifyRegistrationPhone(ctx, regToken, phone, code, meta)
	if err != nil || res.Registration == nil {
		t.Fatalf("VerifyRegistrationPhone(%s) failed: %+v %v", phone, res, err)
	}
	return res.Registration.Token
}

func TestGoogleLogin_RequiresPhoneVerificationOnNextStep(t *testing.T) {
	h := newHarness()
	ctx := context.Background()
	meta := domain.ClientMeta{IP: "10.0.0.1", UserAgent: "flutter"}

	h.google.profile = &domain.GoogleProfile{
		Subject:       "google-sub-123",
		Email:         "teacher@example.com",
		EmailVerified: true,
		GivenName:     "Dilnoza",
		FamilyName:    "Karimova",
		AvatarURL:     "https://lh3.googleusercontent.com/avatar.png",
	}

	// Mobile ID token login -> registration_required
	res, err := h.svc.GoogleIDTokenLogin(ctx, "fake-id-token", meta)
	if err != nil {
		t.Fatalf("GoogleIDTokenLogin failed: %v", err)
	}
	if res.Status != LoginStatusRegistrationRequired || res.Registration == nil {
		t.Fatalf("expected registration_required, got %+v", res)
	}

	// Completing registration before SMS phone verification must fail
	if _, err := h.svc.CompleteRegistration(ctx, CompleteRegistrationInput{
		RegistrationToken: res.Registration.Token,
		Role:              "teacherMaterials",
		FanIDs:            []string{"english"},
		FirstName:         "Dilnoza",
		LastName:          "Karimova",
		BirthDate:         "1994-03-21",
		Region:            "Samarqand viloyati",
		Gender:            "female",
	}, meta); !errors.Is(err, domain.ErrPhoneVerificationRequired) {
		t.Fatalf("expected ErrPhoneVerificationRequired, got %v", err)
	}

	// Verify phone via SMS on step 2, then complete registration
	verifiedToken := verifyRegPhone(t, h, res.Registration.Token, "+998931230001", meta)
	regRes, err := h.svc.CompleteRegistration(ctx, CompleteRegistrationInput{
		RegistrationToken: verifiedToken,
		Role:              "teacherMaterials",
		FanIDs:            []string{"english"},
		FirstName:         "Dilnoza",
		LastName:          "Karimova",
		BirthDate:         "1994-03-21",
		Region:            "Samarqand viloyati",
		Gender:            "female",
	}, meta)
	if err != nil {
		t.Fatalf("Google CompleteRegistration failed: %v", err)
	}
	if regRes.User.Phone == nil || *regRes.User.Phone != "+998931230001" {
		t.Fatalf("expected verified phone saved on user, got %v", regRes.User.Phone)
	}
	if regRes.User.Email == nil || *regRes.User.Email != "teacher@example.com" {
		t.Fatalf("expected google email saved on user")
	}

	// User can edit profile (including correcting name and adding phone) after login
	edited, err := h.svc.UpdateProfile(ctx, regRes.User, UpdateProfileInput{
		FirstName: "Dilnoza",
		LastName:  "Karimova-Aliyeva",
		Phone:     "+998931234567",
		BirthDate: "1994-03-21",
		Region:    "Toshkent viloyati",
		Gender:    "female",
	})
	if err != nil || edited.Phone == nil || *edited.Phone != "+998931234567" || *edited.Region != "Toshkent viloyati" {
		t.Fatalf("UpdateProfile failed: %+v %v", edited, err)
	}

	// Subsequent Google login authenticates directly
	login2, err := h.svc.GoogleCallback(ctx, "code", "verifier", meta)
	if err != nil || login2.Status != LoginStatusAuthenticated || login2.User.ID != regRes.User.ID {
		t.Fatalf("expected direct google login, got %+v %v", login2, err)
	}
}

func TestTelegramBotLoginFlow(t *testing.T) {
	h := newHarness()
	ctx := context.Background()
	meta := domain.ClientMeta{IP: "192.168.1.5", UserAgent: "Chrome"}

	started, err := h.svc.StartTelegramLogin(ctx, meta)
	if err != nil {
		t.Fatalf("StartTelegramLogin failed: %v", err)
	}

	// Poll while pending
	poll1, err := h.svc.PollTelegramLogin(ctx, started.AttemptID, started.Secret, meta)
	if err != nil || poll1.Status != LoginStatusPending || *poll1.BotOpened {
		t.Fatalf("expected pending bot_opened=false, got %+v %v", poll1, err)
	}

	// User opens /start <token> in bot (first time -> needs contact)
	step, err := h.tgSvc.OpenLogin(ctx, started.StartToken, 777001, 777001)
	if err != nil || !step.NeedContact || step.AttemptID != started.AttemptID {
		t.Fatalf("expected NeedContact=true with AttemptID, got %+v %v", step, err)
	}

	// User shares own contact -> receives confirmation prompt
	prompt, err := h.tgSvc.ShareContact(ctx, 777001, 777001, 777001, "+998911112233", "Sardor", "Akbarov", "sardor", &step.AttemptID)
	if err != nil || prompt == nil || prompt.AttemptID != started.AttemptID {
		t.Fatalf("expected confirmation prompt, got %+v %v", prompt, err)
	}

	// User clicks "✅ Tasdiqlash"
	if err := h.tgSvc.DecideLogin(ctx, prompt.AttemptID, 777001, true); err != nil {
		t.Fatalf("DecideLogin failed: %v", err)
	}

	// Web/Mobile polls -> registration_required with phone + telegram_id
	poll2, err := h.svc.PollTelegramLogin(ctx, started.AttemptID, started.Secret, meta)
	if err != nil || poll2.Status != LoginStatusRegistrationRequired || poll2.Registration == nil {
		t.Fatalf("expected registration_required after confirm, got %+v %v", poll2, err)
	}

	// Verify phone via SMS on step 2 -> Register -> authenticated
	tgVerifiedToken := verifyRegPhone(t, h, poll2.Registration.Token, "+998911112233", meta)
	regRes, err := h.svc.CompleteRegistration(ctx, CompleteRegistrationInput{
		RegistrationToken: tgVerifiedToken,
		Role:              "schoolStudent",
		FirstName:         "Sardor",
		LastName:          "Akbarov",
		BirthDate:         "2010-09-01",
		Region:            "Farg'ona viloyati",
		Gender:            "male",
	}, meta)
	if err != nil || regRes.Status != LoginStatusAuthenticated {
		t.Fatalf("Telegram CompleteRegistration failed: %+v %v", regRes, err)
	}
}

func TestAccountLinking_GoogleTelegramPhoneAndUnlink(t *testing.T) {
	h := newHarness()
	ctx := context.Background()
	meta := domain.ClientMeta{IP: "127.0.0.1", UserAgent: "Chrome"}

	// 1. Register with Google + verified phone
	h.google.profile = &domain.GoogleProfile{
		Subject:       "google-link-1",
		Email:         "user@example.com",
		EmailVerified: true,
		GivenName:     "Aziz",
		FamilyName:    "Tursunov",
	}
	gRes, err := h.svc.GoogleCallback(ctx, "c", "v", meta)
	if err != nil {
		t.Fatalf("GoogleCallback failed: %v", err)
	}
	gVerifiedToken := verifyRegPhone(t, h, gRes.Registration.Token, "+998909998877", meta)
	reg, err := h.svc.CompleteRegistration(ctx, CompleteRegistrationInput{
		RegistrationToken: gVerifiedToken,
		Role:              "student",
		FanIDs:            []string{"math"},
		FirstName:         "Aziz",
		LastName:          "Tursunov",
		BirthDate:         "2004-02-10",
		Region:            "Toshkent shahri",
		Gender:            "male",
	}, meta)
	if err != nil {
		t.Fatalf("CompleteRegistration failed: %v", err)
	}

	// Unlink phone -> google remains; cannot unlink last remaining login method
	if _, err := h.svc.UnlinkMethod(ctx, reg.User, "phone"); err != nil {
		t.Fatalf("UnlinkMethod(phone) failed: %v", err)
	}
	if _, err := h.svc.UnlinkMethod(ctx, reg.User, "google"); !errors.Is(err, domain.ErrLastLoginMethod) {
		t.Fatalf("expected ErrLastLoginMethod, got %v", err)
	}

	// 2. Link Telegram from profile
	tgStart, err := h.svc.StartTelegramLink(ctx, meta)
	if err != nil {
		t.Fatalf("StartTelegramLink failed: %v", err)
	}
	step, err := h.tgSvc.OpenLogin(ctx, tgStart.StartToken, 888001, 888001)
	if err != nil || !step.NeedContact {
		t.Fatalf("OpenLogin failed: %+v %v", step, err)
	}
	prompt, err := h.tgSvc.ShareContact(ctx, 888001, 888001, 888001, "+998909998877", "Aziz", "T", "aziz_tg", &step.AttemptID)
	if err != nil || prompt == nil {
		t.Fatalf("ShareContact failed: %v", err)
	}
	if err := h.tgSvc.DecideLogin(ctx, prompt.AttemptID, 888001, true); err != nil {
		t.Fatalf("DecideLogin failed: %v", err)
	}
	linkedTG, err := h.svc.PollTelegramLink(ctx, reg.User, tgStart.AttemptID, tgStart.Secret, meta)
	if err != nil || linkedTG.Status != LinkStatusLinked || len(linkedTG.Methods) != 2 {
		t.Fatalf("expected google+telegram linked (2 methods), got %+v %v", linkedTG, err)
	}

	// 3. Verify & link a new phone via SMS OTP
	if _, err := h.svc.SendSMSOTP(ctx, "+998935554433", meta); err != nil {
		t.Fatalf("SendSMSOTP failed: %v", err)
	}
	parts := strings.Fields(h.sms.lastText)
	otpCode := parts[len(parts)-1]
	linkedPhone, err := h.svc.VerifyAndLinkPhone(ctx, linkedTG.User, "+998935554433", otpCode, meta)
	if err != nil || linkedPhone.User.Phone == nil || *linkedPhone.User.Phone != "+998935554433" {
		t.Fatalf("VerifyAndLinkPhone failed: %+v %v", linkedPhone, err)
	}

	// 4. Can now unlink Google safely because Telegram + Phone remain
	afterUnlink, err := h.svc.UnlinkMethod(ctx, linkedPhone.User, "google")
	if err != nil || len(afterUnlink.Methods) != 2 {
		t.Fatalf("UnlinkMethod(google) failed: %+v %v", afterUnlink, err)
	}
}

func TestAccountMerge_GoogleAccountMergesIntoExistingTelegramAccount(t *testing.T) {
	h := newHarness()
	ctx := context.Background()
	meta := domain.ClientMeta{IP: "127.0.0.1", UserAgent: "Chrome"}

	// 1. Account A created via Telegram (+998901112233)
	tg1, err := h.svc.StartTelegramLogin(ctx, meta)
	if err != nil {
		t.Fatalf("StartTelegramLogin failed: %v", err)
	}
	step1, err := h.tgSvc.OpenLogin(ctx, tg1.StartToken, 99001, 99001)
	if err != nil {
		t.Fatalf("OpenLogin failed: %v", err)
	}
	prompt1, err := h.tgSvc.ShareContact(ctx, 99001, 99001, 99001, "+998901112233", "Jasur", "Qodirov", "jasur", &step1.AttemptID)
	if err != nil {
		t.Fatalf("ShareContact failed: %v", err)
	}
	if err := h.tgSvc.DecideLogin(ctx, prompt1.AttemptID, 99001, true); err != nil {
		t.Fatalf("DecideLogin failed: %v", err)
	}
	poll1, err := h.svc.PollTelegramLogin(ctx, tg1.AttemptID, tg1.Secret, meta)
	if err != nil {
		t.Fatalf("PollTelegramLogin failed: %v", err)
	}
	accAToken := verifyRegPhone(t, h, poll1.Registration.Token, "+998901112233", meta)
	accountA, err := h.svc.CompleteRegistration(ctx, CompleteRegistrationInput{
		RegistrationToken: accAToken,
		Role:              "teacher",
		FanIDs:            []string{"physics"},
		FirstName:         "Jasur",
		LastName:          "Qodirov",
		BirthDate:         "1990-01-15",
		Region:            "Buxoro viloyati",
		Gender:            "male",
	}, meta)
	if err != nil {
		t.Fatalf("register account A failed: %v", err)
	}

	// 2. Later from another browser, same person signs in with Google (different phone) -> creates Account B
	h.google.profile = &domain.GoogleProfile{
		Subject:       "google-sub-jasur",
		Email:         "jasur@example.com",
		EmailVerified: true,
		GivenName:     "Jasur",
		FamilyName:    "Qodirov",
	}
	gRes, err := h.svc.GoogleCallback(ctx, "c", "v", meta)
	if err != nil {
		t.Fatalf("GoogleCallback failed: %v", err)
	}
	accBToken := verifyRegPhone(t, h, gRes.Registration.Token, "+998901112244", meta)
	accountB, err := h.svc.CompleteRegistration(ctx, CompleteRegistrationInput{
		RegistrationToken: accBToken,
		Role:              "student",
		FanIDs:            []string{"math"},
		FirstName:         "Jasur",
		LastName:          "Qodirov",
		BirthDate:         "1990-01-15",
		Region:            "Buxoro viloyati",
		Gender:            "male",
	}, meta)
	if err != nil {
		t.Fatalf("register account B failed: %v", err)
	}
	if accountB.User.ID == accountA.User.ID {
		t.Fatalf("expected distinct accounts before merge")
	}

	// 3. Inside Account B's profile, user links Telegram -> accounts merge into Account A!
	tgLink, err := h.svc.StartTelegramLink(ctx, meta)
	if err != nil {
		t.Fatalf("StartTelegramLink failed: %v", err)
	}
	step2, err := h.tgSvc.OpenLogin(ctx, tgLink.StartToken, 99001, 99001)
	if err != nil || step2.Prompt == nil {
		t.Fatalf("OpenLogin for link failed: %+v %v", step2, err)
	}
	if err := h.tgSvc.DecideLogin(ctx, step2.Prompt.AttemptID, 99001, true); err != nil {
		t.Fatalf("DecideLogin for link failed: %v", err)
	}
	merged, err := h.svc.PollTelegramLink(ctx, accountB.User, tgLink.AttemptID, tgLink.Secret, meta)
	if err != nil {
		t.Fatalf("PollTelegramLink merge failed: %v", err)
	}
	if !merged.Merged || merged.User.ID != accountA.User.ID || merged.Tokens == nil {
		t.Fatalf("expected merge into account A (%d) with fresh tokens, got %+v", accountA.User.ID, merged)
	}
	if len(merged.Methods) < 3 {
		t.Fatalf("expected unified methods (phone+telegram+google), got %d: %+v", len(merged.Methods), merged.Methods)
	}

	// 4. Fresh access token authenticates as Account A and Google login now logs directly into Account A
	verifiedUser, err := h.svc.VerifyAccessToken(ctx, merged.Tokens.AccessToken)
	if err != nil || verifiedUser.ID != accountA.User.ID {
		t.Fatalf("merged access token should belong to Account A, got %+v %v", verifiedUser, err)
	}
	googleLoginAgain, err := h.svc.GoogleCallback(ctx, "c2", "v2", meta)
	if err != nil || googleLoginAgain.Status != LoginStatusAuthenticated || googleLoginAgain.User.ID != accountA.User.ID {
		t.Fatalf("Google login after merge should sign into Account A, got %+v %v", googleLoginAgain, err)
	}
}

func TestQRLoginFlow_ExistingUserRegistrationAndReject(t *testing.T) {
	h := newHarness()
	ctx := context.Background()
	desktopMeta := domain.ClientMeta{IP: "203.0.113.10", UserAgent: "Mozilla/5.0 (Windows NT 10.0) Chrome/130.0"}

	// Create an existing user via Google
	h.google.profile = &domain.GoogleProfile{
		Subject: "qr-g-1", Email: "qruser@example.com", EmailVerified: true, GivenName: "Ali", FamilyName: "Valiyev",
	}
	gRes, err := h.svc.GoogleCallback(ctx, "c", "v", desktopMeta)
	if err != nil || gRes.Registration == nil {
		t.Fatalf("GoogleCallback failed: %v", err)
	}
	qrUserToken := verifyRegPhone(t, h, gRes.Registration.Token, "+998905556677", desktopMeta)
	reg, err := h.svc.CompleteRegistration(ctx, CompleteRegistrationInput{
		RegistrationToken: qrUserToken, Role: "pupil",
		FirstName: "Ali", LastName: "Valiyev", BirthDate: "2008-03-10", Region: "Toshkent shahri", Gender: "male",
	}, desktopMeta)
	if err != nil {
		t.Fatalf("CompleteRegistration failed: %v", err)
	}

	// 1. Desktop starts QR -> pending, not scanned
	qr, err := h.svc.StartQRLogin(ctx, desktopMeta)
	if err != nil || qr.QRToken == "" || qr.Secret == "" {
		t.Fatalf("StartQRLogin failed: %+v %v", qr, err)
	}
	p1, err := h.svc.PollQRLogin(ctx, qr.AttemptID, qr.Secret, desktopMeta)
	if err != nil || p1.Status != LoginStatusPending || p1.Scanned {
		t.Fatalf("expected unscanned pending, got %+v %v", p1, err)
	}

	// 2. Phone scans QR -> desktop sees scanned=true
	scan, err := h.svc.ScanQRLogin(ctx, qr.QRToken)
	if err != nil || scan.DesktopDevice != "Windows · Chrome" {
		t.Fatalf("ScanQRLogin failed: %+v %v", scan, err)
	}
	p2, err := h.svc.PollQRLogin(ctx, qr.AttemptID, qr.Secret, desktopMeta)
	if err != nil || p2.Status != LoginStatusPending || !p2.Scanned {
		t.Fatalf("expected scanned pending, got %+v %v", p2, err)
	}

	// 3. Phone approves -> desktop immediately receives tokens for Ali and cannot replay
	if err := h.svc.ApproveQRWithUser(ctx, qr.QRToken, reg.User, domain.ProviderGoogle); err != nil {
		t.Fatalf("ApproveQRWithUser failed: %v", err)
	}
	p3, err := h.svc.PollQRLogin(ctx, qr.AttemptID, qr.Secret, desktopMeta)
	if err != nil || p3.Status != LoginStatusAuthenticated || p3.User == nil || p3.User.ID != reg.User.ID || p3.Tokens == nil {
		t.Fatalf("expected desktop authenticated, got %+v %v", p3, err)
	}
	if _, err := h.svc.PollQRLogin(ctx, qr.AttemptID, qr.Secret, desktopMeta); !errors.Is(err, domain.ErrQRUsed) {
		t.Fatalf("expected ErrQRUsed on replay, got %v", err)
	}

	// 4. New-user registration ticket handoff via QR
	qrNew, err := h.svc.StartQRLogin(ctx, desktopMeta)
	if err != nil {
		t.Fatalf("StartQRLogin(2) failed: %v", err)
	}
	h.google.profile = &domain.GoogleProfile{
		Subject: "qr-g-new", Email: "newqr@example.com", EmailVerified: true, GivenName: "Malika", FamilyName: "Karimova",
	}
	gNew, err := h.svc.GoogleCallback(ctx, "c2", "v2", desktopMeta)
	if err != nil || gNew.Registration == nil {
		t.Fatalf("GoogleCallback new user failed: %v", err)
	}
	if err := h.svc.ApproveQRWithRegistration(ctx, qrNew.QRToken, gNew.Registration.Token); err != nil {
		t.Fatalf("ApproveQRWithRegistration failed: %v", err)
	}
	pNew, err := h.svc.PollQRLogin(ctx, qrNew.AttemptID, qrNew.Secret, desktopMeta)
	if err != nil || pNew.Status != LoginStatusRegistrationRequired || pNew.Registration == nil {
		t.Fatalf("expected registration_required handoff, got %+v %v", pNew, err)
	}

	// 5. Reject flow
	qrRej, _ := h.svc.StartQRLogin(ctx, desktopMeta)
	if err := h.svc.RejectQRLogin(ctx, qrRej.QRToken); err != nil {
		t.Fatalf("RejectQRLogin failed: %v", err)
	}
	if _, err := h.svc.PollQRLogin(ctx, qrRej.AttemptID, qrRej.Secret, desktopMeta); !errors.Is(err, domain.ErrQRRejected) {
		t.Fatalf("expected ErrQRRejected, got %v", err)
	}

	// 6. Direct Telegram bot confirmation unlocks desktop QR poll even when mobile browser never polls
	qrTG, err := h.svc.StartQRLogin(ctx, desktopMeta)
	if err != nil {
		t.Fatalf("StartQRLogin(tg) failed: %v", err)
	}
	tgStart, err := h.svc.StartQRTelegram(ctx, qrTG.QRToken, desktopMeta)
	if err != nil {
		t.Fatalf("StartQRTelegram failed: %v", err)
	}
	tgOpen, err := h.tgSvc.OpenLogin(ctx, tgStart.StartToken, 77001, 77001)
	if err != nil || !tgOpen.NeedContact {
		t.Fatalf("expected NeedContact, got %+v %v", tgOpen, err)
	}
	prompt, err := h.tgSvc.ShareContact(ctx, 77001, 77001, 77001, "+998907778899", "Bot", "User", "botuser", &tgOpen.AttemptID)
	if err != nil || prompt == nil {
		t.Fatalf("ShareContact failed: %+v %v", prompt, err)
	}
	if err := h.tgSvc.DecideLogin(ctx, prompt.AttemptID, 77001, true); err != nil {
		t.Fatalf("DecideLogin failed: %v", err)
	}
	pTG, err := h.svc.PollQRLogin(ctx, qrTG.AttemptID, qrTG.Secret, desktopMeta)
	if err != nil || pTG.Status != LoginStatusRegistrationRequired || pTG.Registration == nil {
		t.Fatalf("expected desktop QR poll to resolve Telegram confirmation directly, got %+v %v", pTG, err)
	}
}
