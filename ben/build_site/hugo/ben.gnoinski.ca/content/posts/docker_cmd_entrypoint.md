---
title: "Docker CMD and ENTRYPOINT"
date: 2019-02-10T09:20:05Z
categories:
  - Infrastructure
tags:
  - docker
  - dev tools
  - beginner
---

In this post I am going to explain the difference between CMD and ENTRYPOINT.

### Requirements

* [Docker Introduction](/posts/docker_intro/)
* [Dockerfile Build And Layers](/posts/dockerfile_build_layers/)
* [Docker CMD](https://docs.docker.com/engine/reference/builder/#cmd)
* [Docker ENTRYPOINT](https://docs.docker.com/engine/reference/builder/#entrypoint)
* [Github example code for this post](https://github.com/BGnoinski/gnoinski.ca/tree/master/ben/docker/docker_cmd_entrypoint)

Give the docs linked above in the requirements a read if you haven't already and you'll be better off.

If I run a command any of the files required to run the command should be in the Github Repo, and you should be able to run the commands as long as you are in that folder.

### Steps I'm going to cover

1. <a href="#CMD">CMD</a>
1. <a href="#ENTRYPOINT">ENTRYPOINT</a>

### Let's roll

**<p id="CMD">CMD</p>**

I am staring with CMD because in the previous lessons we actually used CMD without necesarrily knowing it. When you run `docker run ubuntu:18.04 ls -alh` on the command line <code class="highlight">ls -alh</code> is the CMD that is passed to the container. You can change the CMD simply by changing the command `docker run ubuntu:18.04 ls /usr/bin`.

Where this actually becomes useful is when you bake the CMD into your Dockerfile. Example, you have a webserver and you want to run the container without specifying the CMD as part of the docker run command.

I am going to build 'Dockerfile.cmd', then run the resulting container which has a CMD of <code class="highlight">["nginx", "-g", "daemon off;"]</code>
<span style="color:#054300"> *Info* - The CMD above makes nginx run in the forground instead of as a daemon which gives docker the long running process it craves.</span> 


`docker build -f Dockerfile.cmd .`
```
Sending build context to Docker daemon  15.87kB
Step 1/4 : FROM ubuntu:18.04
 ---> ea4c82dcd15a
Step 2/4 : RUN apt-get update && apt-get upgrade -y
 ---> Using cache
 ---> 6e04ff2dfe05
Step 3/4 : RUN apt-get install -y nginx-light
 ---> Using cache
 ---> d7834447bebf
Step 4/4 : CMD ["nginx", "-g", "daemon off;"]
 ---> Using cache
 ---> 6a1ee32f804f
Successfully built 6a1ee32f804f
```


`docker run -td 6a1`
```
bf67ffdb213b5ab3acfbe7ffa0b1021c3c67a5203955ce8b9456632fb2f031d2
```

I already had this container built so it's just using the cached layers.

If I exec into the container I can curl localhost and see the nginx default page


`docker exec -it bf6 /bin/bash`
```
curl localhost
bash: curl: command not found
```

Or not, I never installed curl so let's do that now and retry curling.

<span style="color:#054300"> *Info* - I have updated Dockerfile.cmd to include curl for you.</span>

`root@bf67ffdb213b:/# apt-get update && apt-get install -y curl`

Now with curl installed

```
root@bf67ffdb213b:/# curl localhost
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
```

I truncated my curl output but you can see that we have nginx running without specifying anything on the command line as it's using the CMD in Dockerfile.cmd .

Why is this useful? When  I run the container I can specify a different CMD on the command line which overrides CMD in the Dockerfile. I am going to kill the container running nginx and then run a different command as part of `docker run`.


`docker kill bf6`
```
bf6
```


`docker run 6a1 nginx -v`
```
nginx version: nginx/1.14.0 (Ubuntu)
```


`docker ps`
```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
0becb15cceaa        hugo:latest         "/usr/bin/hugo serve…"   4 hours ago         Up 4 hours          0.0.0.0:1313->1313/tcp   hugodev
```

We can see when I gave `docker run` a command 'nginx -v' it overrode the CMD in the Dockerfile with the one provided. If it didn't we wouldn't have seen the output <code class="highlight">nginx version: nginx/1.14.0 (Ubuntu)</code>, and I would have a second container running nginx when I run `docker ps`.

<span style="color:#8C4B20">*WARNING* -</span> If you are using CMD without ENTRYPOINT which will be explained next, the first argument of CMD must be an executable.

**<p id="ENTRYPOINT">ENTRYPOINT</p>**

Now I will perform the same process with Dockerfile.entrypoint which simply replaces CMD with ENTRYPOINT.

`docker build -f Dockerfile.entrypoint .`
```
Sending build context to Docker daemon  3.072kB
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

I ran my build twice because my first build included installing curl and I wanted shorter output for this post, your output should be pretty similar to above.

Now if I start a container based on the newly built image and exec into ita we should see the nginx default page output using `curl localhost`.


`docker run -td fbd`
```
56e01b4f4ffb8c6b435cb93ca22f25c4c637239a60439f928b709b741c609b1d
```

`docker exec -it 56e /bin/bash`
```
root@56e01b4f4ffb:/# curl localhost
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>docker run fbd nginx -v
<style>
```

I again trimmed the output but it's curling the nginx default site.

So what happens now if I run the container with a command like we did before?


`docker run fbd nginx -v`
```
nginx: invalid option: "nginx"
```

<span style="color:#054300">What happend Ben, You broke it!? Why is nginx an invalid option, we saw before that it works.</span>

When you use CMD in conjuntion with ENTRYPOINT the CMD get's appended to ENTRYPOINT as command arguments. If this is not entirely clear let me hopefully clear this up.

<table>
  <th>Type</th>
  <th>In Dockerfile</th>
  <th>Command line</th>
  <th>What container executes</th>
  <tr>
    <td>CMD</td>
    <td>CMD ["nginx", "-g", "daemon off;"]</td>
    <td>docker run -td {image}</td>
    <td><code>nginx -g daemon off;</code></td>
  </tr>
  <tr>
    <td>CMD</td>
    <td>CMD ["nginx", "-g", "daemon off;"]</td>
    <td>docker run {image} nginx -v</td>
    <td><code>nginx -v</code></td>
  </tr>
  <tr>
    <td>ENTRYPOINT</td>
    <td>ENTRYPOINT ["nginx", "-g", "daemon off;"]</td>
    <td>docker run -td {image}</td>
    <td><code>nginx -g daemon off;</code></td>
  </tr>
  <tr>
    <td>ENTRYPOINT</td>
    <td>ENTRYPOINT ["nginx", "-g", "daemon off;"]</td>
    <td>docker run nginx -v</td>
    <td><code>nginx -g "daemon off;" nginx -v</code></td>
  </tr>    
</table>

It's may be hard to see in the above table so maybe that attempt didn't clear it up entirely, so I'll jump into the entrypoint container and run the command to see the exact same error from earlier.


`docker run -td fbd`
```
30629558dbc154e20ddcf90113f22d28c88afc40aaea2f49073b9c0da567f8ac
```

`docker exec -it 306 /bin/bash`
```
root@30629558dbc1:/# nginx -g "daemon off;" nginx -v
nginx: invalid option: "nginx"a
```

You may be wondering, why is ENTRYPOINT with CMD useful? Maybe your application takes a config file as a command line argument, instead of building a container for each of your environments, you provide an ENTRYPOINT for which app to start and then which config file to use via CMD. It also means that if you pass this container off to someone else it will execute the correct application. It may fail if they pass in invalid arguments, but at least you should be able to limit your troubleshooting scope. 

Example:

`application.sh {env.json}` # is how your application is started.

The Dockerfile entrypoint would be:

ENTRYPOINT ["application.sh"]

and you could run it like so:


`docker build -f Dockerfile.example1 .`
```
Sending build context to Docker daemon  7.168kB
Step 1/5 : FROM ubuntu:18.04
 ---> ea4c82dcd15a
Step 2/5 : COPY application.sh /root
 ---> Using cache
 ---> d63ab4ba0b07
Step 3/5 : COPY *.json /root/
 ---> Using cache
 ---> b799dffafd4f
Step 4/5 : WORKDIR /root
 ---> Using cache
 ---> 148295b6f714
Step 5/5 : ENTRYPOINT ["/root/application.sh"]
 ---> Using cache
 ---> 80500caf49c9
Successfully built 80500caf49c9
```

`docker run 805 dev.json`
```
{
  "APP_ENV": "dev"
}
```

`docker run 805 prod.json`
```
{
  "APP_ENV": "prod"
}
```

So you can see the results depend on which CMD is passed to the container.

Hopefully you're starting to understand the difference of, and how ENTRYPOINT and CMD work together to give flexibility in starting your containers.