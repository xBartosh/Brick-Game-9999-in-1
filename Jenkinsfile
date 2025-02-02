pipeline {
    agent any

    environment {
        // Repozytorium w DockerHub (zmień wg własnych ustawień)
        DOCKERHUB_REPO = "xbartoshtest/brick"
    }

    stages {
        stage('Checkout') {
            steps {
                sh 'rm -rf repo'
                withCredentials([string(credentialsId: 'GIT_PAT', variable: 'GIT_PAT')]) {
                    sh "git clone https://${GIT_PAT}@github.com/xBartosh/Brick-Game-9999-in-1.git repo"
                }
            }
        }
        stage('Set Version') {
            steps {
                script {
                    // Ustalamy wersję semantyczną – tutaj przykładowo: 1.0.<BUILD_NUMBER>
                    def semanticVersion = "1.0.${env.BUILD_NUMBER}"
                    env.IMAGE_VERSION = semanticVersion
                    echo "Semantic Version set to: ${semanticVersion}"
                }
            }
        }
        stage('Build Deploy Container') {
            steps {
                script {
                    // Budujemy obraz na podstawie Dockerfile_deploy znajdującego się w katalogu "repo"
                    sh "docker build -f repo/Dockerfile_deploy -t brick-game-deploy repo > deploy-build.log 2>&1"
                    sh "mv deploy-build.log deploy-build-${env.BUILD_NUMBER}.log"
                    archiveArtifacts artifacts: "deploy-build-${env.BUILD_NUMBER}.log", fingerprint: true
                }
            }
        }
        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DOCKERHUB', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    // Logujemy się do DockerHub
                    sh "docker login -u $DOCKERHUB_USER -p $DOCKERHUB_PASS"
                    // Tagujemy obraz z ustaloną wersją semantyczną
                    sh "docker tag brick-game-deploy ${DOCKERHUB_REPO}:${IMAGE_VERSION}"
                    // Wysyłamy obraz do DockerHub
                    sh "docker push ${DOCKERHUB_REPO}:${IMAGE_VERSION}"
                }
            }
        }
        stage('Run Deployment') {
            steps {
                script {
                    // Uruchamiamy kontener z obrazem z DockerHub z użyciem tagu semantycznego
                    sh "docker run -d --name brick-game-deploy-container -p 8088:8088 ${DOCKERHUB_REPO}:${IMAGE_VERSION}"
                }
            }
        }
        stage('Smoke test') {
            steps {
                script {
                    // Czekamy, aż kontener w pełni wystartuje
                    sleep(time: 10, unit: 'SECONDS')
                    // Wysyłamy zapytanie curl do uruchomionej instancji
                    def deployResponse = sh(script: "curl -s http://localhost:8080/", returnStdout: true).trim()
                    // Zapisujemy wynik do pliku
                    writeFile file: "deploy-test-${env.BUILD_NUMBER}.log", text: deployResponse
                    // Archiwizujemy logi
                    archiveArtifacts artifacts: "deploy-test-${env.BUILD_NUMBER}.log", fingerprint: true
                }
            }
        }
    }
}
