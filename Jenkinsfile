pipeline {
    agent {
        label 'docker-agent'
    }
    stages {
        stage('Get Source') {
            steps {
                sh 'ls'
                sh 'pwd'
            }
        }
        stage('Build') {
            steps {
                script {
                    sh 'cd client'
                    docker.build('frontend:${BUILD_ID}')
                    sh 'docker images'
                }
            }
        }
    }
}
