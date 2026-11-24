package entity

type UserEntity struct {
	ID        uint     `json:"id"`
	FirstName string   `json:"first_name"`
	LastName  *string  `json:"last_name,omitempty"`
	Role      string   `json:"role,omitempty"`
	FanIDs    []string `json:"fan_ids,omitempty"`
	AvatarURL *string  `json:"avatar_url,omitempty"`
	Phone     *string  `json:"phone,omitempty"`
	Email     *string  `json:"email,omitempty"`
	BirthDate *string  `json:"birth_date,omitempty"`
	Region    *string  `json:"region,omitempty"`
	Gender    *string  `json:"gender,omitempty"`
	IsBlocked bool     `json:"is_blocked,omitempty"`
}
