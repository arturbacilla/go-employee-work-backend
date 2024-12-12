package models

import (
	"gorm.io/datatypes"
	"gorm.io/gorm"
)

type Log struct {
	gorm.Model
	UserID    uint
	WeekDay   int8
	TimeIn    datatypes.Time
	TimeOut   datatypes.Time
	DayTask   string `gorm:"type:varchar(255)"`
	FromHome  bool   `gorm:"type:boolean;not null;default:false"`
	ProjectID uint
}
