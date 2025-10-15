# Jenkins Pipeline Setup for booklib-db

## Overview

This document explains how to set up the Jenkins pipeline for deploying the booklib-db database service.

## Prerequisites

### 1. Jenkins Configuration

- Jenkins server should be running
- Required plugins:
  - Pipeline plugin
  - SSH Agent plugin
  - Git plugin

### 2. SSH Credentials

You need to configure SSH credentials in Jenkins to access the deployment server:

1. Go to Jenkins → Manage Jenkins → Credentials
2. Add new credentials:
   - **Kind**: SSH Username with private key
   - **ID**: `deploy-key`
   - **Username**: `deploy`
   - **Private Key**: Enter your SSH private key for the deploy user

### 3. Deployment Server Setup

Ensure the deployment server (192.168.1.175) has:

- Docker installed and running
- Docker Compose installed
- User `deploy` with:
  - SSH access configured
  - Permission to run Docker commands (add to docker group)
  ```bash
  sudo usermod -aG docker deploy
  ```

## Pipeline Stages

### 1. **Prepare Deployment Files**

- Lists and verifies workspace files

### 2. **Backup Database**

- Creates automatic backup before deployment
- Backups stored in `/opt/booklib/db/backups/`
- Format: `backup_YYYYMMDD_HHMMSS.sql`
- Skips if no database is running (first deployment)

### 3. **Deploy to Server**

- Creates necessary directories on deployment server
- Copies deployment files:
  - `docker-compose.yml`
  - `alembic.ini`
  - `models.py`
  - `requirements.txt`
  - `init-scripts/*`
  - `migrations/*`
- Creates Docker network `booklib-net` (shared with booklib-api)
- Stops old containers
- Starts database service

### 4. **Run Migrations**

- Verifies database connection
- Placeholder for running Alembic migrations
- Can be extended to run migrations in a container

### 5. **Health Check**

- Verifies database container is running
- Tests database connectivity using `pg_isready`
- Fails deployment if health check fails

## Environment Variables

The pipeline uses these environment variables:

```groovy
DEPLOY_SERVER = '192.168.1.175'      // IP address of deployment server
DEPLOY_USER = 'deploy'                // SSH user for deployment
DEPLOY_PATH = '/opt/booklib/db'       // Deployment directory
DB_BACKUP_PATH = '/opt/booklib/db/backups'  // Backup directory
```

## Creating the Jenkins Job

### Option 1: Pipeline from SCM (Recommended)

1. Create new Pipeline job in Jenkins
2. Configure:
   - **Pipeline** → **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: Your booklib-db git repository
   - **Script Path**: `Jenkinsfile`

### Option 2: Direct Pipeline Script

1. Create new Pipeline job
2. Copy the Jenkinsfile content directly into Pipeline script section

## Deployment Paths

The pipeline deploys to the following structure on the server:

```
/opt/booklib/db/
├── docker-compose.yml
├── alembic.ini
├── models.py
├── requirements.txt
├── init-scripts/
├── migrations/
└── backups/
    └── backup_YYYYMMDD_HHMMSS.sql
```

## Network Configuration

The database service connects to the `booklib-net` Docker network, which allows:

- Communication with booklib-api service
- Isolation from other containers
- Shared network namespace

The network is created automatically if it doesn't exist.

## Database Connection

After deployment, the database is accessible:

- **From deployment server**: `localhost:5432`
- **From other containers on booklib-net**: `booklib-db-dev:5432`
- **From external hosts**: `192.168.1.175:5432`

Connection details:

- **Database**: `booklib_dev`
- **User**: `booklib_user`
- **Password**: `dev_password`

## Running the Pipeline

1. Commit and push your changes to Git
2. Go to Jenkins → Your booklib-db job
3. Click "Build Now"
4. Monitor the pipeline execution

## Post-Deployment Verification

After successful deployment, verify:

```bash
# SSH to deployment server
ssh deploy@192.168.1.175

# Check container status
cd /opt/booklib/db
docker compose ps

# Test database connection
docker exec booklib-db-dev psql -U booklib_user -d booklib_dev -c "SELECT version();"

# View logs
docker compose logs db
```

## Troubleshooting

### SSH Connection Issues

- Verify SSH credentials are configured in Jenkins
- Test SSH access manually: `ssh deploy@192.168.1.175`
- Check SSH key permissions (should be 600)

### Database Won't Start

- Check logs: `docker compose logs db`
- Verify port 5432 is not already in use
- Check disk space on deployment server

### Health Check Fails

- Container may need more time to start (increase sleep time in Jenkinsfile)
- Check database logs for errors
- Verify database credentials

### Network Issues

- Ensure booklib-net network exists: `docker network ls`
- Recreate network if needed: `docker network create booklib-net`

## Backup and Restore

### Manual Backup

```bash
ssh deploy@192.168.1.175
cd /opt/booklib/db
docker exec booklib-db-dev pg_dump -U booklib_user booklib_dev > backups/manual_backup.sql
```

### Restore from Backup

```bash
ssh deploy@192.168.1.175
cd /opt/booklib/db
cat backups/backup_YYYYMMDD_HHMMSS.sql | docker exec -i booklib-db-dev psql -U booklib_user -d booklib_dev
```

## Integration with booklib-api

The booklib-api service connects to this database using:

- **Host**: `booklib-db-dev` (container name on booklib-net network)
- **Port**: `5432`
- **Database**: `booklib_dev`

Ensure booklib-api's `.env` file has:

```
DATABASE_URL=postgresql://booklib_user:dev_password@booklib-db-dev:5432/booklib_dev
```

## Security Notes

⚠️ **Important Security Considerations:**

1. Change default passwords in production
2. Use environment variables or secrets for sensitive data
3. Restrict database port access using firewall rules
4. Enable SSL/TLS for database connections in production
5. Regular backup strategy implementation
6. Limit SSH access to deployment server

## Next Steps

1. ✅ Set up SSH credentials in Jenkins (`deploy-key`)
2. ✅ Create Jenkins pipeline job
3. ✅ Verify deployment server access
4. ✅ Run initial deployment
5. Configure automated backups (optional)
6. Set up monitoring and alerting (optional)
7. Implement migration automation if needed
