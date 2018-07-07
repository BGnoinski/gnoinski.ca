---
title: "Switching From Pelican To Hugo"
date: 2018-07-05T03:33:05Z
draft: true
categories:
  - blog
tags: 
  - hugo
---

While I have been reasonably happy with Pelican I don't love it. It's not really being maintained, themes are outdated, and I really don't care to do front end work mainly because I don't care how pretty something looks as long as it's functional, and man are there a lot of pretty looking useless websites out there. 

In order to build my new site I'm going to follow a similar process as I did with pelican. Create a Docker container for Hugo dev. Create either a Make file or a python script to automate the build process.

### Requirements

* [Hugo install](https://gohugo.io/getting-started/installing/)
* [Hugo quickstart](https://gohugo.io/getting-started/quick-start/)

Give the docs linked above in the requirements a read if you haven't already and you'll be better off.

### Steps I'm going to cover

1. <a href="#dockerfile">Build A Docker Container</a>
1. <a href="#sitesetup">Setup A Site</a>
1. <a href="#runhugoserver">Run Hugo Server</a>


### Let's roll

**<p id="dockerfile">Build A Docker Container</p>**

From the [docs](https://gohugo.io/getting-started/installing/#debian-and-ubuntu) Looks like we want to run with something like Ubuntu 18.04. I like ubuntu so I'll start with that image. Also it looks like if I want to do code highlighting I need to install the python package 'pygments'

Dockerfile
```
FROM ubuntu:18.04
RUN apt-get update
RUN apt-get install -y hugo python3-pip
RUN pip3 install pygments
```

There we have it a basic Dockerfile that has the requirements installed for hugo. But now we need to actually build the container so that we can run it. 

```
docker build -t hugo:latest .

Sending build context to Docker daemon  2.048kB
Step 1/4 : FROM ubuntu:18.04
 ---> 113a43faa138
Step 2/4 : RUN apt-get update
 ---> Running in b5ee1981e208

... BUILD INFO HERE

 ---> 3963865fa921
Step 4/4 : RUN pip3 install pygments
 ---> Running in fbe4d4eaa2ec
Collecting pygments
  Downloading https://files.pythonhosted.org/packages/02/ee/b6e02dc6529e82b75bb06823ff7d005b141037cb1416b10c6f00fc419dca/Pygments-2.2.0-py2.py3-none-any.whl (841kB)
Installing collected packages: pygments
Successfully installed pygments-2.2.0
Removing intermediate container fbe4d4eaa2ec
 ---> 6fb84c6bf962
Successfully built 6fb84c6bf962
Successfully tagged hugo:latest
```

I now have a docker container tagged locally with hugo:latest

```
docker images
REPOSITORY                      TAG                 IMAGE ID            CREATED             SIZE
hugo                            latest              6fb84c6bf962        26 seconds ago      468MB
```

**<p id="testandtroubleshoot">Setup A Site</p>**

Before we set anything up we need to start up our container with a local volume mounted inside the container.

```
docker run -td -v $(pwd):/hugo hugo:latest
da00ca55e1d77e463f5209e982652bb4ce6f3eeaef1fdc8c2b88d74a8ee03709
```

I got the docker command right on the first try! Now I can get console into my docker container by Running

```
docker exec -it da00 /bin/bash
```

Let's get a lay of the land

```
ls -l
total 68
drwxr-xr-x   2 root root 4096 May 26 00:45 bin
drwxr-xr-x   2 root root 4096 Apr 24 08:34 boot
drwxr-xr-x   5 root root  360 Jul  5 03:04 dev
drwxr-xr-x   1 root root 4096 Jul  5 03:04 etc
drwxr-xr-x   2 root root 4096 Apr 24 08:34 home
drwxrwxr-x   2 1000 1000 4096 Jul  5 03:01 hugo
drwxr-xr-x   1 root root 4096 Jul  5 03:02 lib
drwxr-xr-x   2 root root 4096 May 26 00:44 lib64
drwxr-xr-x   2 root root 4096 May 26 00:44 media
drwxr-xr-x   2 root root 4096 May 26 00:44 mnt
drwxr-xr-x   2 root root 4096 May 26 00:44 opt
dr-xr-xr-x 294 root root    0 Jul  5 03:04 proc
drwx------   1 root root 4096 Jul  5 03:02 root
drwxr-xr-x   1 root root 4096 Jun  5 21:20 run
drwxr-xr-x   1 root root 4096 Jun  5 21:20 sbin
drwxr-xr-x   2 root root 4096 May 26 00:44 srv
dr-xr-xr-x  13 root root    0 Jul  5 02:54 sys
drwxrwxrwt   1 root root 4096 Jul  5 03:02 tmp
drwxr-xr-x   1 root root 4096 May 26 00:44 usr
drwxr-xr-x   1 root root 4096 May 26 00:45 var
```

Looks like i'm currently in the root, and there is that hugo folder from the docker command awesome.

Now we have a container running with all of our requirements a folder called /hugo that should be the local folder I ran this from. Now to actually start with Hugo. To the [Quickstart guid](https://gohugo.io/getting-started/quick-start/)

Looks like we need to run `hugo new site quickstart` I have a feeling that 'quickstart' is the site name. So I'll run `hugo new site ben.gnoinski.ca`

```
hugo new site ben.gnoinski.ca
Congratulations! Your new Hugo site is created in /hugo/ben.gnoinski.ca.

Just a few more steps and you're ready to go:

1. Download a theme into the same-named folder.
   Choose a theme from https://themes.gohugo.io/, or
   create your own with the "hugo new theme <THEMENAME>" command.
2. Perhaps you want to add some content. You can add single files
   with "hugo new <SECTIONNAME>/<FILENAME>.<FORMAT>".
3. Start the built-in live server via "hugo server".

Visit https://gohugo.io/ for quickstart guide and full documentation.
```

So it looks like I need a theme, after browsing [some themes](https://themes.gohugo.io/) I'm going with Hyde Hyde as it's pretty similar to my current layout. 

```
cd ben.gnoinski.ca
git init
git submodule add https://github.com/htr3n/hyde-hyde themes/hyde-hyde
echo 'theme = "hyde-hyde"' >> config.toml

git init
bash: git: command not found
```

Dockerfile update!
Let's kill our current running container
`docker kill da00`

```
FROM ubuntu:18.04
RUN apt-get update
RUN apt-get install -y hugo python3-pip git
RUN pip3 install pygments
```

```
docker build -t hugo:latest .

DOCKER BUILD OUTPUT HERE
```

start up the newly built container
```
docker run -td -v $(pwd):/hugo hugo:latest
2e15da4278e5c98c505c5b56e3b19be2300288e87093fa5c3bfd235b800406c5
```

get into the container
`docker exec -it 2e15 /bin/bash`

go back into /hugo
```
cd /hugo
```

And now we're back to trying to get our theme installed.

```
root@2e15da4278e5:/hugo/ben.gnoinski.ca# git init
Initialized empty Git repository in /hugo/ben.gnoinski.ca/.git/
r3n/hyde-hyde themes/hyde-hydeoinski.ca# git submodule add https://github.com/htr
Cloning into '/hugo/ben.gnoinski.ca/themes/hyde-hyde'...
remote: Counting objects: 726, done.
remote: Compressing objects: 100% (44/44), done.
remote: Total 726 (delta 28), reused 43 (delta 17), pack-reused 663
Receiving objects: 100% (726/726), 1.91 MiB | 4.25 MiB/s, done.
Resolving deltas: 100% (384/384), done.
root@2e15da4278e5:/hugo/ben.gnoinski.ca# echo 'theme = "hyde-hyde"' >> config.toml
```

Alright Theme is installed.

Now to Add some content. 

```
root@2e15da4278e5:/hugo/ben.gnoinski.ca# hugo new posts/my-first-post.md 
/hugo/ben.gnoinski.ca/content/posts/my-first-post.md created
```

Let's see what that looks like:

```
cat content/posts/my-first-post.md 
---
title: "My First Post"
date: 2018-07-05T03:33:05Z
draft: true
---git submodule add https://github.com/htr3n/hyde-hyde
```

Ok not too different than Pelican.

**<p id="runhugoserver">Run Hugo Server</p>**

Now that we have some test content let's get a hugo server fired up.

```
hugo server -D
root@2e15da4278e5:/hugo/ben.gnoinski.ca# hugo server -D

                   | EN  
+------------------+----+
  Pages            | 10  
  Paginator pages  |  0  
  Non-page files   |  0  
  Static files     | 11  
  Processed images |  0  
  Aliases          |  0  
  Sitemaps         |  1  
  Cleaned          |  0  

Total in 21 ms
Watching for changes in /hugo/ben.gnoinski.ca/{content,data,layouts,static,themes}
Watching for config changes in /hugo/ben.gnoinski.ca/config.toml
Serving pages from memory
Running in Fast Render Mode. For full rebuilds on change: hugo server --disableFastRender
Web Server is available at http://localhost:1313/ (bind address 127.0.0.1)
Press Ctrl+C to stop
```

Keep in mind that since this is inside docker localhost:1313 is local within the docker container. You could not go onto a browser on your system and have this work. Yet. In another terminal window I am going to connect to the same docker container as this one is currently occupied running the hugo server. 

Back on my host system I forgot the docker conatiner, so let's just get all running containers.

```
docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
2e15da4278e5        hugo:latest         "/bin/bash"         17 minutes ago      Up 17 minutes                           stoic_lumiere
e98af6248825        ubuntu:18.04        "/bin/bash"         44 minutes ago      Up 44 minutes                           gallant_lumiere

docker exec -it 2e15da4278e5 /bin/bash
root@2e15da4278e5:/# curl localhost:1313
bash: curl: command not found
```

Ok well I'm not going to modify my docker file at this point as I don't need curl included all the time, so since I'm already in the docker container I am just going to install curl in this container. 

```
apt-get install -y curl
APT-GET OUTPUT HERE
curl localhost:1313

<!DOCTYPE html>
<html lang="en-us">
    <head>
    <link href="http://gmpg.org/xfn/11" rel="profile">
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <!-- Enable responsiveness on mobile devices -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1">
```

Alright my hugo site is working within the container. I need to make it accessible to my local browser.

We need to kill this container, so from outside of the docker container on our local system.

```
docker kill 2e15da4278e5
```

Now we need to restart it and map container port 1313 to host port 1313.

```
docker run -td -v $(pwd):/hugo -p 1313:1313 hugo:latest
ec3855f3d7523ddfa6d2796e2e7c05506937dcdf38aa7afad4180ddac1722261
```
console into the container and start the hugo server

```
docker exec -it ec385 /bin/bash
cd /hugo/ben.gnoinski.ca
hugo server -D
```

And even now when I try to visit the site in my browser at localhost:1313 I get a connection reset. 
I'm thinking it has something to do with the fact the server is binding itself to '(bind address 127.0.0.1)'

```
hugo sever --help
HUGOHELPSTUFF
     --bind string                interface to which the server will bind (default "127.0.0.1")
MOREHUGOHELPSTUFF
    -D, --buildDrafts                include content marked as draft
```

I think bind is what I want. And I also decided to find out what -D did while I was in there, and it builds drafts cool.

```
hugo server -D --bind 0.0.0.0

                   | EN  
+------------------+----+
  Pages            | 10  
  Paginator pages  |  0  
  Non-page files   |  0  
  Static files     | 11  
  Processed images |  0  
  Aliases          |  0  
  Sitemaps         |  1  
  Cleaned          |  0  

Total in 20 ms
Watching for changes in /hugo/ben.gnoinski.ca/{content,data,layouts,static,themes}
Watching for config changes in /hugo/ben.gnoinski.ca/config.toml
Serving pages from memory
Running in Fast Render Mode. For full rebuilds on change: hugo server --disableFastRender
Web Server is available at http://localhost:1313/ (bind address 0.0.0.0)
Press Ctrl+C to stop
```

And I have a website available through chrome at https://localhost:1313 ! If you've been following along the previous link should work for you!

Now I am going to customize 'config.toml' with my info.

That's it for this post. In my next post I am going to convert all of my pelican posts to hugo.