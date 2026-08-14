# DevOps Capstone — Automated AWS Container Deployment

This repository contains the DevOps capstone for Team 3: a small presentation web application built as a Docker image, published to Amazon ECR, and deployed to Amazon ECS (Fargate) using infrastructure managed by Terraform. Jenkins on an EC2 instance runs the CI/CD pipeline. Ansible configures the Jenkins host.

This README is a concise, actionable reference for reviewers and mentors: what the project is, how to run and verify it, what is done, and what remains.

---

## Status (current)

- Pipeline: Jenkins builds, tests, and pushes Docker images to ECR — verified in the latest run (example build `13-7e6579a`).
- Infrastructure: Terraform includes a remote S3 backend + DynamoDB lock table (configured in `terraform/backend.tf` and created by `terraform/bootstrap`).
- Runtime: the app runs on ECS Fargate as a single service behind an ALB.
- Known blocker: Jenkins' EC2 instance role currently lacks `ecs:UpdateService` permission, so the pipeline cannot complete automated ECS updates until the IAM permission is granted. See `docs/MENTOR_UPDATE.md` for details and evidence.

---

## Quick links

- Mentor update: `docs/MENTOR_UPDATE.md`
- Presentation script: `docs/PRESENTATION_SCRIPT.md`
- Terraform backend: `terraform/backend.tf`
- Terraform bootstrap: `terraform/bootstrap/main.tf`
- Jenkins pipeline: `Jenkinsfile`
- App files: `app/`, `docker/Dockerfile`

---

## Prerequisites (for reviewers)

- Git
- Docker (for local image build/testing)
- Terraform >= 1.5 (to initialize the backend and plan/apply)
- AWS CLI configured with credentials that can read/write the target account (for verification commands)
- Access to the Jenkins instance (web UI) if you want to review logs live

---

## Local development — build & test image

Run locally to verify the presentation image builds and serves the static site:

```bash
# build image locally (same script Jenkins uses)
bash scripts/build-image.sh

# test image locally (script starts a container and checks /health and /version)
bash scripts/test-image.sh
```

Notes: `scripts/build-image.sh` will skip a proxy image build if no proxy Dockerfile exists.

---

## CI / Jenkins

- The `Jenkinsfile` implements stages: Checkout, Validate, Prepare Build (tags with `BUILD_NUMBER-short_sha`), Build Images, Test Image, Security Scan, Verify AWS Identity, Push to ECR, Deploy (disabled by default), Health checks, Smoke tests, Archive evidence.
- Jenkins environment variables and sensitive values should be stored in **Jenkins Credentials** as documented in the project notes.

To run the automated deploy stage, set `DEPLOY_ENABLED=true` in the Jenkins job's environment or credentials and make sure the Jenkins EC2 instance role has the required IAM permissions (see Known blocker below).

---

## Terraform & remote state (S3 + DynamoDB)

The project uses a remote S3 backend with DynamoDB locking. Files of interest:

- `terraform/backend.tf` — backend configuration (bucket name, key, region, dynamodb_table).
- `terraform/bootstrap/main.tf` — resources that create the S3 bucket and DynamoDB lock table.

To initialize Terraform and confirm the backend is configured (capture output for evidence):

```bash
cd terraform
terraform init -reconfigure
# (optional) pull remote state if it exists
terraform state pull > remote_state.json
```

If you can access the AWS account, you may also run:

```bash
aws s3api head-object --bucket <bucket-name-from-backend> --key <key-from-backend> --region eu-west-1
aws dynamodb describe-table --table-name <dynamodb-table-from-backend> --region eu-west-1
```

---

## How to verify deployment & evidence to present

- Check Jenkins console log for the latest build number and ECR push lines (`ECR push completed`).
- Check ECR for the pushed tags (`13-...` and `latest`).
- Use the ALB URL to open the presentation SPA; verify `/health.html` and `/version.json`.
- Save outputs from `terraform init` and (if possible) `terraform state pull` as proof of remote state.

Example useful commands for a mentor demo (copy these):

```bash
# show backend config
cat terraform/backend.tf

# show latest version.json from repo (what the app should return)
cat app/version.json

# check ECR (requires AWS creds)
aws ecr describe-images --repository-name bootcamp-app-team3 --region eu-west-1 --query 'imageDetails[?contains(join(`,`, imageTags), `13`)]'

# Jenkins: open the job console and show build log where `ECR push completed` appears
```

---

## Known issues and next steps

1. Permission fix (high priority): grant the Jenkins EC2 instance role permission to call `ecs:UpdateService` and `ecs:DescribeServices` and `iam:PassRole` so Jenkins can update ECS services. After granting, re-run the Jenkins job.

2. Optional cleanup & polish:
  - Remove proxy / blue-green placeholders from `Jenkinsfile` if you decide not to implement them.
  - Add `alb_dns_name` to Terraform outputs for easier demo linking.
  - Compile the AI-usage docs into `docs/ai-usage/README.md` and embed them in the SPA.

---

## Contributing / Contact

If you are a mentor or reviewer and need any additional commands or saved output for verification (Terraform init, `terraform state pull`, Jenkins console logs, or AWS CLI outputs), ask and we will provide them.

Team contacts: See `docs/` for member responsibilities and the presentation script.

---

## License

See repository license (if any). If not present, assume course-use only.
