module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "my-vpc-2"
  cidr   = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "ec2_ssh" {
  name        = "ec2-ssh-access"
  description = "Allow SSH from GitHub Actions for Ansible automation"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ec2_instances" {
  source             = "./modules/ec2"
  ami                = var.ami
  instance_type      = var.instance_type
  key_name           = var.key_name
  instance-name      = "Pete"
  app                = "cg-airoli-old"
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [aws_security_group.ec2_ssh.id]
}

module "ec2_instances_2" {
  source             = "./modules/ec2"
  ami                = var.ami
  instance_type      = var.instance_type
  key_name           = var.key_name
  instance-name      = "mike"
  app                = "cg-vikhroli-old"
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [aws_security_group.ec2_ssh.id]
}

module "ec2_instance_redis" {
  source             = "./modules/ec2"
  ami                = var.ami
  instance_type      = var.instance_type
  key_name           = var.key_name
  instance-name      = "redis"
  app                = "redis-cache"
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [aws_security_group.ec2_ssh.id]
}
