variable "image_name" {
  type    = string
  default = "ubuntu-24.04"
}

variable "server_flavor" {
  type    = string
  default = "m1.small"
}

variable "key_pair" {
  default = "cherdantsev"
}

variable "network_name" {
  default = "student-net"
}

variable "user_name" {}
variable "password" {}