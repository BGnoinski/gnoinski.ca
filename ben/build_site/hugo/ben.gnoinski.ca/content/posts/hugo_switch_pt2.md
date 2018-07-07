---
title: "Switching From Pelican To Hugo - Pt2"
date: 2018-07-06T02:38:05Z
categories:
  - blog
tags: 
  - hugo
---

I have a bunch of posts for Pelican that I need to convert into Hugo syntax.
I could modify each file by hand... But no, just no, well maybe some parts. We'll use tools to make most of this happen.

### Steps I'm going to cover

1. <a href="#copyfiles">Copy Posts</a>
1. <a href="#postupdate">Script Post Update</a>
1. <a href="#updatemetadata">Update Metadata</a>


### Let's roll

**<p id="copyfiles">Copy Posts</p>**

This step is going to be quick. At a high level my file structure looks like:

```
├── build_site
│   ├── content
│   │   ├── awscli_setup.md
│   │   ├── create_iam_user.md
│   │   └── terraform_variables.md
├── hugo
│   ├── ben.gnoinski.ca
│   │   ├── archetypes
│   │   │   └── default.md
│   │   ├── config.toml
│   │   ├── content
│   │   │   └── posts
│   │   │       ├── awscli_setup.md
```

I used the command `tree` to get the folder structure like the above.

I just need to `cd build_site/content` and then run

`cp -r * ../../hugo/ben.gnoinski.ca/content/posts`

That's it files copied.

**<p id="postupdate">Script Post Update</p>**

Alright here is where the magic happens. I need to modify a few things in my files. First and foremost the file metatadata at the top needs to be converted to hugo format. 

Current Pelican meta data looks like:
```
Title: AWS cli setup
Date: 2018-04-29 14:25
Category: Utility
Tags: AWS, cli
```

I'm not sure if I can use Category or Tags with hugo, so I should figure that out before I continue so that I know if I have to remove it or not. [Hugo taxonomies](https://gohugo.io/content-management/taxonomies/) yep I sure can.

What it needs to look like

```
---
title: "Converting Pelican posts to Hugo"
date: 2018-07-06T02:38:05Z
draft: true
categories:
  - blog
tags: 
  - stuff
---
```

Also a lot of my files have 

```
** <p> Stuff here </p> **
```

For link anchors. Apparently the ** should not have any whitespace around it, woops. 

* <span style="color:#054300"> *Info* What I did so that I can quickly revert a post after running my code is simply run `git add POST.md` so that I can just do a `git checkout POST.md` and any changes I made will be reverted.</span>

So right away I need to change the case of the first few words to lower case. I am going to use `sed` to accomplish this.

```
sed -i 's|Title:|---\ntitle:|g' awscli_setup.md
sed -i 's|Date:|date:|g' awscli_setup.md
sed -i 's|Category:|categories:|g' awscli_setup.md
sed -i 's|Tags:|tags:|g' awscli_setup.md
```

I also snuck in adding --- at the top of the file. So I now need to add a --- after, I googled for 'sed insert at line in file' and this was the first result https://stackoverflow.com/questions/6537490/insert-a-line-at-specific-line-number-with-sed-or-awk

```
sed -i '6i---' awscli_setup.md
```

I did it this way to start with because I'm pretty sure my Pelican posts all have the same metadata. So the above 5 lines will get the starting --- and the ending ---

After running the above commands my metadata looks like:

```
---
title: AWS cli setup
date: 2018-04-29 14:25
categories: Utility
tags: AWS, cli
---
```

The categories and tags still need to be on their own lines.

I just came back from a walk and decided that I can put categories: and tags: on their own lines first, then insert the trailing --- on line 8.

```
sed -i 's|Title:|---\ntitle:|g' awscli_setup.md
sed -i 's|Date:|date:|g' awscli_setup.md
sed -i 's|Category:|categories:\n  -|g' awscli_setup.md
sed -i 's|Tags:|tags:\n  -|g' awscli_setup.md
sed -i '8i---' awscli_setup.md
```

Metadata now looks like:

```
---
title: AWS cli setup
date: 2018-04-29 14:25
categories:
  - Utility
tags:
  - AWS, cli
---
```


Now that I have the categories and tags on their own lines, I [found here](https://www.linuxquestions.org/questions/linux-newbie-8/sed-substitute-a-word-only-in-a-certain-line-786438/) that you can use sed on a specific line number like so

`sed -i '7 s|,|\n  -|g'`

Because my tags were , seprated before, this line will replace any , with a newline, 2 spaces, and a - to form my yaml list.

<span style="color:#054300"> *Info* I started making my list on the tags(line 7), as it will not change which line the categories are on (line5). Had I done the categories on line 5 first, the Tags may have started on line 8 instead of 7. </span>

`sed -i '5 s|,|\n  -|g'`

Can't forget the '** <' and '> **' updates that I need to do which don't have anything to do with the metadata, but since I'll be running this on all of the posts, I'll include it anyways. 

```
sed -i 's|Title:|---\ntitle:|g' awscli_setup.md
sed -i 's|Date:|date:|g' awscli_setup.md
sed -i 's|Category:|categories:\n  -|g' awscli_setup.md
sed -i 's|Tags:|tags:\n  -|g' awscli_setup.md
sed -i '8i---' awscli_setup.md
sed -i '7 s|,|\n  -|g' awscli_setup.md
sed -i '5 s|,|\n  -|g' awscli_setup.md
sed -i 's|> \*\*|>\*\*|g' awscli_setup.md
sed -i 's|\*\* <|\*\*<|g' awscli_setup.md
```

Metadata now looks like:

```
--
title: AWS cli setup
date: 2018-04-29 14:25
categories:
  - Utility
tags:
  - AWS
  - cli
---
```
Neat.

**<p id="updatemetadata">Update Metadata</p>**

Now that we have a way to update the information I need to update all of my posts. I could get all of the posts filenames and copy and paste the above sed lines for each file like I did on my awscli_setup.md example or I can build a script that takes a filename as an input, then dynamically find all of my posts and execute the script. 

So I am going to create a file called [update_posts.sh](https://github.com/BGnoinski/gnoinski.ca/blob/master/ben/scripts/hugo/update_posts.sh) and populate it as follows:

```
#!/bin/bash
sed -i 's|Title:|---\ntitle:|g' $1
sed -i 's|Date:|date:|g' $1
sed -i 's|Category:|categories:\n  -|g' $1
sed -i 's|Tags:|tags:\n  -|g' $1
sed -i '8i---' $1
sed -i '7 s|,|\n  -|g' $1
sed -i '5 s|,|\n  -|g' $1
sed -i 's|> \*\*|>\*\*|g' $1
sed -i 's|\*\* <|\*\*<|g' $1
```

Notice I have replaced awscli_setup.md with $1 because when I call this script I am going to pass it a file name as the first argument like so


`update_posts.sh awscli_setup.md`


But I still don't want to call each file individually. So I'll use find to run it for me.


`find . -name "*.md" -exec bash update_posts.sh {} \;`


And just like that all of my meta data has been updated.

Last thing I need to fix is the date format. Hopefully this won't be too hard but might have to jump into python. First lets figure out how to convert my date from the old to the new. I'm thinking the `date` command

2018-04-29 14:25

Needs to be

2018-04-29T07:25:00Z

I needed to know if I could input a date into `date` which [I can](https://unix.stackexchange.com/questions/107290/extract-date-from-a-variable-in-a-different-format)

DATE="2018-04-29 14:25"; date -d"$DATE" +%Y-%m-%dT%TZ

```
DATE="2018-04-29 14:25"; date -d"$DATE" +%Y-%m-%dT%TZ
2018-04-29T14:25:00Z
```

Ok, that looks correct. It's not the correct Zulu time as I'm currently -7 but I'm not too worried about the time and I can fix that later if I really want to. The time isn't currently shown on the posts, so it's likely only used for post ordering. 

I though about doing some clever regex to parse through all the files finding the date and modifying it, but it will likely take me longer to write that then to find all of the current dates in the files and quickly build a sed to fix them. So first I need to find all of the dates in my files. in comes grep. 

```
grep -Hrn date:
makefile_vs_python_pt1.md:3:date: 2018-04-09 16:30
terraform_variables.md:3:date: 2018-06-01 18:55
site_setup_pt5.md:3:date: 2018-04-06 17:30
create_iam_user.md:3:date: 2018-04-27 18:55
makefile_vs_python_pt2.md:3:date: 2018-04-10 16:30
terraform_interpolation.md:3:date: 2018-06-02 07:03
convert_posts_from_pelican.md:3:date: 2018-07-06T02:38:05Z
convert_posts_from_pelican.md:79:date: 2018-07-06T02:38:05Z
convert_posts_from_pelican.md:94:sed -i 's|Date:|date:|g' awscli_setup.md
convert_posts_from_pelican.md:112:date: 2018-04-29 14:25
convert_posts_from_pelican.md:124:sed -i 's|Date:|date:|g' awscli_setup.md
convert_posts_from_pelican.md:142:sed -i 's|Date:|date:|g' awscli_setup.md
convert_posts_from_pelican.md:161:sed -i 's|Date:|date:|g' $1
terraform_conditionals.md:3:date: 2018-06-14 19:46
site_setup_pt3.md:3:date: 2018-04-03 17:30
update_posts.sh:3:sed -i 's|Date:|date:|g' $1
site_setup_pt2.md:3:date: 2018-04-02 17:08
awscli_setup.md:3:date: 2018-04-29 14:25
terraform_loops.md:3:date: 2018-06-03 07:56
site_setup_pt1.md:3:date: 2018-04-01 18:39
my-first-post.md:3:date: 2018-07-05T03:33:05Z
my-first-post.md:210:date: 2018-07-05T03:33:05Z
TEMPLATE:3:date: 2018-07-05T03:33:05Z
site_setup_final.md:3:date: 2018-04-06 18:30
site_setup_pt4.md:3:date: 2018-04-05 17:30
pages/about.md:3:date: 2018-04-14 10:41
terraform_intro.md:3:date: 2018-05-29 19:25
makefile_vs_python_pt4.md:3:date: 2018-04-19 19:30
makefile_vs_python_pt3.md:3:date: 2018-04-11 16:30
```

I know that some of those files have dates I don't want to modify so I'll remove them and trim my list. Leaving me with:

```
makefile_vs_python_pt1.md:3:date: 2018-04-09 16:30
terraform_variables.md:3:date: 2018-06-01 18:55
site_setup_pt5.md:3:date: 2018-04-06 17:30
create_iam_user.md:3:date: 2018-04-27 18:55
makefile_vs_python_pt2.md:3:date: 2018-04-10 16:30
terraform_interpolation.md:3:date: 2018-06-02 07:03
convert_posts_from_pelican.md:112:date: 2018-04-29 14:25
terraform_conditionals.md:3:date: 2018-06-14 19:46
site_setup_pt3.md:3:date: 2018-04-03 17:30
site_setup_pt2.md:3:date: 2018-04-02 17:08
awscli_setup.md:3:date: 2018-04-29 14:25
terraform_loops.md:3:date: 2018-06-03 07:56
site_setup_pt1.md:3:date: 2018-04-01 18:39
site_setup_final.md:3:date: 2018-04-06 18:30
site_setup_pt4.md:3:date: 2018-04-05 17:30
pages/about.md:3:date: 2018-04-14 10:41
terraform_intro.md:3:date: 2018-05-29 19:25
makefile_vs_python_pt4.md:3:date: 2018-04-19 19:30
makefile_vs_python_pt3.md:3:date: 2018-04-11 16:30
```

So it looks like all of my dates are on line3 which will allow me to narrow down my find and replace. I first need to build a sed on a single file to make sure I have the command correct.

I think something like this should work:

sed "3 s|2018-04-29 14:25|$(DATE=2018-04-29 14:25; date -d"$DATE" +%Y-%m-%dT%TZ)|g" awscli_setup.md

Yeah that really didn't work because $() executes the result of the commands in () the command was not found so after a minor tweak we get:

NEWDATE=$(DATE="2018-04-29 14:25"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-04-29 14:25|$NEWDATE|g" awscli_setup.md

And this worked, now I am going to use the magic of my text editors multiline capability to write all of the needed sed commands. 


And we end up with this:

```
NEWDATE=$(DATE="2018-04-09 16:30"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-04-09 16:30|$NEWDATE|g" makefile_vs_python_pt1.md
NEWDATE=$(DATE="2018-06-01 18:55"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-06-01 18:55|$NEWDATE|g" terraform_variables.md
NEWDATE=$(DATE="2018-04-06 17:30"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-04-06 17:30|$NEWDATE|g" site_setup_pt5.md
NEWDATE=$(DATE="2018-04-27 18:55"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-04-27 18:55|$NEWDATE|g" create_iam_user.md
NEWDATE=$(DATE="2018-04-10 16:30"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-04-10 16:30|$NEWDATE|g" makefile_vs_python_pt2.md
NEWDATE=$(DATE="2018-06-02 07:03"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-06-02 07:03|$NEWDATE|g" terraform_interpolation.md
NEWDATE=$(DATE="2018-04-29 14:25"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-04-29 14:25|$NEWDATE|g" convert_posts_from_pelican.md
NEWDATE=$(DATE="2018-06-14 19:46"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-06-14 19:46|$NEWDATE|g" terraform_conditionals.md
NEWDATE=$(DATE="2018-04-03 17:30"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-04-03 17:30|$NEWDATE|g" site_setup_pt3.md
NEWDATE=$(DATE="2018-04-02 17:08"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-04-02 17:08|$NEWDATE|g" site_setup_pt2.md
NEWDATE=$(DATE="2018-04-29 14:25"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-04-29 14:25|$NEWDATE|g" awscli_setup.md
NEWDATE=$(DATE="2018-06-03 07:56"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-06-03 07:56|$NEWDATE|g" terraform_loops.md
NEWDATE=$(DATE="2018-04-01 18:39"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-04-01 18:39|$NEWDATE|g" site_setup_pt1.md
NEWDATE=$(DATE="2018-04-06 18:30"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-04-06 18:30|$NEWDATE|g" site_setup_final.md
NEWDATE=$(DATE="2018-04-05 17:30"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-04-05 17:30|$NEWDATE|g" site_setup_pt4.md
NEWDATE=$(DATE="2018-04-14 10:41"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-04-14 10:41|$NEWDATE|g" pages/ab
NEWDATE=$(DATE="2018-05-29 19:25"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-05-29 19:25|$NEWDATE|g" terraform_intro.md
NEWDATE=$(DATE="2018-04-19 19:30"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-04-19 19:30|$NEWDATE|g" makefile_vs_python_pt4.md
NEWDATE=$(DATE="2018-04-11 16:30"; date -d "$DATE" +%Y-%m-%dT%TZ); sed -i "3 s|2018-04-11 16:30|$NEWDATE|g" makefile_vs_python_pt3.md
```

And just like that all of my posts metadata have been updated. yay!

* [Switching From Pelican To Hugo - Pt1](/posts/hugo_switch_pt1/)
* [Switching From Pelican To Hugo - Pt3](/posts/hugo_switch_pt3/)
* [Switching From Pelican To Hugo - Conclusion](/posts/hugo_switch_conclusion/)