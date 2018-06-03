provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr}"

  tags {
    "Name" = "${var.app_env}"
  }
}

resource "aws_subnet" "public_ca-central-1a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.public_ca-central-1a_cidr}"
  availability_zone = "${var.availability_zones_list[0]}"
}

resource "aws_subnet" "public_ca-central-1b" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.public_ca-central-1b_cidr}"
  availability_zone = "${element(var.availability_zones_list, 1)}"
}

resource "aws_subnet" "private_ca-central-1a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.private_ca-central-1a_cidr}"
  availability_zone = "${var.availability_zones_map["private_ca-central-1a"]}"
}

resource "aws_subnet" "private_ca-central-1b" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.private_ca-central-1b_cidr}"
  availability_zone = "${lookup(var.availability_zones_map, "private_ca-central-1b")}"
}
