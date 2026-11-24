package authhttp

import (
	"errors"
	"net/http"
	"strings"

	"github.com/google/uuid"
	"github.com/muhriddinnorqulov/skeleton/src/auth/domain"
	"github.com/muhriddinnorqulov/skeleton/src/auth/service"
	"github.com/muhriddinnorqulov/skeleton/src/core/application/response"
	"github.com/muhriddinnorqulov/skeleton/src/core/domain/ports/httpport/ctx"
)

type Handlers struct {
	svc *service.AuthService
}

// @inject
func NewHandlers(svc *service.AuthService) *Handlers {
	return &Handlers{svc: svc}
}

func clientMeta(c ctx.Context) domain.ClientMeta {
	h := c.GetRequest().Header
	ip := strings.TrimSpace(strings.Split(h.Get("X-Forwarded-For"), ",")[0])
	if ip == "" {
		ip = strings.TrimSpace(h.Get("X-Real-IP"))
	}
	return domain.ClientMeta{
		IP:        ip,
		UserAgent: h.Get("User-Agent"),
	}
}

func mapErr(err error) error {
	if err == nil {
		return nil
	}
	var authErr *domain.AuthError
	if errors.As(err, &authErr) {
		return authErr.ToResponse()
	}
	return err
}

func (h *Handlers) SendSMSOTP(c ctx.Context) error {
	req, err := ctx.GetBody[SendSMSRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	out, err := h.svc.SendSMSOTP(c.GetContext(), req.Phone, clientMeta(c))
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, out)
}

func (h *Handlers) VerifySMSOTP(c ctx.Context) error {
	req, err := ctx.GetBody[VerifySMSRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	out, err := h.svc.VerifySMSOTP(c.GetContext(), req.Phone, req.Code, clientMeta(c))
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, out)
}

func (h *Handlers) StartGoogle(c ctx.Context) error {
	out, err := h.svc.StartGoogleLogin()
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusCreated, out)
}

func (h *Handlers) GoogleCallback(c ctx.Context) error {
	req, err := ctx.GetBody[GoogleCallbackRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	out, err := h.svc.GoogleCallback(c.GetContext(), req.Code, req.CodeVerifier, clientMeta(c))
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, out)
}

func (h *Handlers) GoogleIDToken(c ctx.Context) error {
	req, err := ctx.GetBody[GoogleIDTokenRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	out, err := h.svc.GoogleIDTokenLogin(c.GetContext(), req.IDToken, clientMeta(c))
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, out)
}

func (h *Handlers) StartTelegram(c ctx.Context) error {
	out, err := h.svc.StartTelegramLogin(c.GetContext(), clientMeta(c))
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusCreated, out)
}

func (h *Handlers) PollTelegram(c ctx.Context) error {
	req, err := ctx.GetBody[PollTelegramRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	attemptID, err := uuid.Parse(req.AttemptID)
	if err != nil {
		return domain.ErrTelegramNotFound.ToResponse()
	}
	out, err := h.svc.PollTelegramLogin(c.GetContext(), attemptID, req.Secret, clientMeta(c))
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, out)
}

func (h *Handlers) InspectRegistration(c ctx.Context) error {
	req, err := ctx.GetBody[InspectRegistrationRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	out, err := h.svc.InspectRegistration(c.GetContext(), req.RegistrationToken)
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, out)
}

func (h *Handlers) VerifyRegistrationPhone(c ctx.Context) error {
	req, err := ctx.GetBody[VerifyRegistrationPhoneRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	out, err := h.svc.VerifyRegistrationPhone(c.GetContext(), req.RegistrationToken, req.Phone, req.Code, clientMeta(c))
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, out)
}

func (h *Handlers) Register(c ctx.Context) error {
	req, err := ctx.GetBody[CompleteRegistrationRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	out, err := h.svc.CompleteRegistration(c.GetContext(), service.CompleteRegistrationInput{
		RegistrationToken: req.RegistrationToken,
		Role:              req.Role,
		FanIDs:            req.FanIDs,
		FirstName:         req.FirstName,
		LastName:          req.LastName,
		Phone:             req.Phone,
		BirthDate:         req.BirthDate,
		Region:            req.Region,
		Gender:            req.Gender,
		AvatarURL:         req.AvatarURL,
	}, clientMeta(c))
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusCreated, out)
}

func (h *Handlers) Refresh(c ctx.Context) error {
	req, err := ctx.GetBody[RefreshTokenRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	out, err := h.svc.RefreshTokens(c.GetContext(), req.RefreshToken)
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, out)
}

func (h *Handlers) Logout(c ctx.Context) error {
	user := c.User()
	if user == nil {
		return response.NewResponse(response.CodeUnauthorized, false, nil, "Unauthorized user")
	}
	var req LogoutRequest
	_ = c.Bind(&req)
	if err := h.svc.Logout(c.GetContext(), user.ID, req.RefreshToken); err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, map[string]bool{"ok": true})
}

func (h *Handlers) Me(c ctx.Context) error {
	user := c.User()
	if user == nil {
		return response.NewResponse(response.CodeUnauthorized, false, nil, "Unauthorized user")
	}
	out, err := h.svc.GetMe(c.GetContext(), user)
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, out)
}

func (h *Handlers) UpdateProfile(c ctx.Context) error {
	user := c.User()
	if user == nil {
		return response.NewResponse(response.CodeUnauthorized, false, nil, "Unauthorized user")
	}
	req, err := ctx.GetBody[UpdateProfileRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	updated, err := h.svc.UpdateProfile(c.GetContext(), user, service.UpdateProfileInput{
		FirstName: req.FirstName,
		LastName:  req.LastName,
		Phone:     req.Phone,
		BirthDate: req.BirthDate,
		Region:    req.Region,
		Gender:    req.Gender,
		AvatarURL: req.AvatarURL,
	})
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, map[string]any{"user": updated})
}

func (h *Handlers) LinkGoogleCallback(c ctx.Context) error {
	user := c.User()
	if user == nil {
		return response.NewResponse(response.CodeUnauthorized, false, nil, "Unauthorized user")
	}
	req, err := ctx.GetBody[GoogleCallbackRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	out, err := h.svc.LinkGoogleCallback(c.GetContext(), user, req.Code, req.CodeVerifier, clientMeta(c))
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, out)
}

func (h *Handlers) LinkGoogleIDToken(c ctx.Context) error {
	user := c.User()
	if user == nil {
		return response.NewResponse(response.CodeUnauthorized, false, nil, "Unauthorized user")
	}
	req, err := ctx.GetBody[GoogleIDTokenRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	out, err := h.svc.LinkGoogleIDToken(c.GetContext(), user, req.IDToken, clientMeta(c))
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, out)
}

func (h *Handlers) StartTelegramLink(c ctx.Context) error {
	if c.User() == nil {
		return response.NewResponse(response.CodeUnauthorized, false, nil, "Unauthorized user")
	}
	out, err := h.svc.StartTelegramLink(c.GetContext(), clientMeta(c))
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusCreated, out)
}

func (h *Handlers) PollTelegramLink(c ctx.Context) error {
	user := c.User()
	if user == nil {
		return response.NewResponse(response.CodeUnauthorized, false, nil, "Unauthorized user")
	}
	req, err := ctx.GetBody[PollTelegramRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	attemptID, err := uuid.Parse(req.AttemptID)
	if err != nil {
		return domain.ErrTelegramNotFound.ToResponse()
	}
	out, err := h.svc.PollTelegramLink(c.GetContext(), user, attemptID, req.Secret, clientMeta(c))
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, out)
}

func (h *Handlers) VerifyLinkPhone(c ctx.Context) error {
	user := c.User()
	if user == nil {
		return response.NewResponse(response.CodeUnauthorized, false, nil, "Unauthorized user")
	}
	req, err := ctx.GetBody[VerifySMSRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	out, err := h.svc.VerifyAndLinkPhone(c.GetContext(), user, req.Phone, req.Code, clientMeta(c))
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, out)
}

func (h *Handlers) UnlinkMethod(c ctx.Context) error {
	user := c.User()
	if user == nil {
		return response.NewResponse(response.CodeUnauthorized, false, nil, "Unauthorized user")
	}
	out, err := h.svc.UnlinkMethod(c.GetContext(), user, c.Param("provider"))
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, out)
}

func (h *Handlers) StartQR(c ctx.Context) error {
	out, err := h.svc.StartQRLogin(c.GetContext(), clientMeta(c))
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusCreated, out)
}

func (h *Handlers) PollQR(c ctx.Context) error {
	req, err := ctx.GetBody[PollQRRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	attemptID, err := uuid.Parse(req.AttemptID)
	if err != nil {
		return domain.ErrQRNotFound.ToResponse()
	}
	out, err := h.svc.PollQRLogin(c.GetContext(), attemptID, req.Secret, clientMeta(c))
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, out)
}

func (h *Handlers) ScanQR(c ctx.Context) error {
	req, err := ctx.GetBody[QRTokenRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	out, err := h.svc.ScanQRLogin(c.GetContext(), req.QRToken)
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, out)
}

func (h *Handlers) StartQRTelegram(c ctx.Context) error {
	req, err := ctx.GetBody[QRTokenRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	out, err := h.svc.StartQRTelegram(c.GetContext(), req.QRToken, clientMeta(c))
	if err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusCreated, out)
}

func (h *Handlers) ApproveQRSession(c ctx.Context) error {
	user := c.User()
	if user == nil {
		return response.NewResponse(response.CodeUnauthorized, false, nil, "Unauthorized user")
	}
	req, err := ctx.GetBody[QRTokenRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	if err := h.svc.ApproveQRWithUser(c.GetContext(), req.QRToken, user, domain.ProviderQR); err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, map[string]bool{"ok": true})
}

func (h *Handlers) ApproveQRRegistration(c ctx.Context) error {
	req, err := ctx.GetBody[ApproveQRRegistrationRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	if err := h.svc.ApproveQRWithRegistration(c.GetContext(), req.QRToken, req.RegistrationToken); err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, map[string]bool{"ok": true})
}

func (h *Handlers) RejectQR(c ctx.Context) error {
	req, err := ctx.GetBody[QRTokenRequest](c)
	if err != nil {
		return response.NewResponse(response.CodeBadRequest, false, nil, err.Error())
	}
	if err := h.svc.RejectQRLogin(c.GetContext(), req.QRToken); err != nil {
		return mapErr(err)
	}
	return c.Success(http.StatusOK, map[string]bool{"ok": true})
}
