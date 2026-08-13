Infrastructure — Terraform

Updated Terraform configuration for a new Amazon Linux 2023 EC2 instance
Created a dedicated S3 bucket
Configured the EC2 to use the existing Bootcamp-Instance-Profile
Kept infrastructure aligned with the team's SSM-only security requirements
Applied and verified the infrastructure successfully

Server Configuration — Ansible
Adapted Ansible inventory for local execution through SSM instead of SSH
Reviewed and modified Ansible roles for Amazon Linux 2023
Fixed the curl / curl-minimal package conflict
Successfully automated installation and configuration of:
Docker
Java 21 Corretto
Jenkins
AWS CLI
CloudWatch Agent

Security & Access
Used AWS Systems Manager Session Manager instead of SSH
Kept SSH access out of the deployment
Accessed Jenkins through SSM port forwarding
Configured Jenkins user/admin access for the team