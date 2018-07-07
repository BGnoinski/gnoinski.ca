Title: Final Thoughts On Setting Up My Site
Date: 2018-04-06 18:30
Category: AWS
Tags: Editorial

# Site Setup Part 6

* [Part 1 - How this site came to be](how-this-site-came-to-be.html)
* [Part 2 - Uploading My New Site To S3](uploading-my-new-site-to-s3.html)
* [Part 3 - Setting up SSL Certs and Route53 Cert validation](set-up-acm-ssl-certs-and-domain-validation-with-route53.html)
* [Part 4 - Setting up Cloudfront Distribution](setting-up-cloudfront-distribution.html)
* [Part 5 - Invalidating Cloudfront Cache](invalidating-cloudfront-cache.html)

I've wanted to do something for quite some time, I just wasn't sure what. [The Codependent Codr](https://www.codependentcodr.com) gave me the kick I needed to get this started.

I started this whole project April 1st 2018 putting in 1-2 hours a night. Obviously if I wasn't documenting everything I could have had everything up within a few hours. In my day to day work I use Terraform for so you truly got to see my process working with the aws cli and the AWS docs. I have read so many sites that everything is polished and works the first time . None of them really show just how much time these tasks can take, or the times things didn't work along the way.

If you're new, please keep in mind that I have been working with AWS and docker for quite some time so I already knew all of the work that was required to complete these tasks. 

There are so many sites with information and resources, but one of the best things that you can do is RTFM (Read the fucking manual) Just go to the docs and don't skim them, read them. I know it's boring as hell, I hate doing it, but you'll be better off for it. While I was setting up the Cloudfront distribution it really helped knowing what options were required/deprecated, as well as the description and type of each option. Sure there were times where the docs were confusing and messed me up, but All I used for setting up this site was the Amazon cli help flag, and the amazon docs themselves. If you're new you might need to google to find out which of AWS's numerous products you need to setup in the first place.

At the end of the day try it, google it, break it, ask questions if needed, fix it.

At the time of finishing Part 6 there is front end design work that I need to do to make it function better. But I stared, and that's what counts. As long as I keep it up.....