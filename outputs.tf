output "instance_public_ip" {
  value = aws_eip.linux_lab.public_ip
}

output "instance_id" {
  value = aws_instance.linux_lab.id
}
