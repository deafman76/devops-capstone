#!/usr/bin/env bash

set -euo pipefail

# Clean deploy script: triggers a rolling deployment by forcing a new ECS deployment
# Requires: AWS CLI v2 configured with credentials and region (or set AWS_REGION env var)

AWS_REGION="${AWS_REGION:-eu-west-1}"
ECS_CLUSTER="${ECS_CLUSTER:-bootcamp-ecs-cluster-team3}"
ECS_SERVICE="${ECS_SERVICE:-bootcamp-app-service}"

: "${BUILD_TAG:?BUILD_TAG is required}"

echo "Starting ECS rolling deployment"
echo "Cluster: ${ECS_CLUSTER}  Service: ${ECS_SERVICE}  Build: ${BUILD_TAG}"

echo "Current service state:" >&2
aws ecs describe-services \
	--cluster "${ECS_CLUSTER}" \
	--services "${ECS_SERVICE}" \
	--region "${AWS_REGION}" \
	--query 'services[0].{Status:status,Desired:desiredCount,Running:runningCount,Pending:pendingCount,TaskDefinition:taskDefinition}' \
	--output json

echo "Forcing new deployment..." >&2
aws ecs update-service \
	--cluster "${ECS_CLUSTER}" \
	--service "${ECS_SERVICE}" \
	--force-new-deployment \
	--region "${AWS_REGION}" \
	--query 'service.{Name:serviceName,Desired:desiredCount,Running:runningCount,Pending:pendingCount,TaskDefinition:taskDefinition}' \
	--output json

echo "Waiting for service to become stable..." >&2
aws ecs wait services-stable \
	--cluster "${ECS_CLUSTER}" \
	--services "${ECS_SERVICE}" \
	--region "${AWS_REGION}"

echo "Final service state:" >&2
aws ecs describe-services \
	--cluster "${ECS_CLUSTER}" \
	--services "${ECS_SERVICE}" \
	--region "${AWS_REGION}" \
	--query 'services[0].{Status:status,Desired:desiredCount,Running:runningCount,Pending:pendingCount,TaskDefinition:taskDefinition,LatestEvent:events[0].message}' \
	--output json

echo "ECS rolling deployment completed for build ${BUILD_TAG}."