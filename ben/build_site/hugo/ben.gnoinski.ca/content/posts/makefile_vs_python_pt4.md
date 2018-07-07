---
title: Updating Makefile to a Python script - Conclusion
date: 2018-04-19T19:30:00Z
categories:
  - Utility
tags:
  - Editorial
---

* [Part1 Clean](updating-makefile-to-a-python-script-clean.html)
* [Part2 build run dev container](updating-makefile-to-a-python-script-build-run-dev-container.html)
* [Part3 upload to s3, argparse](updating-makefile-to-a-python-script-upload-to-s3-argparse.html)

```
wc Makefile 
 19  68 586 Makefile

wc newmake.py 
 57  149 1750 newmake.py
```

I went through the entire process of converting my Makefile to Python. After all of the effort while python was generally faster, no human would ever notice. It took 3X more code to accomplish the same things in Python as it did make. Maybe my code can be optimized, but I don't think much. 

As with everything in life there are pros and cons to both. And the pros of Make are the cons of Python and vice versa.

Make is very quick and simple to setup, Python took more effort.
Performing complex logic operations is easier in Python without a doubt.
Performance is a tie, unless you count disk space used.

I think I will likely end up using Python now that I have a template because of the ability to do complex logic. While I'm sure Make can be just as complex I haven't worked with it enough to be comfortable running complex if/else returns etc.. running `make SOMETHING` is pretty much muscle memory at this point, but I think that I can make the switch. I just might also trying re-writing this all in bash to see if it's any better.