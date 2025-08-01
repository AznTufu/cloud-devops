region = "eu-west-1"
availability_zones = ["eu-west-1a", "eu-west-1b"]
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
app_name = "cloud-devops-app"
environment = "dev"
public_subnet_count = 2
private_subnet_count = 2

# Docker images (will be updated by CI/CD)
