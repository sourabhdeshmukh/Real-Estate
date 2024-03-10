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
                    def version = ${BUILD_ID}
                    docker.build('frontend:${version}')
                }
            }
        }
    }
}
