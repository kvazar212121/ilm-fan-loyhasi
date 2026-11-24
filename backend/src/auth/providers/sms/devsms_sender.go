package sms

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/muhriddinnorqulov/skeleton/src/auth/domain"
	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/env"
)

// devsmsSender sends SMS via devsms.uz REST API (POST <base>/send_sms.php).
type devsmsSender struct {
	url         string
	token       string
	from        string
	callbackURL string
	client      *http.Client
}

func newDevSMSSender(cfg *env.Env) (devsmsSender, error) {
	baseURL := strings.TrimSpace(cfg.DevSMSBaseURL)
	if baseURL == "" {
		baseURL = "https://devsms.uz/api"
	}
	token := strings.TrimSpace(cfg.DevSMSToken)
	if token == "" {
		return devsmsSender{}, fmt.Errorf("SMS_PROVIDER=devsms requires DEVSMS_TOKEN")
	}
	from := strings.TrimSpace(cfg.DevSMSSender)
	if from == "" {
		from = "4546"
	}
	return devsmsSender{
		url:         strings.TrimRight(baseURL, "/") + "/send_sms.php",
		token:       token,
		from:        from,
		callbackURL: strings.TrimSpace(cfg.DevSMSCallback),
		client:      &http.Client{Timeout: 20 * time.Second},
	}, nil
}

type devsmsRequest struct {
	Phone       string `json:"phone"`
	Message     string `json:"message"`
	From        string `json:"from"`
	CallbackURL string `json:"callback_url,omitempty"`
}

type devsmsResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
	Error   string `json:"error"`
}

func (s devsmsSender) Send(ctx context.Context, phoneE164, text string) error {
	payload, err := json.Marshal(devsmsRequest{
		Phone:       strings.TrimPrefix(phoneE164, "+"),
		Message:     text,
		From:        s.from,
		CallbackURL: s.callbackURL,
	})
	if err != nil {
		return domain.ErrSMSUnavailable
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, s.url, bytes.NewReader(payload))
	if err != nil {
		return domain.ErrSMSUnavailable
	}
	req.Header.Set("Authorization", "Bearer "+s.token)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")

	res, err := s.client.Do(req)
	if err != nil {
		return domain.ErrSMSUnavailable
	}
	defer func() { _ = res.Body.Close() }()

	body, _ := io.ReadAll(io.LimitReader(res.Body, 1024))
	var parsed devsmsResponse
	if err := json.Unmarshal(body, &parsed); err != nil {
		return domain.NewAuthError(
			domain.ErrSMSUnavailable.ResponseCode,
			domain.ErrSMSUnavailable.ErrorCode,
			fmt.Sprintf("devsms.uz status %d: invalid response", res.StatusCode),
			nil,
		)
	}
	if res.StatusCode >= http.StatusBadRequest || !parsed.Success {
		msg := strings.TrimSpace(parsed.Message)
		if msg == "" {
			msg = strings.TrimSpace(parsed.Error)
		}
		if msg == "" {
			msg = fmt.Sprintf("devsms.uz status %d", res.StatusCode)
		}
		return domain.NewAuthError(
			domain.ErrSMSUnavailable.ResponseCode,
			domain.ErrSMSUnavailable.ErrorCode,
			msg,
			nil,
		)
	}
	return nil
}
