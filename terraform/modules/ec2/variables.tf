variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of existing AWS key pair"
  type        = string
}
variable "public_key_path" {
  description = "Path to local public key used to create an AWS key pair when key_name is empty"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name used for tagging"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs to attach to the instance"
  type        = list(string)
}
