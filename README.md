What-Is-This
============
**What-Is-This (or wit) is a simple fast system information script written in perl, for linux.**

*sample screenshot-*

![alt tag](https://raw.github.com/KuroiLight/What-Is-This/master/latest_screenshot.png)

It is very much a work in progress, and needs bug reports and portability testing.

### Update+
LongStory:
complete merge of wia to wit, so its easier to manage;

TLDR: do 'wit -l' to get the same functionality.

####Update+1
Reached 500 lines!

Added rough WM/DE info.

##### Feature Progress
 - [x] distro and kernel
 - [x] processor
 - [x] memory
 - [x] currently installed shells and their versions
 - [x] currently installed interpreters/scripting languages (e.g. lua, perl...)
 - [/] add more shells/interpreters
 - [/] add gpu info *[wip]*
 - [X] add mobo info
 - [x] add proper cmd line switches
 - [_] add terminal color detection
 - [x] add package counting

##### Requirements
 - perl5 obviously (tested on version 5.10-5.18)
 - some sysfs files
 - linux flavored procfs
 - whoami(optional) and hostname


```
License: MIT
Email: kuroilight @ openmailbox.org
```