variable "region" {
    type = string
    description = "region were the cluster will be deployed"
    default = ""
}

variable "cluster_name" {
    type = string
    description = "Name of the cluster to be created"
    default = ""
}

variable "cluster_version" {
    type = string
    description = "Version of the cluster to be deployed"
    default = "" 
}

variable "vpc_id" {
  type = string
  description = "Vpc id"
  default = ""
}

variable "control_plane_subnet_ids" {
    type = list(string)
    description = "private subnetes were the control plane components will be created"
}

variable "private_subnet_ids" {
  type = list(string)
  description = "private subnets were the data plane/worker nodes components will be provisioned"
}

variable "bastion-sg" {
    type = string
    description = "sg for the bastion that will be addded to the sg of the cluster"
    default = ""
}

variable "ami_id" {
    type = string
    description = "The AMI that will be used to provision the worker nodes"
    default = ""
}

variable "source_security_group_id" {}

variable "added_auth_role" {}

variable "tags" {}

variable "managed_node_groups" {}

variable "cluster_additional_security_group_ids" {
    type = list(string)
}

variable "aws_auth_accounts" {}

