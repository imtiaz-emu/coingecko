#!/usr/bin/env bash
# bin/local_db.sh — starts PostgreSQL 16.4 and pgAdmin4 via Docker

set -e

CONTAINER_NAME="shrtn_postgres"
POSTGRES_PASSWORD="password"
POSTGRES_USER="postgres"
HOST_PORT="5433"           # 5433 avoids conflicts with any local postgres
VOLUME_PATH="$HOME/shrtn_local_data"
DB_NAMES=("shrtn_development" "shrtn_test")

# Pull postgres image if not present
if ! docker image inspect postgres:16.4 &>/dev/null; then
  echo "Pulling postgres:16.4..."
  docker pull postgres:16.4
fi

# Start container if not already running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Starting PostgreSQL container..."
  docker run --rm --name "$CONTAINER_NAME" \
    -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
    -e POSTGRES_USER="$POSTGRES_USER" \
    -d -p "$HOST_PORT:5432" \
    -v "$VOLUME_PATH:/var/lib/postgresql/data" \
    postgres:16.4
  echo "Waiting for PostgreSQL to be ready..."
  sleep 5
else
  echo "PostgreSQL container already running."
fi

# Create databases if they don't exist
for DB_NAME in "${DB_NAMES[@]}"; do
  DB_EXISTS=$(docker exec "$CONTAINER_NAME" psql -U postgres -tc \
    "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME';" | xargs)
  if [ "$DB_EXISTS" != "1" ]; then
    echo "Creating database '$DB_NAME'..."
    docker exec "$CONTAINER_NAME" psql -U postgres -c "CREATE DATABASE $DB_NAME;"
  else
    echo "Database '$DB_NAME' already exists."
  fi
done

echo "PostgreSQL running on localhost:$HOST_PORT"
echo "Connect: psql -h localhost -p $HOST_PORT -U postgres"

# Start Redis if not running
if ! docker ps --format '{{.Names}}' | grep -q "^shrtn_redis$"; then
  if ! docker image inspect redis:7-alpine &>/dev/null; then
    echo "Pulling redis:7-alpine..."
    docker pull redis:7-alpine
  fi
  docker run --rm --name shrtn_redis -d -p 6379:6379 redis:7-alpine
  echo "Redis running on localhost:6379"
else
  echo "Redis already running on localhost:6379"
fi

# Start pgAdmin4 if not running
if ! docker ps --format '{{.Names}}' | grep -q "^shrtn_pgadmin$"; then
  if ! docker image inspect dpage/pgadmin4:latest &>/dev/null; then
    echo "Pulling pgAdmin4..."
    docker pull dpage/pgadmin4:latest
  fi
  docker run --rm --name shrtn_pgadmin \
    -p 82:80 \
    -e PGADMIN_DEFAULT_EMAIL=dev@shrtn.io \
    -e PGADMIN_DEFAULT_PASSWORD=password \
    -d dpage/pgadmin4
  echo "pgAdmin4 running at http://localhost:82"
else
  echo "pgAdmin4 already running at http://localhost:82"
fi
