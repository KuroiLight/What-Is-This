#!/usr/bin/perl

use Cwd qw/ abs_path /;
use autodie;
use File::Temp qw/ tempfile /;
use File::Copy qw/ copy /;

#########
# wit installer script [WIP]
#########

my $install = 0;
my $uninstall = 0;

my $ISROOT = (($> + $<) ? 0 : 1);

my $wit_bin = '/usr/bin/wit';
my $wit_path = abs_path('') . '/wit.pl';

foreach my $arg (@ARGV) {
    if($arg =~ qr/u/i) {
        $uninstall = 1;
    } elsif ($arg =~ qr/i/i) {
        $install = 1;
    } elsif ($arg =~ qr/h/i) {
        print "This script will symlink wit.pl to /usr/bin/wit.\nThis script must be run as root.";
        print "\n\t-u\t uninstall link from bin directory";
        print "\n\t-i\t install link to bin directory";
        print "\n\t-h\t display this help\n";
        exit 0;
    }
}

if(not $ISROOT) {
    print "Must run this setup as root to install.\n";
}

sub IsInstalled {
    if(-e $wit_bin) {
        print "$wit_bin is installed.\n";
        return 1;
    }
    print "$wit_bin is not installed.\n";
    return 0;
}

sub Uninstall {
    if(not IsInstalled) {
        print "Exiting...\n";
        exit 0;
    }
    print "unlinking...\n";
    unlink $wit_bin or warn "could not unlink file..\n";
}

sub Install {
    if(IsInstalled) {
        print "Exiting...\n";
        exit 0;
    }
    print "symlinking...\n";
    symlink ($wit_path, $wit_bin) or warn "could not link file..\n";
}

if(not -e -r $wit_path) {
    print "[error] script not found, exiting.\n";
    exit 1;
}

if($install) {
    Install();
} elsif($uninstall) {
    Uninstall();
} else {
    IsInstalled();
}
