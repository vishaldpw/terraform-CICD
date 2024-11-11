resource "aws_instance" "my-ec2" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "black-Bottle"
  subnet_id     = var.subnet_id
  tags = {
    Name = var.instance-name
    application = var.app
  }
}

