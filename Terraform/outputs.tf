output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.public.id
}

output "security_group_id" {
  value = aws_security_group.web.id
}

output "instance_id" {
  value = aws_instance.web.id
}

output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "instance_private_ip" {
  value = aws_instance.web.private_ip
}

output "application_url" {
  value = "http://${aws_instance.web.public_ip}"
}

output "ssh_command" {
  value = "ssh -i <your-key.pem> ec2-user@${aws_instance.web.public_ip}"
}
