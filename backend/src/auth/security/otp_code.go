package security

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"math/big"

	"github.com/google/uuid"
	"github.com/muhriddinnorqulov/skeleton/src/auth/domain"
	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/env"
)

var otpCodeSpace = new(big.Int).Exp(big.NewInt(10), big.NewInt(domain.OTPCodeLength), nil)

type OTPCodeServiceImpl struct {
	key []byte
}

// @inject
func NewOTPCodeServiceImpl(cfg *env.Env) domain.OTPCodeService {
	sum := sha256.Sum256([]byte("ilm-fan:auth:otp-code:" + cfg.HmacSecret))
	return &OTPCodeServiceImpl{key: sum[:]}
}

func (s *OTPCodeServiceImpl) Generate() (string, error) {
	n, err := rand.Int(rand.Reader, otpCodeSpace)
	if err != nil {
		return "", fmt.Errorf("generate otp: %w", err)
	}
	return fmt.Sprintf("%0*d", domain.OTPCodeLength, n.Int64()), nil
}

func (s *OTPCodeServiceImpl) Hash(challengeID uuid.UUID, code string) string {
	m := hmac.New(sha256.New, s.key)
	m.Write(challengeID[:])
	m.Write([]byte(code))
	return hex.EncodeToString(m.Sum(nil))
}

func (s *OTPCodeServiceImpl) Verify(challengeID uuid.UUID, code, hash string) bool {
	return hmac.Equal([]byte(s.Hash(challengeID, code)), []byte(hash))
}
