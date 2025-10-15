pipeline {
    agent any
    
    environment {
        DEPLOY_SERVER = '192.168.1.175'
        DEPLOY_USER = 'deploy'
        DEPLOY_PATH = '/opt/booklib/db'
    }
    
    stages {
        stage('Deploy to Server') {
            steps {
                sshagent(['deploy-key']) {
                    script {
                        sh """
                            set -e
                            cd ${WORKSPACE}
                            echo "Deploying database container..."

                            # Ensure deploy path exists
                            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_SERVER} 'mkdir -p ${DEPLOY_PATH}'
                            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_SERVER} 'mkdir -p ${DEPLOY_PATH}/backups'

                            echo "Copying docker-compose.yml..."
                            scp -o StrictHostKeyChecking=no ${WORKSPACE}/docker-compose.yml ${DEPLOY_USER}@${DEPLOY_SERVER}:${DEPLOY_PATH}/
                        """
                        
                        // Deploy script
                        sh '''
                            ssh -o StrictHostKeyChecking=no deploy@192.168.1.175 bash -s << 'EOF'
                                set +e
                                cd /opt/booklib/db

                                # Create network if it doesn't exist
                                docker network inspect booklib-net >/dev/null 2>&1 || docker network create booklib-net

                                # Deploy database service
                                docker compose -f docker-compose.yml up -d db
                                
                                # Wait for database to be ready
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
        
        stage('Health Check') {
            steps {
                sshagent(['deploy-key']) {
                    script {
                        def result = sh(
                            script: """
                                set +e
                                ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_SERVER} '
                                    echo "Running database health check..."
                                    
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