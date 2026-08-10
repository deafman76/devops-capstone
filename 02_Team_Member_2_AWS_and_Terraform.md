> **Region:** Europe (Ireland), AWS region code `eu-west-1`.  
> **Team size:** 5 people.  
> **Shared repository:** `devops-capstone`.  
> **Recommended beginner-friendly design:** two Amazon Linux 2023 EC2 instances, one for Jenkins and one for the application with k3s Kubernetes.  
> **Never commit passwords, tokens, private keys, `.tfstate`, kubeconfig, or Jenkins secrets to Git.

# 👤 Team Member 2: AWS Ireland and Terraform

## 🎯 Your mission

You own all AWS infrastructure created as code in `eu-west-1`.  
You are the normal operator for `terraform apply` and `terraform destroy`.  
One routine Terraform operator reduces state conflicts for a beginner team.

## 🏗️ Target infrastructure

The beginner-friendly baseline contains:

```text
1 VPC
1 public subnet
1 Internet Gateway
1 route table
1 Jenkins EC2 instance
1 application EC2 instance
2 security groups
2 IAM instance roles, if allowed
1 S3 Terraform state bucket
1 DynamoDB lock table, to match the mentor bonus wording
CloudWatch log groups and alarms
```

Kubernetes runs as k3s on the application EC2 instance, which preserves the mentor's EC2 public-IP requirement and adds Kubernetes without requiring EKS permissions.

## 📦 Files you own

```text
terraform/bootstrap/**
terraform/environment/**
docs/aws-resources.md
docs/terraform-runbook.md
```

## 🔗 Inputs you need

- **From Team Member 3:** required EC2 operating system, usernames, and server ports.
- **From Team Member 4:** Jenkins inbound access requirement and pipeline AWS permissions.
- **From Team Member 5:** application port, NodePort, CloudWatch log groups, and alarm names.

## 📤 Outputs you give

- **To Team Member 3:** Jenkins and application instance IDs, public IPs, usernames, and inventory data.
- **To Team Member 4:** Jenkins public URL and AWS identity model.
- **To Team Member 5:** application public IP, CloudWatch resource names, and tags.

# ✅ Step-by-step tasks

## Step 1: Log in and select Ireland

Sign in using the account and MFA method supplied by the bootcamp.  
Select `Europe (Ireland)` in the AWS Console.

```bash
export AWS_REGION=eu-west-1
export AWS_DEFAULT_REGION=eu-west-1
aws sts get-caller-identity
```

**Checkpoint T1:** save the account ID and principal ARN in team notes without saving credentials.  
**Collaboration:** Team Member 5 witnesses the account and region check before the first apply.

## Step 2: Inspect existing resources

Check existing EC2 instances, VPCs, S3 buckets, CloudFormation stacks, and CloudWatch log groups.  
Record existing resource names in `docs/aws-resources.md` so the team does not destroy unrelated resources.

## Step 3: Create Terraform bootstrap code

Define:

- S3 state bucket with a globally unique name.
- S3 versioning.
- S3 encryption.
- S3 public-access block.
- DynamoDB table with string partition key `LockID`, if the team follows the mentor bonus literally.

Run:

```bash
cd terraform/bootstrap
terraform fmt -check
terraform init
terraform validate
terraform plan -out=bootstrap.tfplan
terraform show bootstrap.tfplan
```

**Checkpoint T2:** Team Member 5 reviews the plan and confirms it contains only backend resources.  
Apply only the reviewed plan:

```bash
terraform apply bootstrap.tfplan
```

## Step 4: Configure the environment backend

Configure `terraform/environment/backend.tf` to use the state bucket and lock table.  
Never commit AWS credentials into this file.

## Step 5: Define the AWS network

Define the VPC, public subnet, Internet Gateway, route table, and subnet association in Terraform.  
A single public subnet is sufficient for this lab baseline, but it is not a production high-availability design.

## Step 6: Define security groups

Jenkins security group:

```text
22/tcp from the approved team IP range, only if SSH is required
8080/tcp from the approved team or mentor IP range
```

Application security group:

```text
22/tcp from the approved team IP range, only if SSH is required
80/tcp from the Internet for the public demo
```

k3s API and Kubernetes NodePort should not be exposed to the Internet when host NGINX can proxy locally.

**Checkpoint T3:** Team Members 3 and 5 review every inbound rule before apply.

## Step 7: Define two Amazon Linux 2023 EC2 instances

Create:

```text
devops-capstone-jenkins
devops-capstone-app
```

Use `t3.medium` where the assigned account permits it because the internal bootcamp exercise uses that instance type.  
Add tags:

```text
Project=devops-capstone
Environment=demo
ManagedBy=terraform
Owner=team
```

## Step 8: Define IAM and CloudWatch resources

Use instance roles instead of storing long-lived AWS access keys on EC2 when the assigned account permits role creation.  
Define CloudWatch log groups and alarms agreed with Team Member 5.

## Step 9: Define outputs

```text
jenkins_instance_id
jenkins_public_ip
app_instance_id
app_public_ip
aws_region
jenkins_security_group_id
app_security_group_id
```

## Step 10: Validate and plan

```bash
cd terraform/environment
terraform fmt -recursive
terraform init -reconfigure
terraform validate
terraform plan -out=environment.tfplan
terraform show environment.tfplan
```

**Checkpoint T4:** all five members review the human-readable plan summary.  
The plan must show the correct account, region, names, tags, and no unrelated deletion.

## Step 11: Apply

```bash
aws sts get-caller-identity
terraform apply environment.tfplan
terraform output
```

**Checkpoint T5:** Team Member 3 confirms both EC2 instances are reachable by the agreed management method.  
**Checkpoint T6:** Team Member 5 confirms that the application public IP is assigned and CloudWatch resources exist.

## Step 12: Give outputs to the team safely

Share public IPs, instance IDs, and region in team notes.  
Never share private keys or temporary credentials in Git or team chat.

## Step 13: Prepare teardown before the demo

```bash
terraform state list
terraform plan -destroy -out=destroy.tfplan
terraform show destroy.tfplan
```

**Checkpoint T7:** Team Member 5 verifies that only project-tagged or project-state resources appear in the destroy plan.  
Do not apply the destroy plan until the demo evidence is saved and Team Member 4 has disabled the pipeline.

# 🤝 Collaboration map

| Step | Collaborator | Handoff |
|---|---|---|
| T1 | Team Member 5 | Witness account and `eu-west-1` |
| T3 | Team Members 3 and 5 | Review ports and exposure |
| T4 | Whole team | Review Terraform plan |
| T5 | Team Member 3 | Provide both server endpoints |
| T6 | Team Member 5 | Provide CloudWatch names |
| T7 | Team Members 4 and 5 | Stop changes, save evidence, review destroy |

# 🧹 Final teardown tasks

1. Confirm Team Member 4 disabled the webhook and no build is running.
2. Confirm Team Member 5 deleted the application workload or stopped traffic.
3. Run `aws sts get-caller-identity` and confirm `eu-west-1`.
4. Run and review `terraform plan -destroy` again.
5. Apply the reviewed destroy plan.
6. Verify both EC2 instances reach `terminated`.
7. Check Elastic IPs, volumes, load balancers, CloudWatch groups, and IAM roles for project leftovers.
8. Keep or destroy the state backend only according to the team's final evidence decision.

# 🏁 Your Definition of Finished

- A clean Terraform apply creates the agreed AWS resources in `eu-west-1`.
- State is remote and protected against concurrent writes.
- Both EC2 outputs are available to Team Member 3.
- No SSH or Jenkins port is unnecessarily open to the world.
- CloudWatch resources exist for Team Member 5.
- A reviewed destroy plan removes only project resources.
