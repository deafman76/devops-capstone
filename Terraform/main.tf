resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.ec2_subnet_id
  vpc_security_group_ids = [var.security_group_id]

  associate_public_ip_address = true

  iam_instance_profile = "Bootcamp-Instance-Profile"

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "bootcamp-ec2-team3"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}


# S3 ======================================================================


resource "aws_s3_bucket" "app" {
  bucket = var.bucket_name

  tags = {
    Name        = "bootcamp-s3-team3"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}


# ECR ===================================================================


resource "aws_ecr_repository" "app" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = var.ecr_repository_name
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "bootcamp-automation"
  }
}


# ECS CLUSTER=====================================================


resource "aws_ecs_cluster" "app" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = var.ecs_cluster_name
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "bootcamp-automation"
  }
}



# ECS TASK DEFINITION ======================================================


resource "aws_ecs_task_definition" "app" {
  family                   = var.ecs_task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = var.fargate_cpu
  memory = var.fargate_memory

  # Use the EXISTING IAM ROLE
  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = "${aws_ecr_repository.app.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
    }
  ])

  tags = {
    Name        = var.ecs_task_family
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "bootcamp-automation"
  }
}



# ECS create FARGATE SERVICE ===============================================


resource "aws_ecs_service" "app" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn

  desired_count = var.ecs_desired_count

  launch_type      = "FARGATE"
  platform_version = "LATEST"

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets = var.subnet_ids

    security_groups = [
      var.security_group_id
    ]

    assign_public_ip = true
  }

  tags = {
    Name        = var.ecs_service_name
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "bootcamp-automation"
  }
}

 
