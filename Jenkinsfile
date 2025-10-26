pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'amitgoldgh'
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')
        IMAGE_NAME = 'flask-crud-app'
    }

    stages {
        stage('Checkout Repo') {
            steps {
                git branch: 'main', credentialsId: 'github-cred', url: 'https://github.com/amitgoldGH/python-devops-crud-app.git'
            }
        }
        stage('Build Docker Image') {
                steps {
                    script {
                        // Get the short Git commit hash
                        GIT_HASH = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()

                        // Build Docker image
                        sh "docker build -f ./app/Dockerfile -t ${IMAGE_NAME}:latest ./app"

                        // Tag with latest and Git commit hash
                        sh "docker tag ${IMAGE_NAME}:latest ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                        sh "docker tag ${IMAGE_NAME}:latest ${DOCKER_HUB_USER}/${IMAGE_NAME}:${GIT_HASH}"
                    }
                }
            }
        stage('Push to Docker Hub') {
            steps {
                script {
                    // Login to Docker Hub using the existing credential 'dockerhub-cred'
                    // Push both tags
                    sh """
                    docker login -u \$DOCKERHUB_CREDENTIALS_USR -p \$DOCKERHUB_CREDENTIALS_PSW
                    docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest
                    docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${GIT_HASH}
                    """
                    
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished."
        }
    }
}

