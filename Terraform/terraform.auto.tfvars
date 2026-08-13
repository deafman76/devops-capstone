aws_region    = "eu-west-1"
subnet_id     = "subnet-09499899162c048f7"
instance_type = "t3.medium"

bucket_name = "bootcamp-project-team3-eu-west-1-2026"

# ECR
ecr_repository_name = "bootcamp-app-team3"

# ECS
ecs_cluster_name = "bootcamp-ecs-cluster-team3"
ecs_service_name = "bootcamp-app-service"
ecs_task_family  = "bootcamp-app"
container_name   = "bootcamp-app"
container_port   = 80

# Fargate
fargate_cpu       = 256
fargate_memory    = 512
ecs_desired_count = 2

# Existing AWS IAM role
ecs_task_execution_role_arn = "arn:aws:iam::597765856364:role/ecsTaskExecutionRole"

vpc_id = "vpc-04b6091923e283784"
