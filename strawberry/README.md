# Strawberry Android Kernel for i9300

Android kernel for the Samsung Galaxy S3 international (i9300).

## Purpose and Motivation

The original i9300 Android kernel released by Samsung is based on the
3.0.x Linux kernel branch, and all other kernels working for that
device seem to be based on that Samsung kernel, and stuck to 3.0.x as well.
You can find the LineageOS kernel here:

https://github.com/LineageOS/android_kernel_samsung_smdk4412

According to its Makefile, this is sort of Linux 3.0.101.
Such an old folk comes with all sorts of annoyances.
Here is one: It is not possible to run Debian 9 (Stretch)
in a chroot environment because its glibc version requires
at least a 3.2 kernel, while Debian 8 (Jessie) works.
See

https://www.debian.org

https://github.com/groegerj/LNL

It should be possible to backport the Debian 9 core packages
such as to support Linux 3.0. Of course, the better way is to
upgrade the i9300 kernel to at least 3.2, and here we go.

## Difficulties and Related Work

For various reasons, upgrading some Android kernel is far from trivial.
This is very well explained by Wolfgang Wiedmeyer:

https://blog.fossencdi.org/newer-kernel-galaxys3.html

In fact, Wolfgang has been working on that for a while.
His first attempt was to make a partial merge with 3.2.x, but he ended up
with something unmaintainable.
Recently, he has worked on starting with a recent Linux kernel,
and patch it until it works on the device.

https://code.fossencdi.org/kernel_i9300_mainline.git

In fact, most of the general Android as well as i9300 stuff has been
included in one or another way in the mainline Linux kernel until today,
and so that strategy has a chance of becoming successful.
I wish Wolfgang all the best.

## Strategy and Status

Wolfgang explains why merging is bad. He is completely right on this.
But I started doing it anyway, and I still think with some effort it can be done.
Here is my plan. After every change I make, I test a few things:

*  The kernel still compiles.
*  Android boots.
*  Playing a video works.
*  Loading a website via wireless network works.

Things still can break, but this way I at least ensure that the basic system always works.

### Step 0: Starting with the LineageOS SMDK Kernel

I started with the LineageOS i9300 kernel mentioned above. It claims to be 3.0.101, so it
is worth comparing it with the original Linux 3.0.101 kernel, which is available here.

https://www.kernel.org/pub/linux/kernel/v3.0

For brevity, let us call Linux 3.0.101 "mainline" (even though this is bad terminology),
and the LineageOS kernel "smdk".

Playing around with grep, I learned that there are 2190 items that are either only
in mainline or different from smdk.
Here, an item is either a single file or a directory appearing in smdk but not in mainline
or vice versa (that case is very rare however).
I did not spend more effort to count more precisely. In particular, this completely misses the
different names arch/arm/mach-exynos in smdk and arch/arm/mach-exynos4 in mainline, which
are (quite) different versions of the same directory containing some 100 files.
Nevertheless, that number 2190 should give you some idea.

Now, of the things which are different, there are different sort os being different.
smdk contains drivers and stuff not only for the i9300 but for many different Samsung
devices. Then drivers, but also core code, is a mixture of versions. There is stuff
very close to mainline-3.0.101, other stuff 3.1-ish but also code backported, patched
and fried from mainline-upto-3.4. Then of course general Android stuff, much of which
has been mainlined starting from mainline-3.3.

### Step 1: mainlining-3.0.101

Upgrading stuff with changing kernel APIs is not an automatic task so, for simplicity,
I keep deleting (respectively replacing by mainline version) everyting not needed for i9300.
This is already a lot, and not too difficult. Then there is code that is already close to
mainline-3.0.101. Sometimes, this contains an essential patch not in mainline, but really
needed. More often, the respective subsystem just has a version which matches mainline-3.0.101
not exactly but comes from a stage between 3.0.101 and 3.1, for example. Or, the Samsung
guys have added some optimisation of security fix or whatever. In such a case, I replace
that smdk stuff with mainline. Step 1 is almost finished by now.

### Step 2: mainlining-3.1

A very important partial goal is to upgrade to 3.1 with the least possible differences to
mainline-3.1. Notice that I keep speaking of "mainline-3.0.101" which is not quite correct.
The mainline Linux kernel branch

https://github.com/torvalds/linux

contains 3.0, 3.1, 3.2 etc., but the minor stable versions such as 3.0.x are not found
here. Instead, e.g. for 3.0, there is a new branch, called "stable", which contains
3.0.1 up to 3.0.101. That is to say, there is not direct way (in the sense of git history)
from 3.0.101 to 3.1. However, it is clear that the path from 3.0.101 to 3.1 is much easier
than the path from 3.0.101 directly to 3.2 (or even later).
This is why, after having mainlined as much code to 3.0.101, I started mainlining as
much as possible to 3.1. Sometimes entire files can be replaced by mainline-3.1 versions,
but often, there are side effects, and API changes etc. have to be taken into account.

By now, I could mainline the whole network stack to 3.1, and parts of fs/, kernel/ and more.
Compared with the original number 2190 of different items, the number of items different
from either mainline-3.0.101 or mainline-3.1 could be cut down to about half.
Step 2 is still work in progress, but I work hard to reduct the differences with mainline-3.1
to a minimum.

### Step 3: further upgrade

Starting from "i9300-version3.1", I expect it to be much easier to upgrade to 3.2 than
it was to come to 3.1. The number of differences to mainline has been cut down a lot,
and from 3.1 to 3.2, it will be much easier to merge the git commit history (even though
an automatic merge will for sure also not work there).

