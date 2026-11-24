package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	wire "github.com/muhriddinnorqulov/skeleton/cmd/container"
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	app := wire.InitTelegramBotApp()
	if err := app.Run(ctx); err != nil {
		fmt.Fprintf(os.Stderr, "telegram-bot fatal: %v\n", err)
		os.Exit(1)
	}
}
