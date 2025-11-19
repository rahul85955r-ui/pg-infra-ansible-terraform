variable "prefix" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "private_master_subnet_cidr" {
  type = string
}

variable "private_replica_subnet_cidr" {
  type = string
}

variable "public_az" {
  type = string
}

variable "private_master_az" {
  type = string
}

variable "private_replica_az" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
