package config

import (
	"fmt"
	"internal/messages"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	HOST              string
	PORT              string
	POSTGRES_DB       string
	POSTGRES_USER     string
	POSTGRES_PASSWORD string
}

var AppConfig *Config

func LoadConfig() {
	err := godotenv.Load(".env")
	if err != nil {
		messages.MsgError(fmt.Sprintf("%s", err))
	}

	requiredEnvVars := []string{"POSTGRES_DB", "POSTGRES_USER", "POSTGRES_PASSWORD"}

	for _, envVar := range requiredEnvVars {
		if os.Getenv(envVar) == "" {
			messages.MsgError(fmt.Sprintf("Environment variable %s is required but not set", envVar))
		}
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "3001"
		messages.MsgWarn("No ports been set on environment variables. Using default port 3001")
	}

	host := os.Getenv(("HOST"))
	if host == "" {
		host = "localhost"
		messages.MsgWarn("No host have been set. Using localhost")
	}

	AppConfig = &Config{
		HOST:              host,
		PORT:              port,
		POSTGRES_DB:       os.Getenv("POSTGRES_DB"),
		POSTGRES_USER:     os.Getenv("POSTGRES_USER"),
		POSTGRES_PASSWORD: os.Getenv("POSTGRES_PASSWORD"),
	}
}
