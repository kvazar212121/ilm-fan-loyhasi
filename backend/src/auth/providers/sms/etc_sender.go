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

	"github.com/google/uuid"
	"github.com/muhriddinnorqulov/skeleton/src/auth/domain"
	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/env"
)

// etcSender sends SMS via the sms.etc.uz gateway (POST <base>/single-sms).
// CdPN expects the E.164 phone number without the leading "+".
type etcSender struct {
	url       string
	username  string
	password  string
	alphaName string
	client    *http.Client
}

func newEtcSender(cfg *env.Env) (etcSender, error) {
	if cfg.SMSEtcBaseURL == "" || cfg.SMSEtcUsername == "" || cfg.SMSEtcPassword == "" || cfg.SMSEtcAlphaName == "" {
		return etcSender{}, fmt.Errorf("SMS_PROVIDER=etc requires SMS_ETC_BASE_URL, SMS_ETC_USERNAME, SMS_ETC_PASSWORD and SMS_ETC_ALPHA_NAME")
	}
	return etcSender{
		url:       strings.TrimRight(cfg.SMSEtcBaseURL, "/") + "/single-sms",
		username:  cfg.SMSEtcUsername,
		password:  cfg.SMSEtcPassword,
		alphaName: cfg.SMSEtcAlphaName,
		client:    &http.Client{Timeout: 10 * time.Second},
	}, nil
}

type etcRequest struct {
	Header etcHeader `json:"header"`
	Body   etcBody   `json:"body"`
}

type etcHeader struct {
	Login string `json:"login"`
	Pwd   string `json:"pwd"`
	CgPN  string `json:"CgPN"`
}

type etcBody struct {
	MessageID string `json:"message_id_in"`
	CdPN      string `json:"CdPN"`
	Text      string `json:"text"`
}

func (s etcSender) Send(ctx context.Context, phoneE164, text string) error {
	payload, err := json.Marshal(etcRequest{
		Header: etcHeader{
			Login: s.username,
			Pwd:   s.password,
			CgPN:  s.alphaName,
		},
		Body: etcBody{
			MessageID: uuid.NewString(),
			CdPN:      strings.TrimPrefix(phoneE164, "+"),
			Text:      text,
		},
	})
	if err != nil {
		return domain.ErrSMSUnavailable
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, s.url, bytes.NewReader(payload))
	if err != nil {
		return domain.ErrSMSUnavailable
	}
	req.Header.Set("Content-Type", "application/json")

	res, err := s.client.Do(req)
	if err != nil {
		return domain.ErrSMSUnavailable
	}
	defer func() { _ = res.Body.Close() }()
	if res.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(io.LimitReader(res.Body, 512))
		return domain.NewAuthError(
			domain.ErrSMSUnavailable.ResponseCode,
			domain.ErrSMSUnavailable.ErrorCode,
			fmt.Sprintf("sms.etc.uz status %d: %s", res.StatusCode, strings.TrimSpace(string(body))),
			nil,
		)
	}
	_, _ = io.Copy(io.Discard, res.Body)
	return nil
}
