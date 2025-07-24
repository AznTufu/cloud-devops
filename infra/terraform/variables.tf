variable "region" {
  description = "The AWS region to deploy the resources"
  type        = string
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "cloud-devops-app"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
}

variable "public_subnet_count" {
  description = "Number of public subnets"
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets"
  type        = number
  default     = 2
}

variable "docker_hub_username" {
  description = "Docker Hub username"
  type        = string
  default     = "romainparisot"
}

variable "server_image_tag" {
  description = "Tag for the server Docker image"
  type        = string
  default     = "latest"
}

variable "client_image_tag" {
  description = "Tag for the client Docker image"
  type        = string
  default     = "latest"
}

# Variables pour le backend S3 (utiles pour la documentation et les outputs)
variable "terraform_state_bucket" {
  description = "Nom du bucket S3 utilisé pour le state Terraform"
  type        = string
  default     = "cloud-devops-terraform-state-bucket"
}

variable "terraform_state_key" {
  description = "Clé du fichier state dans le bucket S3"
  type        = string
  default     = "terraform/state/terraform.tfstate"
}
