Title: Setting up Cloudfront Distribution
Date: 2018-04-03 17:30
Category: AWS
Tags: AWS, Route53, ACM, SSL

# Part 4

In this post I will go through the steps that I took get my site setup behind Cloudfront. <span style="color:#054300"> That was wishfull thinking will happen in part 4 now</span>

I am starting with a domain that has nothing else on it, no subdomains, mx records nothing. I will be updating the domains Nameservers to Route53.

* <span style="color:#8C4B20">*WARNING* ~ ** If your domain has existing records be very careful following this post, if you change nameservers without setting up all of your other records first your site(s) may stop working!!!** </span> You have been warned, ops responsibly.

* <span style="color:#054300">*Info* ~ Cloudfront sits infront of static assets such as html, images, or javascript. Cloudfront is a CDN (Content Delivery Network), it is **not** a webserver even though there may be some webserver like features that I'm not going to get into here. A CDN is a bunch of globally distributed servers that cache and distribute requested objects. So how does it work? First the CDN needs an origin, where it pulls files from. For my site it's going to be my s3-website url which [I setup in the previous post](uploading-my-new-site-to-s3.html) ( http://ben.gnoinski.ca.s3-website.ca-central-1.amazonaws.com/ ),  when you setup Cloudfront it gives you a distribution url like http://asdfasdfasdf.cloudfront.net . Now if you were to go to a url like http://asdfasdfasdf.cloudfront.net/set-up-cloudfront.html the CDN first checks it's cache to see if it has the file, if it does it serves it to you. If it doesn't or it's TTL (time to live) has expired, the CDN goes to it's origin http://ben.gnoinski.ca.s3-website.ca-central-1.amazonaws.com/set-up-cloudfront.html and asks for the file. If the file exists on the origin it serves it to the client first, then populates it to the rest of the CDN servers worldwide so that if the next person that accesses that page is across the globe it's instantly available for them providing it has had enough time to populate and the TTL hasn't expired. "But Ben how does my client on the other side of the world get the file as fast as my local client?" Good question. AWS controls the DNS for their domain, cloudfront.net. They setup that DNS so that clients get routed to the closest Edge Location, also known as a POP (points of presence). You can select different [Price classes](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html) for your edge locations if required. As you can see below if you run `nslookup FIXME DOMAINHERE` it returns multiple values. </span>
```
FILL ME IN NSLOOKUP OF A CDN DISTRIBUTION
``` 

### Requirements

* Domain
* AWS account
* [AWS cli](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
* Access to your registrar ** See above warning **

### steps I'm going to cover

1. Add my domain to route53
1. Update NS servers for my domain at my registrar
1. Get ACM SSL wildcard Cert for my domain
1. Update DNS on my domain to verify domain for SSL cert
1. Create Cloudfront Distribution
1. Update my Cloudfront distribution with a custom CNAME
1. Create the CNAME
1. Hope everything works (it probably won't so if there are more steps I forgot some stuff)

<span style="color:#054300"> Cloudfront is like number 5 on that list maybe I should separate parts 3 of what was supped to be a simple post into part 3 and 4. Well we'll see how it goes.</span>

### Let's roll