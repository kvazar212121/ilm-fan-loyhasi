package env

import (
	"os"

	"github.com/caarlos0/env/v10"
	"github.com/joho/godotenv"
)

type Env struct {
	HttpAddress string `env:"HTTP_ADDRESS,required"`
	DBHost      string `env:"DB_HOST,required"`
	DBPort      string `env:"DB_PORT,required"`
	DBUser      string `env:"DB_USER,required"`
	DBPassword  string `env:"DB_PASSWORD,required"`
	DBName      string `env:"DB_NAME,required"`
	DBSSLMode   string `env:"DB_SSLMODE,required"`

	RedisAddress  string `env:"REDIS_ADDRESS,required"`
	RedisPassword string `env:"REDIS_PASSWORD,required"`

	CorsAllowCredentials bool     `env:"CORS_ALLOW_CREDENTIALS,required"`
	CorsAllowOrigin      []string `env:"CORS_ALLOW_ORIGIN,required"`

	JwtSecret  string `env:"JWT_SECRET,required"`
	HmacSecret string `env:"HMAC_SECRET,required"`

	AccessTimeExpireMinutes   int64 `env:"ACCESS_EXPIRE_MINUTES,required"`
	RefreshTokenExpireMinutes int64 `env:"REFRESH_EXPIRE_MINUTES,required"`

	StoragePath string `env:"STORAGE_PATH" envDefault:"storage"`
	StorageURL  string `env:"STORAGE_URL,required"`

	DevUsername string `env:"DEV_USERNAME" envDefault:"admin"`
	DevPassword string `env:"DEV_PASSWORD" envDefault:"admin"`

	// Auth: SMS ("log" for local dev, "etc" for sms.etc.uz, "devsms" for devsms.uz)
	SMSProvider     string `env:"SMS_PROVIDER" envDefault:"log"`
	SMSAppDomain    string `env:"SMS_APP_DOMAIN" envDefault:"sat-ilmfan.gvazar.uz"`
	SMSOTPTemplate  string `env:"SMS_OTP_TEMPLATE"`
	SMSEtcBaseURL   string `env:"SMS_ETC_BASE_URL"`
	SMSEtcUsername  string `env:"SMS_ETC_USERNAME"`
	SMSEtcPassword  string `env:"SMS_ETC_PASSWORD"`
	SMSEtcAlphaName string `env:"SMS_ETC_ALPHA_NAME"`
	DevSMSBaseURL   string `env:"DEVSMS_BASE_URL" envDefault:"https://devsms.uz/api"`
	DevSMSToken     string `env:"DEVSMS_TOKEN"`
	DevSMSSender    string `env:"DEVSMS_SENDER" envDefault:"4546"`
	DevSMSCallback  string `env:"DEVSMS_CALLBACK_URL"`

	// Auth: Google OAuth (Web PKCE + optional Flutter/mobile client IDs)
	GoogleClientID        string   `env:"GOOGLE_CLIENT_ID"`
	GoogleClientSecret    string   `env:"GOOGLE_CLIENT_SECRET"`
	GoogleRedirectURL     string   `env:"GOOGLE_REDIRECT_URL"`
	GoogleMobileClientIDs []string `env:"GOOGLE_MOBILE_CLIENT_IDS"`

	// Auth: Telegram Bot
	TelegramBotToken    string `env:"TELEGRAM_BOT_TOKEN"`
	TelegramBotUsername string `env:"TELEGRAM_BOT_USERNAME"`
}

// @inject
func NewEnv() *Env {
	return parseEnv()
}

func parseEnv() *Env {
	loadEnv()
	cfg := &Env{}
	if err := env.Parse(cfg); err != nil {
		panic(err)
	}
	return cfg
}

func loadEnv() {
	if os.Getenv("CONTAINER_MODE") != "1" {
		_ = godotenv.Load(".env.local")
		_ = godotenv.Load(".env")
	}
}
