
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