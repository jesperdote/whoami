pipeline {
    agent { label 'bananapi' }

    options {
        disableConcurrentBuilds()
        timeout(time: 10, unit: 'MINUTES')
    }

    environment {
        REPO_DIR = '/home/jenkins/repos/whoami'
    }

    stages {
        // No cross-arch build needed here (unlike blog/zola) - the Dockerfile is a
        // plain nginx:alpine build that runs fine directly on the BananaPi's armv7,
        // so build and deploy both happen in a single stage on that agent.
        stage('Deploy') {
            steps {
                dir("${REPO_DIR}") {
                    sh 'git pull origin main'
                    sh 'docker-compose -f docker-compose.prod.yml up -d --build --force-recreate'
                }
            }
        }
    }

    post {
        failure {
            echo "Deploy failed — check docker compose logs on the BananaPi."
        }
    }
}
