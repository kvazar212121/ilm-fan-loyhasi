package domain

import (
	"fmt"
	"strings"

	"github.com/nyaruka/phonenumbers"
)

const defaultPhoneRegion = "UZ"

// PhoneNumber is a validated E.164 phone number with its ISO region code.
type PhoneNumber struct {
	E164   string `json:"e164"`
	Region string `json:"region"`
}

// ParsePhoneNumber parses and validates a phone number, defaulting to Uzbekistan (+998)
// when no international prefix is given.
func ParsePhoneNumber(raw string) (PhoneNumber, error) {
	trimmed := strings.TrimSpace(raw)
	if trimmed == "" {
		return PhoneNumber{}, ErrInvalidPhone
	}
	num, err := phonenumbers.Parse(trimmed, defaultPhoneRegion)
	if err != nil || !phonenumbers.IsValidNumber(num) {
		return PhoneNumber{}, ErrInvalidPhone
	}
	return PhoneNumber{
		E164:   phonenumbers.Format(num, phonenumbers.E164),
		Region: phonenumbers.GetRegionCodeForNumber(num),
	}, nil
}

// Masked returns a privacy-safe display format such as "+998 90 *** ** 67".
func (p PhoneNumber) Masked() string {
	if len(p.E164) < 6 {
		return p.E164
	}
	prefix := p.E164[:min(6, len(p.E164)-2)]
	suffix := p.E164[len(p.E164)-2:]
	return fmt.Sprintf("%s*****%s", prefix, suffix)
}
