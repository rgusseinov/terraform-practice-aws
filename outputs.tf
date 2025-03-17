output "dev_instance_public_ip" {
  value = aws_instance.my_instance[0].public_ip
}

output "staging_instance_public_ip" {
  value = aws_instance.my_instance[1].public_ip
}