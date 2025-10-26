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

                        // Get current branch name
                        BRANCH_NAME = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
                        BRANCH_SAFE = BRANCH_NAME.replaceAll("/", "-")

                        // Build Docker image
                        sh "docker build -f ./app/Dockerfile -t ${IMAGE_NAME}:latest ./app"

                        // Tag with latest and Git commit hash
                        sh "docker tag ${IMAGE_NAME}:latest ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                        sh "docker tag ${IMAGE_NAME}:latest ${DOCKER_HUB_USER}/${IMAGE_NAME}:${BRANCH_SAFE}-${GIT_HASH}"
                    }
                }
            }
        stage('Push to Docker Hub') {
            steps {
                script {
                    // Login to Docker Hub using the existing credential 'dockerhub-cred'
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "docker login -u \$USER -p \$PASS"
                    }

                    // Push both tags
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${BRANCH_SAFE}-${GIT_HASH}"
                }
            }
        }
    }

    post {


        always {
            script {
                // Remove dangling images
                sh "docker image prune -f"
                // Optionally remove the built image to free space
                sh "docker rmi ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest || true"
                sh "docker rmi ${DOCKER_HUB_USER}/${IMAGE_NAME}:${BRANCH_SAFE}-${GIT_HASH} || true"
            }
            
            echo "Pipeline finished."
        }
    }
}

