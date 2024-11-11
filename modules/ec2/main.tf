# modules/ec2/main.tf

resource "aws_instance" "my-ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = "black-Bottle"
  subnet_id              = var.subnet_id
  associate_public_ip_address = true  # This ensures the instance gets a public IP

  tags = {
    Name        = var.instance-name
    application = var.app
  }
}
