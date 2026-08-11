# Jenkins Pipeline

Team Member 4 owns the release path from a GitHub push to the public ECS/Fargate presentation.

## Stages

1. Checkout source from GitHub.
2. Validate required application and Docker files.
3. Copy the application into `.build` and inject build number, Git SHA, version, and color.
4. Build the application image and, when present, the proxy image.
5. Run health and version checks against the local application container.
6. Scan source and the image with Trivy when installed.
7. Authenticate to private ECR through the Jenkins credential `aws-ci-credentials` and push `BUILD_NUMBER-short_git_sha` tags.
8. Register a green ECS task definition and wait for the green service to stabilize.
9. Call the green service directly. A failed check stops the build before traffic changes.
10. Register the proxy task definition pointing at green and wait for the proxy service.
11. Smoke-test the ALB root, health endpoint, and version endpoint.
12. Scale blue down only after the public smoke test passes.

## Jenkins configuration

Create these environment variables from Terraform outputs or Jenkins configuration:

- `AWS_DEFAULT_REGION`
- `ECR_REPOSITORY_APP`
- `ECR_REPOSITORY_PROXY`
- `ECS_CLUSTER_NAME`
- `ECS_SERVICE_BLUE`
- `ECS_SERVICE_GREEN`
- `ECS_SERVICE_PROXY`
- `ECS_TASK_FAMILY_APP`
- `ECS_TASK_FAMILY_PROXY`
- `ALB_URL`
- `GREEN_HEALTH_URL`
- `TASK_DEFINITION_FILE`
- `PROXY_TASK_DEFINITION_FILE`

Store AWS access key and secret key in Jenkins Credentials as `aws-ci-credentials`. Store the GitHub webhook secret as `github-webhook-secret`; do not put either value in Git or pipeline output.

The repository includes local task-definition templates under `deploy/` and the `Render Task Definitions` stage. Jenkins renders them into `.build/` using the ECR, IAM-role, logging, and service-discovery values supplied by TM2.
