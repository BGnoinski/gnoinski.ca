---
aliases:
  - setting-up-cloudfront-distribution.html
title: Setting up Cloudfront Distribution
date: 2018-04-05T17:30:00Z
categories:
  - AWS
tags:
  - AWS
  - Route53
  - ACM
  - SSL
---

In this post I will go through the steps that I took get my site setup behind Cloudfront.

* <span style="color:#054300">*Info* ~ Cloudfront sits infront of static assets such as html, images, or javascript. Cloudfront is a CDN (Content Delivery Network), it is **not** a webserver even though there may be some webserver like features that I'm not going to get into here. A CDN is a bunch of globally distributed servers that cache and distribute requested objects. So how does it work? First the CDN needs an origin, where it pulls files from. For my site it's going to be my s3-website url which [I setup in the previous post](uploading-my-new-site-to-s3.html) ( http://ben.gnoinski.ca.s3-website.ca-central-1.amazonaws.com/ ),  when you setup Cloudfront it gives you a distribution url like http://d4ajzg0vlxksf.cloudfront.net . Now if you were to go to a url like http://d4ajzg0vlxksf.cloudfront.net/setting-up-cloudfront-distribution.html the CDN first checks it's cache to see if it has the file, if it does it serves it to you. If it doesn't or it's TTL (time to live) has expired, the CDN goes to it's origin http://ben.gnoinski.ca.s3-website.ca-central-1.amazonaws.com/setting-up-cloudfront-distribution.html and asks for the file. If the file exists on the origin it serves it to the client first, then populates it to the rest of the CDN servers worldwide so that if the next person that accesses that page is across the globe it's instantly available for them providing it has had enough time to populate and the TTL hasn't expired. "But Ben how does my client on the other side of the world get the file as fast as my local client?" Good question. AWS controls the DNS for their domain, cloudfront.net. They setup that DNS so that clients get routed to the closest Edge Location, also known as a POP (points of presence). You can select different [Price classes](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html) for your edge locations if required. As you can see below if you run `nslookup d4ajzg0vlxksf.cloudfront.net` it returns multiple values. And if you visit [this link]https://www.whatsmydns.net/#A/d4ajzg0vlxksf.cloudfront.net You'll see that depending on where you are in the world you get returned a bunch of different values. </span>

``` bash
Server:		127.0.0.53
Address:	127.0.0.53#53

Non-authoritative answer:
Name:	d4ajzg0vlxksf.cloudfront.net
Address: 13.33.151.31
Name:	d4ajzg0vlxksf.cloudfront.net
Address: 13.33.151.41
Name:	d4ajzg0vlxksf.cloudfront.net
Address: 13.33.151.118
Name:	d4ajzg0vlxksf.cloudfront.net
Address: 13.33.151.70
Name:	d4ajzg0vlxksf.cloudfront.net
Address: 13.33.151.83
Name:	d4ajzg0vlxksf.cloudfront.net
Address: 13.33.151.82
Name:	d4ajzg0vlxksf.cloudfront.net
Address: 13.33.151.27
Name:	d4ajzg0vlxksf.cloudfront.net
Address: 13.33.151.144
``` 

### Requirements

* Domain Name
* Route53 Hosted Zone (You can use your own DNS provider if you want)
* AWS account
* [AWS cli](/aws-cli-setup.html)

### Steps I'm going to cover

1. Create Cloudfront Distribution
1. Ensure I have https setup with http > https *Done During the initial distribution setup*
1. Update my Cloudfront distribution to reply to an alternate domain name *Done During the initial distribution setup*
1. Create a CNAME in my domain that points at the cloudfront distribution
1. Hope everything works (it probably won't so if there are more steps I forgot some stuff)

### Let's roll

**Create Cloudfront Distribution**

Finally we are at the part where we can setup the Cloudfront distribution.

Hopefully by now you know where I'm going with this `aws cloudfront help` then `aws cloudfront create-distribution help` And we are back to a lot of json for this configuration. I am very likely going to screw this up something fierce. So with all of the tweaks to the json, this very well may be it for this post... Or I might just commit each variation to my repo so you can see just how many iterations I had to go through to get it right. 

I copied the json that they have in the help doc into my current code editor VSCode and started working my way from the bottom up because after the paste I was at the end. There is really no reason why I did this other than I did. 

While working through the json there are a bunch of settings I'm really not sure about so I'm looking up the docs.

The following will be a list of the help pages that I went to while creating my config. 

* I first [Ended up on this page](https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_ViewerCertificate.html) for the SSL cert settings.
* Then I realized that [This page](https://docs.aws.amazon.com/cloudfront/latest/APIReference/Welcome.html) Is pretty much the homepage for all of the cloudfront settings.
* [Logging was next](https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_LoggingConfig.html)<span style="color:#054300"> The page claims that all of the settings are required, but I know for a fact that I don't have logging enabled on other distributions. I'm going to try removing the logging block entirely....</span>
* [Cache behaviour](https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_CacheBehavior.html)
* <span style="color:#054300">It was at this point I realized my mystake working from the bottom up. I was modifying a cache behaviour not the **Default** cache behaviour. For this particular distribution I only need the default cache. Luckily I now know what options I need. So I removed the cache behaviour I just finished. I also don't have an origin setup yet so I'll need to return to that. 
* [Custom Origin Config](https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_CustomOriginConfig.html)
* [Aliases](https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_Aliases.html)

Ok my first attempt looks like this:

```
{
   "CallerReference": "InitialCreation",
   "Aliases": {
     "Quantity": 2,
     "Items": ["ben.gnoinski.ca", "ben.goinski.com"]
   },
   "DefaultRootObject": "index.html",
   "Origins": {
     "Quantity": 1,
     "Items": [
       {
         "Id": "BensBlog",
         "DomainName": "ben.gnoinski.ca.s3-website.ca-central-1.amazonaws.com",
         "CustomOriginConfig": {
           "HTTPPort": 80,
           "OriginProtocolPolicy": "http-only"
         }
       }
     ]
   },
   "DefaultCacheBehavior": {
     "TargetOriginId": "BensBlog",
     "ForwardedValues": {
       "QueryString": false,
       "Cookies": {
         "Forward": "none"
       }
     },
     "ViewerProtocolPolicy": "redirect-to-https",
     "MinTTL": 3600,
     "Compress": true
   },
   "PriceClass": "PriceClass_All",
   "Enabled": true,
   "ViewerCertificate": {
     "CloudFrontDefaultCertificate": true,
     "ACMCertificateArn": "arn:aws:acm:us-east-1:917788456904:certificate/76a538cf-5eef-43e0-aed9-9d0dd2403990",
     "SSLSupportMethod": "sni-only",
     "MinimumProtocolVersion": "TLSv1.2_2018"
   }
}
```

So my command to create this is going to be `aws cloudfront create-distribution --distribution-config file://cloudfront.json`

```
Parameter validation failed:
Missing required parameter in DistributionConfig: "Comment"
Missing required parameter in DistributionConfig.Origins.Items[0].CustomOriginConfig: "HTTPSPort"
Missing required parameter in DistributionConfig.DefaultCacheBehavior: "TrustedSigners"
```

Damn so close. 

```
{
   "CallerReference": "InitialCreation",
   "Aliases": {
     "Quantity": 2,
     "Items": ["ben.gnoinski.ca", "ben.goinski.com"]
   },
   "DefaultRootObject": "index.html",
   "Origins": {
     "Quantity": 1,
     "Items": [
       {
         "Id": "BensBlog",
         "DomainName": "ben.gnoinski.ca.s3-website.ca-central-1.amazonaws.com",
         "CustomOriginConfig": {
           "HTTPPort": 80,
           "HTTPSPort": 443,
           "OriginProtocolPolicy": "http-only"
         }
       }
     ]
   },
   "DefaultCacheBehavior": {
     "TargetOriginId": "BensBlog",
     "ForwardedValues": {
       "QueryString": false,
       "Cookies": {
         "Forward": "none"
       },
       "TrustedSigners": {
          "Enabled": false
       }
     },
     "ViewerProtocolPolicy": "redirect-to-https",
     "MinTTL": 3600,
     "Compress": true
   },
   "Comment": "BensBlog",
   "PriceClass": "PriceClass_All",
   "Enabled": true,
   "ViewerCertificate": {
     "CloudFrontDefaultCertificate": true,
     "ACMCertificateArn": "arn:aws:acm:us-east-1:917788456904:certificate/76a538cf-5eef-43e0-aed9-9d0dd2403990",
     "SSLSupportMethod": "sni-only",
     "MinimumProtocolVersion": "TLSv1.2_2018"
   }
}
```

```
Parameter validation failed:
Missing required parameter in DistributionConfig.DefaultCacheBehavior: "TrustedSigners"
Unknown parameter in DistributionConfig.DefaultCacheBehavior.ForwardedValues: "TrustedSigners", must be one of: QueryString, Cookies, Headers, QueryStringCacheKeys
```

I should have read the docs for TrustedSigners, but got lazy. I should also read the error message as I put trusted signers under ForwardedValues.

* [TrustedSigners Documentation](https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_TrustedSigners.html)

```
{
   "CallerReference": "InitialCreation",
   "Aliases": {
     "Quantity": 2,
     "Items": ["ben.gnoinski.ca", "ben.goinski.com"]
   },
   "DefaultRootObject": "index.html",
   "Origins": {
     "Quantity": 1,
     "Items": [
       {
         "Id": "BensBlog",
         "DomainName": "ben.gnoinski.ca.s3-website.ca-central-1.amazonaws.com",
         "CustomOriginConfig": {
           "HTTPPort": 80,
           "HTTPSPort": 443,
           "OriginProtocolPolicy": "http-only"
         }
       }
     ]
   },
   "DefaultCacheBehavior": {
     "TargetOriginId": "BensBlog",
     "ForwardedValues": {
       "QueryString": false,
       "Cookies": {
         "Forward": "none"
       },
     },
     "TrustedSigners": {
        "Enabled": false,
        "Quantity": 0
     },
     "ViewerProtocolPolicy": "redirect-to-https",
     "MinTTL": 3600,
     "Compress": true
   },
   "Comment": "BensBlog",
   "PriceClass": "PriceClass_All",
   "Enabled": true,
   "ViewerCertificate": {
     "CloudFrontDefaultCertificate": true,
     "ACMCertificateArn": "arn:aws:acm:us-east-1:917788456904:certificate/76a538cf-5eef-43e0-aed9-9d0dd2403990",
     "SSLSupportMethod": "sni-only",
     "MinimumProtocolVersion": "TLSv1.2_2018"
   }
}
```

```
Error parsing parameter '--distribution-config': Invalid JSON: Expecting property name enclosed in double quotes: line 29 column 6 (char 694)
```

Had an extra ','

```
{
   "CallerReference": "InitialCreation",
   "Aliases": {
     "Quantity": 2,
     "Items": ["ben.gnoinski.ca", "ben.goinski.com"]
   },
   "DefaultRootObject": "index.html",
   "Origins": {
     "Quantity": 1,
     "Items": [
       {
         "Id": "BensBlog",
         "DomainName": "ben.gnoinski.ca.s3-website.ca-central-1.amazonaws.com",
         "CustomOriginConfig": {
           "HTTPPort": 80,
           "HTTPSPort": 443,
           "OriginProtocolPolicy": "http-only"
         }
       }
     ]
   },
   "DefaultCacheBehavior": {
     "TargetOriginId": "BensBlog",
     "ForwardedValues": {
       "QueryString": false,
       "Cookies": {
         "Forward": "none"
       }
     },
     "TrustedSigners": {
        "Enabled": false,
        "Quantity": 0
     },
     "ViewerProtocolPolicy": "redirect-to-https",
     "MinTTL": 3600,
     "Compress": true
   },
   "Comment": "BensBlog",
   "PriceClass": "PriceClass_All",
   "Enabled": true,
   "ViewerCertificate": {
     "CloudFrontDefaultCertificate": true,
     "ACMCertificateArn": "arn:aws:acm:us-east-1:917788456904:certificate/76a538cf-5eef-43e0-aed9-9d0dd2403990",
     "SSLSupportMethod": "sni-only",
     "MinimumProtocolVersion": "TLSv1.2_2018"
   }
}
```

```
An error occurred (InvalidViewerCertificate) when calling the CreateDistribution operation: You cannot specify more than one of ACMCertificateArn, IAMCertificateId, or CloudFrontDefaultCertificate.
```

Damn it AWS [your docs](https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_ViewerCertificate.html) are confusing!

```
You must specify only one of the following values:

ViewerCertificate:ACMCertificateArn
ViewerCertificate:IAMCertificateId
ViewerCertificate:CloudFrontDefaultCertificate

Don't specify false for CloudFrontDefaultCertificate.
```

So first it says to only specify one in the list, but then after the list it says not to specify false for CloudFrontDefaultCertificate. Damn it AWS you wasted my time. 

```
{
   "CallerReference": "InitialCreation",
   "Aliases": {
     "Quantity": 2,
     "Items": ["ben.gnoinski.ca", "ben.goinski.com"]
   },
   "DefaultRootObject": "index.html",
   "Origins": {
     "Quantity": 1,
     "Items": [
       {
         "Id": "BensBlog",
         "DomainName": "ben.gnoinski.ca.s3-website.ca-central-1.amazonaws.com",
         "CustomOriginConfig": {
           "HTTPPort": 80,
           "HTTPSPort": 443,
           "OriginProtocolPolicy": "http-only"
         }
       }
     ]
   },
   "DefaultCacheBehavior": {
     "TargetOriginId": "BensBlog",
     "ForwardedValues": {
       "QueryString": false,
       "Cookies": {
         "Forward": "none"
       }
     },
     "TrustedSigners": {
        "Enabled": false,
        "Quantity": 0
     },
     "ViewerProtocolPolicy": "redirect-to-https",
     "MinTTL": 3600,
     "Compress": true
   },
   "Comment": "BensBlog",
   "PriceClass": "PriceClass_All",
   "Enabled": true,
   "ViewerCertificate": {
     "ACMCertificateArn": "arn:aws:acm:us-east-1:917788456904:certificate/76a538cf-5eef-43e0-aed9-9d0dd2403990",
     "SSLSupportMethod": "sni-only",
     "MinimumProtocolVersion": "TLSv1.2_2018"
   }
}
```

HOLY CRAP that one finally worked. Awesome.

```
{
    "Location": "https://cloudfront.amazonaws.com/2017-03-25/distribution/EW7T5A29H3R3J",
    "ETag": "E1V3JDYGVH2VO3",
    "Distribution": {
        "Id": "EW7T5A29H3R3J",
        "ARN": "arn:aws:cloudfront::917788456904:distribution/EW7T5A29H3R3J",
        "Status": "InProgress",
        "LastModifiedTime": "2018-04-06T03:57:35.121Z",
        "InProgressInvalidationBatches": 0,
        "DomainName": "d4ajzg0vlxksf.cloudfront.net",
        "ActiveTrustedSigners": {
            "Enabled": false,
            "Quantity": 0
        },
        "DistributionConfig": {
            "CallerReference": "InitialCreation",
            "Aliases": {
                "Quantity": 2,
                "Items": [
                    "ben.goinski.com",
                    "ben.gnoinski.ca"
                ]
            },
            "DefaultRootObject": "index.html",
            "Origins": {
                "Quantity": 1,
                "Items": [
                    {
                        "Id": "BensBlog",
                        "DomainName": "ben.gnoinski.ca.s3-website.ca-central-1.amazonaws.com",
                        "OriginPath": "",
                        "CustomHeaders": {
                            "Quantity": 0
                        },
                        "CustomOriginConfig": {
                            "HTTPPort": 80,
                            "HTTPSPort": 443,
                            "OriginProtocolPolicy": "http-only",
                            "OriginSslProtocols": {
                                "Quantity": 2,
                                "Items": [
                                    "SSLv3",
                                    "TLSv1"
                                ]
                            },
                            "OriginReadTimeout": 30,
                            "OriginKeepaliveTimeout": 5
                        }
                    }
                ]
            },
            "DefaultCacheBehavior": {
                "TargetOriginId": "BensBlog",
                "ForwardedValues": {
                    "QueryString": false,
                    "Cookies": {
                        "Forward": "none"
                    },
                    "Headers": {
                        "Quantity": 0
                    },
                    "QueryStringCacheKeys": {
                        "Quantity": 0
                    }
                },
                "TrustedSigners": {
                    "Enabled": false,
                    "Quantity": 0
                },
                "ViewerProtocolPolicy": "redirect-to-https",
                "MinTTL": 3600,
                "AllowedMethods": {
                    "Quantity": 2,
                    "Items": [
                        "HEAD",
                        "GET"
                    ],
                    "CachedMethods": {
                        "Quantity": 2,
                        "Items": [
                            "HEAD",
                            "GET"
                        ]
                    }
                },
                "SmoothStreaming": false,
                "DefaultTTL": 86400,
                "MaxTTL": 31536000,
                "Compress": true,
                "LambdaFunctionAssociations": {
                    "Quantity": 0
                }
            },
            "CacheBehaviors": {
                "Quantity": 0
            },
            "CustomErrorResponses": {
                "Quantity": 0
            },
            "Comment": "BensBlog",
            "Logging": {
                "Enabled": false,
                "IncludeCookies": false,
                "Bucket": "",
                "Prefix": ""
            },
            "PriceClass": "PriceClass_All",
            "Enabled": true,
            "ViewerCertificate": {
                "ACMCertificateArn": "arn:aws:acm:us-east-1:917788456904:certificate/76a538cf-5eef-43e0-aed9-9d0dd2403990",
                "SSLSupportMethod": "sni-only",
                "MinimumProtocolVersion": "TLSv1.2_2018",
                "Certificate": "arn:aws:acm:us-east-1:917788456904:certificate/76a538cf-5eef-43e0-aed9-9d0dd2403990",
                "CertificateSource": "acm"
            },
            "Restrictions": {
                "GeoRestriction": {
                    "RestrictionType": "none",
                    "Quantity": 0
                }
            },
            "WebACLId": "",
            "HttpVersion": "http2",
            "IsIPV6Enabled": true
        }
    }
}
```

**Create a CNAME in my domain that points at the cloudfront distribution**

I was considering putting this in a new post, but since I've already shown you [how to create a DNS CNAME entry](setting-up-ssl-certs-and-route53-cert-valication.html) this should be pretty simple.
`aws route53 change-resource-record-sets --hosted-zone-id Z1UZQNFWWZLI94 --change-batch file://cloudfront-record-sets.json`
```
{
    "Comment": "BensBlog Cloudfront record",
    "Changes": [
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "ben.gnoinski.ca",
                "Type": "CNAME",
                "TTL": 300,
                "ResourceRecords": [
                {
                    "Value": "d4ajzg0vlxksf.cloudfront.net"
                }
                ]
            }
        }
    ]
}
```

```
{
    "ChangeInfo": {
        "Id": "/change/C4V5899B4GJH2",
        "Status": "PENDING",
        "SubmittedAt": "2018-04-07T01:18:22.397Z",
        "Comment": "BensBlog Cloudfront record"
    }
}

```

And that's it for this post, my site is now available at ben.gnoinski.ca and you'll notice it automatically re-directs you to https://ben.gnoinski.ca . Check out [My Summary Post]() for my final thoughts on setting up my blog. 

* [Part1 How This Site Came To Be](/how-this-site-came-to-be.html)
* [Part2 Uploading My New Site to S3](/uploading-my-new-site-to-s3.html)
* [Part3 Setting up SSL Certs and Route53 cert valication](/set-up-acm-ssl-certs-and-domain-validation-with-route53.html)
* [Part5 Invalidating Cloudfront Cache](/invalidating-cloudfront-cache.html)
* [Part6 Final Thoughts On Setting Up My Site](/final-thoughts-on-setting-up-my-site.html)
