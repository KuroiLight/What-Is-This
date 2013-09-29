#!/usr/bin/perl
###
#   What Is This (wit) 
#   Simple Fast System Information
#   This file and its accompanying files are Licensed under the MIT License.
#   Written by: Kuroilight@openmailbox.org
###
use strict;
use warnings; #lemme get my orange vest.
##
# Dear reader,
#   Treading beyond this point invalidates any garantee
#  what so ever (that you thought you had)
#  that this code does anything remotely useful.
##
# Dear future maintainer,
#   Please direct any further edits to /dev/null
##

eval {
    require utf8;
    utf8->import();
};

my $wit_version = '0.43.0';

my @bins = (
'/usr/bin',
'/usr/sbin',
'/bin',
'/sbin',
'/usr/local/bin',
'/usr/local/sbin',
);

#untaint path
$ENV{'PATH'} = undef;
for my $ind (0..((scalar @bins) - 1)) {
    if(-e -d $bins[$ind]) {
        $ENV{'PATH'} .= ':' if($ind);
        $ENV{'PATH'} .= $bins[$ind];
    } else {
        splice @bins, $ind, 1;
    }
}


my $langs = 0;
my $colors = 1;
my $title_color = '';
my $subtitle_color = '';
my $value_color = '';

#==========================You have been warned, hazardous material ahead.
sub CommithForth ($) { #pass (cmd)
    foreach my $bin (@bins) {
        return 1 if(-e -r "$bin/$_[0]");
    }
    return 0;
}

sub OpenFile ($) { #pass (file)
    my $filename = $_[0]; my $filehandle;
    if(-e -r $filename) {
        open($filehandle, '<', $filename) or return undef;
        return $filehandle;
    }
    return undef;
}

sub ReadFile ($) { #pass (file)
    return do {
        local $/ = undef; my $contents = undef;
        if(my $handle = OpenFile($_[0])) {
            $contents = <$handle>;
            close($handle);
        }
        $contents;
    };
}

my $version_string = "What-Is-This (wit) version $wit_version.\n";
my @help_string = (
    'Help:  wit <options>',
    "\t-v,--version\t\tdisplay version and exit",
    "\t-h,--help\t\tdisplay this help and exit",
    "\t-l,--langs\t\tdisplay programming languages/editors",
    "\t-ac,--altcolors\t\tuses alternate color scheme",
    "\t-nc,--nocolors \t\tturns off colors completely"
);

sub Startup { #init code here
    foreach my $arg (@ARGV) {
        if($arg =~ /(-v|--version)/){
            print $version_string;
            exit 0;
        } elsif($arg =~ /(-h|--help)/){
            $" = "\n";
            print "$version_string@help_string\n";
            exit 0;
        } elsif($arg =~ /(-l|--langs)/){
            $langs = 1;
            next;
        } elsif($arg =~ /(-nc|--nocolors)/){
            $colors = 0;
            next;
        } elsif($arg =~ /-ac|--altcolors/){
            $colors = 2;
            next;
        } else {
            $" = "\n";
            print "Invalid option <$arg>\n@help_string\n";
            exit 1;
        }
    }
    $colors = 0 if(system('tput colors > /dev/null 2>&1'));
    if($colors) {
        if($colors == 1) {
            $title_color = "\033[1;33m";
            $subtitle_color = "\033[1;31m";
            $value_color = "\033[1;34m";
        } elsif ($colors == 2) {
            $title_color = "\033[2;33m";
            $subtitle_color = "\033[2;35m";
            $value_color = "\033[2;36m";
        }
    }
}

sub Cleanup {
    if ($colors) {
        print ("\033[0m");
    }
}
#==========================PROGRAM LISTS
my $re_version = eval { qr/((?:(?:[\d]){1,3}[\.]){1,3}(?:[\d]){1,3})/ };

my %LISTS = (
    # '3Tools' => [
    #     { name => 'awk',         versioncmd => 'awk --version' },
    #     { name => 'grep',        versioncmd => 'grep --version' },
    #     { name => 'sed',         versioncmd => 'sed --version' },
    # ],
    '0Shells' => [
        { name => 'Bash',        versioncmd => 'bash --version' },
        { name => 'Fish',        versioncmd => 'fish --version' },
        { name => 'Mksh',        versioncmd => 'mksh',
            altcmd => '' },
        { name => 'Tcsh',        versioncmd => 'tcsh --version' },
        { name => 'Zsh',         versioncmd => 'zsh --version' },
    ],
    '1Programming' => [
        { name => 'Falcon',      versioncmd => 'falcon -v' },
        { name => 'HaXe',        versioncmd => 'haxe -version' },
        { name => 'Io',          versioncmd => 'io --version',
            edgecase => eval { qr/(?:v\.[\s])([\d]+)/ }},
        { name => 'Lua',         versioncmd => 'lua -v' },
        { name => 'MoonScript',  versioncmd => 'moon -v' },
        { name => 'Neko',        versioncmd => 'neko' },
        { name => 'newLisp',     versioncmd => 'newlisp -v' },
        { name => 'Perl5',       versioncmd => 'perl --version' },
        { name => 'Perl6',       versioncmd => 'perl6 -v' },
        { name => 'Python2',     versioncmd => 'python2 --version' },
        { name => 'Python3',     versioncmd => 'python3 --version' },
        { name => 'Racket',      versioncmd => 'racket --version' },
        { name => 'Ruby',        versioncmd => 'ruby --version' },
        { name => 'Squirrel',    versioncmd => 'squirrel -v' },
        { name => 'Tcl',         versioncmd => 'tclsh',
            altcmd => "echo 'puts \$tcl_version;exit 0' | tclsh"},
                    #compilers
        { name => 'GNAT Ada',    versioncmd => 'gnat' },
        { name => 'Chicken',     versioncmd => 'chicken -version' },
        { name => 'GCC',         versioncmd => 'gcc --version' },
        { name => 'Haskell',     versioncmd => 'ghc -V' },
        { name => 'Guile',       versioncmd => 'guile -v' },
        { name => 'Rust',        versioncmd => 'rust --version' },
        { name => 'Vala',        versioncmd => 'valac --version' },
        { name => 'Ypsilon',     versioncmd => 'ypsilon --version' },
    ],
    '2Editors' => [
        { name => 'dex',         versioncmd => 'dex -V' }, #simply displays 'no-version' last I checked.
        { name => 'Diakonos',    versioncmd => 'diakonos --version' },
        { name => 'Emacs',       versioncmd => 'emacs --version' },
        { name => 'geany',       versioncmd => 'geany --version' },
        { name => 'gedit',       versioncmd => 'gedit --version' },
        { name => 'jed',         versioncmd => 'jed --version' },
        { name => 'Joe',         versioncmd => 'joe',
            altcmd => '' }, #no version option...
        { name => 'Kate',        versioncmd => 'kate --version',
            edgecase => eval { qr/(?:Kate:[\s])$re_version/ }},
        { name => 'Leafpad',     versioncmd => 'leafpad --version' },
        { name => 'medit',       versioncmd => 'medit --version' },
        { name => 'mousepad',    versioncmd => 'mousepad --version' },
        { name => 'nano',        versioncmd => 'nano --version' },
        { name => 'SublimeText 2', versioncmd => 'subl -v',
            edgecase => eval { qr/(?:[\d]?[\s\w]+)([\d]{4})/i } },
        { name => 'SublimeText 3', versioncmd => 'subl3 -v',
            edgecase => eval { qr/(?:[\d]?[\s\w]+)([\d]{4})/i } },
        { name => 'vi',          versioncmd => 'vi',
            altcmd => '' }, #can't get vi version info from cli switch, so just check if it exists.
        { name => 'Vim',         versioncmd => 'vim --version' },
    ],
);

sub PopulateLists { #REPLACE WITH ASYNC IPC MAYBE?
    foreach my $vals (keys %LISTS) {
        foreach my $elem ( @{$LISTS{$vals}}) {
            if(CommithForth((split /\ /, $elem->{versioncmd})[0])) {
                if(($elem->{altcmd} ? `$elem->{altcmd} 2>&1` : `$elem->{versioncmd} 2>&1`) =~ ($elem->{edgecase} ? $elem->{edgecase} : $re_version)) {
                    $elem->{version} = $1;
                } else {
                    $elem->{version} = 'unknown';
                }
            }
        }
    }
}
#==========================CPU INFORMATION
my $processor = {
    '1Vendor' => undef,
    '2Model' => undef,
    '3Details' => undef,
};

my @coremap = (
    'Single',
    'Dual',
    'Triple',
    'Quad',
    'Penta',
    'Hexa',
    'Hepta',
    'Octo',
    'Nona',
    'Deca',
    'Hendeca',
    'Dodeca',
    'Trideca',
    'Tetradeca',
    'Pentadeca',
    'Hexadeca',
);

my $re_cpu = eval { qr/[\s\:]+(.+)/ };
my $re_intelghz = eval { qr/\ \@.+/ };

sub GetCPUInfo { #still a mess...
    if(my $buffer = ReadFile('/proc/cpuinfo')) {
        $processor->{'1Vendor'} = $1 if($buffer =~ qr/vendor_id$re_cpu/m);
        $processor->{'2Model'} = $1 if ($buffer =~ qr/model name$re_cpu/m);
        $processor->{'2Model'} =~ s/(?:$re_intelghz)//;
        
        my $freq = ''; my $hypsterthreads = '';
        my $cores = ( ($buffer =~ qr/cpu cores$re_cpu/m) and $1 or ()= ($buffer =~ /processor$re_cpu/g) );
        if($cores) {
            if($buffer =~ qr/siblings$re_cpu/m){
                my $threads = $1;
                $hypsterthreads = (($1 / $cores) == 2 ? 'with HyperThreading' : '');
            }
            if($coremap[$cores-1]) {
                $cores = "$coremap[$cores-1]-Core";
            } else {
                $cores = "$cores-Core";
            }
        }

        if(my $limitbreak = ReadFile('/sys/bus/cpu/devices/cpu0/cpufreq/bios_limit')) {
            $freq = $limitbreak / 1000000;
        } elsif ($buffer =~ qr/cpu MHz$re_cpu/m) {
            $freq = $1 / 1000;
        }

        if($freq) {
            $freq = sprintf('%0.2f', $freq);
            $freq = ($cores ? '@' : '') . "${freq}GHz";
        }

        $processor->{'3Details'} = "$cores $freq $hypsterthreads";
        
    }
}
#==========================MOTHERBOARD
my $motherboard = {
    '1Vendor' => undef,
    '2Board' => undef,
    '3Bios' => undef,
};

my $re_anyword = eval { qr/(.+)/ };

sub GetMoboInfo {
    my $buffer = ReadFile('/sys/class/dmi/id/board_vendor');
    if($buffer) {
        $motherboard->{'1Vendor'} = $1 if($buffer =~ /$re_anyword/);
        undef $buffer;
    }
    $buffer = ReadFile('/sys/class/dmi/id/board_name');
    if($buffer) {
        $motherboard->{'2Board'} = $1 if($buffer =~ /$re_anyword/);
        undef $buffer;
    }
    $buffer = ReadFile('/sys/class/dmi/id/bios_vendor');
    if($buffer) {
        $motherboard->{'3Bios'} = $1 if($buffer =~ /$re_anyword/);
        undef $buffer;
    }
    $buffer = ReadFile('/sys/class/dmi/id/bios_version');
    if($buffer) {
        $motherboard->{'3Bios'} = "$motherboard->{'3Bios'} ($1)" if($buffer =~ /$re_anyword/);
        undef $buffer;
    }
}
#==========================OPERATING SYSTEM
#WM List originally generated with regex, from the list in screenfetch, Though I'm adding new/old ones not included.
# #=depracated; #+=added
my %wm_list = (
    'afterstep'     =>      'AfterStep',         #+
    'awesome'       =>        'Awesome',             
    'beryl'         =>          'Beryl',                #
    'blackbox'      =>       'Blackbox',          #
    'cinnamon'      =>       'Cinnamon',           
    'cwm'           =>         'CalmWM',                  #+
    'compiz'        =>         'Compiz',               
    'dminiwm'       =>        'dminiwm',             
    'dwm'           =>            'DWM',                    #
    'e16'           =>            'E16',                    #
    'emerald'       =>        'Emerald',            #
    'enlightenment' =>            'E17',           
    'fluxbox'       =>        'FluxBox',             
    'fvwm'          =>           'FVWM',                   
    'herbstluftwm'  =>   'herbstluftwm',   
    'icewm'         =>          'IceWM',                 
    'jwm'           =>            'JWM',                     #+
    'kwin'          =>           'KWin',                   
    'metacity'      =>       'Metacity',           
    'monsterwm'     =>      'monsterwm',         
    'musca'         =>          'Musca',                 
    'mutter'        =>         'Mutter',               #+
    'openbox'       =>        'OpenBox',             
    'pekwm'         =>          'PekWM',                 
    'ratpoison'     =>      'Ratpoison',         
    'sawfish'       =>        'Sawfish',             
    'scrotwm'       =>        'ScrotWM',            #
    'spectrwm'      =>       'SpectrWM',           
    'stumpwm'       =>        'StumpWM',            #
    #twm                                #
    'subtle'        =>         'subtle',               
    'wmaker'        =>    'WindowMaker',          
    'wmfs'          =>           'WMFS',                   
    'wmii'          =>           'wmii',                  #
    'xfwm4'         =>          'Xfwm4',                 
    'xmonad'        =>         'XMonad',               
    'i3'            =>             'i3',                       
);

my %desktops = (
    'xfce4' => 'Xfce4',
    'mate' => 'Mate',
    'kde' => 'KDE',
    'gnome' => 'GNOME',
    'cinnamon' => 'Cinnamon',
    'lx' => 'LXDE',
);

my $os = {
    '1Distro' => undef,
    '2Kernel' => undef,
    '3User@Host' => undef,
    '4WM/DE' => undef,
    '5Packages' => undef,
};

sub GetOSInfo {
    if(my $buffer = ReadFile('/proc/version')) {
        $os->{'2Kernel'} = "$1 $2" if($buffer =~ qr/([\w]+)[\s]+version[\s]+$re_version/i);
    }
    
    if(not ($os->{'3User@Host'} = $ENV{'USER'})) {
        if(CommithForth('whoami')) {
            $os->{'3User@Host'} = $1 if(`whoami` =~ $re_anyword);
        }
    }

    if(my $buffer = ReadFile('/proc/sys/kernel/hostname')) { #much faster
        $os->{'3User@Host'} .= "\@$1" if($buffer =~ $re_anyword);
    } elsif(CommithForth('hostname')) {
        $os->{'3User@Host'} .= "\@$1" if(`hostname` =~ $re_anyword);
    }
    
    if(my $buffer = (ReadFile('/etc/lsb-release') or ReadFile('/etc/os-release'))) {
        if ($buffer =~ qr/^DISTRIB_ID=(.+)/m) {
            $os->{'1Distro'} = $1;
            $os->{'1Distro'} .= " $1" if($buffer =~ qr/^DISTRIB_RELEASE=(.+)/m);
            $os->{'1Distro'} .= " $1" if($buffer =~ qr/^DISTRIB_CODENAME=(.+)/m);
        }
    } elsif ($buffer = ReadFile('/etc/os-release')) {
        $os->{'1Distro'} = "$1" if ($buffer =~ qr/NAME=\"$re_anyword\"/m);
    } elsif ($buffer = ReadFile('/etc/debian_version')) {
        $os->{'1Distro'} = "Debian $1" if ($buffer =~ qr/re_anyword/m);
    } elsif(my $osfile = (grep /[\w]+[\-\_](?:version|release)/, `ls -1 /etc/* 2>/dev/null`)[0]) { # works just about everywhere else
        $osfile =~ s/[\n]//;
        if (my $buffer = ReadFile($osfile)) {
            $os->{'1Distro'} = $1 if ($buffer =~ qr/(.+)/m);
        }
    }

    my @packages = 0;
    if(CommithForth('pacman')) { #Good ol' Arch (tested)
        @packages = (`pacman -Qq`);
    } elsif(-e -d '/var/db/pkg/') { #Gentoo (untested)
        @packages = (`ls -d -1 /var/db/pkg/*/*`);
    } elsif (CommithForth('dpkg')) { #Ubuntu (tested)
        @packages = (grep (/ii/, `dpkg -l 2>&1`));
    } elsif (-e -d '/var/log/packages') { #Debian (tested)
        @packages = (`ls -1 /var/log/packages`);
    } elsif(CommithForth('rpm')) { #Suse/RedHat (untested will test later)
        @packages = (`rpm -qa`);
    } #elsif(CommithForth('pkg_info')) { #BSD (untested maybe later)
#         @packages = (`pkg_info`);
#     }
    $os->{'5Packages'} = scalar @packages;
    undef @packages;
    
    if(my @plist = `ps axco command`) {
        my $WM; my $DE;
        foreach my $wm (keys %wm_list) {
            if(grep(/$wm/, @plist)) {
                $WM = $wm_list{$wm};
                last;
            }
        }
        foreach my $de (keys %desktops) {
            if(grep(/$de[\-\_]session/, @plist)) {
                $DE = $desktops{$de};
                last;
            }
        }
        $os->{'4WM/DE'} = (($WM and $DE) ? "$WM/$DE" : $WM or $DE);
    }
}

#==========================MEMORY INFORMATION
my $memory = {
    '1Ram' => undef,
    '2Swap' => undef,
};

my $re_number = eval { qr/[\s]*([\d]+)/ };

sub GetMemInfo {
    if(my $buffer = ReadFile('/proc/meminfo')) {
        my $ram_total; my $swap_total;
        my $ram_used; my $swap_used;

        if($buffer =~ qr/MemTotal:$re_number/m) {
            $ram_used = $ram_total = $1;
            $ram_used -= $1 if($buffer =~ qr/^Buffers:$re_number/m);
            $ram_used -= $1 if($buffer =~ qr/^Cached:$re_number/m);
            $ram_used -= $1 if($buffer =~ qr/^MemFree:$re_number/m);
            $ram_used = int($ram_used / 1024);
            $ram_total = int($ram_total / 1024);
            $memory->{'1Ram'} = "${ram_used}M/${ram_total}M";
        }

        if($buffer =~ qr/SwapTotal:$re_number/m) {
            $swap_used = $swap_total = $1;
            $swap_used -= $1 if($buffer =~ qr/^SwapCached:$re_number/m);
            $swap_used -= $1 if($buffer =~ qr/^SwapFree:$re_number/m);
            $swap_total = int($swap_total / 1024);
            $swap_used = int($swap_used / 1024);
            $memory->{'2Swap'} = "${swap_used}M/${swap_total}M";
        }
    }
}
#==========================GPU INFORMATION (INCOMPLETE)

my $gpu = {
    '1Vendor' => undef,
    '2Model' => undef,
    '3Driver' => undef,
};

my %re_vid = (
    amd => eval { qr/(fglrx|r(?:adeon(?:si)?|[\d]{3}(?:g)?))/i },
    nvidia => eval { qr/(nvidia|nouveau)/i },
    intel => eval { qr/(intel)/i },
    vbox => eval { qr/(vboxvideo)/i },
);

sub GetGPUInfo { #WILL NEED MORE DRIVER INFORMATION TO FINISH
    if(my $buffer = ReadFile('/proc/modules')) {
        if($buffer =~ /^(drm.+live.+)$/im) {
            my $drm = $1;
            if($drm =~ /$re_vid{nvidia}/) { #NVIDIA
                $gpu->{'1Vendor'} = 'NVIDIA'; $drm = $1;
                if($drm eq 'nouveau') {
                    $gpu->{'3Driver'} = 'OpenSource (nouveau)';
                } elsif($drm eq 'nvidia') {
                    $gpu->{'3Driver'} = 'Proprietary';
                    if(my $contents = ReadFile('/proc/driver/nvidia/gpus/0/information')) { #delve further
                        $gpu->{'2Model'} = $1 if ($contents =~ /Model:[\.\s]+(.+)/);
                        my $dvers = $1 if ( (ReadFile '/proc/driver/nvidia/version') =~ /Module[\s]+$re_version[\s]/);
                        $gpu->{'3Driver'} .= " ($dvers)";
                    }
                }
            } elsif($drm =~ /$re_vid{amd}/) { #AMD/ATI
                $gpu->{'1Vendor'} = 'AMD'; $drm = $1;
                if($drm =~ /(r(?:adeon|[\d]{3}(?:g)?))/) {
                    $gpu->{'3Driver'} = 'OpenSource ($1)';
                } elsif($drm eq 'fglrx') {
                    $gpu->{'3Driver'} = 'Proprietary'; #add search for amd data
                }
            } elsif($drm =~ /$re_vid{intel}/) { #Intel
                $gpu->{'1Vendor'} = 'Intel';
            } elsif($drm =~ /$re_vid{vbox}/) { #vbox
                $gpu->{'1Vendor'} = 'VirtualBox';
                $gpu->{'3Driver'} = 'vboxvideo';
            }
        }
    }
}

#==========================((length($_[0]) >= 16) ? '' : ((length($_[0]) >= 8) ? '' : "\t"))
sub PrintEntry ($$) {
    if($_[1]) {
        my $ws = "\t" x int((16 - length($_[0])) / 9);
        print "\t${subtitle_color}${_[0]}\t${ws}${value_color}${_[1]}\n";
    }
}

sub PrintList ($) {
    my $list = $_[0]; my $count = 0;
    foreach my $elem (@{$list}) {
        if($elem->{version}) {
            PrintEntry($elem->{name}, $elem->{version});
        }
    }
}

sub HasContents ($) {
    my $count = 0;
    foreach my $elem (values %{$_[0]}) {
        if($elem) { $count++; }
    }
    return $count;
}

my $re_nosortnum = eval { qr/[\d]?(.+)/ };

sub PrintHashes {
    for my $vals (sort keys %LISTS) {
        $vals =~ /$re_nosortnum/;
        print "${title_color}$1-\n";
        PrintList($LISTS{$vals});
    }
}

sub PrintHashTable ($$) {
    if(HasContents($_[0])) {
        print "${title_color}${_[1]}\n";
        for my $tkey (sort keys %{$_[0]}) {     #using numbers to sort a hash is a dirty hack, but its the only thing I 
            $tkey =~ /$re_nosortnum/;            # could come up with to maintain order, without writing garbage.
            PrintEntry($1, $_[0]{$tkey});
        }
    }
}
#==========================WRITE OUTPUT/MAIN
Startup();
PopulateLists() if($langs);
GetCPUInfo();
GetMemInfo();
GetOSInfo();
GetMoboInfo();
GetGPUInfo();

PrintHashTable($os, 'Operating System');
PrintHashTable($motherboard, 'Motherboard');
PrintHashTable($processor, 'Processor');
PrintHashTable($gpu, 'Video Card');
PrintHashTable($memory, 'Memory');

PrintHashes() if($langs);

Cleanup();
