#!/usr/bin/perl
my $DEBUG = 0; #set to 1 to enable verbose output (needs a switch)
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
my $wit_version = '0.35.0';
my $HASROOT = ($< + $>) ? 0 : 1; # check for root
my @bins = split /:/, $ENV{PATH}; # get bin directories

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
    ( $HASROOT ? 'dmidecode --version' : undef ), #requires root so I need a non-root replacement
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
        $found = 0;
        foreach my $bin (@bins) {
            if(-e "$bin/$cmd") {
                $found = 1;
                last;
            }
        }
        if(not $found) {
            $missing++;
            print "Missing command '$cmd'...\n";
        }
    }

    if ($missing) {
        print "$missing dependencie(s)... exiting.\n";
        exit 1;
    }
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

#this sub feels like awk, which is the reason for the name, may change later
sub Awk { #pass (target text, pattern, index) if target is `command` or <file> use scalar.
    my $target = $_[0]; my $result; my $pattern = $_[1]; my $index = $_[2];
    if ($DEBUG) {
        print ("[DBG] Awk($target, $pattern, $index);\n[DBG] possible matches ");
        foreach my $elem(split($pattern, $target)) {
            print "$elem | ";
        }
    }
    $result = ( split /$pattern/, $target )[$index];
    $result = TrimWhite($result) if $result;
    print "\nreturned " . ($result ? "'$result'" : 'undef') . "\n" if $DEBUG;
    return $result; 
}

sub TrimWhite { #pass (target text)
    return (split($LEADING_TRAILING_WHITESPACE, $_[0]))[0];
}

sub Startup { #init code here
    print (color 'reset');
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
    ],
);

sub PopulateLists {
    foreach my $vals (keys %LISTS) {
        foreach my $elem ( @{$LISTS{$vals}}) {
            foreach my $bin (@bins) {
                if(-e "$bin/$elem->{name}") {
                    $elem->{exists} = 1;
                    $elem->{name} = ucfirst $elem->{name};
                    $elem->{version} = ($elem->{versioncmd} ? Awk(scalar `$elem->{versioncmd}`, $VERSION_MATCH, 1) : 'unknown');
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

sub GetCPUInfo {
    my $ahandle = OpenFile($FILES->{CPUINFO});
    my @buffer = <$ahandle>;
    close($ahandle);
    if(@buffer) {
        $processor->{vendor} = Awk((grep(/vendor_id/, @buffer))[0], ': ', 1); #grab vendor name
        $processor->{name} = Awk((grep(/model name/, @buffer))[0], ': ', 1); #model name
        $processor->{cores} = Awk((grep(/cpu cores/, @buffer))[0], ': ', 1); #core count
        do {$processor->{ht} = 1; $processor->{cores} /= 2; } if(Awk((grep(/siblings/, @buffer))[0], ': ', 1) == ($processor->{cores} * 2)); #check for hyperthreading
        if(my $handle = OpenFile($FILES->{BIOSLIMIT})) { #get clock freq
            print "[DBG] fetching freq from bios_limit...\n" if $DEBUG;
            $processor->{freq} = (scalar <$handle>) / (1000**2);
            close($handle);
        } else {
            $processor->{freq} = Awk((grep(/cpu MHz/, @buffer))[0], ': ', 1) / 1000;
        }
        $processor->{freq} = sprintf('%0.2f', $processor->{freq});
    }
    undef @buffer;
}
#==========================OPERATING SYSTEM
my $os = {
    userhost => undef,
    kernel => undef,
    distro => undef,
    distro_version => undef,
};

sub GetOSInfo {
    my $ahandle = OpenFile($FILES->{VERSION});
    my $buffer = <$ahandle>;
    close($ahandle);

    $os->{kernel} = Awk($buffer, ' version ', 0) . ' ' . Awk($buffer, $VERSION_MATCH, 1);
    $os->{userhost} = TrimWhite (`whoami`) . '@' . TrimWhite(`hostname`);

    undef $buffer;

    my $ahandle = OpenFile($FILES->{LSBR});
    my @buffer = <$ahandle>;
    close($ahandle);

    $os->{distro} = Awk((grep(/DISTRIB_ID/, @buffer))[0], '=', 1);
    $os->{distro} =~ s/[Ll]inux//;
    $os->{distro_version} = TrimWhite(Awk((grep(/DISTRIB_RELEASE/, @buffer))[0], '=', 1)) . ' ' . TrimWhite(Awk((grep(/DISTRIB_CODENAME/, @buffer))[0], '=', 1));
    
    undef @buffer;
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

my $re_number = qr/([0-9]+)/;

sub GetMemInfo {
    my $ahandle = OpenFile($FILES->{MEMINFO});
    my @buffer = <$ahandle>;
    close($ahandle);
    $memory->{ram_total} = Awk((grep(/MemTotal/, @buffer))[0], $re_number, 1);

    $memory->{ram_used} = int( ($memory->{ram_total} - 
            (Awk((grep(/Buffers/, @buffer))[0], $re_number, 1)
            + Awk((grep(/Cached/, @buffer))[0], $re_number, 1)
            + Awk((grep(/MemFree/, @buffer))[0], $re_number, 1))
        ) / 1024 );
    
    $memory->{ram_total} = int($memory->{ram_total} / 1024);

    $memory->{swap_total} = Awk((grep(/SwapTotal/, @buffer))[0], $re_number, 1);
    $memory->{swap_used} = int(($memory->{swap_total}
        - (Awk((grep(/SwapFree/, @buffer))[0], $re_number, 1)
        + Awk((grep(/SwapCached/, @buffer))[0], $re_number, 1))
        ) / 1024 );

    $memory->{swap_total} = int($memory->{swap_total} / 1024);
    
    #might not keep this ->v
    if($HASROOT) { #get chip info if we have root.
        my @dmibuf = `dmidecode --type memory`;
        my $index = 0;

        $memory->{slots} = Awk(((grep(/Number Of Devices\:\ /, @dmibuf))[0]), '\: ', 1);
        $memory->{chips} = $memory->{slots} - scalar grep(/No Module Installed/, @dmibuf);
        while(Awk((grep(/Size/, @dmibuf))[$index], '\: ', 1) =~ /No Module Installed/) { #find first installed module
            $index++;
        }
        $memory->{type} = (grep(/Type\:\ /, @dmibuf))[$index+1];
        $memory->{type} = Awk($memory->{type}, '\: ', 1);
        $memory->{type} = TrimWhite($memory->{type});

        $memory->{man} = Awk((grep(/Manufacturer/, @dmibuf))[$index], '\: ', 1);
        $memory->{man} = TrimWhite($memory->{man});

        $memory->{part} = Awk((grep(/Part Number/, @dmibuf))[$index], '\: ', 1);
        $memory->{part} = TrimWhite($memory->{part});

        $memory->{speed} = Awk((grep(/Configured Clock Speed/, @dmibuf))[$index], '\: ', 1);
        $memory->{speed} = (split(/[\s+\n]/, $memory->{speed}))[0];
    }
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

#needs a switch
#print "What Is This\n\twit\t\t[$wit_version]\n";
    
print "${title_color}Operating System-\n";
print "${subtitle_color}\tDistro\t\t${value_color}$os->{distro} $os->{distro_version}\n${subtitle_color}\tKernel\t\t${value_color}$os->{kernel}\n${subtitle_color}\tUser\@Host\t${value_color}$os->{userhost}\n";

print "${title_color}Shells-\n\t";
PrintList($LISTS{shells});
print "\n";

print "${title_color}Script Langs-\n\t";
PrintList($LISTS{scripts});
print "\n";

print "${title_color}Processor-\n\t";
print "${subtitle_color}Vendor\t${value_color}\t$processor->{vendor}\n\t${subtitle_color}Model\t${value_color}\t$processor->{name}\n\t${subtitle_color}Details\t${value_color}\t$processor->{cores}-Cores @ $processor->{freq}ghz" . ($processor->{ht} ? " with hyper-threading\n" : "\n");

print "${title_color}Memory-\n";
if($HASROOT) {
    print "\t${subtitle_color}Modules\t${value_color}\t$memory->{man} $memory->{part} [$memory->{chips}/$memory->{slots}]\n";
    print "\t${subtitle_color}Type\t${value_color}\t$memory->{type} @ $memory->{speed}mhz\n" if $memory->{man};
}
print "\t${subtitle_color}Ram\t${value_color}\t$memory->{ram_used}m/$memory->{ram_total}m\n" if $memory->{ram_total};
print "\t${subtitle_color}Swap\t${value_color}\t$memory->{swap_used}m/$memory->{swap_total}m\n" if $memory->{swap_total};

Cleanup();
