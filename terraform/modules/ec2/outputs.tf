output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.web[*].id
}

output "public_ips" {
  description = "Public IPs of the EC2 instances"
  value       = aws_instance.web[*].public_ip
}

output "public_dns" {
  description = "Public DNS of the EC2 instances"
  value       = aws_instance.web[*].public_dns
}
