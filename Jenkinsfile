pipeline {
    agent none
    stages {
        stage('Maven Compile and SAST Spotbugs') {
            agent {
                label 'maven'
            }
            steps {
                sh 'mvn compile spotbugs:spotbugs'
                archiveArtifacts artifacts: 'target/site/spotbugs.html'
                archiveArtifacts artifacts: 'target/spotbugs.xml'
            }
        }
        stage('Secret Scanning') {
            agent {
                docker {
                    image 'trufflesecurity/trufflehog:latest'
                    args '-u root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint='
                }
            }
            steps {
                sh 'trufflehog --no-update filesystem . --json > trufflehogscan.json'
                sh 'cat trufflehogscan.json'
                archiveArtifacts artifacts: 'trufflehogscan.json'
            }
        }
        stage('Build Docker Image') {
            agent {
                docker {
                    image 'docker:dind'
                    args '-u root -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                sh 'docker build -t vulnerable-java-application:0.1 .'
            }
        }
        stage('Run Docker Image') {
            agent {
                label 'built-in'
            }
            steps {
                sh 'docker rm --force vulnerable-java-application'
                sh 'docker run --name vulnerable-java-application -p 9000:9000 -d vulnerable-java-application:0.1'
            }
        }
        stage('DAST') {
            agent {
                docker {
                    image 'zaproxy/zap-stable'
                    args '-u root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint= -v .:/zap/wrk/:rw'
                }
            }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh 'zap-full-scan.py -t https://172.19.0.3:9000 -r zap-full-report.html -x zap-full-report.xml'
                }
                sh 'cp /zap/wrk/zap-full-report.html ./zap-full-report.html'
                sh 'cp /zap/wrk/zap-full-report.xml ./zap-full-report.xml'
                archiveArtifacts artifacts: 'zap-full-report.html'
                archiveArtifacts artifacts: 'zap-full-report.xml'
            }
        }
    }
}