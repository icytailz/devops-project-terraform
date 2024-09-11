output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.vpc.vpc_arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = module.vpc.private_subnet_arns
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.vpc.private_subnets_cidr_blocks
}
output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = module.vpc.public_subnet_arns
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = module.vpc.public_subnets_cidr_blocks
}

################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_dualstack_oidc_issuer_url" {
  description = "Dual-stack compatible URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_dualstack_oidc_issuer_url
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = module.eks.cluster_platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = module.eks.cluster_status
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = module.eks.cluster_primary_security_group_id
}

output "cluster_service_cidr" {
  description = "The CIDR block where Kubernetes pod and service IP addresses are assigned from"
  value       = module.eks.cluster_service_cidr
}

output "cluster_ip_family" {
  description = "The IP family used by the cluster (e.g. `ipv4` or `ipv6`)"
  value       = module.eks.cluster_ip_family
}

################################################################################
# Access Entry
################################################################################

output "access_entries" {
  description = "Map of access entries created and their attributes"
  value       = module.eks.access_entries
}

################################################################################
# Security Group
################################################################################

output "cluster_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the cluster security group"
  value       = module.eks.cluster_security_group_arn
}

output "cluster_security_group_id" {
  description = "ID of the cluster security group"
  value       = module.eks.cluster_security_group_id
}

################################################################################
# Node Security Group
################################################################################

output "node_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the node shared security group"
  value       = module.eks.node_security_group_arn
}

output "node_security_group_id" {
  description = "ID of the node shared security group"
  value       = module.eks.node_security_group_id
}

################################################################################
# IRSA
################################################################################

output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = module.eks.oidc_provider_arn
}

output "cluster_tls_certificate_sha1_fingerprint" {
  description = "The SHA1 fingerprint of the public key of the cluster's certificate"
  value       = module.eks.cluster_tls_certificate_sha1_fingerprint
}

################################################################################
# IAM Role
################################################################################

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "cluster_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.eks.cluster_iam_role_unique_id
}

################################################################################
# EKS Addons
################################################################################

output "cluster_addons" {
  description = "Map of attribute maps for all EKS cluster addons enabled"
  value       = module.eks.cluster_addons
}

################################################################################
# EKS Identity Provider
################################################################################

output "cluster_identity_providers" {
  description = "Map of attribute maps for all EKS identity providers enabled"
  value       = module.eks.cluster_identity_providers
}

################################################################################
# CloudWatch Log Group
################################################################################

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = module.eks.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created"
  value       = module.eks.cloudwatch_log_group_arn
}

################################################################################
# Fargate Profile
################################################################################

output "fargate_profiles" {
  description = "Map of attribute maps for all EKS Fargate Profiles created"
  value       = module.eks.fargate_profiles
}

################################################################################
# EKS Managed Node Group
################################################################################

output "eks_managed_node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value       = module.eks.eks_managed_node_groups
}

output "eks_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by EKS managed node groups"
  value       = module.eks.eks_managed_node_groups_autoscaling_group_names
}

################################################################################
# Self Managed Node Group
################################################################################

output "self_managed_node_groups" {
  description = "Map of attribute maps for all self managed node groups created"
  value       = module.eks.self_managed_node_groups
}

output "self_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by self-managed node groups"
  value       = module.eks.self_managed_node_groups_autoscaling_group_names
}

################################################################################
# Karpenter controller IAM Role
################################################################################

output "karpenter_iam_role_name" {
  description = "The name of the controller IAM role"
  value       = module.karpenter.iam_role_name
}

output "karpenter_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the controller IAM role"
  value       = module.karpenter.iam_role_arn
}

output "karpenter_iam_role_unique_id" {
  description = "Stable and unique string identifying the controller IAM role"
  value       = module.karpenter.iam_role_unique_id
}

################################################################################
# Node Termination Queue
################################################################################

output "karpenter_queue_arn" {
  description = "The ARN of the SQS queue"
  value       = module.karpenter.queue_arn
}

output "karpenter_queue_name" {
  description = "The name of the created Amazon SQS queue"
  value       = module.karpenter.queue_name
}

output "karpenter_queue_url" {
  description = "The URL for the created Amazon SQS queue"
  value       = module.karpenter.queue_url
}

################################################################################
# Node Termination Event Rules
################################################################################

output "karpenter_event_rules" {
  description = "Map of the event rules created and their attributes"
  value       = module.karpenter.event_rules
}

################################################################################
# Node IAM Role
################################################################################

output "karpenter_node_iam_role_name" {
  description = "The name of the IAM role"
  value       = module.karpenter.node_iam_role_name
}

output "karpenter_node_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.karpenter.node_iam_role_arn
}

output "karpenter_node_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.karpenter.node_iam_role_unique_id
}

################################################################################
# Node IAM Instance Profile
################################################################################

output "karpenter_instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = module.karpenter.instance_profile_arn
}

output "karpenter_instance_profile_id" {
  description = "Instance profile's ID"
  value       = module.karpenter.instance_profile_id
}

output "karpenter_instance_profile_name" {
  description = "Name of the instance profile"
  value       = module.karpenter.instance_profile_name
}

output "karpenter_instance_profile_unique" {
  description = "Stable and unique string identifying the IAM instance profile"
  value       = module.karpenter.instance_profile_unique
}
##########################################
# DB
##########################################
# Master
# output "master_db_instance_address" {
#   description = "The address of the RDS instance"
#   value       = module.master_db.db_instance_address
# }

# output "master_db_instance_arn" {
#   description = "The ARN of the RDS instance"
#   value       = module.master_db.db_instance_arn
# }

# output "master_db_instance_availability_zone" {
#   description = "The availability zone of the RDS instance"
#   value       = module.master_db.db_instance_availability_zone
# }

# output "master_db_instance_endpoint" {
#   description = "The connection endpoint"
#   value       = module.master_db.db_instance_endpoint
# }

# output "master_db_instance_engine" {
#   description = "The database engine"
#   value       = module.master_db.db_instance_engine
# }

# output "master_db_instance_engine_version_actual" {
#   description = "The running version of the database"
#   value       = module.master_db.db_instance_engine_version_actual
# }

# output "master_db_instance_hosted_zone_id" {
#   description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
#   value       = module.master_db.db_instance_hosted_zone_id
# }

# output "master_db_instance_identifier" {
#   description = "The RDS instance identifier"
#   value       = module.master_db.db_instance_identifier
# }

# output "master_db_instance_resource_id" {
#   description = "The RDS Resource ID of this instance"
#   value       = module.master_db.db_instance_resource_id
# }

# output "master_db_instance_status" {
#   description = "The RDS instance status"
#   value       = module.master_db.db_instance_status
# }

# output "master_db_instance_name" {
#   description = "The database name"
#   value       = module.master_db.db_instance_name
# }

# output "master_db_instance_username" {
#   description = "The master username for the database"
#   value       = module.master_db.db_instance_username
#   sensitive   = true
# }

# output "master_db_instance_port" {
#   description = "The database port"
#   value       = module.master_db.db_instance_port
# }

# output "master_db_subnet_group_id" {
#   description = "The db subnet group name"
#   value       = module.master_db.db_subnet_group_id
# }

# output "master_db_subnet_group_arn" {
#   description = "The ARN of the db subnet group"
#   value       = module.master_db.db_subnet_group_arn
# }

# output "master_db_instance_cloudwatch_log_groups" {
#   description = "Map of CloudWatch log groups created and their attributes"
#   value       = module.master_db.db_instance_cloudwatch_log_groups
# }

# # Replica
# output "replica_db_instance_address" {
#   description = "The address of the RDS instance"
#   value       = module.replica_db.db_instance_address
# }

# output "replica_db_instance_arn" {
#   description = "The ARN of the RDS instance"
#   value       = module.replica_db.db_instance_arn
# }

# output "replica_db_instance_availability_zone" {
#   description = "The availability zone of the RDS instance"
#   value       = module.replica_db.db_instance_availability_zone
# }

# output "replica_db_instance_endpoint" {
#   description = "The connection endpoint"
#   value       = module.replica_db.db_instance_endpoint
# }

# output "replica_db_instance_engine" {
#   description = "The database engine"
#   value       = module.replica_db.db_instance_engine
# }

# output "replica_db_instance_engine_version_actual" {
#   description = "The running version of the database"
#   value       = module.replica_db.db_instance_engine_version_actual
# }

# output "replica_db_instance_hosted_zone_id" {
#   description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
#   value       = module.replica_db.db_instance_hosted_zone_id
# }

# output "replica_db_instance_identifier" {
#   description = "The RDS instance identifier"
#   value       = module.replica_db.db_instance_identifier
# }

# output "replica_db_instance_resource_id" {
#   description = "The RDS Resource ID of this instance"
#   value       = module.replica_db.db_instance_resource_id
# }

# output "replica_db_instance_status" {
#   description = "The RDS instance status"
#   value       = module.replica_db.db_instance_status
# }

# output "replica_db_instance_name" {
#   description = "The database name"
#   value       = module.replica_db.db_instance_name
# }

# output "replica_db_instance_username" {
#   description = "The replica username for the database"
#   value       = module.replica_db.db_instance_username
#   sensitive   = true
# }

# output "replica_db_instance_port" {
#   description = "The database port"
#   value       = module.replica_db.db_instance_port
# }

# output "replica_db_instance_cloudwatch_log_groups" {
#   description = "Map of CloudWatch log groups created and their attributes"
#   value       = module.replica_db.db_instance_cloudwatch_log_groups
# }
