resource "aws_instance" "my-ec2" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = var.instance-name
    application = var.app
  }
}

resource "aws_instance" "my-ec2-2" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = var.instance-name2
    application = var.app2
  }
}