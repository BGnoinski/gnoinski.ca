---
aliases:
  - terraform-conditionals.html
title: Terraform Conditionals
date: 2018-06-14T19:46:00Z
draft: true
categories:
  - Infrastructure 
tags:
  - Terraform
---

Logic statements, if, else if, else are used everywhere in programming, including Terraform. The difference is in Terraform you need to get clever. I primarily use conditionals as feature flags with my variable files. 

A use case that I currently have is my dev environment needs a VPN to Datacenter A, but my prod environment needs a VPN to Datacenter B. In my Terraform code I have resources for both VPNs. Within those resource blocks I have a conditional as the value for the count key and that tells Terraform to either deploy the resource or not. 

If this is confusing don't worry about it. Continue reading, I show examples which hopefully makes it easier to understand.

### Requirements

* [Terraform Intro](/terraform-intro.html)
* [Terraform Variables](/terraform-variables.html)
* [Terraform Count and "Loops"](/terraform-count-and-loops.html)
* [Terraform Interpolation Docs](https://www.terraform.io/docs/configuration/interpolation.html)
    * Scroll down to "Conditionals"

Give the docs linked above in the requirements a read if you haven't already and you'll be better off.

### Steps I'm going to cover

1. <a href="#syntax">Conditional Syntax</a>
1. <a href="#usage">Practical usage</a>

### Let's roll

**<p id="syntax">Conditional Syntax</p>**


```
"${argument1 || argument1a && argument1c ? argument2 : argument3}"
```

**argument1**: What values we are we checking? This can be a variable, an interpolation, and we can chain multiple values together with `||`(OR) or `&&`(AND). We can also use the unary not operator `!`. 

* *I think you can use parentheses around your values for the `||` and `&&` operations like `${(var.vara || var.varb) && var.varc ? 1 : 0}` We'll test this out to confirm.*

**argument2**: Value returned if all evaluated expression is true.

**argument3**: Value returned if all evaulated expression is false.

Couple of things to note

1. The value returned must be the same type (int, str, bool) for both true and false. So you can not return '1' if true and 'nothing' if false.
1. You can use interpolation for any of the arguments. Keep rule 1 in mind if you are using interpolation for your true/false values.


**<p id="usage">Practical usage</p>**

