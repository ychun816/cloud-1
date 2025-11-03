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
  default     = "t3a.small"
}

variable "key_name" {
  description = "Name of an existing AWS key pair to use (optional). If empty, import-key-pair can be used."
  type        = string
  default     = ""
}

variable "public_key_path" {
  description = "Absolute path to the public key file; used if creating an aws_key_pair resource"
  type        = string
  default     = "/home/youruser/.ssh/cloud1_id_ed25519.pub"
}
