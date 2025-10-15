#!/bin/bash

# Setup script for BookLib Database development environment

set -e

echo "🗄️  Setting up BookLib Database development environment..."

# Check prerequisites
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is required but not installed"
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed"
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📄 Creating .env file..."
    cat > .env << EOF
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=booklib_dev
DB_USER=booklib_user
DB_PASSWORD=dev_password

# Test Database
TEST_DB_NAME=booklib_test
TEST_DB_PASSWORD=test_password

# pgAdmin
PGADMIN_DEFAULT_EMAIL=admin@booklib.com
PGADMIN_DEFAULT_PASSWORD=admin
EOF
fi

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip install -r requirements.txt

# Start database services
echo "🚀 Starting database services..."
docker-compose up -d db

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
./scripts/wait-for-db.sh

# Initialize database schema
echo "🗃️  Initializing database schema..."
if [ ! -d "migrations/versions" ] || [ -z "$(ls -A migrations/versions)" ]; then
    echo "Creating initial migration..."
    alembic revision --autogenerate -m "Initial schema"
fi

alembic upgrade head

echo "✅ Database setup complete!"
echo ""
echo "🔗 Database connection details:"
echo "   Host: localhost"
echo "   Port: 5432"
echo "   Database: booklib_dev" 
echo "   Username: booklib_user"
echo "   Password: dev_password"
echo ""
echo "🌐 Optional tools:"
echo "   Start pgAdmin: docker-compose --profile tools up -d pgadmin"
echo "   Access at: http://localhost:8080"
echo ""
echo "🧪 Testing:"
echo "   Start test database: docker-compose --profile testing up -d test_db"
echo "   Run tests: pytest tests/"