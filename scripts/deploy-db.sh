#!/bin/bash
# Deploy database migrations to test server

set -e

SERVER="192.168.1.175"
USER="deploy"
DEPLOY_PATH="/opt/booklib/db"

echo "🚀 Deploying database migrations to $SERVER..."

# Copy updated files to server
echo "📦 Copying migration files..."
scp -r migrations/* ${USER}@${SERVER}:${DEPLOY_PATH}/migrations/
scp models.py ${USER}@${SERVER}:${DEPLOY_PATH}/
scp alembic.ini ${USER}@${SERVER}:${DEPLOY_PATH}/

# Run migrations on server
echo "🔄 Running migrations on server..."
ssh ${USER}@${SERVER} << 'EOF'
    cd /opt/booklib/db
    
    # Run migrations using temporary Python container
    docker run --rm \
      --network booklib-net \
      -v $(pwd):/app \
      -w /app \
      -e DATABASE_URL="postgresql://booklib_user:test_password@booklib-db:5432/booklib_test" \
      python:3.12-slim \
      bash -c "
        apt-get update > /dev/null 2>&1 && \
        apt-get install -y gcc libpq-dev > /dev/null 2>&1 && \
        pip install -q --no-cache-dir -r requirements.txt && \
        alembic upgrade head
      "
    
    echo "✅ Migrations completed!"
EOF

echo ""
echo "✨ Database deployment complete!"
echo ""
echo "🔍 Verify with: ssh ${USER}@${SERVER} \"docker exec booklib-db psql -U booklib_user -d booklib_test -c '\dt'\""
echo ""
