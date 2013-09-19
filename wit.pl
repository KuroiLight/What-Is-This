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


my $wit_version = '0.42.2';

my @bins = sort 
'/usr/local/bin',
'/usr/bin/',
'/bin',
'/usr/local/sbin',
'/usr/sbin',
'/sbin',
;

#untaint path
$ENV{'PATH'} = undef;
{
    my $index = 0;
    while ($index <= $#bins) {
        my $b = $bins[$index];
        if (-e -d $b) {
            $ENV{'PATH'} .= (($index ? ':' : '') . "$b");
            $index++;
        } else {
            splice @bins, $index, 1;
        }
    }
}

#print "You should upgrade perl, as you'll probably have problems running this script on anything under version 5.12\n\n" if ($] < 5.012);

my $langs = 0;
my $colors = 1;
my $title_color = '';
my $subtitle_color = '';
my $value_color = '';

#==========================You have been warned, hazardous material ahead.
sub CommithForth ($) { #pass (cmd)
    foreach my $bin (@bins) {
        return 1 if(-e "$bin/$_[0]");
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
        local $/ = undef;
        my $handle = OpenFile($_[0]);
        return ($handle ? scalar <$handle> : undef);
    };
}

sub FirstMatch ($$) { #pass (target string, pattern with grouping)
    return ($_[0] =~ $_[1] ? $1 : undef);
}

sub Startup { #init code here
    foreach my $arg (@ARGV) {
        if($arg =~ /(-v|--version)/){
            print "What-Is-This (wit) version $wit_version.\n";
            exit 0;
        } elsif($arg =~ /(-h|--help)/){
            print "What-Is-This (wit) version $wit_version.\n";
            print "Help:\n  wit <options>";
            print "\n\t-v,--version\t\tdisplay version and exit";
            print "\n\t-h,--help\t\tdisplay this help and exit";
            print "\n\t-l,--langs\t\tdisplay programming languages/editors";
            print "\n\t-ac,--altcolors\t\tuses alternate color scheme";
            print "\n\t-nc,--nocolors \t\tturns off colors completely\n";
            exit 0;
        } elsif($arg =~ /(-i|--install)/){ #start hackish code:
            my $abs_path = $ENV{'PWD'};
            print((not (-e ($abs_path . '/setup_bashrc.pl')) and "setup script missing...\n")
            or ((not system('perl ' . $abs_path . '/setup_bashrc.pl -i')) or "setup failed\n")); #extra parenthesis help get the point across
            exit 0;
        } elsif($arg =~ /(-u|--uninstall)/){
            my $abs_path = $ENV{'PWD'};
            print((not (-e ($abs_path . '/setup_bashrc.pl')) and "setup script missing...\n")
            or ((not system('perl ' . $abs_path . '/setup_bashrc.pl -u')) or "setup failed\n"));
            exit 0;                         #end hackish code:
        } elsif($arg =~ /(-l|--langs)/){
            $langs = 1;
        } elsif($arg =~ /(-nc|--nocolors)/){
            $colors = 0;
        } elsif($arg =~ /-ac|--altcolors/){
            $colors = 2;
        } else {
            print "Invalid option $arg\n";
            exit 1;
        }
    }
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
#my $re_version = eval { qr/((?:(?:[\d]+)\.)+[\d]+)/im };
my $re_version = qr/((?:(?:[\d]){1,3}[\.]){1,3}(?:[\d]){1,3})/;

my %LISTS = (
    '3Tools' => [
        { name => 'awk',         versioncmd => 'awk --version',        version => undef },
        { name => 'grep',        versioncmd => 'grep --version',       version => undef },
        { name => 'sed',         versioncmd => 'sed --version',        version => undef },
    ],
    '0Shells' => [
        { name => 'Bash',        versioncmd => 'bash --version',       version => undef },
        { name => 'Fish',        versioncmd => 'fish --version',       version => undef },
        { name => 'Mksh',        versioncmd => 'mksh',                 version => undef,
            altcmd => '' },
        { name => 'Tcsh',        versioncmd => 'tcsh --version',       version => undef },
        { name => 'Zsh',         versioncmd => 'zsh --version',        version => undef },
    ],
    '1Programming' => [
        { name => 'Falcon',      versioncmd => 'falcon -v',            version => undef },
        { name => 'HaXe',        versioncmd => 'haxe -version',        version => undef },
        { name => 'Io',          versioncmd => 'io --version',         version => undef,
            edgecase => eval { qr/(?:v\.[\s])([\d]+)/ }},
        { name => 'Lua',         versioncmd => 'lua -v',               version => undef },
        { name => 'MoonScript',  versioncmd => 'moon -v',              version => undef },
        { name => 'Neko',        versioncmd => 'neko',                 version => undef },
        { name => 'newLisp',     versioncmd => 'newlisp -v',           version => undef },
        { name => 'Perl5',       versioncmd => 'perl --version',       version => undef },
        { name => 'Perl6',       versioncmd => 'perl6 -v',             version => undef },
        { name => 'Python2',     versioncmd => 'python2 --version',    version => undef },
        { name => 'Python3',     versioncmd => 'python3 --version',    version => undef },
        { name => 'Racket',      versioncmd => 'racket --version',     version => undef },
        { name => 'Ruby',        versioncmd => 'ruby --version',       version => undef },
        { name => 'Squirrel',    versioncmd => 'squirrel -v',          version => undef },
        { name => 'Tcl',         versioncmd => 'tclsh',                version => undef,
            altcmd => "echo 'puts \$tcl_version;exit 0' | tclsh"},
                    #compilers
        { name => 'GNAT Ada',    versioncmd => 'gnat',                 version => undef },
        { name => 'Chicken',     versioncmd => 'chicken -version',     version => undef },
        { name => 'GCC',         versioncmd => 'gcc --version',        version => undef },
        { name => 'Guile',       versioncmd => 'guile -v',             version => undef },
        { name => 'Rust',        versioncmd => 'rust --version',       version => undef },
        { name => 'Vala',        versioncmd => 'valac --version',      version => undef },
        { name => 'Ypsilon',     versioncmd => 'ypsilon --version',    version => undef },
    ],
    '2Editors' => [
        { name => 'dex',         versioncmd => 'dex -V',               version => undef }, #simply displays 'no-version' last I checked.
        { name => 'Diakonos',    versioncmd => 'diakonos --version',   version => undef },
        { name => 'Emacs',       versioncmd => 'emacs --version',      version => undef },
        { name => 'geany',       versioncmd => 'geany --version',      version => undef },
        { name => 'gedit',       versioncmd => 'gedit --version',      version => undef },
        { name => 'jed',         versioncmd => 'jed --version',        version => undef },
        { name => 'Joe',         versioncmd => 'joe',                  version => undef,
            altcmd => '' }, #no version option...
        { name => 'Kate',        versioncmd => 'kate --version',       version => undef,
            edgecase => eval { qr/(?:Kate:[\s])($re_version)/ }},
        { name => 'Leafpad',     versioncmd => 'leafpad --version',    version => undef },
        { name => 'medit',       versioncmd => 'medit --version',      version => undef },
        { name => 'mousepad',    versioncmd => 'mousepad --version',   version => undef },
        { name => 'nano',        versioncmd => 'nano --version',       version => undef },
        { name => 'vi',          versioncmd => 'vi',                   version => undef,
            altcmd => '' }, #can't get vi version info from cli switch, so just check if it exists.
        { name => 'Vim',         versioncmd => 'vim --version',        version => undef },
    ],
);

sub PopulateLists {
    foreach my $vals (keys %LISTS) {
        foreach my $elem ( @{$LISTS{$vals}}) {
            if(($elem->{versioncmd} =~ qr/([\w]+)\ ?/) and CommithForth($1)) {
                $elem->{version} = ( #for the love of god, if you can't read this, blame my cat.
                (
                    (defined $elem->{altcmd} ? (scalar `$elem->{altcmd} 2>&1`) : (scalar `$elem->{versioncmd} 2>&1`)) #use altcmds if available
                    =~
                    (defined $elem->{edgecase} ? $elem->{edgecase} : $re_version) #use edge cases if available
                    and $1
                )
                or ('unknown') #this is an edge case in it self...
                );
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

my $re_cpu = eval { qr/[\t\:\ ]+(.+)[\W]+/ };
my $re_intelghz = eval { qr/\ \@.+/ };

sub GetCPUInfo {
    my $buffer = ReadFile('/proc/cpuinfo');
    if($buffer) {
        $processor->{'1Vendor'} = FirstMatch($buffer, qr/vendor_id$re_cpu/m);
        $processor->{'2Model'} = FirstMatch($buffer, qr/model name$re_cpu/m);
        $processor->{'2Model'} =~ s/$re_intelghz//;
        
        my $cores;
        if($buffer =~ qr/cpu cores$re_cpu/m) {
            $processor->{'3Details'} = $1;
        } elsif (not ($processor->{'3Details'} =()= ($buffer =~ /processor$re_cpu/g))) { #if /cpu cores/ is not present fallback to somewhat less accurate processor counting.
            $processor->{'3Details'} = 1;
        }
        $cores = $processor->{'3Details'};
        if($processor->{'3Details'} > 1) {
            $processor->{'3Details'} .= "-Cores ";
        } elsif($processor->{'3Details'} == 1) {
            $processor->{'3Details'} .= "-Core ";
        }
        
        my $freq;
        if(-e '/sys/bus/cpu/devices/cpu0/cpufreq/bios_limit') { #more accurate
            $freq = sprintf('%0.2f', (ReadFile('/sys/bus/cpu/devices/cpu0/cpufreq/bios_limit') / 1000000))
        } else {
            $freq =  FirstMatch($buffer, qr/cpu MHz$re_cpu/m) / 1000;
            $freq = sprintf('%0.2f', $freq);
        }
        $processor->{'3Details'} .= ($processor->{'3Details'} ? '@' : '') . $freq . 'GHz ' if($freq);
        
        if($buffer =~ qr/siblings$re_cpu/m){
            my $sibs = $1;
            $processor->{'3Details'} .= (
                (int($sibs / $cores) - 1) ? 'HyperThreaded' : ''
            );
        }
        undef $buffer;
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
        $motherboard->{'1Vendor'} = FirstMatch($buffer, $re_anyword);
        undef $buffer;
    }
    $buffer = ReadFile('/sys/class/dmi/id/board_name');
    if($buffer) {
        $motherboard->{'2Board'} = FirstMatch($buffer, $re_anyword);
        undef $buffer;
    }
    $buffer = ReadFile('/sys/class/dmi/id/bios_vendor');
    if($buffer) {
        $motherboard->{'3Bios'} = FirstMatch($buffer, $re_anyword);
        undef $buffer;
    }
    $buffer = ReadFile('/sys/class/dmi/id/bios_version');
    if($buffer) {
        $motherboard->{'3Bios'} .= ' (' . FirstMatch($buffer, $re_anyword) . ')';
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
    '3User@Host' => undef,
    '2Kernel' => undef,
    '4WM/DE' => undef,
    '5Packages' => undef,
};

sub GetOSInfo {
    my $buffer = ReadFile('/proc/version');
    if($buffer) {
        $os->{'2Kernel'} = FirstMatch($buffer, qr/^([\w]+) version /im) . ' ' . FirstMatch($buffer, qr/version $re_version/im);
        undef $buffer;
    }
    
    if(not ($os->{'3User@Host'} = $ENV{'USER'})) {
        $os->{'3User@Host'} = FirstMatch(`whoami`, $re_anyword) if (CommithForth('whoami'));
    }
    if(-e '/proc/sys/kernel/hostname') { #much faster
        chomp ($os->{'3User@Host'} .= "@" . ReadFile('/proc/sys/kernel/hostname'));
    } elsif(CommithForth('hostname') and `hostname` =~ $re_anyword) {
        $os->{'3User@Host'} .= ($1 ? "\@$1" : '');
    }
    
    if(($buffer = (ReadFile('/etc/lsb-release') or ReadFile('/etc/os-release')) )) {
        if($buffer) {
            $os->{'1Distro'} = FirstMatch($buffer, qr/DISTRIB_ID=$re_anyword/m);
            $os->{'1Distro'} .= ' ' . FirstMatch($buffer, qr/DISTRIB_RELEASE=$re_anyword/m) . ' ' . FirstMatch($buffer, qr/DISTRIB_CODENAME=$re_anyword/m);
            undef $buffer;
        }
    } elsif((my $line =(grep(/([\w]+-release)$/, `ls -1 /etc/*-release 2>&1`))[0])) { #propose: /([\w]+-release|[\w]+_version)$/
        if($line =~ $re_anyword) {
            my $matching_file = $1;
            if(-e -r $matching_file) {
                $os->{'1Distro'} = ReadFile($matching_file);
                $os->{'1Distro'} =~ s/[\n]*//;
            }
        }
    } else {
        if(-e '/etc/debian_version') {
            $os->{'1Distro'} = 'Debian ' . (($buffer = ReadFile('/etc/debian_version')) ? $buffer : '');
        }
    }
    $os->{'1Distro'} =~ s/[\n]+// if($os->{'1Distro'});
    
    
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
    
    {
        if(CommithForth('ps')) {
            my @plist = `ps axco command`;
            foreach my $wm (keys %wm_list) {
                if (grep(/$wm/, @plist)) {
                    $os->{'4WM/DE'} = $wm_list{$wm};
                    last;
                }
            }
            
            {   #look for $de[\-\_]session process, to determine DE.
                my $desktop;
                foreach my $de (keys %desktops) {
                    if(my @occurrances = grep(/$de[\-\_]session/i, @plist)) {
                        $desktop = $de;
                        last;
                    }
                }
                if($os->{'4WM/DE'}) {
                    $os->{'4WM/DE'} .= "/$desktops{$desktop}";
                } else {
                    $os->{'4WM/DE'} = $desktops{$desktop};
                }
            }
            undef @plist;
        }
    }
}

#==========================MEMORY INFORMATION
my $memory = {
    '1Ram' => undef,
    '2Swap' => undef,
};

my $re_number = eval { qr/[\s]*([\d]+)/ };

sub GetMemInfo {
    my $buffer = ReadFile('/proc/meminfo');
    if($buffer) {
        my $ram_used; my $swap_used;
        $memory->{'1Ram'} = FirstMatch($buffer, qr/MemTotal:$re_number/im);
        {
            my $buffers = FirstMatch($buffer, qr/Buffers:$re_number/im);
            my $cached = FirstMatch($buffer, qr/Cached:$re_number/im);
            my $memfree = FirstMatch($buffer, qr/MemFree:$re_number/im);
            $ram_used = int(($memory->{'1Ram'} - ($buffers + $cached + $memfree)) / 1024);
        }
        $memory->{'1Ram'} = int($memory->{'1Ram'} / 1024);
        
        $memory->{'2Swap'} = FirstMatch($buffer, qr/SwapTotal:$re_number/m);
        {
            my $cached = FirstMatch($buffer, qr/SwapCached:$re_number/m);
            my $swapfree = FirstMatch($buffer, qr/SwapFree:$re_number/m);
            $swap_used = int( ($memory->{'2Swap'} - ($swapfree + $cached)) / 1024);
        }
        $memory->{'2Swap'} = int($memory->{'2Swap'} / 1024);
        undef $buffer;
        
        if($memory->{'2Swap'}) {
            $memory->{'2Swap'} .= "M";
            $swap_used .= "M";
            $memory->{'2Swap'} = "$swap_used/$memory->{'2Swap'}";
        }
        if($memory->{'1Ram'}) {
            $memory->{'1Ram'} .= "M";
            $ram_used .= "M";
            $memory->{'1Ram'} = "$ram_used/$memory->{'1Ram'}";
        }
    }
}
#==========================GPU INFORMATION (requires glxinfo atm)

my $gpu = {
    '1Vendor' => undef,
    '2Model' => undef,
    '3Driver' => undef,
};

# my @driver_patterns = ( #needs proper patterns...
#     qr/X($re_version-$re_version)/i,
#     qr/(mesa $re_version)/i,
#     qr/(nvidia $re_version)/i,
#     qr/$re_version/,
# );

sub GetGPUInfo {
    if(-e '/proc/driver/nvidia/gpus/0/information') {
        my $contents = ReadFile '/proc/driver/nvidia/gpus/0/information';
        $gpu->{'1Vendor'} = 'NVIDIA';
        $gpu->{'2Model'} = $1 if ($contents =~ /Model:[\.\s]+(.+)/i);
        $gpu->{'3Driver'} = $1 if ( (ReadFile '/proc/driver/nvidia/version') =~ /Module[\s]+$re_version[\s]/i);
    } 
#     elsif(CommithForth('glxinfo')) {
#         my @glx_data = `glxinfo`;
#         
#         $gpu->{vendor} = (grep(/OpenGL vendor string/, @glx_data))[0];
#         $gpu->{vendor} = $1 if($gpu->{vendor} =~ qr/\:\ ([\w\.\ ]+)/);
#         
#         $gpu->{driver} = ((grep(/OpenGL core profile version string/, @glx_data))[0] or (grep(/OpenGL version string/, @glx_data))[0]);
#         if($gpu->{driver}) {
#             foreach my $regex(@driver_patterns) { #yes, I replaced a smartmatch with a foreach loop, forgive me.
#                 if($gpu->{driver} =~ $regex) {
#                     $gpu->{driver} = $1;
#                     last; #in the words of shaggy, "lets get outta here!"
#                 }
#             }
#         }
#         
#         $gpu->{card} = (grep(/OpenGL renderer string/, @glx_data))[0];
#         if($gpu->{card}) {
#             $gpu->{card} = $1 if($gpu->{card} =~ qr/:[\s]+([^\/\n]+)[\/]?/);
#         }
#         
#         undef @glx_data;
#     }
}

#==========================
sub PrintEntry ($$) {
    if($_[1]) {
        print "\t${subtitle_color}${_[0]}\t" . ((length($_[0]) >= 16) ? '' : ((length($_[0]) >= 8) ? '' : "\t")) . "${value_color}${_[1]}\n";
    }
}

sub PrintList ($) {
    my $list = $_[0]; my $count = 0;
    foreach my $elem (@{$list}) {
        if($elem->{version}) {
            PrintEntry($elem->{name}, (not ($elem->{version} eq 'unknown') ? 'v' : '') . $elem->{version});
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

my $re_nosortnum = qr/[\d]?([\w]+)/;

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
PrintHashTable($memory, 'Memory');
PrintHashTable($gpu, 'Video Card');

PrintHashes() if($langs);

Cleanup();
