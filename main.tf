# Configuración del provider AWS
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}

# Data source para obtener la AMI de Amazon Linux 2
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Generar password aleatorio para RDS si no se proporciona
resource "random_password" "db_password" {
  count   = var.db_password == "" ? 1 : 0
  length  = 16
  special = true
}

# Módulo VPC
module "vpc" {
  source = "./modules/vpc"

  project_name     = var.project_name
  environment      = var.environment
  vpc_cidr         = var.vpc_cidr
  availability_zones = var.availability_zones
  common_tags      = var.common_tags
}

# Módulo Security Groups
module "security_groups" {
  source = "./modules/security-groups"

  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  allowed_ssh_ips = var.allowed_ssh_ips
  common_tags     = var.common_tags
}

# Módulo ECR
module "ecr" {
  source = "./modules/ecr"

  project_name         = var.project_name
  environment          = var.environment
  ecr_repository_name  = var.ecr_repository_name
  common_tags          = var.common_tags
}

# Módulo RDS
module "rds" {
  source = "./modules/rds"

  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  security_group_id         = module.security_groups.rds_security_group_id
  db_instance_class         = var.db_instance_class
  db_allocated_storage      = var.db_allocated_storage
  db_max_allocated_storage  = var.db_max_allocated_storage
  db_engine_version         = var.db_engine_version
  db_name                   = var.db_name
  db_username               = var.db_username
  db_password               = var.db_password != "" ? var.db_password : random_password.db_password[0].result
  common_tags               = var.common_tags
}

# Módulo EC2
module "ec2" {
  source = "./modules/ec2"

  project_name           = var.project_name
  environment            = var.environment
  ami_id                 = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_pair_name          = var.key_pair_name
  vpc_id                 = module.vpc.vpc_id
  public_subnet_id       = module.vpc.public_subnet_ids[0]
  security_group_id      = module.security_groups.ec2_security_group_id
  rds_endpoint           = module.rds.rds_endpoint
  rds_username           = var.db_username
  rds_password           = var.db_password != "" ? var.db_password : random_password.db_password[0].result
  rds_database           = var.db_name
  ecr_repository_url     = module.ecr.repository_url
  common_tags            = var.common_tags
}

