pipeline {
    agent any

    options {
        
        disableConcurrentBuilds()
    }

    triggers {
        pollSCM('H/5 * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo 'Source code checked out successfully.'
            }
        }

        stage('Test Backend') {
            steps {
                sh '''
                    docker build \
                      -t fa2-backend-test:${BUILD_NUMBER} \
                      -f docker/backend/Dockerfile.test \
                      docker/backend

                    docker run --rm \
                      fa2-backend-test:${BUILD_NUMBER}
                '''
            }
        }

        stage('Build Docker Images') {
            steps {
                sh '''
                    docker build \
                      -t fa2-backend:${BUILD_NUMBER} \
                      docker/backend

                    docker build \
                      -t fa2-frontend:${BUILD_NUMBER} \
                      docker/frontend
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    kubectl set image deployment/backend \
                      backend=fa2-backend:${BUILD_NUMBER}

                    kubectl set image deployment/frontend \
                      frontend=fa2-frontend:${BUILD_NUMBER}
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    kubectl rollout status deployment/backend \
                      --timeout=120s

                    kubectl rollout status deployment/frontend \
                      --timeout=120s

                    kubectl get deployments
                    kubectl get pods
                    kubectl get services
                '''
            }
        }
    }

    post {
        success {
            echo 'CI/CD pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the stage logs for details.'
        }
        always {
            echo 'Pipeline execution finished.'
        }
    }
}
