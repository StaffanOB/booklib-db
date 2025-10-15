#!/bin/bash

# Wait for database to be ready

set -e

DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USER:-booklib_user}
DB_NAME=${DB_NAME:-booklib_dev}
DB_PASSWORD=${DB_PASSWORD:-dev_password}

echo "Waiting for database to be ready at $DB_HOST:$DB_PORT..."

max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
    # Try using docker-compose exec if we're in the docker context
    if command -v docker-compose >/dev/null 2>&1 && [ -f docker-compose.yml ]; then
        if docker-compose exec -T -e PGPASSWORD="$DB_PASSWORD" db psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
            echo "✅ Database is ready!"
            exit 0
        fi
    # Try using pg_isready if available
    elif command -v pg_isready >/dev/null 2>&1; then
        if pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; then
            echo "✅ Database is ready!"
            exit 0
        fi
    # Try using psql directly if available
    elif command -v psql >/dev/null 2>&1; then
        if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
            echo "✅ Database is ready!"
            exit 0
        fi
    # Try using nc (netcat) as a fallback
    elif command -v nc >/dev/null 2>&1; then
        if nc -z "$DB_HOST" "$DB_PORT" >/dev/null 2>&1; then
            echo "✅ Database port is open (assuming ready)!"
            exit 0
        fi
    else
        echo "❌ No suitable tools found to check database connectivity (pg_isready, psql, or nc)"
        exit 1
    fi
    
    echo "⏳ Attempt $attempt/$max_attempts - Database not ready yet..."
    sleep 2
    attempt=$((attempt + 1))
done

echo "❌ Database failed to become ready after $max_attempts attempts"
exit 1