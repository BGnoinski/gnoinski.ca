provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  count = "${var.deploy_vpc ? 1 : 0}"
  cidr_block = "10.10.10.0/24"
}

resource "aws_vpn_gateway" "vgw" {
  count = "${var.vpn_to_office || var.vpn_to_datacenter ? 1 : 0}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "main"
  }
}
