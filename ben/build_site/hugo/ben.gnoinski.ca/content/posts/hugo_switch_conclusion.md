---
title: "Switching From Pelican To Hugo - Conclusion"
date: 2018-07-07T17:11:05Z
categories:
  - blog
tags:
  - hugo
---

## Conclusion

All in all I have only started to scratch the Surface of Hugo, but so far it seems really awesome. There appears to be a whole bunch of built in functions for image manipulation, translations, [check them all out there](https://gohugo.io/functions/).

Within the metadata there is a 'draft:' key which when used without the hugo -D flag don't show up which I really like. I updated my site, and republished it without these switching to Hugo posts, as I wanted to review and edit them, as long as draft was true they didn't show up. 

Part of devops work is weighing time spent on a task vs gain. In this case the amount of time spent scripting some things could have been greater than the amount of time using a multiline editor or going through each post manually. 

The reason I thought that scripting updating links could be more work is because I have to find each link in my posts and then decide if it was an external link 'http{s}://' or an internal link 'stuff.html'. And there could be edge cases that I don't want modified. So with the time of creating a one time script + testing + verifying it would have been time I could be doing other things.

There will be people who say "You should have scripted it anyways." And to each their own, I didn't see the value in it for my particular use case. 

There are some things left over for me to do with Hugo, creating a <del>Makefile</del> or python script to make my dev and publishing easier. Since I already did that [on my Pelican site setup posts](/posts/site_setup_pt1/) and [Makefile to Python series](/posts/makefile_vs_python_pt1/) and my repo is public I am not going to go over it again. By the time you see this post this will be done ;).

I want to update the pygments for code highlighting as well as general theme tweaks. Going through the [Hugo Configuration](https://gohugo.io/getting-started/configuration/) should help me out a lot.

* [Switching From Pelican To Hugo - Pt1](/posts/hugo_switch_pt1/)
* [Switching From Pelican To Hugo - Pt2](/posts/hugo_switch_pt2/)
* [Switching From Pelican To Hugo - Pt3](/posts/hugo_switch_pt3/)