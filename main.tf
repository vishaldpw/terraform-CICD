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

output "resource_summary" {
  description = "Summary of all resources provisioned by this stack."
  value = {
    vpc = {
      id              = module.vpc.vpc_id
      cidr            = module.vpc.vpc_cidr_block
      azs             = var.azs
      public_subnets  = module.vpc.public_subnets
      private_subnets = module.vpc.private_subnets
      nat_gateway_ids = module.vpc.natgw_ids
    }

    security_group = {
      id   = aws_security_group.ec2_ssh.id
      name = aws_security_group.ec2_ssh.name
    }

    ec2_instances = [
      {
        name        = module.ec2_instances.name
        application = module.ec2_instances.application
        instance_id = module.ec2_instances.instance_id
        public_ip   = module.ec2_instances.public_ip
        public_dns  = module.ec2_instances.public_dns
        private_ip  = module.ec2_instances.private_ip
      },
      {
        name        = module.ec2_instances_2.name
        application = module.ec2_instances_2.application
        instance_id = module.ec2_instances_2.instance_id
        public_ip   = module.ec2_instances_2.public_ip
        public_dns  = module.ec2_instances_2.public_dns
        private_ip  = module.ec2_instances_2.private_ip
      },
      {
        name        = module.ec2_instance_redis.name
        application = module.ec2_instance_redis.application
        instance_id = module.ec2_instance_redis.instance_id
        public_ip   = module.ec2_instance_redis.public_ip
        public_dns  = module.ec2_instance_redis.public_dns
        private_ip  = module.ec2_instance_redis.private_ip
      },
    ]
  }
}
