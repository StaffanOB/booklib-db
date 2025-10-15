# BookLib Database - Local Development Guide

## Overview
The BookLib Database repository contains PostgreSQL database schema, migrations, and setup scripts for the BookLib application ecosystem.

## Prerequisites
- Docker & Docker Compose
- PostgreSQL client tools (optional, for direct database access)

## Quick Setup

### 1. Clone Repository
```bash
git clone <repository-url>
cd booklib-db
```

### 2. Start Database
```bash
# Start PostgreSQL with Docker Compose
docker-compose up -d

# Check status
docker-compose ps
```

### 3. Verify Database
```bash
# Connect to database
psql postgresql://booklib_user:dev_password@localhost:5432/booklib_dev

# Or using Docker exec
docker-compose exec booklib-db-dev psql -U booklib_user -d booklib_dev
```

### 4. Initialize Data (Optional)
```bash
# Run initialization scripts
psql postgresql://booklib_user:dev_password@localhost:5432/booklib_dev -f init.sql
```

## Database Configuration

### Connection Details
- **Host**: localhost
- **Port**: 5432
- **Database**: booklib_dev
- **Username**: booklib_user
- **Password**: dev_password

### Connection String
```
postgresql://booklib_user:dev_password@localhost:5432/booklib_dev
```

## Database Schema

The database includes the following tables:

### Core Tables
- `users` - User accounts and authentication
- `books` - Book catalog with metadata
- `authors` - Author information
- `tags` - Categorization tags

### Relationship Tables
- `book_tags` - Many-to-many books and tags
- `ratings` - User book ratings
- `comments` - User book comments

### System Tables
- `plugins` - External service plugins
- `alembic_version` - Database migration tracking

## Development Workflow

### Starting/Stopping Database
```bash
# Start database
docker-compose up -d

# Stop database
docker-compose down

# Stop and remove volumes (WARNING: Data loss!)
docker-compose down -v
```

### Database Operations
```bash
# View logs
docker-compose logs booklib-db-dev

# Access database shell
docker-compose exec booklib-db-dev psql -U booklib_user -d booklib_dev

# Backup database
docker-compose exec booklib-db-dev pg_dump -U booklib_user booklib_dev > backup.sql

# Restore database
docker-compose exec -T booklib-db-dev psql -U booklib_user -d booklib_dev < backup.sql
```

### Schema Management
```bash
# View all tables
psql postgresql://booklib_user:dev_password@localhost:5432/booklib_dev -c "\dt"

# View table structure
psql postgresql://booklib_user:dev_password@localhost:5432/booklib_dev -c "\d users"

# Run custom queries
psql postgresql://booklib_user:dev_password@localhost:5432/booklib_dev -c "SELECT COUNT(*) FROM books;"
```

## Project Structure
```
booklib-db/
├── docker-compose.yml       # Docker Compose configuration
├── init.sql                # Database initialization script
├── migrations/             # Database migration files
│   └── alembic/           # Alembic migration environment
├── docs/                  # Database documentation
└── README.md             # This file
```

## Environment Configuration

### Development Environment
The `docker-compose.yml` file defines:
- PostgreSQL 15-alpine container
- Development database credentials
- Port mapping (5432:5432)
- Volume persistence for data

### Environment Variables
```bash
# Database settings
POSTGRES_DB=booklib_dev
POSTGRES_USER=booklib_user
POSTGRES_PASSWORD=dev_password

# Container settings
POSTGRES_HOST_AUTH_METHOD=md5
```

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Check what's using port 5432
   lsof -i :5432
   
   # Stop existing PostgreSQL services
   sudo systemctl stop postgresql
   ```

2. **Permission Denied**
   ```bash
   # Fix Docker permissions
   sudo usermod -aG docker $USER
   
   # Restart Docker service
   sudo systemctl restart docker
   ```

3. **Database Connection Failed**
   ```bash
   # Check container status
   docker-compose ps
   
   # View container logs
   docker-compose logs booklib-db-dev
   
   # Restart container
   docker-compose restart booklib-db-dev
   ```

4. **Data Persistence Issues**
   ```bash
   # Check Docker volumes
   docker volume ls | grep booklib
   
   # Recreate volume if needed
   docker-compose down -v
   docker-compose up -d
   ```

### Performance Tuning

1. **Memory Settings** (for production):
   ```yaml
   # In docker-compose.yml
   environment:
     - POSTGRES_SHARED_PRELOAD_LIBRARIES=pg_stat_statements
     - POSTGRES_MAX_CONNECTIONS=100
     - POSTGRES_SHARED_BUFFERS=256MB
   ```

2. **Connection Pooling**:
   Consider using pgpool-II or connection pooling in your application

## Data Management

### Sample Data
```sql
-- Insert sample user
INSERT INTO users (username, email, password_hash) 
VALUES ('developer', 'dev@booklib.local', 'hashed_password');

-- Insert sample book
INSERT INTO books (title, isbn, publication_year) 
VALUES ('Sample Book', '978-0123456789', 2024);
```

### Backup Strategy
```bash
# Daily backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker-compose exec booklib-db-dev pg_dump -U booklib_user booklib_dev > "backup_${DATE}.sql"

# Keep only last 7 days of backups
find . -name "backup_*.sql" -type f -mtime +7 -delete
```

## Security Considerations

### Development vs Production
- Change default passwords in production
- Use environment variables for secrets
- Enable SSL/TLS for production connections
- Implement proper firewall rules

### Access Control
```sql
-- Create read-only user for reporting
CREATE USER booklib_readonly WITH PASSWORD 'readonly_password';
GRANT CONNECT ON DATABASE booklib_dev TO booklib_readonly;
GRANT USAGE ON SCHEMA public TO booklib_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO booklib_readonly;
```

## Related Repositories
- `booklib-api`: Flask API that connects to this database
- `booklib-tests`: Test suites that use this database
- `booklib-deployment`: Production deployment configurations