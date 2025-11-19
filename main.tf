locals {
  common_tags = merge({
    Project   = var.project
    Env       = var.env
    ManagedBy = "terraform"
  }, var.tags)
}

resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = file("${path.root}/${var.public_key_path}")
  tags       = local.common_tags
}

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

module "bastion" {
  source   = "./modules/ec2"
  prefix   = var.project
  name_tag = "${var.project}-${var.env}-bastion"
  role     = "bastion"
  env      = var.env

  ami                 = var.ami
  instance_type       = var.bastion_instance_type
  subnet_id           = module.vpc.public_subnet_id
  vpc_id              = module.vpc.vpc_id
  key_name            = aws_key_pair.main.key_name
  sg_name             = "bastion-sg"
  associate_public_ip = true

  ingress_rules = [
    {
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = [var.admin_cidr]
      security_groups = []
      description     = "SSH from admin"
    }
  ]

  tags = local.common_tags
}

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

  vpc_id   = module.vpc.vpc_id
  key_name = aws_key_pair.main.key_name

  sg_name = "db-${count.index == 0 ? "master" : "replica"}-sg"

  ingress_rules = [
    {
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.bastion.security_group_id]
      description     = "SSH from bastion"
    },
    {
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      cidr_blocks     = [var.vpc_cidr]
      security_groups = []
      description     = "PostgreSQL"
    }
  ]

  tags = local.common_tags
}
