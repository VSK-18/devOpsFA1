terraform {
  required_version = ">= 1.0.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  # Use default Docker socket (Unix) or named pipe (Windows)
  # On Windows, you might need to set DOCKER_HOST or use the default
  # We'll rely on the default which works for most setups
}

# Build frontend Docker image
resource "docker_image" "frontend" {
  name         = "${var.frontend_image_name}:${var.environment}"
  build {
    context = "${path.module}/../docker/frontend"
  }
}

# Build backend Docker image
resource "docker_image" "backend" {
  name         = "${var.backend_image_name}:${var.environment}"
  build {
    context = "${path.module}/../docker/backend"
  }
}

# Create a Docker network (optional but good practice)
resource "docker_network" "fa1" {
  name = var.network_name
}

# Run frontend container
resource "docker_container" "frontend" {
  name  = "frontend-${var.environment}"
  image = docker_image.frontend.name
  ports {
    internal = 80
    external = var.frontend_port
  }
  networks_advanced {
    name = docker_network.fa1.name
  }
  depends_on = [
    docker_network.fa1,
    docker_image.frontend
  ]
}

# Run backend container
resource "docker_container" "backend" {
  name  = "backend-${var.environment}"
  image = docker_image.backend.name
  env = [
    "ENVIRONMENT=${var.environment}"
  ]
  ports {
    internal = 5000
    external = var.backend_port
  }
  networks_advanced {
    name = docker_network.fa1.name
  }
  depends_on = [
    docker_network.fa1,
    docker_image.backend
  ]
}