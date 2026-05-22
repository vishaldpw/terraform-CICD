# modules/ec2/main.tf

resource "aws_instance" "my-ec2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true

  tags = {
    Name        = var.instance-name
    application = var.app
  }
}

output "instance_id" {
  value = aws_instance.my-ec2.id
}

output "public_ip" {
  value = aws_instance.my-ec2.public_ip
}

output "public_dns" {
  value = aws_instance.my-ec2.public_dns
}

output "private_ip" {
  value = aws_instance.my-ec2.private_ip
}

output "name" {
  value = var.instance-name
}

output "application" {
  value = var.app
}
