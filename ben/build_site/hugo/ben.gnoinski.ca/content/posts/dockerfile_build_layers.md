---
title: "Dockerfile Build And Layers"
date: 2018-07-14T16:22:05Z
categories:
  - Infrastructure
tags:
  - docker
  - dev tools
  - intermediate
---

In the introduction post we got some basic docker fundamentals which we are going to build on. Running and modifying a container locally is good for troubleshooting, or starting your build. The real goal is to be able to consistently build customized images that run our apps. 

### Requirements

* [Docker Introduction](/posts/docker_intro/)
* [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
* [docker build](https://docs.docker.com/engine/reference/commandline/build/)
* [Github example code for this post](https://github.com/BGnoinski/gnoinski.ca/tree/master/ben/docker/dockerfile_and_build/)

Give the docs linked above in the requirements a read if you haven't already and you'll be better off.

### Steps I'm going to cover

1. <a href="#dockerfile">Create A Dockerfile</a>
1. <a href="#build">Build Your Dockerfile</a>
1. <a href="#layers">Docker Layers</a>

    * Includes a tangent into Docker layers.

### Let's roll

**<p id="dockerfile">Create A Dockerfile</p>**

When you run a docker build, by default it looks for a file called 'Dockerfile'. The Dockerfile the format is:

```
INSTRUCTION arguments
```

The INSTRUCTIONs will include but are not limited to:

* FROM - Which image are we going to use for the remainder of the Dockerfile? ex: `FROM ubuntu:18.04`
* ENV - Set a variable that can be used with specific INSTRUCTIONs ex: `ENV foo /bar`
* RUN - Command to execute within the image. ex: `RUN mkdir ${foo}` <- ${foo} was set by the ENV command
* COPY - Copy a file from the local file system into the remote file system `COPY Dockerfile ${foo}/`
* WORKDIR - Which directory inside the container to work work in. Can be used multiple times. ex: `WORKDIR ${foo}`
* ENTRYPOINT - Command to run when the container starts
* CMD - Docs quote "The main purpose of a CMD is to provide defaults for an executing container. These defaults can include an executable, or they can omit the executable, in which case you must specify an ENTRYPOINT INSTRUCTION as well."

I will go into ENTRYPOINT and CMD in depth <del>later in this post, or may bededicate one for it</del> in the next post. For now just know that they exist.

We start todays journey with a new file called Dockerfile.

Dockerfile
```
 
```
It's a new file, of course it's blank. Using with our example INSTRUCTIONS above we can add:


Example1

```
FROM ubuntu:18.04
ENV foo /bar
RUN mkdir ${foo}
COPY Dockerfile ${foo}/
WORKDIR ${foo}
```

This is a basic valid Dockerfile. After you pick your image and set any environment variables, it's going to be a collection of 'RUNs, 'COPYs, and WORKDIRs.

**<p id="build">Build your Dockerfile</p>**

The simplest form of the build command is:

* `docker build {PATH}` {PATH} being the path to the folder containing the Dockerfile. Most of the time you will run docker build from the folder containg the Dockerfile. ex: `docker build .`
* <span style="color:#8C4B20">*WARNING* - Make sure you create a new folder before starting your Docker development. When you run `docker build` docker sends ALL of the files in the current directory to the docker daemon to process. If you created the Dockerfile in your home folder, it would send all of your Documents, Downloads, Pictures, Music etc.. to the dameon. So possibly 100s of GB read for no reason. If your build times are abysmal, this could be a cause.</span>

```
ls -l
total 12
-rw-rw-r-- 1 ben ben 87 Jul 12 19:03 Dockerfile

docker build .

Sending build context to Docker daemon  2.048kB
Step 1/6 : FROM ubuntu:18.04
18.04: Pulling from library/ubuntu
6b98dfc16071: Pull complete 
4001a1209541: Pull complete 
6319fc68c576: Pull complete 
b24603670dc3: Pull complete 
97f170c87c6f: Pull complete 
Digest: sha256:5f4bdc3467537cbbe563e80db2c3ec95d548a9145d64453b06939c4592d67b6d
Status: Downloaded newer image for ubuntu:18.04
 ---> 113a43faa138
Step 2/6 : ENV foo /bar
 ---> Running in fdd9f77f4169
Removing intermediate container fdd9f77f4169
 ---> 7eb0b742ae97
Step 3/6 : RUN mkdir ${foo}
 ---> Running in 13800b35fe74
Removing intermediate container 13800b35fe74
 ---> 4f2a7f9b56ff
Step 4/6 : COPY Dockerfile ${foo}/
 ---> d72bacd488ba
Step 5/6 : WORKDIR ${foo}
Removing intermediate container 64f82cd2f845
 ---> 977a5ce2b0c7
Step 6/6 : RUN pwd
 ---> Running in 89e45f89fec7
/bar
Removing intermediate container 89e45f89fec7
 ---> a4f7b426bde2
Successfully built a4f7b426bde2
```

I'll go through each of the steps that were performed just to hammer home what happened:

1. FROM dockerhub pull image ubuntu:18.04
1. SET variable "foo" to "/bar"
1. RUN the command "mkdir /bar"
1. COPY Dockerfile to the container in the /bar folder.
1. WORKDIR is now set to "/bar". When the container is built, if you console into it, your prompt will be in the last set WORKDIR.
1. RUN command "pwd" to show what the current working folder is.

And finally at the bottom we see that it successfully built "a4f7b426bde2"

Let's see what we have for images now.

```
docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
<none>              <none>              a4f7b426bde2        5 minutes ago       81.2MB
ubuntu              18.04               113a43faa138        5 weeks ago         81.2MB
```

There is the ubuntu:18.04 image that was pulled in the FROM step. Then there is our image, notice it has no repository or tag, just an image ID. Let's fix that to make it easier to identify. I am going to use the -t flag you can see all the flags and their usage in `man docker build`.

```
docker build -t dockerfile_and_build:example1 .

Sending build context to Docker daemon  2.048kB
Step 1/6 : FROM ubuntu:18.04
 ---> 113a43faa138
Step 2/6 : ENV foo /bar
 ---> Using cache
 ---> 7eb0b742ae97
Step 3/6 : RUN mkdir ${foo}
 ---> Using cache
 ---> 4f2a7f9b56ff
Step 4/6 : COPY Dockerfile ${foo}/
 ---> Using cache
 ---> d72bacd488ba
Step 5/6 : WORKDIR ${foo}
 ---> Using cache
 ---> 977a5ce2b0c7
Step 6/6 : RUN pwd
 ---> Using cache
 ---> a4f7b426bde2
Successfully built a4f7b426bde2
Successfully tagged dockerfile_and_build:example1


docker images
REPOSITORY             TAG                 IMAGE ID            CREATED             SIZE
dockerfile_and_build   example1            a4f7b426bde2        8 minutes ago       81.2MB
ubuntu                 18.04               113a43faa138        5 weeks ago         81.2MB

```

Looking at this output it tagged the image like I wanted, but what's also exciting is "Using cache" and the fact the output is *MUCH* smaller. Well in the case of this simple image it isn't, but I will get into that.

We can now use our custom custom image just like any other.

```
docker run -td dockerfile_and_build:example1
5cf35259f0b0124f911f2d1a7bf1f174611a8f11519f3e0af8a038a0aa1cc2e3

docker exec -it 5cf /bin/bash
root@5cf35259f0b0:/bar# ls -l
total 4
-rw-rw-r-- 1 root root 95 Jul 14 02:35 Dockerfile
```

Notice when we go into the container we are in the /bar folder which was set by the last WORKDIR, and when we run `ls` there is our Dockerfile that got COPYied. Yes I know COPYied is not a word, but I'm using it anyways.

**<p id="layers">Docker Layers</p>**

Back to that "Using cache" thing. Docker tracks all of your INSTRUCTIONS and creates a unique container after each succesfully completed INSTRUCTION. 

Using our examples if you look at each line that says "Using cache" and go back to the initial build output, you will see that docker created intermediate containers for each of the steps! You can optimize your Docker build times if you put INSTRUCTIONS that rarely change at the top as Docker will be able to cache the results on subsequent builds. 

How would you use the cache to your advantage? When developing your images as you're installing additional packages it's best to put them on new lines so that docker doesn't have to rebuild everything. Then once you are satisfied that your image is working as intended you combine all of the packages that need to be installed into a single line and do a final build.

I have removed all containers, and existing images from my system to give a from scratch perspective. I am going to run a shell script that gives us a start time, an end time, and a delta of the build to give total run time for each of the examples.

In the following Examples I am going to:

* Example2 Install just python3
* Example3 Install python3-pip on it's own run line.
* Example4 Install python3-pip at the same time as python3

**example2**

```
FROM ubuntu:18.04
RUN apt update
RUN apt install -y python3
```

`./build.sh`

```
----------
Fri Jul 13 21:06:21 PDT 2018
----------
Sending build context to Docker daemon  3.072kB
Step 1/3 : FROM ubuntu:18.04
18.04: Pulling from library/ubuntu
6b98dfc16071: Pull complete 
4001a1209541: Pull complete 
6319fc68c576: Pull complete 
b24603670dc3: Pull complete 
97f170c87c6f: Pull complete 
Digest: sha256:5f4bdc3467537cbbe563e80db2c3ec95d548a9145d64453b06939c4592d67b6d
Status: Downloaded newer image for ubuntu:18.04
 ---> 113a43faa138
Step 2/3 : RUN apt update
 ---> Running in 297d21ec2e03

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Get:1 http://archive.ubuntu.com/ubuntu bionic InRelease [242 kB]
Get:2 http://archive.ubuntu.com/ubuntu bionic-updates InRelease [88.7 kB]
Get:3 http://archive.ubuntu.com/ubuntu bionic-backports InRelease [74.6 kB]
Get:4 http://archive.ubuntu.com/ubuntu bionic/universe Sources [11.5 MB]
Get:5 http://archive.ubuntu.com/ubuntu bionic/universe amd64 Packages [11.3 MB]
Get:6 http://archive.ubuntu.com/ubuntu bionic/main amd64 Packages [1344 kB]
Get:7 http://archive.ubuntu.com/ubuntu bionic/multiverse amd64 Packages [186 kB]
Get:8 http://archive.ubuntu.com/ubuntu bionic/restricted amd64 Packages [13.5 kB]
Get:9 http://archive.ubuntu.com/ubuntu bionic-updates/universe Sources [48.0 kB]
Get:10 http://archive.ubuntu.com/ubuntu bionic-updates/universe amd64 Packages [151 kB]
Get:11 http://archive.ubuntu.com/ubuntu bionic-updates/multiverse amd64 Packages [3679 B]
Get:12 http://archive.ubuntu.com/ubuntu bionic-updates/main amd64 Packages [245 kB]
Get:13 http://archive.ubuntu.com/ubuntu bionic-backports/universe amd64 Packages [2807 B]
Get:14 http://security.ubuntu.com/ubuntu bionic-security InRelease [83.2 kB]
Get:15 http://security.ubuntu.com/ubuntu bionic-security/universe Sources [8689 B]
Get:16 http://security.ubuntu.com/ubuntu bionic-security/multiverse amd64 Packages [1074 B]
Get:17 http://security.ubuntu.com/ubuntu bionic-security/main amd64 Packages [143 kB]
Get:18 http://security.ubuntu.com/ubuntu bionic-security/universe amd64 Packages [44.0 kB]
Fetched 25.5 MB in 7s (3626 kB/s)
Reading package lists...
Building dependency tree...
Reading state information...
10 packages can be upgraded. Run 'apt list --upgradable' to see them.
Removing intermediate container 297d21ec2e03
 ---> c531f90471be
Step 3/3 : RUN apt install -y python3
 ---> Running in d68bb127e7ae

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Reading package lists...
Building dependency tree...
Reading state information...
The following additional packages will be installed:
  file libexpat1 libmagic-mgc libmagic1 libmpdec2 libpython3-stdlib
  libpython3.6-minimal libpython3.6-stdlib libreadline7 libsqlite3-0 libssl1.1
  mime-support python3-minimal python3.6 python3.6-minimal readline-common
  xz-utils
Suggested packages:
  python3-doc python3-tk python3-venv python3.6-venv python3.6-doc binutils
  binfmt-support readline-doc
The following NEW packages will be installed:
  file libexpat1 libmagic-mgc libmagic1 libmpdec2 libpython3-stdlib
  libpython3.6-minimal libpython3.6-stdlib libreadline7 libsqlite3-0 libssl1.1
  mime-support python3 python3-minimal python3.6 python3.6-minimal
  readline-common xz-utils
0 upgraded, 18 newly installed, 0 to remove and 10 not upgraded.
Need to get 6184 kB of archives.
After this operation, 33.4 MB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu bionic-updates/main amd64 libssl1.1 amd64 1.1.0g-2ubuntu4.1 [1128 kB]

{ TRUNCATED OUTPUT}

running python rtupdate hooks for python3.6...
running python post-rtupdate hooks for python3.6...
Processing triggers for libc-bin (2.27-3ubuntu1) ...
Removing intermediate container d68bb127e7ae
 ---> a9f9429d3eb2
Successfully built a9f9429d3eb2
----------
Fri Jul 13 21:06:46 PDT 2018
----------
25 seconds for the build
```

**example3**

```
FROM ubuntu:18.04
RUN apt update
RUN apt install -y python3
RUN apt install -y python3-pip
```

`./build.sh`

```
----------
Fri Jul 13 21:06:53 PDT 2018
----------
Sending build context to Docker daemon  3.072kB
Step 1/4 : FROM ubuntu:18.04
 ---> 113a43faa138
Step 2/4 : RUN apt update
 ---> Using cache
 ---> c531f90471be
Step 3/4 : RUN apt install -y python3
 ---> Using cache
 ---> a9f9429d3eb2
Step 4/4 : RUN apt install -y python3-pip
 ---> Running in 095a1c510818

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Reading package lists...
Building dependency tree...
Reading state information...
The following additional packages will be installed:
  binutils binutils-common binutils-x86-64-linux-gnu build-essential
  ca-certificates cpp cpp-7 dbus dh-python dirmngr dpkg-dev fakeroot g++ g++-7
  gcc gcc-7 gcc-7-base gir1.2-glib-2.0 gnupg gnupg-l10n gnupg-utils gpg
  gpg-agent gpg-wks-client gpg-wks-server gpgconf gpgsm gpgv
  libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl
  libapparmor1 libasan4 libasn1-8-heimdal libassuan0 libatomic1 libbinutils
  libc-dev-bin libc6-dev libcc1-0 libcilkrts5 libdbus-1-3 libdpkg-perl
  libexpat1-dev libfakeroot libfile-fcntllock-perl libgcc-7-dev
  libgdbm-compat4 libgdbm5 libgirepository-1.0-1 libglib2.0-0 libglib2.0-data
  libgomp1 libgssapi3-heimdal libhcrypto4-heimdal libheimbase1-heimdal
  libheimntlm0-heimdal libhx509-5-heimdal libicu60 libisl19 libitm1
  libkrb5-26-heimdal libksba8 libldap-2.4-2 libldap-common
  liblocale-gettext-perl liblsan0 libmpc3 libmpfr6 libmpx2 libnpth0
  libperl5.26 libpython3-dev libpython3.6 libpython3.6-dev libquadmath0
  libroken18-heimdal libsasl2-2 libsasl2-modules libsasl2-modules-db
  libstdc++-7-dev libtsan0 libubsan0 libwind0-heimdal libxml2 linux-libc-dev
  make manpages manpages-dev netbase openssl patch perl perl-base
  perl-modules-5.26 pinentry-curses python-pip-whl python3-asn1crypto
  python3-cffi-backend python3-crypto python3-cryptography python3-dbus
  python3-dev python3-distutils python3-gi python3-idna python3-keyring
  python3-keyrings.alt python3-lib2to3 python3-pkg-resources
  python3-secretstorage python3-setuptools python3-six python3-wheel
  python3-xdg python3.6-dev shared-mime-info xdg-user-dirs
Suggested packages:
  binutils-doc cpp-doc gcc-7-locales default-dbus-session-bus
  | dbus-session-bus dbus-user-session libpam-systemd pinentry-gnome3 tor
  debian-keyring g++-multilib g++-7-multilib gcc-7-doc libstdc++6-7-dbg
  gcc-multilib autoconf automake libtool flex bison gdb gcc-doc gcc-7-multilib
  libgcc1-dbg libgomp1-dbg libitm1-dbg libatomic1-dbg libasan4-dbg
  liblsan0-dbg libtsan0-dbg libubsan0-dbg libcilkrts5-dbg libmpx2-dbg
  libquadmath0-dbg parcimonie xloadimage scdaemon glibc-doc git bzr gdbm-l10n
  libsasl2-modules-gssapi-mit | libsasl2-modules-gssapi-heimdal
  libsasl2-modules-ldap libsasl2-modules-otp libsasl2-modules-sql
  libstdc++-7-doc make-doc man-browser ed diffutils-doc perl-doc
  libterm-readline-gnu-perl | libterm-readline-perl-perl pinentry-doc
  python-crypto-doc python-cryptography-doc python3-cryptography-vectors
  python-dbus-doc python3-dbus-dbg gnome-keyring libkf5wallet-bin
  gir1.2-gnomekeyring-1.0 python-secretstorage-doc python-setuptools-doc
The following NEW packages will be installed:
  binutils binutils-common binutils-x86-64-linux-gnu build-essential
  ca-certificates cpp cpp-7 dbus dh-python dirmngr dpkg-dev fakeroot g++ g++-7
  gcc gcc-7 gcc-7-base gir1.2-glib-2.0 gnupg gnupg-l10n gnupg-utils gpg
  gpg-agent gpg-wks-client gpg-wks-server gpgconf gpgsm libalgorithm-diff-perl
  libalgorithm-diff-xs-perl libalgorithm-merge-perl libapparmor1 libasan4
  libasn1-8-heimdal libassuan0 libatomic1 libbinutils libc-dev-bin libc6-dev
  libcc1-0 libcilkrts5 libdbus-1-3 libdpkg-perl libexpat1-dev libfakeroot
  libfile-fcntllock-perl libgcc-7-dev libgdbm-compat4 libgdbm5
  libgirepository-1.0-1 libglib2.0-0 libglib2.0-data libgomp1
  libgssapi3-heimdal libhcrypto4-heimdal libheimbase1-heimdal
  libheimntlm0-heimdal libhx509-5-heimdal libicu60 libisl19 libitm1
  libkrb5-26-heimdal libksba8 libldap-2.4-2 libldap-common
  liblocale-gettext-perl liblsan0 libmpc3 libmpfr6 libmpx2 libnpth0
  libperl5.26 libpython3-dev libpython3.6 libpython3.6-dev libquadmath0
  libroken18-heimdal libsasl2-2 libsasl2-modules libsasl2-modules-db
  libstdc++-7-dev libtsan0 libubsan0 libwind0-heimdal libxml2 linux-libc-dev
  make manpages manpages-dev netbase openssl patch perl perl-modules-5.26
  pinentry-curses python-pip-whl python3-asn1crypto python3-cffi-backend
  python3-crypto python3-cryptography python3-dbus python3-dev
  python3-distutils python3-gi python3-idna python3-keyring
  python3-keyrings.alt python3-lib2to3 python3-pip python3-pkg-resources
  python3-secretstorage python3-setuptools python3-six python3-wheel
  python3-xdg python3.6-dev shared-mime-info xdg-user-dirs
The following packages will be upgraded:
  gpgv perl-base
2 upgraded, 117 newly installed, 0 to remove and 8 not upgraded.
Need to get 69.6 MB of archives.
After this operation, 294 MB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu bionic-updates/main amd64 perl-base amd64 5.26.1-6ubuntu0.1 [1391 kB]

{ TRUNCATED OUTPUT}

done.
Removing intermediate container 095a1c510818
 ---> d1d2d53ca02a
Successfully built d1d2d53ca02a
----------
Fri Jul 13 21:07:28 PDT 2018
----------
35 seconds for the build

```

**example4**

```
FROM ubuntu:18.04
RUN apt update
RUN apt install -y python3 python3-pip
```

`./build.sh`

```
----------
Fri Jul 13 21:07:32 PDT 2018
----------
Sending build context to Docker daemon  3.072kB
Step 1/3 : FROM ubuntu:18.04
 ---> 113a43faa138
Step 2/3 : RUN apt update
 ---> Using cache
 ---> c531f90471be
Step 3/3 : RUN apt install -y python3 python3-pip
 ---> Running in b4d59cfabe60

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Reading package lists...
Building dependency tree...
Reading state information...
The following additional packages will be installed:
  binutils binutils-common binutils-x86-64-linux-gnu build-essential
  ca-certificates cpp cpp-7 dbus dh-python dirmngr dpkg-dev fakeroot file g++
  g++-7 gcc gcc-7 gcc-7-base gir1.2-glib-2.0 gnupg gnupg-l10n gnupg-utils gpg
  gpg-agent gpg-wks-client gpg-wks-server gpgconf gpgsm gpgv
  libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl
  libapparmor1 libasan4 libasn1-8-heimdal libassuan0 libatomic1 libbinutils
  libc-dev-bin libc6-dev libcc1-0 libcilkrts5 libdbus-1-3 libdpkg-perl
  libexpat1 libexpat1-dev libfakeroot libfile-fcntllock-perl libgcc-7-dev
  libgdbm-compat4 libgdbm5 libgirepository-1.0-1 libglib2.0-0 libglib2.0-data
  libgomp1 libgssapi3-heimdal libhcrypto4-heimdal libheimbase1-heimdal
  libheimntlm0-heimdal libhx509-5-heimdal libicu60 libisl19 libitm1
  libkrb5-26-heimdal libksba8 libldap-2.4-2 libldap-common
  liblocale-gettext-perl liblsan0 libmagic-mgc libmagic1 libmpc3 libmpdec2
  libmpfr6 libmpx2 libnpth0 libperl5.26 libpython3-dev libpython3-stdlib
  libpython3.6 libpython3.6-dev libpython3.6-minimal libpython3.6-stdlib
  libquadmath0 libreadline7 libroken18-heimdal libsasl2-2 libsasl2-modules
  libsasl2-modules-db libsqlite3-0 libssl1.1 libstdc++-7-dev libtsan0
  libubsan0 libwind0-heimdal libxml2 linux-libc-dev make manpages manpages-dev
  mime-support netbase openssl patch perl perl-base perl-modules-5.26
  pinentry-curses python-pip-whl python3-asn1crypto python3-cffi-backend
  python3-crypto python3-cryptography python3-dbus python3-dev
  python3-distutils python3-gi python3-idna python3-keyring
  python3-keyrings.alt python3-lib2to3 python3-minimal python3-pkg-resources
  python3-secretstorage python3-setuptools python3-six python3-wheel
  python3-xdg python3.6 python3.6-dev python3.6-minimal readline-common
  shared-mime-info xdg-user-dirs xz-utils
Suggested packages:
  binutils-doc cpp-doc gcc-7-locales default-dbus-session-bus
  | dbus-session-bus dbus-user-session libpam-systemd pinentry-gnome3 tor
  debian-keyring g++-multilib g++-7-multilib gcc-7-doc libstdc++6-7-dbg
  gcc-multilib autoconf automake libtool flex bison gdb gcc-doc gcc-7-multilib
  libgcc1-dbg libgomp1-dbg libitm1-dbg libatomic1-dbg libasan4-dbg
  liblsan0-dbg libtsan0-dbg libubsan0-dbg libcilkrts5-dbg libmpx2-dbg
  libquadmath0-dbg parcimonie xloadimage scdaemon glibc-doc git bzr gdbm-l10n
  libsasl2-modules-gssapi-mit | libsasl2-modules-gssapi-heimdal
  libsasl2-modules-ldap libsasl2-modules-otp libsasl2-modules-sql
  libstdc++-7-doc make-doc man-browser ed diffutils-doc perl-doc
  libterm-readline-gnu-perl | libterm-readline-perl-perl pinentry-doc
  python3-doc python3-tk python3-venv python-crypto-doc
  python-cryptography-doc python3-cryptography-vectors python-dbus-doc
  python3-dbus-dbg gnome-keyring libkf5wallet-bin gir1.2-gnomekeyring-1.0
  python-secretstorage-doc python-setuptools-doc python3.6-venv python3.6-doc
  binfmt-support readline-doc
The following NEW packages will be installed:
  binutils binutils-common binutils-x86-64-linux-gnu build-essential
  ca-certificates cpp cpp-7 dbus dh-python dirmngr dpkg-dev fakeroot file g++
  g++-7 gcc gcc-7 gcc-7-base gir1.2-glib-2.0 gnupg gnupg-l10n gnupg-utils gpg
  gpg-agent gpg-wks-client gpg-wks-server gpgconf gpgsm libalgorithm-diff-perl
  libalgorithm-diff-xs-perl libalgorithm-merge-perl libapparmor1 libasan4
  libasn1-8-heimdal libassuan0 libatomic1 libbinutils libc-dev-bin libc6-dev
  libcc1-0 libcilkrts5 libdbus-1-3 libdpkg-perl libexpat1 libexpat1-dev
  libfakeroot libfile-fcntllock-perl libgcc-7-dev libgdbm-compat4 libgdbm5
  libgirepository-1.0-1 libglib2.0-0 libglib2.0-data libgomp1
  libgssapi3-heimdal libhcrypto4-heimdal libheimbase1-heimdal
  libheimntlm0-heimdal libhx509-5-heimdal libicu60 libisl19 libitm1
  libkrb5-26-heimdal libksba8 libldap-2.4-2 libldap-common
  liblocale-gettext-perl liblsan0 libmagic-mgc libmagic1 libmpc3 libmpdec2
  libmpfr6 libmpx2 libnpth0 libperl5.26 libpython3-dev libpython3-stdlib
  libpython3.6 libpython3.6-dev libpython3.6-minimal libpython3.6-stdlib
  libquadmath0 libreadline7 libroken18-heimdal libsasl2-2 libsasl2-modules
  libsasl2-modules-db libsqlite3-0 libssl1.1 libstdc++-7-dev libtsan0
  libubsan0 libwind0-heimdal libxml2 linux-libc-dev make manpages manpages-dev
  mime-support netbase openssl patch perl perl-modules-5.26 pinentry-curses
  python-pip-whl python3 python3-asn1crypto python3-cffi-backend
  python3-crypto python3-cryptography python3-dbus python3-dev
  python3-distutils python3-gi python3-idna python3-keyring
  python3-keyrings.alt python3-lib2to3 python3-minimal python3-pip
  python3-pkg-resources python3-secretstorage python3-setuptools python3-six
  python3-wheel python3-xdg python3.6 python3.6-dev python3.6-minimal
  readline-common shared-mime-info xdg-user-dirs xz-utils
The following packages will be upgraded:
  gpgv perl-base
2 upgraded, 135 newly installed, 0 to remove and 8 not upgraded.
Need to get 75.8 MB of archives.
After this operation, 328 MB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu bionic-updates/main amd64 perl-base amd64 5.26.1-6ubuntu0.1 [1391 kB]

{ TRUNCATED OUTPUT}

done.
Removing intermediate container b4d59cfabe60
 ---> e4be7ed6b199
Successfully built e4be7ed6b199
----------
Fri Jul 13 21:08:18 PDT 2018
----------
46 seconds for the build


```

I truncated a lot of output, it is included for each example on Github.

|example|build time|line count|
|:-------|:----------|:----------|
|example2|25s|191|
|example3|35s|717|
|example4|46s|833|

Maybe this wasn't the best example as we're only saving ourselves 10 seconds but we're also only dealing with 2 packages. Or Maybe layers don't save us any time at all and it really doesn't affect build times. Since I have a docker file for my hugo site I am going to run a couple more tests to see if what I said earlier is true at all. I am going to truncate all of the output leaving just build times for these. I also just realized that in example2 it had to pull the image which will increase the build time. So for these next examples I am going to run them all with ubuntu:18.04 already pulled. 

* Example5 Install without git
* Example6 Install git on it's own run line.
* Example7 Install git with hugo and python3-pip

example5
```
FROM ubuntu:18.04

RUN adduser -gecos '' ben --disabled-password
RUN apt-get update
RUN apt-get install -y hugo python3-pip
RUN pip3 install pygments
WORKDIR /hugo/ben.gnoinski.ca
```

`./build.sh`

```
----------
Sat Jul 14 08:50:58 PDT 2018
----------
{ TRUNCATED OUTPUT}
----------
Sat Jul 14 08:52:05 PDT 2018
----------
67 seconds for the build
```


example6
```
FROM ubuntu:18.04

RUN adduser -gecos '' ben --disabled-password
RUN apt-get update
RUN apt-get install -y hugo python3-pip
RUN apt-get install -y git
RUN pip3 install pygments
WORKDIR /hugo/ben.gnoinski.ca
```

`./build.sh`

```
----------
Sat Jul 14 08:59:50 PDT 2018
----------
{ TRUNCATED OUTPUT}
----------
Sat Jul 14 09:00:05 PDT 2018
----------
15 seconds for the build
```


example7
```
FROM ubuntu:18.04

RUN adduser -gecos '' ben --disabled-password
RUN apt-get update
RUN apt-get install -y hugo python3-pip git
RUN pip3 install pygments
WORKDIR /hugo/ben.gnoinski.ca
```

`./build.sh`

```
----------
Sat Jul 14 09:00:12 PDT 2018
----------
{ TRUNCATED OUTPUT}
----------
Sat Jul 14 09:01:13 PDT 2018
----------
61 seconds for the build
```

|example|build time|line count|
|:-------|:----------|:----------|
|example5|67s|870|
|example6|15s|210|
|example7|61s|1007|

Again these are very small examples, but demonstrate my point a little better, thankfully. Our initial build without git took 67 seconds, then when git was installed on a new line our new build only took 15 seconds compared to 61 when we added git with hugo and python3-pip.

Maybe in your own Dockerfiles the first thing you do is copy your code to the container. Because your code changes presumably on every build, you force every single other layer to get rebuilt. Instead you can move any package installs above it to at lease improve you build times a bit. 

<!--started2018-07-12T13:33:05Z-->