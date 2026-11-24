package google

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"io"
	"net/http"
	"net/url"
	"slices"
	"strings"
	"time"

	"github.com/muhriddinnorqulov/skeleton/src/auth/domain"
	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/env"
)

const (
	authEndpoint      = "https://accounts.google.com/o/oauth2/v2/auth"
	tokenEndpoint     = "https://oauth2.googleapis.com/token"
	userinfoEndpoint  = "https://openidconnect.googleapis.com/v1/userinfo"
	tokenInfoEndpoint = "https://oauth2.googleapis.com/tokeninfo"
)

// OAuthImpl supports both:
//  1. Web OAuth 2.0 Authorization Code + PKCE (S256) via Start + Exchange
//  2. Mobile (Flutter) native Google Sign-In ID Token verification via VerifyIDToken
type OAuthImpl struct {
	clientID       string
	clientSecret   string
	redirectURL    string
	allowedAuds    []string
	client         *http.Client
	tokenURL       string
	userinfoURL    string
	tokenInfoURL   string
}

// @inject
func NewOAuthImpl(cfg *env.Env) domain.GoogleOAuth {
	auds := make([]string, 0, 1+len(cfg.GoogleMobileClientIDs))
	if cfg.GoogleClientID != "" {
		auds = append(auds, cfg.GoogleClientID)
	}
	for _, id := range cfg.GoogleMobileClientIDs {
		if trimmed := strings.TrimSpace(id); trimmed != "" {
			auds = append(auds, trimmed)
		}
	}
	return &OAuthImpl{
		clientID:     cfg.GoogleClientID,
		clientSecret: cfg.GoogleClientSecret,
		redirectURL:  cfg.GoogleRedirectURL,
		allowedAuds:  auds,
		client:       &http.Client{Timeout: 10 * time.Second},
		tokenURL:     tokenEndpoint,
		userinfoURL:  userinfoEndpoint,
		tokenInfoURL: tokenInfoEndpoint,
	}
}

func (o *OAuthImpl) Enabled() bool {
	return o.clientID != "" && o.clientSecret != "" && o.redirectURL != ""
}

func (o *OAuthImpl) Start() (*domain.GoogleAuthStart, error) {
	if !o.Enabled() {
		return nil, domain.ErrGoogleNotConfigured
	}
	state, err := randomToken()
	if err != nil {
		return nil, err
	}
	verifier, err := randomToken()
	if err != nil {
		return nil, err
	}
	sum := sha256.Sum256([]byte(verifier))
	q := url.Values{
		"client_id":             {o.clientID},
		"redirect_uri":          {o.redirectURL},
		"response_type":         {"code"},
		"scope":                 {"openid email profile"},
		"state":                 {state},
		"code_challenge":        {base64.RawURLEncoding.EncodeToString(sum[:])},
		"code_challenge_method": {"S256"},
		"prompt":                {"select_account"},
	}
	return &domain.GoogleAuthStart{
		AuthorizationURL: authEndpoint + "?" + q.Encode(),
		State:            state,
		CodeVerifier:     verifier,
	}, nil
}

type tokenResponse struct {
	AccessToken string `json:"access_token"`
	Error       string `json:"error"`
}

type userinfoResponse struct {
	Sub           string `json:"sub"`
	Email         string `json:"email"`
	EmailVerified bool   `json:"email_verified"`
	GivenName     string `json:"given_name"`
	FamilyName    string `json:"family_name"`
	Picture       string `json:"picture"`
}

func (o *OAuthImpl) Exchange(ctx context.Context, code, codeVerifier string) (*domain.GoogleProfile, error) {
	if !o.Enabled() {
		return nil, domain.ErrGoogleNotConfigured
	}
	form := url.Values{
		"grant_type":    {"authorization_code"},
		"code":          {code},
		"code_verifier": {codeVerifier},
		"client_id":     {o.clientID},
		"client_secret": {o.clientSecret},
		"redirect_uri":  {o.redirectURL},
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, o.tokenURL, strings.NewReader(form.Encode()))
	if err != nil {
		return nil, domain.ErrGoogleCodeInvalid
	}
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	var tok tokenResponse
	status, err := o.doJSON(req, &tok)
	if err != nil {
		return nil, domain.ErrGoogleNotConfigured
	}
	if status == http.StatusBadRequest || status == http.StatusUnauthorized || tok.AccessToken == "" {
		return nil, domain.ErrGoogleCodeInvalid
	}
	if status != http.StatusOK {
		return nil, domain.ErrGoogleCodeInvalid
	}

	req, err = http.NewRequestWithContext(ctx, http.MethodGet, o.userinfoURL, nil)
	if err != nil {
		return nil, domain.ErrGoogleCodeInvalid
	}
	req.Header.Set("Authorization", "Bearer "+tok.AccessToken)

	var info userinfoResponse
	status, err = o.doJSON(req, &info)
	if err != nil || status != http.StatusOK || info.Sub == "" {
		return nil, domain.ErrGoogleCodeInvalid
	}

	return &domain.GoogleProfile{
		Subject:       info.Sub,
		Email:         strings.ToLower(strings.TrimSpace(info.Email)),
		EmailVerified: info.EmailVerified,
		GivenName:     strings.TrimSpace(info.GivenName),
		FamilyName:    strings.TrimSpace(info.FamilyName),
		AvatarURL:     strings.TrimSpace(info.Picture),
	}, nil
}

type tokenInfoResponse struct {
	Aud           string `json:"aud"`
	Sub           string `json:"sub"`
	Email         string `json:"email"`
	EmailVerified string `json:"email_verified"`
	GivenName     string `json:"given_name"`
	FamilyName    string `json:"family_name"`
	Picture       string `json:"picture"`
}

// VerifyIDToken validates a native mobile (Flutter) Google Sign-In ID token over HTTPS
// against Google's tokeninfo endpoint and checks aud against configured client IDs.
func (o *OAuthImpl) VerifyIDToken(ctx context.Context, idToken string) (*domain.GoogleProfile, error) {
	if len(o.allowedAuds) == 0 {
		return nil, domain.ErrGoogleNotConfigured
	}
	trimmed := strings.TrimSpace(idToken)
	if trimmed == "" {
		return nil, domain.ErrGoogleIDTokenInvalid
	}
	endpoint := o.tokenInfoURL + "?id_token=" + url.QueryEscape(trimmed)
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return nil, domain.ErrGoogleIDTokenInvalid
	}

	var info tokenInfoResponse
	status, err := o.doJSON(req, &info)
	if err != nil || status != http.StatusOK || info.Sub == "" {
		return nil, domain.ErrGoogleIDTokenInvalid
	}
	if !slices.Contains(o.allowedAuds, info.Aud) {
		return nil, domain.ErrGoogleIDTokenInvalid
	}
	return &domain.GoogleProfile{
		Subject:       info.Sub,
		Email:         strings.ToLower(strings.TrimSpace(info.Email)),
		EmailVerified: strings.EqualFold(info.EmailVerified, "true"),
		GivenName:     strings.TrimSpace(info.GivenName),
		FamilyName:    strings.TrimSpace(info.FamilyName),
		AvatarURL:     strings.TrimSpace(info.Picture),
	}, nil
}

func (o *OAuthImpl) doJSON(req *http.Request, out any) (int, error) {
	req.Header.Set("Accept", "application/json")
	res, err := o.client.Do(req)
	if err != nil {
		return 0, err
	}
	defer func() { _ = res.Body.Close() }()
	body, err := io.ReadAll(io.LimitReader(res.Body, 64<<10))
	if err != nil {
		return res.StatusCode, err
	}
	_ = json.Unmarshal(body, out)
	return res.StatusCode, nil
}

func randomToken() (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(b), nil
}
