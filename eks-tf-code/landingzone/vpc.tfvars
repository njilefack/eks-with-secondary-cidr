
vpc_name                = "eks-vpc"
cluster_name            = "eks-cluster"
region                  = "us-west-2"
vpc_cidr                = "10.0.0.0/16"
#secondary_cidr_blocks   = ["10.1.0.0/16", "10.2.0.0/16"]
private_subnets         = ["10.0.0.0/24", "10.0.16.0/24", "10.0.32.0/24"]
public_subnets          = ["10.0.48.0/24", "10.0.49.0/24", "10.0.50.0/24"]
database_subnets        = ["10.0.52.0/24", "10.0.53.0/24", "10.0.54.0/24"]
#elasticache_subnets     = ["10.0.31.0/24", "10.0.32.0/24", "10.0.33.0/24"]
#redshift_subnets        = ["10.0.41.0/24", "10.0.42.0/24", "10.0.43.0/24"]
intra_subnets           = ["10.0.56.0/24", "10.0.57.0/24", "10.0.58.0/24"]

private_subnet_names = ["Private-Subnet-01", "Private-Subnet-02", "Private-Subnet-03"]
# public_subnet_names omitted to show default name generation for all three subnets
database_subnet_names    = ["DB-Subnet-01", "DB-Subnet-02", "DB-Subnet-03"]
# elasticache_subnet_names = ["Elasticache-Subnet-01", "Elasticache-Subnet-02", "Elasticache-Subnet-03"]
# redshift_subnet_names    = ["Redshift-Subnet-01", "Redshift-Subnet-02", "Redshift-Subnet-03"]
intra_subnet_names       = ["Infra-Subnet-01", "Infra-Subnet-03", "Infra-Subnet-03"]

create_database_subnet_group = true

enable_dns_hostnames = true
# enable_dns_support   = false

enable_nat_gateway = true
single_nat_gateway = true

# enable_vpn_gateway = true

# enable_dhcp_options              = true
# dhcp_options_domain_name         = "service.consul"
# dhcp_options_domain_name_servers = ["127.0.0.1", "10.10.0.2"]

# VPC Flow Logs (Cloudwatch log group and IAM role will be created)
enable_flow_log = true
create_flow_log_cloudwatch_log_group = true
create_flow_log_cloudwatch_iam_role  = true
flow_log_max_aggregation_interval    = 60

tags = {
  project       = "eks-lab"
  poc           = "Jil"
  poc-email     = "email@email.com"
}

vpc_tags = {
  project       = "eks-lab"
  poc           = "Jil"
  poc-email     = "email@email.com"
}

