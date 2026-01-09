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

  // Modern approach: Use a remote backend (S3) or local state inside the env directory.
  // For practice, we use local state inside this folder.
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile != "" ? var.aws_profile : null
}
