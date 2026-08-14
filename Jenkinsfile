pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-west-1'

        ECS_CLUSTER = 'bootcamp-ecs-cluster-team3'
        ECS_SERVICE = 'bootcamp-app-service'

        COLOR = 'green'
        APP_PORT = '8080'
        APP_HEALTH_PATH = '/health.html'
        APP_VERSION_PATH = '/version.json'

        ECR_APP_REPO = '597765856364.dkr.ecr.eu-west-1.amazonaws.com/bootcamp-app-team3'
    }

    options {
        timestamps()
        timeout(time: 60, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'CHECKOUT: retrieving latest source from GitHub.'
                checkout scm
                sh 'git --no-pager status --short'
            }
        }

        stage('Validate') {
            steps {
                echo 'VALIDATE: checking repository structure.'
                sh 'bash scripts/validate.sh'
            }
        }

        stage('Prepare Build') {
            steps {
                script {
                    env.SHORT_SHA = sh(
                        script: 'git rev-parse --short=7 HEAD',
                        returnStdout: true
                    ).trim()

                    env.BUILD_TAG = "${env.BUILD_NUMBER}-${env.SHORT_SHA}"
                    env.APP_IMAGE = "${env.ECR_APP_REPO}:${env.BUILD_TAG}"
                }

                sh 'bash scripts/prepare-build.sh'

                echo "BUILD VERSION: ${env.BUILD_TAG}"
                echo "APPLICATION IMAGE: ${env.APP_IMAGE}"
            }
        }

        stage('Build Image') {
            steps {
                echo "BUILD: creating ${env.APP_IMAGE}"
                sh 'bash scripts/build-image.sh'
            }
        }

        stage('Test Image') {
            steps {
                echo 'TEST: starting and validating the application image locally.'
                sh 'bash scripts/test-image.sh'
            }
        }

        stage('Security Scan') {
            steps {
                echo 'SECURITY: placeholder baseline check.'
                echo 'NOTE: full container vulnerability scanning is not configured yet.'
            }
        }

        stage('Verify AWS Identity') {
            steps {
                echo 'AWS: verifying Jenkins instance-role identity.'
                sh 'aws sts get-caller-identity --region "${AWS_REGION}"'
            }
        }

        stage('Push to ECR') {
            steps {
                echo "PUBLISH: pushing ${env.BUILD_TAG} and latest to ECR."
                sh 'bash scripts/push-ecr.sh'
                echo "PUBLISH COMPLETE: ${env.APP_IMAGE}"
            }
        }

        stage('Verify Published Image') {
            steps {
                echo "VERIFY ECR: checking ${env.BUILD_TAG}"

                sh '''
                    aws ecr describe-images \
                      --repository-name bootcamp-app-team3 \
                      --image-ids imageTag="${BUILD_TAG}" \
                      --region "${AWS_REGION}" \
                      --query 'imageDetails[0].{Digest:imageDigest,Tags:imageTags,Pushed:imagePushedAt}' \
                      --output json
                '''
            }
        }

        stage('Deploy to ECS') {
            steps {
                echo '============================================================'
                echo 'ECS DEPLOYMENT STARTING'
                echo "Cluster: ${env.ECS_CLUSTER}"
                echo "Service: ${env.ECS_SERVICE}"
                echo "Published build: ${env.BUILD_TAG}"
                echo 'Strategy: single-service rolling deployment'
                echo '============================================================'

                sh '''
                    aws ecs update-service \
                      --cluster "${ECS_CLUSTER}" \
                      --service "${ECS_SERVICE}" \
                      --force-new-deployment \
                      --region "${AWS_REGION}" \
                      --query 'service.{Service:serviceName,Desired:desiredCount,Running:runningCount,Pending:pendingCount}' \
                      --output table
                '''

                echo 'ECS DEPLOYMENT REQUEST ACCEPTED.'
            }
        }

        stage('Wait for ECS Stable') {
            steps {
                echo 'ECS: waiting for the service deployment to stabilize.'

                sh '''
                    aws ecs wait services-stable \
                      --cluster "${ECS_CLUSTER}" \
                      --services "${ECS_SERVICE}" \
                      --region "${AWS_REGION}"
                '''

                echo 'ECS SERVICE STABLE.'
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'VERIFY ECS: reading final service state.'

                sh '''
                    aws ecs describe-services \
                      --cluster "${ECS_CLUSTER}" \
                      --services "${ECS_SERVICE}" \
                      --region "${AWS_REGION}" \
                      --query 'services[0].{Service:serviceName,Desired:desiredCount,Running:runningCount,Pending:pendingCount,TaskDefinition:taskDefinition}' \
                      --output table
                '''

                echo "DEPLOYMENT VERIFIED FOR BUILD: ${env.BUILD_TAG}"
            }
        }

        stage('Archive Evidence') {
            steps {
                archiveArtifacts(
                    artifacts: 'app/version.json, **/*.log',
                    allowEmptyArchive: true
                )

                echo "EVIDENCE ARCHIVED: ${env.BUILD_TAG}"
            }
        }
    }

    post {
        always {
            echo '============================================================'
            echo 'PIPELINE FINISHED'
            echo "Build: ${env.BUILD_TAG ?: env.BUILD_NUMBER}"
            echo '============================================================'
        }

        success {
            echo 'RESULT: SUCCESS'
            echo "Git commit built successfully."
            echo "Image published: ${env.APP_IMAGE}"
            echo "ECS service: ${env.ECS_SERVICE}"
            echo 'ECS rolling deployment completed and service stabilized.'
        }

        failure {
            echo 'RESULT: FAILURE'
            echo "Pipeline failed for build ${env.BUILD_TAG ?: env.BUILD_NUMBER}."
            echo 'Check the first failed stage above.'
            echo 'Do not assume ECS changed unless the Deploy to ECS stage shows that the update request was accepted.'
        }
    }
}
