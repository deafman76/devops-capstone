# Jenkins Pipeline Plan

## Purpose

This pipeline is the Team Member 4 CI/CD contract for the capstone project. It is designed to run when the repository changes and to prepare for a controlled blue/green deployment to ECS Fargate behind an NGINX proxy.

## Stages

1. Checkout
2. Validate repository files and metadata placeholders
3. Prepare build metadata with a version tag based on Jenkins build number and Git SHA
4. Build the application image
5. Run local smoke tests in a temporary container
6. Security scanning placeholder and secret checks
7. Push images to Amazon ECR with Jenkins credentials
8. Deploy the GREEN service revision
9. Health-check GREEN directly
10. Switch the NGINX upstream to GREEN only after success
11. Smoke test the ALB endpoints
12. Scale down BLUE briefly for rollback readiness
13. Archive evidence

## Required Jenkins configuration

- Jenkins job must run from the repository root
- Required plugins: Pipeline, Git, Credentials Binding, Docker Pipeline, AWS/ECR helpers
- Jenkins credentials expected:
  - aws-ci-credentials
  - github-webhook-secret
- Build metadata is injected into app/version.json before building the app image
- The release tag format is BUILD_NUMBER-short_sha

## Environment variables used by the pipeline

- AWS_REGION = eu-west-1
- COLOR = green
- APP_SERVICE_GREEN = app-green
- PROXY_SERVICE = nginx-proxy
- ALB_URL = placeholder until Terraform completes
- ECR_APP_REPO = placeholder-app-repo
- ECR_PROXY_REPO = placeholder-proxy-repo

## Failure behavior

The pipeline must not switch the proxy on a failed health check or failed test. In that case, BLUE remains the public target and the Jenkins build is marked as failed.
