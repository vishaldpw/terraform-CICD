resource "aws_instance" "my-ec2" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = var.instance-name
    application = "rundeck"
  }
}

resource "aws_instance" "my-db" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = var.instance-name2
    application = "rundeck"
  }
}
