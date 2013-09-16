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


my $wit_version = '0.42.1';

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
            $title_color = "\033[2;32m";
            $subtitle_color = "\033[1;31m";
            $value_color = "\033[1;34m";
        } elsif ($colors == 2) {
            $title_color = "\033[1;33m";
            $subtitle_color = "\033[1;35m";
            $value_color = "\033[1;36m";
        }
    }
}

sub Cleanup {
    if ($colors) {
        print ("\033[0m");
    }
}
#==========================PROGRAM LISTS
my $re_version = eval { qr/((([\d]+)\.)+[\d]+)/im };

my %LISTS = (
    '3Tools' => [
        { name => 'awk', versioncmd => 'awk --version', version => undef },
        { name => 'grep', versioncmd => 'grep --version', version => undef },
        { name => 'sed', versioncmd => 'sed --version', version => undef },
    ],
    '0Shells' => [
        { name => 'Bash', versioncmd => 'bash --version', version => undef },
        { name => 'Fish', versioncmd => 'fish --version', version => undef },
        { name => 'Mksh', versioncmd => 'mksh', version => undef, altcmd => '' },
        { name => 'Tcsh', versioncmd => 'tcsh --version', version => undef },
        { name => 'Zsh', versioncmd => 'zsh --version', version => undef },
    ],
    '1Programming' => [
        { name => 'Falcon', versioncmd => 'falcon -v', version => undef },
        { name => 'HaXe', versioncmd => 'haxe -version', version => undef },
        { name => 'Io', versioncmd => 'io --version', version => undef, edgecase => eval { qr/(?<=v. )([\d]+)/ }},
        { name => 'Lua', versioncmd => 'lua -v', version => undef },
        { name => 'MoonScript', versioncmd => 'moon -v', version => undef },
        { name => 'Neko', versioncmd => 'neko', version => undef },
        { name => 'newLisp', versioncmd => 'newlisp -v', version => undef },
        { name => 'Perl5', versioncmd => 'perl --version', version => undef },
        { name => 'Perl6', versioncmd => 'perl6 -v', version => undef },
        { name => 'Python2', versioncmd => 'python2 --version', version => undef },
        { name => 'Python3', versioncmd => 'python3 --version', version => undef },
        { name => 'Racket', versioncmd => 'racket --version', version => undef },
        { name => 'Ruby', versioncmd => 'ruby --version', version => undef },
        { name => 'Squirrel', versioncmd => 'squirrel -v', version => undef },
        { name => 'Tcl', versioncmd => 'tclsh', version => undef, altcmd => "echo 'puts \$tcl_version;exit 0' | tclsh"},
                    #compilers
        { name => 'GNAT Ada', versioncmd => 'gnat', version => undef },
        { name => 'Chicken', versioncmd => 'chicken -version', version => undef },
        { name => 'GCC', versioncmd => 'gcc --version', version => undef },
        { name => 'Guile', versioncmd => 'guile -v', version => undef },
        { name => 'Rust', versioncmd => 'rust --version', version => undef },
        { name => 'Vala', versioncmd => 'valac --version', version => undef },
        { name => 'Ypsilon', versioncmd => 'ypsilon --version', version => undef },
    ],
    '2Editors' => [
        { name => 'dex', versioncmd => 'dex -V', version => undef }, #simply displays 'no-version' last I checked.
        { name => 'Diakonos', versioncmd => 'diakonos --version', version => undef },
        { name => 'Emacs', versioncmd => 'emacs --version', version => undef },
        { name => 'geany', versioncmd => 'geany --version', version => undef },
        { name => 'gedit', versioncmd => 'gedit --version', version => undef },
        { name => 'jed', versioncmd => 'jed --version', version => undef },
        { name => 'Joe', versioncmd => 'joe', version => undef, altcmd => '' }, #no version option...
        { name => 'Kate', versioncmd => 'kate --version', version => undef, edgecase => eval { qr/(?<=Kate:[\s])($re_version)/ }},
        { name => 'Leafpad', versioncmd => 'leafpad --version', version => undef },
        { name => 'medit', versioncmd => 'medit --version', version => undef },
        { name => 'mousepad', versioncmd => 'mousepad --version', version => undef },
        { name => 'nano', versioncmd => 'nano --version', version => undef },
        { name => 'vi', versioncmd => 'vi', version => undef, altcmd => '' }, #can't get vi version info from cli switch, so just check if it exists.
        { name => 'Vim', versioncmd => 'vim --version', version => undef },
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
    vendor => undef,
    name => undef,
    cores => undef,
    ht => undef,
    freq => undef,
};

my $re_cpu = eval { qr/[\t\:\ ]+(.+)[\W]+/ };
my $re_intelghz = eval { qr/\ \@.+/ };

sub GetCPUInfo {
    my $buffer = ReadFile('/proc/cpuinfo');
    if($buffer) {
        $processor->{vendor} = FirstMatch($buffer, qr/vendor_id$re_cpu/m);
        $processor->{name} = FirstMatch($buffer, qr/model name$re_cpu/m);
        $processor->{name} =~ s/$re_intelghz//;
        
        if($buffer =~ qr/cpu cores$re_cpu/m) {
            $processor->{cores} = $1;
        } elsif (not ($processor->{cores} =()= ($buffer =~ /processor$re_cpu/g))) { #if /cpu cores/ is not present fallback to somewhat less accurate processor counting.
            $processor->{cores} = 1;
        }
        if($buffer =~ qr/siblings$re_cpu/m){
            $processor->{ht} = int($1 / $processor->{cores}) - 1;
        } else {
            $processor->{ht} = 0; #if we can't find it, assume it doesn't exist.
        }
        $processor->{freq} =  FirstMatch($buffer, qr/cpu MHz$re_cpu/m) / 1000;
        $processor->{freq} = sprintf('%0.2f', $processor->{freq});
        undef $buffer;
    }
}
#==========================MOTHERBOARD
my $motherboard = {
    vendor => undef,
    board => undef,
    bios => undef,
};

my $re_anyword = eval { qr/(.+)/ };

sub GetMoboInfo {
    my $buffer = ReadFile('/sys/class/dmi/id/board_vendor');
    if($buffer) {
        $motherboard->{vendor} = FirstMatch($buffer, $re_anyword);
        undef $buffer;
    }
    $buffer = ReadFile('/sys/class/dmi/id/board_name');
    if($buffer) {
        $motherboard->{board} = FirstMatch($buffer, $re_anyword);
        undef $buffer;
    }
    $buffer = ReadFile('/sys/class/dmi/id/bios_vendor');
    if($buffer) {
        $motherboard->{bios} = FirstMatch($buffer, $re_anyword);
        undef $buffer;
    }
    $buffer = ReadFile('/sys/class/dmi/id/bios_version');
    if($buffer) {
        $motherboard->{bios} .= ' (' . FirstMatch($buffer, $re_anyword) . ')';
        undef $buffer;
    }
}
#==========================OPERATING SYSTEM
#WM List originally generated with regex, from the list in screenfetch, Though I'm adding new/old ones not included.
my %wm_list = (
    'afterstep' => 'AfterStep',         #+
    'awesome' => 'Awesome',             
    'beryl' => 'Beryl',                #
    'blackbox' => 'Blackbox',          #
    'cinnamon' => 'Cinnamon',           
    'cwm' => 'CalmWM',                  #+
    'compiz' => 'Compiz',               
    'dminiwm' => 'dminiwm',             
    'dwm' => 'DWM',                    #
    'e16' => 'E16',                    #
    'emerald' => 'Emerald',            #
    'enlightenment' => 'E17',           
    'fluxbox' => 'FluxBox',             
    'fvwm' => 'FVWM',                   
    'herbstluftwm' => 'herbstluftwm',   
    'icewm' => 'IceWM',                 
    'jwm' => 'JWM',                     #+
    'kwin' => 'KWin',                   
    'metacity' => 'Metacity',           
    'monsterwm' => 'monsterwm',         
    'musca' => 'Musca',                 
    'mutter' => 'Mutter',               #+
    'openbox' => 'OpenBox',             
    'pekwm' => 'PekWM',                 
    'ratpoison' => 'Ratpoison',         
    'sawfish' => 'Sawfish',             
    'scrotwm' => 'ScrotWM',            #
    'spectrwm' => 'SpectrWM',           
    'stumpwm' => 'StumpWM',            #
    #twm                                #
    'subtle' => 'subtle',               
    'wmaker' => 'WindowMaker',          
    'wmfs' => 'WMFS',                   
    'wmii' => 'wmii',                  #
    'xfwm4' => 'Xfwm4',                 
    'xmonad' => 'XMonad',               
    'i3' => 'i3',                       
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
    userhost => undef,
    kernel => undef,
    distro => undef,
    distro_version => undef,
    package_count => undef,
    window_manager => undef,
    desktop_env => undef, #not always present
};

sub GetOSInfo {
    my $buffer = ReadFile('/proc/version');
    if($buffer) {
        $os->{kernel} = FirstMatch($buffer, qr/^([\w]+) version /im) . ' ' . FirstMatch($buffer, qr/version $re_version/im);
        undef $buffer;
    }
    
    if(not ($os->{userhost} = $ENV{'USER'})) {
        $os->{userhost} = FirstMatch(`whoami`, $re_anyword) if (CommithForth('whoami'));
    }
    if(CommithForth('hostname') and `hostname` =~ $re_anyword) {
        $os->{userhost} .= ($1 ? "\@$1" : '');
    }
    
    if(($buffer = (ReadFile('/etc/lsb-release') or ReadFile('/etc/os-release')) )) {
        if($buffer) {
            $os->{distro} = FirstMatch($buffer, qr/DISTRIB_ID=$re_anyword/m);
            $os->{distro_version} = FirstMatch($buffer, qr/DISTRIB_RELEASE=$re_anyword/m) . ' ' . FirstMatch($buffer, qr/DISTRIB_CODENAME=$re_anyword/m);
            undef $buffer;
        }
    } elsif((my $line =(grep(/([\w]+-release)$/, `ls -1 /etc/*-release 2>&1`))[0])) {
        if($line =~ $re_anyword) {
            my $matching_file = $1;
            if(-e -r $matching_file) {
                $os->{distro} = ReadFile($matching_file);
                $os->{distro} =~ s/[\n]*//;
            }
        }
    } else {
        if(-e '/etc/debian_version') {
            $os->{distro} = 'Debian ' . (($buffer = ReadFile('/etc/debian_version')) ? $buffer : '');
        }
    }
    $os->{distro} =~ s/[\n]+// if($os->{distro});
    
    
    my @packages = 0;
    if(CommithForth('pacman')) { #Good ol' Arch (tested)
        @packages = (`pacman -Qq`);
    } elsif(-e -d '/var/db/pkg/') { #Gentoo (untested and I have no clue how different a gentoo environment may be)
        @packages = (`ls -d -1 /var/db/pkg/*/*`);
    } elsif (CommithForth('dpkg')) { #Ubuntu (tested)
        @packages = (grep (/ii/, `dpkg -l 2>&1`));
    } elsif (-e -d '/var/log/packages') { #Debian (tested)
        @packages = (`ls -1 /var/log/packages`);
    } elsif(CommithForth('rpm')) { #Suse/RedHat (untested will test later)
        @packages = (`rpm -qa`);
    } elsif(CommithForth('pkg_info')) { #BSD (untested maybe later)
        @packages = (`pkg_info`);
    }
    $os->{package_count} = scalar @packages;
    undef @packages;
    
    {
        if(CommithForth('ps')) {
            my @plist = `ps axco command`;
            foreach my $wm (keys %wm_list) {
                if (grep(/$wm/, @plist)) {
                    $os->{window_manager} = $wm_list{$wm};
                    last;
                }
            }
            
            {   #look for $de[\-\_]session process, to determine DE.
                foreach my $de (keys %desktops) {
                    if(my @occurrances = grep(/$de[\-\_]session/i, @plist)) {
                        $os->{desktop_env} = $de;
                        last;
                    }
                }
#                 if(not ($os->{desktop_env})) { #if no $de[\-\_]session found use guesswork, based on process list.
#                     my $cur_highest = 0;
#                     foreach my $de (keys %desktops) {
#                         if(my $current = (my @occurrances = grep(/$de/i, @plist) )) {
#                             if($current > $cur_highest) {
#                                 $os->{desktop_env} = $de;
#                                 $cur_highest = $current;
#                             }
#                         }
#                     }
#                 }
                $os->{desktop_env} = $desktops{$os->{desktop_env}} if ($os->{desktop_env});
            }
            undef @plist;
        }
    }
}

#==========================MEMORY INFORMATION
my $memory = {
    ram_used => undef,
    ram_total => undef,
    swap_used => undef,
    swap_total => undef,
};

my $re_number = eval { qr/\s*([\d]+)/ };

sub GetMemInfo {
    my $buffer = ReadFile('/proc/meminfo');
    if($buffer) {
        $memory->{ram_total} = FirstMatch($buffer, qr/MemTotal:$re_number/im);
        {
            my $buffers = FirstMatch($buffer, qr/Buffers:$re_number/im);
            my $cached = FirstMatch($buffer, qr/Cached:$re_number/im);
            my $memfree = FirstMatch($buffer, qr/MemFree:$re_number/im);
            $memory->{ram_used} =int(($memory->{ram_total} - ($buffers + $cached + $memfree)) / 1024);
        }
        $memory->{ram_total} = int($memory->{ram_total} / 1024);
        
        $memory->{swap_total} = FirstMatch($buffer, qr/SwapTotal:$re_number/m);
        {
            my $cached = FirstMatch($buffer, qr/SwapCached:$re_number/m);
            my $swapfree = FirstMatch($buffer, qr/SwapFree:$re_number/m);
            $memory->{swap_used} = int( ($memory->{swap_total} - ($swapfree + $cached)) / 1024);
        }
        $memory->{swap_total} = int($memory->{swap_total} / 1024);
        undef $buffer;
    }
}
#==========================GPU INFORMATION (requires glxinfo atm)

my $gpu = {
    vendor => undef,
    card => undef,
    driver => undef,
};

my @driver_patterns = ( #needs proper patterns...
    qr/X($re_version-$re_version)/i,
    qr/(mesa $re_version)/i,
    qr/(nvidia $re_version)/i,
    qr/$re_version/,
);

sub GetGPUInfo {
    if(CommithForth('glxinfo')) {
        my @glx_data = `glxinfo`;
        
        $gpu->{vendor} = (grep(/OpenGL vendor string/, @glx_data))[0];
        $gpu->{vendor} = $1 if($gpu->{vendor} =~ qr/\:\ ([\w\.\ ]+)/);
        
        $gpu->{driver} = ((grep(/OpenGL core profile version string/, @glx_data))[0] or (grep(/OpenGL version string/, @glx_data))[0]);
        if($gpu->{driver}) {
            foreach my $regex(@driver_patterns) { #yes, I replaced a smartmatch with a foreach loop, forgive me.
                if($gpu->{driver} =~ $regex) {
                    $gpu->{driver} = $1;
                    last; #in the words of shaggy, "lets get outta here!"
                }
            }
        }
        
        $gpu->{card} = (grep(/OpenGL renderer string/, @glx_data))[0];
        if($gpu->{card}) {
            $gpu->{card} = $1 if($gpu->{card} =~ qr/:[\s]+([^\/\n]+)[\/]?/);
        }
        
        undef @glx_data;
    }
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

sub PrintHashes {
    for my $vals (sort keys %LISTS) {
        $vals =~ qr/[\d]?([\w]+)/; #get val without sort order number, assuming is has such a thing
        print "${title_color}$1-\n";
        PrintList($LISTS{$vals});
    }
}

# sub PrintHash {
#     for my %item (
#==========================WRITE OUTPUT/MAIN
Startup();
PopulateLists() if($langs);
GetCPUInfo();
GetMemInfo();
GetOSInfo();
GetMoboInfo();
GetGPUInfo();


if(HasContents($os)) {
    print "${title_color}Operating System-\n";
    PrintEntry('Distro', ($os->{distro} ? "$os->{distro} " : '') . ($os->{distro_version} ? "$os->{distro_version} " : ''));
    PrintEntry('Kernel', $os->{kernel});
    PrintEntry('User@Host', $os->{userhost});
    
    #I know there are better ways to go about this but this is just a quick fix for now.
    if($os->{desktop_env} and not $os->{window_manager}) {
        PrintEntry('DE', $os->{desktop_env});
    } elsif($os->{window_manager} and not $os->{desktop_env}) {
        PrintEntry('WM', $os->{window_manager});
    } elsif($os->{window_manager} and $os->{desktop_env}) {
        PrintEntry('WM/DE', $os->{window_manager} . '/' . $os->{desktop_env});
    }
    PrintEntry('Packages', $os->{package_count});
}

if(HasContents($motherboard)) {
    print "${title_color}Motherboard-\n";
    PrintEntry('Vendor', $motherboard->{vendor});
    PrintEntry('Model', $motherboard->{board});
    PrintEntry('Bios', $motherboard->{bios});
}
if(HasContents($processor)) {
    print "${title_color}Processor-\n";
    PrintEntry('Vendor', $processor->{vendor});
    PrintEntry('Model', $processor->{name});
    PrintEntry('Details', 
               ($processor->{cores} ? "$processor->{cores}-Core" . ($processor->{cores} > 1 ? 's ' : ' ') : '')
               . ($processor->{freq} ? "\@$processor->{freq}GHz " : '')
               . ($processor->{ht} ? 'with hyperthreading' : '')
    );
}
if(HasContents($gpu)){
    print "${title_color}Video Card-\n";
    PrintEntry('Vendor', $gpu->{vendor});
    PrintEntry('Card', $gpu->{card});
    PrintEntry('Driver', $gpu->{driver});
}
if(HasContents($memory)) {
    print "${title_color}Memory-\n";
    PrintEntry('Ram', ($memory->{ram_total} ? "$memory->{ram_used}M/$memory->{ram_total}M" : ''));
    PrintEntry('Swap', ($memory->{swap_total} ? "$memory->{swap_used}M/$memory->{swap_total}M" : ''));
}

if($langs) {
    PrintHashes();
}

Cleanup();
