> **Region:** Europe (Ireland), AWS region code `eu-west-1`.  
> **Team size:** 5 people.  
> **Shared repository:** `devops-capstone`.  
> **Recommended beginner-friendly design:** two Amazon Linux 2023 EC2 instances, one for Jenkins and one for the application with k3s Kubernetes.  
> **Never commit passwords, tokens, private keys, `.tfstate`, kubeconfig, or Jenkins secrets to Git.

# 🚀 Our Project: End-to-End Automated Application Deployment

## 1. What the mentors are asking from us

The capstone asks the team to build a complete DevOps pipeline that automates infrastructure provisioning, server configuration, application containerization, CI/CD, and deployment on AWS.  
The task names AWS EC2, Amazon Linux, Bash, Docker, Ansible, Jenkins, Terraform, Git, and Docker Hub.  
The final application should require minimal manual intervention after the automation is established.  
The listed deliverables include Terraform code, a Bash installation script, a Dockerfile, a Docker Hub image, an Ansible playbook, a Jenkins pipeline, a GitHub repository, and a running application accessible through an EC2 public IP.

## 2. Bonus items shown in the task

The task lists these bonus challenges:

- Configure an NGINX reverse proxy in front of the application.
- Use an S3 Terraform backend and a DynamoDB table for locking.
- Trigger Jenkins automatically through GitHub webhooks.
- Store Docker Hub and AWS credentials securely in Jenkins Credentials.
- Implement blue/green deployment using two containers and switch traffic after a health check.
- Configure CloudWatch logging and alarms.
- Build and push versioned Docker images using the Jenkins build number.
- Destroy the test infrastructure automatically with Terraform after testing.

## 3. What we add to impress the mentor

We add Kubernetes through k3s on the application EC2 instance.  
We implement blue/green as two Kubernetes Deployments with one stable Service.  
We add container, infrastructure, and secret scans.  
We demonstrate both a successful release and a blocked or rolled-back failed release.  
We keep the solution understandable by using a static HTML application and putting the complexity into safe automation.

## 4. Agreed architecture

```text
Developer
   |
   | git push
   v
GitHub repository
   |
   | webhook
   v
Jenkins EC2, Amazon Linux 2023
   |
   | validate, scan, build, test, tag, push
   v
Docker Hub
   |
   | versioned image
   v
Application EC2, Amazon Linux 2023
   |
   +--> k3s Kubernetes
   |      +--> web-blue Deployment
   |      +--> web-green Deployment
   |      +--> web-active Service on NodePort 30080
   |
   +--> host NGINX port 80
             |
             v
      EC2 public IP

AWS support services:
Terraform remote state in S3
DynamoDB state locking
CloudWatch logs and alarms
IAM instance roles where permitted
```

This architecture is a lab showcase, not a production high-availability design.

## 5. Team ownership

```text
Team Member 1: static HTML and Docker image
Team Member 2: AWS Ireland and Terraform
Team Member 3: Bash, Ansible, Jenkins host, k3s host, NGINX
Team Member 4: GitHub webhook, Jenkins pipeline, Docker Hub, release and rollback
Team Member 5: Kubernetes manifests, security, CloudWatch validation, testing, README, demo
```

One person is accountable for each subsystem, but every integration boundary has a second-person checkpoint.

# 6. Sequence of our work

## Stage 0: freeze the contract

All five members agree:

```text
AWS region: eu-west-1
Project: devops-capstone
Environment: demo
Container port: 8080
Health path: /health.html
Version path: /version.json
Namespace: capstone
Blue Deployment: web-blue
Green Deployment: web-green
Stable Service: web-active
NodePort: 30080
Image tag: BUILD_NUMBER-short_git_sha
```

**Gate 0:** no implementation begins with different names or ports.

## Stage 1: independent foundations

- **Team Member 1:** builds the page and local Docker image.
- **Team Member 2:** writes Terraform backend and environment code.
- **Team Member 3:** writes Ansible roles and bootstrap automation.
- **Team Member 4:** writes pipeline scripts and Jenkinsfile skeleton.
- **Team Member 5:** writes Kubernetes skeleton, tests, security policy, and README structure.

**Gate 1 evidence:**

```text
Local container is healthy
Terraform validates
Ansible syntax check passes
Jenkinsfile has the agreed stages
Kubernetes files pass dry-run validation
```

## Stage 2: create AWS infrastructure

1. Team Member 2 logs in with MFA and selects `eu-west-1`.
2. Team Member 2 verifies the AWS account and existing resources.
3. Team Member 2 creates the remote-state backend.
4. Team Member 2 creates and shares the Terraform plan.
5. All five members review the plan.
6. Team Member 2 applies the reviewed plan.

**Gate 2 evidence:** two project-tagged EC2 instances exist in Ireland and Terraform outputs are available.

## Stage 3: configure servers

1. Team Member 3 uses Terraform outputs in Ansible inventory.
2. Team Member 3 configures Docker on both hosts.
3. Team Member 3 configures Jenkins on the Jenkins host.
4. Team Member 3 configures k3s and NGINX on the application host.
5. Team Member 3 configures CloudWatch Agent.
6. Team Member 3 runs Ansible twice.

**Gate 3 evidence:** Jenkins is active, k3s node is Ready, NGINX is active, Docker works, and the second Ansible run is idempotent.

## Stage 4: first simple deployment

1. Team Member 1 publishes the agreed application contract.
2. Team Member 5 deploys only the initial blue version.
3. Team Member 3 verifies NGINX routing.
4. Team Member 4 builds and pushes one versioned image.
5. The team verifies the EC2 public URL.

**Gate 4 evidence:** one versioned application is reachable through the application EC2 public IP.

## Stage 5: automate CI/CD

1. Team Member 4 configures Jenkins credentials.
2. Team Member 4 adds validation and scans.
3. Team Member 4 builds, tests, and pushes an immutable image.
4. Team Member 4 configures the GitHub webhook.
5. Team Member 5 confirms secrets are absent from Git and logs.

**Gate 5 evidence:** a GitHub push starts Jenkins and produces a validated, versioned Docker Hub image.

## Stage 6: blue/green deployment

1. Team Member 5 creates blue, green, stable, and candidate definitions.
2. Team Member 4 reads the current active slot.
3. Team Member 4 deploys the new image to the inactive slot.
4. Team Member 4 tests the candidate directly.
5. Team Member 4 switches the stable Service selector.
6. Team Member 5 runs the public smoke test.

**Gate 6 evidence:** the browser shows the new version and deployment slot after a health-checked traffic switch.

## Stage 7: failure demonstration

1. Team Member 1 supplies the controlled unhealthy candidate.
2. Team Member 4 runs the release pipeline.
3. Team Member 5 confirms candidate failure.
4. The stable Service remains on the healthy slot or returns to it.
5. Team Member 4 archives diagnostics.

**Gate 7 evidence:** public health remains successful while Jenkins clearly reports the failed candidate.

## Stage 8: monitoring and documentation

1. Team Member 5 confirms CloudWatch receives fresh logs.
2. Team Member 5 confirms agreed alarms exist.
3. Team Member 5 completes README and architecture documentation.
4. Every member follows the README section owned by another member.

**Gate 8 evidence:** a different team member can reproduce each documented step without hidden manual knowledge.

## Stage 9: mentor demo

```text
1. Show the task and final architecture
2. Show Terraform and AWS resources in eu-west-1
3. Show the second Ansible run
4. Open the current application
5. Push a visible page change
6. Show GitHub webhook and Jenkins stages
7. Show the versioned Docker Hub image
8. Show inactive candidate health
9. Show blue/green traffic switch
10. Refresh the browser and show new metadata
11. Run the controlled failed release
12. Show that the healthy application remains available
13. Show CloudWatch evidence
14. Show the reviewed Terraform destroy plan
```

**Gate 9:** all five members have a speaking and demonstration action.

## Stage 10: teardown

1. Team Member 4 disables webhook-triggered changes and confirms no build is active.
2. Team Member 5 saves final evidence and removes application traffic.
3. Team Member 2 verifies account, region, workspace, state, and destroy plan.
4. Team Members 2 and 5 perform the final sanity-check.
5. Team Member 2 applies the reviewed destroy plan.
6. Team Member 3 confirms both EC2 instances terminate.
7. Team Member 2 checks for project leftovers.
8. The team decides whether to retain or remove the state backend.

**Gate 10:** no unintended project resource remains billable.

# 7. Required deliverables

- GitHub repository.
- Terraform infrastructure code.
- Bash bootstrap script.
- Ansible inventory, playbook, and roles.
- Static HTML application.
- Dockerfile.
- Versioned Docker Hub image.
- Jenkinsfile.
- Kubernetes blue and green Deployments.
- Stable and candidate Services.
- NGINX reverse proxy.
- Health and version endpoints.
- CloudWatch logging and alarm configuration.
- Security scanning configuration.
- Successful-release evidence.
- Failed-release and rollback or no-switch evidence.
- README, architecture diagram, demo script, and teardown checklist.

# 8. Project Definition of Finished, DoF

The project is finished only when every item below is true.

## Infrastructure DoF

- Terraform creates the project infrastructure in `eu-west-1` from a clean environment.
- Terraform uses remote state and locking.
- Resources have consistent project tags.
- A reviewed destroy plan contains only project resources.

## Configuration DoF

- Ansible configures Jenkins and application hosts.
- The second Ansible run makes no unnecessary changes.
- Jenkins, Docker, k3s, NGINX, and CloudWatch Agent are active.

## Application DoF

- The Docker image builds from a clean repository clone.
- Health and version endpoints respond.
- The page visibly identifies version, build, commit, and slot.

## Pipeline DoF

- A GitHub push triggers Jenkins.
- Required validation and security scans run.
- Jenkins pushes an immutable versioned image.
- Secrets are stored outside Git and masked in logs.

## Deployment DoF

- Blue and green Deployments can run independently.
- The candidate is health-checked before traffic switching.
- The stable Service selects exactly one active slot.
- The application is reachable through the EC2 public IP.
- A failed candidate does not replace the healthy release.

## Monitoring and evidence DoF

- CloudWatch receives the agreed logs.
- Agreed alarms are configured and documented.
- Successful and failed pipeline evidence is saved.
- README and demo instructions are complete.

## Cleanup DoF

- The team can disable new pipeline activity.
- Terraform destroys the environment from the correct state.
- Both EC2 instances are confirmed terminated.
- Project volumes, addresses, load balancers, and other leftovers are checked.
- External tokens and webhooks are revoked or removed when no longer needed.

# 9. Rules that prevent integration failure

- No one changes agreed ports, names, labels, or credential IDs without updating the integration contract.
- No one commits directly to `main` without the agreed review process.
- No one performs an unreviewed Terraform apply or destroy.
- No one manually fixes a server without adding the fix to Ansible.
- No one manually changes a release without updating the pipeline or documented desired state.
- No one exposes credentials in Git, scripts, screenshots, or console logs.
- Every feature must finish with evidence and a second-person checkpoint.

# 10. Confidence summary

- The mentor requirements and bonus items above are taken from the supplied task screenshots.
- The two-EC2 k3s design is the clearest beginner implementation that also keeps the application on an EC2 public IP.
- This design is simpler to deliver and explain than EKS while still demonstrating Kubernetes.
- The assigned AWS account permits all IAM, S3, DynamoDB, CloudWatch, and EC2 actions required by the design. The team must verify permissions before the first Terraform apply.
