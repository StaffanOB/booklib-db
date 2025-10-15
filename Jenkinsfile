pipeline {
    agent any
    
    environment {
        DEPLOY_SERVER = '192.168.1.175'
        DEPLOY_USER = 'deploy'
        DEPLOY_PATH = '/opt/booklib/db'
        DB_BACKUP_PATH = '/opt/booklib/db/backups'
    }
    
    stages {
        stage('Prepare Deployment Files') {
            steps {
                script {
                    sh """
                        echo "Preparing deployment files..."
                        ls -la
                    """
                }
            }
        }
        
        stage('Backup Database') {
            steps {
                sshagent(['deploy-key']) {
                    script {
                        sh """
                            set +e
                            echo "Creating database backup..."
                            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_SERVER} '
                                mkdir -p ${DB_BACKUP_PATH}
                                cd ${DEPLOY_PATH}
                                
                                # Check if database container is running
                                if docker ps | grep -q booklib-db; then
                                    echo "Creating backup of existing database..."
                                    docker exec booklib-db pg_dump -U booklib_user booklib_test > ${DB_BACKUP_PATH}/backup_\$(date +%Y%m%d_%H%M%S).sql || true
                                    echo "Backup created"
                                else
                                    echo "No running database found, skipping backup"
                                fi
                            '
                        """
                    }
                }
            }
        }

        stage('Deploy to Server') {
            steps {
                sshagent(['deploy-key']) {
                    script {
                        sh """
                            set -e
                            cd ${WORKSPACE}
                            echo "Current workspace:"
                            pwd
                            ls -la

                            # Ensure deploy path exists
                            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_SERVER} 'mkdir -p ${DEPLOY_PATH}'
                            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_SERVER} 'mkdir -p ${DEPLOY_PATH}/init-scripts'
                            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_SERVER} 'mkdir -p ${DEPLOY_PATH}/backups'
                            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_SERVER} 'mkdir -p ${DEPLOY_PATH}/migrations'

                            echo "Copying deployment files..."
                            scp -o StrictHostKeyChecking=no ${WORKSPACE}/docker-compose.yml ${DEPLOY_USER}@${DEPLOY_SERVER}:${DEPLOY_PATH}/
                            scp -o StrictHostKeyChecking=no ${WORKSPACE}/alembic.ini ${DEPLOY_USER}@${DEPLOY_SERVER}:${DEPLOY_PATH}/
                            scp -o StrictHostKeyChecking=no ${WORKSPACE}/models.py ${DEPLOY_USER}@${DEPLOY_SERVER}:${DEPLOY_PATH}/
                            scp -o StrictHostKeyChecking=no ${WORKSPACE}/requirements.txt ${DEPLOY_USER}@${DEPLOY_SERVER}:${DEPLOY_PATH}/
                            
                            # Copy init scripts if they exist
                            if [ -d "${WORKSPACE}/init-scripts" ] && [ "\$(ls -A ${WORKSPACE}/init-scripts)" ]; then
                                scp -o StrictHostKeyChecking=no -r ${WORKSPACE}/init-scripts/* ${DEPLOY_USER}@${DEPLOY_SERVER}:${DEPLOY_PATH}/init-scripts/
                            fi
                            
                            # Copy migrations
                            scp -o StrictHostKeyChecking=no -r ${WORKSPACE}/migrations/* ${DEPLOY_USER}@${DEPLOY_SERVER}:${DEPLOY_PATH}/migrations/
                        """
                        
                        // Deploy script - using separate sh block to avoid escaping issues
                        sh '''
                            ssh -o StrictHostKeyChecking=no deploy@192.168.1.175 bash -s << 'EOF'
                                set +e
                                cd /opt/booklib/db

                                # Create network if it doesn't exist
                                docker network inspect booklib-net >/dev/null 2>&1 || docker network create booklib-net

                                # Stop and remove old containers
                                docker compose -f docker-compose.yml down || true

                                # Start database service
                                docker compose -f docker-compose.yml up -d db
                                
                                # Wait for container to start and database to be ready
                                echo "Waiting for database to start..."
                                i=1
                                while [ $i -le 30 ]; do
                                    if docker exec booklib-db pg_isready -U booklib_user -d booklib_test 2>/dev/null; then
                                        echo "Database is ready!"
                                        break
                                    fi
                                    echo "Waiting... (attempt $i/30)"
                                    sleep 2
                                    i=$((i + 1))
                                done
                                
                                # Check database status
                                docker compose ps
                                
                                exit 0
EOF
                        '''
                    }
                }
            }
        }
        
        stage('Run Migrations') {
            steps {
                sshagent(['deploy-key']) {
                    script {
                        sh """
                            set +e
                            echo "Running database migrations..."
                            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_SERVER} '
                                cd ${DEPLOY_PATH}
                                
                                # Install alembic if needed and run migrations
                                docker exec booklib-db psql -U booklib_user -d booklib_test -c "SELECT version();" || true
                                
                                # If you have a migrations container or need to run alembic:
                                # docker run --rm --network booklib-net -v \$(pwd):/app -w /app python:3.12-slim bash -c "
                                #   pip install -r requirements.txt && alembic upgrade head
                                # "
                                
                                echo "Migrations completed (if configured)"
                            '
                        """
                    }
                }
            }
        }
        
        stage('Health Check') {
            steps {
                sshagent(['deploy-key']) {
                    script {
                        def result = sh(
                            script: """
                                set +e
                                ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_SERVER} '
                                    echo "Running database health check..."
                                    cd ${DEPLOY_PATH}
                                    
                                    # Check if container is running
                                    if docker ps | grep -q booklib-db; then
                                        echo "Database container is running"
                                        
                                        # Test database connection
                                        docker exec booklib-db pg_isready -U booklib_user -d booklib_test
                                        if [ \$? -eq 0 ]; then
                                            echo "Database is accepting connections"
                                            exit 0
                                        else
                                            echo "Database is not ready"
                                            exit 1
                                        fi
                                    else
                                        echo "Database container is not running"
                                        exit 1
                                    fi
                                '
                            """,
                            returnStatus: true
                        )
                        
                        if (result == 0) {
                            echo "Health check passed!"
                        } else {
                            echo "Health check failed with exit code ${result}"
                            error("Database health check failed")
                        }
                    }
                }
            }
        }    
    }
    
    post {
        success {
            echo "Database deployment to ${DEPLOY_SERVER} completed successfully!"
        }
        failure {
            echo "Database deployment failed. Please check the logs."
            script {
                sh """
                    ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_SERVER} '
                        cd ${DEPLOY_PATH}
                        docker compose logs --tail=50 db || true
                    ' || true
                """
            }
        }
        always {
            cleanWs()
        }
    }
}