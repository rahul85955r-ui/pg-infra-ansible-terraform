project = "pg"
env     = "prod"
region  = "ap-northeast-1"

key_name        = "postgres-key"
public_key_path = "tmp/public_ssh_key.pub"
admin_cidr      = "223.190.82.187/32"

ami = "ami-0aec5ae807cea9ce0"

bastion_instance_type = "t3.micro"
db_instance_type      = "t3.small"

vpc_cidr = "10.0.0.0/16"

public_subnet_cidr          = "10.0.1.0/24"
private_master_subnet_cidr  = "10.0.2.0/24"
private_replica_subnet_cidr = "10.0.3.0/24"

public_az          = "ap-northeast-1a"
private_master_az  = "ap-northeast-1a"
private_replica_az = "ap-northeast-1c"
