output "environment" {
  description = "The deployed environment"
  value       = var.environment
}

output "frontend_url" {
  description = "URL to access the frontend"
  value       = "http://localhost:${var.frontend_port}"
}

output "backend_url" {
  description = "URL to access the backend"
  value       = "http://localhost:${var.backend_port}"
}

output "frontend_container_name" {
  description = "Name of the frontend container"
  value       = docker_container.frontend.name
}

output "backend_container_name" {
  description = "Name of the backend container"
  value       = docker_container.backend.name
}