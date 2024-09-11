data "aws_availability_zones" "virginia" {}
data "aws_availability_zones" "ohio" {
  provider = aws.ohio
}
data "aws_caller_identity" "current" {}
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

locals {
  name   = "tf-created"
  region = "us-east-1"
  region2 = "us-east-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.virginia.names, 0, 3)

  engine = "postgres"
  engine_version = "14"
  family = "postgres14"
  major_engine_version = "14"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  max_allocated_storage = 100
  port = 5432

  tags = {
    Name    = local.name
  }
}

################################################################################
# VPC for bastion and gitlab
################################################################################
resource "aws_vpc" "bastion-gitlab" {
  cidr_block = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = local.name
  }
}

resource "aws_internet_gateway" "bastion-gitlab-igw" {
  vpc_id = aws_vpc.bastion-gitlab

  tags = {
    Name = "${local.name}-igw"
  }
}
resource "aws_subnet" "bastion-gitlab-private" {
  vpc_id = aws_vpc.bastion-gitlab.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-1a"

  tags = {
    Name = "${local.name}-private"
  }
  
}

resource "aws_subnet" "bastion-gitlab-public" {
  vpc_id = aws_vpc.bastion-gitlab
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-1b"

  tags = {
    Name = "${local.name}-public"
  }
  
}

resource "aws_route_table" "bastion-gitlab-public" {
  vpc_id = aws_vpc.bastion-gitlab

  route = [ {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bastion-gitlab-igw.id
  } ]

  tags = {
    Name = "${local.name}-public-rt"
  }
  
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.bastion-gitlab-public.id
  subnet_id = aws_subnet.bastion-gitlab-public.id
}
resource "aws_nat_gateway" "nat" {
  subnet_id = aws_subnet.bastion-gitlab-public.id
  allocation_id = aws_eip.nat.id
  
  tags = {
    Name = "${local.name}-main-nat-gw"
  }
}
resource "aws_eip" "nat" {
  domain = "vpc"
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.bastion-gitlab.id

  route = [ {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  } ]

  tags = {
    Name = "${local.name}-private-route-table"
  }
  
}

resource "aws_route_table_association" "private" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.bastion-gitlab-private.id
  
}

################################################################################
#bastion and gitlab EC2
################################################################################
data "aws_ami" "amz" {
  most_recent = true

  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_eip" "bastion" {
  domain = "vpc"
}
resource "aws_instance" "bastion" {
  ami = data.aws_ami.amz.id
  instance_type = "t3.medium"
  subnet_id = aws_subnet.bastion-gitlab-public.id

  tags = {
    Name = "bastion"
  }
}
resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id = aws_instance.bastion.id
  allocation_id = aws_eip.bastion.id
}


resource "aws_instance" "gitlab" {
  ami = data.aws_ami.amz.id
  instance_type = "t3.xlarge"
  subnet_id = aws_subnet.bastion-gitlab-private.id

  tags = {
    Name = "gitlab"
  }
}
################################################################################
# EKS Module
################################################################################

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = local.name
  cluster_version = "1.30"

  # Gives Terraform identity admin access to cluster which will
  # allow deploying resources (Karpenter) into the cluster
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_groups = {
    karpenter = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 3
      desired_size = 2

      taints = {
        # This Taint aims to keep just EKS Addons and Karpenter running on this MNG
        # The pods that do not tolerate this taint should run on nodes created by Karpenter
        addons = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        },
      }
    }
  }

  # cluster_tags = merge(local.tags, {
  #   NOTE - only use this option if you are using "attach_cluster_primary_security_group"
  #   and you know what you're doing. In this case, you can remove the "node_security_group_tags" below.
  #  "karpenter.sh/discovery" = local.name
  # })

  node_security_group_tags = merge(local.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.name
  })

  tags = local.tags
}

################################################################################
# Karpenter
################################################################################
module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = module.eks.cluster_name

  enable_v1_permissions = true

  enable_pod_identity             = true
  create_pod_identity_association = true

  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  tags = local.tags
}
module "karpenter_disabled" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  create = false
}

################################################################################
# Karpenter Helm chart & manifests
# Not required; just to demonstrate functionality of the sub-module
################################################################################

resource "helm_release" "karpenter" {
  namespace           = "kube-system"
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = "1.0.0"
  wait                = false

  values = [
    <<-EOT
    serviceAccount:
      name: ${module.karpenter.service_account}
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    EOT
  ]
}

resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2023
      role: ${module.karpenter.node_iam_role_name}
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      tags:
        karpenter.sh/discovery: ${module.eks.cluster_name}
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: default
    spec:
      template:
        spec:
          nodeClassRef:
            name: default
          requirements:
            - key: "karpenter.k8s.aws/instance-category"
              operator: In
              values: ["t"]
            - key: "karpenter.k8s.aws/instance-cpu"
              operator: In
              values: ["2", "4"]
            - key: "karpenter.k8s.aws/instance-generation"
              operator: Gt
              values: ["2"]
      limits:
        cpu: 20
      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 30s
  YAML

  depends_on = [
    kubectl_manifest.karpenter_node_class
  ]
}

# Example deployment using the [pause image](https://www.ianlewis.org/en/almighty-pause-container)
# and starts with zero replicas
resource "kubectl_manifest" "karpenter_example_deployment" {
  yaml_body = <<-YAML
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: inflate
    spec:
      replicas: 0
      selector:
        matchLabels:
          app: inflate
      template:
        metadata:
          labels:
            app: inflate
        spec:
          terminationGracePeriodSeconds: 0
          containers:
            - name: inflate
              image: public.ecr.aws/eks-distro/kubernetes/pause:3.7
              resources:
                requests:
                  cpu: 1
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}


###############################################
# ArgoCD helm
###############################################
resource "helm_release" "argocd" {
  depends_on = [ helm_release.karpenter ]
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.5.2"

  namespace = "argocd"
  create_namespace = true

  set {
   name  = "server.service.type"
   value = "LoadBalancer"
  }
  set {
   name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
   value = "nlb"
  }
  
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 56)]

  enable_nat_gateway = true
  single_nat_gateway = true
  create_database_subnet_group = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = local.name
    "database" = "postgresql"
  }

  tags = local.tags
}

module "security_group_vpc" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name = local.name
  description = "Replica PostgreSQL security group"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = local.tags
}

module "vpc2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  providers = {
    aws = aws.ohio
  }

  name = local.name
  cidr = local.vpc_cidr

  azs             = slice(data.aws_availability_zones.ohio.names, 0, 3)
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 56)]

  enable_nat_gateway = true
  single_nat_gateway = true
  create_database_subnet_group = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = local.name
    "database" = "postgresql"
  }

  tags = local.tags
}

module "security_group_vpc2" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  providers = {
    aws = aws.ohio
  }

  name = local.name
  description = "Replica PostgreSQL security group"
  vpc_id = module.vpc2.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc2.vpc_cidr_block
    },
  ]

  tags = local.tags
}
################################################################################
# RDS Master DB
################################################################################
# module "master_db" {
#   source = "terraform-aws-modules/rds/aws"

#   identifier = "${local.name}-master-db"

#   engine = local.engine
#   engine_version = local.engine_version
#   family = local.family
#   major_engine_version = local.major_engine_version
#   instance_class = local.instance_class

#   allocated_storage = local.allocated_storage
#   max_allocated_storage = local.max_allocated_storage

#   db_name = "replicaPostgresql"
#   username = "replica_postgresql"
#   manage_master_user_password = true
#   port = local.port

#   multi_az = true
#   db_subnet_group_name = module.vpc.database_subnet_group_name
#   vpc_security_group_ids = [module.security_group_vpc.security_group_id]

#   enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

#   backup_retention_period = 1
#   skip_final_snapshot = true
#   deletion_protection = false

#   tags = local.tags
# }

# ################################################################################
# # Replica DB
# ################################################################################
# module "kms" {
#   source = "terraform-aws-modules/kms/aws"
#   version = "~> 1.0"
#   description = "KMS key for cross region replica DB"

#   aliases = [local.name]
#   aliases_use_name_prefix = true

#   key_owners = [data.aws_caller_identity.current.id]
#   tags = local.tags

#   providers = {
#     aws = aws.ohio
#   }
# }

# module "replica_db" {
#   source = "terraform-aws-modules/rds/aws"

#   providers = {
#     aws = aws.ohio
#   }

#   identifier = "${local.name}-replica-db"

#   replicate_source_db = module.master_db.db_instance_arn

#   engine               = local.engine
#   engine_version       = local.engine_version
#   family               = local.family
#   major_engine_version = local.major_engine_version
#   instance_class       = local.instance_class
#   kms_key_id           = module.kms.key_arn

#   allocated_storage     = local.allocated_storage
#   max_allocated_storage = local.max_allocated_storage

#   manage_master_user_password = false

#   port = local.port

#   create_db_parameter_group = false
  
#   multi_az = false
#   vpc_security_group_ids = [module.security_group_vpc2.security_group_id]

#   enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

#   backup_retention_period = 0
#   skip_final_snapshot = true
#   deletion_protection = false

#   db_subnet_group_name = module.vpc2.database_subnet_group_name

#   tags = local.tags
# }