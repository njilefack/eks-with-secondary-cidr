provider "aws" {
  region = var.region
}

locals {
  name   = "ex-${replace(basename(path.cwd), "_", "-")}"
  region = var.region #"us-east-1"

  tags = var.vpc_tags

  # tags = {
  #   Example    = local.name
  #   GithubRepo = "terraform-aws-vpc"
  #   GithubOrg  = "terraform-aws-modules"
  # }
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "./modules/vpc"

  name = var.vpc_name
  cidr = var.vpc_cidr
  #secondary_cidr_blocks = var.secondary_cidr_blocks

  azs                 = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets 
  database_subnets    = var.database_subnets
  intra_subnets       = var.intra_subnets
  # elasticache_subnets = var.elasticache_subnets
  # redshift_subnets    = var.redshift_subnets


  private_subnet_names = var.private_subnet_names
  # public_subnet_names omitted to show default name generation for all three subnets
  database_subnet_names    = var.database_subnet_names
  # elasticache_subnet_names = var.elasticache_subnet_names
  # redshift_subnet_names    = var.redshift_subnet_names
  intra_subnet_names       = var.intra_subnet_names

  create_database_subnet_group = var.create_database_subnet_group
  database_subnet_group_name   = var.database_subnet_group_name

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                    = 1
  } 


  # manage_default_network_acl = true
  # default_network_acl_tags   = { Name = "${local.name}-default" }

  # manage_default_route_table = true
  # default_route_table_tags   = { Name = "${local.name}-default" }

  # manage_default_security_group = true
  # default_security_group_tags   = { Name = "${local.name}-default" }

  enable_dns_hostnames = var.enable_dns_hostnames #true
  enable_nat_gateway = var.enable_nat_gateway #true
  single_nat_gateway = var.single_nat_gateway #true
  #enable_dns_support   = var.enable_dns_support #true



  # customer_gateways = {
  #   IP1 = {
  #     bgp_asn     = 65112
  #     ip_address  = "1.2.3.4"
  #     device_name = "some_name"
  #   },
  #   IP2 = {
  #     bgp_asn    = 65112
  #     ip_address = "5.6.7.8"
  #   }
  # }

  #enable_vpn_gateway = var.enable_vpn_gateway #true

  #enable_dhcp_options              = var.enable_dhcp_options #true
  #dhcp_options_domain_name         = var.dhcp_options_domain_name #"service.consul"
  #dhcp_options_domain_name_servers = var.dhcp_options_domain_name_servers #["127.0.0.1", "10.10.0.2"]

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = var.enable_flow_log #true
  create_flow_log_cloudwatch_log_group = var.create_flow_log_cloudwatch_log_group #true
  create_flow_log_cloudwatch_iam_role  = var.create_flow_log_cloudwatch_iam_role #true
  flow_log_max_aggregation_interval    = var.flow_log_max_aggregation_interval #60

  tags = var.tags
}

################################################################################
# VPC Endpoints Module
################################################################################

/*module "vpc_endpoints" {
  source = "./modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [data.aws_security_group.default.id]

  endpoints = {
    s3 = {
      service = "s3"
      tags    = { Name = "s3-vpc-endpoint" }
    },
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
      tags            = { Name = "dynamodb-vpc-endpoint" }
    },
    ssm = {
      service             = "ssm"
      private_dns_enabled = var.private_dns_enabled #true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_tls.id]
    },
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = var.private_dns_enabled #true
      subnet_ids          = module.vpc.private_subnets
    },
    lambda = {
      service             = "lambda"
      private_dns_enabled = var.private_dns_enabled #true
      subnet_ids          = module.vpc.private_subnets
    },
    ecs = {
      service             = "ecs"
      private_dns_enabled = var.private_dns_enabled #true
      subnet_ids          = module.vpc.private_subnets
    },
    ecs_telemetry = {
      create              = false
      service             = "ecs-telemetry"
      private_dns_enabled = var.private_dns_enabled #true
      subnet_ids          = module.vpc.private_subnets
    },
    ec2 = {
      service             = "ec2"
      private_dns_enabled = var.private_dns_enabled #true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_tls.id]
    },
    ec2messages = {
      service             = "ec2messages"
      private_dns_enabled = var.private_dns_enabled #true
      subnet_ids          = module.vpc.private_subnets
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = var.private_dns_enabled #true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = var.private_dns_enabled #true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
    },
    kms = {
      service             = "kms"
      private_dns_enabled = var.private_dns_enabled #true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_tls.id]
    },
    codedeploy = {
      service             = "codedeploy"
      private_dns_enabled = var.private_dns_enabled #true
      subnet_ids          = module.vpc.private_subnets
    },
    codedeploy_commands_secure = {
      service             = "codedeploy-commands-secure"
      private_dns_enabled = var.private_dns_enabled #true
      subnet_ids          = module.vpc.private_subnets
    },
  }

  tags = merge(local.tags, {
    Project  = "Secret"
    Endpoint = "true"
  })
}

module "vpc_endpoints_nocreate" {
  source = "./modules/vpc-endpoints"

  create = false
}*/

################################################################################
# Supporting Resources
################################################################################

/*data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

data "aws_iam_policy_document" "dynamodb_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["dynamodb:*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpce"

      values = [module.vpc.vpc_id]
    }
  }
}

data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpc"

      values = [module.vpc.vpc_id]
    }
  }
}

resource "aws_security_group" "vpc_tls" {
  name_prefix = "${local.name}-vpc_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = var.vpc_tags
}*/
