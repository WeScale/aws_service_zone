variable "vpc_name" {}

variable "vpc_id" {}

variable "amis" {
  default = {
    eu-west-1 = "ami-e079f893"
  }
}

variable "az_1" {}

variable "private_subnet_id" {}

variable "public_subnet_id" {}

variable "keypair" {}

variable "bastion_ami_id" {}

variable "bastion_instance_type" {}

variable "bastion_keypair" {}
