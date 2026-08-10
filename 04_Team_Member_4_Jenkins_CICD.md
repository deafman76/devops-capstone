> **Region:** Europe (Ireland), AWS region code `eu-west-1`.  
> **Team size:** 5 people.  
> **Shared repository:** `devops-capstone`.  
> **Recommended beginner-friendly design:** two Amazon Linux 2023 EC2 instances, one for Jenkins and one for the application with k3s Kubernetes.  
> **Never commit passwords, tokens, private keys, `.tfstate`, kubeconfig, or Jenkins secrets to Git.

# 👤 Team Member 4: GitHub, Jenkins CI/CD, Docker Hub, and Release Automation

## 🎯 Your mission

You own the automated journey from Git commit to a tested, versioned Docker image and a verified release.  
You do not own AWS networking or manual server configuration.  
Keeping pipeline commands in small scripts makes testing easier for a beginner team.

## 📦 Files you own

```text
Jenkinsfile
scripts/validate.sh
scripts/build-image.sh
scripts/test-image.sh
scripts/push-image.sh
scripts/deploy-candidate.sh
scripts/switch-traffic.sh
scripts/rollback.sh
scripts/destroy-request.sh
docs/pipeline.md
```

## 🔗 Inputs you need

- **From Team Member 1:** Dockerfile, image port, health endpoint, and metadata placeholders.
- **From Team Member 2:** Jenkins URL and approved AWS identity arrangement.
- **From Team Member 3:** installed Jenkins plugins, Docker access, and kubeconfig method.
- **From Team Member 5:** Kubernetes names, blue/green labels, NodePort, and scan thresholds.

## 📤 Outputs you give

- **To Team Member 1:** exact build variables and image-tag format.
- **To Team Member 5:** immutable image tag, candidate slot, deployment logs, smoke-test result, and rollback evidence.
- **To Team Member 2:** a controlled request to destroy infrastructure, never an unreviewed automatic destroy.

# ✅ Step-by-step tasks

## Step 1: Agree the release contract

Use:

```text
Image repository: <dockerhub-user>/devops-capstone
Image tag: <BUILD_NUMBER>-<SHORT_GIT_SHA>
Namespace: capstone
Deployments: web-blue and web-green
Stable Service: web-active
Health path: /health.html
Public path: http://<app-public-ip>/
```

**Checkpoint P1:** Team Members 1 and 5 sign off on these exact names before pipeline coding.

## Step 2: Create Jenkins credentials

Add Docker Hub username and access token to Jenkins Credentials.  
Add GitHub credentials and webhook secret as required by the selected Jenkins GitHub integration.  
Do not print secrets to the console.

Suggested IDs:

```text
dockerhub-credentials
github-token
github-webhook-secret
```

**Checkpoint P2:** Team Member 5 confirms no credential value exists in Git or visible pipeline logs.

## Step 3: Create a pipeline skeleton

Use these stages:

```text
Checkout
Validate
Security checks
Build image
Test image
Scan image
Push image
Find inactive slot
Deploy candidate
Candidate health check
Switch traffic
Public smoke test
Archive evidence
```

**Checkpoint P3:** Jenkins can check out the repository and run a harmless validation stage.

## Step 4: Add build metadata

During the build, derive:

```bash
SHORT_SHA=$(git rev-parse --short HEAD)
IMAGE_TAG="${BUILD_NUMBER}-${SHORT_SHA}"
```

Replace the application placeholders in the Jenkins workspace, not permanently in source files.

## Step 5: Validate before building

Run the team-approved checks:

```text
Terraform formatting and validation without apply
Ansible syntax check
Kubernetes manifest validation
Secret scan
Configuration scan
```

Stop the pipeline if a required gate fails.

## Step 6: Build and test the image

```bash
docker build -f docker/Dockerfile -t "${DOCKER_IMAGE}:${IMAGE_TAG}" .
docker run -d --name capstone-test -p 18080:8080 "${DOCKER_IMAGE}:${IMAGE_TAG}"
curl --retry 10 --retry-delay 2 --fail http://127.0.0.1:18080/health.html
docker rm -f capstone-test
```

**Checkpoint P4:** Team Member 1 confirms the version endpoint contains the correct build metadata.

## Step 7: Push the immutable image

Use Jenkins credentials binding and `docker login --password-stdin`.  
Push the immutable build tag.  
Use the immutable tag in Kubernetes rather than relying on `latest`.

## Step 8: Find the inactive slot

Read the active `slot` selector from the stable Service.  
If blue is active, deploy green. If green is active, deploy blue.

**Checkpoint P5:** Team Member 5 verifies the script never updates the currently active Deployment first.

## Step 9: Deploy the candidate

Update the inactive Deployment to the immutable image tag.  
Wait for Kubernetes rollout status.  
Test the candidate directly before traffic switching.

**Checkpoint P6:** candidate rollout and candidate health check both succeed.

## Step 10: Switch traffic

Patch the stable Service selector from the old slot to the candidate slot only after P6.  
Record the previous slot for rollback.

## Step 11: Run public smoke test

```bash
curl --retry 10 --retry-delay 3 --fail http://<app-public-ip>/health.html
curl --fail http://<app-public-ip>/version.json
```

**Checkpoint P7:** Team Member 5 confirms public health and correct release metadata.

## Step 12: Roll back on failure

If the post-switch smoke test fails, restore the previous Service selector.  
Mark the Jenkins build failed and archive diagnostics.  
Do not destroy the previously healthy Deployment immediately.

**Checkpoint P8:** Team Members 1 and 5 witness one controlled failed release where the live application remains healthy.

## Step 13: Configure GitHub webhook

Configure the repository webhook endpoint required by the installed Jenkins GitHub plugin.  
Use the agreed webhook secret.  
Push a harmless README change and verify one build starts.

**Checkpoint P9:** GitHub reports successful delivery and Jenkins starts exactly one expected build.

## Step 14: Keep destroy controlled

The normal application pipeline must not destroy infrastructure after every push.  
Use a separate, manually authorized destroy job or parameter that produces a destroy plan for Team Member 2 to review.

**Checkpoint P10:** Team Members 2 and 5 review the destroy plan before any apply.

# 🤝 Collaboration map

| Checkpoint | Collaborator | What is verified |
|---|---|---|
| P1 and P4 | Team Member 1 | Image, metadata, port, and health contract |
| P2 | Team Member 5 | Secret handling and log safety |
| P3 | Team Member 3 | Jenkins host and tools work |
| P5 to P8 | Team Member 5 | Kubernetes deployment, switch, and rollback |
| P10 | Team Members 2 and 5 | Reviewed and safe teardown |

# 🏁 Your Definition of Finished

- A GitHub push triggers Jenkins.
- Required validation and security gates run before deployment.
- Jenkins creates and pushes an immutable image tag.
- Jenkins deploys only to the inactive slot first.
- Traffic switches only after a candidate health check.
- Public smoke testing verifies the release.
- Failed release testing proves rollback or no-switch behavior.
- Pipeline evidence is archived.
- Infrastructure destruction requires a separate reviewed action.
