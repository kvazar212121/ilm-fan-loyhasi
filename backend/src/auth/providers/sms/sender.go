package sms

import (
	"context"
	"fmt"

	"github.com/muhriddinnorqulov/skeleton/src/auth/domain"
	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/env"
	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/logger"
	"go.uber.org/zap"
)

const (
	ProviderLog    = "log"
	ProviderEtc    = "etc"
	ProviderDevSMS = "devsms"
)

// NewSender selects the SMS transport from SMS_PROVIDER:
//   - "devsms": sends via devsms.uz (requires DEVSMS_TOKEN)
//   - "etc": sends via sms.etc.uz (requires SMS_ETC_BASE_URL, SMS_ETC_USERNAME, SMS_ETC_PASSWORD, SMS_ETC_ALPHA_NAME)
//   - "log": writes the SMS text (with OTP code) to console log for local development
//
// @inject
func NewSender(cfg *env.Env, consoleLogger *logger.ConsoleLogger) domain.SMSSender {
	switch cfg.SMSProvider {
	case ProviderDevSMS:
		s, err := newDevSMSSender(cfg)
		if err != nil {
			consoleLogger.Error("SMS provider=devsms misconfigured", zap.Error(err))
			return unconfiguredSender{reason: err.Error()}
		}
		return s
	case ProviderEtc:
		s, err := newEtcSender(cfg)
		if err != nil {
			consoleLogger.Error("SMS provider=etc misconfigured", zap.Error(err))
			return unconfiguredSender{reason: err.Error()}
		}
		return s
	case ProviderLog:
		return logSender{lg: consoleLogger}
	default:
		return unconfiguredSender{reason: fmt.Sprintf("unsupported SMS_PROVIDER=%q (use 'log', 'etc' or 'devsms')", cfg.SMSProvider)}
	}
}

type logSender struct {
	lg *logger.ConsoleLogger
}

func (s logSender) Send(_ context.Context, phoneE164, text string) error {
	masked := phoneE164
	if p, err := domain.ParsePhoneNumber(phoneE164); err == nil {
		masked = p.Masked()
	}
	s.lg.Warn("DEV SMS (SMS_PROVIDER=log)",
		zap.String("to", masked),
		zap.String("text", text),
	)
	return nil
}

type unconfiguredSender struct {
	reason string
}

func (s unconfiguredSender) Send(context.Context, string, string) error {
	return domain.NewAuthError(
		domain.ErrSMSUnavailable.ResponseCode,
		domain.ErrSMSUnavailable.ErrorCode,
		s.reason,
		nil,
	)
}
