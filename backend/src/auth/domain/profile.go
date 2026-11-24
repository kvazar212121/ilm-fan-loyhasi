package domain

import (
	"strings"
	"time"

	"github.com/muhriddinnorqulov/skeleton/src/core/application/response"
)

const (
	GenderMale   = "male"
	GenderFemale = "female"
)

var (
	ErrInvalidBirthDate = NewAuthError(response.CodeBadRequest, "INVALID_BIRTH_DATE", "Tug'ilgan sana noto'g'ri (YYYY-MM-DD)", nil)
	ErrInvalidRegion    = NewAuthError(response.CodeBadRequest, "INVALID_REGION", "Viloyat tanlanishi shart", nil)
	ErrInvalidGender    = NewAuthError(response.CodeBadRequest, "INVALID_GENDER", "Jins noto'g'ri ('male' yoki 'female')", nil)
)

func ValidateBirthDate(raw string, now time.Time) (string, error) {
	trimmed := strings.TrimSpace(raw)
	if trimmed == "" {
		return "", ErrInvalidBirthDate
	}
	parsed, err := time.Parse("2006-01-02", trimmed)
	if err != nil {
		return "", ErrInvalidBirthDate
	}
	if parsed.Year() < 1920 || parsed.After(now) {
		return "", ErrInvalidBirthDate
	}
	return parsed.Format("2006-01-02"), nil
}

func ValidateRegion(raw string) (string, error) {
	trimmed := strings.TrimSpace(raw)
	if trimmed == "" || len([]rune(trimmed)) > 64 {
		return "", ErrInvalidRegion
	}
	return trimmed, nil
}

func ValidateGender(raw string) (string, error) {
	switch strings.ToLower(strings.TrimSpace(raw)) {
	case GenderMale:
		return GenderMale, nil
	case GenderFemale:
		return GenderFemale, nil
	default:
		return "", ErrInvalidGender
	}
}
