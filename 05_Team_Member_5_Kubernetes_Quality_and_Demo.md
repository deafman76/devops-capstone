> **Region:** Europe (Ireland), AWS region code `eu-west-1`.  
> **Team size:** 5 people.  
> **Shared repository:** `devops-capstone`.  
> **Recommended beginner-friendly design:** two Amazon Linux 2023 EC2 instances, one for Jenkins and one for the application with k3s Kubernetes.  
> **Never commit passwords, tokens, private keys, `.tfstate`, kubeconfig, or Jenkins secrets to Git.

# 👤 Team Member 5: Kubernetes, NGINX Routing, Security, Monitoring, Quality, and Demo

## 🎯 Your mission

You are the integration and quality owner.  
You own Kubernetes workload definitions, blue/green behavior, security checks, monitoring verification, end-to-end tests, and presentation evidence.  
This role should coordinate interfaces without taking over other owners' implementation work.

## 📦 Files you own

```text
kubernetes/namespace.yaml
kubernetes/blue-deployment.yaml
kubernetes/green-deployment.yaml
kubernetes/service.yaml
kubernetes/candidate-service.yaml
security/**
tests/smoke-test.sh
tests/rollback-test.md
tests/drift-test.md
docs/architecture.md
docs/demo-script.md
docs/checkpoints.md
docs/teardown-checklist.md
README.md
```

## 🔗 Inputs you need

- **From Team Member 1:** image name, port `8080`, health path, and version path.
- **From Team Member 2:** application public IP, security-group rules, CloudWatch names, and resource tags.
- **From Team Member 3:** working k3s, host NGINX, kubeconfig method, and log paths.
- **From Team Member 4:** image tag, Jenkins build evidence, deployment scripts, and rollback mechanism.

## 📤 Outputs you give

- **To Team Member 3:** NodePort and NGINX reverse-proxy target.
- **To Team Member 4:** exact Kubernetes resource names, labels, selectors, and test criteria.
- **To the whole team:** checkpoint status, architecture diagram, demo script, and teardown readiness.

# ✅ Step-by-step tasks

## Step 1: Freeze Kubernetes names

Use:

```text
Namespace: capstone
Application label: app=capstone-web
Blue label: slot=blue
Green label: slot=green
Deployments: web-blue and web-green
Stable Service: web-active
Candidate Service: web-candidate
Container port: 8080
NodePort: 30080
Health path: /health.html
```

**Checkpoint K1:** Team Members 1, 3, and 4 agree these names and record them in the integration contract.

## Step 2: Create the namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: capstone
```

## Step 3: Create blue and green Deployments

Each Deployment must have matching selectors and pod labels.  
Each container must include readiness and liveness probes on `/health.html`, port `8080`.  
Add resource requests and limits.  
Add a security context that prevents privilege escalation and requests non-root execution.

**Checkpoint K2:** Team Member 1 confirms the image can satisfy the probes and security context.

## Step 4: Create the stable Service

`web-active` selects `app=capstone-web` and one slot.  
Expose it as NodePort `30080` so host NGINX can proxy locally.

**Checkpoint K3:** Team Member 3 configures host NGINX from port `80` to local port `30080`.

## Step 5: Create a candidate-test path

Create a temporary `web-candidate` Service or another documented method that selects the inactive slot before production traffic switches.  
Team Member 4 uses this path for candidate health checks.

**Checkpoint K4:** a candidate can be tested independently while `web-active` still selects the old slot.

## Step 6: Validate Kubernetes resources

```bash
kubectl apply --dry-run=client -f kubernetes/namespace.yaml
kubectl apply --dry-run=client -f kubernetes/blue-deployment.yaml
kubectl apply --dry-run=client -f kubernetes/green-deployment.yaml
kubectl apply --dry-run=client -f kubernetes/service.yaml
```

**Checkpoint K5:** all resources pass client-side validation and the selectors match the expected labels.

## Step 7: Deploy the initial blue version

```bash
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/blue-deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl rollout status deployment/web-blue -n capstone
kubectl get pods,svc -n capstone -o wide
```

**Checkpoint K6:** Team Members 3 and 4 confirm blue is healthy and reachable through the application EC2 public IP.

## Step 8: Add security checks

Configure the selected tools in repeatable scripts or pipeline stages.  
The baseline checks are:

```text
Gitleaks for repository secrets
Checkov for Terraform and Kubernetes configuration
Trivy for the built container image
```

Document which severity levels fail the pipeline and which findings are accepted with reasons.

**Checkpoint K7:** Team Member 4 integrates the agreed commands and Team Member 2 reviews infrastructure findings.

## Step 9: Verify CloudWatch

Confirm that fresh events arrive from Jenkins, host NGINX, bootstrapping, and agreed system logs.  
Confirm the EC2 status-check alarm and any approved CPU alarm are present.  
Do not claim an alarm works solely because it exists; record how the configuration was verified.

**Checkpoint K8:** Team Members 2 and 3 provide resource and agent details, and you capture evidence.

## Step 10: Run successful release test

Record:

```text
Old active slot
New image tag
Candidate rollout result
Candidate health result
Service selector after switch
Public version response
Jenkins build link or captured evidence
```

**Checkpoint K9:** all five members witness one complete successful release.

## Step 11: Run failed release test

Use Team Member 1's controlled unhealthy version.  
Verify that the unhealthy candidate never replaces the healthy active slot.  
If testing post-switch rollback, verify the selector returns to the known-good slot.

**Checkpoint K10:** production health remains successful and diagnostic evidence explains the failed candidate.

## Step 12: Maintain the README

README must contain:

```text
Project goal
Architecture
Repository structure
Prerequisites
AWS region
Credential safety rules
Infrastructure deployment
Ansible configuration
Jenkins setup
Application release
Blue/green logic
Health checks
Monitoring
Rollback
Cleanup
Known limitations
```

## Step 13: Create the demo script

Use this speaking order:

```text
1. Team Member 2: AWS and Terraform
2. Team Member 3: Ansible and servers
3. Team Member 1: application and Docker
4. Team Member 4: Jenkins release
5. Team Member 5: failed release, monitoring, and teardown proof
```

## Step 14: Gate teardown

Confirm final evidence is saved.  
Confirm Team Member 4 disabled the webhook and no pipeline is active.  
Confirm Kubernetes application resources are no longer serving traffic.  
Review Team Member 2's destroy plan against project tags and state.

**Checkpoint K11:** you and Team Member 2 sign off before destruction.

# 🤝 Collaboration map

| Checkpoint | Collaborator | What you verify |
|---|---|---|
| K1 and K2 | Team Member 1 | Port, image, health, security context |
| K3 and K8 | Team Member 3 | NGINX route, k3s access, logs |
| K6, K9, K10 | Team Member 4 | Release, switch, rollback evidence |
| K7 and K11 | Team Member 2 | AWS security findings and safe destroy |
| K9 | Whole team | End-to-end successful release |

# 🏁 Your Definition of Finished

- Blue and green workloads have correct labels, probes, and limits.
- Stable traffic uses one Service selector.
- Candidate health can be checked before switching.
- Host NGINX exposes the application through the EC2 public IP.
- Security scans run with documented thresholds.
- CloudWatch receives agreed logs and contains agreed alarms.
- Successful and failed releases are demonstrated.
- README and demo script are usable by beginners.
- Teardown evidence and sign-off are complete.
