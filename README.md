# bootcamp-project
DevOps Bootcamp Capstone Task


## Current Working Baseline

- Jenkins checks out the main branch from GitHub.

- Jenkins validates the repository and generates build metadata.

- Jenkins builds and locally tests the application Docker image.

- Jenkins authenticates to AWS through the EC2 IAM instance role.

- Jenkins pushes immutable build tags and the latest compatibility tag to private Amazon ECR.

- The application runs on Amazon ECS Fargate using task definition bootcamp-app:4.

- The ECS service maintains two running tasks.

- The application serves health.html and version.json on port 8080.

- Automated Jenkins-to-ECS deployment is disabled until the Jenkins instance role receives ecs:DescribeServices and ecs:UpdateService.

- ALB, dedicated proxy, blue/green services, Cloud Map, and CloudWatch alarms are deferred.