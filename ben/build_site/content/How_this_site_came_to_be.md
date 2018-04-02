Title: How this site came to be
Date: 2018-04-01 18:39
Category: Info

A co-worker was asking for some help on AWS Cloudfront/S3 in slack and [I clicked on the link](https://www.codependentcodr.com) for the page he was setting up. I asked him what he was using and he said pelican and that it was based on Python which is the language I am most familiar with. I saw it supports markdown which I also enjoy using. He mentioned other people were using Jekyll which is based on ruby, so that was a haaaard no for me.

I figured my first post would be getting this site setup.

## Requirements

My current host system is Ubuntu 17.10 so you may need to adjust this slightly.

* [docker](https://www.docker.com/) You should know `docker pull` `docker build` `docker run` and Dockerfiles
* [pelican](getpelican.com)
* Make
* Time (No this is not a library or technology, simply time)

## Let's get started

First thing I needed to do was install docker.[Instructions here](https://docs.docker.com/install/linux/docker-ce/ubuntu/)

```bash
apt-get update && apt-get upgrade
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install docker-ce
```

Then I built a base dockerfile that has simply `FROM alpline:latest`
With that docker container built I ran it using `docker run -td {IMAGE ID}`
And then got into it running `docker exec -it {CONTAINER ID} /bin/sh`

I started going through the pelican docs doing their `pelican quickstart` and my docker file new looks like:

```
FROM alpine:latest

RUN apk update
RUN apk add python3 alpine-sdk bash
RUN pip3 install pylint pelican markdown
RUN pip3 install --upgrade pip
```

For local testing I ended up with:

`docker run -td -p 8080:8080 -v /home/ben/gnoinski.ca/ben/build_site/:/site {IMAGE ID}`

And after the pelican quickstart I can run `./develop_server.sh start 8080` and then browse everything on the localhost.

At this point I looked at CodependentCodr s repo to see what theme he was using and realized I messed up something so basic I should be emabarresed. I didn't have a requirements.txt for pip. I was just installing all the requirements adhoc in the Dockerfile. Fixed that, and added vim. Everytime I went `vim file` and the command doesn't exist it annoyed me, so I might as well fix it since vim is muscle memory at this point.

New docker file:

```
FROM alpine:latest

COPY requirements.txt /site/requirements.txt

RUN apk update
RUN apk add python3 alpine-sdk bash
RUN pip3 install --upgrade pip
RUN pip3 install -r /site/requirements.txt
```

I didn't like the default theme that came with it so next I found a theme that I liked. Pelican has [a list of themes](https://github.com/getpelican/pelican-themes). *DISCLAIMER* It looks like a lot of the themes listed are at specific commits/never updated. As with most free stuff YMMV. After you find one that you like you need to clone it to your local site directory the `pelican-theme` command requires a local path for install. I forked the public repo to my own github to ensure that it will always be available. I then added it as a submodule to my repo.

The Makefile that came with Pelican has a lot of good default options. Since I'm using docker *none* of it applies to me unless I'm in the container itself so I removed it and decided to create my own.

I have a few options that I can do here. I could do bash, or a python scripts, but I'm going to use Make. Make has it's own language which I have found difficult to use at times. What I really like is that I can do `make build` and without any other input it will do a few other required steps first. For my terraform I frequently use `make plan` which first runs `clean` which removes the .terraform and any plans, then runs `configure` which does the terraform init, and then it will finally do the terraform plan.

Inital Makefile is pretty basic
``` Make
current_dir = $(shell pwd)

clean:
        rm -rf output/*

build:
        docker build -t gnoinski.ca:latest .

dev: build
        docker run -td -p 8080:8080 -v $(current_dir):/site gnoinski.ca:latest /bin/bash -c '/site/develop_server.sh start 8080 && sleep 1d'
```

Of course I could make the image name a variable but since this will only be used for me I'm ok with hardcoding the name. I found that if I was not in the /site folder and tried to run develop_server it errored with 
```
bash-4.4# /bin/bash -c '/site/develop_server.sh start 8080 && sleep 1d'
Starting up Pelican and HTTP server
DEBUG: Pelican version: 3.7.1
DEBUG: Python version: 3.6.3
CRITICAL: FileNotFoundError: [Errno 2] No such file or directory: '//pelicanconf.py'
Traceback (most recent call last):
  File "/usr/bin/pelican", line 11, in <module>
    sys.exit(main())
  File "/usr/lib/python3.6/site-packages/pelican/__init__.py", line 393, in main
    pelican, settings = get_instance(args)
  File "/usr/lib/python3.6/site-packages/pelican/__init__.py", line 374, in get_instance
    settings = read_settings(config_file, override=get_config(args))
  File "/usr/lib/python3.6/site-packages/pelican/settings.py", line 155, in read_settings
    local_settings = get_settings_from_file(path)
  File "/usr/lib/python3.6/site-packages/pelican/settings.py", line 225, in get_settings_from_file
    module = load_source(name, path)
  File "/usr/lib/python3.6/site-packages/pelican/settings.py", line 21, in load_source
    return SourceFileLoader(name, path).load_module()
  File "<frozen importlib._bootstrap_external>", line 399, in _check_name_wrapper
  File "<frozen importlib._bootstrap_external>", line 823, in load_module
  File "<frozen importlib._bootstrap_external>", line 682, in load_module
  File "<frozen importlib._bootstrap>", line 265, in _load_module_shim
  File "<frozen importlib._bootstrap>", line 684, in _load
  File "<frozen importlib._bootstrap>", line 665, in _load_unlocked
  File "<frozen importlib._bootstrap_external>", line 674, in exec_module
  File "<frozen importlib._bootstrap_external>", line 780, in get_code
  File "<frozen importlib._bootstrap_external>", line 832, in get_data
FileNotFoundError: [Errno 2] No such file or directory: '//pelicanconf.py'
Pelican didn't start. Is the Pelican package installed?
Stopping HTTP server
Stale PID, deleting
/site/develop_server.sh: line 34:    28 Terminated              $PY -m pelican.server $port  (wd: //output)
```

So I had to update my Dockerfile to include a WORKDIR

```
FROM alpine:latest

COPY requirements.txt /site/requirements.txt

RUN apk update
RUN apk add python3 alpine-sdk bash vim
RUN pip3 install --upgrade pip
RUN pip3 install -r /site/requirements.txt

WORKDIR /site
```

Alright my local dev environment is now setup and listening on port 8080.

At this point I wanted a way to also be able to stop and remove all of my docker mess associated with the above. Updated my Makefile

``` Make
current_dir = $(shell pwd)
current_container = $(shell docker ps -f name=gnoinski -q)

clean:
	rm -rf output/*
	docker kill $(current_container)
	docker rm $(current_container)

build:
	docker build -t gnoinski.ca:latest .

dev: clean build
	docker run -td -p 8080:8080 -v $(current_dir):/site --name bengnoinskidev -u $(USER) gnoinski.ca:latest /bin/bash -c '/site/develop_server.sh start 8080 && sleep 1d'
```

Hmm `make clean` will error if the container does not exist. Well let's do a little if statement

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
```

I am going to host this using Cloudfront backed by s3. I'm undecided if I should continue on with how I'm going to upload and host the site or do that in another post.