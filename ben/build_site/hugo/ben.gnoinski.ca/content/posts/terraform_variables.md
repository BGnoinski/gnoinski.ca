---
aliases:
  - terraform-variables.html
title: Terraform Variables 
date: 2018-06-01T18:55:00Z
categories:
  - Terraform
tags:
  - Terraform
  - beginner
---

This post is going to start off with the basics, and then get move into intermediate level concetps. 

### Requirements

* [Intro to Terraform](/introduction-to-terraform.html)
* [Terraform Variable Docs](https://www.terraform.io/docs/configuration/variables.html)
* [github example code for this post](https://github.com/BGnoinski/gnoinski.ca/tree/master/ben/terraform/variables/)

Give the docs linked above in the requirements a read if you haven't already and you'll be better off.

### Steps I'm going to cover

1. <a href="#declare">Declare variables</a>
1. <a href="#assigning">Assigning variables</a>
1. <a href="#using">Using variables</a>
1. <a href="#varfiles">Variable files</a>

### Let's roll

**<p id="declare">Declare variables</p>**

Declaring a variable is really easy.

```
variable "argument1" {
    type = ""
    default = ""
}
```

**variable**: Tells Terraform we are declaring a variable

**argument1**: Unique identifier for the variable.

**type**: must be one of "string", "list", "map". If your variable is a string you can omit the type and string will be inferred. 

**default**: creates a default variable of the specified type.

Declaring variables

```
variable "string" {}

variable "list" {
    type = "list"
}

variable "map"{
    type = "map"
}
```

Declaring variables with default values

```
variable "string" {
    default "Test string"
}

variable "list" {
    type = "list"
    default = ["value1", "value2", "value3"]
}

variable "map"{
    type = "map"
    default = {
        "key1" = "value1"
        "key2" = "value2"
    }
}
```

**<p id="assigning">Assigning variables</p>**

If you declare a variable Terraform requires the variable be assigned. In our main.tf we can assign values at the top of the file like so

```
argument1 = "value"
```

**argument1**: This is the unique identifier of the variable, will be the same as argument1 above.

```
string = "Test string2"

list = ["value4", "value5", "value6"]

map = {
    "key3" = "value3"
    "key4" = "value4"
} 
```

That's how you assign variables. Note that if you have a default value, but declare it elsewhere the default value is overwritten by your declared value.

If you are running Terraform interactively and a variable is not assigned in any of the files it loads you will be prompted to manually input the variable at plan/apply time. 

**<p id="using">Using Variables</p>**

Now that we have declared a variable, how do we use it in our code? We use interpolation to get the value of the variable. This is our first foray into interpolation and looks like this:

```
variable "region" { 
    default = "ca-central-1"
}

provider "aws" {
    region = "${var.region}"
}
```

When you use "${}" Terraform knows that the code in the middle needs to be parsed. In this case it knows that it needs to go and get the value of region variable. So variables get called with "${var.UNIQUEIDENTIFIER}" .

If you declared a variable but have not assigned it, Terraform will ask you to input it. But if you call a variable, and have not declared it you will see

```
terraform plan

Error: resource 'aws_vpc.vpc' config: unknown variable referenced: 'app_env'; define it with a 'variable' block
```

**<p id="varfiles">Variable files</p>**

Hard coding the variables at the top of main.tf does us little good as there is no way to change the variables depending on environment or application. In comes variable files, and the `-var-file=` terraform command flag.

Like with .tf files, if you have a file called 'terraform.tfvars' or '*.auto.tfvars' Terraform will automatically load and parse them. It's best practice to give your variable files a .tfvars extension.

I like to create a .tfvars file per environment so I have 'dev.tfvars', 'test.tfvars', 'prod.tfvars' etc. You could expand this to have a file per environment and region if you have resources in ca-central-1 as well as us-west-2.

Hopefully you have grabbed the code linked in the requirements. So that you can follow along. 

Files in this example:

* 'main.tf' - Has the aws provider, and the vpc resource declared in it. 
* 'variables.tf' has the variables declared
* terraform.tfvars has the region declared (because it's called terraform.tfvars it gets loaded automagically by Terraform)
* 'dev.tfvars' has it's app_env and cidr declared
* 'test.tfvars' has it's app_env and cidr declared

`terraform plan` at this point will ask us to input the app_env variable manually

```
terraform plan
var.app_env
  Enter a value: 
```

I just canceled out of that with `ctrl + c` since we have assigned the varibles in dev.tfvars file we are going to run `terraform plan -var-file=dev.tfvars`

```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_vpc.vpc
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


Plan: 1 to add, 0 to change, 0 to destroy.

```

We can see that it's going to create our vpc with the 10.10.0.0/16 cidr and tag our vpc with the "Name" "dev"

Now if we run `terraform plan -var-file=test.tfvars` we'll get

```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_vpc.vpc
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


Plan: 1 to add, 0 to change, 0 to destroy.
```

Different cidr and Name tag.

By using variable files you can leverage infrastructure as code to ensure that your resources are the same between different environments. We're getting rid of "It works in dev, not sure what's going on in production".
