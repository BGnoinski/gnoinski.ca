---
title: "Switching From Pelican To Hugo - Pt3"
date: 2018-07-06T03:22:05Z
categories:
  - blog
tags:
  - hugo
---

Hugo has a different way of generating links so I need to do a couple of things to make sure the new blog doesn't break old links. Pelican took the title of the post, replaced spaces with - and added .html at the end.

'updating-makefile-to-a-python-script-clean.html'

Hugo takes the file name, I think (my urls happen to be what I name the file), and makes what they call "pretty" urls

'/posts/hugo_switch_pt1/'

I also need move and update links to my static files(images). 

### Requirements

* [Hugo URL Management](https://gohugo.io/content-management/urls/)
    * **added after my initial best laid plans**
* [Hugo Static Files](https://gohugo.io/content-management/static-files/)

Give the docs linked above in the requirements a read if you haven't already and you'll be better off.

### Steps I'm going to cover

1. <a href="#currenttitles">Get Current Titles</a>
1. <a href="#createaliases">Transform Titles To Links</a>
1. <a href="#addaliases">Add Aliases to Posts</a>
1. <a href="#updateexisting">Update Existing Links On My Posts</a>
    * **added after my initial best laid plans**
* <a href="#staticfiles">Update Static Files</a>

### Let's roll

**<p id="currenttitles">Get Current Titles</p>**

In order to get the current titles I am going to use grep to find all of the titles.

```
grep -Hrn 'title: '

posts/makefile_vs_python_pt1.md:2:title: Updating Makefile to a Python script - Clean
posts/terraform_variables.md:2:title: Terraform Variables 
posts/site_setup_pt5.md:2:title: Invalidating Cloudfront Cache
posts/create_iam_user.md:2:title: Create an AWS IAM user
posts/makefile_vs_python_pt2.md:2:title: Updating Makefile to a Python script - build run dev container
posts/terraform_interpolation.md:2:title: Terraform Interpolation
posts/terraform_conditionals.md:2:title: Terraform Conditionals
posts/site_setup_pt3.md:2:title: Set up ACM SSL Certs and Domain Validation with Route53
posts/site_setup_pt2.md:2:title: Uploading My New Site To S3
posts/awscli_setup.md:2:title: AWS cli setup
posts/terraform_loops.md:2:title: Terraform Count and Loops
posts/site_setup_pt1.md:2:title: How this site came to be
posts/TEMPLATE:2:title: ""
posts/site_setup_final.md:2:title: Final Thoughts On Setting Up My Site
posts/site_setup_pt4.md:2:title: Setting up Cloudfront Distribution
posts/hugo_switch_pt1.md:2:title: "Switching From Pelican To Hugo"
posts/hugo_switch_pt1.md:213:title: "My First Post"
posts/terraform_intro.md:2:title: Introduction to Terraform
posts/makefile_vs_python_pt4.md:2:title: Updating Makefile to a Python script - Conclusion
posts/hugo_switch_pt3.md:2:title: "Adding Aliases to posts"
posts/hugo_switch_pt3.md:40:`grep -Hrn 'title: '`
posts/hugo_switch_pt2.md:2:title: "Converting Pelican posts to Hugo"
posts/hugo_switch_pt2.md:78:title: "Converting Pelican posts to Hugo"
posts/hugo_switch_pt2.md:111:title: AWS cli setup
posts/makefile_vs_python_pt3.md:2:title: Updating Makefile to a Python script - upload to s3, argparse
```

As you can see almost of all 'title:'s are located on line 2, the only ones that aren't are in the hugo_switch posts but we can just skip those entirely as they were never in pelican. And of course we'll skip TEMPLATE.

A few things I wanted to Clarify
* Does pelican just convert all spaces to -? No, all words are single hypen sperated
* Does pelican mix uppercase, lowercase? No, all converted to lowercase. 
* How does Pelican treat commas? Stripped out. 

I used a text editor to create a list to work on without any of the file info, and saved it as titles.txt.

```
cat titles.txt

Updating Makefile to a Python script - Clean
Terraform Variables 
Invalidating Cloudfront Cache
Create an AWS IAM user
Updating Makefile to a Python script - build run dev container
Terraform Interpolation
Terraform Conditionals
Set up ACM SSL Certs and Domain Validation with Route53
Uploading My New Site To S3
AWS cli setup
Terraform Count and Loops
How this site came to be
Final Thoughts On Setting Up My Site
Setting up Cloudfront Distribution
Introduction to Terraform
Updating Makefile to a Python script - Conclusion
Updating Makefile to a Python script - upload to s3, argparse
```

**<p id="createaliases">Transform Titles To Links</p>**

I create a script called 'titles_to_links.sh' that I think will create what I want. I had to google to figure out how to append to the end of a line, as well as how to convert everything to lowercase.

```
#!/bin/bash
sed -i 's| - |-|g' titles.txt
sed -i 's|,||g' titles.txt
sed -i 's| |-|g' titles.txt
# https://stackoverflow.com/questions/9591744/how-to-add-to-the-end-of-lines-containing-a-pattern-with-sed-or-awk
sed -i '/-/ s/$/.html/' titles.txt
# https://unix.stackexchange.com/questions/171603/convert-file-contents-to-lower-case
tr '[:upper:]' '[:lower:]' < titles.txt > titles_lowercase.txt
mv titles_lowercase.txt titles.txt
```

By running `./titles_to_links.sh` titles.txt is transformed into:

```
updating-makefile-to-a-python-script-clean.html
terraform-variables.html
invalidating-cloudfront-cache.html
create-an-aws-iam-user.html
updating-makefile-to-a-python-script-build-run-dev-container.html
terraform-interpolation.html
terraform-conditionals.html
set-up-acm-ssl-certs-and-domain-validation-with-route53.html
uploading-my-new-site-to-s3.html
aws-cli-setup.html
terraform-count-and-loops.html
how-this-site-came-to-be.html
final-thoughts-on-setting-up-my-site.html
setting-up-cloudfront-distribution.html
introduction-to-terraform.html
updating-makefile-to-a-python-script-conclusion.html
updating-makefile-to-a-python-script-upload-to-s3-argparse.html
```

Just to confirm that everything is good there I am going to use my text editor and curl just to make sure each page gives me a 200 back. I used [This Page](https://stackoverflow.com/questions/10060098/getting-only-response-header-from-http-post-using-curl) to get just the header info from the pages. 

```
curl -sSL -D - localhost:8080/updating-makefile-to-a-python-script-clean.html -o /dev/null
curl -sSL -D - localhost:8080/terraform-variables.html -o /dev/null
curl -sSL -D - localhost:8080/invalidating-cloudfront-cache.html -o /dev/null
curl -sSL -D - localhost:8080/create-an-aws-iam-user.html -o /dev/null
curl -sSL -D - localhost:8080/updating-makefile-to-a-python-script-build-run-dev-container.html -o /dev/null
curl -sSL -D - localhost:8080/terraform-interpolation.html -o /dev/null
curl -sSL -D - localhost:8080/terraform-conditionals.html -o /dev/null
curl -sSL -D - localhost:8080/set-up-acm-ssl-certs-and-domain-validation-with-route53.html -o /dev/null
curl -sSL -D - localhost:8080/uploading-my-new-site-to-s3.html -o /dev/null
curl -sSL -D - localhost:8080/aws-cli-setup.html -o /dev/null
curl -sSL -D - localhost:8080/terraform-count-and-loops.html -o /dev/null
curl -sSL -D - localhost:8080/how-this-site-came-to-be.html -o /dev/null
curl -sSL -D - localhost:8080/final-thoughts-on-setting-up-my-site.html -o /dev/null
curl -sSL -D - localhost:8080/setting-up-cloudfront-distribution.html -o /dev/null
curl -sSL -D - localhost:8080/introduction-to-terraform.html -o /dev/null
curl -sSL -D - localhost:8080/updating-makefile-to-a-python-script-conclusion.html -o /dev/null
curl -sSL -D - localhost:8080/updating-makefile-to-a-python-script-upload-to-s3-argparse.html -o /dev/null
```

I am still running my pelican server locally so I just copy and pasted the entire block above into shell and scrolled back through my history and saw all 200s.

Of course I could have used for loops and scripted everything, but for testing it took me under a minute with a multiline editor to get all of the curl lines written out and then pasted into bash.

**<p id="addaliases">Add Aliases to Post</p>**

Now that I have my list of URLs I need to build the aliases for each page they should look like:

```
aliases:
  - linktopage.html
```

I am going to append the aliases after the first ---

I am again going to use my editor to construct all of the replacement values.

I only want to replace the first instance of --- so I needed to [figure out how to do that](https://stackoverflow.com/questions/148451/how-to-use-sed-to-replace-only-the-first-occurrence-in-a-file)

```
sed -i '0,/---/{s/---/---\naliases:\n  - updating-makefile-to-a-python-script-clean.html/}' posts/makefile_vs_python_pt1.md
sed -i '0,/---/{s/---/---\naliases:\n  - terraform-variables.html/}' posts/terraform_variables.md
sed -i '0,/---/{s/---/---\naliases:\n  - invalidating-cloudfront-cache.html/}' posts/site_setup_pt5.md
sed -i '0,/---/{s/---/---\naliases:\n  - create-an-aws-iam-user.html/}' posts/create_iam_user.md
sed -i '0,/---/{s/---/---\naliases:\n  - updating-makefile-to-a-python-script-build-run-dev-container.html/}' posts/makefile_vs_python_pt2.md
sed -i '0,/---/{s/---/---\naliases:\n  - terraform-interpolation.html/}' posts/terraform_interpolation.md
sed -i '0,/---/{s/---/---\naliases:\n  - terraform-conditionals.html/}' posts/terraform_conditionals.md
sed -i '0,/---/{s/---/---\naliases:\n  - set-up-acm-ssl-certs-and-domain-validation-with-route53.html/}' posts/site_setup_pt3.md
sed -i '0,/---/{s/---/---\naliases:\n  - uploading-my-new-site-to-s3.html/}' posts/site_setup_pt2.md
sed -i '0,/---/{s/---/---\naliases:\n  - aws-cli-setup.html/}' posts/awscli_setup.md
sed -i '0,/---/{s/---/---\naliases:\n  - terraform-count-and-loops.html/}' posts/terraform_loops.md
sed -i '0,/---/{s/---/---\naliases:\n  - how-this-site-came-to-be.html/}' posts/site_setup_pt1.md
sed -i '0,/---/{s/---/---\naliases:\n  - final-thoughts-on-setting-up-my-site.html/}' posts/site_setup_final.md
sed -i '0,/---/{s/---/---\naliases:\n  - setting-up-cloudfront-distribution.html/}' posts/site_setup_pt4.md
sed -i '0,/---/{s/---/---\naliases:\n  - introduction-to-terraform.html/}' posts/terraform_intro.md
sed -i '0,/---/{s/---/---\naliases:\n  - updating-makefile-to-a-python-script-conclusion.html/}' posts/makefile_vs_python_pt4.md
sed -i '0,/---/{s/---/---\naliases:\n  - updating-makefile-to-a-python-script-upload-to-s3-argparse.html/}' posts/makefile_vs_python_pt3.md

```

**<p id="updateexisting">Update Existing Links On My Posts</p>**

For this I am just going through my existing posts and where I had links like
'* [AWS cli](aws-cli-setup.html)'

I just manually updated it to:

'* [AWS cli](/aws-cli-setup.html)'

I have under 20 posts at this point so going going through each one in order is very quick in my text editor. As I said before I could spend time and script this all out, and if I had hundreds of posts I would have. 


**<p id="staticfiles">Update Static Files</p>**

I was going through my posts after making all of the above changes and realized that my static files were not working. This is not really a surprise as I'm using a different build system.

Previously my images were in the content folder in a folder called images:

```
├── content
│   ├── awscli_setup.md
│   ├── create_iam_user.md
│   ├── images
│   │   ├── iam_confirm.png
│   │   ├── iam_create_user1.png
│   │   ├── iam_create_user2.png
│   │   ├── iam_menu.png
│   │   ├── iam_policy.png
│   │   ├── iam_service.png
│   │   └── iam_the_good_stuff.png
```

For hugo I am going to copy the images folder into the static folder.

```
~/gnoinski.ca/ben/build_site/pelican/content$ cp -R images ../../hugo/ben.gnoinski.ca/static/
ls ../../hugo/ben.gnoinski.ca/static/
images
```

Now how to access them and make sure my posts(1) that has images is updated. [Refer to the docs](https://gohugo.io/content-management/static-files/)

That was as simple as finding {filename} and removing it in my post that had images.

* [Switching From Pelican To Hugo - Pt1](/posts/hugo_switch_pt1/)
* [Switching From Pelican To Hugo - Pt2](/posts/hugo_switch_pt2/)
* [Switching From Pelican To Hugo - Conclusion](/posts/hugo_switch_conclusion/)