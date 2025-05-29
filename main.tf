module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "my-vpc-2"
  cidr   = "10.0.0.0/16"

  azs             = ["us-east-2a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "ec2_instances" {
  source        = "./modules/ec2"
  ami           = "ami-00eb69d236edcfaf8"
  instance_type = "t3.micro"
  instance-name = "shooban"

  app = "cg-airoli-old"


  subnet_id = module.vpc.public_subnets[0] # Reference VPC's public subnet
}

module "ec2_instances-2" {
  source        = "./modules/ec2"
  ami           = "ami-00eb69d236edcfaf8"
  instance_type = "t3.micro"
  instance-name = "shubada"

  app = "cg-vikhroli-old"


  subnet_id = module.vpc.public_subnets[0] # Reference VPC's public subnet
}


