## 👤 Team Member 2: AWS, Terraform, ECR, ECS Fargate (Blue/Green), NGINX Proxy Infra & Teardown

### 🎯 Your role

You own the AWS infrastructure in **eu-west-1**. You create everything with **Terraform** using a **remote S3 backend + DynamoDB state locking**, provide all outputs to the team, and perform the reviewed teardown.

The web application must **not** run on EC2. Jenkins runs on EC2; the web app runs on **AWS Fargate** as **blue + green** services behind an **NGINX reverse-proxy** service behind an **ALB**.

### 🏗️ Infrastructure you own
```
Terraform remote state (S3)               ← BONUS
DynamoDB state-lock table                 ← BONUS
VPC, public + private subnets
Internet Gateway, NAT (if needed), route tables
Jenkins EC2 instance + security group + IAM instance role
Amazon ECR private repo: app             ← no Docker Hub
Amazon ECR private repo: proxy           ← no Docker Hub
Amazon ECS cluster
ECS task execution role + task role
ECS task definition: app (blue) + app (green)
ECS task definition: nginx-proxy
ECS Fargate service: app-blue            ← BONUS blue/green
ECS Fargate service: app-green           ← BONUS blue/green
ECS Fargate service: nginx-proxy         ← BONUS reverse proxy
Cloud Map / service discovery for color resolution
Application Load Balancer + listener + target group
Security groups (ALB, proxy, app)
CloudWatch log groups (app, proxy, Jenkins)
CloudWatch alarms (ALB 5xx, unhealthy hosts, CPU)   ← BONUS
```

### 📦 Files you own
```
terraform/bootstrap/**        # S3 bucket + DynamoDB lock table
terraform/environment/**      # full environment
docs/aws-resources.md
docs/terraform-runbook.md
docs/teardown-runbook.md
docs/ai-usage/team-member-2.md
```

### 📥 What you need from others
**From TM1:** app container port; proxy port (80); health path; minimal CPU/memory; app + proxy container names.
**From TM3:** Jenkins OS/management requirements; CloudWatch log requirements; diagram review points.
**From TM4:** ECR + ECS + Cloud Map permissions Jenkins needs; required Terraform outputs; image tag format; how the pipeline flips the proxy upstream.

### 📤 What you give to others
**To TM3:** Jenkins EC2 instance ID + endpoint; region; IAM role name; security-group behavior.
**To TM4:** ECR URIs (app + proxy); ECS cluster name; blue/green/proxy service names; task-definition families; container names; region; **ALB URL**; Cloud Map namespace/DNS for color switching.

### ✅ Tasks

#### Step 1: Verify AWS access
Sign in with MFA; select **Europe (Ireland) eu-west-1**; verify caller identity; inspect existing EC2/VPC/ECR/ECS/S3/DynamoDB/CloudWatch resources; record anything not belonging to this project.
**Checkpoint T1 with TM3:** account + region recorded in docs; no credentials saved.

#### Step 2: Create the Terraform backend (BONUS: S3 + DynamoDB)
`terraform/bootstrap` creates:
- **S3 state bucket** (encryption, versioning, public-access block);
- **DynamoDB lock table** (`LockID` hash key) for state locking.
Create a plan and review before apply. The `environment` config then points its backend at this bucket + table.
**Checkpoint T2 with TM3:** the diagram includes the S3 backend + DynamoDB lock, separate from the app runtime.

#### Step 3: Create networking
Create VPC; public subnets (ALB + proxy); private subnets (app blue/green); IGW; route tables; associations; security groups.
Security intent:
```
Internet → ALB (port 80/443)
ALB → NGINX proxy (port 80)
NGINX proxy → app-blue / app-green (container port)
Approved admin path → Jenkins EC2
Jenkins → AWS APIs via IAM
```
**Checkpoint T3 with TM3 & TM4:** TM3 reviews the flow; TM4 confirms Jenkins can reach ECR/ECS/Cloud Map APIs.

#### Step 4: Create Jenkins EC2 (Amazon Linux 2023)
Create the Jenkins EC2 (**Amazon Linux 2023** AMI), its security group, IAM instance role, and CloudWatch resources; output for TM3. **No web app runs here.**
**Checkpoint T4 with TM3:** TM3 can connect and begin Ansible.

#### Step 5: Create Amazon ECR (app + proxy)
Create **two** private ECR repositories (app, proxy) with encryption, immutability (tag-immutable), optional lifecycle policy, and output the URIs. **Docker Hub must not appear anywhere.**
**Checkpoint T5 with TM4:** TM4 authenticates from Jenkins and pushes one immutable test image to each repo.

#### Step 6: Create ECS Fargate runtime — blue/green + proxy (BONUS)
Create:
- ECS cluster;
- task execution role + task role;
- task definitions: **app** (used by blue and green) and **nginx-proxy**;
- Fargate services: **app-blue**, **app-green**, **nginx-proxy**;
- **Cloud Map** (service discovery) so the proxy can resolve `app-blue`/`app-green` by DNS;
- CloudWatch log configuration for each service.
Use the container port + health path agreed with TM1.
**Checkpoint T6 with TM1:** task definitions match the Docker image contract; proxy resolves both colors.

#### Step 7: Create the Application Load Balancer
Create ALB, target group (fronting the **nginx-proxy** service), listener, security-group rules, and a health check on the agreed path via the proxy.
**Checkpoint T7 with TM1 & TM4:** TM1 confirms the health path; TM4 confirms the ALB URL is suitable for the pipeline smoke test.

> 🟡 Because NGINX performs the color switch, the ALB targets the **proxy** only. If the organizer prefers ALB-native blue/green, add blue-TG + green-TG + CodeDeploy instead — recorded as a design decision.

#### Step 8: Create CloudWatch resources (BONUS: logging + alarms)
Create log groups (app, proxy, Jenkins) and **alarms**: ALB `HTTPCode_ELB_5XX_Count`, `UnHealthyHostCount`, and ECS/EC2 CPU high. Wire useful Terraform outputs.
**Checkpoint T8 with TM3:** monitoring section + diagram match deployed resources.

#### Step 9: Review and apply the complete plan
Verify account + eu-west-1; review every name/tag; confirm no unrelated deletions; review IAM + public ingress; confirm backend uses S3 + DynamoDB.
**Checkpoint T9 with the whole team:** all four review the plan summary before apply.

#### Step 10: Handoff outputs
Provide a safe handoff doc (no secrets): region; Jenkins EC2 info; ECR URIs (app+proxy); ECS cluster; blue/green/proxy service names; task families; container names; **ALB URL**; Cloud Map DNS; CloudWatch log-group names.

#### Step 11: Prepare and perform teardown (BONUS: terraform destroy)
Before destruction: TM4 disables webhook + confirms no pipeline running; TM3 saves docs + evidence + AI log. Verify account/region/workspace/state/tags; produce + review the **destroy plan**; apply only the reviewed plan; verify Jenkins EC2, ECS services (blue/green/proxy), Fargate tasks, ALB, target group, Cloud Map, and ECR project resources removed; check leftovers; decide separately whether the **S3+DynamoDB backend** is retained.
**Checkpoint T10 with TM3 & TM4:** evidence saved, deployments stopped → teardown proceeds.

#### Step 12: AI-usage logging (MANDATORY)
Maintain `docs/ai-usage/team-member-2.md` (platform, model/LLM, exact prompts, how/why). Mark AI-generated Terraform with:
```hcl
# === AI-GENERATED (Generated by AI) ===
# Platform: <e.g., Microsoft Copilot>
# Model/LLM: <e.g., Claude / GPT-4o>
# Reviewed & adapted by: Team Member 2
# === END AI-GENERATED ===
```

### 🤝 Collaboration summary

| Checkpoint | Collaborator | Result |
|---|---|---|
| T1–T2 | TM3 | Account, region, **S3+DynamoDB** backend, diagram aligned |
| T3 | TM3 & TM4 | Network, security, Jenkins API access aligned |
| T4 | TM3 | Jenkins EC2 (AL2023) ready for Ansible |
| T5 | TM4 | ECR push works (app + proxy) |
| T6 | TM1 | ECS tasks match image; proxy resolves both colors |
| T7 | TM1 & TM4 | ALB health + smoke test agreed |
| T8 | TM3 | CloudWatch logs + **alarms** accurate |
| T9 | Whole team | Complete plan reviewed |
| T10 | TM3 & TM4 | Safe `terraform destroy` approved |

### 🏁 Definition of Finished
- Terraform creates eu-west-1 using **remote S3 state + DynamoDB locking**.
- Web app runtime is **ECS Fargate blue/green**, never EC2.
- Image registry is **Amazon ECR** (app + proxy), never Docker Hub.
- Jenkins EC2 (Amazon Linux 2023) is available to Ansible.
- **NGINX proxy service** fronts blue/green; ALB routes healthy traffic to it.
- CloudWatch receives logs and has **alarms**.
- All required outputs documented (incl. Cloud Map + ALB URL).
- A clean apply is reproducible; a reviewed `terraform destroy` removes only project resources.
- Final AWS cleanup verified; **AI usage logged** and Terraform AI blocks marked.
