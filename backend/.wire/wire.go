package wire

import (
	authtelegram "github.com/muhriddinnorqulov/skeleton/src/auth/telegram"
	"github.com/muhriddinnorqulov/skeleton/src/entrypoint/asynctask"
	"github.com/muhriddinnorqulov/skeleton/src/entrypoint/http"

	"github.com/google/wire"
)

func InitHttpApp() *http.App {
	wire.Build(ProviderSet)
	return nil
}

func InitAsyncApp() *asynctask.App {
	wire.Build(ProviderSet)
	return nil
}

func InitTelegramBotApp() *authtelegram.BotApp {
	wire.Build(ProviderSet)
	return nil
}
