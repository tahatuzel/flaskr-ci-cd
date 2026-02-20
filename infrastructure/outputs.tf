output "ecr_repository_url" {
  description = "ECR repository URL (use as ECR_REPO_NAME in GitLab CI/CD)"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = module.ecr.repository_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name (use as ECS_CLUSTER_NAME in GitLab CI/CD)"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name (use as ECS_SERVICE_NAME in GitLab CI/CD)"
  value       = module.ecs.service_name
}

output "ecs_task_definition_family" {
  description = "ECS task definition family (use as ECS_TASK_DEFINITION in GitLab CI/CD)"
  value       = module.ecs.task_definition_family
}

output "alb_dns_name" {
  description = "ALB DNS name to access the application"
  value       = module.alb.alb_dns_name
}

output "aws_region" {
  description = "AWS region (use as AWS_DEFAULT_REGION in GitLab CI/CD)"
  value       = var.aws_region
}
