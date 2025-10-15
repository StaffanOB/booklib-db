# Development & Deployment Workflow

## Local Development Setup

### 1. Start Local Database

```bash
cd ~/develop/projekts/booklib/booklib-db
docker-compose up -d db
```

This starts PostgreSQL locally on port 5432 with:

- Database: `booklib_test`
- User: `booklib_user`
- Password: `test_password`

### 2. Run Initial Migrations Locally

```bash
# Set environment variable
export DATABASE_URL="postgresql://booklib_user:test_password@localhost:5432/booklib_test"

# Run migrations
alembic upgrade head
```

### 3. Develop Your API

In the `booklib-api` directory:

```bash
cd ~/develop/projekts/booklib/booklib-api

# Update .env to point to local database
# DATABASE_URL=postgresql://booklib_user:test_password@localhost:5432/booklib_test

# Run your API
python app/main.py
```

## Making Database Changes

### 1. Update Models

Edit `models.py` in booklib-db:

```bash
cd ~/develop/projekts/booklib/booklib-db
vim models.py
```

### 2. Generate Migration

```bash
export DATABASE_URL="postgresql://booklib_user:test_password@localhost:5432/booklib_test"
alembic revision --autogenerate -m "Description of changes"
```

### 3. Review Generated Migration

Check the file in `migrations/versions/` and edit if needed.

### 4. Apply Migration Locally

```bash
alembic upgrade head
```

### 5. Test in API

Make corresponding changes in your API code and test locally.

## Deploying to Test Server

### Option A: Deploy Both API and DB (Recommended)

1. **Commit DB changes**:

```bash
cd ~/develop/projekts/booklib/booklib-db
git add models.py migrations/
git commit -m "Add new feature to database"
git push
```

2. **Run booklib-db Jenkins pipeline** - this will:

   - Deploy database service
   - Run migrations automatically

3. **Commit API changes**:

```bash
cd ~/develop/projekts/booklib/booklib-api
git add .
git commit -m "Add new feature"
git push
```

4. **Run booklib-api Jenkins pipeline** - this will:
   - Deploy updated API

### Option B: Quick Scripts

Use the helper scripts in `scripts/`:

```bash
# Deploy just database migrations
./scripts/deploy-db.sh

# Full local setup
./scripts/local-setup.sh
```

## Common Commands

### Local Development

```bash
# Start local database
docker-compose up -d db

# Stop local database
docker-compose down

# View database logs
docker logs booklib-db

# Access database CLI
docker exec -it booklib-db psql -U booklib_user -d booklib_test

# Run migrations
export DATABASE_URL="postgresql://booklib_user:test_password@localhost:5432/booklib_test"
alembic upgrade head

# Rollback one migration
alembic downgrade -1

# Check current migration version
alembic current

# View migration history
alembic history
```

### Remote Server

```bash
# Check tables on server
ssh deploy@192.168.1.175 "docker exec booklib-db psql -U booklib_user -d booklib_test -c '\dt'"

# Run migrations manually on server
ssh deploy@192.168.1.175 "cd /opt/booklib/db && bash scripts/run-migrations.sh"

# View server database logs
ssh deploy@192.168.1.175 "docker logs booklib-db --tail=50"
```

## Workflow Summary

```
┌─────────────────────────────────────────────────────────────┐
│                    LOCAL DEVELOPMENT                        │
├─────────────────────────────────────────────────────────────┤
│ 1. Start local DB: docker-compose up -d db                 │
│ 2. Edit models.py                                           │
│ 3. Generate migration: alembic revision --autogenerate     │
│ 4. Apply locally: alembic upgrade head                      │
│ 5. Update API code                                          │
│ 6. Test locally                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                 COMMIT & PUSH CHANGES                       │
├─────────────────────────────────────────────────────────────┤
│ 1. Commit booklib-db changes: git push                     │
│ 2. Commit booklib-api changes: git push                    │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   JENKINS DEPLOYMENT                        │
├─────────────────────────────────────────────────────────────┤
│ 1. Run booklib-db pipeline → Migrations run automatically  │
│ 2. Run booklib-api pipeline → API deployed with new schema │
└─────────────────────────────────────────────────────────────┘
```

## Troubleshooting

### Migration conflicts

If you get conflicts, you may need to resolve them manually or create a new migration head.

### Database out of sync

```bash
# Check current version
alembic current

# Force to specific version (use carefully!)
alembic stamp head
```

### Local database reset

```bash
docker-compose down -v  # WARNING: Deletes all data!
docker-compose up -d db
alembic upgrade head
```
