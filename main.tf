
module "ec2_instances" {
  source         = "./modules/ec2"
  ami            = "ami-00eb69d236edcfaf8"
  instance_type  = "t2.micro"
  instance-name  = "Vishal-test-app"
  instance-name2 = "Vishal-test-db"
  app            = "stackstorm"
  app2           = "stackstorm-db"
}

module "ec2_instances_2" {
  source         = "./modules/ec2"
  ami            = "ami-00eb69d236edcfaf8"
  instance_type  = "t2.micro"
  instance-name  = "Vishal-test-app2"
  instance-name2 = "Vishal-test-db2"
  app            = "stackstorm"
  app2           = "stackstorm-db"
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "my-vpc-2"
  cidr   = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}