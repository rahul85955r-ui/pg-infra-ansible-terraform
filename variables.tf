variable "project" {
  type        = string
  description = "Project prefix (used as resource name prefix)"
  default     = "pg"
}

variable "env" {
  type        = string
  description = "Environment (dev/stage/prod)"
  default     = "prod"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "ap-northeast-1"
}

variable "key_name" {
  type        = string
  description = "Keypair name to create in AWS"
  default     = "postgres-key"
}

variable "public_key_path" {
  type        = string
  description = "Relative path to public key file generated at runtime by Jenkins"
  default     = "tmp/public_ssh_key.pub"
}

variable "admin_cidr" {
  type        = string
  description = "CIDR allowed to SSH to bastion (single IP recommended)"
  default     = "0.0.0.0/0"
}

variable "ami" {
  type        = string
  description = "AMI id for instances"
}

variable "bastion_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "db_instance_type" {
  type    = string
  default = "t3.small"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_master_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "private_replica_subnet_cidr" {
  type    = string
  default = "10.0.3.0/24"
}

variable "public_az" {
  type    = string
  default = "ap-northeast-1a"
}

variable "private_master_az" {
  type    = string
  default = "ap-northeast-1a"
}

variable "private_replica_az" {
  type    = string
  default = "ap-northeast-1c"
}

variable "tags" {
  type    = map(string)
  default = {}
}
