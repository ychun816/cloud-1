// Variable: aws_region
// - description: human-readable explanation used by `terraform plan` and docs
// - type: expected data type
// - default: fallback value when no override is provided
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

// Variable: aws_profile
// - optional: if set, Terraform/AWS provider will try the named profile in ~/.aws/credentials
// - when empty, Terraform uses environment credentials (AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY)
variable "aws_profile" {
  description = "Optional AWS CLI profile name"
  type        = string
  default     = ""
}

// Variable: instance_type
// - EC2 machine type used for the web instance (e.g., t3a.small, t3a.medium)
// - Choose smaller types for dev to save costs and larger types for prod for capacity
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3a.small"
}

// Variable: key_name
// - If you already created a KeyPair in AWS, set its name here so the instance will be accessible via SSH
// - If left empty, you can optionally have Terraform create an aws_key_pair from a local public key
variable "key_name" {
  description = "Name of an existing AWS key pair to use (optional). If empty, import-key-pair can be used."
  type        = string
  default     = ""
}

// Variable: public_key_path
// - Path on your workstation to the public SSH key file (e.g. ~/.ssh/id_ed25519.pub)
// - Used only if you enable the optional `aws_key_pair` resource that reads this file and uploads it to AWS
variable "public_key_path" {
  description = "Absolute path to the public key file; used if creating an aws_key_pair resource"
  type        = string
  default     = "/home/YOURUSER/.ssh/cloud1_id_ed25519.pub"
}
