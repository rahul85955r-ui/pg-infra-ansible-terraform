##############################
# VPC MODULE
##############################
module "vpc" {
  source = "./modules/vpc"

  prefix                    = var.prefix
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidr       = var.public_subnet_cidr
  private_master_subnet_cidr  = var.private_master_subnet_cidr
  private_replica_subnet_cidr = var.private_replica_subnet_cidr
  public_az                = var.public_az
  private_az               = var.private_az
  env                      = var.env

  tags = {
    Project = "pg"
    ManagedBy = "terraform"
    Env = var.env
  }
}


##############################
# SSH KEY
##############################
resource "aws_key_pair" "main" {
  key_name   = "postgres-key"
  public_key = file("${path.module}/keys/postgres-key.pub")

  tags = {
    Project   = "pg"
    Env       = var.env
    ManagedBy = "terraform"
  }
}


##############################
# BASTION HOST
##############################
module "bastion" {
  source = "./modules/ec2"

  name_tag       = "pg-${var.env}-bastion"
  role           = "bastion"
  env            = var.env
  ami            = var.ami
  instance_type  = "t3.micro"
  subnet_id      = module.vpc.public_subnet_id
  key_name       = aws_key_pair.main.key_name
  associate_public_ip = true

  ingress_rules = [
    {
      description = "SSH from Anywhere"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  user_data = null
  tags = {
    Project = "pg"
    ManagedBy = "terraform"
  }
}


##############################
# POSTGRES MASTER
##############################
module "pg_master" {
  source = "./modules/ec2"

  name_tag      = "pg-${var.env}-db-master"
  role          = "master"
  env           = var.env
  ami           = var.ami
  instance_type = "t3.small"
  subnet_id     = module.vpc.private_master_subnet_id
  key_name      = aws_key_pair.main.key_name
  associate_public_ip = false

  ingress_rules = [
    # SSH only via bastion
    {
      description     = "SSH from Bastion"
      protocol        = "tcp"
      from_port       = 22
      to_port         = 22
      security_groups = [module.bastion.security_group_id]
    },

    # Allow PostgreSQL from Replica
    {
      description     = "Postgres Replication"
      protocol        = "tcp"
      from_port       = 5432
      to_port         = 5432
      security_groups = [module.pg_replica.security_group_id]
    }
  ]

  tags = {
    Project = "pg"
    ManagedBy = "terraform"
  }
}


##############################
# POSTGRES REPLICA
##############################
module "pg_replica" {
  source = "./modules/ec2"

  name_tag      = "pg-${var.env}-db-replica"
  role          = "replica"
  env           = var.env
  ami           = var.ami
  instance_type = "t3.small"
  subnet_id     = module.vpc.private_replica_subnet_id
  key_name      = aws_key_pair.main.key_name
  associate_public_ip = false

  ingress_rules = [
    # SSH via Bastion only
    {
      description     = "SSH from Bastion"
      protocol        = "tcp"
      from_port       = 22
      to_port         = 22
      security_groups = [module.bastion.security_group_id]
    },

    # Allow PostgreSQL from Master
    {
      description     = "PostgreSQL from Master"
      protocol        = "tcp"
      from_port       = 5432
      to_port         = 5432
      security_groups = [module.pg_master.security_group_id]
    }
  ]

  tags = {
    Project = "pg"
    ManagedBy = "terraform"
  }
}


##############################
# OUTPUTS
##############################
output "bastion_public_ip" {
  value = module.bastion.public_ip
}

output "db_private_ips" {
  value = [
    module.pg_master.private_ip,
    module.pg_replica.private_ip
  ]
}

output "db_instance_ids" {
  value = [
    module.pg_master.instance_id,
    module.pg_replica.instance_id
  ]
}
