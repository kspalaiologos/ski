#!/usr/bin/perl

use strict;
use warnings;

# LOC counter.
my ($loc, $comments) = (0, 0);

# Regexp rules hash
my %rules = ();

# CLI flags.
my %flags = ();

# Combinator list.
my %combinators = ();

# Procedure list.
my %procedures = ();

sub handle {
    my ($s) = @_;

    # 1. Find `#' directives.
    #    They are unoverridable.

    if($s =~ m/^#(.*)$/) {
        my $text = '';

        eval { qr/$1/ };
        die "[skittles] invalid regex: $1" if $@;

        while(<>) {
            $loc++;
            last unless /^[\t ]+/;
            $text .= s/[\t ]//gr;
        }

        $rules{$1} = $text;
        $hits{$1} = 0;

        return;
    }

    # 2. Parse combinator declarations.

    if($s =~ m/%(.)[ \t]*(.*)$/) {
        if(defined $combinators{$1}) {
            die '[skittles]: combinator $1 redefined.';
        }

        $combinators{$1} = $2;
        return;
    }

    # 4. Parse named inline lambda declarations.

    if($s =~ m/\$([0-9A-Za-z_]+)\:(.*)$/) {
        $procedures{$1} = $2;
        return;
    }

    my $changed = 1;
    while($changed > 0) {
        $changed = 0;
        
        foreach my $key (keys %procedures) {
            my $hit = $s =~ s/\b$key\b/$procedures{$key}\n/g;
            $changed = $hit if($changed == 0);
        }

        foreach my $key (keys %combinators) {
            my $hit = $s =~ s/$key/$combinators{$key}\n/g;
            $changed = $hit if($changed == 0);
        }

        foreach my $key (keys %rules) {
            my $hit = $s =~ s/$key/$rules{$key}\n/g;
            $changed = $hit if($changed == 0);
        }
    }

    my @backtrace;

    while($s =~ /\@.*$|[^SK\`\(\) \t\r\n]/gm) {
        my $match = $&;
        
        eval {
            if($match =~ /^\@push (.*)$/) {
                push(@backtrace, $1);
            } elsif($match =~ /^\@pop$/) {
                pop(@backtrace);
            } else {
                die "Syntax error. Unexpected $match at line $..\nStack trace:\n\tat "
                    . join("\n\tat ", @backtrace) . "\n";
            }
        };

        # Catch syntax errors.
        die $@ if $@ =~ /Syntax error/;

        # Internal compiler errors.
        die "ICE: $@" if $@;
    }

    $s =~ s/\n\@.*\n/\n/g if $flags{'-l'};

    print $s;
}

if($ARGV[0] =~ /^-/) {
    my $arg = shift @ARGV;
    $arg =~ s/(.)/$flags{'-' . $1} = 1;/ge;
}

if($flags{'-h'}) {
    print STDERR "skittles - Copyright (C) 2020 by Kamila Szewczyk.\n";
    print STDERR "Licensed under the terms of MIT license.\n\n";
    print STDERR "stage1 - filter out comments, parse #-directives.\n\n";
    print STDERR "Usage:\n";
    print STDERR "  ./stage1.pl [-h/-s] FILE1 FILE2 ...\n\n";
    print STDERR "  -h     - display this listing.\n";
    print STDERR "  -s     - display statistics (LOC, comments, perf, pattern hits).\n";
    print STDERR "  -l     - disable emitting line numbers.\n";

    die;
}

while(<>) {
    $loc++;
    s/;(.*)$//g and $comments++;
    handle($_);
}
