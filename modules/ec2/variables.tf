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

variable "key_name" {
  type = string
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the instance in"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs to attach to the instance"
  type        = list(string)
  default     = []
}
