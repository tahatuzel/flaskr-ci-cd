output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.main.name
}

output "task_definition_family" {
  description = "ECS task definition family"
  value       = aws_ecs_task_definition.main.family
}
