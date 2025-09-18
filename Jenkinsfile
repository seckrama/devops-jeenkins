pipeline {
    agent any

    tools {
        nodejs "node"
    }

    environment {
        DOCKER_HUB_USER = "bintabdallah"
        IMAGE_NAME = "forgithubaction"
        DEPLOY_PORT = "8080"   
    }

    stages {
        stage('Checkout') {
            steps {
                    git branch: 'main', 
                    url: 'https://github.com/seckrama/devops-jeenkins.git'

                    credentialsId: 'github-credentials'
            }
        }

        stage('Install dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Test') {
            steps {
                echo '⚠️ Aucun test défini, stage ignoré'
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    def image = docker.build("${DOCKER_HUB_USER}/${IMAGE_NAME}:${env.BUILD_NUMBER}")
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub') {
                        image.push()
                        image.push("latest")
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo '🚀 Déploiement en cours...'

                 
                    sh """
                        if [ \$(docker ps -aq -f name=${IMAGE_NAME}) ]; then
                            echo "Arrêt du container existant..."
                            docker stop ${IMAGE_NAME} || true
                            docker rm ${IMAGE_NAME} || true
                            echo "Container existant supprimé"
                        fi
                    """

                  
                    def deployPort = env.DEPLOY_PORT
                    
                    
                    def port8080Used = sh(
                        script: "lsof -i:8080 > /dev/null 2>&1",
                        returnStatus: true
                    ) == 0
                    
                    if (port8080Used) {
                        echo "⚠️ Port 8080 occupé, tentative sur le port 8081"
                        
                       def port8081Used = sh(
                            script: "lsof -i:8081 > /dev/null 2>&1",
                            returnStatus: true
                        ) == 0
                        
                        if (port8081Used) {
                            echo "⚠️ Port 8081 aussi occupé, utilisation du port 8082"
                            deployPort = "8082"
                        } else {
                            deployPort = "8081"
                        }
                    }

                    echo "📍 Déploiement sur le port ${deployPort}"

                  
                    sh """
                        echo "Lancement du container sur le port ${deployPort}..."
                        docker run -d -p ${deployPort}:80 --name ${IMAGE_NAME} ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest
                        
                        # Attendre que le container démarre complètement
                        echo "Attente du démarrage du container..."
                        sleep 5
                        
                        # Vérifier que le container fonctionne correctement
                        if docker ps | grep ${IMAGE_NAME} > /dev/null; then
                            echo "✅ Container démarré avec succès"
                            echo "📋 Informations du container :"
                            docker ps | grep ${IMAGE_NAME}
                            echo "📄 Logs récents :"
                            docker logs ${IMAGE_NAME} --tail 10
                        else
                            echo "❌ Erreur lors du démarrage du container"
                            echo "📄 Logs complets pour diagnostic :"
                            docker logs ${IMAGE_NAME} 2>/dev/null || echo "Aucun log disponible"
                            exit 1
                        fi
                    """

                    echo "✅ Déploiement terminé avec succès sur le port ${deployPort}"
                    echo "🌐 Application accessible sur : http://localhost:${deployPort}"
                    
                 
                    sh """
                        echo "🔍 Test de connectivité..."
                        sleep 3
                        if curl -f http://localhost:${deployPort} > /dev/null 2>&1; then
                            echo "✅ Application répond correctement"
                        else
                            echo "⚠️ L'application ne répond pas encore (peut nécessiter plus de temps)"
                        fi
                    """
                }
            }
        }
    }

    post {
        always {
            echo "🧹 Nettoyage de l'espace de travail..."
            cleanWs()
        }
        success {
            echo '✅ Pipeline exécuté avec succès !'
            echo '🎉 L\'application a été déployée correctement'
        }
        failure {
            echo '❌ Pipeline échoué !'
            script {
                // Nettoyer les containers en cas d'échec pour éviter les conflits futurs
                echo "🧹 Nettoyage des containers en cas d'échec..."
                sh """
                    if [ \$(docker ps -aq -f name=${IMAGE_NAME}) ]; then
                        echo "Suppression du container défaillant..."
                        docker stop ${IMAGE_NAME} || true
                        docker rm ${IMAGE_NAME} || true
                        echo "Nettoyage terminé"
                    fi
                """
            }
        }
    }
}