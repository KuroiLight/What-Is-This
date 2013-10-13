What-Is-This
============
**What-Is-This (or wit) is a simple fast system information script written in perl, for linux.**

---
###Installation
#####Download
Run the following (assuming you have git)
```
git -b dev https://github.com/KuroiLight/What-Is-This.git
```
#####Requirements
 - Perl 5 (tested on 5.10)
 - Linux procfs/sysfs
 
#####Create a symbolic link & make it executable
Run the following commands in the wit directory (with sudo/root if needed)
```
ln -f -r -s ./wit.pl /usr/bin/wit
chmod +x ./wit.pl
```

---
#### Current Features/Preview
```
wit
```
![alt tag](https://raw.github.com/KuroiLight/What-Is-This/screns/0.43prev.png)

#### Known issues
 - video card display needs a little more work.

---
```
License: MIT
Email: kuroilight @ openmailbox.org
```