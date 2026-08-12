# Demo Script

## Expected flow

1. Push a repository change.
2. Jenkins triggers a build.
3. Repository validation passes.
4. Metadata is prepared for the new version.
5. App image builds locally and health/version checks pass.
6. ECR login and image push occur using Jenkins credentials.
7. GREEN environment is deployed.
8. GREEN health check passes.
9. Proxy is switched to GREEN.
10. ALB smoke tests confirm the new version is public.
11. BLUE is scaled down and kept warm for rollback.

## Evidence to capture

- Jenkins build number
- Git SHA and released version tag
- App/version endpoint response
- ECR image tag in the repository
- GREEN health result
- Proxy switch result
- ALB smoke test result
- Any failed-build evidence for rollback scenarios
