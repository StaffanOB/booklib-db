# BookLib Database

Database management, migrations, and utilities for the BookLib project ecosystem.

## 🚀 Local Development Guide

**For detailed local development setup instructions, see [README_DEV.md](README_DEV.md)**

## Repository Structure

```
booklib-db/
├── docker-compose.yml          # Database services (dev, test, pgadmin)
├── migrations/                 # Alembic migration files
│   ├── alembic.ini
│   ├── env.py
│   └── versions/
├── scripts/                    # Database utilities
│   ├── setup.sh               # Database initialization
│   ├── backup.sh              # Backup utilities
│   ├── restore.sh             # Restore utilities
│   └── wait-for-db.sh         # Health check script
├── sql/                        # SQL scripts
│   ├── init.sql               # Initial schema
│   └── seed.sql               # Sample data
└── docs/                       # Database documentation
    └── schema.md
```

## Quick Start for Local Development

### Prerequisites
- Docker Engine 20.10+
- Docker Compose 2.0+
- Python 3.11+ (for migration management)
- PostgreSQL client tools (optional, for direct access)

### 1. Setup Database Environment
```bash
# Clone the repository
git clone https://github.com/StaffanOB/booklib-db.git
cd booklib-db

# Create Python virtual environment for migrations
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install migration dependencies
pip install -r requirements.txt
```

### 2. Start Development Database
```bash
# Start PostgreSQL database
docker-compose up -d db

# Wait for database to be ready
./scripts/wait-for-db.sh

# Check database status
docker-compose ps
```

### 3. Initialize Database Schema
```bash
# Run initial setup (creates tables, indexes, etc.)
./scripts/setup.sh

# Apply all migrations
source .venv/bin/activate
alembic upgrade head

# Verify tables were created
docker-compose exec db psql -U booklib_user -d booklib_dev -c "\dt"
```

### 4. Load Sample Data (Optional)
```bash
# Load development seed data
docker-compose exec db psql -U booklib_user -d booklib_dev -f /docker-entrypoint-initdb.d/seed.sql

# Or create your own test data
docker-compose exec db psql -U booklib_user -d booklib_dev
# SQL> INSERT INTO books (title, author, isbn) VALUES ('Test Book', 'Test Author', '123456789');
```

### 5. Development Workflow
```bash
# Make database schema changes by creating migrations
source .venv/bin/activate
alembic revision --autogenerate -m "Add new table or column"

# Review generated migration in migrations/versions/
# Edit if needed, then apply
alembic upgrade head

# Test migration rollback
alembic downgrade -1
alembic upgrade head

# Check current migration status
alembic current
alembic history --verbose
```

## Integration with BookLib Services

### API Integration (booklib-api)
```bash
# Start database for API development
docker-compose up -d db

# API connects using these credentials:
# DATABASE_URL=postgresql://booklib_user:dev_password@localhost:5432/booklib_dev

# Verify API can connect
cd ../booklib-api
source .venv/bin/activate
export DATABASE_URL=postgresql://booklib_user:dev_password@localhost:5432/booklib_dev
python -c "from app.models import db; print('Database connection successful')"
```

### Testing Integration (booklib-tests)
```bash
# Start test database
docker-compose --profile testing up -d test_db

# Reset test database before each test run
docker-compose exec test_db psql -U booklib_user -d booklib_test -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
./scripts/setup.sh test
alembic upgrade head

# Run tests
cd ../booklib-tests  
robot --variable DB_URL:postgresql://booklib_user:test_password@localhost:5433/booklib_test robot/api/
```

### Full Stack Development
```bash
# Start complete development environment
docker-compose up -d db pgadmin

# Connect to PgAdmin (optional GUI)
# Browser: http://localhost:5050
# Email: admin@booklib.com
# Password: admin

# Or use psql directly
docker-compose exec db psql -U booklib_user -d booklib_dev
```

## Database Management

### Environment-Specific Databases
```bash
# Development (default)
docker-compose up -d db
# Accessible at localhost:5432

# Test database (for automated testing)
docker-compose --profile testing up -d test_db  
# Accessible at localhost:5433

# Both databases simultaneously
docker-compose --profile testing up -d db test_db pgadmin
```

### Database Operations
```bash
# Create backup
./scripts/backup.sh booklib_dev

# Restore from backup
./scripts/restore.sh booklib_dev backup_file.sql

# Reset database to clean state
docker-compose exec db psql -U booklib_user -d booklib_dev -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
./scripts/setup.sh
alembic upgrade head
```

### Migration Management
```bash
# Create new migration after model changes
alembic revision --autogenerate -m "Description of changes"

# Apply migrations
alembic upgrade head

# Rollback migrations
alembic downgrade -1      # Go back one version
alembic downgrade base    # Go back to beginning

# Check migration status
alembic current           # Current version
alembic history          # Migration history
alembic show <revision>  # Show specific migration
```

## Environment Variables

### Development
```bash
POSTGRES_DB=booklib_dev
POSTGRES_USER=booklib_user  
POSTGRES_PASSWORD=dev_password
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
```

### Testing
```bash
POSTGRES_DB=booklib_test
POSTGRES_USER=booklib_user
POSTGRES_PASSWORD=test_password  
POSTGRES_HOST=localhost
POSTGRES_PORT=5433
```

### Production
```bash
POSTGRES_DB=booklib_prod
POSTGRES_USER=booklib_user
POSTGRES_PASSWORD=secure_prod_password
POSTGRES_HOST=prod_db_host
POSTGRES_PORT=5432
```

## Troubleshooting

### Common Issues
```bash
# Database connection refused
docker-compose ps                           # Check if db is running
docker-compose logs db                      # Check database logs
./scripts/wait-for-db.sh                   # Wait for database to be ready

# Migration errors
alembic current                            # Check current migration state
alembic history                            # Check migration history
alembic stamp head                         # Force migration state (careful!)

# Permission errors
docker-compose exec db psql -U postgres   # Connect as superuser
# GRANT ALL PRIVILEGES ON DATABASE booklib_dev TO booklib_user;

# Port conflicts
sudo netstat -tulpn | grep 5432           # Check what's using port 5432
docker-compose down                        # Stop services
```

### Database URLs for Each Environment
- **Development**: `postgresql://booklib_user:dev_password@localhost:5432/booklib_dev`
- **Test**: `postgresql://booklib_user:test_password@localhost:5433/booklib_test`
- **PgAdmin**: http://localhost:5050 (admin@booklib.com / admin)

## Quick Start for Local Development

### Prerequisites
- Docker and Docker Compose
- Python 3.11+
- PostgreSQL client tools (optional)

### 1. Clone the Repository
```bash
git clone https://github.com/StaffanOB/booklib-db.git
cd booklib-db
```

### 2. Start Local Database
```bash
# Start PostgreSQL with Docker
docker-compose up -d

# Wait for database to be ready
./scripts/wait-for-db.sh
```

### 3. Run Migrations
```bash
# Install dependencies
pip install -r requirements.txt

# Run database migrations
alembic upgrade head

# Load sample data (optional)
python scripts/seed_data.py
```

### 4. Verify Setup
```bash
# Test database connection
python scripts/test_connection.py

# Run database tests
pytest tests/
```

### 5. Access Database
```bash
# Connect via psql
psql -h localhost -p 5432 -U booklib_user -d booklib_dev

# Or use pgAdmin at http://localhost:8080
# Email: admin@booklib.com
# Password: admin
```

## Development Workflow

### Creating New Migrations
```bash
# Generate migration for model changes
alembic revision --autogenerate -m "Add new table"

# Review generated migration file
vim migrations/versions/xxx_add_new_table.py

# Apply migration
alembic upgrade head
```

### Testing Changes
```bash
# Run all database tests
pytest tests/

# Test specific migration
pytest tests/test_migrations.py::test_migration_xxx

# Performance tests
pytest tests/test_performance.py
```

### Data Management
```bash
# Create database backup
./scripts/backup.sh local

# Restore from backup
./scripts/restore.sh backup_file.sql

# Reset database with fresh data
./scripts/reset_dev_db.sh
```

## Environment Variables

Create `.env` file:
```bash
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=booklib_dev
DB_USER=booklib_user
DB_PASSWORD=dev_password

# Test Database
TEST_DB_NAME=booklib_test

# pgAdmin Configuration
PGADMIN_DEFAULT_EMAIL=admin@booklib.com
PGADMIN_DEFAULT_PASSWORD=admin
```

## Available Scripts

- `scripts/setup.sh` - Initial database setup
- `scripts/reset_dev_db.sh` - Reset development database
- `scripts/seed_data.py` - Load sample data
- `scripts/backup.sh` - Create database backup
- `scripts/restore.sh` - Restore database backup
- `scripts/performance_check.py` - Database performance analysis
- `scripts/wait-for-db.sh` - Wait for database to be ready

## Integration with Other Services

### API Integration
The API repository (`booklib-api`) uses this database:
```bash
# In booklib-api directory
# Make sure database is running first
cd ../booklib-db && docker-compose up -d
cd ../booklib-api && python app/main.py
```

### Testing Integration
The test repository (`booklib-tests`) can use this database:
```bash
# In booklib-tests directory  
# Run tests against local database
robot --variable DATABASE_URL:postgresql://booklib_user:dev_password@localhost:5432/booklib_test robot/api/
```

## Troubleshooting

### Database Connection Issues
```bash
# Check if database is running
docker ps | grep postgres

# Check logs
docker-compose logs db

# Reset database container
docker-compose down -v && docker-compose up -d
```

### Migration Issues
```bash
# Check current migration status
alembic current

# Show migration history
alembic history

# Rollback to previous migration
alembic downgrade -1
```

### Performance Issues
```bash
# Run performance analysis
python scripts/performance_check.py

# Check slow queries
python scripts/analyze_queries.py

# Rebuild indexes
python scripts/rebuild_indexes.py
```

## Contributing

1. Create feature branch: `git checkout -b feature/new-schema`
2. Make database changes and create migrations
3. Test migrations: `pytest tests/`
4. Update documentation if needed
5. Submit pull request

## Database Schema

See [Database Schema Documentation](docs/schema.md) for detailed information about:
- Table relationships
- Indexes and constraints  
- Data types and validation
- Performance considerations