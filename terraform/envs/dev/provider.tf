// ======================================================
// Terraform provider configuration
// Dev environment
// ======================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  // Modern approach: Use a remote backend (S3) for state storage.
  // Stores state in S3 bucket and uses DynamoDB for state locking.
  backend "s3" {
    bucket         = "tf-state-cloud-1-ychun816"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "tf-lock-cloud-1"
    encrypt        = true
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile != "" ? var.aws_profile : null
}
