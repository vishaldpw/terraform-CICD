

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance-name" {
  type = string
}



variable "app" {
  type = string
}


variable "subnet_id" {
  description = "The ID of the subnet to launch the instance in"
  type        = string
}
