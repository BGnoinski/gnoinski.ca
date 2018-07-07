---
title: Terraform Count and Loops
date: 2018-06-03T07:56:00Z
categories:
  - Utility
tags:
  - Terraform
  - advanced
---

When working with infrastructure there is a very good chance that we want more than 1 of some resource. We need more than 1 subnet, we need 4 instances. How can we accomplish that without having to explicitly declare each resource, we use the special 'count' key that exists for every resource type.

Maybe we don't want those subnets to have the same name, so we create a list of names to loop through. If you have read the Terraform docs, you are probably thinking <span style="color:#054300"> "Ben Terraform doesn't have any loop syntax, you're just making this up."</span> Well you're not wrong, Terraform does not currently have native loop syntax. (I know a guy, and he said that hcl v2 might have some basic loops built in!!). So we are going to use leverage the 'count' key with it's special attribute 'index'

### Requirements

* [Intro to Terraform](introduction-to-terraform.html)
* [Terraform Interpolation](terraform-interpolation.html)
* [Terraform docs - count](https://www.terraform.io/docs/configuration/resources.html)
* [github example code for this post](https://github.com/BGnoinski/gnoinski.ca/tree/master/ben/terraform/loops/)


Give the docs linked above a read if you haven't already and you'll be better off.

### Steps I'm going to cover

1. <a href="#count">Using count to create multiple resources</a>
1. <a href="#countindex">Using count.index to provide loops</a>

1. <a href="#length">Using length() to get a dynamic count</a>

I added in using length as I was done the first 2 surprisingly quickly.

### Let's roll

**<p id="count">Using count to create multiple resources</p>**

To demonstrate the usage of count I have removed all of the subnets and I am going to simply create 2 vpcs. In this example they will be identical which is something that you usually wouldn't do, but it serves the purpose.

```
# variables.tf
variable "region" {}

variable "app_env" {}

variable "cidr" {}

# dev.tfvars
app_env = "dev"

cidr = "10.10.0.0/16"

# main.tf
provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  count = 2
  cidr_block = "${var.cidr}"

  tags {
    "Name" = "${var.app_env}"
  }
}
```

`terraform plan -var-file=dev.tfvars`
```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_vpc.vpc[0]
      id:                               <computed>
      assign_generated_ipv6_cidr_block: "false"
      cidr_block:                       "10.10.0.0/16"
      default_network_acl_id:           <computed>
      default_route_table_id:           <computed>
      default_security_group_id:        <computed>
      dhcp_options_id:                  <computed>
      enable_classiclink:               <computed>
      enable_classiclink_dns_support:   <computed>
      enable_dns_hostnames:             <computed>
      enable_dns_support:               "true"
      instance_tenancy:                 <computed>
      ipv6_association_id:              <computed>
      ipv6_cidr_block:                  <computed>
      main_route_table_id:              <computed>
      tags.%:                           "1"
      tags.Name:                        "dev"

  + aws_vpc.vpc[1]
      id:                               <computed>
      assign_generated_ipv6_cidr_block: "false"
      cidr_block:                       "10.10.0.0/16"
      default_network_acl_id:           <computed>
      default_route_table_id:           <computed>
      default_security_group_id:        <computed>
      dhcp_options_id:                  <computed>
      enable_classiclink:               <computed>
      enable_classiclink_dns_support:   <computed>
      enable_dns_hostnames:             <computed>
      enable_dns_support:               "true"
      instance_tenancy:                 <computed>
      ipv6_association_id:              <computed>
      ipv6_cidr_block:                  <computed>
      main_route_table_id:              <computed>
      tags.%:                           "1"
      tags.Name:                        "dev"


Plan: 2 to add, 0 to change, 0 to destroy.
```

2 identical vpcs are going to be created, they will have different vpc ids though. That's all there is to count, and not really where the magic of this post comes into play.

**<p id="countindex">Using count.index to provide loops</p>**

We saw how count gives us 2 vpcs from one block of code which means that Terraform looped over the code, so how do we leverage that. In comes 'count.index'. When you use 'count', on each iteration Terraform provides 'count.index' which is the current iteration it is on. 'count.index' is also zero indexed like lists, can you see where this is going? Say you want to create a dev, and a test vpc but don't want to give them the same name or cidr. Initially we had to duplicate our code for each vpc, but we can combine 'count.index' with lists, or maps to so that we don't have to duplicate code.

```
# variables.tf
variable "region" {}

variable "vpcs" {
  type = "list"
}

variable "cidrs" {
  type = "map"
}

# dev.tfvars
app_env = "dev"

vpcs = ["dev", "test"]

cidrs = {
  "0" = "10.10.0.0/16"
  "1" = "10.20.0.0/16"
}

# main.tf
provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  count = 2
  cidr_block = "${lookup(var.cidrs, count.index)}"

  tags {
    "Name" = "${element(var.vpcs, count.index)}"
  }
}
```


`terraform plan -var-file=dev.tfvars`
```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_vpc.vpc[0]
      id:                               <computed>
      assign_generated_ipv6_cidr_block: "false"
      cidr_block:                       "10.10.0.0/16"
      default_network_acl_id:           <computed>
      default_route_table_id:           <computed>
      default_security_group_id:        <computed>
      dhcp_options_id:                  <computed>
      enable_classiclink:               <computed>
      enable_classiclink_dns_support:   <computed>
      enable_dns_hostnames:             <computed>
      enable_dns_support:               "true"
      instance_tenancy:                 <computed>
      ipv6_association_id:              <computed>
      ipv6_cidr_block:                  <computed>
      main_route_table_id:              <computed>
      tags.%:                           "1"
      tags.Name:                        "dev"

  + aws_vpc.vpc[1]
      id:                               <computed>
      assign_generated_ipv6_cidr_block: "false"
      cidr_block:                       "10.20.0.0/16"
      default_network_acl_id:           <computed>
      default_route_table_id:           <computed>
      default_security_group_id:        <computed>
      dhcp_options_id:                  <computed>
      enable_classiclink:               <computed>
      enable_classiclink_dns_support:   <computed>
      enable_dns_hostnames:             <computed>
      enable_dns_support:               "true"
      instance_tenancy:                 <computed>
      ipv6_association_id:              <computed>
      ipv6_cidr_block:                  <computed>
      main_route_table_id:              <computed>
      tags.%:                           "1"
      tags.Name:                        "test"


Plan: 2 to add, 0 to change, 0 to destroy.
```

Oooh vpcs with different cidrs, and different Names. In case you're still unsure what happened let's go through this. We are going to create 2 vpcs because of count = 2. 

On the first iteration terraform provides a 'count.index' of 0, remember it's 0 indexed, so the code terraform runs would look like:

```
# count.index = 0
resource "aws_vpc" "vpc" {
  cidr_block = "${lookup(var.cidrs, 0)}"

  tags {
    "Name" = "${element(var.vpcs, 0)}"
  }
}
```

For the cidr block it uses the lookup function on the var.cidrs map and gets the value of the 0 key (10.10.0.0/16). For the Name tag it uses the element fuction on the var.vpcs list to get the value of index 0 (dev).

On the next iteration it would look like this

```
# count.index = 1
resource "aws_vpc" "vpc" {
  cidr_block = "${lookup(var.cidrs, 1)}"

  tags {
    "Name" = "${element(var.vpcs, 1)}"
  }
}
```

It gets the value for the 1 key from var.cidrs (10.20.0.0/16), and it gets value for index 1 from var.vpcs (test).

**<p id="length">Using length() to get a dynamic count</p>**

In the previous examples we had to know how many resources we were creating for count. What if we want to add a prod vpc, we have to modify the var.cidrs, and var.vpcs variables, but also have to modify the count manually, and that's just far too much effort. In comes 'length()'. Length gives us the number if items in a list or keys in a map. 

variables.tf and dev.tfvars remain the same as in the previous examples.

```
# main.tf
resource "aws_vpc" "vpc" {
  count = "${length(var.vpcs)}"
  cidr_block = "${lookup(var.cidrs, count.index)}"

  tags {
    "Name" = "${element(var.vpcs, count.index)}"
  }
}
```

Our count key now uses "${length(var.vpcs)}" to calculate what the count should be. 

* <span style="color:#8C4B20">*WARNING*: You will need to make sure that your var.cidrs and var.vpcs have the same amount of items in each or else you will experience unintended output.</span>