package models

import "gorm.io/gorm"

type UserModel struct {
	gorm.Model
	FirstName string  `gorm:"size:64;not null"`
	LastName  *string `gorm:"size:64"`
	Role      string  `gorm:"size:32;index"`
	FanIDs    string  `gorm:"type:text"`
	AvatarURL *string `gorm:"size:512"`
	Phone     *string `gorm:"size:32;uniqueIndex"`
	Email     *string `gorm:"size:255;uniqueIndex"`
	BirthDate *string `gorm:"size:16"`
	Region    *string `gorm:"size:64"`
	Gender    *string `gorm:"size:16"`
	IsBlocked bool    `gorm:"not null;default:false"`
}

func (this *UserModel) TableName() string {
	return "users"
}
