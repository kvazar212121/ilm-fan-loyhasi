#!/bin/sh
set -eu

mkdir -p \
  /app/logs/http \
  /app/logs/async \
  /app/logs/ws \
  /app/logs/gateway \
  /app/storage

exec "$@"
