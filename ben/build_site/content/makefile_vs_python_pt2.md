Title: Updating Makefile to a Python script - build run dev container
Date: 2018-04-10 16:30
Category: AWS
Tags: Python, Make

# Updating Makefile to a Python script Part 2

Since I already have most of the heavy listing done between `call` and `check_output` I think the rest of the Makefile should come together pretty quick. I also had the epiphany that while using argparse I will mimic Make and instead of having switch flags for the function I'll simply make it `python3 newmake.py ACTION` where action is either clean, build, dev, or upload. 

Some info before we get started.

Makefile building the docker container, running the dev container included. 

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

---

wc Makefile 
 15  54 445 Makefile

```

### Requirements

* python3 (Most of this stuff will work in 2.7, I think)
* [python subprocess](https://docs.python.org/2/library/subprocess.html)
* [python os](https://docs.python.org/3/library/os.html)

I think I am going to need os to get the current dir for the -v flag.

** added after my initial best laid plans **

I also needed os to get the USER env variable.

### steps I'm going to cover

* Rewriting my build function
* Rewriting my dev function

Give the above docs linked in the requirements a read if you haven't already and you'll be better off. But since this is part 2 you've already been through them all. 

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
    pass


def dev():
    pass


def upload():
    pass


def main():
    clean()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Replace your make file here.')
    parser.add_argument('--clean')
    parser.add_argument('--build')
    parser.add_argument('--dev')
    parser.add_argument('--upload')
    args = parser.parse_args()

    main()
```

<span style="color:#054300"> I will refactor argparse later, for now I'm keeping it as is.</span>

```
wc newmake.py 
  51   95 1091 newmake.py
```

** Rewriting my build function ** 

``` python
def build():
    clean()
    call(['docker',  'build', '-t', 'gnoinski.ca:latest', '.'])

...

def main():
    build()
```

argparse isn't setup yet so I'm just calling build directly, and build includes clean just like the Makefile.

```
python3 newmake.py
kill c212af323bcd
c212af323bcd
rm c212af323bcd
c212af323bcd
Sending build context to Docker daemon   4.59MB
Step 1/8 : FROM alpine:latest
 ---> 3fd9065eaf02
Step 2/8 : COPY requirements.txt /site/requirements.txt
 ---> Using cache
 ---> 5ddf42bfe3dd
Step 3/8 : RUN adduser -g '' ben -D
 ---> Using cache
 ---> 3489b2500329
Step 4/8 : RUN apk update
 ---> Using cache
 ---> 75701c0f3c2d
Step 5/8 : RUN apk add python3 alpine-sdk bash vim
 ---> Using cache
 ---> 8c1c9d947449
Step 6/8 : RUN pip3 install --upgrade pip
 ---> Using cache
 ---> bea5c3742dcd
Step 7/8 : RUN pip3 install -r /site/requirements.txt
 ---> Using cache
 ---> b1eed19d4a28
Step 8/8 : WORKDIR /site
 ---> Using cache
 ---> b7dc11800da1
Successfully built b7dc11800da1
Successfully tagged gnoinski.ca:latest
```

It worked. After looking at my Makefile I realized I don't do a clean before build so I have now removed that. Just so that I don't add 0.5xx seconds on to the build job. Want to have as true of tests as possible.

```
def build():
    call(['docker',  'build', '-t', 'gnoinski.ca:latest', '.'])
```

```
time make build
docker build -t gnoinski.ca:latest .
Sending build context to Docker daemon  4.578MB
Step 1/8 : FROM alpine:latest
 ---> 3fd9065eaf02
Step 2/8 : COPY requirements.txt /site/requirements.txt
 ---> Using cache
 ---> 5ddf42bfe3dd
Step 3/8 : RUN adduser -g '' ben -D
 ---> Using cache
 ---> 3489b2500329
Step 4/8 : RUN apk update
 ---> Using cache
 ---> 75701c0f3c2d
Step 5/8 : RUN apk add python3 alpine-sdk bash vim
 ---> Using cache
 ---> 8c1c9d947449
Step 6/8 : RUN pip3 install --upgrade pip
 ---> Using cache
 ---> bea5c3742dcd
Step 7/8 : RUN pip3 install -r /site/requirements.txt
 ---> Using cache
 ---> b1eed19d4a28
Step 8/8 : WORKDIR /site
 ---> Using cache
 ---> b7dc11800da1
Successfully built b7dc11800da1
Successfully tagged gnoinski.ca:latest

real	0m0.201s
user	0m0.104s
sys	0m0.029s
```

```
time python3 newmake.py 
Sending build context to Docker daemon  4.579MB
Step 1/8 : FROM alpine:latest
 ---> 3fd9065eaf02
Step 2/8 : COPY requirements.txt /site/requirements.txt
 ---> Using cache
 ---> 5ddf42bfe3dd
Step 3/8 : RUN adduser -g '' ben -D
 ---> Using cache
 ---> 3489b2500329
Step 4/8 : RUN apk update
 ---> Using cache
 ---> 75701c0f3c2d
Step 5/8 : RUN apk add python3 alpine-sdk bash vim
 ---> Using cache
 ---> 8c1c9d947449
Step 6/8 : RUN pip3 install --upgrade pip
 ---> Using cache
 ---> bea5c3742dcd
Step 7/8 : RUN pip3 install -r /site/requirements.txt
 ---> Using cache
 ---> b1eed19d4a28
Step 8/8 : WORKDIR /site
 ---> Using cache
 ---> b7dc11800da1
Successfully built b7dc11800da1
Successfully tagged gnoinski.ca:latest

real	0m0.187s
user	0m0.103s
sys	0m0.013s
```

I ran the above commands a few times, and python3 was faster averaging 0.190s and Make was around 0.195s. Make was a little slower, but no human would ever know that.

```
wc newmake.py 
  51   99 1146 newmake.py
```

Here we are with 3.4X more lines in newmake.py then we are in the Make file. 

** Rewriting my dev function **

```
def dev():
    clean()
    build()
    call(['docker', 'run', '-td', '-p' ',8080:8080', '-v', '%s:/site' % os.getcwd(), '--name', 'bengnoinskidev', '-u', os.getenv('USER'), 'gnoinski.ca:latest', '/bin/bash', '-c', '\'/site/develop_server.sh start 8080 && sleep 1d\''])

...

def main():
    dev()
```
* <span style="color:#054300"> Well no wonder my container randomly died after being away for a while, I've got a sleep 1d there. This should really be replace with supervisor to monitor the develop_server process. </span>


`pyhon3 newmake.py`

```
docker: Invalid hostPort: ,8080.
See 'docker run --help'.
```
And typo in the code.

```
def dev():
    clean()
    build()
    call(['docker', 'run', '-td', '-p', '8080:8080', '-v', '%s:/site' % os.getcwd(), '--name', 'bengnoinskidev', '-u', os.getenv('USER'), 'gnoinski.ca:latest', '/bin/bash', '-c', '\'/site/develop_server.sh start 8080 && sleep 1d\'']) 
```

Command ran, but container is not up.
```
docker ps -a
CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS                        PORTS               NAMES
0c45168a4b57        gnoinski.ca:latest   "/bin/bash -c ''/sit…"   27 seconds ago      Exited (127) 26 seconds ago                       bengnoinskidev
```

So it looks like it's having an issue with the ports still. But that part of the code looks right. Only thing is the escaped \'\ since it's in quotes already maybe we don't need the extra escaped quotes.

```
def dev():
    clean()
    build()
    call(['docker', 'run', '-td', '-p', '8080:8080', '-v', '%s:/site' % os.getcwd(), '--name', 'bengnoinskidev', '-u', os.getenv('USER'), 'gnoinski.ca:latest', '/bin/bash', '-c', '/site/develop_server.sh start 8080 && sleep 1d']) 

```

```
docker ps -a
CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS              PORTS                    NAMES
3d2008d57b35        gnoinski.ca:latest   "/bin/bash -c '/site…"   3 seconds ago       Up 2 seconds        0.0.0.0:8080->8080/tcp   bengnoinskidev

```

There it is and my container is up.

So now between python and make

```
time make dev

...

Successfully built b7dc11800da1
Successfully tagged gnoinski.ca:latest
docker run -td -p 8080:8080 -v /home/ben/gnoinski.ca/ben/build_site:/site --name bengnoinskidev -u ben gnoinski.ca:latest /bin/bash -c '/site/develop_server.sh start 8080 && sleep 1d'
5be09fc1ae44eb3b1f1dda26b55b9b7f2e91b52aff21b79ef863194881fcfbe5

real	0m1.078s
user	0m0.355s
sys	0m0.049s
```

```
time python3 newmake.py

...

Successfully built b7dc11800da1
Successfully tagged gnoinski.ca:latest
66723bbbab227180f73bceb4bb460cb7b10bc400fa5c612b654ca764a81db4f8

real	0m1.025s
user	0m0.315s
sys	0m0.026s
```
## Part 2 Conclusion


With the Makefile it never went as quick as 1.025s but averaged around 1.07. I saw python go as fast as 1.004, but averaged around 1.04.

```
wc newmake.py 
  
```

* Makefile  15 lines 54 words
* newmake.py 53 lines 122 words

So we are now 3.53X more lines in python. 

Since the groundwork is already laid python was pretty quick to setup these functions with a few minor tweaks required.

Part3 will include the uploading to s3 using the existing AWS cli, I'm not going to introduce boto3 yet even though it is preferred if working with Python and AWS.