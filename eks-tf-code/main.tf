provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

locals {
  name   = var.cluster_name
  cluster_name = var.cluster_name
  region = var.region

  /* vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3) */

}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source = "./terraform-aws-eks-code"

  cluster_version = var.cluster_version
  cluster_name                   = var.cluster_name
  #cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }

    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  # External encryption key
  create_kms_key = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = module.kms.key_arn
  }

  iam_role_additional_policies = {
    additional = aws_iam_policy.additional.arn
  }

  vpc_id                   = var.vpc_id #module.vpc.vpc_id
  subnet_ids               = var.private_subnet_ids #module.vpc.private_subnets
  control_plane_subnet_ids = var.control_plane_subnet_ids #module.vpc.intra_subnets

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
    # Test: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2319
    ingress_source_security_group_id = {
      description              = "Ingress from another computed security group"
      protocol                 = "tcp"
      from_port                = 22
      to_port                  = 22
      type                     = "ingress"
      source_security_group_id = aws_security_group.additional.id
    }

  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    # Test: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2319
    ingress_source_security_group_id = {
      description              = "Ingress from another computed security group"
      protocol                 = "tcp"
      from_port                = 22
      to_port                  = 22
      type                     = "ingress"
      source_security_group_id = aws_security_group.additional.id
    }
  }

  eks_managed_node_groups = var.managed_node_groups

  # Create a new cluster where both an identity provider and Fargate profile is created
  # will result in conflicts since only one can take place at a time
  # # OIDC Identity provider
  # cluster_identity_providers = {
  #   sts = {
  #     client_id = "sts.amazonaws.com"
  #   }
  # }

  # aws-auth configmap
  manage_aws_auth_configmap = true

  /* aws_auth_node_iam_role_arns_non_windows = [
    module.eks_managed_node_group.iam_role_arn,
  ] */

  aws_auth_roles = [
    /* {
      rolearn  = module.eks_managed_node_group.iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    }, */
        {
      rolearn  = var.added_auth_role
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:masters"
      ]
    },
  ]

  aws_auth_users = []
  aws_auth_accounts = var.aws_auth_accounts

  tags = var.tags
  cluster_additional_security_group_ids = var.cluster_additional_security_group_ids #["sg-030ce93bd20736eeb"]
}

resource "aws_security_group_rule" "cluster" {
  type = "ingress"
  security_group_id = module.eks.cluster_primary_security_group_id
  protocol = "tcp"
  from_port = 443
  to_port = 443
  source_security_group_id = "sg-045fa16fae5f3786a" ## bastion sg
}

################################################################################
# Sub-Module Usage on Existing/Separate Cluster
################################################################################

/* module "eks_managed_node_group" {
  source = "./terraform-aws-eks/modules/eks-managed-node-group"

  name            = "separate-eks-mng"
  cluster_name    = var.cluster_name #module.eks.cluster_name
  cluster_version = var.cluster_version #module.eks.cluster_version

  subnet_ids                        = var.private_subnet_ids #module.vpc.private_subnets
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids = [
    module.eks.cluster_security_group_id,
  ]

  ami_type = "BOTTLEROCKET_x86_64"
  platform = "bottlerocket"

  # this will get added to what AWS provides
  bootstrap_extra_args = <<-EOT
    # extra args added
    [settings.kernel]
    lockdown = "integrity"

    [settings.kubernetes.node-labels]
    "label1" = "foo"
    "label2" = "bar"
  EOT

  tags = merge(var.tags, { Separate = "eks-managed-node-group" })
} */


resource "aws_security_group" "additional" {
  name_prefix = "${local.name}-additional"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress  {
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      security_groups = var.source_security_group_id
    }

## additing additional ingress for istio-ingressgateway
  ingress {
      protocol                = "tcp"
      from_port               = 15017
      to_port                 = 15017
      cidr_blocks = [
        "0.0.0.0/0",
]

} 

  tags = merge(var.tags, { Name = "${local.name}-additional", "kubernetes.io/cluster/${local.name}" = "owned","kubernetes.io/role/internal-elb" = 1 })
}

resource "aws_iam_policy" "additional" {
  name = "${local.name}-additional"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.1.0"

  aliases               = ["eks/${local.name}"]
  description           = "${local.name} cluster encryption key"
  enable_default_policy = true
  key_owners            = [data.aws_caller_identity.current.arn]

  tags = var.tags
}
