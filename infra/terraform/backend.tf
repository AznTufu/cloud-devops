terraform {
  backend "s3" {
    bucket         = "cloud-devops-terraform-state-bucket"
    key            = "terraform/state/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
