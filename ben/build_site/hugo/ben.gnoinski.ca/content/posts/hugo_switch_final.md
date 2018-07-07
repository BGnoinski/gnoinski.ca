---
title: "Hugo Switch Conclusion"
date: 2018-07-07T17:11:05Z
draft: true
categories:
  - blog
tags:
  - hugo
---

## Conclusion

Part of dev/ops work is weighing time spent on a task vs gain. 

In this case the amount of time spent scripting some things could have been greater than the amount of time using a multiline editor or going through each post manually. 

The reason I thought that scripting updating links could be more work is because I have to find each link in my posts and then decide if it was an external link 'http{s}://' or an internal link 'stuff.html'. And there could be edge cases that I don't want modified. So with the time of creating a one time script + testing + verifying it would have been time I could be doing other things.

There will be people who say "You should have scripted it anyways." And to each their own, I didn't see the value in it for my particular use case. 

There are some things left over for me to do with Hugo, creating a Makefile or python script to make my dev and publishing easier. Since I already did that [on my Pelican site setup posts](/posts/site_setup_pt1/) and [Makefile to Python series](/posts/makefile_vs_python_pt1/) and my repo is public I am not going to go over it again. By the time you see this post this will be done ;).

I want to update the pygments for code highlighting as well as general theme tweaks. Going through the [Hugo Configuration](https://gohugo.io/getting-started/configuration/) should help me out a lot.