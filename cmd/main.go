package main

import (
	"arturbacilla/go-employee-work-backend/config"
	database "arturbacilla/go-employee-work-backend/initializers"
	"fmt"

	"github.com/gin-gonic/gin"

	"internal/messages"
)

func init() {
	config.LoadConfig()
	database.ConnectToDB()
}

func main() {
	if config.AppConfig == nil {
		messages.MsgError("Config not initialized")
	}

	server := gin.Default()

	server.GET("/ping", func(ctx *gin.Context) {
		ctx.JSON(200, gin.H{
			"message": "pong",
		})
	})

	server.Run(fmt.Sprintf(":%s", config.AppConfig.PORT))

}
