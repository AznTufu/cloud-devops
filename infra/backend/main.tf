# Script pour créer l'infrastructure de base pour le backend Terraform S3
# Ce script doit être exécuté UNE SEULE FOIS avant d'utiliser le backend S3

terraform {
  # c'est pour créer les ressources du backend
}

provider "aws" {
  region = "eu-west-1"
}

# Bucket S3 pour stocker le state Terraform
resource "aws_s3_bucket" "terraform_state" {
  bucket = "cloud-devops-terraform-state-bucket"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "infrastructure"
    Purpose     = "terraform-backend"
  }
}

# Versioning du bucket S3
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Chiffrement du bucket S3
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloquer l'accès public au bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Table DynamoDB pour le lock du state
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "infrastructure"
    Purpose     = "terraform-backend"
  }
}

# Outputs
output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
  description = "Nom du bucket S3 pour le state Terraform"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_state_lock.name
  description = "Nom de la table DynamoDB pour le lock"
}
