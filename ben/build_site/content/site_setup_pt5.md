Title: Invalidating Cloudfront Cache
Date: 2018-04-06 17:30
Category: AWS
Tags: AWS, Cloudfront

# Site Setup Part 5

In this post I will setup invalidating the Cloudfront cache everytime I upload my site. <span style="color:#054300"> "Ben what the hell is the "Cloudfront cache"?" </span> Good question. [In the previous post](setting-up-cloudfront-distribution.html) I explained that Cloudfront only gets a requested file from your origin if a) It doesn't already have it or b) the TTL has expired. So let's say your site rarely ever changes and you have a TTL of 86400 (1 day) That means that if you update your site, the main page may not change show your latest article for up to 1 day depending on when it last requested it.

### Requirements

* AWS account
* [AWS cli](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
* AWS Cloudfront Distribution

### Steps I'm going to cover

1. Create Cloudfront Invalidation
1. Invalidate after every upload


### Let's roll

** Create Cloudfront Invalidation **

So I'm pretty sure you all know where we're going by now `aws cloudfront help` then `aws cloudfront create-invalidation help`
Final command will be `aws cloudfront create-invalidation --distribution-id EW7T5A29H3R3J --paths /*` 

* <span style="color:#8C4B20">*WARNING* ~ I am invalidating the entire cache. If you had hundreds of thousands of files, invalidating the entire cache could put your origin server under high load and potentically cause downtime for your clients. </span>

* <span style="color:blue">*Best practice* ~ In production you should try to be as specific as possible with what you are invalidating. Instead of /images/* do /images/summer/thumbnails/* If you were working on the summer thumbnails for your site.

```
{
    "Location": "https://cloudfront.amazonaws.com/2017-03-25/distribution/EW7T5A29H3R3J/invalidation/I12MK3SKG4UYF2",
    "Invalidation": {
        "Id": "I12MK3SKG4UYF2",
        "Status": "InProgress",
        "CreateTime": "2018-04-07T02:19:09.777Z",
        "InvalidationBatch": {
            "Paths": {
                "Quantity": 27,
                "Items": [
                    "/srv",
                    "/media",
                    "/snap",
                    "/opt",
                    "/mnt",
                    "/sbin",
                    "/bin",
                    "/run",
                    "/sys",
                    "/boot",
                    "/swapfile",
                    "/lib64",
                    "/vmlinuz.old",
                    "/lib",
                    "/tmp",
                    "/initrd.img.old",
                    "/root",
                    "/lost+found",
                    "/cdrom",
                    "/initrd.img",
                    "/etc",
                    "/usr",
                    "/dev",
                    "/var",
                    "/proc",
                    "/vmlinuz",
                    "/home"
                ]
            },
            "CallerReference": "cli-1523067548-180131"
        }
    }
}
```

Dafuq!? Oh I see what it did, It took /* and expanded the paths in my root filesystem. If I do `ls -alh /` I get

```
drwxr-xr-x  24 root root 4.0K Apr  4 06:19 .
drwxr-xr-x  24 root root 4.0K Apr  4 06:19 ..
drwxr-xr-x   2 root root 4.0K Apr  1 15:39 bin
drwxr-xr-x   3 root root 4.0K Apr  4 06:19 boot
drwxrwxr-x   2 root root 4.0K Dec  4 19:57 cdrom
drwxr-xr-x  20 root root 4.4K Apr  6 17:35 dev
drwxr-xr-x 132 root root  12K Apr  5 06:05 etc
drwxr-xr-x   4 root root 4.0K Dec  4 19:58 home
lrwxrwxrwx   1 root root   33 Apr  4 06:19 initrd.img -> boot/initrd.img-4.13.0-38-generic
lrwxrwxrwx   1 root root   33 Apr  1 15:44 initrd.img.old -> boot/initrd.img-4.13.0-37-generic
drwxr-xr-x  23 root root 4.0K Dec  4 19:59 lib
drwxr-xr-x   2 root root 4.0K Jan 17 16:37 lib64
drwx------   2 root root  16K Dec  4 19:56 lost+found
drwxr-xr-x   3 root root 4.0K Dec  4 20:01 media
drwxr-xr-x   2 root root 4.0K Oct 18 11:32 mnt
drwxr-xr-x   3 root root 4.0K Dec  4 20:10 opt
dr-xr-xr-x 296 root root    0 Apr  1 08:32 proc
drwx------   4 root root 4.0K Apr  1 20:01 root
drwxr-xr-x  27 root root 1000 Apr  6 07:19 run
drwxr-xr-x   2 root root  12K Apr  1 15:53 sbin
drwxr-xr-x   5 root root 4.0K Jan 26 18:20 snap
drwxr-xr-x   2 root root 4.0K Oct 18 11:32 srv
-rw-------   1 root root 2.0G Dec  4 19:57 swapfile
dr-xr-xr-x  13 root root    0 Apr  6 19:20 sys
drwxrwxrwt  18 root root  36K Apr  6 19:17 tmp
drwxr-xr-x  10 root root 4.0K Oct 18 11:32 usr
drwxr-xr-x  14 root root 4.0K Oct 18 11:42 var
lrwxrwxrwx   1 root root   30 Apr  4 06:19 vmlinuz -> boot/vmlinuz-4.13.0-38-generic
lrwxrwxrwx   1 root root   30 Apr  1 15:44 vmlinuz.old -> boot/vmlinuz-4.13.0-37-generic
```

So the command litteraly told Cloudfront to invalidate all of the paths that exist on my root file system. And since they are all valid paths Cloudfront just went "Sure dude, whatever". I should know better let's try that with `'/*'`

`aws cloudfront create-invalidation --distribution-id EW7T5A29H3R3J --paths '/*'`

```
{
    "Location": "https://cloudfront.amazonaws.com/2017-03-25/distribution/EW7T5A29H3R3J/invalidation/I67BHKZ4HST3J",
    "Invalidation": {
        "Id": "I67BHKZ4HST3J",
        "Status": "InProgress",
        "CreateTime": "2018-04-07T02:26:06.109Z",
        "InvalidationBatch": {
            "Paths": {
                "Quantity": 1,
                "Items": [
                    "/*"
                ]
            },
            "CallerReference": "cli-1523067965-466156"
        }
    }
}
```

Now that's what I expected to see.

** Invalidate after every upload **

And last but not least we want this to happen every time we upload a site so we need to make a change to the Makefile.

```
current_dir = $(shell pwd)
current_container = $(shell docker ps -af name=gnoinski -q)

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
    aws cloudfront create-invalidation --distribution-id EW7T5A29H3R3J --paths '/*'

```

`make upload`

```
aws s3 sync --delete output/ s3://ben.gnoinski.ca
aws cloudfront create-invalidation --distribution-id EW7T5A29H3R3J --paths '/*'
{
    "Location": "https://cloudfront.amazonaws.com/2017-03-25/distribution/EW7T5A29H3R3J/invalidation/I3LX1ZB52U28UO",
    "Invalidation": {
        "Id": "I3LX1ZB52U28UO",
        "Status": "InProgress",
        "CreateTime": "2018-04-07T02:28:42.500Z",
        "InvalidationBatch": {
            "Paths": {
                "Quantity": 1,
                "Items": [
                    "/*"
                ]
            },
            "CallerReference": "cli-1523068121-390929"
        }
    }
}
```

That's pretty much it for this series of articles I have some final thoughts in the next post. There is what I think some good advice but certainly nothing technical in the next post. 

* [Part6 Final Thoughts On Setting Up My Site](final-thoughts-on-setting-up-my-site.html)