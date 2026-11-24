package security

import (
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"fmt"

	"github.com/muhriddinnorqulov/skeleton/src/auth/domain"
)

const opaqueTokenBytes = 32

type TokenServiceImpl struct{}

// @inject
func NewTokenServiceImpl() domain.TokenService {
	return &TokenServiceImpl{}
}

func (s *TokenServiceImpl) NewOpaqueToken() (string, []byte, error) {
	b := make([]byte, opaqueTokenBytes)
	if _, err := rand.Read(b); err != nil {
		return "", nil, fmt.Errorf("generate token: %w", err)
	}
	plain := base64.RawURLEncoding.EncodeToString(b)
	return plain, s.Hash(plain), nil
}

func (*TokenServiceImpl) Hash(token string) []byte {
	sum := sha256.Sum256([]byte(token))
	return sum[:]
}

func (s *TokenServiceImpl) VerifyHash(token string, expectedHash []byte) bool {
	got := s.Hash(token)
	return subtle.ConstantTimeCompare(got, expectedHash) == 1
}
