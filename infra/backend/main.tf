# Script pour créer l'infrastructure de base pour le backend Terraform S3
# Ce script doit être exécuté UNE SEULE FOIS avant d'utiliser le backend S3

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name

  tags = {
    Name        = "Terraform State Bucket"
    Environment = var.environment
    Purpose     = "terraform-backend"
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = var.environment
    Purpose     = "terraform-backend"
    Project     = var.project_name
  }
}

# Outputs
output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
  description = "Nom du bucket S3 pour le state Terraform"
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
  description = "ARN du bucket S3"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_state_lock.name
  description = "Nom de la table DynamoDB pour le lock"
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.terraform_state_lock.arn
  description = "ARN de la table DynamoDB"
}

output "backend_config" {
  value = {
    bucket         = aws_s3_bucket.terraform_state.bucket
    region         = var.aws_region
    dynamodb_table = aws_dynamodb_table.terraform_state_lock.name
  }
  description = "Configuration complète du backend S3"
}
