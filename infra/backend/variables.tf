variable "aws_region" {
  description = "La région AWS pour les ressources backend"
  type        = string
  default     = "eu-west-1"
}

variable "bucket_name" {
  description = "Nom du bucket S3 pour le state Terraform"
  type        = string
  default     = "cloud-devops-terraform-state-bucket"
}

variable "dynamodb_table_name" {
  description = "Nom de la table DynamoDB pour le locking"
  type        = string
  default     = "terraform-state-lock"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "cloud-devops"
}

variable "environment" {
  description = "Environnement (infrastructure pour le backend)"
  type        = string
  default     = "infrastructure"
}
