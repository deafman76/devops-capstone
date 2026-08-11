# Release Process

## Successful release

Set the integration-contract variables in Jenkins, then trigger the job from a GitHub push. Jenkins builds an immutable image tag in the form `BUILD_NUMBER-short_git_sha`, pushes it to private ECR, deploys green, verifies green directly, switches the proxy, smoke-tests the ALB, and scales blue down.

Evidence is archived from `.build` and `evidence/`. The expected success evidence includes `images.env`, `green-deployment.env`, `proxy-switch.env`, and `public-version.json`.

## Failed release

Use a candidate image that deliberately fails `/health.html` in a temporary branch or test build. `health-check.sh` exits non-zero, so Jenkins stops before `switch-proxy.sh`. Blue remains the public version. Capture the Jenkins console output and ECS service events as failed-release evidence, then remove the temporary branch.

## Rollback

Before scaling blue down, the previous blue task remains available. To roll back, restore the proxy task definition that points to blue, wait for the proxy service to stabilize, and smoke-test the ALB. Record the task definition ARN and public version in `evidence/`.

## Teardown prerequisite

Disable the GitHub webhook/job and verify no build or deployment is running before TM2 runs the reviewed Terraform destroy plan.
