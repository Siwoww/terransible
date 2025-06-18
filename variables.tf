variable "vpc_cidr" {
  type = string
}

/*variable "public_subnet_cidr" {
  type = list(string)
}

variable "private_subnet_cidr" {
  type = list(string)
}
*/

locals {
  available_zone = data.aws_availability_zones.available.names
}

variable "instance_type" {
  default = "t2.micro"
}

variable "main_vol_size" {
  type = number
  default = 8
}

variable "instance_number" {
  type = number
  default = 1
}

variable "inventory_path" {
  type = string
  default = "/ansible-share/aws_hosts"
}

variable "private_key_path_path" {
  type = string
  default = "/ansible-share/ssh_key/terraform"
}