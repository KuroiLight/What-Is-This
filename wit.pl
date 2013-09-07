#!/usr/bin/perl
###
#   What Is This (wit)
#   Simple Fast System Information
#   This file and its accompanying files are Licensed under the MIT License.
#   Written by: Kuroilight@openmailbox.org
###
my $DEBUG = 1;
use Term::ANSIColor;
($DEBUG ? do {use warnings;} : undef);
($DEBUG ? do {use strict;} : do {use 5.010;});
#GLOBALS
my $wit_version = '0.41.2';
my @bins = split /:/, $ENV{PATH}; # get bin directories
my $noshells = 0;
my $nolangs = 0;
my $nohardware = 0;
#colors
my $bCOLORS256 = 1;
if($] < 5.018) { $bCOLORS256 = 0; } #ansi rgb wasnt available til around 5.18
my $title_color = color ( $bCOLORS256 ? 'rgb125' : 'blue');
my $subtitle_color = color ( $bCOLORS256 ? 'rgb224' : 'green');
my $value_color = color ( $bCOLORS256 ? 'rgb134' : 'cyan');

#depend
my $FILES = {
    MEMINFO => '/proc/meminfo',
    CPUINFO => '/proc/cpuinfo',
    DMIID => '/sys/class/dmi/id/',
    LSBR => '/etc/lsb-release',
    VERSION => '/proc/version',
};
my @APPS = (
    'whoami',
    'hostname',
);
#==========================
sub Requires {
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
    if(-e -r $filename) {
        open($filehandle, '<', $filename);
        return $filehandle;
    }
    return undef;
}

sub ReadFile {
    return do {
        local $/ = undef;
        my $handle = OpenFile($_[0]);
        <$handle>;
    };
}


sub FirstMatch { #pass (target string, pattern with grouping)
    return ($_[0] =~ $_[1] ? $1 : undef);
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
            #print "\n\t-d,--debug\tturn on debugging text";
            print "\n\t-ns,--noshells\tdont display shells";
            print "\n\t-nl,--nolangs\tdont display scripting languages\n";
            exit 0;
        } elsif($arg =~ /(-d|--debug)/){
            $DEBUG = 1;
        } elsif($arg =~ /(-nl|--nolangs)/){
            $nolangs = 1;
        } elsif($arg =~ /(-ns|--noshells)/){
            $noshells = 1;
        } elsif($arg =~ /(-nh|--nohw)/){
            $nohardware = 1;
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
        { name => 'Bash', versioncmd => 'bash --version', version => undef },
        { name => 'Fish', versioncmd => 'fish --version 2>&1', version => undef },
        { name => 'Mksh', versioncmd => '', version => undef }, # <- need suggestions for this
        { name => 'Tcsh', versioncmd => 'tcsh --version', version => undef },
        { name => 'Zsh', versioncmd => 'zsh --version', version => undef },
    ], 
    scripts => [
        { name => 'Falcon', versioncmd => 'falcon -v', version => undef },
        { name => 'HaXe', versioncmd => 'haxe -version 2>&1', version => undef },
        { name => 'Lua', versioncmd => 'lua -v', version => undef },
        { name => 'MoonScript', versioncmd => 'moon -v', version => undef },
        { name => 'Neko', versioncmd => 'neko', version => undef },
        { name => 'Perl5', versioncmd => 'perl --version', version => undef },
        { name => 'Perl6', versioncmd => 'perl6 -v', version => undef },
        { name => 'Python2', versioncmd => 'python2 --version 2>&1', version => undef },
        { name => 'Python3', versioncmd => 'python --version 2>&1', version => undef },
        { name => 'Ruby', versioncmd => 'ruby --version', version => undef },
        { name => 'Squirrel', versioncmd => 'squirrel -v', version => undef },
    ], 
);

my $re_versionmatch = qr/([0-9]+\.[0-9]+\.?[0-9]+?)/;

#disk bottle neck at |-e "$bin/$r"|

sub PopulateLists {
    foreach my $vals (keys %LISTS) {
        foreach my $elem ( @{$LISTS{$vals}}) {
            foreach my $bin (@bins) {
                my $r = (split(' ', $elem->{versioncmd}))[0];
                if($r and -e "$bin/$r") {
                    $elem->{version} = ((scalar `$elem->{versioncmd}`) =~ $re_versionmatch ? $1 : undef);
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
my $re_remove_ghz = qr/\ \@.+/;

sub GetCPUInfo {
    my $buffer = ReadFile($FILES->{CPUINFO});
    if($buffer) {
        $processor->{vendor} = FirstMatch($buffer, qr/vendor_id$re_cpu/m);
        $processor->{name} = FirstMatch($buffer, qr/model name$re_cpu/m);
        $processor->{name} = (split(/$re_remove_ghz/, $processor->{name}))[0]; #remove intels ghz ending (temporary fix)
        $processor->{cores} = FirstMatch($buffer, qr/cpu cores$re_cpu/m);
        {
            my $siblings = ($buffer =~ qr/siblings$re_cpu/m ? $1 : $processor->{cores});
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

my $re_anyword = qr/([\w\.\ \_\-]+)/;

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

my $re_distro = qr/([\w\.\ ]+)[^\n]?/m;

sub GetOSInfo {
    my $buffer = ReadFile($FILES->{VERSION});
    if($buffer) {
        $os->{kernel} = FirstMatch($buffer, qr/^([\w]+) version /im) . ' ' . FirstMatch($buffer, qr/version $re_versionmatch/im);
        undef $buffer;
    }
    $os->{userhost} = FirstMatch(`whoami`, qr/([A-Za-z0-9\.\_\-\ ]+)/);
    {
        my $host_name = FirstMatch(`hostname`, qr/([A-Za-z0-9\.\_\-\ ]+)/);
        $os->{userhost} .= ($host_name ? "\@$host_name" : '');
    }

    $buffer = ReadFile($FILES->{LSBR});
    if($buffer) {
        $os->{distro} = FirstMatch($buffer, qr/DISTRIB_ID=$re_distro/m);
        $os->{distro_version} = FirstMatch($buffer, qr/DISTRIB_RELEASE=$re_distro/m) . ' ' . FirstMatch($buffer, qr/DISTRIB_CODENAME=$re_distro/m);
        undef $buffer;
    }
    
    my @packages = 0;
    if(CommandExists('pacman')) { #Good ol' Arch
        @packages = (`pacman -Qq`);
    } elsif (CommandExists('dpkg')) { #Ubuntu
        @packages = (grep (/ii/, `dpkg -l`));
    } elsif (-e -d '/var/log/packages') { #Debian
        @packages = (`ls -1 /var/log/packages`);
    } elsif(-e -d '/var/db/pkg/') { #Gentoo
        @packages = (`ls -d -1 /var/db/pkg/*/*`);
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
    my $buffer = ReadFile($FILES->{MEMINFO});
    if($buffer) {
        $memory->{ram_total} = FirstMatch($buffer, qr/MemTotal:[\s]+([\d]+)/im);
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

sub PrintEntry {
    if($_[1]) {
        print "\t${subtitle_color}${_[0]}\t" . ((length($_[0]) >= 8) ? '' : "\t") . "${value_color}${_[1]}\n";
    }
}

sub PrintList {
    my $list = $_[0]; my $count = 0;
    foreach my $elem (@{$list}) {
        if($elem->{version}) {
            PrintEntry($elem->{name}, 'v' . $elem->{version});
        }
    }
}

sub HasContents {
    my $count = 0;
    foreach my $elem (values %{$_[0]}) {
        if($elem) { $count++; }
    }
    return $count;
}
#==========================WRITE OUTPUT/MAIN
Requires();
Startup();

PopulateLists();
GetCPUInfo();
GetMemInfo();
GetOSInfo();
GetMoboInfo();

if(HasContents($os)) {
    print "${title_color}Operating System-\n";
    PrintEntry('Distro', ($os->{distro} ? "$os->{distro} " : undef) . $os->{distro_version});
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
    if(HasContents($memory)) {
        print "${title_color}Memory-\n";
        PrintEntry('Ram', ($memory->{ram_total} ? "$memory->{ram_used}M/$memory->{ram_total}M" : undef));
        PrintEntry('Swap', ($memory->{swap_total} ? "$memory->{swap_used}M/$memory->{swap_total}M" : undef));
    }
}

Cleanup();
