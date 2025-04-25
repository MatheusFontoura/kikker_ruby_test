#!/bin/bash
set -e

# Remove a pid antiga, se existir
rm -f tmp/pids/server.pid

# Espera o banco de dados estar pronto
if [ -n "$DATABASE_HOST" ]; then
  echo "Aguardando o banco de dados ($DATABASE_HOST)..."
  until nc -z "$DATABASE_HOST" 5432; do
    sleep 0.5
  done
  echo "Banco de dados está pronto!"
fi

exec "$@"
