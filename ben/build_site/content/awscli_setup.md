Title: AWS cli setup
Date: 2018-04-29 14:25
Category: Utility
Tags: AWS, cli

# AWS cli setup

In some of my previous articles I used the AWS Command Line Interface(cli) without ever explaining how to set it up. 

Some may say that using the cli is hard, but the syntax and usage of the cli is very strait forward. What *is* hard is knowing which service to use and how the service is supposed to be configured. A perfect example is when [I setup a Cloudfront Distribution](setting-up-cloudfront-distribution.html), the cli command was extremely simple, the json required for setting up the districution was not.


### Requirements

* [An IAM role](create-an-aws-iam-user.html)
* [python3 pip](https://packaging.python.org/tutorials/installing-packages/#ensure-you-can-run-pip-from-the-command-line)
* [read cli documentation](https://aws.amazon.com/cli/)
* <span style="color:#8C4B20">*WARNING* I use Ubuntu Linux, most of my commands should work on linux/mac. If you're running windows, I'm very sorry to hear that, but I can't help you. 

Give the docs linked above in the requirements a read if you haven't already and you'll be better off.

### Steps I'm going to cover

1. <a href="#awscli">Install awscli (Ubuntu 17.10)</a>
1. <a href="#configure">Use built in method for configuring credentials and config</a>
1. <a href="#profiles">Understanding cli profiles</a>
1. <a href="#variables">Alternate methods of specifying credentials and settings</a>

### Let's roll

** <p id="awscli">Install awscli</p> **

This one is pretty simple `pip3 install --upgrade awscli`

```
pip3 install --upgrade awscli
Collecting awscli
  Downloading https://files.pythonhosted.org/packages/26/a5/981fcedb0cba5cd167382878c92956229d14f0ac6846c71f2cd87906d474/awscli-1.15.10-py2.py3-none-any.whl (1.3MB)
    100% |████████████████████████████████| 1.3MB 1.1MB/s 
Collecting botocore==1.10.10 (from awscli)
  Downloading https://files.pythonhosted.org/packages/77/c9/a40ebce24bbab4c7986fccdac9dade097385ad2feae73dcc47d31a1b4dc8/botocore-1.10.10-py2.py3-none-any.whl (4.2MB)
    100% |████████████████████████████████| 4.2MB 411kB/s 
Collecting s3transfer<0.2.0,>=0.1.12 (from awscli)
  Downloading https://files.pythonhosted.org/packages/d7/14/2a0004d487464d120c9fb85313a75cd3d71a7506955be458eebfe19a6b1d/s3transfer-0.1.13-py2.py3-none-any.whl (59kB)
    100% |████████████████████████████████| 61kB 4.1MB/s 
Collecting docutils>=0.10 (from awscli)
  Downloading https://files.pythonhosted.org/packages/36/fa/08e9e6e0e3cbd1d362c3bbee8d01d0aedb2155c4ac112b19ef3cae8eed8d/docutils-0.14-py3-none-any.whl (543kB)
    100% |████████████████████████████████| 552kB 1.6MB/s 
Collecting PyYAML<=3.12,>=3.10 (from awscli)
  Downloading https://files.pythonhosted.org/packages/4a/85/db5a2df477072b2902b0eb892feb37d88ac635d36245a72a6a69b23b383a/PyYAML-3.12.tar.gz (253kB)
    100% |████████████████████████████████| 256kB 2.6MB/s 
Collecting rsa<=3.5.0,>=3.1.2 (from awscli)
  Downloading https://files.pythonhosted.org/packages/e1/ae/baedc9cb175552e95f3395c43055a6a5e125ae4d48a1d7a924baca83e92e/rsa-3.4.2-py2.py3-none-any.whl (46kB)
    100% |████████████████████████████████| 51kB 4.0MB/s 
Collecting colorama<=0.3.7,>=0.2.5 (from awscli)
  Downloading https://files.pythonhosted.org/packages/b7/8e/ddb32ddaabd431813e180ca224e844bab8ad42fbb47ee07553f0ec44cd86/colorama-0.3.7-py2.py3-none-any.whl
Collecting jmespath<1.0.0,>=0.7.1 (from botocore==1.10.10->awscli)
  Downloading https://files.pythonhosted.org/packages/b7/31/05c8d001f7f87f0f07289a5fc0fc3832e9a57f2dbd4d3b0fee70e0d51365/jmespath-0.9.3-py2.py3-none-any.whl
Collecting python-dateutil<3.0.0,>=2.1; python_version >= "2.7" (from botocore==1.10.10->awscli)
  Downloading https://files.pythonhosted.org/packages/0c/57/19f3a65bcf6d5be570ee8c35a5398496e10a0ddcbc95393b2d17f86aaaf8/python_dateutil-2.7.2-py2.py3-none-any.whl (212kB)
    100% |████████████████████████████████| 215kB 3.1MB/s 
Collecting pyasn1>=0.1.3 (from rsa<=3.5.0,>=3.1.2->awscli)
  Downloading https://files.pythonhosted.org/packages/ba/fe/02e3e2ee243966b143657fb8bd6bc97595841163b6d8c26820944acaec4d/pyasn1-0.4.2-py2.py3-none-any.whl (71kB)
    100% |████████████████████████████████| 71kB 4.0MB/s 
Collecting six>=1.5 (from python-dateutil<3.0.0,>=2.1; python_version >= "2.7"->botocore==1.10.10->awscli)
  Downloading https://files.pythonhosted.org/packages/67/4b/141a581104b1f6397bfa78ac9d43d8ad29a7ca43ea90a2d863fe3056e86a/six-1.11.0-py2.py3-none-any.whl
Building wheels for collected packages: PyYAML
  Running setup.py bdist_wheel for PyYAML ... done
  Stored in directory: /home/ben/.cache/pip/wheels/03/05/65/bdc14f2c6e09e82ae3e0f13d021e1b6b2481437ea2f207df3f
Successfully built PyYAML
Installing collected packages: jmespath, six, python-dateutil, docutils, botocore, s3transfer, PyYAML, pyasn1, rsa, colorama, awscli
Successfully installed PyYAML-3.12 awscli-1.15.10 botocore-1.10.10 colorama-0.3.7 docutils-0.14 jmespath-0.9.3 pyasn1-0.4.2 python-dateutil-2.7.2 rsa-3.4.2 s3transfer-0.1.13 six-1.11.0
```

While --upgrade is not required if it's already installed it will simply upgrade your version to the latest like it did for me.

* <span style="color:#054300"> *Info* - The package that we install is "awscli" however the binary that gets installed and the command we run is `aws`

* <span style="color:#8C4B20">*WARNING* - In the past I have had issues where the aws binary is not executable after install. To fix this I ran `which aws` and then ran `chmod +x PATHFROMPREVIOUSCOMMAND` where PATHFROMPREVIOUSCOMMAND is what was returned from `which aws`

** <p id="configure">Use built in method for configuring credentials and config</p> **

At this point if we tried running a command it's not going to work as we have no credentials setup. 

```
aws acm list-certificates 
Unable to locate credentials. You can configure credentials by running "aws configure".
```

Easiest thing to do is follow the directions

`aws configure`

```
AWS Access Key ID [None]: AKIAJKFADCKE2ZB23BHA
AWS Secret Access Key [None]: kr+0w0tgn10gs4ws1ht+kn1hty114u+tcau0yd1d
Default region name [None]: 
Default output format [None]: 
```

No errors so that appears to have worked. What the command did is create a new folder located at ~/.aws/ and created 2 files called 'credentials' and 'config' within. If we take a look at credentials it looks like

`cat ~/.aws/credentials`

```
[default]
aws_access_key_id = AKIAJKFADCKE2ZB23BHA
aws_secret_access_key = kr+0w0tgn10gs4ws1ht+kn1hty114u+tcau0yd1d
```

And config looks like

`cat ~/.aws/config`

```
[default]
```

* <span style="color:#054300"> "Ben config has nothing in it, what's it used for?"</span> When I ran `aws configure` I did not input a region or ouput format, that is where that information would have been populated had I entered it. And you should already know about this because you read the docs. 


`aws configure`

```
AWS Access Key ID [****************3BHA]: 
AWS Secret Access Key [****************yd1d]: 
Default region name [None]: ca-central-1
Default output format [None]: json

```

`cat ~/.aws/config`

```
[default]
region = ca-central-1
output = json
```

Now if we have actual credentials we can run something like
`aws s3 ls`

```
2018-04-02 19:51:25 ben.gnoinski.ca
```

You now have a fully armed and operational battle station. Err cli fully functional cli.


** <p id="profiles">Understanding cli profiles</p> **

Now what happens if you have credentials for 2 different aws accounts or want to work on different regions within the same account? It's going to suck constantly running 'aws configure' or modifying the credentials/config files. That's where profiles come in. 

In the above examples `aws configure` created a '[default]' profile for us. If we call `aws` without the --profile flag it uses credentials and config stored under '[default]'.

To setup a new profile we append to the credentials and config files with the new profile name in [].
I am going to setup a profile for working with us-east-1.

`cat ~/.aws/credentials`

```
[default]
AWS_ACCESS_KEY_ID=AKIAJKFADCKE2ZB23BHA
AWS_SECRET_ACCESS_KEY=kr+0w0tgn10gs4ws1ht+kn1hty114u+tcau0yd1d

[us-east-1]
AWS_ACCESS_KEY_ID=AKIAJKFADCKE2ZB23BHA
AWS_SECRET_ACCESS_KEY=kr+0w0tgn10gs4ws1ht+kn1hty114u+tcau0yd1d
```

`cat ~/.aws/config`

```
[default]
region = ca-central-1
output = json

[us-east-1]
region = us-east-1
output = json
```

I chose us-east-1 becasue I know I have some acm ssl certficates for cloudfront there, and I have nothing setup in ca-central-1 yet. 

`aws acm list-certificates`

```
{
    "CertificateSummaryList": []
}
```

`aws acm list-certificates --profile us-east-1`

```
You must specify a region. You can also configure your region by running "aws configure".
```

But I did specify a region AWS cli, I did.

*To the docmobile* [cli config file docs](https://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html)

Yep everything looks right, well they mention you can run aws configure so let's see if that works.

`aws configure --profile us-east-1`
 
```
AWS Access Key ID [****************3BHA]: 
AWS Secret Access Key [****************yd1d]: 
Default region name [None]: us-east-1
Default output format [None]: 
```

`cat ~/.aws/config`

```
[default]
region = ca-central-1
output = json

[us-east-1]
region = us-east-1
[profile us-east-1]
region = us-east-1
```

Alright well apparently for the config file you need to put 'profile' in front of the profile name. Why? Because consistency within projects is clearly overrated, they need to keep us guessing. 

`aws acm list-certificates --profile us-east-1`

```
{
    "CertificateSummaryList": [
        {
            "CertificateArn": "arn:aws:acm:us-east-1:917788456904:certificate/76a538cf-5eef-43e0-aed9-9d0dd2403990",
            "DomainName": "gnoinski.ca"
        }
    ]
}
```

That's what I was expecting to see, alright good to go.

** <p id="variables">Alternate methods of specifying credentials and settings</p> **

If we don't want to use the credentials and config files we can also specify those values as environment variables. I use environment variables to specify my region  95% of the time. I work primarily in ca-central-1 but on occasion I need to do some work in us-east-1. 

* <span style="color:#054300"> *Info* - Environment variables will take precedence over the credentials and config files.</span>

1) You can set the environment variable for a single command by prefixing your command with 'VARIABLE=value'
 
`AWS_DEFAULT_REGION=ca-central-1 aws acm list-certificates`

```
{
    "CertificateSummaryList": []
}
```

<span style="color:#054300"> "Slow your roll, we know you had the region on your default profile set to ca-central-1, you didn't prove anything!" </span>You're not wrong but let's run the same command with our us-east-1 profile.

`AWS_DEFAULT_REGION=ca-central-1 aws acm list-certificates --profile us-east-1`

```
{
    "CertificateSummaryList": []
}

```
The above command showed 2 points: it picked up the region from the environment variable, the environment variable took precedence over the config file.

2) you can set the environment variable for the duration of your shell using `export AWS_DEFAULT_REGION=ca-central-1`

I am going to remove all settings from the config file except for [default], and remove my us-east-1 profile for the following examples.

`aws acm list-certificates`

```
You must specify a region. You can also configure your region by running "aws configure".
```

`aws acm list-certificates --profile us-east-1`

```
The config profile (us-east-1) could not be found
``` 

`export AWS_DEFAULT_REGION=ca-central-1`

When you run this command all you'll get is a new line in your shell but now

`aws acm list-certificates`

```
{
    "CertificateSummaryList": []
}
```

Any future command in this shell will also have the default region set.

You can combine both methods to make your life easier. For example I generally have ca-central-1 exported, but sometimes I need to work in us-east-1 so I prefix those commands and specify the region.

`AWS_DEFAULT_REGION=us-east-1 aws acm list-certificates`

```
{
    "CertificateSummaryList": [
        {
            "CertificateArn": "arn:aws:acm:us-east-1:917788456904:certificate/76a538cf-5eef-43e0-aed9-9d0dd2403990",
            "DomainName": "gnoinski.ca"
        }
    ]
}
```

### Conclusion

Hopefully this article has given you a good grasp on how to use the cli and make your life working with multiple accounts/regions a little easier. 

Even with how convinient the above is I have written myself a bunch of little helper functions that will move files around, or export variables depending on what I'm working on. But that may be a future article.
