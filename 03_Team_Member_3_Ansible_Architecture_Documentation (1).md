## 👤 Team Member 3: Ansible, Jenkins Platform, draw.io Architecture, Documentation & AI-Usage Log

### 🎯 Your role

You prepare the Jenkins automation server with **Ansible**, and you own the **full draw.io architecture picture**, the **complete solution documentation**, and the **compiled AI-usage log** required by the organizer.

Ansible configures **Jenkins EC2 only**. The web app runs on ECS Fargate (blue/green) behind an NGINX proxy — never on EC2.

> 🟢 Organizer: "All teams will require to provide full Architecture picture of whole solution — drawio (or alternative), completed work must include Full documentation." And: "All AI actions must be logged … input prompts in final presentation … which AI platform … which model/LLM … AI generated code blocks must be marked … explain how and why you used AI."

### 📦 Files you own
```
scripts/bootstrap.sh                 # Bash installation script (deliverable)
ansible/inventory/**
ansible/playbook.yml
ansible/roles/common/**
ansible/roles/docker/**
ansible/roles/jenkins/**
ansible/roles/awscli/**
ansible/roles/cloudwatch/**
docs/architecture.drawio             # editable source (BONUS-adjacent, mandatory)
docs/architecture.png                # exported picture (embedded in the app)
docs/architecture.md
docs/server-configuration.md
docs/security.md
docs/monitoring.md
docs/troubleshooting.md
docs/ai-usage/README.md              # compiled AI-usage log (all members)
docs/ai-usage/team-member-3.md
README.md
```

### 📥 What you need from others
**From TM1:** presentation-app + proxy descriptions; container port; health path; the SPA's AI-usage rendering hook.
**From TM2:** Jenkins EC2 details; AWS resource names; network/security flow; Terraform outputs; CloudWatch resources; **S3+DynamoDB** backend; Cloud Map + ALB.
**From TM4:** Jenkins plugins; pipeline stages; commands Jenkins runs; ECR/ECS release flow; **blue/green switch mechanism**; Jenkins Credentials setup; pipeline evidence.
**From everyone:** their `docs/ai-usage/<member>.md` entries (platform, model, prompts, how/why).

### 📤 What you give to others
**To TM4:** working Jenkins server; Docker + AWS CLI access for the Jenkins user; required plugins; CloudWatch Agent status.
**To the whole team:** architecture diagram + explanation; complete README; evidence checklist; troubleshooting guide; demo order; teardown checklist; **compiled AI-usage log** for the app.

### ✅ Ansible tasks

#### Step 1: Bash installation script + inventory
Write `scripts/bootstrap.sh` (deliverable) to bootstrap Ansible prerequisites on the control host, then create an inventory containing the Terraform-created Jenkins EC2. Keep keys/temp credentials/sensitive data **out of Git**.
**Checkpoint S1 with TM2:** Ansible reaches the correct Jenkins EC2 in eu-west-1 via the approved method.

#### Step 2: Common role
Configure system updates (AL2023), Git, curl, jq, unzip, directories/permissions, service prerequisites.

#### Step 3: Docker role
Install + configure Docker for Jenkins builds; verify Docker runs as the Jenkins user per the agreed security model.
**Checkpoint S2 with TM4:** TM4 runs a harmless Docker command from a Jenkins job.

#### Step 4: Java + Jenkins role
Install a supported Java, then Jenkins; enable + start. Install **only** the plugins TM4 needs: Pipeline, Git, **GitHub integration (webhooks)**, **Credentials Binding**, Docker Pipeline, and AWS/ECR helpers as required.
**Checkpoint S3 with TM4:** TM4 can create + run a basic pipeline job and see the Credentials store.

#### Step 5: AWS CLI + tools role
Install AWS CLI + pipeline tools. Verify as the Jenkins user: Git works; Docker works; AWS CLI works; caller identity correct.
**Checkpoint S4 with TM2 & TM4:** TM2 confirms IAM identity; TM4 confirms CLI supports ECR push + ECS deploy + Cloud Map updates.

#### Step 6: CloudWatch Agent role (BONUS: logging)
Configure agreed Jenkins + system logs to CloudWatch; never log secrets.
**Checkpoint S5 with TM2:** fresh Jenkins log events appear in the expected CloudWatch location; alarms visible.

#### Step 7: Prove Ansible repeatability
Run syntax check → first run → second run (idempotent, minimal changes).
**Checkpoint S6 with the whole team:** Jenkins EC2 is reproducibly configured.

### 🖼️ Architecture tasks (draw.io — MANDATORY)

#### Step 8: Create the full draw.io diagram
`docs/architecture.drawio` (+ exported `architecture.png`) must include:
```
Developer workstation · GitHub repo · GitHub webhook
Jenkins EC2 (Amazon Linux 2023) · Jenkins Credentials (AWS keys, webhook secret)
Jenkins IAM role
Amazon ECR (app) · Amazon ECR (proxy)
Amazon ECS cluster
ECS task defs: app + nginx-proxy
ECS services: app-BLUE · app-GREEN · nginx-proxy   ← blue/green
Cloud Map / service discovery
AWS Fargate tasks
NGINX reverse proxy (front + switch)               ← bonus
Application Load Balancer · Target group
VPC · public/private subnets · security groups
CloudWatch Logs · metrics · ALARMS                 ← bonus
Terraform S3 backend · DynamoDB lock table         ← bonus
```
Label the flows: `git push`, `webhook`, `checkout`, `docker build`, `push image`, `pull image`, `deploy GREEN`, `health check`, `switch NGINX upstream`, `public HTTP request`, `logs & metrics`, `Terraform creates`, `Ansible configures`.
**Checkpoint S7 with TM2:** every AWS resource matches Terraform + the deployed environment.
**Checkpoint S8 with TM4:** every CI/CD arrow (incl. blue/green switch) matches the real pipeline.

#### Step 9: Complete documentation
Cover: project goal; organizer constraints (incl. **app-as-presentation**, **AI logging**); architecture picture + explanation; region + naming; repo structure; prerequisites; **credential + secret rules (Jenkins Credentials)**; **Terraform S3+DynamoDB backend**; Terraform deployment; Jenkins EC2 config via Ansible; presentation app + Docker; **NGINX reverse proxy**; Amazon ECR; **ECS + Fargate blue/green**; ALB + health checks; Jenkins pipeline; CloudWatch monitoring + alarms; successful deployment evidence; **blue/green failed-release evidence**; troubleshooting; **teardown (terraform destroy)**; **AI-usage log**; known limitations + design decisions (incl. NGINX-switch vs CodeDeploy).

#### Step 10: Compile the AI-usage log (MANDATORY, cross-cutting)
Gather every member's `docs/ai-usage/<member>.md` into `docs/ai-usage/README.md`. Each entry must include: **AI platform**, **model/LLM**, the **exact input prompts**, what was produced, review notes, and **how & why** AI was used. Confirm every AI-generated code block across the repo carries the standard "Generated by AI" marker (platform + model). Provide the compiled content to TM1 for the app's **AI Usage** section.
**Checkpoint (AI) with the whole team:** no unmarked AI block remains; all prompts + platform/model captured.

#### Step 11: Owner reviews
- TM1 reviews app + Docker + proxy sections.
- TM2 reviews AWS, Terraform, IAM, network, monitoring, teardown sections.
- TM4 reviews Jenkins, ECR, ECS blue/green, smoke test, evidence sections.
**Checkpoint S9:** each owner approves their section.

#### Step 12: Presentation materials
Because the **app is the presentation**, ensure the exported `architecture.png` and the compiled AI-usage content are embedded in TM1's SPA. Prepare: concise demo script; screenshot/evidence checklist; **fallback evidence** if a live step fails; final cleanup checklist.
**Checkpoint S10 with the whole team:** all four can explain the full architecture, not only their own component.

### 🤝 Collaboration summary

| Checkpoint | Collaborator | Result |
|---|---|---|
| S1 | TM2 | Correct Jenkins EC2 reached; bootstrap script works |
| S2–S4 | TM4 | Jenkins can build + access AWS (ECR/ECS/Cloud Map) |
| S5 | TM2 | CloudWatch logs + alarms verified |
| S6 | Whole team | Ansible idempotency demonstrated |
| S7 | TM2 | draw.io matches AWS |
| S8 | TM4 | draw.io matches CI/CD + blue/green |
| AI | Whole team | AI-usage compiled; all blocks marked |
| S9–S10 | Whole team | Docs + presentation approved |

### 🏁 Definition of Finished
- Jenkins EC2 fully configured by Ansible; Docker + AWS CLI work for the Jenkins user; required plugins installed; second run idempotent.
- CloudWatch receives agreed Jenkins logs; alarms exist.
- **draw.io** diagram shows the complete solution incl. NGINX proxy, blue/green, S3+DynamoDB, alarms — and clearly shows the app runs on **Fargate, not EC2**.
- No Docker Hub / Kubernetes / app-on-EC2 references remain.
- README covers deploy, operation, blue/green, troubleshooting, monitoring, **AI usage**, and teardown.
- **AI-usage log compiled** (platform + model + prompts + how/why); all AI code blocks marked; rendered in the presentation app.
- Every owner has reviewed their section; presentation + fallback evidence ready.
