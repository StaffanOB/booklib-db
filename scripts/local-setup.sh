#!/bin/bash
# Local setup script for booklib-db development

set -e

echo "🚀 Setting up local booklib-db development environment..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Create network if it doesn't exist
echo "📡 Creating Docker network..."
docker network create booklib-net 2>/dev/null || echo "Network already exists"

# Start database
echo "🐘 Starting PostgreSQL database..."
docker-compose up -d db

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 5

# Check if database is ready
until docker exec booklib-db pg_isready -U booklib_user -d booklib_test > /dev/null 2>&1; do
    echo "   Still waiting..."
    sleep 2
done

echo "✅ Database is ready!"

# Run migrations
echo "🔄 Running database migrations..."
export DATABASE_URL="postgresql://booklib_user:test_password@localhost:5432/booklib_test"
alembic upgrade head

echo ""
echo "✨ Setup complete! Your local database is running."
echo ""
echo "📊 Database connection details:"
echo "   Host: localhost"
echo "   Port: 5432"
echo "   Database: booklib_test"
echo "   User: booklib_user"
echo "   Password: test_password"
echo ""
echo "📝 DATABASE_URL: postgresql://booklib_user:test_password@localhost:5432/booklib_test"
echo ""
echo "🔧 Useful commands:"
echo "   View logs: docker logs booklib-db"
echo "   Access DB: docker exec -it booklib-db psql -U booklib_user -d booklib_test"
echo "   Stop DB: docker-compose down"
echo ""
