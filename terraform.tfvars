region          = "us-east-2"
vpc_cidr        = "10.0.0.0/16"
azs             = ["us-east-2a"]
private_subnets = ["10.0.1.0/24"]
public_subnets  = ["10.0.101.0/24"]
ami             = "ami-00eb69d236edcfaf8"
instance_type   = "t3.micro"
key_name        = "key-may-2025"
