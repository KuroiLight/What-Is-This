#!/usr/bin/perl

use Cwd qw/ abs_path /;
use autodie;
use File::Temp qw/ tempfile /;
use File::Copy qw/ copy /;

#########
# wit installer script [WIP]
#########

my $install_bin = 0;
my $install_bash = 0;
my $check_install = 0;
my $uninstall = 0;

foreach my $arg (@ARGV) {
    if($arg =~ qr/u/i) {
        $uninstall = 1;
    }
    if($arg =~ qr/i/i) {
        $install_bin = 1;
        print "Will add bin link.\n";
    }
    if($arg =~ qr/b/i) {
        $install_bash = 1;
        print "Will add bash startup entry.\n";
    }
    if($arg =~ qr/s/i) {
        $check_install = 1;
        print "Will check if installed...\n";
    }
    if($arg =~ qr/h/i) {
        print "help";
        print "\n\t-u\t uninstall it from both (has priority)";
        print "\n\t-i\t install link to bin directory";
        print "\n\t-b\t add to bash startup";
        print "\n\t-s\t check if installed";
        print "\n\t-h\t display this help";
    }
}

if(not $install_bin and not $install_bash and not $check_install and not $uninstall) {
    print "[error] No options selected, exiting.\n";
    exit 1;
}

if($check_install) {
    my $wit_bin = '/usr/bin/wit'; my $bashrc = abs_path($ENV{HOME} . '/.bashrc');
    if(-e -l $wit_bin) {
        print "Wit is linked in '/usr/bin'.\n";
        $install_bin = 0;
    } else {
        print "Wit is not linked in '/usr/bin'. \n";
    }

    open my $hbash, "<", $bashrc or die $!;
    while(my $line = <$hbash>) {
        if($line eq $wit_path or $line eq 'wit') {
            print "Wit is included in your bashrc.\n";
            $install_bash = 0;
            last;
        }
    }
    close $hbash;
}

if($uninstall) {
    my $wit_bin = '/usr/bin/wit'; my $bashrc = abs_path($ENV{HOME} . '/.bashrc');
    if(-e -l $wit_bin) {
        print "Wit is linked in '/usr/bin'.\n";
    } else {
        print "Wit is not linked in '/usr/bin'. \n";
    }
    my @file_contents;
    open my $hbash, "<", $bashrc or die $!;
    if($hbash) {
        @file_contents = <$hbash>;
        close $hbash;
        open my $hbash, ">", $bashrc or die $!;
        foreach my $line (@file_contents) {
            if($line =~ /hello/) {
                print "found in bashrc and removing..\n";
            } else {
                $hbash->print($line);
            }
        }
        close $hbash;
    }
}

my $dir = abs_path('');
my $wit_path = $dir . '/wit.pl';

if(not -e -r $wit_path) {
    print "[error] script not found, exiting.\n";
    exit 1;
}

if($install_bash) {
    my $bashrc = abs_path($ENV{HOME} . '/.bashrc');
    print "bashrc at $bashrc\n";
    my $wit = ($install_bin ? 'wit' : $wit_path);
    print "adding bash entry.\n";
    if(not -e $bashrc) {
        print "[warning] $bashrc not found, creating...\n";
        open my $file, '>', $bashrc;
    }
    if(not -r -w $bashrc) {
        print "[error] Can't read/write to $bashrc, exiting.\n";
    }
    {
        open my $hbash, "+<", $bashrc or die $!;

        my $already_added = 0;
        while(my $line = <$hbash>) {
            if($line eq $wit_path or $line eq 'wit') {
                $already_added = 1;
                last;
            }
        }

        seek($hbash, 0, 2);

        if(not $already_added) {
            $hbash->print($wit);
        } else {
            print "Already present in bashrc, skipping..\n";
        }
        close $hbash;
    }
}

if($install_bin) {
    my $usrbin = '/usr/bin';
    print "adding link in bin directory.\n";
    if(-e "$usrbin/wit") {
        print "already linked in /usr/bin.\n";
    } else {
        symlink $wit_path, "$usrbin/wit";
    }
}

print "Complete...\n";
