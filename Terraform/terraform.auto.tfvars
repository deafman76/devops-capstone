aws_region = "eu-west-1"
subnet_ids = [
  "subnet-0085786c1374a372c",
  "subnet-09499899162c048f7"
]
ec2_subnet_id     = "subnet-0085786c1374a372c"
security_group_id = "sg-055585017924b8963"
ami_id            = "ami-032490a2400c9afb6"
instance_type     = "t3.medium"
bucket_name       = "bootcamp-eu-west-1-project-s3-bucket-1"

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
