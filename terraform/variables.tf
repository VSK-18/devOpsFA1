variable "environment" {
  description = "Deployment environment (qa, uat, prod)"
  type        = string
}

variable "frontend_port" {
  description = "Port for frontend container on host"
  type        = number
}

variable "backend_port" {
  description = "Port for backend container on host"
  type        = number
}

variable "frontend_image_name" {
  description = "Name for the frontend Docker image"
  type        = string
}

variable "backend_image_name" {
  description = "Name for the backend Docker image"
  type        = string
}

# Optional: Docker network name
variable "network_name" {
  description = "Docker network name"
  type        = string
  default     = "fa1_network"
}