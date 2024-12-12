package models

import (
	"gorm.io/datatypes"
	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	Name      string
	Email     string
	StartDate datatypes.Date `gorm:"type:DATE;not null;default:NOW()"`
	EndDate   *datatypes.Date
	CardId    string
	Salary    float32 `gorm:"type:numeric(6,2);default:10.00"`
	VT        float32 `gorm:"type:numeric(6,2);default:12.00"`
	Logs      []Log
}
