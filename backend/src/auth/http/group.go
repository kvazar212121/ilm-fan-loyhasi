package authhttp

import (
	"github.com/muhriddinnorqulov/skeleton/src/core/domain/ports/httpport"
	"github.com/muhriddinnorqulov/skeleton/src/entrypoint/http/interceptor/permissions"
)

type AuthGroup struct {
	handlers *Handlers
}

// @inject
func NewAuthGroup(handlers *Handlers) *AuthGroup {
	return &AuthGroup{handlers: handlers}
}

func (g *AuthGroup) RegisterRoutes(group httpport.Group) {
	// Phone SMS OTP
	group.POST("/otp/sms", g.handlers.SendSMSOTP)
	group.POST("/otp/verify", g.handlers.VerifySMSOTP)

	// Google OAuth 2.0 + PKCE (Web) and Native ID Token (Flutter/Mobile)
	group.POST("/google/start", g.handlers.StartGoogle)
	group.POST("/google/callback", g.handlers.GoogleCallback)
	group.POST("/google/id-token", g.handlers.GoogleIDToken)

	// Telegram Bot deep-link + polling
	group.POST("/telegram/start", g.handlers.StartTelegram)
	group.POST("/telegram/poll", g.handlers.PollTelegram)

	// Steam-style QR code browser login (desktop scans from mobile browser)
	group.POST("/qr/start", g.handlers.StartQR)
	group.POST("/qr/poll", g.handlers.PollQR)
	group.POST("/qr/scan", g.handlers.ScanQR)
	group.POST("/qr/telegram/start", g.handlers.StartQRTelegram)
	group.POST("/qr/approve-session", g.handlers.ApproveQRSession, permissions.AuthenticatedUserPermission)
	group.POST("/qr/approve-registration", g.handlers.ApproveQRRegistration)
	group.POST("/qr/reject", g.handlers.RejectQR)

	// Multi-step onboarding completion (Role -> Fan -> Profile)
	group.POST("/registration/inspect", g.handlers.InspectRegistration)
	group.POST("/registration/verify-phone", g.handlers.VerifyRegistrationPhone)
	group.POST("/register", g.handlers.Register)

	// Session / Tokens / Profile & Account Linking
	group.POST("/refresh", g.handlers.Refresh)
	group.POST("/logout", g.handlers.Logout, permissions.AuthenticatedUserPermission)
	group.GET("/me", g.handlers.Me, permissions.AuthenticatedUserPermission)
	group.PUT("/me/profile", g.handlers.UpdateProfile, permissions.AuthenticatedUserPermission)
	group.POST("/me/google/link", g.handlers.LinkGoogleCallback, permissions.AuthenticatedUserPermission)
	group.POST("/me/google/id-token", g.handlers.LinkGoogleIDToken, permissions.AuthenticatedUserPermission)
	group.POST("/me/telegram/link/start", g.handlers.StartTelegramLink, permissions.AuthenticatedUserPermission)
	group.POST("/me/telegram/link/poll", g.handlers.PollTelegramLink, permissions.AuthenticatedUserPermission)
	group.POST("/me/phone/verify", g.handlers.VerifyLinkPhone, permissions.AuthenticatedUserPermission)
	group.DELETE("/me/methods/:provider", g.handlers.UnlinkMethod, permissions.AuthenticatedUserPermission)
}
