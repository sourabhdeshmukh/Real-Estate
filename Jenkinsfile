pipeline {
    agent any
    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub' // Credential ID in Jenkins for Docker Hub login
    }
    stages {
        stage('Download Source') {
            steps {
                sh 'rm -rf $PWD/*'
                sh 'git clone https://github.com/sourabhdeshmukh/Real-Estate'
            }
        }
        stage('Analysis of source code') {
            steps {
              sh 'wget https://github.com/insidersec/insider/releases/download/2.1.0/insider_2.1.0_linux_x86_64.tar.gz'
              sh 'tar -xf insider_2.1.0_linux_x86_64.tar.gz'
              sh 'chmod +x insider'
              sh './insider --tech javascript  --target $PWD/Real-Estate'
              sh 'mv *.html insider.html'
            }
        }
        stage('Build') {
                parallel {
                    stage('Build Frontend') {
                        steps {
                            script {
                                docker.build('real-estate-frontend:latest', '-f ./Real-Estate/client/Dockerfile ./Real-Estate/client/')
                                sh 'docker tag real-estate-frontend:latest sourabhdeshmukh/real-estate-frontend:${BUILD_ID}'
                            }
                        }
                    }
                    stage('Build Backend') {
                        steps {
                            script {
                                docker.build('real-estate-backend:latest', '-f ./Real-Estate/server/Dockerfile ./Real-Estate/server/') 
                                sh 'docker tag real-estate-backend:latest sourabhdeshmukh/real-estate-backend:${BUILD_ID}'
                            }
                        }
                    }
                }
        }
        stage('Security Checks') {
            steps {
                script {
                    sh 'trivy image sourabhdeshmukh/real-estate-frontend:latest --scanners vuln --format=json | tee -a trivy-frontend.json'
                    sh 'trivy image sourabhdeshmukh/real-estate-backend:latest --scanners vuln --format=json | tee -a trivy-backend.json'
                }
            }
        }
         stage('Push docker archives to Repository') {
             steps {
                 script {
                     withCredentials(
                        [usernamePassword(credentialsId: 'dockerhub', 
                            usernameVariable: 'USERNAME', 
                            passwordVariable: 'PASSWORD')]) {
                            sh 'docker login --username $USERNAME --password $PASSWORD'
                    }

                        sh 'docker push sourabhdeshmukh/real-estate-frontend:${BUILD_ID}'
                        sh 'docker push sourabhdeshmukh/real-estate-backend:${BUILD_ID}'
                        sh 'docker tag sourabhdeshmukh/real-estate-backend:${BUILD_ID} sourabhdeshmukh/real-estate-backend:latest'
                        sh 'docker tag sourabhdeshmukh/real-estate-backend:${BUILD_ID} sourabhdeshmukh/real-estate-backend:latest'
                        sh 'docker push sourabhdeshmukh/real-estate-frontend:latest'
                        sh 'docker push sourabhdeshmukh/real-estate-backend:latest'
                    }
                }
            }
        stage('Publish HTML report') {
            steps {
                // Publish the HTML report
                publishHTML(target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: '',
                    reportFiles: 'insider.html',
                    reportName: 'Insider Scan Report'
                ])
            }
        }
        stage('local filesystem cleanup') {
            steps {
               script {
                   sh "docker system prune"
               }
            }
        }
        stage('Proceed for deployment?') {
	       steps {
	           timeout(time: 15, unit: "MINUTES") {
	               input message: 'Do you want to approve the deployment?', ok: 'Yes'
	           }
	       }
        }
        stage('deploy the application') {
            steps {
                script {
                    if (env.option == 'new_deploy') {
                        sh "cd terraform"
                        sh "terraform apply -auto-approve"
                    } else {
                        echo 'The New build is not been deployed'
                    }
                }
            }
        }
    }
        post {
            success {
                script {
               def slackMessage = """
                    Jenkins Build ${currentBuild.fullDisplayName} has finished.
                    Result: ${currentBuild.currentResult}
                    Build URL: ${env.BUILD_URL}
                """
                slackSend channel: '#cicd', color: 'green', message: "Build Successful ${env.JOB_NAME} - ${env.BUILD_NUMBER}", teamDomain: 'cicd-pipelineworld', tokenCredentialId: 'slacktoken'
            }
                
            }
            failure {
                script {
                slackSend channel: '#cicd', color: 'red', message: "Build Failed ${env.JOB_NAME} - ${env.BUILD_NUMBER} Check the url for logs ${env.JENKINS_URL}:8080/job/Continuous_Integration_Continuous_Delivery/${env.BUILD_NUMBER}/", teamDomain: 'cicd-pipelineworld', tokenCredentialId: 'slacktoken'
            }
        }
            aborted {
                script {
                slackSend channel: '#cicd', color: 'red', message: "Build Failed ${env.JOB_NAME} - ${env.BUILD_NUMBER} Check the url for logs ${env.JENKINS_URL}/job/Continuous_Integration_Continuous_Delivery/${env.BUILD_NUMBER}/", teamDomain: 'cicd-pipelineworld', tokenCredentialId: 'slacktoken'
            }
            }
    }


}
