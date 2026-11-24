package sms

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/env"
)

func TestDevSMSSender_SuccessAndError(t *testing.T) {
	var gotAuth string
	var gotReq devsmsRequest

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/send_sms.php" {
			t.Fatalf("unexpected path: %s", r.URL.Path)
		}
		gotAuth = r.Header.Get("Authorization")
		_ = json.NewDecoder(r.Body).Decode(&gotReq)
		w.Header().Set("Content-Type", "application/json")
		if gotReq.Phone == "998900000000" {
			w.WriteHeader(http.StatusBadRequest)
			_, _ = w.Write([]byte(`{"success":false,"message":"moderation failed"}`))
			return
		}
		_, _ = w.Write([]byte(`{"success":true,"data":{"sms_id":"123"}}`))
	}))
	defer srv.Close()

	sender, err := newDevSMSSender(&env.Env{
		DevSMSBaseURL: srv.URL,
		DevSMSToken:   "tok-test",
		DevSMSSender:  "4546",
	})
	if err != nil {
		t.Fatalf("newDevSMSSender failed: %v", err)
	}

	if err := sender.Send(context.Background(), "+998901234567", "Test code: 12345"); err != nil {
		t.Fatalf("Send failed: %v", err)
	}
	if gotAuth != "Bearer tok-test" {
		t.Fatalf("expected Bearer auth header, got %q", gotAuth)
	}
	if gotReq.Phone != "998901234567" || gotReq.From != "4546" || gotReq.Message != "Test code: 12345" {
		t.Fatalf("unexpected payload: %+v", gotReq)
	}

	if err := sender.Send(context.Background(), "+998900000000", "Bad"); err == nil {
		t.Fatalf("expected error on rejected SMS")
	}
}
