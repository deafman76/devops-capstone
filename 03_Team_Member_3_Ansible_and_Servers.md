> **Region:** Europe (Ireland), AWS region code `eu-west-1`.  
> **Team size:** 5 people.  
> **Shared repository:** `devops-capstone`.  
> **Recommended beginner-friendly design:** two Amazon Linux 2023 EC2 instances, one for Jenkins and one for the application with k3s Kubernetes.  
> **Never commit passwords, tokens, private keys, `.tfstate`, kubeconfig, or Jenkins secrets to Git.

# 👤 Team Member 3: Bash, Ansible, Jenkins Host, and Application Host

## 🎯 Your mission

You receive two empty Terraform-managed Amazon Linux 2023 instances and configure them automatically.  
You must not install the final platform manually and then leave the steps undocumented.  
Ansible roles make the configuration repeatable and easier to explain.

## 📦 Files you own

```text
scripts/bootstrap.sh
ansible/inventory/**
ansible/playbook.yml
ansible/group_vars/**
ansible/roles/common/**
ansible/roles/docker/**
ansible/roles/jenkins/**
ansible/roles/k3s/**
ansible/roles/nginx/**
ansible/roles/cloudwatch/**
docs/server-configuration.md
```

## 🔗 Inputs you need

- **From Team Member 2:** EC2 IPs, instance IDs, region, usernames, and approved connection method.
- **From Team Member 4:** Jenkins plugins, command-line tools, and credential IDs used by the pipeline.
- **From Team Member 5:** NodePort, health path, NGINX proxy target, and CloudWatch log paths.

## 📤 Outputs you give

- **To Team Member 4:** Jenkins URL, installed tools, service status, and Jenkins credential locations.
- **To Team Member 5:** working k3s cluster, kubeconfig handling method, NGINX status, and app host logs.

# ✅ Step-by-step tasks

## Step 1: Create Ansible inventory

Create two groups:

```yaml
all:
  children:
    jenkins_servers:
      hosts:
        jenkins:
          ansible_host: REPLACE_WITH_TERRAFORM_OUTPUT
          ansible_user: ec2-user
    app_servers:
      hosts:
        app:
          ansible_host: REPLACE_WITH_TERRAFORM_OUTPUT
          ansible_user: ec2-user
```

Keep private key material outside the repository.  
**Checkpoint S1:** `ansible all -i ansible/inventory/hosts.yml -m ping` succeeds for both hosts.

## Step 2: Create a common role

Install common packages required by the team, such as Git, curl, wget, jq, unzip, and Python support.  
Enable time synchronization and create clearly named configuration directories.

## Step 3: Configure Docker on both hosts

Install Docker using the package method supported by Amazon Linux 2023 in the assigned environment.  
Enable and start Docker.  
Add only required service users to the Docker group.

Validate:

```bash
sudo systemctl is-enabled docker
sudo systemctl is-active docker
docker version
```

**Checkpoint S2:** Docker is active on both servers and Team Member 1's local test image contract is understood.

## Step 4: Configure the Jenkins host

Install a Java version supported by the chosen Jenkins release before Jenkins.  
Install Jenkins from its stable repository.  
Enable and start Jenkins.  
Install the plugins requested by Team Member 4.

Minimum agreed plugin categories:

```text
Pipeline
Git
GitHub
Credentials Binding
Docker Pipeline
JUnit, if tests publish JUnit output
```

Validate:

```bash
sudo systemctl is-active jenkins
sudo systemctl is-enabled jenkins
curl -I http://127.0.0.1:8080
```

**Checkpoint S3:** Team Member 4 can open the Jenkins URL and create a test pipeline.

## Step 5: Configure required CLI tools on Jenkins

Install the commands actually used by the Jenkinsfile.  
The baseline includes Git, Docker, AWS CLI, `kubectl`, and validation/scanning tools selected by the team.

Create a verification script:

```bash
git --version
docker --version
aws --version
kubectl version --client
```

**Checkpoint S4:** Team Member 4 runs the script as the Jenkins service user, not only as `ec2-user`.

## Step 6: Configure k3s on the application host

Install k3s through an Ansible task or script checked into the repository.  
Start and enable the k3s service.  
Configure a secure, documented kubeconfig handoff for Jenkins.

Validate on the app host:

```bash
sudo systemctl is-active k3s
sudo k3s kubectl get nodes
sudo k3s kubectl get pods -A
```

**Checkpoint S5:** the single Kubernetes node is `Ready`.  
**Collaboration:** Team Member 5 verifies cluster access and namespace creation.

## Step 7: Configure host NGINX on the application host

Configure host NGINX to listen on port `80`.  
Proxy requests to the local Kubernetes NodePort agreed with Team Member 5.  
Do not expose the NodePort publicly when local proxying is sufficient.

Validate:

```bash
sudo nginx -t
sudo systemctl is-active nginx
curl -I http://127.0.0.1
```

**Checkpoint S6:** Team Member 5 confirms that traffic reaches the Kubernetes Service through host NGINX.

## Step 8: Configure CloudWatch Agent

Configure logs agreed with Team Member 5, including Jenkins, NGINX, bootstrapping, and relevant system logs.  
Avoid logging secrets or credential values.

**Checkpoint S7:** Team Member 5 sees fresh log events in the designated CloudWatch log groups.

## Step 9: Run the complete playbook

```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbook.yml --syntax-check
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbook.yml
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbook.yml
```

**Checkpoint S8:** the first run configures both hosts and the second run makes no unnecessary repeat changes.

## Step 10: Commit through review

```bash
git checkout -b feature/ansible-servers
git add ansible scripts docs/server-configuration.md
git commit -m "feat: configure Jenkins and k3s hosts with Ansible"
git push -u origin feature/ansible-servers
```

**Checkpoint S9:** Team Member 2 reviews AWS assumptions, Team Member 4 reviews Jenkins tooling, and Team Member 5 reviews k3s, NGINX, and logs.

# 🤝 Collaboration map

| Checkpoint | Collaborator | Required proof |
|---|---|---|
| S1 | Team Member 2 | Both Terraform-created hosts reachable |
| S3 and S4 | Team Member 4 | Jenkins and tools work as Jenkins user |
| S5 and S6 | Team Member 5 | k3s ready and public path works |
| S7 | Team Member 5 | CloudWatch receives fresh logs |
| S8 | Whole team | Repeatable configuration from a clean host |

# 🏁 Your Definition of Finished

- Both Amazon Linux hosts are configured from Ansible.
- Jenkins is active and accessible only through the approved security-group path.
- Docker works for Jenkins.
- k3s reports a Ready node.
- Host NGINX proxies port `80` to the agreed Kubernetes Service.
- CloudWatch Agent sends agreed logs.
- A second playbook run is idempotent.
- No manual-only setup step is missing from code or documentation.
