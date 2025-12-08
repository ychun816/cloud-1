// ======================================================
// Terraform input variables
// ======================================================

// AWS region to deploy into
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

// Optional AWS CLI profile
variable "aws_profile" {
  description = "Optional AWS CLI profile name"
  type        = string
  default     = ""
}

// EC2 instance type (t3a.small for dev, t2.micro also works)
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3a.small"
}

// Name of an existing AWS key pair
variable "key_name" {
  description = "sophia_mac"
  type        = string
}

// Allowed CIDR for SSH access
variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into EC2"
  type        = string
  default     = "YOUR_IP/32"
}

// ======================================================
// OPTIONAL 
// ======================================================
// Optional environment label for tagging
// variable "environment" {
//   description = "Environment name (used for tagging, Environment label for tags)"
//   type        = string
//   default     = "dev"
// }

// Optional path to public key if Terraform should create a key pair
// variable "public_key_path" {
//   description = "Path to public key for Terraform to create a keypair (optional)"
//   type        = string
//   default     = "~/.ssh/id_ed25519.pub"
// }
