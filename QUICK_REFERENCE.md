# Quick Reference - Database Development

## 🚀 Quick Start

```bash
# Initial setup (run once)
cd ~/develop/projekts/booklib/booklib-db
./scripts/local-setup.sh
```

## 📝 Daily Development Workflow

### 1. Make Database Changes

```bash
# Edit models
vim models.py

# Generate migration
export DATABASE_URL="postgresql://booklib_user:test_password@localhost:5432/booklib_test"
alembic revision --autogenerate -m "Your change description"

# Apply migration locally
alembic upgrade head
```

### 2. Deploy to Test Server

```bash
# Push changes
git add models.py migrations/
git commit -m "Database changes"
git push

# Option A: Use Jenkins (Recommended)
# → Go to Jenkins and run booklib-db-pipeline

# Option B: Use script
./scripts/deploy-db.sh
```

## 🔧 Common Commands

```bash
# Start local database
docker-compose up -d db

# Stop local database
docker-compose down

# View logs
docker logs booklib-db

# Access database
docker exec -it booklib-db psql -U booklib_user -d booklib_test

# Check migration status
alembic current

# Rollback one migration
alembic downgrade -1
```

## 🔗 Connection Strings

**Local:**

```
postgresql://booklib_user:test_password@localhost:5432/booklib_test
```

**Test Server:**

```
postgresql://booklib_user:test_password@booklib-db:5432/booklib_test
```

## 📚 Full Documentation

See [DEVELOPMENT_WORKFLOW.md](./DEVELOPMENT_WORKFLOW.md) for complete details.
