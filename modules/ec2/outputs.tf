output "instance_id" {
  value = aws_instance.this.id
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "private_dns" {
  value = aws_instance.this.private_dns
}

output "public_ip" {
  value = try(aws_instance.this.public_ip, null)
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "root_volume_id" {
  value = aws_instance.this.root_block_device[0].volume_id
}
