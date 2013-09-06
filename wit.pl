#!/usr/bin/perl
my $DEBUG = 0;
use Term::ANSIColor;
($DEBUG ? do {use warnings;} : undef);
($DEBUG ? do {use strict;} : do {use 5.010;});

###
#   What Is This (wit)
#   Simple Fast System Information
#   MIT License
#   Written by: Kuroilight@openmailbox.org
###
#GLOBALS
my $wit_version = '0.40.0';
my @bins = split /:/, $ENV{PATH}; # get bin directories
my $noshells = 0;
my $nolangs = 0;
#colors
my $bCOLORS256 = 1; #needs a switch or detection
my $title_color = color ( $bCOLORS256 ? 'rgb125' : 'blue');
my $subtitle_color = color ( $bCOLORS256 ? 'rgb224' : 'cyan');
my $value_color = color ( $bCOLORS256 ? 'rgb134' : 'cyan');
#regex
my $LEADING_TRAILING_WHITESPACE = qr/(^(\s+|\n)|(\s+|\n)$)/;
my $VERSION_MATCH = qr/([0-9]+\.[0-9]+\.?[0-9]+?)/;

#depend
my $FILES = {
    SHELLS => '/etc/shells',
    MEMINFO => '/proc/meminfo',
    CPUINFO => '/proc/cpuinfo',
    BIOSLIMIT => '/sys/devices/system/cpu/cpu0/cpufreq/bios_limit',
    #DMIID => '/sys/class/dmi/id/', #not yet needed
    LSBR => '/etc/lsb-release',
    VERSION => '/proc/version',
    #CMDLINE => '/proc/cmdline', #can pool this for architecture
};
my @APPS = (
    #'uname --version',
    'whoami --version',
    'hostname --version',
);
#==========================
sub Requires {
    print "$^O hmmm... \nprobably not going to work on your system, will try anyways...\n" if (not $^O =~ /linux/); #not sure if it matters

    my $missing = 0;
    for my $value(values $FILES) {
        do {
            if(not -e -r $value){
                print "Missing file '$value'...\n";
                $missing += 1;
            }
        } if $value;
    }

    for my $elem(@APPS) {
        next if (not $elem);
        my $cmd = (split / /, $elem)[0];
        
        if(not CommandExists($cmd)) {
            $missing++;
            print "Missing command '$cmd'...\n";
        }
    }

    if ($missing) {
        print "$missing dependencie(s)... exiting.\n";
        exit 1;
    }
}

sub CommandExists {
    my $found = 0; my $cmd = $_[0];
    foreach my $bin (@bins) {
        if(-e "$bin/$cmd") {
            $found = 1;
            last;
        }
    }
    return $found;
}

sub OpenFile { 
    my $filename = $_[0]; my $filehandle;
    print "[DBG] openning file $filename..." if $DEBUG;
    if(-e -r $filename) {
        open($filehandle, '<', $filename);
        print "openned.\n" if $DEBUG;
        return $filehandle;
    }
    return undef;
}

sub FirstMatch { #pass (target string, pattern with grouping)
    my $target = $_[0]; my $pattern = $_[1];
    if($target =~ $pattern) {
        return $1;
    } else {
        return undef;
    }
}

sub Startup { #init code here
    print (color 'reset');
    foreach my $arg (@ARGV) {
        if($arg =~ /(-v|--version)/){
            print "What-Is-This (wit) version $wit_version.\n";
            exit 0;
        } elsif($arg =~ /(-h|--help)/){
            print "What-Is-This (wit) version $wit_version.\n";
            print "Help:\n  wit.pl\t<options>";
            print "\n\t-v,--version\tdisplay version and exit";
            print "\n\t-h,--help\tdisplay this help and exit";
            print "\n\t-d,--debug\tturn on debugging text";
            print "\n\t-ns,--noshells\tdont display shells";
            print "\n\t-nl,--nolangs\tdont display scripting languages\n";
            exit 0;
        } elsif($arg =~ /(-d|--debug)/){
            $DEBUG = 1;
        } elsif($arg =~ /(-nl|--nolangs)/){
            $nolangs = 1;
        } elsif($arg =~ /(-ns|--noshells)/){
            $noshells = 1;
        } else {
            print "Invalid option $arg\n";
            exit 1;
        }
    }
}

sub Cleanup { #clean up here
    print (color 'reset');
}
#==========================PROGRAM LISTS
my %LISTS = (
    shells => [
        { name => 'bash', exists => undef, versioncmd => 'bash --version', version => undef },
        { name => 'fish', exists => undef, versioncmd => 'fish --version 2>&1', version => undef },
        { name => 'zsh', exists => undef, versioncmd => 'zsh --version', version => undef },
        { name => 'mksh', exists => undef, versioncmd => undef, version => undef },
        { name => 'tcsh', exists => undef, versioncmd => 'tcsh --version', version => undef },
    ], 
    scripts => [
        { name => 'lua', exists => undef, versioncmd => 'lua -v', version => undef },
        { name => 'perl', exists => undef, versioncmd => 'perl --version', version => undef },
        { name => 'ruby', exists => undef, versioncmd => 'ruby --version', version => undef },
        { name => 'python3', exists => undef, versioncmd => 'python --version 2>&1', version => undef },
        { name => 'python2', exists => undef, versioncmd => 'python2 --version 2>&1', version => undef },
        { name => 'neko', exists => undef, versioncmd => 'neko', version => undef },
        { name => 'haxe', exists => undef, versioncmd => 'haxe', version => undef },
    ], 
);

sub PopulateLists {
    foreach my $vals (keys %LISTS) {
        foreach my $elem ( @{$LISTS{$vals}}) {
            foreach my $bin (@bins) {
                if(-e "$bin/$elem->{name}") {
                    $elem->{exists} = 1;
                    $elem->{name} = ucfirst $elem->{name};
                    $elem->{version} = ((scalar `$elem->{versioncmd}`) =~ $VERSION_MATCH ? $1 : 'unknown');
                    last;
                }
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

my $re_cpu = qr/[\t\:\ ]+(.+)[\W]+/;

sub GetCPUInfo {
    my $buffer = do {
        local $/ = undef;
        my $handle = OpenFile($FILES->{CPUINFO});
        <$handle>;
    };
    if($buffer) {
        $processor->{vendor} = FirstMatch($buffer, qr/vendor_id$re_cpu/im); # $1 if(($buffer =~ qr/vendor_id$re_cpu/im));
        $processor->{name} = FirstMatch($buffer, qr/model name$re_cpu/im);
        $processor->{cores} = FirstMatch($buffer, qr/cpu cores$re_cpu/im);
        {
            my $siblings = ($buffer =~ qr/cpu cores$re_cpu/im ? $1 : $processor->{cores});
            $processor->{ht} = (($processor->{cores} * 2 == $siblings) ? 1 : 0);
        }
        #v- this can probably be rewritten, adding to TODO -v#
        #if(my $handle = OpenFile($FILES->{BIOSLIMIT})) { #get clock freq
            #    print "[DBG] fetching freq from bios_limit...\n" if $DEBUG;
            #    $processor->{freq} = (scalar <$handle>) / (1000**2);
            #    close($handle);
            #} else {
            $processor->{freq} =  FirstMatch($buffer, qr/cpu MHz$re_cpu/im) / 1000;# Awk((grep(/cpu MHz/, @buffer))[0], ': ', 1) / 1000;
            #}
        $processor->{freq} = sprintf('%0.2f', $processor->{freq});
        #-^
    }
    undef $buffer;
}
#==========================OPERATING SYSTEM
my $os = {
    userhost => undef,
    kernel => undef,
    distro => undef,
    distro_version => undef,
    package_count => undef,
};

my $re_distro = qr/([\w\.\ ]+)[^\n]?/im;

sub GetOSInfo {
    my $buffer = do {
        local $/ = undef;
        my $handle = OpenFile($FILES->{VERSION});
        <$handle>;
    };
    $os->{kernel} = FirstMatch($buffer, qr/^([\w]+) version /im) . ' ' . FirstMatch($buffer, qr/version $VERSION_MATCH/im);
    $os->{userhost} = FirstMatch(`whoami`, qr/([A-Za-z0-9\.\_\-\ ]+)/);

    $buffer = do {
        local $/ = undef;
        my $handle = OpenFile($FILES->{LSBR});
        <$handle>;
    };

    $os->{distro} = FirstMatch($buffer, qr/DISTRIB_ID=$re_distro/im);
    $os->{distro_version} = FirstMatch($buffer, qr/DISTRIB_RELEASE=$re_distro/im)
                            . ' ' . FirstMatch($buffer, qr/DISTRIB_CODENAME=$re_distro/im);
    
    undef $buffer;
    my @packages = 0;
    if(CommandExists('pacman')) { #Good ol' Arch
        @packages = (`pacman -Qq`);
    } elsif (-e -d '/var/log/packages') { #Debian
        @packages = (`ls -1 /var/log/packages`);
    } elsif(-e -d '/var/db/pkg/') { #Gentoo
        @packages = (`ls -d /var/db/pkg/*/*`);
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
    man => undef,
    part => undef,
    speed => undef,
    ram_used => undef,
    ram_total => undef,
    swap_used => undef,
    swap_total => undef,
    slots => undef,
    chips => undef,
    type => undef,
};

my $re_number = qr/[\s]+([\d]+)/;

sub GetMemInfo {
    my $buffer = do {
        local $/ = undef;
        my $handle = OpenFile($FILES->{MEMINFO});
        <$handle>;
    };

    $memory->{ram_total} = FirstMatch($buffer, qr/MemTotal:[\s]+([\d]+)/im);
    {
        my $buffers = FirstMatch($buffer, qr/Buffers:$re_number/im);
        my $cached = FirstMatch($buffer, qr/Cached:$re_number/im);
        my $memfree = FirstMatch($buffer, qr/MemFree:$re_number/im);
        $memory->{ram_used} =int(($memory->{ram_total} - ($buffers + $cached + $memfree)) / 1024);
    }
    $memory->{ram_total} = int($memory->{ram_total} / 1024);

    $memory->{swap_total} = FirstMatch($buffer, qr/SwapTotal:$re_number/im); #Awk((grep(/SwapTotal/, @buffer))[0], $re_number, 1);
    {
        my $cached = FirstMatch($buffer, qr/SwapCached:$re_number/im);
        my $swapfree = FirstMatch($buffer, qr/SwapFree:$re_number/im);
        $memory->{swap_used} = int( ($memory->{swap_total} - ($swapfree + $cached)) / 1024);
    }
    $memory->{swap_total} = int($memory->{swap_total} / 1024);
}

#==========================WRITE OUTPUT/MAIN
Requires();
Startup();

PopulateLists();
GetCPUInfo();
GetMemInfo();
GetOSInfo();

sub PrintList {
    my $list = $_[0]; my $count = 0;
    foreach my $elem (@{$list}) {
        if($elem->{exists}) {
            print "\n\t" if $count++;
            print "${subtitle_color}$elem->{name}\t\t";
            print "${value_color}[$elem->{version}]";
        }
    }
}
    
print "${title_color}Operating System-\n";
print "${subtitle_color}\tDistro\t\t${value_color}$os->{distro} $os->{distro_version}\n" if ($os->{distro});
print "${subtitle_color}\tKernel\t\t${value_color}$os->{kernel}\n" if ($os->{kernel});
print "${subtitle_color}\tUser\@Host\t${value_color}$os->{userhost}\n"  if ($os->{userhost});
print "${subtitle_color}\tPackages\t${value_color}$os->{package_count}\n" if $os->{package_count};

if(not $noshells) {
    print "${title_color}Shells-\n\t";
    PrintList($LISTS{shells});
    print "\n";
}
if(not $nolangs) {
    print "${title_color}Script Langs-\n\t";
    PrintList($LISTS{scripts});
    print "\n";
}

print "${title_color}Processor-\n\t";
print "${subtitle_color}Vendor\t${value_color}\t$processor->{vendor}\n\t" if ($processor->{vendor});
print "${subtitle_color}Model\t${value_color}\t$processor->{name}\n\t" if ($processor->{name});
do {
    print "${subtitle_color}Details\t${value_color}\t";
    print "$processor->{cores}-Cores " if ($processor->{cores});
    print "\@$processor->{freq}GHz " if ($processor->{freq});
    print ($processor->{ht} ? "HyperThreaded\n" : "\n");
} if( ($processor->{cores} or $processor->{freq} or $processor->{ht}) );

print "${title_color}Memory-\n";
print "\t${subtitle_color}Ram\t${value_color}\t$memory->{ram_used}M/$memory->{ram_total}M\n" if $memory->{ram_total};
print "\t${subtitle_color}Swap\t${value_color}\t$memory->{swap_used}M/$memory->{swap_total}M\n" if $memory->{swap_total};

Cleanup();
