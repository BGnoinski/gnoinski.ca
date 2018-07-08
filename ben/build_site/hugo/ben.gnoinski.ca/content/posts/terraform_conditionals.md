---
aliases:
  - terraform-conditionals.html
title: Terraform Conditionals
date: 2018-06-14T19:46:00Z
categories:
  - Infrastructure 
tags:
  - Terraform
  - Intermediate
---

Logic statements, if, else if, else are used everywhere in programming, including Terraform. The difference is in Terraform you need to get clever. I primarily use conditionals as feature flags within my variable files. 

A use case that I currently have is my dev environment needs a VPN to Datacenter A, but my prod environment needs a VPN to Datacenter B. In my Terraform code I have resources for both VPNs. Within those resource blocks I have a conditional as the value for the count key and that tells Terraform to either deploy the resource or not. 

If this is confusing don't worry about it. Continue reading, I show examples which hopefully makes it easier to understand.

### Requirements

* [Terraform Intro](/terraform-intro.html)
* [Terraform Variables](/terraform-variables.html)
* [Terraform Count and "Loops"](/terraform-count-and-loops.html)
* [Terraform Interpolation Docs](https://www.terraform.io/docs/configuration/interpolation.html)
    * Scroll down to "Conditionals"
* [github example code for this post](https://github.com/BGnoinski/gnoinski.ca/tree/master/ben/terraform/conditionals/)

Give the docs linked above in the requirements a read if you haven't already and you'll be better off.

### Steps I'm going to cover

1. <a href="#syntax">Conditional Syntax</a>
1. <a href="#usage">Practical usage</a>

### Let's roll

**<p id="syntax">Conditional Syntax</p>**


```
"${argument1 || argument1a && argument1b ? argument2 : argument3}"
```

**argument1 1a 1b**: What values we are we checking? This can be a variable, an interpolation, and we can chain multiple values together with `||`(OR) or `&&`(AND). We can also use the unary not operator `!`. 

* *<span style="color:#054300">I think you can use parentheses around your values for the `||` and `&&` operations like `${(var.vara || var.varb) && var.varc ? 1 : 0}`</span>*

**argument2**: Value returned if all evaluated expression is true.

**argument3**: Value returned if all evaulated expression is false.

Couple of things to note

1. The value returned must be the same type (int, str, bool) for both true and false. So you can not return '1' if true and 'nothing' if false.
1. You can use interpolation for any of the arguments. Keep rule 1 in mind if you are using interpolation for your true/false values.


**<p id="usage">Practical usage</p>**

Where I use conditionals 90% of the time is in conjunction with "count". If something is true, then deploy this resource. 

**Example 1**

I have a variable called "deploy_vpc" with a default value of false.

```
# main.tf
provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  count = "${var.deploy_vpc ? 1 : 0}"
  cidr_block = "10.10.10.0/24"
}

# variables.tf
variable "region" {}

variable "deploy_vpc" {
  default = false
}

# terraform.tfvars
region = "ca-central-1"
```

Since everything our variable is currently false I expect nothing to happen.

```
terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, no
actions need to be performed.
```

Always nice when what you think is going to happen, happens. Now I am going to add a variable into variables.tf and make deploy_vpc true

```
# terraform.tfvars
region = "ca-central-1"

deploy_vpc = true

terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_vpc.vpc
      id:                               <computed>
      assign_generated_ipv6_cidr_block: "false"
      cidr_block:                       "10.10.10.0/24"
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


Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

And just like that you can have multiple resources in a single file that get turned on and off by setting variables. You can combine this with loops to do some pretty complicated stuff.

**Example 2**

```
# main.tf
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

# variables.tf
variable "region" {}

variable "deploy_vpc" {
  default = false
}

variable "vpn_to_office" {
  default = false
}

variable "vpn_to_datacenter" {
default = false
}


# terraform.tfvars
region = "ca-central-1"

deploy_vpc = true
```

With both vpn\_to\_ variables false we get:

```
Terraform will perform the following actions:

  + aws_vpc.vpc
      id:                               <computed>
      assign_generated_ipv6_cidr_block: "false"
      cidr_block:                       "10.10.10.0/24"
      default_network_acl_id:           <computed>
      default_route_table_id:           <computed>
      default_security_group_id:        <computed>
      dhcp_options_id:                  <computed>
      enable_classiclink:               <computed>
      enable_classiclink_dns_support:   <computed>
      enable_dns_hostnames:             <computed>
      enable_dns_support:               "true"
      instance_tenancy:                 "default"
      ipv6_association_id:              <computed>
      ipv6_cidr_block:                  <computed>
      main_route_table_id:              <computed>


Plan: 1 to add, 0 to change, 0 to destroy.
```

So no virtual gateway, let's see what happnes when we enable one of them:

```
# terraform.tfvars

region = "ca-central-1"

deploy_vpc = true

vpn_to_office = true
```

```
Terraform will perform the following actions:

  + aws_vpc.vpc
      id:                               <computed>
      assign_generated_ipv6_cidr_block: "false"
      cidr_block:                       "10.10.10.0/24"
      default_network_acl_id:           <computed>
      default_route_table_id:           <computed>
      default_security_group_id:        <computed>
      dhcp_options_id:                  <computed>
      enable_classiclink:               <computed>
      enable_classiclink_dns_support:   <computed>
      enable_dns_hostnames:             <computed>
      enable_dns_support:               "true"
      instance_tenancy:                 "default"
      ipv6_association_id:              <computed>
      ipv6_cidr_block:                  <computed>
      main_route_table_id:              <computed>

  + aws_vpn_gateway.vgw
      id:                               <computed>
      amazon_side_asn:                  <computed>
      tags.%:                           "1"
      tags.Name:                        "main"
      vpc_id:                           "${aws_vpc.vpc.id}"


Plan: 2 to add, 0 to change, 0 to destroy.
```

And now let's enable the other one:

```
#terraform.tfvars

region = "ca-central-1"

deploy_vpc = true

vpn_to_datacenter = true
```


```
Terraform will perform the following actions:

  + aws_vpc.vpc
      id:                               <computed>
      assign_generated_ipv6_cidr_block: "false"
      cidr_block:                       "10.10.10.0/24"
      default_network_acl_id:           <computed>
      default_route_table_id:           <computed>
      default_security_group_id:        <computed>
      dhcp_options_id:                  <computed>
      enable_classiclink:               <computed>
      enable_classiclink_dns_support:   <computed>
      enable_dns_hostnames:             <computed>
      enable_dns_support:               "true"
      instance_tenancy:                 "default"
      ipv6_association_id:              <computed>
      ipv6_cidr_block:                  <computed>
      main_route_table_id:              <computed>

  + aws_vpn_gateway.vgw
      id:                               <computed>
      amazon_side_asn:                  <computed>
      tags.%:                           "1"
      tags.Name:                        "main"
      vpc_id:                           "${aws_vpc.vpc.id}"


Plan: 2 to add, 0 to change, 0 to destroy.
```

As you can see by enabling either of the variables we get the vpn_gateway added.

These were some very simple exmaples to show you where to start. Your conditionals can be as simple or complex as you need. 