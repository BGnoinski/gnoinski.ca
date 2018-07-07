Title: Updating Makefile to a Python script - Clean
Date: 2018-04-09 16:30
Category: Utility
Tags: Python, Make

# Updating Makefile to a Python script Part 1

I was over on yyjtech slack the other day when [The Codependent Codr](https://www.codependentcodr.com/) mentioned that he is using a Makefile for his project and someone replied "I really hope you just say the word `Makefile` because of very old habit." 

I'm not against Makefiles, I use them at work and I started this project using one. For running a few quick commands, it's really simple. When I was writing my cleanup script I found that sometimes my docker container would die. Like I finish a post, walk away for <del>12+</del> 24+ hours and come back and the container is no longer running. So I want if container exists and running, kill container then remove, else if container exists, but not running, just remove, then carry on. I'm sure anyone who has used Make more than I have is thinking it's 3 lines of code to do what you want. And while I could spend some time learning Make more, I just don't want to right now. I want to re-do this in Python, see how much nicer, or more work it is.

My Makefile is currently sitting at 8 lines 21 words. * This is for just the clean function * After I stared writing my Python script I got curious about what the difference will be and figure it'll be nice to see lines/word count at random times throughout the process. After writing Part 1 I also decided to add how long each function takes to run just to see if there is any vast difference. 

``` bash
cat Makefile 
current_container = $(shell docker ps -af name=gnoinski -q)

clean:
	rm -rf output/*
ifneq ($(current_container),)
	docker kill $(current_container)
	docker rm $(current_container)
endif

---

wc Makefile 
  8  21 187 Makefile
```

### Requirements

* python3 (Most of this stuff will work in 2.7, I think)
* [python subprocess](https://docs.python.org/2/library/subprocess.html)
* [python argparse](https://docs.python.org/3/library/argparse.html)
* [python argpars.add_argument()](https://docs.python.org/3/library/argparse.html#argparse.ArgumentParser.add_argument)
    * ** added after my initial best laid plans **
* [python shutil](https://docs.python.org/2/library/shutil.html)
* [python os](https://docs.python.org/3/library/os.html)
* [python glob](https://docs.python.org/3.6/library/glob.html)
* [subprocess.check_output()](https://docs.python.org/2/library/subprocess.html#subprocess.check_output)

Give the above docs linked in the requirements a read if you haven't already and you'll be better off. Especially look at subprocess.call as it's what I'll be using to execute tasks. I am going to start off with a template of what I am going to do.

### Steps I'm going to cover

1. rewriting my clean function

### Let's roll

``` python
from subprocess import call
import argparse
import shutil

def clean():
    pass


def build():
    pass


def dev():
    pass


def upload():
    pass


def main():
    pass


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Replace your make file here.')
    parser.add_argument('--clean')
    parser.add_argument('--build')
    parser.add_argument('--dev')
    parser.add_argument('--upload')
    args = parser.parse_args()

    main()
```

```
 wc newmake.py 
 33  40 454 newmake.py
```

Ok my barebones script is 33 lines 40 words. 4.125 X more lines already, but let's see where this takes us.

Starting with the clean script I figured I would try use `call` to remove the files just as I did in the Makefile.

```
def clean():
    call(['rm', '-rf', 'output/*'])
```
Script ran, no error, and all files were left in the output folder. As I suspected [Stack Overflow](https://stackoverflow.com/questions/31977833/rm-all-files-under-a-directory-using-python-subprocess-call?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa) suggests not bothering with `call` for removing files in Python. Python has it's own way of removing files, why not use it? In comes `shutil`. [After reading the docs](https://docs.python.org/2/library/shutil.html), there is nothing in shutil that will do what I want as shutil.rmtree() "Delete an entire directory tree; path must point to a directory". I knew about [glob.glob('PATH')](https://docs.python.org/3.6/library/glob.html) for getting files in a folder but was hoping I was doing it the long way before. I will also use [os.remove(path, *, dir_fd=None)](https://docs.python.org/3/library/os.html#os.remove)


* Out with shutil in with glob and os.
```
from subprocess import call
import argparse
import glob
import os


def clean():
    print(glob.glob('output/*'))

...

def main():
    clean()

```

```
python3 newmake.py 
['output/setting-up-cloudfront-distribution.html', 'output/invalidating-cloudfront-cache.html', 'output/archives.html', 'output/category', 'output/author', 'output/updating-makefile-to-a-python-script.html', 'output/index.html', 'output/authors.html', 'output/uploading-my-new-site-to-s3.html', 'output/categories.html', 'output/set-up-acm-ssl-certs-and-domain-validation-with-route53.html', 'output/theme', 'output/final-thoughts-on-setting-up-my-site.html', 'output/how-this-site-came-to-be.html', 'output/tag', 'output/tags.html']
```

Much better I now have a list of files to delete. Let's put that together with `os.remove`.

```
def clean():
    output = glob.glob('output/*')
    for file_to_remove in output:
        os.remove(file_to_remove)

```

* <span style="color:blue">*Best practice* ~ in my for loop I didn't use `for file in` as file is a [builtin](https://stackoverflow.com/questions/24942358/is-file-a-keyword-in-python?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa) type returned by open() so generally best not to overwrite those. 

```
Traceback (most recent call last):
  File "newmake.py", line 38, in <module>
    main()
  File "newmake.py", line 27, in main
    clean()
  File "newmake.py", line 10, in clean
    os.remove(file_to_remove)
IsADirectoryError: [Errno 21] Is a directory: 'output/category'
```

Of course, one command only removes directories, one only removes files. Well let's try: something else in there.

```
def clean():
    output = glob.glob('output/*')
    for file_to_remove in output:
        try:
            os.remove(file_to_remove)
        except IsADirectoryError:
            os.rmdir(file_to_remove)
```

```
Traceback (most recent call last):
  File "newmake.py", line 11, in clean
    os.remove(file_to_remove)
IsADirectoryError: [Errno 21] Is a directory: 'output/category'

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "newmake.py", line 40, in <module>
    main()
  File "newmake.py", line 29, in main
    clean()
  File "newmake.py", line 13, in clean
    os.rmdir(file_to_remove)
OSError: [Errno 39] Directory not empty: 'output/category'
```

<span style="color:#054300">Ben you idiot, you just caused an exception while trying to handle an exception. Bravo!</span> Well fine then, I'll use shutil.rmtree() to remove the directories.

* Back in with shutil 
```
from subprocess import call
import argparse
import glob
import os
import shutil

def clean():
    output = glob.glob('output/*')
    for file_to_remove in output:
        try:
            os.remove(file_to_remove)
        except IsADirectoryError:
            shutil.rmtree(file_to_remove)
```

Sometimes it's a good idea to be aware of your surroundings. After I ran `python3 newmake.py` and received no errors I thought everything was working perfectly. I edited this file a bit, added some of my commentary. Then ran `ls output` just to marvel in my amazingness. only ALL. OF. MY. FILES. were still there. Then I realized I'm running my dev docker container that republishes my site locally on every article save. So when I made my edits, it just republished everything I had removed. Reran `python3 newmake.py` and everything was removed as I expected.

<span style="color:#054300">I realized that earlier I showed my updated clean function, but never showed that in main() I haven't built in any of the logic for argparse, so I'm just calling clean directly while testing. By the time you read this post it should hopefully be clear.</span>

Ok I've got it removing the output files, and had a thought. Maybe I should kill/remove any docker containers before removing the output. That way the files don't get re-published in the moments between removing the output and killing the container.

I am now using subprocess.call() in order to get a list of running docker containers.

```
def clean():
    container = call(['docker', 'ps', '-af', 'name=gnoinski', '-q'])

    print(container)
```

```
python3 newmake.py 
e84adae152df
0
```

Well shit the `container` variable is the return code, I need the actual output of the command to see if my container exists. I checked to see if the above would still return 0's if no containers exist and it does. So I need to find a way to capture the stdout. [Off to google/stack overflow](https://stackoverflow.com/questions/1996518/retrieving-the-output-of-subprocess-call/34873354?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa) It looks like [subprocess.check_output()](https://docs.python.org/2/library/subprocess.html#subprocess.check_output) Will do what I need and it returns [A byte string](https://stackoverflow.com/questions/6224052/what-is-the-difference-between-a-string-and-a-byte-string?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa) 

```
from subprocess import call, check_output

...

def clean():
    container = check_output(['docker', 'ps', '-af', 'name=gnoinski', '-q'])

    print(container)
```

```
python3 newmake.py 
b'da167755b713\n'
```

```
def clean():
    container = check_output(['docker', 'ps', '-af', 'name=gnoinski', '-q']).decode()
    print(container)
    if not container:
        pass
    else:
        print(call(['docker', 'kill', '%s' % container]))
```

```
5640d1463ba2

Error response from daemon: page not found
1
```


hmm maybe it's not liking the string formatting while building the argument string.

```
    else:
        command = ['docker', 'kill', container]
        print(command)
        print(call(command))
```

```
['docker', 'kill', '5640d1463ba2\n']
Error response from daemon: page not found
1
```

It has a newline at the end. Well we can strip that out easy enough. 

I did a little refactoring, Stripping the newline, made a list of docker commands to perform (kill, rm) and looped through them on the container. If the container isn't running Python runs the kill command spits the error to stdout and then continues on with the next commands, no worries. 

```
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
```

We are now at 52 lines 95 words 6.5 X the amount of lines in the original Makefile, and we aren't even close to done yet. Yeehaw.

Since I have both of these working I'm also interested in seeing how much time each take. I am going to run `make dev && time make clean` followed by `make dev && time python3 newmake.py` a few times and see what if any differences. 

** make clean **
```
rm -rf output/*
docker kill b30f88fadd5e
b30f88fadd5e
docker rm b30f88fadd5e
b30f88fadd5e

real	0m0.549s
user	0m0.236s
sys	0m0.046s

rm -rf output/*
docker kill 8b019f3e9aff
8b019f3e9aff
docker rm 8b019f3e9aff
8b019f3e9aff

real	0m0.569s
user	0m0.277s
sys	0m0.019s

rm -rf output/*
docker kill 54cc1bc83846
54cc1bc83846
docker rm 54cc1bc83846
54cc1bc83846

real	0m0.592s
user	0m0.261s
sys	0m0.027s

```

** python3 newmake.py **
```
kill a8c9f0efdfd2
a8c9f0efdfd2
rm a8c9f0efdfd2
a8c9f0efdfd2

real	0m0.535s
user	0m0.216s
sys	0m0.030s


kill 478ccdb94513
478ccdb94513
rm 478ccdb94513
478ccdb94513

real	0m0.512s
user	0m0.182s
sys	0m0.031s

kill a32df00b1b9f
a32df00b1b9f
rm a32df00b1b9f
a32df00b1b9f

real	0m0.529s
user	0m0.218s
sys	0m0.022s
```


## Part 1 Conclusion

<del><span style="color:#054300">Keep in mind my Makefile is complete at the time of this count. I may go back and strip it down to it's different parts to do a full complete comparison. Damn it now I need to do that just for my own peace of mind. I'll also have to ammend all of the time counts above. Well like most code 'fixes' I'll likely get around to that after all the other features are built. </span></del>

<del>Makefile 19 lines 68 words 586 bytes</del> <- pythons version of markdown [doesn't and won't](https://github.com/Python-Markdown/markdown/issues/221) support strike through so imagine this is striken through. But from reading the link I found the `<del> </del>` so I guess I'll use that. 

I went back and slimmed down the Makefile to just the clean function, and updated this article throughout. 

* Makefile 8 lines 21 words
* newmake.py 52 lines 95 words

6.5X Times more lines in python. 

So far between the 2 the Python has been a bunch more work to get going, but also a bit nicer not having to worry about the container being alive or dead when I try to remove it. Time wise they both run in approximately the same. 


I've been working on this for a couple of hours now, so... I guess I'll just make this part 1.

* [Part2 build run dev container](updating-makefile-to-a-python-script-build-run-dev-container.html)
* [Part3 upload to s3, argparse](updating-makefile-to-a-python-script-upload-to-s3-argparse.html)
* [Part4 Conclusion](updating-makefile-to-a-python-script-conclusion.html)
