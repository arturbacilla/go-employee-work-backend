package main

import (
	"fmt"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"

	"internal/messages"
)

func main() {

	err := godotenv.Load(".env")
	if err != nil {
		messages.MsgError(fmt.Sprintf("%s", err))
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "3001"
		messages.MsgWarn("No ports been set on environment variables. Using default port 3001")
	}

	server := gin.Default()

	server.GET("/ping", func(ctx *gin.Context) {
		ctx.JSON(200, gin.H{
			"message": "pong",
		})
	})

	server.Run(fmt.Sprintf(":%s", port))

}
