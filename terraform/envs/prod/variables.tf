// ======================================================
// Terraform input variables
// Dev environment
// ======================================================

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Optional AWS CLI profile name"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances to deploy"
  type        = number
  default     = 1
  # default     = 2
}

variable "key_name" {
  description = "Name of an existing AWS key pair"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into EC2"
  type        = string
  default     = "0.0.0.0/0"
}

variable "environment" {
  description = "Environment name used for tagging"
  type        = string
  default     = "dev"
}

variable "public_key_path" {
  description = "Path to public key for Terraform to create a keypair"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
