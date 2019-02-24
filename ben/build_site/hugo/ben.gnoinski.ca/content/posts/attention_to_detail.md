---
title: "Attention To Detail"
date: 2019-02-22T19:14:05Z
categories:
  - Personal Skills
tags:
  - skills
  - attitude
---

I want to preface this article by saying I know that having a single server for an application is a horrible design, but that is not what this article is about. It's aboutf how paying attention to the small details may save you a lot of problems.

This evening I was working on an AWS instance that had run out of disk space. I thought to myself, I'll just increase the disk space no big deal I've done this before. And this mentality is where things started to go wrong. I got complacent in my comfort of the task at hand. Well that comfort led to downtime on the application. Luckily it wasn't peak time, and it ended up not being a big deal. But it was 37 minutes of downtime that makes me so angry at myself for letting happen, because I know better.

The process for expanding a disk is simple.

1. [Resize the Volume in AWS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-modify-volume.html)
1. Log onto the host
1. Confirm the new disk size has been picked up
1. Run fdisk on the specific drive
    1. Delete the existing partition
    1. Create a new partition
    1. Write changes to disk
1. Run partprobe if needed
1. Reboot **Only if new size not picked up by this point**
1. Resize the partition to use the full amount. 

This procedure can also be used on VMWare, and can be used on boot drives. That's right this process can resize the root partition of a host live! Hopefully without downtime unlike in my scenario.

So where did I go wrong?<br/>
Let's go through the steps and what I did one by one.
 
1. I resized from 25GB to 75GB in aws
1. Logged onto the host
1. Confirmed the new disk size had been picked up `fdisk -l`

    ```
Disk /dev/xvda: 80.5 GB, 80530636800 bytes
255 heads, 63 sectors/track, 9790 cylinders, total 157286400 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000
    Device Boot      Start         End      Blocks   Id  System
/dev/xvda1   *       16065    52420094    26202015   83  Linux
    ```
    Sure looks like it's been picked up to me.
1. Run fdisk on spcific drive `fdisk /dev/xvda`
    1. Delete Partition <code id="grey">Command (m for help):</code> `d` <br/>
        <code id="grey">Selected partition 1</code>
    1.  Create a new partition <br/>
        <code id="grey">Command (m for help):</code> `n`
        ```
        Partition type:
           p   primary (0 primary, 0 extended, 4 free)
           e   extended
        ```
        <code id="grey">Select (default p):</code>`p`<br/>
        <code id="grey">Partition number (1-4, default 1): </code>`{enter key}`#<- this was left blank to accept the default<br/>
        <code id="grey">Using default value 1</code><br/>
        <code id="grey">First sector (2048-157286399, default 2048):</code>`{enter key}`#<- this was left blank to accept the default<br/>
         ```
        Using default value 2048
        ```
        <code id="grey">Last sector, +sectors or +size{K,M,G} (2048-157286399, default 157286399):</code>`{enter key}`#<- this was left blank to accept the default<br/>
        ```
        Using default value 157286399
        ```

  1. Write changes to disk<br>
        <code id="grey">Command (m for help):</code> `w` <br/>
        ```
        The partition table has been altered!

        Calling ioctl() to re-read partition table.
        
        WARNING: Re-reading the partition table failed with error 16: Device or resource busy.
        The kernel still uses the old table. The new table will be used at
        the next reboot or after you run partprobe(8) or kpartx(8)
        Syncing disks.
        ```

1. From the output above I needed to run partprobe to pick up the changes. `partprobe`
  ```
  Error: Partition(s) 1 on /dev/xvda have been written, but we have been unable to inform the kernel of the change, probably because it/they are in use.  As a result, the old partition(s) will     remain in use.  You should reboot now before making further changes.
  ```
  It was at this point I felt that something was wrong, as I've never had to reboot with AWS in the past. But I didnt use better judgement and stop before rebooting.
1. Reboot if needed `shutdown -h now`

Since I had a bad feeling about this, I checked the instance screenshot as soon as I could and was met with the grub recovery screen. Yep, I knew something was wrong before I even rebooted, so while this spiked my stress and feeling of dread, it didn't't surprise me.

I spent the majority of the downtime restoring backups and getting the app running on a different server. After I had it up and running I was able to breath a bit and go back through what I had done and find where I went wrong. 

At this point I want you to take a minute and go back through everything I've shown so far and see if you can find where I went wrong.  

Scroll Down for the Solution
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
Keep scrolling
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>

### Solution

If you found out what the problem was great! If not, we need to pay close attention to the first sector number or <code class="highlight">start</code> as it shows in fdisk.

my `fdisk -l` shows the start sector is '16065' but the default start sector when you create a new partition is '2048'. Remebmer I just pressed `{enter key}` here to accept the default, which is what I have done dozens of times in the past, complacent in my comfort. When I did that I essentialy made the partition start sooner than it actually did which made the entire drive unreadable. Of course my system couldn't boot the data was not in the correct position. Now that I knew what the problem was, was I able to fix it? Yes.

In AWS you can detach volumes, including the root(if the system is turned off), from any system and attach it to another. I shutdown the broken server, detached the root volume, and attached it to a server I had that was running.

<span style="color:#054300"> *Info* - All of the previous output was pulled strait from the console, I unfortunately don't have the output from when I fixed the drive but so the following is a recreation of the events.</span><br/>

1. I logged into the host that I just attached the broken volume to
1. Ensure that the disk has been picked up `fdisk -l`<br/>

    ```
Disk /dev/xvdf: 80.5 GB, 80530636800 bytes
255 heads, 63 sectors/track, 9790 cylinders, total 157286400 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000
    Device Boot      Start         End      Blocks   Id  System
/dev/xvdf1   *       2048    157286399    78635167+   83  Linux
    ```
1. run fdisk on the specifed disk `fdisk /dev/xvdf`
    1. Delete Partition <code id="grey">Command (m for help):</code> `d` <br/>
        <code id="grey">Selected partition 1</code>
    1.  Create a new partition <br/>
        <code id="grey">Command (m for help):</code> `n`
        ```
        Partition type:
           p   primary (0 primary, 0 extended, 4 free)
           e   extended
        ```
        <code id="grey">Select (default p):</code>`p`<br/>
        <code id="grey">Partition number (1-4, default 1): </code>`{enter key}`#<- this was left blank to accept the default<br/>
        <code id="grey">Using default value 1</code><br/>
        <code id="grey">First sector (2048-157286399, default 2048):</code>`16065`#<- Set to the *ACTUAL* start<br/>
         ```
        Using value 16065
        ```
        <code id="grey">Last sector, +sectors or +size{K,M,G} (2048-157286399, default 157286399):</code>`{enter key}`#<- this was left blank to accept the default<br/>
        ```
        Using default value 157286399
        ```

  1. Write changes to disk<br>
        <code id="grey">Command (m for help):</code> `w` <br/>
        ```
        The partition table has been altered!

        Calling ioctl() to re-read partition table.
        Syncing disks.
        ```

Again I'm not 100% sure what the output was after writing the changes, but I know  it was similar to above and didn't require me to call partprobe to check the new disks.

To verify that the disk was working now, I mounted it to this system and was able run `ls` on the contents to verify it was all there.

We all make mistakes, and that is ok. If you are like me you will feel bad and useless regardless, it doesn't matter what anyone says. Even though I can't take my own advice, you shouldn't be to hard on yourself. It's a learning opportunity and you likely won't make this mistake again. It's ok to slow down a bit and double check what you are doing, *especially* if you don't have access to a peer review process, or if you get that feeling that something is not right. Trust it, **stop** and re-evaluate.

I intentially glossed over troubleshooting, as well as ways to architecht the system to remove the single point of failure to focus on the work I was doing and the issues that not paying attention to that small detail caused. I know that sometimes you have to learn by making the mistake yourself, but I hope this article showed that it's the small details that can really screw up your Friday night.