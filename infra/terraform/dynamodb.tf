# DynamoDB Table pour les todos
resource "aws_dynamodb_table" "todos_table" {
  name           = "${var.app_name}-todos"
  billing_mode   = "PAY_PER_REQUEST" # Mode gratuit
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S" # String
  }

  tags = {
    Name        = "${var.app_name}-todos-table"
    Environment = "dev"
    Project     = var.app_name
  }
}

# IAM Role pour EC2 pour accéder à DynamoDB
resource "aws_iam_role" "ec2_dynamodb_role" {
  name = "${var.app_name}-ec2-dynamodb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "${var.app_name}-ec2-role"
    Project = var.app_name
  }
}

# IAM Policy pour DynamoDB
resource "aws_iam_role_policy" "ec2_dynamodb_policy" {
  name = "${var.app_name}-ec2-dynamodb-policy"
  role = aws_iam_role.ec2_dynamodb_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.todos_table.arn
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.app_name}-ec2-profile"
  role = aws_iam_role.ec2_dynamodb_role.name

  tags = {
    Name    = "${var.app_name}-ec2-profile"
    Project = var.app_name
  }
}
