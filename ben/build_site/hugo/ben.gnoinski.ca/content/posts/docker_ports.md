---
title: "Docker Ports"
date: 2019-02-17T13:45:05Z
categories:
  - Infrastructure
tags:
  - docker
  - dev tools
  - beginner
---

So far I have gone through how to build images, get containers running, and how to run your applications. None of that means anything if you can't access your application outside the container! So how do we do that? We tell the host to listen on a port and forward any traffic it receives to a port on the container. The host port can not be used twice at the same time, but you can use the same port within the container.

### Requirements

* [Docker Introduction](/posts/docker_intro/)
* [Dockerfile Build And Layers](/posts/dockerfile_build_layers/)
* [Docker CMD and ENTRYPOINT](/posts/docker_cmd_entrypoint/)
* [Docker Container Networking](https://docs.docker.com/config/containers/container-networking/)
* [Dockerfile Expose](https://docs.docker.com/engine/reference/builder/#expose)
* [Github example code for this post](https://github.com/BGnoinski/gnoinski.ca/tree/master/ben/docker/docker_ports)


Give the docs linked above in the requirements a read if you haven't already and you'll be better off.

If I run a command any of the files required to run the command should be in the Github Repo, and you should be able to run the commands as long as you are in that folder.

### Steps I'm going to cover

1. <a href="#forward">Forward Host Port To Docker Container</a>
1. <a href="#expose">Expose Container Ports In The Image</a>

### Let's roll

**<p id="forward">Forward Host Port To Docker Container</p>**

First thing we need to do is build an image that has a webserver. I am reusing my example from the [CMD ENTRYPOINT](/posts/docker_cmd_entrypoint) post.
`docker build -f Dockerfile.entrypoint`

```
Sending build context to Docker daemon  2.095kB
Step 1/5 : FROM ubuntu:18.04
 ---> ea4c82dcd15a
Step 2/5 : RUN apt-get update && apt-get upgrade -y
 ---> Using cache
 ---> 6e04ff2dfe05
Step 3/5 : RUN apt-get install -y curl
 ---> Using cache
 ---> 176048a18465
Step 4/5 : RUN apt-get install -y nginx-light
 ---> Using cache
 ---> 56fbb8b68510
Step 5/5 : ENTRYPOINT ["nginx", "-g", "daemon off;"]
 ---> Using cache
 ---> fbdf31b4c72a
Successfully built fbdf31b4c72a
```

Instabuild, gotta love those layers and cache.

Now I could run this container like we have in the past, but we would not be able to access nginx that is running on it outside of the conatiner. So I now introduce the `docker run`
<code class="highlight">-p</code> command argurment. The way -p works is simple <code class="highlight">-p hostport:containerport/protocol</code>

**hostport**: The port the host will listen on. You can talk to this port in order to communicate with the container.

**containerport**: The port inside the container that the host will forward the traffic to. Your application in the container needs to listen on this port.

**/protocol**: The protocol is optional and can be either 'tcp' or 'udp'. tcp is the default if not specified.

You can repeat the -p argument as many times as needed for your application. You can use separate -p arguments to specify both tcp and udp ports.

Let's start a container based on the built image that makes the host listen on port 80, and forwards to port 80 in the container.

`docker run -td fbd -p 80:80` <span style="color:red">*CRITICAL* - This Command is wrong</span>

```
46f028f8b24474e4ac8b2a8ce2ea581183cc7a9adf01b41f9c1af87d30416288
```

So that's it, we started the container. Let's see if there is anything different with `docker ps`

```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
246835fd2ef9        hugo:latest         "/usr/bin/hugo serve…"   About an hour ago   Up About an hour    0.0.0.0:1313->1313/tcp   hugodev
```

This is not what I expected at all, my nginx container isn't running and listening on port 80 like I expect....

So I ran the container just by running `docker run fbd` and then exec'ed into it, made sure nginx was running like I expected. It was. So I went and looked back at the command and realized I typed it in very wrong. 

<span style="color:#8C4B20">*WARNING* - Docker cares about argument position and it expected the image to be the last argument.</span>

Let's try with the correct command `docker run -td -p 80:80 fbd`

```
86610c76cc75b02b57f078749e28d17e4c07b775ae7b09708d8fa65b04c0ca1f
```

`docker ps`
```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
86610c76cc75        fbd                 "nginx -g 'daemon of…"   3 seconds ago       Up 2 seconds        0.0.0.0:80->80/tcp       affectionate_lewin
246835fd2ef9        hugo:latest         "/usr/bin/hugo serve…"   2 hours ago         Up 2 hours          0.0.0.0:1313->1313/tcp   hugodev
```

Despite the format not being great, that is what I expected. We have a second container and under ports <code class="highlight">0.0.0.0:80->80/tcp</code> . This means that the host is listening on port 80 and forwarding to the containers port 80. 

<span style="color:#054300"> *Info* - Port 80 is the default port for http which nginx listens on after a fresh install.</span>

Now if I curl from my local command line, not within the docker container, I get the nginx default page output.

`curl localhost`
```
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
```

That's it, easy. But what if I have something else running on 80 that's not going to work, we can simply specify a different host port, but still send it to the same container port.

`docker run -td -p 8080:80 fbd`
```
53669acd89c627c3440b5d575fecabe72eefd2c529ff01ebb2e62e5ab0500058
```
`docker ps`
```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
53669acd89c6        fbd                 "nginx -g 'daemon of…"   4 seconds ago       Up 2 seconds        0.0.0.0:8080->80/tcp     pensive_golick
86610c76cc75        fbd                 "nginx -g 'daemon of…"   36 minutes ago      Up 36 minutes       0.0.0.0:80->80/tcp       affectionate_lewin
246835fd2ef9        hugo:latest         "/usr/bin/hugo serve…"   2 hours ago         Up 2 hours          0.0.0.0:1313->1313/tcp   hugodev
```

From this output you can see that I have 3 containers running, I am only interested in the 2 running <code class="highlight"><"nginx -g 'daemon of…"</code> . You can see that one is <code class="highlight">0.0.0.0:8080->80/tcp</code> and the other is the original<code class="highlight">0.0.0.0:80->80/tcp</code>

`curl localhost:8080`
```
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
```
Now I can curl on that new host port(8080) and get to the app running in the container which is listening on port 80.

As long as the host port is available, you can run as many containers as you have host ports.
<span style="color:#8C4B20">*WARNING* - I say that you can have as many containers as host ports, but memory, cpu, system or docker limitations may crash your system long before binding containers to all 65535 ports. Try if it you wan't I'm not going to.</span>

What you could now is modify the contents of one container without affecting the other to test changes. Although that is a pretty terrible workflow, and there are better ways of devloping using docker. I won't go into development workflows using docker as it's not my wheelhouse and I am confident there are plenty of examples out there. I kind of got into it on [Switching From Pelican To Hugo - Pt1](/posts/hugo_switch_pt1/) and is how I am currently writing this post.

**<p id="expose">Expose Container Ports In The Image</p>**

On the [Docker CMD and ENTRYPOINT post](/posts/docker_cmd_entrypoint/) I explained how ENTRYPOINT can be used to ensure the correct command is run when you pass a container off to someone else. Just like we want to make sure the correct commands are run, we also want to make sure they know which ports are required for our application. The best way to do this is with detailed Documentation on your container and application. Along with the documentation we should also EXPOSE the ports for our container inside the image.

I am going to build and run my container that is EXPOSE'ing a tcp and a udp port just to show you what it looks like.

`docker build -f Dockerfile.expose .`

```
Sending build context to Docker daemon   2.56kB
Step 1/7 : FROM ubuntu:18.04
 ---> ea4c82dcd15a
Step 2/7 : RUN apt-get update && apt-get upgrade -y
 ---> Using cache
 ---> 6e04ff2dfe05
Step 3/7 : RUN apt-get install -y curl
 ---> Using cache
 ---> 176048a18465
Step 4/7 : RUN apt-get install -y nginx-light
 ---> Using cache
 ---> 56fbb8b68510
Step 5/7 : ENTRYPOINT ["nginx", "-g", "daemon off;"]
 ---> Using cache
 ---> fbdf31b4c72a
Step 6/7 : EXPOSE 80
 ---> Running in 50d29c61fd7a
Removing intermediate container 50d29c61fd7a
 ---> 91dbaf15316b
Step 7/7 : EXPOSE 7514/udp
 ---> Running in 11f2796de386
Removing intermediate container 11f2796de386
 ---> a212cb976e54
Successfully built a212cb976e54
```

Other than EXPOSE'ing the ports, it is the same as the Docker.entrypoint which gives us a container running nginx.

`docker run -td a212`


```
a93a89b4db8352c12f0d5e3bb6ecc798fae71092c4d693673198d832e2a7688e
```

`docker ps`

```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
a93a89b4db83        a212                "nginx -g 'daemon of…"   4 seconds ago       Up 3 seconds        80/tcp, 7514/udp         distracted_albattani
8181d4ca447b        hugo:latest         "/usr/bin/hugo serve…"   18 hours ago        Up 18 hours         0.0.0.0:1313->1313/tcp   hugodev
```

We have a container it says <code class="highlight">80/tcp</code> and <code class="highlight">7514/udp</code> success! Let's just `curl localhost` to see the container running in all it's glory.

```
curl: (7) Failed to connect to localhost port 80: Connection refused
```

Not so fast, did you notice that the output of `docker ps` was slightly different this time? When `curl localhost` worked:<br><code class="highlight">0.0.0.0:80->80/tcp</code><br>
versus: <code class="highlight">80/tcp</code>

The <code class="highlight">0.0.0.0:80->80</code> shows that the host is listening on 0.0.0.0:80 and sending <code class="highlight">-></code> to container port 80. With docker ps, if there is no arrow, then traffic is not being forwarded. What that means is even though the ports are EXPOSEd we still need to tell docker to publish the ports with <code class="highlight">-p</code>. Let's kill that container and re-start it with the ports published.

`docker kill a93`
```
a93
```

`docker run -td -p 80:80 -p 7514:7514/udp a212`
```
77be1ec4a0123637c18f9f3ebc15f135662378b15d9e3cb1d8f1437e11c397ac
```
`docker ps`
```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                        NAMES
77be1ec4a012        a212                "nginx -g 'daemon of…"   2 seconds ago       Up 1 second         0.0.0.0:80->80/tcp, 0.0.0.0:7514->7514/udp   blissful_shtern
8181d4ca447b        hugo:latest         "/usr/bin/hugo serve…"   18 hours ago        Up 18 hours         0.0.0.0:1313->1313/tcp                       hugodev
```

Notice our <code class="highlight">-></code> as well we now also see that 7514 is <code class="highlight">udp</code>.

`curl localhost`
```
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
```

There we have it, we now know how to publish ports using <code class="highlight">-p</code> and how to EXPOSE and read EXPOSEd ports from containers that we did not make.
<!-- Stared 2019-02-12T20:07:05Z -->

