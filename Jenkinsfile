pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Używamy poświadczenia GIT_PAT do klonowania repozytorium.
                // Klonujemy bezpośrednio do katalogu roboczego (workspace),
                // dzięki czemu pliki Dockerfile znajdują się w katalogu głównym.
                withCredentials([string(credentialsId: 'GIT_PAT', variable: 'GIT_PAT')]) {
                    sh "git clone https://${GIT_PAT}@github.com/xBartosh/Brick-Game-9999-in-1.git ."
                }
            }
        }
        stage('Build') {
            steps {
                script {
                    // Budujemy obraz na podstawie Dockerfile i zapisujemy logi
                    sh "docker build -f Dockerfile -t brick-game-build . > build.log 2>&1"
                    sh "mv build.log build-${env.BUILD_NUMBER}.log"
                    archiveArtifacts artifacts: "build-${env.BUILD_NUMBER}.log", fingerprint: true
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    // Budujemy obraz testowy na podstawie Dockerfile_test
                    sh "docker build -f Dockerfile_test -t brick-game-test . > test-build.log 2>&1"
                    sh "mv test-build.log test-build-${env.BUILD_NUMBER}.log"
                    archiveArtifacts artifacts: "test-build-${env.BUILD_NUMBER}.log", fingerprint: true

                    // Uruchamiamy kontener testowy; logi działania zapisujemy do pliku
                    sh "docker run --rm --name brick-game-test-container brick-game-test > test.log 2>&1"
                    sh "mv test.log test-${env.BUILD_NUMBER}.log"
                    archiveArtifacts artifacts: "test-${env.BUILD_NUMBER}.log", fingerprint: true
                }
            }
        }
    }
}
