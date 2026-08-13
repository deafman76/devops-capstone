pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-west-1'
        COLOR = 'green'
        APP_PORT = '8080'
        APP_HEALTH_PATH = '/health.html'
        APP_VERSION_PATH = '/version.json'
        ALB_URL = 'https://placeholder-alb.example.com'
        APP_SERVICE_GREEN = 'app-green'
        PROXY_SERVICE = 'nginx-proxy'
        ECR_APP_REPO = 'placeholder-app-repo'
        ECR_PROXY_REPO = 'placeholder-proxy-repo'
    }

    options {
        timestamps()
        timeout(time: 60, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git --no-pager status --short'
            }
        }

        stage('Validate') {
            steps {
                sh 'bash scripts/validate.sh'
            }
        }

        stage('Prepare Build') {
            steps {
                script {
                    env.SHORT_SHA = sh(script: 'git rev-parse --short=7 HEAD', returnStdout: true).trim()
                    env.BUILD_TAG = "${env.BUILD_NUMBER}-${env.SHORT_SHA}"
                    env.APP_IMAGE = "${env.ECR_APP_REPO}:${env.BUILD_TAG}"
                    env.PROXY_IMAGE = "${env.ECR_PROXY_REPO}:${env.BUILD_TAG}"
                }
                sh 'bash scripts/prepare-build.sh'
            }
        }

        stage('Build Images') {
            steps {
                sh 'bash scripts/build-image.sh'
            }
        }

        stage('Test Image') {
            steps {
                sh 'bash scripts/test-image.sh'
            }
        }

        stage('Security Scan') {
            steps {
                sh 'echo "Security scan placeholder: no secrets in repository, image scan to be configured here."'
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-ci-credentials',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh 'bash scripts/push-ecr.sh'
                }
            }
        }

        stage('Deploy Green') {
            steps {
                sh 'bash scripts/deploy-green.sh'
            }
        }

        stage('Health Check Green') {
            steps {
                sh 'bash scripts/health-check.sh'
            }
        }

        stage('Switch Proxy') {
            steps {
                sh 'bash scripts/switch-proxy.sh'
            }
        }

        stage('Smoke Test') {
            steps {
                sh 'bash scripts/smoke-test.sh'
            }
        }

        stage('Scale Down Blue') {
            steps {
                sh 'bash scripts/scale-down-blue.sh'
            }
        }

        stage('Archive Evidence') {
            steps {
                archiveArtifacts artifacts: 'app/version.json, **/*.log', allowEmptyArchive: true
                sh 'echo "Pipeline evidence archived for build ${BUILD_TAG}"'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo "Deployment successful: ${env.BUILD_TAG}"
        }
        failure {
            echo "Pipeline failed for build ${env.BUILD_TAG}. Blue remains live; no proxy switch should occur on failure."
        }
    }
}
