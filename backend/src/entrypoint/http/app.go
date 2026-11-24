package http

import (
	"fmt"

	authhttp "github.com/muhriddinnorqulov/skeleton/src/auth/http"
	authpersistence "github.com/muhriddinnorqulov/skeleton/src/auth/persistence"
	"github.com/muhriddinnorqulov/skeleton/src/core/domain/ports/httpport"
	"github.com/muhriddinnorqulov/skeleton/src/core/domain/ports/wsport"
	"github.com/muhriddinnorqulov/skeleton/src/entrypoint/http/groups"
	"github.com/muhriddinnorqulov/skeleton/src/entrypoint/http/interceptor/middlewares"
	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/db"
	"github.com/muhriddinnorqulov/skeleton/src/infrastructure/env"
)

type App struct {
	server   httpport.HTTPServer
	env      *env.Env
	database *db.Database

	jwtAuthMiddleware  *middlewares.JwtAuthMiddleware
	responseMiddleware *middlewares.ResponseMiddleware

	authGroup   *authhttp.AuthGroup
	entityGroup *groups.EntityGroup
	wsGroup     *groups.WsGroup
	healthGroup *groups.HealthGroup

	ws wsport.Ws
}

// @inject
func NewApp(
	server httpport.HTTPServer,
	env *env.Env,
	database *db.Database,
	jwtAuthMiddleware *middlewares.JwtAuthMiddleware,
	responseMiddleware *middlewares.ResponseMiddleware,
	authGroup *authhttp.AuthGroup,
	entityGroup *groups.EntityGroup,
	wsGroup *groups.WsGroup,
	healthGroup *groups.HealthGroup,
	ws wsport.Ws,
) *App {
	return &App{
		server:             server,
		env:                env,
		database:           database,
		jwtAuthMiddleware:  jwtAuthMiddleware,
		responseMiddleware: responseMiddleware,
		authGroup:          authGroup,
		entityGroup:        entityGroup,
		wsGroup:            wsGroup,
		healthGroup:        healthGroup,
		ws:                 ws,
	}
}

func (this *App) Init() {
	if err := authpersistence.AutoMigrate(this.database.DB); err != nil {
		panic(fmt.Errorf("[http.App.Init] auto-migrate auth tables: %w", err))
	}
	this.server.Init()
	this.initMiddlewares()
	this.initGroups()
}

func (this *App) initMiddlewares() {
	this.server.Use(this.jwtAuthMiddleware.Wrap)
	this.server.Use(this.responseMiddleware.Wrap)
}

func (this *App) initGroups() {
	v1 := this.group("/v1")

	this.authGroup.RegisterRoutes(v1.Group("/auth"))
	this.entityGroup.RegisterRoutes(v1.Group("/entity"))
	this.wsGroup.RegisterRoutes(v1.Group("/ws"))
	this.healthGroup.RegisterRoutes(v1.Group("/health"))
}

func (this *App) Start() {
	this.server.Run()
}

func (this *App) group(prefix string, mws ...httpport.Middleware) httpport.Group {
	basePath := "/api" + prefix
	return this.server.Group(basePath, mws...)
}
