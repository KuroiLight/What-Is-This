#!/usr/bin/perl

use Cwd qw/ abs_path /;
use autodie;

my $ISROOT = (($> + $<) ? 0 : 1);

if($ISROOT) {
    print "Must be run as non-root to work correctly...\nExiting...\n";
    exit 1;
}

my $bashrc = abs_path($ENV{HOME} . '/.bashrc');
print "bashrc @ $bashrc\n";
my $wit_path = abs_path('') . '/wit.pl';

my $install = 0;
my $uninstall = 0;

foreach my $arg (@ARGV) {
    if($arg =~ qr/u/i) {
        $uninstall = 1;
        print "Uninstalling...\n";
    } elsif($arg =~ qr/i/i) {
        $install = 1;
        print "Installing...\n";
    } elsif($arg =~ qr/h/i) {
        print "help";
        print "This script will add an entry to your bashrc file,\n that will launch wit, at the of a bash shell.\n";
        print "\n\t-u\t remove bashrc entry";
        print "\n\t-i\t add bashrc entry";
        print "\n\t-h\t display this help";
    }
}

sub IsInstalled {
    open my $hbash, "<", $bashrc or die $!;
    while(my $line = <$hbash>) {
        if($line =~ /($wit_path|^wit$)/) {
            print "entry is present in bashrc.\n";
            return 1;
        }
    }
    print "entry is not present in bashrc.\n";
    close $hbash;
    return 0;
}

sub Install {
    if(IsInstalled()){
        print "Exiting...\n";
        exit 0;
    }
    open my $hbash, ">>", $bashrc or die $!;
    $hbash->print($wit_path);
    close $hbash;
    print "entry added!\n";
}

sub Uninstall {
    if(not IsInstalled()){
        print "Exiting...\n";
        exit 0;
    }
    my @file_contents;
    open my $hbash, "<", $bashrc or die $!;
    if($hbash) {
        @file_contents = <$hbash>;
        close $hbash;
        open my $hbash, ">", $bashrc or die $!;
        foreach my $line (@file_contents) {
            if($line =~ "($wit_path|^wit$)") {
                print "found in bashrc and removed..\n";
            } else {
                $hbash->print($line);
            }
        }
        close $hbash;
    } else {
        print "failed to open bashrc\n";
    }
}

if($install) {
    Install();
} elsif($uninstall) {
    Uninstall();
} else {
    IsInstalled();
}
