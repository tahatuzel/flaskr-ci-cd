# Flaskr — CI/CD Blog Application

A full-stack blog application built with **Flask**, containerized with **Docker**, deployed to **AWS ECS Fargate** via a fully automated **GitLab CI/CD** pipeline, with infrastructure provisioned using **Terraform**.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Application Features](#application-features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Local Development](#local-development)
  - [Running with Docker](#running-with-docker)
  - [Running Tests](#running-tests)
- [Infrastructure (Terraform)](#infrastructure-terraform)
  - [AWS Resources](#aws-resources)
  - [Deploying Infrastructure](#deploying-infrastructure)
  - [Terraform Variables](#terraform-variables)
- [CI/CD Pipeline](#cicd-pipeline)
  - [Pipeline Stages](#pipeline-stages)
  - [Required CI/CD Variables](#required-cicd-variables)
- [License](#license)

---

## Overview

This project demonstrates a production-grade DevOps workflow around the classic [Flask Tutorial](https://flask.palletsprojects.com/tutorial/) blog application. Users can register, log in, and create/edit/delete blog posts. The focus is on the end-to-end delivery pipeline:

1. **Code** → Push to GitLab
2. **Test** → Automated pytest suite
3. **Build** → Docker image creation
4. **Push** → Image pushed to AWS ECR
5. **Deploy** → Rolling update on AWS ECS Fargate

---

## Architecture

```
┌──────────────┐       ┌──────────────────────────────────────────────────┐
│   Developer  │       │                    AWS Cloud                    │
│              │       │                                                  │
│  git push    │       │  ┌────────┐    ┌──────────┐    ┌─────────────┐  │
│      │       │       │  │  ECR   │    │   ALB    │    │ ECS Fargate │  │
│      ▼       │       │  │ (Image │◄───│ (Public  │───►│  (Private   │  │
│  ┌───────┐   │       │  │  Repo) │    │  HTTP)   │    │  Subnets)   │  │
│  │GitLab │   │       │  └────────┘    └──────────┘    └─────────────┘  │
│  │ CI/CD ├───┼──────►│                                                  │
│  └───────┘   │       │  ┌──────────────────────────────────────────┐   │
│              │       │  │         VPC (10.0.0.0/16)                │   │
│              │       │  │  Public Subnets  │  Private Subnets      │   │
│              │       │  │  (ALB, NAT GW)   │  (ECS Tasks)         │   │
│              │       │  └──────────────────────────────────────────┘   │
└──────────────┘       └──────────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer            | Technology                              |
| ---------------- | --------------------------------------- |
| **Application**  | Python 3.12, Flask, SQLite, Jinja2      |
| **WSGI Server**  | Waitress                                |
| **Packaging**    | Flit / pyproject.toml                   |
| **Testing**      | Pytest                                  |
| **Container**    | Docker (python:3.12-slim)               |
| **CI/CD**        | GitLab CI/CD (4 stages)                 |
| **IaC**          | Terraform ≥ 1.5, AWS Provider ~> 5.0   |
| **Cloud**        | AWS (VPC, ECR, ECS Fargate, ALB, IAM)   |

---

## Project Structure

```
.
├── flaskr/                     # Flask application package
│   ├── __init__.py             # Application factory
│   ├── auth.py                 # Authentication blueprint (register/login/logout)
│   ├── blog.py                 # Blog blueprint (CRUD operations)
│   ├── db.py                   # SQLite database layer
│   ├── schema.sql              # Database schema (user & post tables)
│   ├── static/                 # Static assets (CSS)
│   └── templates/              # Jinja2 templates
│       ├── base.html           # Base layout template
│       ├── auth/               # Auth templates (login, register)
│       └── blog/               # Blog templates (index, create, update)
│
├── tests/                      # Test suite
│   ├── conftest.py             # Pytest fixtures
│   ├── data.sql                # Test seed data
│   ├── test_auth.py            # Authentication tests
│   ├── test_blog.py            # Blog CRUD tests
│   ├── test_db.py              # Database tests
│   └── test_factory.py         # App factory tests
│
├── infrastructure/             # Terraform IaC
│   ├── main.tf                 # Root module — wires all child modules
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values (for CI/CD integration)
│   ├── provider.tf             # AWS provider configuration
│   └── modules/
│       ├── networking/         # VPC, subnets, IGW, NAT GW, route tables
│       ├── security/           # Security groups (ALB + ECS)
│       ├── ecr/                # ECR repository + lifecycle policy
│       ├── iam/                # ECS task execution & task roles
│       ├── alb/                # Application Load Balancer + target group
│       └── ecs/                # ECS cluster, task definition, service
│
├── Dockerfile                  # Multi-stage Docker build
├── .dockerignore               # Docker build exclusions
├── .gitlab-ci.yml              # GitLab CI/CD pipeline definition
├── pyproject.toml              # Python project metadata & dependencies
├── LICENSE.txt                 # BSD 3-Clause License
└── .gitignore                  # Git exclusions
```

---

## Application Features

- **User Registration** — Create an account with a unique username and hashed password
- **Login / Logout** — Session-based authentication using Flask sessions
- **Create Posts** — Authenticated users can publish blog posts
- **Edit Posts** — Authors can update their own posts
- **Delete Posts** — Authors can delete their own posts
- **SQLite Database** — Lightweight database initialized via `flask init-db`

---

## Getting Started

### Prerequisites

- **Python** 3.12+
- **Docker** (for containerized deployment)
- **Terraform** ≥ 1.5 (for infrastructure provisioning)
- **AWS CLI** configured with appropriate credentials
- **GitLab** account (for CI/CD)

### Local Development

```bash
# Clone the repository
git clone https://gitlab.com/tahatuzel-group/ci-cd-project.git
cd ci-cd-project

# Create a virtual environment
python -m venv .venv
source .venv/bin/activate   # Linux/macOS
.venv\Scripts\activate      # Windows

# Install the app in development mode
pip install -e .

# Initialize the database
flask --app flaskr init-db

# Run the development server
flask --app flaskr run --debug
```

The app will be available at **http://localhost:5000**.

### Running with Docker

```bash
# Build the image
docker build -t flaskr .

# Run the container
docker run -p 5000:5000 flaskr
```

The container uses **Waitress** as the production WSGI server, serving on port `5000`.

### Running Tests

```bash
# Install test dependencies
pip install -e ".[test]"

# Run the test suite
pytest tests/ -v
```

---

## Infrastructure (Terraform)

The `infrastructure/` directory contains a modular Terraform configuration that provisions the complete AWS environment.

### AWS Resources

| Module          | Resources Created                                                   |
| --------------- | ------------------------------------------------------------------- |
| **Networking**  | VPC, 2 public subnets, 2 private subnets, IGW, NAT Gateway, routes |
| **Security**    | ALB security group (HTTP :80), ECS security group (container port)  |
| **ECR**         | Container registry with image scanning & lifecycle policy (10 max)  |
| **IAM**         | ECS task execution role, ECS task role                              |
| **ALB**         | Application Load Balancer, target group, HTTP listener              |
| **ECS**         | Fargate cluster, task definition, service, CloudWatch log group     |

### Deploying Infrastructure

```bash
cd infrastructure

# Initialize Terraform
terraform init

# Preview the changes
terraform plan

# Apply the infrastructure
terraform apply
```

After `terraform apply`, the outputs will provide the values needed for GitLab CI/CD variables:

```bash
terraform output
# ecr_repository_url    → ECR_REPO_NAME
# ecs_cluster_name      → ECS_CLUSTER_NAME
# ecs_service_name      → ECS_SERVICE_NAME
# ecs_task_definition   → ECS_TASK_DEFINITION
# alb_dns_name          → Application URL
# aws_region            → AWS_DEFAULT_REGION
```

### Terraform Variables

| Variable          | Default        | Description                        |
| ----------------- | -------------- | ---------------------------------- |
| `aws_region`      | `eu-central-1` | AWS region                         |
| `project_name`    | `flaskr`       | Resource naming prefix             |
| `vpc_cidr`        | `10.0.0.0/16`  | VPC CIDR block                     |
| `container_port`  | `5000`         | Port the container listens on      |
| `cpu`             | `256`          | Fargate task CPU units             |
| `memory`          | `512`          | Fargate task memory (MiB)          |
| `desired_count`   | `1`            | Number of ECS tasks to run         |

---

## CI/CD Pipeline

The `.gitlab-ci.yml` defines a four-stage pipeline that runs on every push:

### Pipeline Stages

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌──────────┐
│  TEST   │────►│  BUILD  │────►│  PUSH   │────►│  DEPLOY  │
│         │     │         │     │         │     │          │
│ pytest  │     │ docker  │     │ ECR     │     │ ECS      │
│         │     │ build   │     │ push    │     │ update   │
└─────────┘     └─────────┘     └─────────┘     └──────────┘
```

1. **Test** — Installs dependencies and runs `pytest tests/ -v` on `python:3.12-slim`
2. **Build** — Builds the Docker image and saves it as a pipeline artifact (`image.tar`)
3. **Push** — Authenticates to AWS ECR and pushes the image tagged with both `commit SHA` and `latest`
4. **Deploy** — Registers a new ECS task definition with the updated image and triggers a rolling deployment

### Required CI/CD Variables

Set these in **GitLab → Settings → CI/CD → Variables**:

| Variable               | Description                         |
| ---------------------- | ----------------------------------- |
| `AWS_ACCESS_KEY_ID`    | AWS IAM access key                  |
| `AWS_SECRET_ACCESS_KEY`| AWS IAM secret key                  |
| `AWS_DEFAULT_REGION`   | AWS region (e.g. `eu-central-1`)    |
| `AWS_ACCOUNT_ID`       | AWS account ID                      |
| `ECR_REPO_NAME`        | ECR repository name                 |
| `ECS_CLUSTER_NAME`     | ECS cluster name                    |
| `ECS_SERVICE_NAME`     | ECS service name                    |
| `ECS_TASK_DEFINITION`  | ECS task definition family          |

> **Tip:** All values except AWS credentials can be obtained from `terraform output`.

---

## License

This project is licensed under the **BSD 3-Clause License**. See [LICENSE.txt](LICENSE.txt) for details.
