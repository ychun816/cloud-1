// Terraform provider configuration (organized + documented)
// ------------------------------------------------------------------
// This file contains two different, but related, blocks:
// 1) `terraform {}` — declares Terraform-level requirements (which provider
//    plugins and versions to download). It does NOT configure a connection
//    to the cloud. Pinning providers here improves reproducibility.
// 2) `provider "aws" {}` — configures the AWS provider instance Terraform
//    will use at runtime (region, profile, endpoints, etc.). This is the
//    configuration that actually tells the provider how to authenticate and
//    which region to operate in.
//
// Terraform will read all `*.tf` files in the directory. Splitting these
// declarations into a `provider.tf` (or `providers.tf` / `versions.tf`) file
// is purely organizational — it makes the repo easier to navigate.
// ------------------------------------------------------------------

terraform {
  required_providers {
    // Tell Terraform which provider plugin to download and the allowed
    // version range. This pins the provider to the HashiCorp AWS provider
    // v5.x series for reproducible runs.
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  // You can also add `required_version` or backend configuration here, for
  // example a remote S3 backend. Keep backend settings out of VCS if they
  // contain secrets — instead, use environment variables or CI secrets.
}

// Provider configuration: this block configures how Terraform will talk to
// AWS at runtime. You can provide credentials via environment variables,
// an AWS CLI profile, or other supported mechanisms. Avoid hardcoding
// credentials in this file.
provider "aws" {
  region  = var.aws_region
  # Optionally uncomment to use a named AWS CLI profile from ~/.aws/credentials
  # profile = var.aws_profile

  // If you need multiple accounts/regions, create additional provider blocks
  // with `alias` and reference them from resources, e.g.:
  //
  // provider "aws" {
  //   alias  = "eu"
  //   region = "eu-west-1"
  // }
  // resource "aws_instance" "europe" {
  //   provider = aws.eu
  //   ...
  // }
}
