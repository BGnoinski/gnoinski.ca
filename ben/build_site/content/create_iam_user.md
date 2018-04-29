Title: Create an AWS IAM user
Date: 2018-04-27 18:55
Category: AWS
Tags: AWS, IAM

# Create an AWS IAM user

For most of my articles I'll likely be working with AWS in some fashion. One of the first things needed is an IAM user in order to act upon our account wheter from the console or the cli. I already have one setup but I'll quickly show you how to setup your own.

### Requirements

* [AWS Account](https://portal.aws.amazon.com/billing/signup#/start) - You're on your own for setting up an account and logging into the console. I'm not doing an article on that.
* [IAM user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)

Give the docs linked above in the requirements a read if you haven't already and you'll be better off.

### Steps I'm going to cover

* Create an IAM user and get programmatic credentials 
 
### Let's roll

**Create an IAM user and get programmatic credentials**

Before we can do anything with the command line we need credentials which means we need a user. Log into your AWS account with your root user and find the iam service. The easiest way is to search for iam and click on the link once it finds it. 

<img class="img_border_small" src="{filename}/images/iam_service.png" />

Once you're in IAM click on users from the left menu, then click on the Add button:

<img class="img_border_small"  src="{filename}/images/iam_menu.png" />

I just wanted to show you what characters you can't use for your usernames.

<img class="img_border_small"  src="{filename}/images/iam_create_user1.png" />

Select a reasonable name, and then make sure you checkmark the Programmatic access. If this is your first user you should also check `AWS Management Console Access`

* <span style="color:blue">*Best practice* ~ Your root account should have 2FA (multi factor Authentication) enabled and then not used. Use a separate user for your day to day work. </span>

<img class="img_border_small"  src="{filename}/images/iam_create_user2.png" />

On the next screen we are going to select a policy to apply to our new user. If this is your first user, chances are you want the built in AdministratorAccess policy which gives you access to everything except billing. You can enable billing if you want [by following these docs](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/grantaccess.html#ControllingAccessWebsite-Activate). 

<img class="img_border_small"  src="{filename}/images/iam_policy.png" />

This is just the confirmation screen but figured I'd show it so that I'm not skipping any of the steps. 

<img class="img_border_small"  src="{filename}/images/iam_confirm.png" />

This is the info that we have been after all along the **Access key ID** and the **Secret access key** click on the show button and copy the key and paste it elsewherei, or click on the "Download .csv" button. Once you click on Close if you have not copied or downloaded your key, it's gone. There is no way to recover it. You would be required to generate a new key at that point. 
adf
<img class="img_border_small"  src="{filename}/images/iam_the_good_stuff.png" />
