# 🚀 Cloud DevOps App - Deployment Guide

Todo application with automated deployment on AWS via Terraform and GitHub Actions.

## 🏗️ Architecture

```
Frontend (React) → Nginx → Port 80
Backend (Express) → Node.js → Port 3005 → DynamoDB
```

**AWS Infrastructure:**
- EC2 t2.micro (Free Tier)
- DynamoDB Table (Free Tier)
- Security Groups
- VPC + Subnets

## 📦 Prerequisites

### Required Accounts
- **AWS Account**
- **Docker Hub Account** for image registry
- **GitHub Repository** with Actions enabled

## ⚙️ Initial Configuration

### 1. Configure AWS CLI
```bash
aws configure
# AWS Access Key ID: [Your key]
# AWS Secret Access Key: [Your secret key]  
# Default region: eu-west-1
```

### 2. Configure GitHub Secrets
In your GitHub repository → Settings → Secrets and variables → Actions:

| Secret | Description                     |
|--------|---------------------------------|
| `DOCKER_USERNAME` | Docker Hub username  |
| `DOCKER_PASSWORD` | Docker Hub password  |
| `AWS_ACCESS_KEY_ID` | AWS access key     |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |

## 🛠️ Available Scripts

### S3 Backend Terraform (One-time configuration)

#### Create S3 backend
```bash
# Windows
.\infra\scripts\setup-backend.ps1

# Linux/Mac
chmod +x infra/scripts/setup-backend.sh
./infra/scripts/setup-backend.sh
```

#### Delete S3 backend
```bash
# Windows
.\infra\scripts\destroy-backend.ps1

# Linux/Mac
chmod +x infra/scripts/destroy-backend.sh
./infra/scripts/destroy-backend.sh
```

### Local Deployment

#### Development
```bash
# Run with Docker Compose (local build)
docker-compose up --build

# Run in production (Docker Hub images)
DOCKER_USERNAME=your-username docker-compose -f docker-compose.prod.yml up
```

#### Manual build and push
```bash
# Windows
.\infra\scripts\build-and-push.ps1

# Linux/Mac  
chmod +x infra/scripts/build-and-push.sh
./infra/scripts/build-and-push.sh
```

## 🚀 Deployment

### Automatic Deployment (Recommended)
1. **Setup S3 backend** (once only):
   ```bash
   .\infra\scripts\setup-backend.ps1
   ```

2. **Push to main**:
   ```bash
   git add .
   git commit -m "feat: deploy application"
   git push origin main
   ```

3. **Follow the pipeline** in GitHub Actions

### Manual Deployment with Terraform and S3

```bash
# Setup S3 backend (ONCE ONLY):
.\infra\scripts\setup-backend.ps1

# Navigate to terraform folder
cd infra/terraform

# Initialize Terraform (first time or after backend change)
terraform init

# See planned changes
terraform plan

# Apply changes
terraform apply

# See created resources
terraform show

# See outputs (IP, DNS, URLs)
terraform output
```

## 🔧 Useful Terraform Commands

### Resource Management
```bash
# Destroy specific resource
terraform destroy -target=aws_instance.app

# Destroy entire infrastructure
terraform destroy

# Plan destruction
terraform plan -destroy

# Refresh state with AWS
terraform refresh
```

## 🔄 CI/CD Pipeline

The GitHub Actions pipeline triggers automatically on push to `main`:

### Pipeline Steps
1. **Build & Test** - Compilation and tests
2. **Docker Build & Push** - Build and push images to Docker Hub  
3. **Deploy** - Deploy to AWS with Terraform

### URLs after deployment
URLs are displayed in GitHub Actions logs:
- **Frontend**: `http://<PUBLIC_IP>/`
- **Backend API**: `http://<PUBLIC_IP>:3005/`

## 📁 Project Structure

```
.
├── client/                    # React Frontend + Vite
├── server/                    # Express Backend + DynamoDB  
├── infra/
│   ├── backend/               # S3 backend infrastructure
│   ├── terraform/             # Application infrastructure
│   └── scripts/               # Automation scripts
├── .github/workflows/         # CI/CD Pipeline
├── docker-compose.yml         # Local development
├── docker-compose.prod.yml    # Production with hub images
└── README.md                  # This file
```

---

🎯 **Once the S3 backend is configured, a simple `git push` automatically deploys your application to AWS!** 🚀
