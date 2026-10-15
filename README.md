# FA1 & FA2 — Infrastructure as Code, CI/CD, Kubernetes & Monitoring

## Project Overview

This repository demonstrates Infrastructure as Code (IaC), containerization, automated testing, Continuous Integration and Continuous Deployment (CI/CD), Kubernetes orchestration, and monitoring.

The project is divided into two parts:

- **FA1:** Provision and deploy a multi-container Docker application across QA, UAT, and PROD environments using Terraform.
- **FA2:** Automate application testing, Docker image builds, and Kubernetes deployment using Jenkins, with Prometheus and Grafana for monitoring.

## Technologies Used

| Technology | Purpose |
|---|---|
| Terraform | Infrastructure as Code for multi-environment Docker deployment |
| Docker | Containerization of frontend, backend, and Jenkins tooling |
| Flask | Backend REST API |
| Nginx | Frontend web server |
| Jenkins | CI/CD automation |
| Git & GitHub | Source control and pipeline source |
| Kubernetes | Container orchestration |
| Prometheus | Metrics collection and querying |
| Grafana | Monitoring dashboards and visualization |
| Helm | Installation and configuration of the monitoring stack |
| Python unittest | Automated backend API tests |

## Project Structure

```text
devOpsFA1/
├── docker/
│   ├── frontend/
│   │   ├── Dockerfile
│   │   └── index.html
│   └── backend/
│       ├── Dockerfile
│       ├── app.py
│       ├── Dockerfile.test
│       └── test_app.py
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── environments/
│       ├── qa.tfvars
│       ├── uat.tfvars
│       └── prod.tfvars
├── k8s/
│   ├── backend.yaml
│   └── frontend.yaml
├── jenkins/
│   └── Dockerfile
├── monitoring/
│   └── dashboards/
│       └── fa2-kubernetes-dashboard.json
├── Jenkinsfile
├── .gitignore
└── README.md
```

*Note: The structure above describes the intended organization. Verify that every listed file exists in the repository before submission.*

---

# Part 1 — FA1: Terraform and Multi-Environment Deployment

## Objective

Deploy the frontend and backend containers across three environments using a single reusable Terraform configuration.

### Prerequisites

- Docker installed and running
- Terraform v1.0.0 or later
- Git installed

Verify Docker:

```bash
docker version
```

### Initialize and validate Terraform

From the repository root:

```bash
cd terraform
terraform init
terraform fmt -check
terraform validate
```

### Deploy QA

```bash
terraform plan -var-file="environments/qa.tfvars"
terraform apply -var-file="environments/qa.tfvars"
```

### Deploy UAT

```bash
terraform plan -var-file="environments/uat.tfvars"
terraform apply -var-file="environments/uat.tfvars"
```

### Deploy PROD

```bash
terraform plan -var-file="environments/prod.tfvars"
terraform apply -var-file="environments/prod.tfvars"
```

Review the proposed changes before confirming each `terraform apply` operation.

### Access the environments

| Environment | Frontend | Backend API | Health |
|---|---|---|---|
| QA | http://localhost:8081 | http://localhost:5001/ | http://localhost:5001/health |
| UAT | http://localhost:8082 | http://localhost:5002/ | http://localhost:5002/health |
| PROD | http://localhost:8083 | http://localhost:5003/ | http://localhost:5003/health |

The URLs above apply when the corresponding Terraform deployments are running with the documented port mappings.

### Check running containers

```bash
docker ps
```

### Destroy an environment

For QA:

```bash
cd terraform
terraform destroy -var-file="environments/qa.tfvars"
```

Repeat with `uat.tfvars` or `prod.tfvars` to destroy the corresponding environment.

**Important:** Terraform uses its state file to track managed resources. Keep the state file private and do not commit it to Git.

---

# Part 2 — FA2: Jenkins CI/CD Pipeline

## Objective

Automate the software delivery workflow from source control through testing, container image creation, Kubernetes deployment, and deployment verification.

## CI/CD Architecture

```text
GitHub Repository
       |
       v
Jenkins Pipeline
       |
       v
Checkout Source Code
       |
       v
Build Backend Test Image
       |
       v
Run Automated Tests
       |
       v
Build Frontend and Backend Images
       |
       v
Deploy Images to Kubernetes
       |
       v
Verify Deployment Rollouts
       |
       v
Prometheus and Grafana Monitoring
```

## Jenkins Pipeline Stages

The `Jenkinsfile` defines the following stages:

1. **Checkout:** Retrieve the project source code from GitHub.
2. **Test Backend:** Build a dedicated test image and run automated Flask API tests.
3. **Build Docker Images:** Build frontend and backend images tagged with the Jenkins build number.
4. **Deploy to Kubernetes:** Update the frontend and backend Kubernetes deployments.
5. **Verify Deployment:** Wait for Kubernetes rollouts and display deployments, pods, and services.

The pipeline also uses `disableConcurrentBuilds()` to prevent concurrent pipeline executions and `pollSCM` to check for repository changes periodically.

## Backend Tests

The backend tests use Flask's test client and Python's `unittest` framework to check:

- The `/` endpoint returns the expected API response.
- The `/health` endpoint returns a healthy status.

Run the tests through the Jenkins pipeline or build and execute the test image manually:

```bash
docker build \
  -t fa2-backend-test \
  -f docker/backend/Dockerfile.test \
  docker/backend

docker run --rm fa2-backend-test
```

## Configure Jenkins

1. Open the Jenkins dashboard.
2. Create a Pipeline job.
3. Select **Pipeline script from SCM**.
4. Select Git as the SCM.
5. Configure the repository URL:

   `https://github.com/VSK-18/devOpsFA1.git`

6. Set the branch to `*/main`.
7. Set the script path to `Jenkinsfile`.
8. Save and run **Build Now**.

The Jenkins runtime must have access to Docker and Kubernetes, with the necessary permissions and configuration.

## Verify the pipeline

Review the Jenkins console output and confirm that the checkout, testing, image-build, deployment, and rollout-verification stages succeed.

---

# Part 3 — FA2: Kubernetes Deployment

## Objective

Deploy the frontend and backend as Kubernetes workloads.

The project contains Kubernetes manifests for the frontend and backend in the `k8s/` directory.

### Check the Kubernetes cluster

```bash
kubectl config current-context
kubectl get nodes
```

For the local Docker Desktop setup, the expected context is `docker-desktop`.

### Deploy the application

If the Kubernetes manifests have not already been applied:

```bash
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml
```

### Verify deployments and pods

```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

### Access the application

The configured NodePort services use:

- Frontend: http://localhost:30080
- Backend health endpoint: http://localhost:30081/health

These addresses assume the Kubernetes manifests use NodePorts `30080` and `30081` and the deployments are healthy.

The Jenkins pipeline deploys image tags based on the build number. Ensure that the image tags in the manifests or deployment specifications match the images built by Jenkins.

---

# Part 4 — FA2: Prometheus and Grafana Monitoring

## Objective

Collect Kubernetes and container metrics using Prometheus and visualize them in Grafana.

## Monitoring Architecture

```text
Kubernetes Cluster
       |
       v
Prometheus
       |
       v
Grafana Dashboard
       |
       v
CPU, Memory, Pod and Target Metrics
```

## Installation

The monitoring stack was installed in the `monitoring` namespace using Helm and the `kube-prometheus-stack` chart.

Check the monitoring resources:

```bash
kubectl get pods -n monitoring
kubectl get services -n monitoring
```

The Grafana service is configured as a NodePort service.

### Access Grafana

Open:

http://localhost:30300

Retrieve the configured Grafana username:

```powershell
kubectl get secret monitoring-grafana -n monitoring -o jsonpath="{.data.admin-user}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

Retrieve the configured password:

```powershell
kubectl get secret monitoring-grafana -n monitoring -o jsonpath="{.data.admin-password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

Keep these credentials private.

## Grafana Dashboard

The dashboard is intended to display:

- Prometheus target status
- Running Kubernetes pods
- Container CPU usage
- Container memory usage

The following PromQL queries were verified to return metrics in the current setup.

### CPU usage

```promql
rate(container_cpu_usage_seconds_total[5m])
```

### Container memory

```promql
container_memory_working_set_bytes
```

The queries are intentionally unfiltered because the label filters previously tested returned no data in this environment.

### Check Prometheus

To access Prometheus locally:

```powershell
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090
```

Then open:

http://localhost:9090

Use the Prometheus expression browser to execute queries and inspect available metrics.

## Node Exporter limitation

In the current Docker Desktop Kubernetes environment, the Prometheus Node Exporter pod encountered a host-mount error:

```text
path / is mounted on / but it is not a shared or slave mount
```

Therefore, host-level Node Exporter metrics are not currently verified. This does not by itself indicate that the application deployments, Prometheus, or Grafana have failed.

---

# Git Workflow

Check the current changes:

```bash
git status
```

Stage intended project files:

```bash
git add Jenkinsfile .gitignore docker k8s jenkins monitoring terraform README.md
```

Review what will be committed:

```bash
git diff --cached
```

Commit and push:

```bash
git commit -m "Document FA1 infrastructure and FA2 CI/CD monitoring"
git push origin main
```

Never commit passwords, API keys, Jenkins backup archives, Terraform state files, or other secrets.

---

# Troubleshooting

### Jenkins cannot connect to Docker

Check Docker from the Jenkins container and verify that the Docker socket is mounted and accessible:

```bash
docker version
```

### Jenkins cannot access Kubernetes

Check the Kubernetes context and node status:

```bash
kubectl config current-context
kubectl get nodes
```

### Kubernetes pods are not running

Inspect the pod status and logs:

```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

For resources in the monitoring namespace, include `-n monitoring`.

### Grafana shows no data

1. Verify that the Prometheus data source exists in Grafana.
2. Test the query directly in Prometheus.
3. Inspect the metric labels and adapt panel queries to the metrics available in the environment.

---

# Screenshots for College Submission

Capture evidence of the actual running implementation:

1. Project directory structure.
2. Terraform initialization and validation.
3. Terraform deployment of QA, UAT, and PROD, if demonstrated.
4. Docker containers for the three environments.
5. Frontend pages for the environments.
6. Backend API and health endpoint responses.
7. Jenkins pipeline showing successful stages.
8. Backend automated test results.
9. Kubernetes deployments, pods, and services.
10. Grafana dashboard showing CPU, memory, running pods, and Prometheus target status.
11. GitHub repository showing the committed project files.

Only include screenshots of stages and results that you have actually executed.

---

# Important Concepts for Viva

1. **Infrastructure as Code:** Managing infrastructure through declarative configuration.
2. **Terraform providers:** Connecting Terraform to infrastructure platforms such as Docker.
3. **Terraform resources:** Defining Docker images, containers, and networks.
4. **Variables and `.tfvars`:** Reusing the same Terraform code with environment-specific settings.
5. **Terraform state:** Tracking managed resources and their attributes.
6. **Docker images and containers:** Packaging and running applications.
7. **CI/CD:** Automating testing, building, and deployment.
8. **Jenkins Pipeline:** Defining delivery stages in a `Jenkinsfile`.
9. **Automated testing:** Detecting backend regressions before deployment.
10. **Kubernetes deployments:** Managing application replicas and updates.
11. **Kubernetes services:** Providing stable access to application workloads.
12. **Prometheus:** Collecting and querying time-series metrics using PromQL.
13. **Grafana:** Visualizing metrics in dashboards.
14. **Helm:** Installing and managing Kubernetes applications using charts.
15. **Version control:** Tracking configuration and application changes with Git.

---

## Expected Outcomes

The project demonstrates:

- Reusable Terraform configurations for multi-environment Docker deployments.
- Containerized frontend and backend services.
- Automated backend testing.
- Jenkins-based CI/CD from GitHub.
- Kubernetes deployment and rollout verification.
- Prometheus metrics querying.
- Grafana dashboard visualization.
- Version-controlled infrastructure and deployment configuration.

**Repository:** https://github.com/VSK-18/devOpsFA1

*Documentation updated: October 2026.*
