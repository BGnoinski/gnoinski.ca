---
title: Introduction to Terraform
date: 2018-05-29T19:25:00Z
categories:
  - Utility
tags:
  - AWS
  - Terraform
---

Up till now I have been using the AWS provided cli to manage their resources, but what if I also want to use Google Cloud? I would need to download their tools, as well as learn their configuration syntax. Terraform is a fantastic tool that gives us a consistent configuration syntax for managing many different providers. There are around 200 providers, 80 of which are supported directly by Hashicorp. Of course you still need to understand all of the provider specific terminology, ec2 for AWS, instances for Google Cloud.

I have worked almost exclusively with AWS so I will be using AWS for my examples on how to use Terraform.


### Requirements

* [AWS credentials](aws-cli-setup.html)
* [Download Terraform](https://www.terraform.io/downloads.html)
* [Terraform Docs](https://www.terraform.io/docs/index.html)
* [All Terraform Providers](https://www.terraform.io/docs/providers/index.html)
* [Terraform AWS Provider](https://www.terraform.io/docs/providers/aws/index.html)
* [github example code for this post](https://github.com/BGnoinski/gnoinski.ca/tree/master/ben/terraform/intro/)

Give the docs linked above a read if you haven't already and you'll be better off.

### Steps I'm going to cover

1. <a href="#install">"Install" Terraform</a>
1. <a href="#syntax">Syntax</a>
1. <a href="#files">Terraform files</a>
1. <a href="#commands">Terraform commands</a>

### Let's roll

**<p id="install">"Install" Terraform</p>**

The reason why Install is in quotes is that Terraform is just a binary that needs to be added to our path. Visit [The Downloads Page](https://www.terraform.io/downloads.html) and download the zip file for your OS.

`wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip`

Unzip it

`unzip terraform_0.11.7_linux_amd64.zip`

Now there will be an executable called 'terraform' in the directory.

Depending on which directory you are in you likely want to move this into a bin folder that is in your path. I am going to put mine in `/usr/local/bin/` and then test to make sure terraform is working.

```
sudo mv terraform /usr/local/bin/

terraform -v
Terraform v0.11.7
```

While working with AWS, Terraform will gather credentials in all of the same ways that the aws cli does. If you've already setup your AWS credentials then you are good to go. If not click on the AWS Credentials link in the requirements. 

**<p id="syntax">Syntax</p>**

Like programming languages there are strings, lists, and maps. These data types are commonly used for a key values ex:

```
string = "value"

list = ["value1", "value2", "value3"]

map = { 
    "key1" = "value1"
    "key2" = "value2"
    "key3" = "value3"
}
```

The basic format for most of the terraform resources follows this pattern:

```
argument1 "argument_2" "argument3" {
    key1 = "value1"
}
```
ex:

```
provider "aws" {
    region = "ca-central-1"
}

resource "aws_vpc" "dev_vpc" {
    cidr_block = "10.0.0.0/24"
}

```

**argument1**: Describes which terraform module to use. Valid options are

* provider: Does not use argument3. Used to describe which provider terraform should use
* resource: Used to create a resource within a specified provider
* data: Used to gather information on a resource within a provider, read-only

**argument2**: Used to specify the resource type for the module.

* provider: "aws" OR "google" OR "github"
* resource: "aws_instance" OR "google_compute_instance" OR "github_repository"
* data: "aws_availability_zones" OR "google_compute_image" OR "github_ip_ranges"

**argument3**: Unique identifier for the resource. Used for outputs or resource interpolation(More on this in a different post). 

**Key1**: Used to specify which key we are configuring on the resource. Some keys are required, some are optional. 

**Value1**: Key1 value

If you use an AWS resource type for example, you need a corresponding aws provider. So you can't setup an aws_vpc if you have not previously configured an AWS provider. If you only have a single provider of a specific type it will be used by default for all of the associated resources. You can have multiple providers of the same type by naming them (outside of the scope of this post.) You can use multiple different providers, AWS and Google Cloud in the same deployment. Maybe you have your DNS on Route53, but you are deploying your instances on Google.

This is the very basic syntax that you should know. You can perform [interpolation](https://www.terraform.io/docs/configuration/interpolation.html) on your resources. (outside of the scope of this post.)

**<p id="files">Terraform files</p>**

We should now have a grasp on the basic concepts of Terraform, but we can't actually deploy anything. We need to put the above code into a file. I like to put provider and state information into a file called `main.tf`. One of the nice things about terraform is that it will read all .tf files in the current directory so you can logically separate your code but only need to run plan once, as well you can read information(interpolate) from resources in the other files. Because it concatenates all of the .tf files, you need to ensure that your resource unique identifiers are well, unique.

As I said I am going to put the the code provided above in a file called main.tf [You can download it here](https://github.com/BGnoinski/gnoinski.ca/tree/master/ben/terraform/intro/main.tf) if you haven't already to follow along.

main.tf
```
provider "aws" {
    region = "ca-central-1"
}

resource "aws_vpc" "dev_vpc" {
    cidr_block = "10.0.0.0/24"
}
```

**<p id="commands">Terraform commands</p>**

Now that we have the above code, we need to run `terraform init`. What this command does is look in your .tf files and find which providers you are using and download them to a folder called `.terraform`. 

If you don't run terraform init you see something like:

```
1 error(s) occurred:

* provider.aws: no suitable version installed
  version requirements: "(any version)"
  versions installed: none
```

`terraform init`
```
Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "aws" (1.20.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 1.20"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

The next command that we run is `terraform plan` what this will do is parse through all of the .tf files, make sure that variables(we haven't explored this yet) are defined, syntax is correct, and if you have previously deployed infrastrucutre query it to see what if any changes need to be made. Finally it will show you what changes it will be performing. 

`terraform plan`
```
terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_vpc.dev_vpc
      id:                               <computed>
      assign_generated_ipv6_cidr_block: "false"
      cidr_block:                       "10.0.0.0/24"
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

Notice the little message on the bottom we'll go over plan files later. For now the important thing to note is the + symbol beside our vpc which means we are adding a resource. The other options are ~ which means modifying in place, - which means destroying, -/+ which means it will destroy and then create the same resource. Some resources can be modified in place while others may need to be destroyed and re-created. Because of this it is imperative that you pay attention to the plan. 

Since we are only adding a vpc I am going to move on to actually deploying this with 

`terraform apply`
```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_vpc.dev_vpc
      id:                               <computed>
      assign_generated_ipv6_cidr_block: "false"
      cidr_block:                       "10.0.0.0/24"
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

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_vpc.dev_vpc: Creating...
  assign_generated_ipv6_cidr_block: "" => "false"
  cidr_block:                       "" => "10.0.0.0/24"
  default_network_acl_id:           "" => "<computed>"
  default_route_table_id:           "" => "<computed>"
  default_security_group_id:        "" => "<computed>"
  dhcp_options_id:                  "" => "<computed>"
  enable_classiclink:               "" => "<computed>"
  enable_classiclink_dns_support:   "" => "<computed>"
  enable_dns_hostnames:             "" => "<computed>"
  enable_dns_support:               "" => "true"
  instance_tenancy:                 "" => "<computed>"
  ipv6_association_id:              "" => "<computed>"
  ipv6_cidr_block:                  "" => "<computed>"
  main_route_table_id:              "" => "<computed>"
aws_vpc.dev_vpc: Creation complete after 9s (ID: vpc-e717ba8f)
```

On the newer versions of terraform it peforms a plan again, and then have you confirm that you want to deploy it. I went ahead and deployed it and we can see that it created a vpc for us and gave us the vpc ID in the console output. 

In terraform if you want to do multi line comments you wrap the lines in `/*` and `*/`. in the example file that you have already downloaded, comment out the first resource and uncomment the 'Update in place' resource. What I have done  is updated the existing vpc to have a tag "Name" with a value of "dev_vpc". Since you can add, modify, or remove tags at will it updates the resource in place. noted by the ~

`terraform plan`
```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  ~ aws_vpc.dev_vpc
      tags.%:    "0" => "1"
      tags.Name: "" => "dev_vpc"


Plan: 0 to add, 1 to change, 0 to destroy.
```

I am not actually going to apply the change as this is just to show the differences in the plan. Now make sure the first 2 'aws_vpc' resource blocks are commented out and uncomment 'Destroy and re-create'. I changed the cidr of the vpc which can not be updated in place, so it has to first destroy the vpc, and then re-create it with the new cidr. 

`terraform plan`
```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

-/+ aws_vpc.dev_vpc (new resource required)
      id:                               "vpc-e717ba8f" => <computed> (forces new resource)
      assign_generated_ipv6_cidr_block: "false" => "false"
      cidr_block:                       "10.0.0.0/24" => "10.10.0.0/16" (forces new resource)
      default_network_acl_id:           "acl-bda92ad5" => <computed>
      default_route_table_id:           "rtb-219d0049" => <computed>
      default_security_group_id:        "sg-eb288080" => <computed>
      dhcp_options_id:                  "dopt-a7448bce" => <computed>
      enable_classiclink:               "" => <computed>
      enable_classiclink_dns_support:   "" => <computed>
      enable_dns_hostnames:             "false" => <computed>
      enable_dns_support:               "true" => "true"
      instance_tenancy:                 "default" => <computed>
      ipv6_association_id:              "" => <computed>
      ipv6_cidr_block:                  "" => <computed>
      main_route_table_id:              "rtb-219d0049" => <computed>
      tags.%:                           "0" => "1"
      tags.Name:                        "" => "dev_vpc"


Plan: 1 to add, 0 to change, 1 to destroy.
```

If you were to apply this plan, it will destroy the vpc before re-creating it. Now if you have other resources in this vpc chances are it won't actually be able to delete it, but you need to be careful, and plan out your networking ahead of time for production networks.

I am just going to mention that after you did the initial apply there is now a file called terraform.tfstate in your folder which is how Terraform keeps track of the resources it has created.

If you are new to Terraform this is a fair bit of information to absorb so go through it all another time until you have these basic concepts down.