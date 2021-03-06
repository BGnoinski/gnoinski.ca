---
aliases:
  - set-up-acm-ssl-certs-and-domain-validation-with-route53.html
title: Set up ACM SSL Certs and Domain Validation with Route53
date: 2018-04-03T17:30:00Z
categories:
  - AWS
tags:
  - AWS
  - Route53
  - ACM
  - SSL
---

In this post I will go through the steps that I took get my site setup behind Cloudfront. <span style="color:#054300"> That was wishfull thinking will happen in part 4 now</span>

I am starting with a domain that has nothing else on it, no subdomains, mx records nothing. I will be updating the domains Nameservers to Route53.

* <span style="color:#8C4B20">*WARNING* ~ **If your domain has existing records be very careful following this post, if you change nameservers without setting up all of your other records first your site(s) may stop working!!!**</span> You have been warned, ops responsibly.

### Requirements

* Domain
* AWS account
* [AWS cli](/aws-cli-setup.html)
* Access to your registrar **See above warning**

### Steps I'm going to cover

1. Add my domain to route53
1. Update NS servers for my domain at my registrar
1. Get ACM SSL wildcard Cert for my domain
1. Update DNS on my domain to verify domain for SSL cert
1. Create Cloudfront Distribution <span style="color:#054300">Now happening in Part4</span>
1. Update my Cloudfront distribution with a custom CNAME <span style="color:#054300">Now happening in Part4</span>
1. Create the CNAME <span style="color:#054300">Now happening in Part4</span>
1. Hope everything works (it probably won't so if there are more steps I forgot some stuff) 

<span style="color:#054300"> Cloudfront is like number 5 on that list maybe I should separate part 3 of what was supped to be a simple post into parts 3 and 4. Well we'll see how it goes.</span>

### Let's roll

**Add my domain to route53**

Let's see what we get with `aws route53 help` I know they call domains "Hosted Zones" so let's checkout `aws route53 create-hosted-zone help` Looks like I'm going to end up with `aws route53 create-hosted-zone --name gnoinski.ca --caller-reference randomrequiredstring` That returned me the following. I am going to take special note of the NameServers in the DelegationSet, this is what we need to update at our registrar.

```
{
    "Location": "https://route53.amazonaws.com/2013-04-01/hostedzone/Z1UZQNFWWZLI94",
    "HostedZone": {
        "Id": "/hostedzone/Z1UZQNFWWZLI94",
        "Name": "gnoinski.ca.",
        "CallerReference": "randomrequiredstring",
        "Config": {
            "PrivateZone": false
        },
        "ResourceRecordSetCount": 2
    },
    "ChangeInfo": {
        "Id": "/change/C2JUG1GP5MTIYE",
        "Status": "PENDING",
        "SubmittedAt": "2018-04-04T02:38:24.619Z"
    },
    "DelegationSet": {
        "NameServers": [
            "ns-1937.awsdns-50.co.uk",
            "ns-274.awsdns-34.com",
            "ns-555.awsdns-05.net",
            "ns-1153.awsdns-16.org"
        ]
    }
}
```

**Update NS servers for my domain at my registrar**

I use namecheap so I went to [http://www.google.com](http://www.google.com) and searched for "namecheap update nameservers" [I found namecheaps page in the results](https://www.namecheap.com/support/knowledgebase/article.aspx/767/10/how-can-i-change-the-nameservers-for-my-domain) and didn't actually follow the instructions as I've updated NS records hundreds of times. I hope the page I just linked is correct as it is Namecheaps page, but if it's not updated or correct you can just follow the search procedure above to hopefully find some correct instructions.

* <span style="color:#054300">*Info* ~ Back in the old days it was always said that DNS changes can take 24-72 hours to propogate worldwide. In my experience DNS changes usually propogate with 20 minutes for big stuff like NS server updates, and under a minute for individual record changes if your NS server hasn't changed. However you also set a TTL on your records, defaults to 300s I think, so it's possible that local clients will not see the change instantly. [http://whatsmydns.net](http://whatsmydns.net) is my goto for checking DNS. I'm sure there are better ones out there, it's just muscle memory for me at this point. </span>

**Get ACM SSL wildcard Cert for my domain**

I eventually want my site to be https so I need a SSL certificate. Lukily AWS provides Free SSL certs. *Free as in puppies, you can only use AWS certs with AWS services, so you're paying one way or another.* I have heard good things about [let's encrypt certs](https://letsencrypt.org/) but never used them.

I gave a keyword in the title of this section, my first command is going to be `aws acm help` which then gives me `aws acm request-certificate help` And then finally I'll run `aws acm request-certificate --domain-name gnoinski.ca --subject-alternative-names "*.gnoinski.ca" "gnoinski.com" "*.gnoinski.com" --validation-method DNS`

came back with
```
You must specify a region. You can also configure your region by running "aws configure".
```
This goes back to [Part2](uploading-my-new-site-to-s3.html) where I said I usually either set an environment variable, or set it at run time.

* <span style="color:#8C4B20">*WARNING* ~ It was at this moment I remembered that Cloudfront is what I consider one of AWS's "Global" services and as such it's based in us-east-1. When you request the ACM certs for Cloudfront you need to request them in us-east-1.</span> <span style="color:#054300">I guess this is a good time to mention that certs are region dependant, but if you validate with DNS you can just request the certs in any of the regions without having to create new DNS records.</span>

Alright new command `AWS_DEFAULT_REGION=us-east-1 aws acm request-certificate --domain-name gnoinski.ca --subject-alternative-names "*.gnoinski.ca" "gnoinski.com" "*.gnoinski.com" --validation-method DNS`

* <span style="color:#054300">*Info* ~ "Slow your roll Ben, you just ran a bunch of options on that command what the f\*\*k dude? Where did this gnoinski.com stuff come from?" We need to understand some basic concepts when it comes to SSL certs. You can get certs for single domains like 'gnoinski.ca' or a wildcard cert '\*.gnoinski.ca' that is good for 'ben.gnoinski.ca' 'other.gnoinski.ca' 'WHATEVER.gnoinski.ca' it's a wildcard. *Take note that a wilcard cert '\*.gnoinski.ca' **DOES NOT** include the root domain 'gnoinski.ca'.* So instead of getting 2 certs we can add SANs(Subject Alternative Names) to our ssl certs to cover multiple domains. That is why --domain-name is gnoinski.ca and the rest are listed under --subject-alternative-names. I am setting this up to work for both gnoinski.ca and gnoinski.com</span>
* <span style="color:#054300">"You're not off the hook yet! What's this validation-method?" AWS wants to make sure that you own the domain that you are requesting certs for. That way no one can get a valid cert for google.com unless they can verify they own the domain or have enough authority over the domain to add DNS records. There are 2 ways to validate, they will either send you an e-mail [to pre-defined addresses](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-validate-email.html), or give you DNS records that need to be created in your hosted zone. If you go the DNS route it [has benefits](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-validate-dns.html). As long as the DNS record they give you exists they will renew your certs for example.</span>

The new command gave me:

```
{
    "CertificateArn": "arn:aws:acm:us-east-1:917788456904:certificate/76a538cf-5eef-43e0-aed9-9d0dd2403990"
}
```

Hrmmm well there's no DNS records for me to setup there. Back to `aws acm help` and then we'll do `aws acm describe-certificate` and get's us to `AWS_DEFAULT_REGION=us-east-1 aws acm describe-certificate --certificate-arn arn:aws:acm:us-east-1:917788456904:certificate/76a538cf-5eef-43e0-aed9-9d0dd240399` At this point I'm tired of setting the AWS_DEFAULT_REGION on every command. I'm working with cloudfront/us-east-1 right now so I'll just do `export AWS_DEFAULT_REGION=us-east-1` to set it for the remainder of this shell session.

The above command returned
```
{
    "Certificate": {
        "CertificateArn": "arn:aws:acm:us-east-1:917788456904:certificate/76a538cf-5eef-43e0-aed9-9d0dd2403990",
        "DomainName": "gnoinski.ca",
        "SubjectAlternativeNames": [
            "gnoinski.ca",
            "*.gnoinski.ca",
            "gnoinski.com",
            "*.gnoinski.com"
        ],
        "DomainValidationOptions": [
            {
                "DomainName": "gnoinski.ca",
                "ValidationStatus": "PENDING_VALIDATION",
                "ResourceRecord": {
                    "Name": "_5d5f31cde5783a68480ab2e202803fb7.gnoinski.ca.",
                    "Type": "CNAME",
                    "Value": "_dd767c2d804d508c3cb53e04c5365bee.acm-validations.aws."
                },
                "ValidationMethod": "DNS"
            },
            {
                "DomainName": "*.gnoinski.ca",
                "ValidationStatus": "PENDING_VALIDATION",
                "ResourceRecord": {
                    "Name": "_5d5f31cde5783a68480ab2e202803fb7.gnoinski.ca.",
                    "Type": "CNAME",
                    "Value": "_dd767c2d804d508c3cb53e04c5365bee.acm-validations.aws."
                },
                "ValidationMethod": "DNS"
            },
            {
                "DomainName": "gnoinski.com",
                "ValidationStatus": "PENDING_VALIDATION",
                "ResourceRecord": {
                    "Name": "_488b81035f413f0e3abf32db7ffbbea6.gnoinski.com.",
                    "Type": "CNAME",
                    "Value": "_6f7e220fc7496402a267d55ef8e382da.acm-validations.aws."
                },
                "ValidationMethod": "DNS"
            },
            {
                "DomainName": "*.gnoinski.com",
                "ValidationStatus": "PENDING_VALIDATION",
                "ResourceRecord": {
                    "Name": "_488b81035f413f0e3abf32db7ffbbea6.gnoinski.com.",
                    "Type": "CNAME",
                    "Value": "_6f7e220fc7496402a267d55ef8e382da.acm-validations.aws."
                },
                "ValidationMethod": "DNS"
            }
        ],
        "Subject": "CN=gnoinski.ca",
        "CreatedAt": 1522813108.0,
        "Status": "PENDING_VALIDATION",
        "KeyAlgorithm": "RSA-2048",
        "SignatureAlgorithm": "SHA256WITHRSA",
        "InUseBy": [],
        "Type": "AMAZON_ISSUED",
        "KeyUsages": [],
        "ExtendedKeyUsages": []
    }
}

```

**Update DNS on my domain to verify domain for SSL cert**

From the above we can see that we really only need to add 2 dns records, 1 for gnoinski.ca and 1 for gnoinski.com. Back to our trusty `aws route53 help` umm `aws route53 change-resource-record-sets help`? Yeah that looks right. "The request body must include a document with a ChangeResourceRecordSetsRequest element." Ok, what is that? "Use ChangeResourceRecordsSetsRequest to perform the following actions: CREATE DELETE UPSERT" These are new records so I could use CREATE, but I'll use UPSERT instead just on the off chance it was somehow added without me knowing. Alright Continuing on I see that we need to create a file with some JSON to do these updates, and we also need the "Hosted Zone ID". If you look above to the response I got after creating the hosted zone you'll see that my zone id for gnoinski.ca is "Z1UZQNFWWZLI94". The command I'm going to run is 
`aws route53 change-resource-record-sets --hosted-zone-id Z1UZQNFWWZLI94 --change-batch file://change-resource-record-sets.json` And of course we need some json to go into that file, and it's going to look like
```
{
    "Comment": "SSL validation records",
    "Changes": [
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "_5d5f31cde5783a68480ab2e202803fb7",
                "Type": "CNAME",
                "TTL": 300,
                "ResourceRecords": [
                {
                    "Value": "_dd767c2d804d508c3cb53e04c5365bee.acm-validations.aws."
                }
                ]
            }
        }
    ]
}
```

```
An error occurred (InvalidChangeBatch) when calling the ChangeResourceRecordSets operation: RRSet with DNS name _5d5f31cde5783a68480ab2e202803fb7. is not permitted in zone gnoinski.ca.
```

Well s***, I thought I had that one. Maybe it's looking for the full domain name, not just the subdomain for the Name.

```
{
    "Comment": "SSL validation records",
    "Changes": [
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "_5d5f31cde5783a68480ab2e202803fb7.gnoinski.ca",
                "Type": "CNAME",
                "TTL": 300,
                "ResourceRecords": [
                {
                    "Value": "_dd767c2d804d508c3cb53e04c5365bee.acm-validations.aws."
                }
                ]
            }
        }
    ]
}
```

Success!

```
{
    "ChangeInfo": {
        "Id": "/change/CPOWGORDFDLMR",
        "Status": "PENDING",
        "SubmittedAt": "2018-04-05T03:13:46.410Z",
        "Comment": "SSL validation records"
    }
}
```

What I did after this is updated the change-resource-record-sets.json file that I am using with the records for gnoinski.com as well as the hosted zone id. I used `aws route53 list-hosted-zones` to get my 2 zones and IDs.

And with that I think I am going to Cloudfront in the next post. 

* [Part1 How This Site Came To Be](/how-this-site-came-to-be.html)
* [Part2 Uploading My New Site to S3](/uploading-my-new-site-to-s3.html)
* [Part4 Setting up Cloudfront Distribution](/setting-up-cloudfront-distribution.html)
* [Part5 Invalidating Cloudfront Cache](/invalidating-cloudfront-cache.html)
* [Part6 Final Thoughts On Setting Up My Site](/final-thoughts-on-setting-up-my-site.html)
