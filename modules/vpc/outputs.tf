output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public_1a.id
}

output "private_master_subnet_id" {
  value = aws_subnet.private_master_1a.id
}

output "private_replica_subnet_id" {
  value = aws_subnet.private_replica_1c.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}

output "private_route_table_id" {
  value = aws_route_table.private_rt.id
}

