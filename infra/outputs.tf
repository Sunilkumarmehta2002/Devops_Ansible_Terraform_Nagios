output "web_public_ip" {
  value = aws_instance.web.public_ip
}

output "api_public_ip" {
  value = aws_instance.api.public_ip
}

output "nagios_public_ip" {
  value = aws_instance.nagios.public_ip
}
