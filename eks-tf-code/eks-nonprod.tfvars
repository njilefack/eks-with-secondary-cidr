vpc_id                    = "vpc-0e835cbc74420b220"
private_subnet_ids        = ["subnet-05c6d991e360d45f2", "subnet-0f5187b310c173ab0"]
control_plane_subnet_ids  = ["subnet-05c6d991e360d45f2", "subnet-0f5187b310c173ab0"]
cluster_name = "eks-cluster"
cluster_version = "1.26"
region = "us-west-2"
# bastion host sg
source_security_group_id  = ["sg-052c692daf41de614"] # Don't forget to update bastion sg in main.tf line 170
added_auth_role           = "arn:aws:iam::391177159855:role/terraform-role"

tags = {
  project       = "eks-lab"
  poc           = "Jil"
  poc-email     = "email@email.com"
}

# bastion host sg
cluster_additional_security_group_ids = ["sg-052c692daf41de614"]
aws_auth_accounts                     = ["391177159855"]

managed_node_groups = {
  # first_ng = {
  #   disk_size       = 50
  #   instance_types  = ["t3.large"]
  #   capacity_type   = "SPOT"
  #   min_size        = 2
  #   max_size        = 3
  #   desired_size    = 2
  #   subnet_ids      = ["subnet-05c6d991e360d45f2", "subnet-0f5187b310c173ab0"]
  #   }

  second_ng = {
    disk_size       = 50
    instance_types  = ["t3.medium"]
    capacity_type   = "SPOT"
    min_size        = 2
    max_size        = 5
    desired_size    = 2
    subnet_ids      = ["subnet-05c6d991e360d45f2", "subnet-0f5187b310c173ab0"]
    }

  }

   /* map_users                            = [{
                                  userarn  = "arn:aws:iam::391177159855:user/terraform01"
                                  username = "terraform01"
                                  groups   = ["system:masters"]
  }] */

