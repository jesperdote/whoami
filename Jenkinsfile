def notifySlack(String status, String emoji, String url = '') {
    withCredentials([string(credentialsId: 'slack-webhook-url', variable: 'SLACK_WEBHOOK_URL')]) {
        def extra = url ? "\\n${url}" : ''
        sh """
            curl -s -X POST -H 'Content-type: application/json' \\
                --data '{"text":"${emoji} *${env.JOB_NAME}* #${env.BUILD_NUMBER} ${status}\\n${env.BUILD_URL}${extra}"}' \\
                "\$SLACK_WEBHOOK_URL"
        """
    }
}

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
        stage('Notify Start') {
            steps {
                script { notifySlack('started', ':large_blue_circle:') }
            }
        }

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
        success {
            script { notifySlack('succeeded', ':white_check_mark:', 'https://infdxeta.info/whoami/') }
        }
        failure {
            echo "Deploy failed — check docker compose logs on the BananaPi."
            script { notifySlack('failed', ':x:') }
        }
    }
}
