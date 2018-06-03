provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  count = "${length(var.vpcs)}"
  cidr_block = "${lookup(var.cidrs, count.index)}"

  tags {
    "Name" = "${element(var.vpcs, count.index)}"
  }
}
