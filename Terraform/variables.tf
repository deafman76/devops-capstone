variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "ec2_subnet_id" {
  description = "Existing subnet ID for EC2"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for ECS Fargate"
  type        = list(string)
}

variable "security_group_id" {
  description = "Existing security group ID"
  type        = string
}

variable "ami_id" {
  description = "EC2 AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}


# S3 Bucket =====================================


variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

# ECR ================================================


variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "devops-app"
}


# ECS ==================================================


variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = "devops-ecs-cluster"
}


variable "ecs_task_execution_role_arn" {
  description = "ECS tak execution role"
  type        = string
  default     = "devops-app-service"
}


variable "ecs_service_name" {
  description = "ECS service name"
  type        = string
  default     = "devops-app-service"
}

variable "ecs_task_family" {
  description = "ECS task definition family"
  type        = string
  default     = "devops-app"
}

variable "container_name" {
  description = "Container name"
  type        = string
  default     = "devops-app"
}

variable "container_port" {
  description = "Application container port"
  type        = number
  default     = 80
}

variable "fargate_cpu" {
  description = "Fargate CPU units"
  type        = number
  default     = 256
}

variable "fargate_memory" {
  description = "Fargate memory in MiB"
  type        = number
  default     = 512
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}


