pipeline {
    agent any

    environment {
        DOCKER_HUB_USERNAME = credentials('DOCKER_HUB_USERNAME')
        DOCKER_HUB_ACCESS_TOKEN = credentials('DOCKER_HUB_ACCESS_TOKEN')
        IMAGE_NAME = "${env.DOCKER_HUB_USERNAME}/devops-app"
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
            git branch: 'main',
            url: 'https://github.com/seckrama/devops-jeenkins.git' 
            credentialsId: 'github-credentials'            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Construction de l'image
                    def image = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                    
                    // Stockage pour utilisation dans l'étape suivante
                    env.DOCKER_IMAGE = "${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Login Docker Hub avec les credentials
                    sh '''
                        echo $DOCKER_HUB_ACCESS_TOKEN | docker login --username $DOCKER_HUB_USERNAME --password-stdin
                    '''
                    
                    // Push de l'image
                    sh "docker push ${env.DOCKER_IMAGE}"
                    
                    // Logout pour sécurité
                    sh 'docker logout'
                }
            }
        }

     
    }

    post {
        always {
            // Nettoyage des images locales
            sh 'docker system prune -f'
        }
        failure {
            echo 'Pipeline failed!'
        }
        success {
            echo 'Pipeline succeeded!'
        }
    }
}