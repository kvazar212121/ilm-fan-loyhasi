package authhttp

type SendSMSRequest struct {
	Phone string `json:"phone" validate:"required"`
}

type VerifySMSRequest struct {
	Phone string `json:"phone" validate:"required"`
	Code  string `json:"code" validate:"required,min=4,max=8"`
}

type GoogleCallbackRequest struct {
	Code         string `json:"code" validate:"required"`
	CodeVerifier string `json:"code_verifier" validate:"required"`
}

type GoogleIDTokenRequest struct {
	IDToken string `json:"id_token" validate:"required"`
}

type PollTelegramRequest struct {
	AttemptID string `json:"attempt_id" validate:"required,uuid4"`
	Secret    string `json:"secret" validate:"required"`
}

type InspectRegistrationRequest struct {
	RegistrationToken string `json:"registration_token" validate:"required"`
}

type VerifyRegistrationPhoneRequest struct {
	RegistrationToken string `json:"registration_token" validate:"required"`
	Phone             string `json:"phone" validate:"required"`
	Code              string `json:"code" validate:"required,min=4,max=8"`
}

type CompleteRegistrationRequest struct {
	RegistrationToken string   `json:"registration_token" validate:"required"`
	Role              string   `json:"role" validate:"required"`
	FanIDs            []string `json:"fan_ids"`
	FirstName         string   `json:"first_name" validate:"required,min=1,max=64"`
	LastName          string   `json:"last_name" validate:"required,min=1,max=64"`
	Phone             string   `json:"phone" validate:"max=32"`
	BirthDate         string   `json:"birth_date" validate:"required,len=10"`
	Region            string   `json:"region" validate:"required,min=2,max=64"`
	Gender            string   `json:"gender" validate:"required,oneof=male female"`
	AvatarURL         string   `json:"avatar_url" validate:"max=512"`
}

type UpdateProfileRequest struct {
	FirstName string `json:"first_name" validate:"required,min=1,max=64"`
	LastName  string `json:"last_name" validate:"required,min=1,max=64"`
	Phone     string `json:"phone" validate:"max=32"`
	BirthDate string `json:"birth_date" validate:"required,len=10"`
	Region    string `json:"region" validate:"required,min=2,max=64"`
	Gender    string `json:"gender" validate:"required,oneof=male female"`
	AvatarURL string `json:"avatar_url" validate:"max=512"`
}

type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" validate:"required"`
}

type LogoutRequest struct {
	RefreshToken string `json:"refresh_token"`
}

type PollQRRequest struct {
	AttemptID string `json:"attempt_id" validate:"required,uuid4"`
	Secret    string `json:"secret" validate:"required"`
}

type QRTokenRequest struct {
	QRToken string `json:"qr_token" validate:"required"`
}

type ApproveQRRegistrationRequest struct {
	QRToken           string `json:"qr_token" validate:"required"`
	RegistrationToken string `json:"registration_token" validate:"required"`
}
