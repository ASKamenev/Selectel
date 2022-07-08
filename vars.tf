variable "username" {
  description = "The username for the DB master user"
  type        = string
}

variable "password" {
  description = "The password for the DB master user"
  type        = string
}

# Instances count
variable "vms_count" {
  default = "3"
}

# Volume size
variable "volume_size"
  default = "20"
}

# Region name
variable "region" {
  default = "ru-1"
}

# SSh-public-key
variable "public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDdslEjLc49sg1aNOCO1jK+gx17EywPGU8dl0wO3yQhSyrN5Ca7fPCwos2Pwhk5yQ3L2McDkBJf1vRPKmd1QzDGfUP67ZXeeTSNjpG0ymH+HREGATJk1IKOOhs949c5ISdKTPTr2XY0Yd9AyeY6gMCEz2eIRKjfG1GPnXGEKc4TQp6ZlRrNlJTw8eVR5EnSqsAT+H8MtqhJoSToJszJq65HfP+eSg5uC72o8dqlfhmDg4UqneqghxgDhpxxqbpPLpxDpektMjC810AXfYnHwy5AA3gmBG8yfzMvoXI3SZboINZa+Argyr2IS3xdg+3VRUws40R4HQfHF6ZziJi1TZy4mFLmesoDPpJmjcoiHse112+ZR4XdVhKbBhfi6/00nWQUJaD9SYYvrTdNgMyskF1zRU/PbqtzhnY5jT4xdaK6vb5mAS2NfKdLgCg1WCaULG9uRz+IUu2VGihyOS1yUpNZITX/9T649yzf2QXZI7JT6oJsNu3TX5IpzaFbzPq9Jns= andrew@IBM-Laptop"

}

# Avialability zone
variable "az_zone" {
  default = "ru-1b"
}

# Volume type
variable "volume_type" {
  default = "fast.ru-1b"
}

# CIDR for subnet
variable "subnet_cidr" {
  default = "192.168.0.0/29"
}

# Flavor ID
variable "flavor" {
  default = "1011"
}
