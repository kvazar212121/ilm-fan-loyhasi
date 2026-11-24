# #0001 skeleton-redis fails with FATAL CONFIG FILE ERROR requirepass wrong number of arguments when docker compose runs without --env-file ../.env

- 2026-11-23T07:19:04Z `issue`: skeleton-redis fails with FATAL CONFIG FILE ERROR requirepass wrong number of arguments when docker compose runs without --env-file ../.env [backend/docker/docker-compose.yml]
- 2026-11-23T07:20:13Z `fix`: Added env_file: [./../.env] and container-side $$REDIS_PASSWORD shell expansion to skeleton-redis in docker-compose.yml plus docker-up-telegram Makefile target; all 5 containers healthy and live /health, /auth/telegram/start, /auth/otp/sms verified. [backend/docker/docker-compose.yml]
