# BookLib Database# BookLib Database

PostgreSQL database container for the BookLib project ecosystem.Database management, migrations, and utilities for the BookLib project ecosystem.

## Purpose## 🚀 Local Development Guide

This repository provides a **PostgreSQL database container** that creates an empty database and user. **For detailed local development setup instructions, see [README_DEV.md](README_DEV.md)**

**Database migrations are handled by the [booklib-api](https://github.com/StaffanOB/booklib-api) repository.**## Repository Structure

## What This Repository Does```

booklib-db/

- ✅ Provides PostgreSQL 15 in a Docker container├── docker-compose.yml # Database services (dev, test, pgadmin)

- ✅ Creates database `booklib_test` and user `booklib_user`├── migrations/ # Alembic migration files

- ✅ Exposes database on port 5432│ ├── alembic.ini

- ✅ Includes PGAdmin for database management (optional)│ ├── env.py

- ✅ Automated deployment via Jenkins pipeline│ └── versions/

├── scripts/ # Database utilities

## Quick Start│ ├── setup.sh # Database initialization

│ ├── backup.sh # Backup utilities

### Local Development│ ├── restore.sh # Restore utilities

│ └── wait-for-db.sh # Health check script

1. **Start the database**:├── sql/ # SQL scripts

   ````bash│ ├── init.sql               # Initial schema

   docker-compose up -d db│   └── seed.sql               # Sample data

   ```└── docs/                       # Database documentation

    └── schema.md

   ````

2. **Verify it's running**:```

   ```bash

   docker exec booklib-db pg_isready -U booklib_user -d booklib_test## Quick Start for Local Development

   ```

### Prerequisites

3. **Access the database** (if needed):- Docker Engine 20.10+

   ````bash- Docker Compose 2.0+

   docker exec -it booklib-db psql -U booklib_user -d booklib_test- Python 3.11+ (for migration management)

   ```- PostgreSQL client tools (optional, for direct access)
   ````

### Start PGAdmin (Optional)### 1. Setup Database Environment

`````bash

```bash# Clone the repository

docker-compose --profile tools up -d pgadmingit clone https://github.com/StaffanOB/booklib-db.git

```cd booklib-db



Access at: `http://localhost:8080`# Create Python virtual environment for migrations

- Email: `admin@booklib.com`python3 -m venv .venv

- Password: `admin`source .venv/bin/activate  # On Windows: .venv\Scripts\activate



### Server Information# Install migration dependencies

pip install -r requirements.txt

Add server in PGAdmin:```

- **Host**: `booklib-db` (container name)

- **Port**: `5432`### 2. Start Development Database

- **Database**: `booklib_test````bash

- **Username**: `booklib_user`# Start PostgreSQL database

- **Password**: `test_password`docker-compose up -d db



## Configuration# Wait for database to be ready

./scripts/wait-for-db.sh

### Environment Variables

# Check database status

The database is configured in `docker-compose.yml`:docker-compose ps

`````

````yaml

environment:### 3. Initialize Database Schema

  POSTGRES_DB: booklib_test```bash

  POSTGRES_USER: booklib_user# Run initial setup (creates tables, indexes, etc.)

  POSTGRES_PASSWORD: test_password./scripts/setup.sh

````

# Apply all migrations

### Networksource .venv/bin/activate

alembic upgrade head

The database container connects to the `booklib-net` Docker network, allowing other BookLib services to access it by container name (`booklib-db`).

# Verify tables were created

## Deploymentdocker-compose exec db psql -U booklib_user -d booklib_dev -c "\dt"

````

### Jenkins Pipeline

### 4. Load Sample Data (Optional)

The repository includes a Jenkins pipeline (`Jenkinsfile`) that:```bash

# Load development seed data

1. Deploys docker-compose.yml to the test serverdocker-compose exec db psql -U booklib_user -d booklib_dev -f /docker-entrypoint-initdb.d/seed.sql

2. Creates the Docker network if needed

3. Starts the database container# Or create your own test data

4. Runs a health checkdocker-compose exec db psql -U booklib_user -d booklib_dev

# SQL> INSERT INTO books (title, author, isbn) VALUES ('Test Book', 'Test Author', '123456789');

**To deploy**: Run the `booklib-db-pipeline` job in Jenkins.```



### Manual Deployment### 5. Development Workflow

```bash

```bash# Make database schema changes by creating migrations

# Copy docker-compose.yml to serversource .venv/bin/activate

scp docker-compose.yml deploy@192.168.1.175:/opt/booklib/db/alembic revision --autogenerate -m "Add new table or column"



# SSH to server and deploy# Review generated migration in migrations/versions/

ssh deploy@192.168.1.175# Edit if needed, then apply

cd /opt/booklib/dbalembic upgrade head

docker network create booklib-net  # if not exists

docker-compose up -d db# Test migration rollback

```alembic downgrade -1

alembic upgrade head

## Database Schema

# Check current migration status

**Schema and migrations are managed by the booklib-api repository.**alembic current

alembic history --verbose

This repository only provides the empty database. The API handles:```

- Creating tables

- Running migrations## Integration with BookLib Services

- Managing schema changes

### API Integration (booklib-api)

See [booklib-api](https://github.com/StaffanOB/booklib-api) for database schema details.```bash

# Start database for API development

## Useful Commandsdocker-compose up -d db



### Check Database Status# API connects using these credentials:

# DATABASE_URL=postgresql://booklib_user:dev_password@localhost:5432/booklib_dev

```bash

# Check if container is running# Verify API can connect

docker ps | grep booklib-dbcd ../booklib-api

source .venv/bin/activate

# Check if database is readyexport DATABASE_URL=postgresql://booklib_user:dev_password@localhost:5432/booklib_dev

docker exec booklib-db pg_isready -U booklib_user -d booklib_testpython -c "from app.models import db; print('Database connection successful')"

````

# View logs

docker logs booklib-db### Testing Integration (booklib-tests)

````bash

# Start test database

### Access Databasedocker-compose --profile testing up -d test_db



```bash# Reset test database before each test run

# psql CLIdocker-compose exec test_db psql -U booklib_user -d booklib_test -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

docker exec -it booklib-db psql -U booklib_user -d booklib_test./scripts/setup.sh test

alembic upgrade head

# List tables (once API has created them)

docker exec booklib-db psql -U booklib_user -d booklib_test -c '\dt'# Run tests

cd ../booklib-tests

# Check database sizerobot --variable DB_URL:postgresql://booklib_user:test_password@localhost:5433/booklib_test robot/api/

docker exec booklib-db psql -U booklib_user -d booklib_test -c "SELECT pg_size_pretty(pg_database_size('booklib_test'));"```

```

### Full Stack Development

### Stop/Start Database```bash

# Start complete development environment

```bashdocker-compose up -d db pgadmin

# Stop

docker-compose down# Connect to PgAdmin (optional GUI)

# Browser: http://localhost:5050

# Start# Email: admin@booklib.com

docker-compose up -d db# Password: admin



# Restart# Or use psql directly

docker-compose restart dbdocker-compose exec db psql -U booklib_user -d booklib_dev

````

### Backup & Restore## Database Management

```````bash### Environment-Specific Databases

# Backup```bash

docker exec booklib-db pg_dump -U booklib_user booklib_test > backup.sql# Development (default)

docker-compose up -d db

# Restore# Accessible at localhost:5432

cat backup.sql | docker exec -i booklib-db psql -U booklib_user -d booklib_test

```# Test database (for automated testing)

docker-compose --profile testing up -d test_db

## Network Configuration# Accessible at localhost:5433



The database container uses the external Docker network `booklib-net`. This allows other BookLib services (like booklib-api) to access the database using the container name:# Both databases simultaneously

docker-compose --profile testing up -d db test_db pgadmin

```python```

# In booklib-api

DATABASE_URL = "postgresql://booklib_user:test_password@booklib-db:5432/booklib_test"### Database Operations

``````bash

# Create backup

## Repository Structure./scripts/backup.sh booklib_dev



```# Restore from backup

booklib-db/./scripts/restore.sh booklib_dev backup_file.sql

├── docker-compose.yml       # Database and PGAdmin services

├── Jenkinsfile             # CI/CD pipeline# Reset database to clean state

├── README.md               # This filedocker-compose exec db psql -U booklib_user -d booklib_dev -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

├── backups/                # Database backups directory./scripts/setup.sh

└── scripts/alembic upgrade head

    ├── deploy-db.sh       # Manual deployment script```

    ├── setup.sh           # Setup helpers

    └── wait-for-db.sh     # Health check script### Migration Management

``````bash

# Create new migration after model changes

## Related Repositoriesalembic revision --autogenerate -m "Description of changes"



- **[booklib-api](https://github.com/StaffanOB/booklib-api)** - REST API that uses this database and manages schema migrations# Apply migrations

alembic upgrade head

## Development Workflow

# Rollback migrations

1. **This repo (booklib-db)**: Provides empty PostgreSQL databasealembic downgrade -1      # Go back one version

2. **booklib-api repo**: alembic downgrade base    # Go back to beginning

   - Manages database schema with Alembic migrations

   - Creates and updates tables# Check migration status

   - Handles all database changesalembic current           # Current version

alembic history          # Migration history

When developing:alembic show <revision>  # Show specific migration

- Make schema changes in booklib-api```

- This repo just provides the database container

- Deploy this repo only when database configuration changes (credentials, ports, etc.)## Environment Variables



## Support### Development

```bash

For issues related to:POSTGRES_DB=booklib_dev

- Database container not starting → Check this repoPOSTGRES_USER=booklib_user

- Tables not created or schema issues → Check booklib-api repoPOSTGRES_PASSWORD=dev_password

- Connection issues → Check network configuration in both reposPOSTGRES_HOST=localhost

POSTGRES_PORT=5432
```````

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
