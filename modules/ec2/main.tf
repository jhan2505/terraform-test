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

# CloudWatch Log Group para EC2
resource "aws_cloudwatch_log_group" "ec2" {
  name              = "/aws/ec2/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ec2-logs"
  })
}

# IAM Role para EC2
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ec2-role"
  })
}

# IAM Policy para EC2
resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.project_name}-${var.environment}-ec2-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/${var.project_name}-${var.environment}/*"
      }
    ]
  })
}

# Instance Profile para EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ec2-profile"
  })
}

# User Data script para EC2
locals {
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    project_name        = var.project_name
    environment         = var.environment
    rds_endpoint        = var.rds_endpoint
    rds_username        = var.rds_username
    rds_password        = var.rds_password
    rds_database        = var.rds_database
    ecr_repository_url  = var.ecr_repository_url
  }))
}

# Instancia EC2
resource "aws_instance" "main" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = var.public_subnet_id
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = local.user_data

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true

    tags = merge(var.common_tags, {
      Name = "${var.project_name}-${var.environment}-root-volume"
    })
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ec2"
  })

  depends_on = [aws_cloudwatch_log_group.ec2]
}

# Elastic IP para la instancia
resource "aws_eip" "main" {
  instance = aws_instance.main.id
  domain   = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-eip"
  })

  depends_on = [aws_instance.main]
}

