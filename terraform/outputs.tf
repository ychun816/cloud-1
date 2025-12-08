
// ======================================================
// Terraform outputs
// Terraform outputs are useful because they let you see important values after terraform apply without going into the AWS console
// ======================================================

// Public IP of the EC2 instance
output "instance_public_ip" {
  description = "Public IP address of the web EC2 instance"
  value       = aws_instance.web.public_ip
}

// Public DNS of the EC2 instance
output "instance_public_dns" {
  description = "Public DNS name of the web EC2 instance"
  value       = aws_instance.web.public_dns
}

// EC2 instance ID
output "instance_id" {
  description = "ID of the web EC2 instance"
  value       = aws_instance.web.id
}

// Security group ID (optional, if you want to reference elsewhere)
output "security_group_id" {
  description = "ID of the security group for the web EC2 instance"
  value       = aws_security_group.web_sg.id
}

