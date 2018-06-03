variable "region" {}

variable "app_env" {}

variable "cidr" {}

variable "public_ca-central-1a_cidr" {}

variable "public_ca-central-1b_cidr" {}

variable "private_ca-central-1a_cidr" {}

variable "private_ca-central-1b_cidr" {}

variable "availability_zones_list" {
  type = "list"
}

variable "availability_zones_map" {
  type = "map"
}
