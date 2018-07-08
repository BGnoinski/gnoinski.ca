provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  count = "${var.deploy_vpc ? 1 : 0}"
  cidr_block = "10.10.10.0/24"
}
