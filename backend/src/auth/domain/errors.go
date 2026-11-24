package domain

import (
	"errors"

	"github.com/muhriddinnorqulov/skeleton/src/core/application/response"
)

// AuthError carries a stable machine-readable code alongside HTTP response mapping.
type AuthError struct {
	ResponseCode response.Code
	ErrorCode    string
	Message      string
	Data         any
}

func (e *AuthError) Error() string {
	return e.Message
}

func (e *AuthError) ToResponse() *response.Response {
	payload := map[string]any{"error": e.ErrorCode}
	if e.Data != nil {
		payload["details"] = e.Data
	}
	return response.NewResponse(e.ResponseCode, false, payload, e.Message)
}

func NewAuthError(respCode response.Code, errorCode, message string, data any) *AuthError {
	return &AuthError{
		ResponseCode: respCode,
		ErrorCode:    errorCode,
		Message:      message,
		Data:         data,
	}
}

var (
	ErrNotFound = errors.New("auth: record not found")

	ErrInvalidPhone = NewAuthError(response.CodeBadRequest, "INVALID_PHONE", "Telefon raqam formati noto'g'ri", nil)
	ErrInvalidRole  = NewAuthError(response.CodeBadRequest, "INVALID_ROLE", "Noto'g'ri rol tanlandi", nil)

	ErrOTPNotFound         = NewAuthError(response.CodeBadRequest, "OTP_NOT_FOUND", "Tasdiqlash kodi topilmadi", nil)
	ErrOTPExpired          = NewAuthError(response.CodeBadRequest, "OTP_EXPIRED", "Tasdiqlash kodi muddati tugagan", nil)
	ErrOTPAttemptsExceeded = NewAuthError(response.CodeBadRequest, "OTP_ATTEMPTS_EXCEEDED", "Urinishlar soni tugadi, yangi kod so'rang", nil)
	ErrOTPDailyLimit       = NewAuthError(response.CodeTooManyRequests, "OTP_DAILY_LIMIT", "Bugungi SMS limiti tugadi", nil)
	ErrLoginLocked         = NewAuthError(response.CodeTooManyRequests, "LOGIN_LOCKED", "Juda ko'p urinish. Keyinroq qayta urinib ko'ring", nil)

	ErrRegistrationTicketInvalid = NewAuthError(response.CodeBadRequest, "REGISTRATION_TICKET_INVALID", "Ro'yxatdan o'tish tokeni yaroqsiz yoki muddati tugagan", nil)
	ErrPhoneVerificationRequired = NewAuthError(response.CodeBadRequest, "PHONE_VERIFICATION_REQUIRED", "Telefon raqamingizni SMS kod orqali tasdiqlashingiz shart", nil)
	ErrIdentityTaken             = NewAuthError(response.CodeConflict, "IDENTITY_TAKEN", "Ushbu akkaunt allaqachon boshqa profilga ulangan", nil)
	ErrLastLoginMethod           = NewAuthError(response.CodeBadRequest, "LAST_LOGIN_METHOD", "Oxirgi kirish usulini uzib bo'lmaydi", nil)
	ErrInvalidProvider           = NewAuthError(response.CodeBadRequest, "INVALID_PROVIDER", "Noto'g'ri kirish usuli", nil)
	ErrUserBlocked               = NewAuthError(response.CodeForbidden, "USER_BLOCKED", "Foydalanuvchi bloklangan", nil)

	ErrGoogleNotConfigured   = NewAuthError(response.CodeServiceUnavailable, "GOOGLE_NOT_CONFIGURED", "Google orqali kirish hali sozlanmagan", nil)
	ErrGoogleCodeInvalid     = NewAuthError(response.CodeBadRequest, "GOOGLE_CODE_INVALID", "Google kodi yaroqsiz yoki muddati tugagan", nil)
	ErrGoogleEmailUnverified = NewAuthError(response.CodeForbidden, "GOOGLE_EMAIL_UNVERIFIED", "Google email tasdiqlanmagan", nil)
	ErrGoogleIDTokenInvalid  = NewAuthError(response.CodeBadRequest, "GOOGLE_ID_TOKEN_INVALID", "Google ID token yaroqsiz", nil)

	ErrTelegramNotConfigured = NewAuthError(response.CodeServiceUnavailable, "TELEGRAM_NOT_CONFIGURED", "Telegram bot hali sozlanmagan", nil)
	ErrTelegramNotFound      = NewAuthError(response.CodeNotFound, "TELEGRAM_LOGIN_NOT_FOUND", "Telegram kirish so'rovi topilmadi", nil)
	ErrTelegramExpired       = NewAuthError(response.CodeBadRequest, "TELEGRAM_LOGIN_EXPIRED", "Telegram kirish havolasi muddati tugagan", nil)
	ErrTelegramUsed          = NewAuthError(response.CodeConflict, "TELEGRAM_LOGIN_USED", "Telegram kirish havolasi allaqachon ishlatilgan", nil)
	ErrTelegramRejected      = NewAuthError(response.CodeForbidden, "TELEGRAM_LOGIN_REJECTED", "Telegram kirish bekor qilindi", nil)
	ErrTelegramWrongContact  = NewAuthError(response.CodeForbidden, "TELEGRAM_WRONG_CONTACT", "Faqat o'zingizning telefon raqamingizni yuboring", nil)

	ErrQRNotFound = NewAuthError(response.CodeNotFound, "QR_LOGIN_NOT_FOUND", "QR kod topilmadi yoki eskirgan", nil)
	ErrQRExpired  = NewAuthError(response.CodeBadRequest, "QR_LOGIN_EXPIRED", "QR kod muddati tugagan, yangisini oling", nil)
	ErrQRUsed     = NewAuthError(response.CodeConflict, "QR_LOGIN_USED", "Ushbu QR kod allaqachon ishlatilgan", nil)
	ErrQRRejected = NewAuthError(response.CodeForbidden, "QR_LOGIN_REJECTED", "Kirish so'rovi telefon orqali rad etildi", nil)

	ErrSessionInvalid = NewAuthError(response.CodeUnauthorized, "SESSION_INVALID", "Sessiya yaroqsiz yoki tugatilgan", nil)
	ErrSMSUnavailable = NewAuthError(response.CodeServiceUnavailable, "SMS_UNAVAILABLE", "SMS yuborish xizmati mavjud emas", nil)
)

func ErrOTPInvalid(attemptsLeft int) *AuthError {
	return NewAuthError(response.CodeBadRequest, "OTP_INVALID", "Tasdiqlash kodi noto'g'ri", map[string]any{
		"attempts_left": attemptsLeft,
	})
}

func ErrOTPResendCooldown(retryAfterSeconds int) *AuthError {
	return NewAuthError(response.CodeTooManyRequests, "OTP_RESEND_COOLDOWN", "Yangi kod so'rash uchun biroz kuting", map[string]any{
		"retry_after_seconds": retryAfterSeconds,
	})
}
