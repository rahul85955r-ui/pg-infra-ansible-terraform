############################################
# LOCAL TAGS
############################################
locals {
  common_tags = {
    Project   = var.project
    Env       = var.env
    ManagedBy = "terraform"
  }
}

############################################
# SSH KEYPAIR (PUBLIC KEY FROM JENKINS)
############################################
resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = file("${path.root}/${var.public_key_path}")
  tags       = local.common_tags
}

############################################
# VPC MODULE
############################################
module "vpc" {
  source = "./modules/vpc"

  prefix                      = var.project
  vpc_cidr                    = var.vpc_cidr
  public_subnet_cidr          = var.public_subnet_cidr
  private_master_subnet_cidr  = var.private_master_subnet_cidr
  private_replica_subnet_cidr = var.private_replica_subnet_cidr

  public_az          = var.public_az
  private_master_az  = var.private_master_az
  private_replica_az = var.private_replica_az

  tags = local.common_tags
}

############################################
# BASTION HOST
############################################
module "bastion" {
  source = "./modules/ec2"

  prefix   = var.project
  name_tag = "${var.project}-${var.env}-bastion"
  role     = "bastion"
  env      = var.env

  ami           = var.ami
  instance_type = var.bastion_instance_type
  subnet_id     = module.vpc.public_subnet_id
  vpc_id        = module.vpc.vpc_id
  key_name      = aws_key_pair.main.key_name
  sg_name       = "bastion-sg"

  associate_public_ip = true

  root_volume_size = 20
  root_volume_type = "gp3"

  ingress_rules = [
    {
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = [var.admin_cidr]
      security_groups = []
      description     = "SSH from Admin"
    }
  ]

  tags = local.common_tags
}

############################################
# DATABASE INSTANCES (MASTER + REPLICA)
############################################
module "db" {
  source = "./modules/ec2"
  count  = 2

  prefix   = var.project
  name_tag = "${var.project}-${var.env}-db-${count.index == 0 ? "master" : "replica"}"
  role     = count.index == 0 ? "master" : "replica"
  env      = var.env

  ami           = var.ami
  instance_type = var.db_instance_type

  subnet_id = count.index == 0 ? module.vpc.private_master_subnet_id : module.vpc.private_replica_subnet_id

  vpc_id        = module.vpc.vpc_id
  key_name      = aws_key_pair.main.key_name
  sg_name       = "db-${count.index == 0 ? "master" : "replica"}-sg"
  associate_public_ip = false

  root_volume_size = 30
  root_volume_type = "gp3"

  ingress_rules = [
    {
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.bastion.security_group_id]
      description     = "SSH from Bastion"
    },
    {
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      cidr_blocks     = [var.vpc_cidr]
      security_groups = []
      description     = "PostgreSQL internal"
    }
  ]

  tags = local.common_tags
}
