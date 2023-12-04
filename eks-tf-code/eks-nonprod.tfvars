vpc_id                    = "vpc-03182af9613eca88f"
private_subnet_ids        = ["subnet-08828872797a7d30d", "subnet-0685622351128d622"]
control_plane_subnet_ids  = ["subnet-08828872797a7d30d", "subnet-0685622351128d622"]
cluster_name = "eks-cluster"
cluster_version = "1.26"
region = "us-west-2"
# bastion host sg
source_security_group_id  = ["sg-045fa16fae5f3786a"] # Don't forget to update bastion sg in main.tf line 170
added_auth_role           = "arn:aws:iam::391177159855:role/terraform-role"

tags = {
  project       = "eks-lab"
  poc           = "Jil"
  poc-email     = "email@email.com"
}

# bastion host sg
cluster_additional_security_group_ids = ["sg-045fa16fae5f3786a"]
aws_auth_accounts                     = ["391177159855"]

managed_node_groups = {
    first_ng = {
      node_group_name = "first_ng"
      disk_size       = 50
      instance_types  = ["t3.large"]
      capacity_type   = "SPOT"
      min_size        = 1
      max_size        = 3
      desired_size    = 1
      subnet_ids      = ["subnet-08828872797a7d30d", "subnet-0685622351128d622"]
    }

managed_node_groups = {
    first_ng = {
      node_group_name = "second_ng"
      disk_size       = 50
      instance_types  = ["t3.large"]
      capacity_type   = "SPOT"
      min_size        = 3
      max_size        = 5
      desired_size    = 3
      subnet_ids      = ["subnet-08828872797a7d30d", "subnet-0685622351128d622"]
    }}

  }

   /* map_users                            = [{
                                  userarn  = "arn:aws:iam::391177159855:user/terraform01"
                                  username = "terraform01"
                                  groups   = ["system:masters"]
  }] */

