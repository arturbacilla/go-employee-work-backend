package models

import (
	"gorm.io/gorm"
)

type Project struct {
	gorm.Model
	Name          string
	Log           Log
	Year          string
	ProjectNumber int32
}
