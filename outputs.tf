output "bastion_public_ip" {
  value = module.bastion.public_ip
}

output "bastion_instance_id" {
  value = module.bastion.instance_id
}

output "db_private_ips" {
  value = [for i in module.db : i.private_ip]
}

output "db_instance_ids" {
  value = [for i in module.db : i.instance_id]
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "private_master_subnet_id" {
  value = module.vpc.private_master_subnet_id
}

output "private_replica_subnet_id" {
  value = module.vpc.private_replica_subnet_id
}

# NAT outputs for debugging + Ansible needs
output "nat_gateway_id" {
  value = module.vpc.nat_gateway_id
}

output "private_route_table_id" {
  value = module.vpc.private_route_table_id
}
