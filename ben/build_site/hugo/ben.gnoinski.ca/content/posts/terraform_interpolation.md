---
title: Terraform Interpolation
date: 2018-06-02T07:03:00Z
categories:
  - Terraform
tags:
  - Terraform
  - Intermediate
---

Interpolation and why do we need it? When we use Terraform to create a resource, often we want to use information from that resource while creating another resource. An example that I used before is getting the IP address of an instance for use with a DNS record. 

I am using the sample code from [Terraform Variables](terraform-variables.html) as a starting point. We have the ability to create a dev or test vpc with their own names and cidrs. I will extend that to create public and private subnets in availability zones ca-central-1a and ca-central-1b in either vpc using lists and maps. In the end we will have vpc that contains public subnets in ca-central-1a and ca-central-1b, and private subnets in ca-central-1a and ca-central-1b.

### Requirements

* [Intro to Terraform](introduction-to-terraform.html)
* [Terraform Interpolation Docs](https://www.terraform.io/docs/configuration/interpolation.html)
* [Terraform aws_vpc resource](https://www.terraform.io/docs/providers/aws/r/vpc.html)
* [Terraform aws_subent resource](https://www.terraform.io/docs/providers/aws/r/subnet.html)
* [github example code for this post](https://github.com/BGnoinski/gnoinski.ca/tree/master/ben/terraform/interpolation/)

Give the docs linked above in the requirements a read if you haven't already and you'll be better off. Specifically take a look at the attributes reference of the aws_vpc, as well as the element() and lookup() interpolation functions.

### Steps I'm going to cover

1. <a href="#attributes">User Created Resources</a>
1. <a href="#lists">List Values</a>
1. <a href="#maps">Map Values</a>

### Let's roll

**<p id="attributes">User Created Resources</p>**

In order to create subnets in both vpcs using the same resources I added to variables.tf

```
# variables.tf
variable "public_ca-central-1a_cidr" {}

variable "public_ca-central-1b_cidr" {}

variable "private_ca-central-1a_cidr" {}

variable "private_ca-central-1b_cidr" {}
```

I also added corresponding values in both dev.tfvars and test.tfvars depending on the vpc cidr.


```
# dev.tfvars
public_ca-central-1a_cidr = "10.10.0.0/24"

public_ca-central-1b_cidr = "10.10.1.0/24"

private_ca-central-1a_cidr = "10.10.2.0/24"

private_ca-central-1b_cidr = "10.10.3.0/24"
```

At this point I have a vpc with no subnets and I have all of the variables setup to create subnets so let's see what that looks like for a single subnet.

```
resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr}"
}

resource "aws_subnet" "public_ca-central-1a" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.public_ca-central-1a_cidr}"
}
```

From this we can see that the subnets cidr_block is getting it's value from a variable which we've seen before, but the vpc id is coming from "${aws_vpc.vpc.id}" . Let's break this down.

```
"${argument1.argument2.argument3}"
```

**argument1**: Which resource type are we getting information from?

**argument2**: What is the unique identifier of the resource type?

**argument3**: What is the attribute that we are using from that resource?

In our case we are going to the aws_vpc with the unique id 'vpc' and getting the attribute 'id'. So when we run a plan it looks like this:

```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_subnet.private_ca-central-1a
      id:                              <computed>
      assign_ipv6_address_on_creation: "false"
      availability_zone:               <computed>
      cidr_block:                      "10.10.2.0/24"
      ipv6_cidr_block:                 <computed>
      ipv6_cidr_block_association_id:  <computed>
      map_public_ip_on_launch:         "false"
      vpc_id:                          "vpc-973798ff"

Plan: 1 to add, 0 to change, 0 to destroy.
```

Where did this vpc-973798ff come from, well it came from the vpc that we had created previously. If you have not previously applied applied any Terraform it would look like this:

```
  + aws_subnet.private_ca-central-1a
      id:                               <computed>
      assign_ipv6_address_on_creation:  "false"
      availability_zone:                <computed>
      cidr_block:                       "10.10.2.0/24"
      ipv6_cidr_block:                  <computed>
      ipv6_cidr_block_association_id:   <computed>
      map_public_ip_on_launch:          "false"
      vpc_id:                           "${aws_vpc.vpc.id}"
```

Because the vpc had not previously been created when I planned out this subnet Terraform has no way of knowing what the vpc id will be, so it simply shows you that it's going to get the value from "${aws_vpc.vpc.id}".

* <span style="color:#054300">*Info* ~ "Slow your roll Ben, are you trying to say we need to make sure our code creates the resources in order?" </span> Not at all. As long as you do not create a circular dependency, `terraform plan` figures out which resources need to be created in which order. Terraform also does it's best to create resources in parallel.

**<p id="lists">List Values</p>**

In the above examples I created the subnets in the vpc, but despite what I named stuff we didn't actually specify which availability zone to create the resources in. Terraform will pick availability zones for us, but if it chooses the same availability zone we do not have any redundancy against availbility zone failure. I am going to create a list variable called availability_zones_list with 2 values, "ca-central-1a" and "ca-central-1b".

```
# variables.tf
variable "availability_zones_list" {
    type = "list"
}

# dev.tfvars
availability_zones_list = ["ca-central-1a", "ca-central-1b"]

# main.tf
resource "aws_subnet" "public_ca-central-1a" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.public_ca-central-1a_cidr}"
  availability_zone = "${var.availability_zones_list[0]}"
}

resource "aws_subnet" "public_ca-central-1b" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.public_ca-central-1b_cidr}"
  availability_zone = "${element(var.availability_zones_list, 1)}"
}
```

`terraform plan -var-file=dev.tfvars`
```
+ aws_subnet.public_ca-central-1a
      id:                               <computed>
      assign_ipv6_address_on_creation:  "false"
      availability_zone:                "ca-central-1a"
      cidr_block:                       "10.10.0.0/24"
      ipv6_cidr_block:                  <computed>
      ipv6_cidr_block_association_id:   <computed>
      map_public_ip_on_launch:          "false"
      vpc_id:                           "${aws_vpc.vpc.id}"

  + aws_subnet.public_ca-central-1b
      id:                               <computed>
      assign_ipv6_address_on_creation:  "false"
      availability_zone:                "ca-central-1b"
      cidr_block:                       "10.10.1.0/24"
      ipv6_cidr_block:                  <computed>
      ipv6_cidr_block_association_id:   <computed>
      map_public_ip_on_launch:          "false"
      vpc_id:                           "${aws_vpc.vpc.id}"
```

A few different things happened here, I'll start with `aws_subnet.public_ca-central-1a`. I called the variable like we have seen in the past, but added [0] at the end. This means that lists in Terraform are 0 indexed, and you can access the values like you can in other programming languages. In `aws_subnet.public_ca-central-1b` I didn't do that, I used 'element()' which took 2 arguments, first the list, second the index of the item within the list. If you know the position of your value ahead of time the [0] method works just fine, but element definitely has it's uses and we'll explore that in a later post.

Now in the plan availability_zone is no longer `<computed>`, it is very clearly either ca-central-1a, or ca-central-1b. 

**<p id="maps">Map Values</p>**

Maps certainly have their uses in terraform so for this example I am going to create a variable "availabitily_zones_map" with 2 keys "private_ca-central-1a" and "private_ca-central-1b". Each keys value will be it's corresponding availability zone, either "ca-central-1a" or "ca-central-1b". 

```
# variables.tf
variable "availability_zones_map" {
  type = "map"
}

# dev.tfvars
availability_zones_map = {
  "private_ca-central-1a" = "ca-central-1a"
  "private_ca-central-1b" = "ca-central-1b"
}

# main.tf
resource "aws_subnet" "private_ca-central-1a" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.private_ca-central-1a_cidr}"
  availability_zone = "${var.availability_zones_map["private_ca-central-1a"]}"
}

resource "aws_subnet" "private_ca-central-1b" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.private_ca-central-1b_cidr}"
  availability_zone = "${lookup(var.availability_zones_map, "private_ca-central-1b")}"
}
```

`terraform plan -var-file=dev.tfvars`

```
  + aws_subnet.private_ca-central-1a
      id:                               <computed>
      assign_ipv6_address_on_creation:  "false"
      availability_zone:                "ca-central-1a"
      cidr_block:                       "10.10.2.0/24"
      ipv6_cidr_block:                  <computed>
      ipv6_cidr_block_association_id:   <computed>
      map_public_ip_on_launch:          "false"
      vpc_id:                           "${aws_vpc.vpc.id}"

  + aws_subnet.private_ca-central-1b
      id:                               <computed>
      assign_ipv6_address_on_creation:  "false"
      availability_zone:                "ca-central-1b"
      cidr_block:                       "10.10.3.0/24"
      ipv6_cidr_block:                  <computed>
      ipv6_cidr_block_association_id:   <computed>
      map_public_ip_on_launch:          "false"
      vpc_id:                           "${aws_vpc.vpc.id}"
```

Should be no surprise here our subnets have very clearly defined availability zones. Similar to lists, we can access the maps values by using ["key_name"] at the end of the variable. Or we can use the 'lookup()' function. Which like 'element()' takes 2 arguments(actually 3, 3rd is optional and we aren't using it) first the map, second the key to lookup. The maps keys can be whatever you need, including numbers which will be important in a later post. 

 * <span style="color:#8C4B20">*WARNING*: The keys for maps must be encased in double quotes `" "`. Yes it is weird that you have double quotes surrounding the interpolation and then double quotes inside as well, but single quotes will break your code. Trust me on that.
 * <span style="color:#8C4B20">*WARNING*: If you are familiar with complicate data structures, lists nested in maps, or maps nested in lists abandon all hope of trying to get interpolation to work with them. In Terraform it's bets to use flat maps, and lists.

At this point I hope you have a basic grasp of how interpolation works, and can start to see some of the possibilities that Terraform can provide. 

I use the following functions pretty heavily, so I recommend you read the docs on them yourself, I will be using them in later posts.

* length()
* split()