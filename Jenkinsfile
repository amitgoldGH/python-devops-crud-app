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

        stage('Set Git Variables') {
            steps {
                script {
                    // Assign to top-level env variables for global access
                    env.GIT_HASH = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    env.BRANCH_NAME = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
                    env.BRANCH_SAFE = env.BRANCH_NAME.replaceAll("/", "-")
                    echo "Branch safe: ${env.BRANCH_SAFE}, Commit: ${env.GIT_HASH}"
                }
            }
        }
        
        stage('Test & Lint') {
            steps {
                script {
                    sh '''
                    python3 -m venv venv
                    . venv/bin/activate

                    # Upgrade pip and install dependencies inside venv
                    pip install --upgrade pip
                    pip install -r ./app/requirements.txt
                    pip install pytest flake8

                    # Run linting
                    flake8 ./app/

                    # Run tests if test directory exists
                    if [ -d "./app/tests" ]; then
                        echo "Running unit tests..."
                        pytest ./app/tests/ -v
                    else
                        echo "No tests directory. Skipping."
                    fi
                    '''
                }
            }
        }

        stage('Build Docker Image') {
                when {
                    changeset "**/app/**"
                }
                steps {
                    script {
                        // Build Docker image
                        sh "docker build -f ./app/Dockerfile -t ${IMAGE_NAME}:latest ./app"

                        // Tag with latest and Git commit hash
                        sh "docker tag ${IMAGE_NAME}:latest ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                        sh "docker tag ${IMAGE_NAME}:latest ${DOCKER_HUB_USER}/${IMAGE_NAME}:${env.BRANCH_SAFE}-${env.GIT_HASH}"
                    }
                }
            }
        stage('Push to Docker Hub') {
            when {
                changeset "**/app/**"
            }
            steps {
                script {
                    // Login to Docker Hub using the existing credential 'dockerhub-cred', set up on jenkins
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "docker login -u \$USER -p \$PASS"
                    }

                    // Push both tags
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${env.BRANCH_SAFE}-${env.GIT_HASH}"
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
                sh "docker rmi ${DOCKER_HUB_USER}/${IMAGE_NAME}:${env.BRANCH_SAFE}-${env.GIT_HASH} || true"
            }
            
            echo "Pipeline finished."
        }
    }
}

