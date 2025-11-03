// Terraform AWS provider (skeleton). Do NOT store credentials in this file.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  # Use a profile or environment credentials. Do NOT hardcode secrets here.
  # profile = var.aws_profile
}
