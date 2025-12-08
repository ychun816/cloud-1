// ======================================================
// Terraform provider configuration
// root module
// terraform {} block declares provider versions and optional backend.
// provider "aws" configures the runtime connection.
// profile is optional, useful if you have multiple AWS CLI profiles.
// In multi-module projects, only the root module contains the provider block. Child modules reference it automatically.
// ======================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile != "" ? var.aws_profile : null
}
