package security

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"time"

	"github.com/muhriddinnorqulov/skeleton/src/auth/domain"
	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/env"
)

var registrationTicketAAD = []byte("ilm-fan.auth.registration-ticket.v1")

type RegistrationTicketSealerImpl struct {
	aead cipher.AEAD
}

type sealedTicketPayload struct {
	Method         domain.AuthProvider `json:"m"`
	PhoneE164      string              `json:"p,omitempty"`
	PhoneRegion    string              `json:"r,omitempty"`
	PhoneVerified  bool                `json:"pv,omitempty"`
	TelegramUserID *int64              `json:"t,omitempty"`
	TelegramName   string              `json:"tn,omitempty"`
	Google         *domain.GoogleClaim `json:"g,omitempty"`
	ExpiresAt      int64               `json:"e"`
}

// @inject
func NewRegistrationTicketSealerImpl(cfg *env.Env) domain.RegistrationTicketSealer {
	key := sha256.Sum256([]byte("ilm-fan:auth:registration-ticket:" + cfg.HmacSecret + ":" + cfg.JwtSecret))
	block, err := aes.NewCipher(key[:])
	if err != nil {
		panic(fmt.Errorf("auth registration ticket cipher: %w", err))
	}
	aead, err := cipher.NewGCM(block)
	if err != nil {
		panic(fmt.Errorf("auth registration ticket gcm: %w", err))
	}
	return &RegistrationTicketSealerImpl{aead: aead}
}

func (s *RegistrationTicketSealerImpl) Seal(t *domain.RegistrationTicket) (string, error) {
	payload := sealedTicketPayload{
		Method:         t.Method,
		PhoneVerified:  t.PhoneVerified,
		TelegramUserID: t.TelegramUserID,
		TelegramName:   t.TelegramName,
		Google:         t.Google,
		ExpiresAt:      t.ExpiresAt.Unix(),
	}
	if t.Phone != nil {
		payload.PhoneE164 = t.Phone.E164
		payload.PhoneRegion = t.Phone.Region
	}
	plain, err := json.Marshal(payload)
	if err != nil {
		return "", fmt.Errorf("seal registration ticket: %w", err)
	}
	nonce := make([]byte, s.aead.NonceSize())
	if _, err := rand.Read(nonce); err != nil {
		return "", fmt.Errorf("seal registration ticket nonce: %w", err)
	}
	ciphertext := s.aead.Seal(nonce, nonce, plain, registrationTicketAAD)
	return base64.RawURLEncoding.EncodeToString(ciphertext), nil
}

func (s *RegistrationTicketSealerImpl) Open(token string) (*domain.RegistrationTicket, error) {
	if token == "" || len(token) > 3072 {
		return nil, domain.ErrRegistrationTicketInvalid
	}
	raw, err := base64.RawURLEncoding.DecodeString(token)
	n := s.aead.NonceSize()
	if err != nil || len(raw) < n {
		return nil, domain.ErrRegistrationTicketInvalid
	}
	plain, err := s.aead.Open(nil, raw[:n], raw[n:], registrationTicketAAD)
	if err != nil {
		return nil, domain.ErrRegistrationTicketInvalid
	}
	var p sealedTicketPayload
	if err := json.Unmarshal(plain, &p); err != nil {
		return nil, domain.ErrRegistrationTicketInvalid
	}
	t := &domain.RegistrationTicket{
		Method:         p.Method,
		PhoneVerified:  p.PhoneVerified,
		TelegramUserID: p.TelegramUserID,
		TelegramName:   p.TelegramName,
		Google:         p.Google,
		ExpiresAt:      time.Unix(p.ExpiresAt, 0),
	}
	if p.PhoneE164 != "" {
		t.Phone = &domain.PhoneNumber{E164: p.PhoneE164, Region: p.PhoneRegion}
	}
	return t, nil
}
