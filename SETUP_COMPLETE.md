# Complete Development & Deployment Setup Summary

## ✅ What's Been Set Up

### 1. **Local Development Environment**

- ✅ Local PostgreSQL database running on port 5432
- ✅ Database: `booklib_test`
- ✅ All tables created via Alembic migrations
- ✅ Python virtual environment with Alembic installed

### 2. **Test Server (192.168.1.175)**

- ✅ PostgreSQL database running in Docker
- ✅ All tables created and up-to-date
- ✅ booklib-api connected and working
- ✅ PGAdmin running on port 8080
- ✅ Jenkins pipeline for automated deployment

### 3. **Development Workflow**

- ✅ Documentation in `DEVELOPMENT_WORKFLOW.md`
- ✅ Quick reference in `QUICK_REFERENCE.md`
- ✅ Helper scripts in `scripts/`:
  - `local-setup.sh` - Set up local environment
  - `deploy-db.sh` - Deploy to test server
  - `run-migrations.sh` - Run migrations on server

---

## 🎯 Your Workflow (Step by Step)

### **Phase 1: Local Development**

1. **Start working on a feature**:

   ```bash
   cd ~/develop/projekts/booklib/booklib-db

   # Make sure database is running
   docker-compose up -d db
   ```

2. **Make database changes**:

   ```bash
   # Edit your models
   vim models.py

   # Activate virtual environment
   source venv/bin/activate

   # Generate migration
   export DATABASE_URL="postgresql://booklib_user:test_password@localhost:5432/booklib_test"
   alembic revision --autogenerate -m "Add new feature"

   # Review the generated migration
   vim migrations/versions/xxxx_add_new_feature.py

   # Apply migration locally
   alembic upgrade head
   ```

3. **Update your API** (in booklib-api directory):

   ```bash
   cd ~/develop/projekts/booklib/booklib-api

   # Update your API code to use new database schema
   vim app/models.py  # or wherever your models are
   vim app/routes.py  # add new endpoints

   # Test locally with local database
   python app/main.py
   ```

4. **Test everything locally**:
   - Your API should connect to `localhost:5432`
   - Test all your new features
   - Make sure everything works

---

### **Phase 2: Deploy to Test Server**

When you're happy with your changes:

1. **Commit database changes**:

   ```bash
   cd ~/develop/projekts/booklib/booklib-db
   git add models.py migrations/
   git commit -m "Add new feature to database"
   git push
   ```

2. **Deploy database** (Choose one):

   **Option A: Jenkins Pipeline (Recommended)**

   - Go to Jenkins: http://your-jenkins:8080
   - Run `booklib-db-pipeline`
   - Migrations run automatically

   **Option B: Manual script**

   ```bash
   ./scripts/deploy-db.sh
   ```

3. **Commit API changes**:

   ```bash
   cd ~/develop/projekts/booklib/booklib-api
   git add .
   git commit -m "Add new feature"
   git push
   ```

4. **Deploy API**:

   - Go to Jenkins
   - Run `booklib-api-pipeline`

5. **Verify deployment**:

   ```bash
   # Test the API on server
   curl http://192.168.1.175:5000/health

   # Check database on server
   ssh deploy@192.168.1.175 "docker exec booklib-db psql -U booklib_user -d booklib_test -c '\dt'"
   ```

---

## 📋 Example: Adding a New Field

Let's say you want to add a `rating_count` field to the books table:

### 1. Local Development

```bash
cd ~/develop/projekts/booklib/booklib-db

# Edit models.py
# Add: rating_count = Column(Integer, default=0)

source venv/bin/activate
export DATABASE_URL="postgresql://booklib_user:test_password@localhost:5432/booklib_test"

# Generate migration
alembic revision --autogenerate -m "Add rating_count to books"

# Apply locally
alembic upgrade head

# Verify
docker exec booklib-db psql -U booklib_user -d booklib_test -c '\d books'
```

### 2. Update API

```bash
cd ~/develop/projekts/booklib/booklib-api

# Update your Book model/schema
# Add logic to use rating_count
# Test locally
```

### 3. Deploy

```bash
# Push DB changes
cd ~/develop/projekts/booklib/booklib-db
git add models.py migrations/
git commit -m "Add rating_count to books table"
git push

# Run Jenkins: booklib-db-pipeline

# Push API changes
cd ~/develop/projekts/booklib/booklib-api
git add .
git commit -m "Use rating_count field"
git push

# Run Jenkins: booklib-api-pipeline
```

---

## 🔧 Useful Commands

### Local Database

```bash
# Start
docker-compose up -d db

# Stop
docker-compose down

# View logs
docker logs booklib-db -f

# Access database CLI
docker exec -it booklib-db psql -U booklib_user -d booklib_test

# Reset database (⚠️ DELETES ALL DATA)
docker-compose down -v
docker-compose up -d db
source venv/bin/activate
export DATABASE_URL="postgresql://booklib_user:test_password@localhost:5432/booklib_test"
alembic upgrade head
```

### Alembic

```bash
# Check current version
alembic current

# View history
alembic history

# Upgrade to specific version
alembic upgrade <revision>

# Downgrade one step
alembic downgrade -1

# Downgrade to specific version
alembic downgrade <revision>

# Generate empty migration
alembic revision -m "description"
```

### Remote Server

```bash
# Check tables
ssh deploy@192.168.1.175 "docker exec booklib-db psql -U booklib_user -d booklib_test -c '\dt'"

# View logs
ssh deploy@192.168.1.175 "docker logs booklib-db --tail=50"

# Run migrations manually
ssh deploy@192.168.1.175 "cd /opt/booklib/db && bash scripts/run-migrations.sh"
```

---

## 🌐 Access Points

### Local

- **Database**: `localhost:5432`
- **API**: `localhost:5000` (when running)
- **Connection**: `postgresql://booklib_user:test_password@localhost:5432/booklib_test`

### Test Server (192.168.1.175)

- **Database**: `192.168.1.175:5432`
- **API**: `http://192.168.1.175:5000`
- **PGAdmin**: `http://192.168.1.175:8080`
  - Email: `admin@booklib.com`
  - Password: `admin`
- **Jenkins**: Your Jenkins URL

---

## 🎉 You're All Set!

Your complete development workflow is now in place:

1. ✅ Develop locally with full database
2. ✅ Generate and test migrations locally
3. ✅ Deploy to test server via Jenkins (or scripts)
4. ✅ Automatic migration execution on deployment
5. ✅ Separate repositories working together seamlessly

**Next Steps:**

- Start developing your API features
- Make database changes as needed
- Follow the workflow above for each feature

**Need Help?**

- Check `DEVELOPMENT_WORKFLOW.md` for detailed info
- Check `QUICK_REFERENCE.md` for quick commands
- Use the helper scripts in `scripts/`
