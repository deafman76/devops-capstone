## 👤 Team Member 4: GitHub Webhook, Jenkins CI/CD, ECR, Blue/Green ECS Deployment & Demo

### 🎯 Your role

You connect everyone's work into one automatic delivery process. Your pipeline takes a GitHub change, builds and tests the **presentation app** and **NGINX proxy** images, versions them with the **Jenkins build number**, stores them in **Amazon ECR**, deploys the **GREEN** color, health-checks it, and **switches the NGINX proxy to GREEN only after success** — then verifies the public app through the **ALB**.

You use **no Docker Hub** and **no Kubernetes**. Secrets live in **Jenkins Credentials**.

### 🔄 Your complete flow
```
GitHub push
→ Jenkins webhook                                   ← BONUS webhook
→ checkout code
→ validate project
→ prepare metadata (VERSION, GIT_COMMIT, BUILD_NUMBER, COLOR=green)
→ build app image + proxy image
→ test app container locally (health + version)
→ security scan (secrets + image vulns)
→ tag image: BUILD_NUMBER-<short_git_sha>           ← BONUS versioning
→ ECR login via Jenkins Credentials (AWS)           ← BONUS Jenkins Credentials
→ push images to Amazon ECR                          ← no Docker Hub
→ deploy GREEN Fargate service (new task revision)
→ wait for GREEN health check to pass                ← BONUS blue/green (health-gated)
→ switch NGINX proxy upstream → GREEN
→ smoke test ALB URL (/, /health.html, /version.json)
→ scale down BLUE (keep warm briefly for rollback)
→ archive evidence
```

### 📦 Files you own
```
Jenkinsfile
scripts/validate.sh
scripts/prepare-build.sh          # injects VERSION/GIT_COMMIT/BUILD_NUMBER/COLOR
scripts/build-image.sh            # builds app + proxy
scripts/test-image.sh
scripts/push-ecr.sh
scripts/deploy-green.sh           # deploy new color
scripts/health-check.sh           # direct health check of GREEN
scripts/switch-proxy.sh           # flip NGINX upstream after success
scripts/smoke-test.sh
scripts/scale-down-blue.sh
docs/pipeline.md
docs/release-process.md
docs/demo-script.md
docs/ai-usage/team-member-4.md
```

### 📥 What you need from others
**From TM1:** app + proxy Dockerfile paths; build context; container port; health/version paths; metadata placeholders (incl. `__COLOR__`).
**From TM2:** AWS region; ECR URIs (app+proxy); ECS cluster; blue/green/proxy service names; task families; container names; **ALB URL**; **Cloud Map DNS** for color switching; Jenkins IAM permissions.
**From TM3:** Jenkins URL; required plugins; Docker + AWS CLI access; logging/evidence locations.

### 📤 What you give to others
**To TM1:** image tag format; build variables; container test results; how the SPA reads `__COLOR__`.
**To TM2:** required ECR/ECS/Cloud Map permissions; expected Terraform outputs; image tag per deploy.
**To TM3:** actual pipeline stages; success + failed-release (blue/green rollback) evidence; demo sequence.

### ✅ Tasks

#### Step 1: Integration contract
Record region; ECR URIs; ECS cluster; blue/green/proxy service names; task families; container names; port; health/version paths; ALB URL; Cloud Map DNS; image tag format; **Jenkins credential IDs (values excluded)**: `aws-ci-credentials`, `github-webhook-secret`. Use placeholders until TM1/TM2 finalize values.
**Checkpoint P1 with TM1 & TM2:** all image, ECS, port, path, naming, and switch values match.

#### Step 2: Jenkinsfile skeleton
Create stages: `Checkout · Validate · Prepare Build · Build Images · Test Image · Security Scan · Push to ECR · Deploy Green · Health Check Green · Switch Proxy · Smoke Test · Scale Down Blue · Archive Evidence`. First version may print safe explanatory output.
**Checkpoint P2 with TM3:** Jenkins loads the Jenkinsfile and runs the safe skeleton.

#### Step 3: Image versioning (BONUS)
Tag = `BUILD_NUMBER-<short_git_sha>` (e.g., `27-a1b2c3d`), immutable in ECR. Inject the same values (+ `COLOR`) into the app metadata before building so `/version.json` matches the pushed tag.
**Checkpoint P3 with TM1:** the version endpoint shows the same tag pushed to ECR.

#### Step 4: Build + test locally in Jenkins
Build app + proxy images; start a temporary app container; call `/health.html` + `/version.json`; stop/remove; fail clearly on any check failure.
**Checkpoint P4 with TM1 & TM3:** TM1 confirms behavior; TM3 confirms Docker works as the Jenkins user.

#### Step 5: Security checks
Check for accidental secrets; scan the Docker image for vulnerabilities; check config issues. Document which findings fail vs. are accepted (with reasons).
**Checkpoint P5 with TM3:** no secret value appears in Git, the Jenkinsfile, screenshots, or console output.

#### Step 6: Jenkins Credentials + ECR push (BONUS: Jenkins Credentials)
Store **AWS access keys** for a dedicated CI IAM identity and the **GitHub webhook secret** in **Jenkins Credentials**. The pipeline uses `Credentials Binding` to authenticate to ECR (no Docker Hub). Determine the registry address; obtain ECR auth; tag with the full ECR URI; push immutable tags (app + proxy); record image URIs in evidence.
**Checkpoint P6 with TM2:** one versioned image per repo appears in the correct private ECR; credentials never printed.

> 🟡 The bonus literally says "Docker Hub credentials + AWS credentials in Jenkins Credentials." Docker Hub is banned, so we satisfy the bonus by storing **AWS credentials** (and the webhook secret) in Jenkins Credentials. Recorded as a design decision. (IAM instance role is the more secure alternative and is documented.)

#### Step 7: Blue/green deploy — deploy GREEN (BONUS)
Register a new task revision for the **GREEN** service using the new ECR image; update `app-green`. Preserve Terraform-defined settings; change only release data. Record old/new revisions, new image URI, and service result. **BLUE keeps serving public traffic** at this point.
**Checkpoint P7 with TM2:** `app-green` starts Fargate tasks with the new image while `app-blue` still serves.

#### Step 8: Health-check GREEN, then switch NGINX (BONUS: switch after success)
`health-check.sh` calls GREEN **directly** (via Cloud Map DNS) until healthy or timeout. **Only on success**, `switch-proxy.sh` reconfigures the NGINX proxy upstream to GREEN and reloads/redeploys the proxy. On failure: mark build failed, collect ECS events + CloudWatch info, **do not switch**, keep BLUE live.
**Checkpoint P8 with TM3:** failure evidence is understandable in the docs; no-switch-on-failure is proven.

#### Step 9: Public smoke test + scale down BLUE
Call the ALB URL: `/`, `/health.html`, `/version.json`; verify the public version + color match the new build. Then scale down BLUE (keep briefly warm for rollback).
**Checkpoint P9 with the whole team:** all four see the GitHub change appear in the public Fargate app, now served by GREEN.

#### Step 10: GitHub webhook (BONUS)
Configure the repo webhook to trigger Jenkins on push, using the **webhook secret from Jenkins Credentials**. Verify one push → one build.
**Checkpoint P10 with TM3:** webhook + trigger evidence recorded without exposing secrets.

#### Step 11: Prepare the demo
Live section: visible change to the **presentation app** → git push → webhook → build + local test → ECR tag → GREEN deploy → health check → **NGINX switch** → ALB health → public version/color change. Provide screenshots / saved console output as fallback.
**Checkpoint P11 with TM3:** pipeline + architecture docs describe exactly the same flow (incl. blue/green switch).

#### Step 12: Stop automation before teardown
Before TM2 destroys: disable the webhook/job; confirm no build running; save final evidence; confirm no deploy in progress.
**Checkpoint P12 with TM2 & TM3:** TM2 gets teardown approval; TM3 confirms docs + evidence complete.

#### Step 13: AI-usage logging (MANDATORY)
Maintain `docs/ai-usage/team-member-4.md` (platform, model/LLM, exact prompts, how/why). Mark AI-generated pipeline/script code:
```groovy
// === AI-GENERATED (Generated by AI) ===
// Platform: <e.g., Microsoft Copilot>
// Model/LLM: <e.g., Claude / GPT-4o>
// Reviewed & adapted by: Team Member 4
// === END AI-GENERATED ===
```

### 🤝 Collaboration summary

| Checkpoint | Collaborator | Result |
|---|---|---|
| P1 | TM1 & TM2 | Runtime, AWS, and switch contract fixed |
| P2 | TM3 | Jenkinsfile skeleton runs |
| P3–P4 | TM1 & TM3 | Versioned metadata + local test work |
| P5 | TM3 | Secret-safe pipeline confirmed |
| P6 | TM2 | Jenkins Credentials + ECR push work |
| P7–P8 | TM2 & TM3 | Blue/green deploy + health-gated switch work |
| P9 | Whole team | End-to-end release witnessed (GREEN live) |
| P10–P11 | TM3 | Webhook + docs aligned |
| P12 | TM2 & TM3 | Safe teardown approved |

### 🏁 Definition of Finished
- A GitHub push triggers Jenkins via **webhook**.
- Jenkins validates, builds + locally tests the container, and runs security checks.
- Images carry an **immutable Jenkins-build-number + Git tag** and are pushed to **private Amazon ECR** (no Docker Hub).
- **AWS credentials + webhook secret stored in Jenkins Credentials.**
- Jenkins deploys **GREEN**, health-checks it, and **switches the NGINX proxy to GREEN only after success**; a failed candidate never takes public traffic (BLUE stays live).
- Jenkins smoke-tests the ALB URL; public version + color match the ECR tag.
- Deployment + failed-release (rollback) evidence archived.
- Docker Hub and Kubernetes are absent from the pipeline.
- Automation is stopped safely before teardown; **AI usage logged** and pipeline AI blocks marked.
