
generate-docs:
	@echo "Generating documentation..."
	@swag init -g ./cmd/http/main.go -o ./src/infrastructure/docs
	@echo "Documentation generated successfully."

wire-build:
	@echo "Running wire in the di folder..."
	@wiregenx --root ./src --out ../.wire/provider.go
	@cd .wire/ && wire && mv wire_gen.go ../cmd/container/container.go

docker-run.local:
	@echo "Running Docker container..."
	@cd docker && docker compose -f docker-compose.local.yml --env-file ./../.env up --build -d

docker-up:
	@echo "Starting backend stack (http, async, postgres, redis)..."
	@cd docker && docker compose -f docker-compose.yml --env-file ./../.env up --build -d

docker-up-telegram:
	@echo "Starting backend stack with telegram-bot..."
	@cd docker && docker compose -f docker-compose.yml --env-file ./../.env --profile telegram up --build -d
