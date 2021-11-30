provider "aws" {
  #version = "~> 3.22"
  region                  = "ap-northeast-2"
  shared_credentials_file = "/Users/kym/.aws/credentials"
  profile                 = "default"
  
}


resource "aws_kms_key" "this" {
}


resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits = 4096
  
  provisioner "local-exec" {
    command = "echo '${tls_private_key.this.private_key_pem}' > ./${var.key_pair_name}.pem"
  }
  
}

# resource "aws_eip" "bastion_eip" {
#   instance = module.ec2_bastion.id[0]
#   vpc      = true
#   tags = {
#     Name = format("${var.vpc_name}-BASTION-EIP")
#   }
# }

module "key_pair" {
  source = "./modules/key_pair"

  key_name   = var.key_pair_name
  public_key = tls_private_key.this.public_key_openssh
}

################################################################################################################
# VPC
# create VPC & Subnets & etc network services
################################################################################################################
module "vpc" {
  #source = "terraform-aws-modules/vpc/aws"
  source = "./modules/vpc"

  name = "${var.vpc_name}"
  cidr = "${var.vpc_cidr}"
  


  azs             = "${var.vpc_azs}"
  public_subnets  = "${var.public_cidr}"
  # private_subnets   = "${var.private_cidr}"
  
  gateway_private_subnets   = "${var.gateway_private_cidr}"
  frontend_private_subnets  = "${var.frontend_private_cidr}"
  backend_private_subnets   = "${var.backend_private_cidr}"
  db_private_subnets        = "${var.db_private_cidr}"
  managed_private_subnets   = "${var.managed_private_cidr}"
  bigdata_private_subnets   = "${var.bigdata_private_cidr}"
  

  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway  = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Terraform = "true"
    Environment = "PROD"
  }
}

# ################################################################################################################
# EC2
# create EC2 instances and EBS
# ################################################################################################################

module "ec2_bastion"{
  source                 = "./modules/ec2_bastion"

  name                   = format("${var.vpc_name}-BASTION")
  instance_count         = 1

  ami                    = data.aws_ami.amazon_linux2.id
  instance_type          = var.ec2_bastion_instnace_type
  
  key_name               = var.key_pair_name
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  subnet_id              = module.vpc.public_subnets[0]
  associate_public_ip_address = true 
  
  user_data_base64 = base64encode(local.user_data)
  
  enable_volume_tags = true
  
  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
      # tags = {
      #   Name = format("${var.vpc_name}-BASTION-ROOT-EBS")
      # }
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp2"
      volume_size = 10
      encrypted   = true
      kms_key_id  = aws_kms_key.this.arn
    }
  ]
  
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# ################################################################################################################
# RDS
# create RDS instances
# ################################################################################################################
module "db_mysql" {
  source  = "./modules/db_mysql"

  identifier = "kymdb"

  engine            = "mysql"
  engine_version    = "8.0.20"
  instance_class    = "db.t2.large"
  allocated_storage = 5

  name     = "kymdb"
  username = "admin"
  password = "admin123!"
  port     = "3306"

  iam_database_authentication_enabled = false
  publicly_accessible = true

  vpc_security_group_ids = [aws_security_group.rds-mysql-sg.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval = "30"
  monitoring_role_name = "MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Owner       = "admin"
    Environment = "dev"
  }

  # DB subnet group
  subnet_ids = module.vpc.db_private_subnets

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name = "character_set_client"
      value = "utf8mb4"
    },
    {
      name = "character_set_server"
      value = "utf8mb4"
    }
  ]
  
  

#   options = [
#     {
#       option_name = "MEMCACHED"

#       option_settings = [
#         {
#           name  = "SERVER_AUDIT_EVENTS"
#           value = "CONNECT"
#         },
#         {
#           name  = "SERVER_AUDIT_FILE_ROTATIONS"
#           value = "37"
#         },
#       ]
#     },
#   ]
 }


# ##############################################################################################################
# EKS
# create EKS cluster & node groups
# ##############################################################################################################
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  #load_config_file       = false
}


module "eks" {
  source          = "./modules/eks"
  #source = "terraform-aws-modules/eks/aws"
  #version = "<14.0.0"
  cluster_name    = format("${var.vpc_name}-%s", "EKS")
  cluster_version = "1.20"
  subnets         = concat(module.vpc.public_subnets, module.vpc.gateway_private_subnets,  module.vpc.frontend_private_subnets, module.vpc.backend_private_subnets, module.vpc.managed_private_subnets)
  vpc_id          = module.vpc.vpc_id

  node_groups = {
  
    gateway = {
      name             = "GATEWAY"
      desired_capacity = 1
      max_capacity     = 15
      min_capacity     = 1
      subnets = module.vpc.gateway_private_subnets
      instance_type = var.gateway_node_instance_type

      launch_template_id      = aws_launch_template.gateway.id
      launch_template_version = aws_launch_template.gateway.default_version

      additional_tags = {
        CustomTag = "GATEWAY"
      }
    }
  
    frontend = {
      name             = "FRONTEND"
      desired_capacity = 1
      max_capacity     = 15
      min_capacity     = 1
      subnets = module.vpc.frontend_private_subnets
      instance_type = var.frontend_node_instance_type

      launch_template_id      = aws_launch_template.frontend.id
      launch_template_version = aws_launch_template.frontend.default_version

      additional_tags = {
        CustomTag = "FRONTEND"
      }
    }
      
    backend = {
      name             = "BACKEND"
      desired_capacity = 1
      max_capacity     = 15
      min_capacity     = 1
      subnets = module.vpc.backend_private_subnets
      instance_type = var.backend_node_instance_type

      launch_template_id      = aws_launch_template.backend.id
      launch_template_version = aws_launch_template.backend.default_version

      additional_tags = {
        CustomTag = "BACKEND"
      }
    }
    
    managed = {
      name             = "MANAGED"
      desired_capacity = 1
      max_capacity     = 15
      min_capacity     = 1
      subnets = module.vpc.managed_private_subnets
      instance_type = var.managed_node_instance_type
      
      launch_template_id      = aws_launch_template.managed.id
      launch_template_version = aws_launch_template.managed.default_version

      additional_tags = {
        CustomTag = "MANAGED"
      }
    }
  }
}

