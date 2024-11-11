
module "ec2_instances" {
  source         = "./modules/ec2"
  ami            = "ami-00eb69d236edcfaf8"
  instance_type  = "t2.micro"
  instance-name  = "redis"
  instance-name2 = "Vishal-test-db"
  app            = "stackstorm"
  app2           = "stackstorm-db"
}

module "ec2_instances_2" {
  source         = "./modules/ec2"
  ami            = "ami-00eb69d236edcfaf8"
  instance_type  = "t2.micro"
  instance-name  = "redis"
  instance-name2 = "Vishal-test-db2"
  app            = "stackstorm"
  app2           = "stackstorm-db"
}


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