FROM golang:1.26.1 AS builder

WORKDIR /src

COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

COPY ./src ./src
COPY ./cmd ./cmd

RUN --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux \
    go build -trimpath -ldflags="-s -w" -o /out/http ./cmd/http/main.go \
 && CGO_ENABLED=0 GOOS=linux \
    go build -trimpath -ldflags="-s -w" -o /out/async ./cmd/async/main.go \
 && CGO_ENABLED=0 GOOS=linux \
    go build -trimpath -ldflags="-s -w" -o /out/telegram-bot ./cmd/telegram-bot/main.go


FROM alpine:3.23

ENV CONTAINER_MODE=1

RUN apk add --no-cache ca-certificates wget

WORKDIR /app

COPY docker/entrypoint.sh /entrypoint.sh
COPY --from=builder /out/http /out/async /out/telegram-bot ./

RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./http"]
