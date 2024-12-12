package database

import (
	"arturbacilla/go-employee-work-backend/config"
	"fmt"
	"internal/messages"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectToDB() (postgresDB *gorm.DB) {
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=5432 sslmode=disable TimeZone=America/Sao_Paulo", config.AppConfig.HOST, config.AppConfig.POSTGRES_USER, config.AppConfig.POSTGRES_PASSWORD, config.AppConfig.POSTGRES_DB)
	messages.MsgInfo(dsn)
	DB, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})

	if err != nil {
		messages.MsgError("Failed to connect to database")
	}

	return DB
}
