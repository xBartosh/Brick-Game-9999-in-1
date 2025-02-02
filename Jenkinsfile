pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Usuwamy folder 'repo' jeśli istnieje, aby uniknąć konfliktów
                sh 'rm -rf repo'
                // Klonujemy repozytorium do katalogu "repo" z wykorzystaniem poświadczenia GIT_PAT
                withCredentials([string(credentialsId: 'GIT_PAT', variable: 'GIT_PAT')]) {
                    sh "git clone https://${GIT_PAT}@github.com/xBartosh/Brick-Game-9999-in-1.git repo"
                }
            }
        }
        stage('Build') {
            steps {
                script {
                    // Budujemy obraz na podstawie pliku Dockerfile znajdującego się w katalogu "repo"
                    sh "docker build -f repo/Dockerfile -t brick-game-build repo > build.log 2>&1"
                    // Numerujemy plik loga builda wg numeru buildu
                    sh "mv build.log build-${env.BUILD_NUMBER}.log"
                    archiveArtifacts artifacts: "build-${env.BUILD_NUMBER}.log", fingerprint: true
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    // Budujemy obraz testowy na podstawie Dockerfile_test z katalogu "repo"
                    sh "docker build -f repo/Dockerfile_test -t brick-game-test repo > test-build.log 2>&1"
                    sh "mv test-build.log test-build-${env.BUILD_NUMBER}.log"
                    archiveArtifacts artifacts: "test-build-${env.BUILD_NUMBER}.log", fingerprint: true

                    // Uruchamiamy kontener testowy, zbieramy logi działania i zapisujemy je jako artefakt
                    sh "docker run --rm --name brick-game-test-container brick-game-test > test.log 2>&1"
                    sh "mv test.log test-${env.BUILD_NUMBER}.log"
                    archiveArtifacts artifacts: "test-${env.BUILD_NUMBER}.log", fingerprint: true
                }
            }
        }
    }
}
