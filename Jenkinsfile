pipeline {
    agent any

    environment {
        DOCKER_HUB_USERNAME = credentials('DOCKER_HUB_USERNAME')
        DOCKER_HUB_PASSWORD = credentials('DOCKER_HUB_ACCESS_TOKEN')
        RENDER_API_KEY = credentials('RENDER_API_KEY')
        RENDER_SERVICE_ID = credentials('RENDER_SERVICE_ID')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/seckrama/devops-cours-workflow.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${env.DOCKER_HUB_USERNAME}/devops-app:latest")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        docker.image("${env.DOCKER_HUB_USERNAME}/devops-app:latest").push()
                    }
                }
            }
        }

        stage('Deploy on Render') {
            steps {
                sh '''
                curl -X POST "https://api.render.com/v1/services/${RENDER_SERVICE_ID}/deploys" \
                -H "Authorization: Bearer ${RENDER_API_KEY}" \
                -H "Accept: application/json" \
                -H "Content-Type: application/json"
                '''
            }
        }
    }
}
