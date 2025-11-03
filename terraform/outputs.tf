output "public_ip" {
  description = "Public IP address of the web instance"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS name of the web instance"
  value       = aws_instance.web.public_dns
}
