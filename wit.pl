#!/usr/bin/perl
#use warnings;
#use diagnostics;
###
#   What Is This (wit) 
#   Simple Fast System Information
#   This file and its accompanying files are Licensed under the MIT License.
#   Written by: Kuroilight@openmailbox.org
###
eval {
    require Term::ANSIColor;
    Term::ANSIColor->import();
};
my $nocolor = 1 if($@);
eval {
    require utf8;
    utf8->import();
};
#GLOBALS
my $wit_version = '0.41.6';
 # bin directories
my @bins = (
'/usr/local/bin/',
'/usr/bin/',
'/bin/',
'/usr/local/sbin/',
'/usr/sbin/',
'/sbin/',
);
print "You should upgrade perl, as you'll probably have problems running this script on anything under version 5.12" if ($] < 5.012);
my $noshells = 0;
my $nolangs = 0;
my $nohardware = 0;
my $flying_tables = 0;
#colors
my $bCOLORS256 = 1;
my $title_color = '';
my $subtitle_color = '';
my $value_color = '';

#==========================
sub CommandExists ($) { #pass (cmd)
    foreach my $bin (@bins) {
        return 1 if(-e "$bin$_[0]");
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
            print "Help:\n  wit.pl\t<options>";
            print "\n\t-v,--version\tdisplay version and exit";
            print "\n\t-h,--help\tdisplay this help and exit";
            print "\n\t-ex,--experimental\tenable experimental features";
            print "\n\t-ns,--noshells\tdont display shells";
            print "\n\t-nl,--nolangs\tdont display scripting languages";
            print "\n\t-nh,--nohw\tdont display hardware";
            print "\n\t-na,--no256\tdisable rgb256 coloring\n";
            exit 0;
        } elsif($arg =~ /(-nl|--nolangs)/){
            $nolangs = 1;
        } elsif($arg =~ /(-ns|--noshells)/){
            $noshells = 1;
        } elsif($arg =~ /(-nh|--nohw)/){
            $nohardware = 1;
        } elsif($arg =~ /(-na|--no256)/){
            $bCOLORS256 = 0;
        } elsif($arg =~ /(-ex|--experimental)/) {
            $flying_tables = 1;
        } else {
            print "Invalid option $arg\n";
            exit 1;
        }
    }
    if(not $nocolor) {
        $bCOLORS256 = ($Term::ANSIColor::VERSION >= 4.00 ? $bCOLORS256 : 0);
        $title_color = color ( $bCOLORS256 ? 'rgb125' : 'blue');
        $subtitle_color = color ( $bCOLORS256 ? 'rgb224' : 'green');
        $value_color = color ( $bCOLORS256 ? 'rgb134' : 'cyan');
    }
}

sub Cleanup { #clean up here
    unless ($nocolor) {
        print (color('reset'));
    }
}
#==========================PROGRAM LISTS
my %LISTS = (
    shells => [
        { name => 'Bash', versioncmd => 'bash --version', version => undef },
        { name => 'Fish', versioncmd => 'fish --version 2>&1', version => undef },
        { name => 'Mksh', versioncmd => '', version => undef }, # <- need suggestions for this
        { name => 'Tcsh', versioncmd => 'tcsh --version', version => undef },
        { name => 'Zsh', versioncmd => 'zsh --version', version => undef },
    ], 
    scripts => [
        { name => 'Falcon', versioncmd => 'falcon -v', version => undef },
        { name => 'HaXe', versioncmd => 'haxe -version 2>&1', version => undef },
        { name => 'Lua', versioncmd => 'lua -v 2>&1', version => undef },
        { name => 'MoonScript', versioncmd => 'moon -v', version => undef },
        { name => 'Neko', versioncmd => 'neko', version => undef },
        { name => 'Perl', versioncmd => 'perl --version', version => undef },
        { name => 'Perl6', versioncmd => 'perl6 -v', version => undef },
        { name => 'Python2', versioncmd => 'python2 --version 2>&1', version => undef },
        { name => 'Python3', versioncmd => 'python3 --version 2>&1', version => undef },
        { name => 'Ruby', versioncmd => 'ruby --version', version => undef },
        { name => 'Squirrel', versioncmd => 'squirrel -v', version => undef },
    ], 
);

my $re_versionmatch = eval { qr/(([\d]+\.){1,2}[\d]+)/ };

sub PopulateLists { #very sharp loop :P
    foreach my $vals (keys %LISTS) {
        foreach my $elem ( @{$LISTS{$vals}}) {
            if(($elem->{versioncmd} =~ qr/([\w]+)\ ?/) and CommandExists($1)) {
                $elem->{version} = $1 if ((scalar `$elem->{versioncmd}`) =~ $re_versionmatch);
            }
        }
    }
}
#==========================CPU INFORMATION
#fix plural for single cores
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
        $processor->{cores} = FirstMatch($buffer, qr/cpu cores$re_cpu/m) or 1;
        {
            my $siblings = ($buffer =~ qr/siblings$re_cpu/m ? $1 : $processor->{cores}) or 1;
            $processor->{ht} = ($processor->{cores} * 2 == $siblings);
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
my $os = {
    userhost => undef,
    kernel => undef,
    distro => undef,
    distro_version => undef,
    package_count => undef,
};

sub GetOSInfo {
    my $buffer = ReadFile('/proc/version');
    if($buffer) {
        $os->{kernel} = FirstMatch($buffer, qr/^([\w]+) version /im) . ' ' . FirstMatch($buffer, qr/version $re_versionmatch/im);
        undef $buffer;
    }
    $os->{userhost} = FirstMatch(`whoami`, $re_anyword) if (CommandExists('whoami'));
    do {
        my $host_name = FirstMatch(`hostname`, $re_anyword);
        $os->{userhost} .= ($host_name ? "\@$host_name" : '');
    } if (CommandExists('hostname'));

    if(($buffer = (ReadFile('/etc/lsb-release') or ReadFile('/etc/os-release')) )) {
        if($buffer) {
            $os->{distro} = FirstMatch($buffer, qr/DISTRIB_ID=$re_anyword/m);
            $os->{distro_version} = FirstMatch($buffer, qr/DISTRIB_RELEASE=$re_anyword/m) . ' ' . FirstMatch($buffer, qr/DISTRIB_CODENAME=$re_anyword/m);
            undef $buffer;
        }
    } elsif((grep(/([\w]+-release)$/, `ls -1 /etc/*-release 2>&1`))[0] =~ $re_anyword) {
        my $matching_file = $1;
        if(-e -r $matching_file) {
            $os->{distro} = ReadFile($matching_file);
            $os->{distro} =~ s/[\n]*//;
        }
    }
    
    my @packages = 0;
    if(CommandExists('pacman')) { #Good ol' Arch (tested)
        @packages = (`pacman -Qq`);
    } elsif(-e -d '/var/db/pkg/') { #Gentoo
        @packages = (`ls -d -1 /var/db/pkg/*/*`);
    } elsif (CommandExists('dpkg')) { #Ubuntu (tested)
        @packages = (grep (/ii/, `dpkg -l`));
    } elsif (-e -d '/var/log/packages') { #Debian (tested)
        @packages = (`ls -1 /var/log/packages`);
    } elsif(CommandExists('rpm')) { #Suse/RedHat
        @packages = (`rpm -qa`);
    } elsif(CommandExists('pkg_info')) { #BSD
        @packages = (`pkg_info`);
    }
    $os->{package_count} = scalar @packages;
    undef @packages;
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
#==========================GPU INFORMATION (requires glxinfo atm) キタ!!
#bug when missing if.pm
no if $] >= 5.017011, warnings => 'experimental::smartmatch'; #Whyyyyyyy!!! (╯°□°）╯︵ ┻━┻

my $gpu = {
    vendor => undef,
    card => undef,
    driver => undef,
};

my @driver_patterns = ( #needs proper patterns...(*￣m￣)
    qr/X($re_versionmatch-$re_versionmatch)/i,
    qr/(mesa $re_versionmatch)/i,
    qr/(nvidia $re_versionmatch)/i,
    qr/$re_versionmatch/,
);

#glxinfo is very slow...（￣□￣；）
#may have to ask something else for gpu info instead... (>_<)
sub tableflip {
    if($flying_tables and CommandExists('glxinfo')) {
        my @glx_data = `glxinfo`;

        $gpu->{vendor} = (grep(/OpenGL vendor string/, @glx_data))[0];
        $gpu->{vendor} = $1 if($gpu->{vendor} =~ qr/\:\ ([\w\ ]+)/);

        $gpu->{driver} = ((grep(/OpenGL core profile version string/, @glx_data))[0] or (grep(/OpenGL version string/, @glx_data))[0]);
        if($gpu->{driver}) {
            $gpu->{driver} = $1 if ($gpu->{driver} ~~ @driver_patterns); #Will need to be replaced. (╯°□°）╯︵ ┻━┻
        }

        $gpu->{card} = (grep(/OpenGL renderer string/, @glx_data))[0];
        if($gpu->{card}) {
            $gpu->{card} = $1 if($gpu->{card} =~ qr/: ([\w\ \(\)\.\!]+)[\/]?/); # or something like [.][^\\] [\/] # ((+_+))
        }

        undef @glx_data;
    }
}

#==========================
sub PrintEntry ($$) {
    if($_[1]) {
        print "\t${subtitle_color}${_[0]}\t" . ((length($_[0]) >= 8) ? '' : "\t") . "${value_color}${_[1]}\n";
    }
}

sub PrintList ($) {
    my $list = $_[0]; my $count = 0;
    foreach my $elem (@{$list}) {
        if($elem->{version}) {
            PrintEntry($elem->{name}, 'v' . $elem->{version});
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
#==========================WRITE OUTPUT/MAIN
Startup();

PopulateLists();
GetCPUInfo();
GetMemInfo();
GetOSInfo();
GetMoboInfo();
tableflip();

if(HasContents($os)) {
    print "${title_color}Operating System-\n";
    PrintEntry('Distro', ($os->{distro} ? "$os->{distro} " : '') . ($os->{distro_version} ? "$os->{distro_version} " : ''));
    PrintEntry('Kernel', $os->{kernel});
    PrintEntry("User\@Host", $os->{userhost});
    PrintEntry('Packages', $os->{package_count});
}
if(not $noshells) {
    print "${title_color}Shells-\n";
    PrintList($LISTS{shells});
}
if(not $nolangs) {
    print "${title_color}Script Langs-\n";
    PrintList($LISTS{scripts});
}
if(not $nohardware) {
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
            ($processor->{cores} ? "$processor->{cores}-Cores " : undef)
            . ($processor->{freq} ? "@ $processor->{freq}GHz " : undef)
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
        PrintEntry('Ram', ($memory->{ram_total} ? "$memory->{ram_used}M/$memory->{ram_total}M" : undef));
        PrintEntry('Swap', ($memory->{swap_total} ? "$memory->{swap_used}M/$memory->{swap_total}M" : undef));
    }
}

Cleanup();
