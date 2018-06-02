provider "aws" {
  region = "ca-central-1"
}

# Initial vpc block, you should plan and apply this one

resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/24"
}

# Update in place
/*
resource "aws_vpc" "dev_vpc" {
    cidr_block = "10.0.0.0/24"

    tags {
        Name = "dev_vpc"
    }
}
*/


# Destroy and re-create
/*
resource "aws_vpc" "dev_vpc" {
    cidr_block = "10.10.0.0/16"

    tags {
        Name = "dev_vpc"
    }
}
*/

