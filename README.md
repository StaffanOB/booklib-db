# BookLib Database# BookLib Database# BookLib Database



PostgreSQL database container for the BookLib project ecosystem.PostgreSQL database container for the BookLib project ecosystem.Database management, migrations, and utilities for the BookLib project ecosystem.



## Overview## Purpose## 🚀 Local Development Guide



This repository provides a **PostgreSQL database container** that creates an empty database and user for the BookLib project.This repository provides a **PostgreSQL database container** that creates an empty database and user. **For detailed local development setup instructions, see [README_DEV.md](README_DEV.md)**



- ✅ PostgreSQL 15-alpine container**Database migrations are handled by the [booklib-api](https://github.com/StaffanOB/booklib-api) repository.**## Repository Structure

- ✅ Creates database `booklib_test` and user `booklib_user`

- ✅ Empty database (no tables - migrations handled by booklib-api)## What This Repository Does```

- ✅ PGAdmin for database management (optional)

- ✅ Works locally and on remote serversbooklib-db/



**Database schema and migrations are handled by [booklib-api](https://github.com/StaffanOB/booklib-api).**- ✅ Provides PostgreSQL 15 in a Docker container├── docker-compose.yml # Database services (dev, test, pgadmin)



---- ✅ Creates database `booklib_test` and user `booklib_user`├── migrations/ # Alembic migration files



## 🏠 Local Development- ✅ Exposes database on port 5432│ ├── alembic.ini



### Start the Database- ✅ Includes PGAdmin for database management (optional)│ ├── env.py



```bash- ✅ Automated deployment via Jenkins pipeline│ └── versions/

# Clone the repository

git clone https://github.com/StaffanOB/booklib-db.git├── scripts/ # Database utilities

cd booklib-db

## Quick Start│ ├── setup.sh # Database initialization

# Create the external network (first time only)

docker network create booklib-net│ ├── backup.sh # Backup utilities



# Start the database### Local Development│ ├── restore.sh # Restore utilities

docker-compose up -d db

```│ └── wait-for-db.sh # Health check script



### Verify Database is Running1. **Start the database**:├── sql/ # SQL scripts



```bash   ````bash│ ├── init.sql               # Initial schema

# Check container status

docker ps | grep booklib-db   docker-compose up -d db│   └── seed.sql               # Sample data



# Test database connection   ```└── docs/                       # Database documentation

docker exec booklib-db pg_isready -U booklib_user -d booklib_test

    └── schema.md

# Should output: "booklib_test:5432 - accepting connections"

```   ````



### Connect to Database Locally2. **Verify it's running**:```



#### Option 1: Using Docker exec (psql)   ```bash



```bash   docker exec booklib-db pg_isready -U booklib_user -d booklib_test## Quick Start for Local Development

# Access database CLI

docker exec -it booklib-db psql -U booklib_user -d booklib_test   ```



# List databases### Prerequisites

\l

3. **Access the database** (if needed):- Docker Engine 20.10+

# List tables (will be empty until booklib-api creates schema)

\dt   ````bash- Docker Compose 2.0+



# Exit   docker exec -it booklib-db psql -U booklib_user -d booklib_test- Python 3.11+ (for migration management)

\q

```   ```- PostgreSQL client tools (optional, for direct access)

   ````

#### Option 2: Using External Database Client

### Start PGAdmin (Optional)### 1. Setup Database Environment

Connect with any PostgreSQL client using these credentials:

`````bash

| Setting  | Value                |

|----------|----------------------|```bash# Clone the repository

| Host     | `localhost`          |

| Port     | `5432`              |docker-compose --profile tools up -d pgadmingit clone https://github.com/StaffanOB/booklib-db.git

| Database | `booklib_test`       |

| Username | `booklib_user`       |```cd booklib-db

| Password | `test_password`      |



**Connection String:**

```Access at: `http://localhost:8080`# Create Python virtual environment for migrations

postgresql://booklib_user:test_password@localhost:5432/booklib_test

```- Email: `admin@booklib.com`python3 -m venv .venv



#### Option 3: Using PGAdmin (Web Interface)- Password: `admin`source .venv/bin/activate  # On Windows: .venv\Scripts\activate



```bash

# Start PGAdmin

docker-compose --profile tools up -d pgadmin### Server Information# Install migration dependencies



# Access at: http://localhost:8080pip install -r requirements.txt

# Login: admin@booklib.com / admin

```Add server in PGAdmin:```



In PGAdmin, add a new server:- **Host**: `booklib-db` (container name)

- **Name**: BookLib Local

- **Host**: `booklib-db`- **Port**: `5432`### 2. Start Development Database

- **Port**: `5432`

- **Database**: `booklib_test`- **Database**: `booklib_test````bash

- **Username**: `booklib_user`

- **Password**: `test_password`- **Username**: `booklib_user`# Start PostgreSQL database



---- **Password**: `test_password`docker-compose up -d db



## 🌐 Remote Server (192.168.1.175)



### Connect to Remote Database## Configuration# Wait for database to be ready



The database is deployed to `192.168.1.175` using Jenkins pipeline../scripts/wait-for-db.sh



#### Database Connection (External Access)### Environment Variables



| Setting  | Value                |# Check database status

|----------|----------------------|

| Host     | `192.168.1.175`      |The database is configured in `docker-compose.yml`:docker-compose ps

| Port     | `5432`              |

| Database | `booklib_test`       |`````

| Username | `booklib_user`       |

| Password | `test_password`      |````yaml



**Connection String:**environment:### 3. Initialize Database Schema

```

postgresql://booklib_user:test_password@192.168.1.175:5432/booklib_test  POSTGRES_DB: booklib_test```bash

```

  POSTGRES_USER: booklib_user# Run initial setup (creates tables, indexes, etc.)

#### PGAdmin Access

  POSTGRES_PASSWORD: test_password./scripts/setup.sh

**Web Interface:** http://192.168.1.175:8080

- **Login**: admin@booklib.com````

- **Password**: admin

# Apply all migrations

In PGAdmin, the server should be pre-configured as:

- **Name**: BookLib Remote### Networksource .venv/bin/activate

- **Host**: `booklib-db` (container name)

- **Port**: `5432`alembic upgrade head

- **Database**: `booklib_test`

- **Username**: `booklib_user`The database container connects to the `booklib-net` Docker network, allowing other BookLib services to access it by container name (`booklib-db`).

- **Password**: `test_password`

# Verify tables were created

#### SSH Access to Remote Server

## Deploymentdocker-compose exec db psql -U booklib_user -d booklib_dev -c "\dt"

```bash

# SSH to server````

ssh deploy@192.168.1.175

### Jenkins Pipeline

# Check database status

cd /opt/booklib/db### 4. Load Sample Data (Optional)

docker ps | grep booklib-db

docker logs booklib-dbThe repository includes a Jenkins pipeline (`Jenkinsfile`) that:```bash



# Access database CLI on remote server# Load development seed data

docker exec -it booklib-db psql -U booklib_user -d booklib_test

```1. Deploys docker-compose.yml to the test serverdocker-compose exec db psql -U booklib_user -d booklib_dev -f /docker-entrypoint-initdb.d/seed.sql



---2. Creates the Docker network if needed



## 🔧 Common Operations3. Starts the database container# Or create your own test data



### Start/Stop Database4. Runs a health checkdocker-compose exec db psql -U booklib_user -d booklib_dev



```bash# SQL> INSERT INTO books (title, author, isbn) VALUES ('Test Book', 'Test Author', '123456789');

# Local

docker-compose up -d db          # Start**To deploy**: Run the `booklib-db-pipeline` job in Jenkins.```

docker-compose stop db          # Stop

docker-compose restart db       # Restart

docker-compose down             # Stop and remove

### Manual Deployment### 5. Development Workflow

# Remote (via SSH)

ssh deploy@192.168.1.175 "cd /opt/booklib/db && docker-compose up -d db"```bash

ssh deploy@192.168.1.175 "cd /opt/booklib/db && docker-compose down"

``````bash# Make database schema changes by creating migrations



### View Database Logs# Copy docker-compose.yml to serversource .venv/bin/activate



```bashscp docker-compose.yml deploy@192.168.1.175:/opt/booklib/db/alembic revision --autogenerate -m "Add new table or column"

# Local

docker logs booklib-db -f



# Remote# SSH to server and deploy# Review generated migration in migrations/versions/

ssh deploy@192.168.1.175 "docker logs booklib-db -f"

```ssh deploy@192.168.1.175# Edit if needed, then apply



### Database Health Checkcd /opt/booklib/dbalembic upgrade head



```bashdocker network create booklib-net  # if not exists

# Local

docker exec booklib-db pg_isready -U booklib_user -d booklib_testdocker-compose up -d db# Test migration rollback



# Remote```alembic downgrade -1

ssh deploy@192.168.1.175 "docker exec booklib-db pg_isready -U booklib_user -d booklib_test"

```alembic upgrade head



### Check Tables (After API Creates Schema)## Database Schema



```bash# Check current migration status

# Local

docker exec booklib-db psql -U booklib_user -d booklib_test -c '\dt'**Schema and migrations are managed by the booklib-api repository.**alembic current



# Remotealembic history --verbose

ssh deploy@192.168.1.175 "docker exec booklib-db psql -U booklib_user -d booklib_test -c '\dt'"

```This repository only provides the empty database. The API handles:```



---- Creating tables



## 📊 Database Backup & Restore- Running migrations## Integration with BookLib Services



### Create Backup- Managing schema changes



```bash### API Integration (booklib-api)

# Local

docker exec booklib-db pg_dump -U booklib_user booklib_test > backup_$(date +%Y%m%d_%H%M%S).sqlSee [booklib-api](https://github.com/StaffanOB/booklib-api) for database schema details.```bash



# Remote# Start database for API development

ssh deploy@192.168.1.175 "docker exec booklib-db pg_dump -U booklib_user booklib_test" > remote_backup_$(date +%Y%m%d_%H%M%S).sql

```## Useful Commandsdocker-compose up -d db



### Restore Backup



```bash### Check Database Status# API connects using these credentials:

# Local

cat backup_file.sql | docker exec -i booklib-db psql -U booklib_user -d booklib_test# DATABASE_URL=postgresql://booklib_user:dev_password@localhost:5432/booklib_dev



# Remote```bash

cat backup_file.sql | ssh deploy@192.168.1.175 "docker exec -i booklib-db psql -U booklib_user -d booklib_test"

```# Check if container is running# Verify API can connect



---docker ps | grep booklib-dbcd ../booklib-api



## 🚀 Deploymentsource .venv/bin/activate



### Jenkins Pipeline# Check if database is readyexport DATABASE_URL=postgresql://booklib_user:dev_password@localhost:5432/booklib_dev



The repository includes a Jenkins pipeline that deploys the database to `192.168.1.175`:docker exec booklib-db pg_isready -U booklib_user -d booklib_testpython -c "from app.models import db; print('Database connection successful')"



1. Go to Jenkins (your Jenkins URL)````

2. Run the `booklib-db-pipeline` job

3. Pipeline will:# View logs

   - Copy docker-compose.yml to server

   - Create Docker network if neededdocker logs booklib-db### Testing Integration (booklib-tests)

   - Start database container

   - Run health check````bash



### Manual Deployment# Start test database



```bash### Access Databasedocker-compose --profile testing up -d test_db

# Deploy to remote server

scp docker-compose.yml deploy@192.168.1.175:/opt/booklib/db/



ssh deploy@192.168.1.175 '```bash# Reset test database before each test run

  cd /opt/booklib/db

  docker network create booklib-net || true# psql CLIdocker-compose exec test_db psql -U booklib_user -d booklib_test -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

  docker-compose up -d db

'docker exec -it booklib-db psql -U booklib_user -d booklib_test./scripts/setup.sh test

```

alembic upgrade head

---

# List tables (once API has created them)

## 🔗 Integration with BookLib API

docker exec booklib-db psql -U booklib_user -d booklib_test -c '\dt'# Run tests

The booklib-api connects to this database using the Docker network:

cd ../booklib-tests

**API Connection (within Docker network):**

```python# Check database sizerobot --variable DB_URL:postgresql://booklib_user:test_password@localhost:5433/booklib_test robot/api/

DATABASE_URL = "postgresql://booklib_user:test_password@booklib-db:5432/booklib_test"

```docker exec booklib-db psql -U booklib_user -d booklib_test -c "SELECT pg_size_pretty(pg_database_size('booklib_test'));"```



**API Connection (external/local development):**```

```python

DATABASE_URL = "postgresql://booklib_user:test_password@localhost:5432/booklib_test"  # Local### Full Stack Development

DATABASE_URL = "postgresql://booklib_user:test_password@192.168.1.175:5432/booklib_test"  # Remote

```### Stop/Start Database```bash



---# Start complete development environment



## 🗂️ Repository Structure```bashdocker-compose up -d db pgadmin



```# Stop

booklib-db/

├── docker-compose.yml       # Database and PGAdmin servicesdocker-compose down# Connect to PgAdmin (optional GUI)

├── Jenkinsfile             # CI/CD pipeline for deployment

├── README.md               # This file# Browser: http://localhost:5050

├── backups/                # Local backup directory

└── scripts/# Start# Email: admin@booklib.com

    ├── deploy-db.sh       # Manual deployment script

    ├── setup.sh           # Setup helpersdocker-compose up -d db# Password: admin

    └── wait-for-db.sh     # Health check script

```



---# Restart# Or use psql directly



## 🆘 Troubleshootingdocker-compose restart dbdocker-compose exec db psql -U booklib_user -d booklib_dev



### Database Won't Start````



```bash### Backup & Restore## Database Management

# Check logs

docker logs booklib-db```````bash### Environment-Specific Databases



# Check if network exists# Backup```bash

docker network ls | grep booklib-net

docker exec booklib-db pg_dump -U booklib_user booklib_test > backup.sql# Development (default)

# Create network if missing

docker network create booklib-netdocker-compose up -d db



# Restart database# Restore# Accessible at localhost:5432

docker-compose down

docker-compose up -d dbcat backup.sql | docker exec -i booklib-db psql -U booklib_user -d booklib_test

```

```# Test database (for automated testing)

### Can't Connect to Database

docker-compose --profile testing up -d test_db

1. **Check if database is running:**

   ```bash## Network Configuration# Accessible at localhost:5433

   docker ps | grep booklib-db

   ```



2. **Check if port is exposed:**The database container uses the external Docker network `booklib-net`. This allows other BookLib services (like booklib-api) to access the database using the container name:# Both databases simultaneously

   ```bash

   docker port booklib-dbdocker-compose --profile testing up -d db test_db pgadmin

   ```

```python```

3. **Test connection:**

   ```bash# In booklib-api

   docker exec booklib-db pg_isready -U booklib_user -d booklib_test

   ```DATABASE_URL = "postgresql://booklib_user:test_password@booklib-db:5432/booklib_test"### Database Operations



4. **Verify credentials in docker-compose.yml**``````bash



### PGAdmin Won't Connect# Create backup



1. **Verify PGAdmin is running:**## Repository Structure./scripts/backup.sh booklib_dev

   ```bash

   docker ps | grep pgadmin

   ```

```# Restore from backup

2. **Check network connectivity:**

   ```bashbooklib-db/./scripts/restore.sh booklib_dev backup_file.sql

   docker exec booklib-pgadmin ping booklib-db

   ```├── docker-compose.yml       # Database and PGAdmin services



3. **Use container name `booklib-db` as host in PGAdmin, not `localhost`**├── Jenkinsfile             # CI/CD pipeline# Reset database to clean state



---├── README.md               # This filedocker-compose exec db psql -U booklib_user -d booklib_dev -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"



## 📋 Quick Reference├── backups/                # Database backups directory./scripts/setup.sh



| Task | Local Command | Remote Command |└── scripts/alembic upgrade head

|------|---------------|----------------|

| Start DB | `docker-compose up -d db` | SSH + `docker-compose up -d db` |    ├── deploy-db.sh       # Manual deployment script```

| Stop DB | `docker-compose down` | SSH + `docker-compose down` |

| DB CLI | `docker exec -it booklib-db psql -U booklib_user -d booklib_test` | SSH + same command |    ├── setup.sh           # Setup helpers

| Check Status | `docker ps \| grep booklib-db` | SSH + same command |

| View Logs | `docker logs booklib-db` | SSH + same command |    └── wait-for-db.sh     # Health check script### Migration Management

| PGAdmin | http://localhost:8080 | http://192.168.1.175:8080 |

``````bash

**Database URLs:**

- **Local**: `postgresql://booklib_user:test_password@localhost:5432/booklib_test`# Create new migration after model changes

- **Remote**: `postgresql://booklib_user:test_password@192.168.1.175:5432/booklib_test`

- **Container Network**: `postgresql://booklib_user:test_password@booklib-db:5432/booklib_test`## Related Repositoriesalembic revision --autogenerate -m "Description of changes"



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
