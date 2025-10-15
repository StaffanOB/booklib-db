#!/bin/bash
# Run Alembic migrations in a temporary container

set -e

echo "Running database migrations..."

# Run migrations using a Python container connected to the database
docker run --rm \
  --network booklib-net \
  -v $(pwd):/app \
  -w /app \
  -e DATABASE_URL="postgresql://booklib_user:test_password@booklib-db:5432/booklib_test" \
  python:3.12-slim \
  bash -c "
    pip install -q -r requirements.txt && \
    alembic upgrade head
  "

echo "Migrations completed successfully!"
