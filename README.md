# FA1 - Git-Based Infrastructure as Code and Multi-Environment Container Deployment

## Project Objective
This project demonstrates Infrastructure as Code (IaC) using Terraform to deploy a multi-container Docker application across three environments (QA, UAT, PROD) from a single Terraform codebase.

## Technologies Used
- **Terraform** (v1.0.0+) - For provisioning and managing Docker containers and images
- **Docker** - Container platform
- **nginx:alpine** - Frontend web server
- **python:3.12-slim** - Backend runtime
- **Flask** - Python web framework for the backend API

## Project Structure
```
FA1/
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   │
│   └── environments/
│       ├── qa.tfvars
│       ├── uat.tfvars
│       └── prod.tfvars
│
├── docker/
│   ├── frontend/
│   │   ├── Dockerfile
│   │   └── index.html
│   │
│   └── backend/
│       ├── Dockerfile
│       └── app.py
│
├── .gitignore
└── README.md
```

## Prerequisites
1. [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) installed (v1.0.0+)
2. [Docker](https://docs.docker.com/get-docker/) installed and running
3. Git installed (for version control)

## How to Check Docker
Verify Docker is running by executing:
```bash
docker version
```
You should see both client and server version information.

## How to Initialize Terraform
From the project root, navigate to the terraform directory and run:
```bash
cd terraform
terraform init
```
This will download the Docker provider (kreuzwerker/docker) and initialize the backend.

## How to Validate Terraform
After initializing, run:
```bash
terraform validate
```
This checks for any syntax errors in the Terraform configuration.

## How to Deploy QA
```bash
cd terraform
terraform plan -var-file="environments/qa.tfvars"
terraform apply -var-file="environments/qa.tfvars"
```
Confirm the apply by typing `yes` when prompted.

## How to Deploy UAT
```bash
cd terraform
terraform plan -var-file="environments/uat.tfvars"
terraform apply -var-file="environments/uat.tfvars"
```
Confirm the apply by typing `yes` when prompted.

## How to Deploy PROD
```bash
cd terraform
terraform plan -var-file="environments/prod.tfvars"
terraform apply -var-file="environments/prod.tfvars"
```
Confirm the apply by typing `yes` when prompted.

## How to Check Docker Containers
After any deployment, list running containers:
```bash
docker ps
```
You should see containers named like `frontend-qa`, `backend-qa`, etc.

## How to Access the Frontend
Open a web browser and navigate to:
- QA: http://localhost:8081
- UAT: http://localhost:8082
- PROD: http://localhost:8083

## How to Test the Backend
Use curl or a browser to test the backend endpoints:
- QA backend: http://localhost:5001/
- QA health: http://localhost:5001/health
- UAT backend: http://localhost:5002/
- UAT health: http://localhost:5002/health
- PROD backend: http://localhost:5003/
- PROD health: http://localhost:5003/health

## How the Same Terraform Code Supports Multiple Environments
The Terraform code in `main.tf`, `variables.tf`, and `outputs.tf` is generic and uses variables for environment-specific values. The actual values for these variables are provided in the `.tfvars` files located in the `environments/` directory. Each environment (QA, UAT, PROD) has its own `.tfvars` file that sets:
- `environment` (qa, uat, prod)
- `frontend_port` and `backend_port` (to avoid port conflicts)
- `frontend_image_name` and `backend_image_name` (base names for images, tagged with environment)
- `network_name` (Docker network name)

When running `terraform apply -var-file="environments/qa.tfvars"`, Terraform uses the values from `qa.tfvars` to populate the variables, thus creating a QA-specific deployment. The same applies to UAT and PROD.

## How to Destroy the Environment
To destroy a specific environment, run:
```bash
cd terraform
terraform destroy -var-file="environments/qa.tfvars"
```
Confirm the destroy by typing `yes` when prompted.
Repeat for UAT and PROD by changing the `.tfvars` file.

## Git Commands for Committing and Pushing the Project
Initialize the repository, add files, commit, and (if you have a remote) push:
```bash
git init
git add .
git commit -m "Initial FA1 implementation"
# If you have a remote repository, add it and push:
# git remote add origin <your-repository-url>
# git push -u origin main
```

## Validation
After creating the files, you can run:
```bash
cd terraform
terraform fmt -check   # checks formatting
terraform validate     # validates configuration
```
Then proceed with deployment as described above.

## Expected Output/Results
After deploying QA, you should see:
- Two Docker containers running: `frontend-qa` and `backend-qa`
- Frontend accessible at http://localhost:8081 showing the FA1 project title and environment info
- Backend API accessible at http://localhost:5001 returning JSON messages
- Health endpoint at http://localhost:5001/health returning `{"status":"healthy"}`

Similar results for UAT and PROD on their respective ports.

## Screenshots for College Assignment
1. Project structure in file explorer (showing the FA1 directory with subdirectories)
2. Docker containers running for all three environments (output of `docker ps` after deploying all three)
3. Frontend page in browser for each environment (showing environment name)
4. Backend API response in browser or curl for each environment
5. Backend health endpoint response in browser or curl for each environment
6. Terraform apply output showing resources being created
7. Terraform destroy output showing resources being destroyed

## Important Terraform Concepts for Viva
1. **Providers**: Explained the use of the `kreuzwerker/docker` provider to interact with Docker.
2. **Resources**: Defined `docker_image` to build images and `docker_container` to run containers.
3. **Variables**: Declared in `variables.tf` and assigned values via `.tfvars` files.
4. **Outputs**: Defined in `outputs.tf` to display useful information after apply.
5. **Dependency Management**: Used `depends_on` to ensure containers start after images are built and network is ready.
6. **Workspaces vs. tfvars**: Explained why we used `.tfvars` files instead of Terraform workspaces (simpler for this use case).
7. **State Management**: Mentioned that Terraform state is stored locally (`.tfstate` files) and how it tracks resources.
8. **Immutable Infrastructure**: How changing a variable and re-applying updates the deployment.
9. **Resource Naming**: How we used environment names in container names and image tags to avoid conflicts.
10. **Port Mapping**: How we mapped internal container ports to different host ports for each environment.

---
*Last updated: September 9, 2026*