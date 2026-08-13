# UPDATE FOR TEAMMATE — Terraform / ECR / ECS

## Current project state

The Jenkins EC2 infrastructure is already working and MUST NOT be recreated unnecessarily.

Current setup:
- Amazon Linux 2023 EC2
- EC2 managed by Terraform
- Existing `Bootcamp-Instance-Profile`
- SSM access works
- No SSH access is required
- Jenkins installed and running through Ansible
- Docker installed and running
- Java 21 Corretto installed
- AWS CLI and CloudWatch Agent installed
- S3 bucket created by Terraform
- Jenkins is accessed through SSM port forwarding on local port 8080

The working Jenkins EC2 should remain in Terraform state.

## What was added

ECR/ECS resources were added to `Terraform/main.tf`:
- ECR repository
- ECS cluster
- Fargate task definition
- ECS Fargate service

The general architecture should be:

Developer
  -> Jenkins
  -> Docker build
  -> ECR
  -> ECS/Fargate
  -> Web application

The web application MUST NOT run from the Jenkins EC2.

## Things to check/fix

### 1. ECS variables

The ECS service currently references:

`var.subnet_ids`

The corresponding variable must exist in `variables.tf`:

```hcl
variable "subnet_ids" {
  description = "Subnets for ECS Fargate"
  type        = list(string)
}
```

The correct subnet IDs must then be supplied in `terraform.auto.tfvars`.

Do NOT blindly reuse the Jenkins subnet configuration without checking the intended ECS networking.

### 2. ECS security group

The existing Terraform security group:

`aws_security_group.jenkins`

is specifically for the Jenkins EC2.

It currently has outbound access and no inbound rules, which is intentional because Jenkins is accessed through SSM.

DO NOT attach the Jenkins security group to Fargate.

Create/use a separate ECS/Fargate security group with only the required inbound application traffic.

The ECS service currently references:

`var.security_group_id`

There is currently no ECS security-group resource in the shown `main.tf`.

Prefer creating a dedicated Terraform-managed ECS security group and referencing:

```hcl
security_groups = [aws_security_group.ecs.id]
```

instead of using a generic `security_group_id` variable.

### 3. ECS task execution IAM role

The task definition currently uses:

`var.ecs_task_execution_role_arn`

Our AWS user does not appear to have unrestricted IAM administration permissions.

Previously Terraform attempted to create an IAM role and hit permission restrictions.

Therefore:
- Do NOT create a new IAM role unless permissions are confirmed.
- Find/reuse the existing ECS task execution role if one already exists.
- Verify that the role has the permissions required by the Fargate task, especially pulling from ECR and writing logs if CloudWatch logging is configured.

### 4. ECR image / `latest`

The ECS task definition currently uses:

`${aws_ecr_repository.app.repository_url}:latest`

Remember that a newly created ECR repository does not contain an image automatically.

Expected flow:

Jenkins
  -> build image
  -> push image to ECR
  -> ECS pulls the image
  -> Fargate task starts

Do not assume ECS tasks will successfully start before Jenkins has pushed the required image.

### 5. Public IP / application access

The current ECS service has:

`assign_public_ip = true`

Review whether this matches the final architecture and assignment requirements.

The instructor requires:
- Web application MUST NOT run from EC2
- SSH keys/SSH ports are not allowed
- SSM is used for AWS resource access
- Security best practices are required

Do not open SSH or Jenkins port 8080 to `0.0.0.0/0`.

If the final architecture requires an ALB, that should be considered rather than exposing Fargate tasks unnecessarily.

## Important: do NOT recreate the Jenkins EC2

Before applying Terraform, always run:

```powershell
terraform fmt
terraform validate
terraform plan
```

Inspect the plan.

We want the existing Jenkins EC2 and S3 to remain unchanged.

If Terraform says the Jenkins EC2 will be:

- `+ create`
- `-/+ destroy and create replacement`
- or otherwise recreated

STOP and fix the Terraform/state/configuration first.

The desired result is approximately:

```text
Existing:
  Jenkins EC2     -> no change
  S3              -> no change
  Jenkins SG      -> no change

New:
  ECR             -> create
  ECS cluster     -> create
  ECS task        -> create
  ECS service     -> create
  ECS SG          -> create (if needed)
```

Only apply after the plan has been reviewed.

## Existing Jenkins security model

Jenkins EC2:
- No inbound SSH
- No public Jenkins port required
- SSM Session Manager is used
- Jenkins listens internally on port 8080
- Developers can use SSM port forwarding:

```powershell
aws ssm start-session --target <INSTANCE_ID> --document-name AWS-StartPortForwardingSession --parameters portNumber="8080",localPortNumber="8080" --profile dev-mfa --region eu-west-1
```

Then browse to:

`http://localhost:8080`

## AI-generated code requirement

The instructors require AI usage to be documented.

AI platform used:
- OpenAI ChatGPT
- Model: GPT-5.6 Luna

AI-generated code blocks in the repository should remain clearly marked according to the team's documentation requirements.

## Goal

Please review the current Terraform configuration on `main`, fix the ECR/ECS integration without breaking the existing Jenkins infrastructure, and make sure:

1. Terraform validates.
2. ECS variables are defined correctly.
3. ECS uses a dedicated application security group.
4. An appropriate existing ECS task execution role is reused if possible.
5. Fargate networking is correct.
6. ECR -> Jenkins -> ECS image flow is correct.
7. `terraform plan` does NOT recreate the working Jenkins EC2.
8. The final Terraform configuration can be safely applied.
