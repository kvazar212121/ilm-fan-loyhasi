package middlewares

import (
	"strings"

	authdomain "github.com/muhriddinnorqulov/skeleton/src/auth/domain"
	"github.com/muhriddinnorqulov/skeleton/src/core/domain/ports/httpport"
	"github.com/muhriddinnorqulov/skeleton/src/core/domain/ports/httpport/ctx"
)

type JwtAuthMiddleware struct {
	verifier authdomain.AccessTokenVerifier
}

// @inject
func NewJwtAuthMiddleware(verifier authdomain.AccessTokenVerifier) *JwtAuthMiddleware {
	return &JwtAuthMiddleware{verifier: verifier}
}

func (this *JwtAuthMiddleware) Wrap(next httpport.HandlerFunc) httpport.HandlerFunc {
	return func(c ctx.Context) error {
		authHeader := c.GetRequest().Header.Get("Authorization")
		if authHeader != "" && strings.HasPrefix(authHeader, "Bearer ") {
			token := strings.TrimSpace(strings.TrimPrefix(authHeader, "Bearer "))
			if token != "" {
				if user, err := this.verifier.VerifyAccessToken(c.GetContext(), token); err == nil && user != nil {
					c.SetUser(user)
				}
			}
		}
		return next(c)
	}
}
