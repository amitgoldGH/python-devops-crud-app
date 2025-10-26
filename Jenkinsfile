pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'amitgoldgh'
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
                        sh "docker build -t ${IMAGE_NAME}:latest ."

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
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                    }

                    // Push both tags
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${GIT_HASH}"
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

