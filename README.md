What-Is-This
============
**What-Is-This (or wit) is a simple fast system information script written in perl, for linux.**

---
###Installation
#####Download
Run the following (assuming you have git)
```
git -b master https://github.com/KuroiLight/What-Is-This.git
```
#####Requirements
 - Perl 5 (tested on 5.10)
 - Linux proc and sys filesystems (for most functionality)
 
###### also recommended but optional
 - hostname, whoami and glxinfo binaries
 - Term::ANSIColor perl module.
 
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
![alt tag](https://raw.github.com/KuroiLight/What-Is-This/screns/main.png)
```
wit -l
```
![alt tag](https://raw.github.com/KuroiLight/What-Is-This/screns/extended.png)

#### Known issues
 - Display of ati/amd video card information is unknown (I dont have access to any of these cards)
 - Distro and Desktop Environment detection needs work, so it may not be correct at this time.

---
```
License: MIT
Email: kuroilight @ openmailbox.org
```