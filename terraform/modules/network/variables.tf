variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into EC2 (e.g., 1.2.3.4/32)"
  type        = string
}

variable "environment" {
  description = "Environment name used for tagging"
  type        = string
}
