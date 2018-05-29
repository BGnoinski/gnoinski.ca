Title: Uploading My New Site To S3
Date: 2018-04-02 17:08
Category: AWS
Tags: AWS, S3, IAM

# Site Setup Part 2

In this post I will go through the steps that I took to make my site live in a s3 website URL.

### Requirements

* AWS account
* [AWS cli](aws-cli-setup.html)

### Steps I'm going to cover

1. Create IAM user for myself
1. Setup AWS cli
1. Create S3 bucket for site 
1. Enable bucket versioning
1. Enable website hosting
1. Update Makefile to include upload to s3

### Let's roll

** Create IAM user for myself **

My AWS account hasn't been used for much so I need to [create an IAM user for myself](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html). I am going to assign myself the AdministratorAccess policy as well as programmatic access.

* <span style="color:blue">*Best practice* ~ Your root account should have 2FA (multi factor Authentication) enabled and then not used. Use a separate user for your day to day work. </span>
* <span style="color:red">*CRITICAL* ~ ** Make sure you do not commit your AWS secret access key and password to github. *ever!* </span>**

** Setup AWS cli **

Once your IAM user is created the easiest way to setup your credentials is to run `aws configure` on the command line. It asks you for the access key,secret, default region, and default output. Fill it out as required, I set my default region to ca-central-1.

Once this is done you will notice that you have a new folder ~/.aws/ and within 2 files `credentials` and `config` credentials looks like

```
[default]
AWS_ACCESS_KEY_ID=AKIAJKFADCKE2ZB23BHA
AWS_SECRET_ACCESS_KEY=kr+0w0tgn10gs4ws1ht+kn1hty114u+tcau0yd1d
```

and config will look like
```
[default]
region = ca-central-1
```

I never actually use the config file, I always set the region as an environment variable like `export AWS_DEFAULT_REGION=ca-central-1` or append it before a command `AWS_DEFAULT_REGION=ca-central-1 $(aws ecr get-login --no-include-email)`

** Create S3 bucket for site **

Now that we have the cli setup we can create a bucket for our new site. I am going to name mine the same as the subdomain which will be `ben.gnoinski.ca` If at anytime you get stuck with the aws command line you can use help ex: `aws help` to get all cli commands, you can continue appending `help` to the end of any of the commands to get more specific command help `aws help` -> `aws s3 help` -> `aws s3 cp help`

It looks like `aws s3 mb` is what we are looking for and I'm guessing mb means 'make bucket'??, even though the description says 'Creates an S3 bucket'. 

<span style="color:#054300">*Sometimes aws commands make a grand total of 0 sense, you just need to accept that sometimes things are named extremely poorly. Best guess they didn't want people getting cb and cp mixed up and having a whole bunch of random bucket names created. If that's the reason I guess it makes sense.* - Authors unsolicited commentary</span>

In any case it looks like all I need to run is `aws s3 mb s3://ben.gnoinski.ca --region ca-central-1`
The output was only:
```
make_bucket: ben.gnoinski.ca
```

but if I run a `aws s3 ls` I can see the bucket now exists on my account. 

** Enable bucket versioning **

I now want to enable bucket versioning so that if I accidentally overwrite a file, all is not lost. <span style="color:#054300">*Everything is in source control so I'm not overly concerned about losing anything, but versioning never hurts.*</span> So we run `aws s3 help` and see absolutely nothing about versioning. <span style="color:#054300">*We are going back to AWS sometimes making 0 sense.*</span> I know from experience we actually want `aws s3api help` And it looks like I am going to run `aws s3api put-bucket-versioning --bucket ben.gnoinski.ca --versioning-configuration Status=Enabled` And we get no output. No news is good news? If you want to confirm you can log into the S3 console, go into the bucket properties and make sure that versioning is now enabled.

** Enable website hosting **

Alright now we need to enable website hosting on that bucket `aws s3 help` shows there is a `website` command, it's hidden down at the bottom but it exists.
`aws s3 website help` is the next command to run, make sure you make note of where your website endpoint is going to be *hint: It's region dependant* and from that I am going to run `aws s3 website s3://ben.gnoinski.ca/ --index-document index.html` And again no news is good news. If you read the docs, then you know my endpoint is going to be `http://ben.gnoinski.ca.s3-website-ca-central-1.amazonaws.com` But for me that didn't work, at all.... All I get is
```
ben.gnoinski.ca.s3-website-ca-central-1.amazonaws.com’s server IP address could not be found.
``` 

Interesting.

So I went into the AWS S3 console, then the buckets website hosting properties and get a differnt link `http://ben.gnoinski.ca.s3-website.ca-central-1.amazonaws.com/` It looks like a '.' between website and the region not a '-' like the docs show. 

* <span style="color:#8C4B20">*WARNING* ~ As of the date this article was published the url in the `aws s3 website help` docs is wrong at least for ca-central-1 </span>

When we enable website hosting we need to make sure that all of the objects are publically readable by attaching a bucket policy. [AWS Docs for this](https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteAccessPermissionsReqd.html)

I am going to create a file called policy.json with the following contents
``` json
{
  "Version":"2012-10-17",
  "Statement":[{
	"Sid":"PublicReadGetObject",
        "Effect":"Allow",
	  "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::ben.gnoinski.ca/*"
      ]
    }
  ]
}
```
then run the command `aws s3api put-bucket-policy --bucket ben.gnoinski.ca --policy file://policy.json`

** Update Makefile to include upload to s3 **

In my local environment I have my `make dev` which builds my pelican container and starts up the dev server, what this also does is generate all of the output required for the site. As I am working on an article it also detects changes and re-publishes content on when I save. I can make all of the changes locally make sure nothing broke in dev and then upload the site that I was working with locally.

This was a pretty easy change and my Makefile now looks like:

``` Make
current_dir = $(shell pwd)
current_container = $(shell docker ps -f name=gnoinski -q)

clean:
	rm -rf output/*
ifneq ($(current_container),)
	docker kill $(current_container)
	docker rm $(current_container)
endif

build:
	docker build -t gnoinski.ca:latest .

dev: clean build
	docker run -td -p 8080:8080 -v $(current_dir):/site --name bengnoinskidev -u $(USER) gnoinski.ca:latest /bin/bash -c '/site/develop_server.sh start 8080 && sleep 1d'

upload:
	aws s3 sync --delete output/ s3://ben.gnoinski.ca
```

So `make upload` publishes my content.

<span style="color:#054300">I was going to continue this article on to include setting up Cloudfront, but this seems like a logical ending to this post. I may amend this post to include it if setting up Cloudfront isn't to long. Or I may make Setting up Cloudfront and Route53 one article.</span>

* [Part3 Setting up SSL Certs and Route53 cert valication](set-up-acm-ssl-certs-and-domain-validation-with-route53.html)
