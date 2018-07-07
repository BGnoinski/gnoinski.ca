---
aliases:
  - updating-makefile-to-a-python-script-upload-to-s3-argparse.html
title: Updating Makefile to a Python script - upload to s3, argparse
date: 2018-04-11T16:30:00Z
categories:
  - Utility
tags:
  - Python
  - Make
---

I'm just jumping right into this one. 

Completed Makefile

``` bash
cat Makefile 
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

---

wc Makefile 
 19  68 586 Makefile
```

### Requirements

* python3 (Most of this stuff will work in 2.7, I think)
* [python subprocess](https://docs.python.org/2/library/subprocess.html)
    * **added after my initial best laid plans**
* **[shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) <span style="color:red">NEW REQUIREMENTS HERE</span>**
* [chmod](https://linux.die.net/man/1/chmod)

Give the above docs linked in the requirements a read if you haven't already and you'll be better off. But since this is part 3 you've already been through most of them, twice.

### Steps I'm going to cover

1. Rewriting my upload function
1. Make arparse work
    1. **added after my initial best laid plans**
1. Remove the need for `python3 newmake.py`

### Let's roll

Python script I am starting out with.

``` python
from subprocess import call, check_output
import argparse
import glob
import os
import shutil

def clean():
    container = check_output(['docker', 'ps', '-af', 'name=gnoinski', '-q']).decode().rstrip("\n")
    if not container:
        print('There is no container currently')
        pass
    else:
        actions = ['kill', 'rm']
        for action in actions:
            command = ['docker', action , container]
            print('%s %s' % (action, container))
            call(command)

    output_files = glob.glob('output/*')
    for file_to_remove in output_files:
        try:
            os.remove(file_to_remove)
        except IsADirectoryError:
            shutil.rmtree(file_to_remove)


def build():
    call(['docker',  'build', '-t', 'gnoinski.ca:latest', '.'])


def dev():
    clean()
    build()
    call(['docker', 'run', '-td', '-p', '8080:8080', '-v', '%s:/site' % os.getcwd(), '--name', 'bengnoinskidev', '-u', os.getenv('USER'), 'gnoinski.ca:latest', '/bin/bash', '-c', '/site/develop_server.sh start 8080 && sleep 1d']) 


def upload():
    pass


def main():
    dev()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Replace your make file here.')
    parser.add_argument('--clean')
    parser.add_argument('--build')
    parser.add_argument('--dev')
    parser.add_argument('--upload')
    args = parser.parse_args()

    main()
```

**Rewriting my upload function**

```
def upload():
   call(['aws', 's3', 'sync', '--delete', '%s/output' % os.getcwd(), 's3://ben.gnoinski.ca'])  
   call(['aws', 'cloudfront', 'create-invalidation', '--distribution-id', 'EW7T5A29H3R3J', '--paths', '/*'])


def main():
    upload()
```

```
python3 newmake.py 
upload: output/archives.html to s3://ben.gnoinski.ca/archives.html 
upload: output/set-up-acm-ssl-certs-and-domain-validation-with-route53.html to s3://ben.gnoinski.ca/set-up-acm-ssl-certs-and-domain-validation-with-route53.html
upload: output/author/ben-gnoinski.html to s3://ben.gnoinski.ca/author/ben-gnoinski.html
upload: output/authors.html to s3://ben.gnoinski.ca/authors.html    
upload: output/categories.html to s3://ben.gnoinski.ca/categories.html
upload: output/final-thoughts-on-setting-up-my-site.html to s3://ben.gnoinski.ca/final-thoughts-on-setting-up-my-site.html
upload: output/category/info.html to s3://ben.gnoinski.ca/category/info.html
delete: s3://ben.gnoinski.ca/tag/command-line.html                  
upload: output/how-this-site-came-to-be.html to s3://ben.gnoinski.ca/how-this-site-came-to-be.html
upload: output/index.html to s3://ben.gnoinski.ca/index.html         
upload: output/setting-up-cloudfront-distribution.html to s3://ben.gnoinski.ca/setting-up-cloudfront-distribution.html
upload: output/tag/acm.html to s3://ben.gnoinski.ca/tag/acm.html     
upload: output/invalidating-cloudfront-cache.html to s3://ben.gnoinski.ca/invalidating-cloudfront-cache.html
upload: output/tag/editorial.html to s3://ben.gnoinski.ca/tag/editorial.html
upload: output/tag/cloudfront.html to s3://ben.gnoinski.ca/tag/cloudfront.html
upload: output/tag/aws.html to s3://ben.gnoinski.ca/tag/aws.html     
upload: output/tag/python.html to s3://ben.gnoinski.ca/tag/python.html
upload: output/tag/iam.html to s3://ben.gnoinski.ca/tag/iam.html     
upload: output/category/aws.html to s3://ben.gnoinski.ca/category/aws.html
upload: output/tag/make.html to s3://ben.gnoinski.ca/tag/make.html   
upload: output/tag/route53.html to s3://ben.gnoinski.ca/tag/route53.html
upload: output/tag/s3.html to s3://ben.gnoinski.ca/tag/s3.html      
upload: output/tags.html to s3://ben.gnoinski.ca/tags.html          
upload: output/tag/ssl.html to s3://ben.gnoinski.ca/tag/ssl.html    
delete: s3://ben.gnoinski.ca/updating-makefile-to-a-python-script.html
upload: output/updating-makefile-to-a-python-script-build-run-dev-container.html to s3://ben.gnoinski.ca/updating-makefile-to-a-python-script-build-run-dev-container.html
upload: output/updating-makefile-to-a-python-script-clean.html to s3://ben.gnoinski.ca/updating-makefile-to-a-python-script-clean.html
upload: output/updating-makefile-to-a-python-script-upload-to-s3-conclusion.html to s3://ben.gnoinski.ca/updating-makefile-to-a-python-script-upload-to-s3-conclusion.html
upload: output/uploading-my-new-site-to-s3.html to s3://ben.gnoinski.ca/uploading-my-new-site-to-s3.html
{
    "Location": "https://cloudfront.amazonaws.com/2017-03-25/distribution/EW7T5A29H3R3J/invalidation/IKAUNTQJOSAA",
    "Invalidation": {
        "Id": "IKAUNTQJOSAA",
        "Status": "InProgress",
        "CreateTime": "2018-04-12T02:32:08.857Z",
        "InvalidationBatch": {
            "Paths": {
                "Quantity": 1,
                "Items": [
                    "/*"
                ]
            },
            "CallerReference": "cli-1523500328-39725"
        }
    }
}
```

Yep looks like it worked, I was kind of worried about the /* in the invalidation, but it appears to have handled it fine. Aaaand I just uploaded my half done blog posts and unrevised part2. Well luckily I have a grand total of 1 reader at this point in time.

```
time make upload

real	0m3.974s
user	0m0.865s
sys	0m0.100s

```

```
time python3 newmake.py
real	0m3.310s
user	0m0.841s
sys	0m0.097s
```

```
wc Makefile 
 19  68 586 Makefile

wc newmake.py 
  54  136 1587 newmake.py
```

2.84X more words in the python script. No noticible difference in speed. Upload could be skewed due to network conditions.


**Make arparse work**

I wanted to avoid a bunch of if statements to figure out which argument was used, I just wanted the action on the command line called. I found [This link which does exactly what I want](https://stackoverflow.com/questions/27529610/call-function-based-on-argparse?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa)

```
def main(args):
    func = FUNCTION_MAP[args.action]
    func()


if __name__ == '__main__':
    FUNCTION_MAP = {'clean': clean,
                    'build': build,
                    'dev': dev,
                    'upload': upload}
    parser = argparse.ArgumentParser(description='Replace your make file here.')
    parser.add_argument('action', choices=FUNCTION_MAP, help='usage, python3 newmake.py build|dev|clean|upload')
    args = parser.parse_args()

    main(args)
```

```
wc newmake.py 
  57  151 1747 newmake.py
```

Currently at exactly 3X more lines in python than in Make, and it's not executable yet. 

* <span style="color:#054300">I had a thought while revising this, I can simplify the code I got from github.</span>
```
    func = FUNCTION_MAP[args.action]
    func()
```

<span style="color:#054300">Becomes</span>

```
FUNCTION_MAP[args.action]()
```

<span style="color:#054300">I generally try to avoid assiging things to variables simply for the sake of assigning.</span>

**Remove the need for `python3 newmake.py`**

```
#!/usr/bin/env python3

from subprocess import call, check_output
import argparse
import glob
...

```

When I originally wrote this article I found where the python3 binary was and then used it. /usr/bin/env is available on both linux and MacOS by default so this is the superior approach as it doesn't matter where the binary is located.


On the command line in the same folder as newmake.py `chmod +x newmake.py`

`./newmake.py clean`
```
kill 29c72c49707e
29c72c49707e
rm 29c72c49707e
29c72c49707e
```

What did I do here. First thing is added a shebang line at the top of my python script `#!/usr/bin/python3` which tells the os to pass the script to the program specified. It's much more elegantly explained in the linked page in the requirements.

Second thing, `chmod +x` this makes lets the os know this type of file is executable. So now we can just do `./newmake.py` and since the first line passes the script to '/usr/bin/python3' it works as if we had called `python3 newmake.py' also additional arguments get passed.

## Part 3 Conclusion

So with all of the new parts added into my "newmake.py" do we see any real difference. let's see. 

`time ./newmake.py clean`

```
time ./newmake.py clean

real	0m0.524s
user	0m0.179s
sys	0m0.032s
```

`time ./newmake.py dev`

```
real	0m1.080s
user	0m0.306s
sys	0m0.030s
```

I do not think there there was any difference in speed, at least not to any human.

In part 4 I will have a brief conclusion.

* [Part1 Clean](/updating-makefile-to-a-python-script-clean.html)
* [Part2 build run dev container](/updating-makefile-to-a-python-script-build-run-dev-container.html)
* [Part4 Conclusion](/updating-makefile-to-a-python-script-conclusion.html)
