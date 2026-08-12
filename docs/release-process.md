# Release Process

## Release contract

The version tag follows the format:

BUILD_NUMBER-short_git_sha

Example:

27-a1b2c3d

The same tag is stored in app/version.json for the built image, allowing the app to report its exact release metadata.

## Deployment flow

1. Build is triggered by repository change or Jenkins job run.
2. Repository validation checks for required app and Docker files.
3. Version metadata is prepared.
4. App image is built and local smoke tests confirm health and version endpoints work.
5. AWS credentials are used to log in to ECR and push immutable images.
6. GREEN service revision is deployed without touching BLUE public traffic.
7. GREEN is checked directly via service discovery or direct endpoint.
8. NGINX upstream is switched only after success.
9. Public smoke tests verify the ALB is serving the new version.
10. BLUE is scaled down after successful validation.

## Rollback plan

If GREEN fails the health check, the build is failed and the switch stage is skipped. BLUE stays live and the app remains on the previous working release.
