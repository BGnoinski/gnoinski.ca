provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr}"

  tags {
    "Name" = "${var.app_env}"
  }
}
