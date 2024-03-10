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
                    sh 'docker build -t frontend:${BUILD_ID}'
                    sh 'docker images'
                }
            }
        }
    }
}
