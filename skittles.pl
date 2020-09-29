#!/usr/bin/perl

use strict;
use warnings;

# LOC counter.
my ($loc, $comments) = (0, 0);

# Regexp rules hash
my %rules = ();
my %hits = ();

# CLI flags.
my %flags = ();

# Combinator list.
my %combinators = ();
my %combhits = ();

# Procedure list.
my %procedures = ();
my %lhits = ();

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

        handle($_);

        return;
    }

    # 2. Parse combinator declarations.

    if($s =~ m/%(.)[ \t]*(.*)$/) {
        if(defined $combinators{$1}) {
            die '[skittles]: combinator $1 redefined.';
        }

        $combinators{$1} = $2;
        $combhits{$1} = 0;

        return;
    }

    # 3. Parse named lambda declarations.

    if($s =~ m/\$(\p{L}+)$/) {
        my $text = '';

        while(<>) {
            $loc++;
            last unless /^[\t ]+/;
            $text .= s/[\t ]//gr;
        }

        $procedures{$1} = $text;
        $lhits{$1} = 0;

        handle($_);

        return;
    }

    # 4. Parse named inline lambda declarations.

    if($s =~ m/\$(\p{L}+)\:(.*)$/) {
        $procedures{$1} = $2;
        $lhits{$1} = 0;

        return;
    }

    foreach my $key (keys %rules) {
        $hits{$key} += $s =~ s/$key/\n\@push #$key\n$rules{$key}\@pop\n/g;
    }
    
    foreach my $key (keys %procedures) {
        $lhits{$key} += $s =~ s/\b$key\b/\n\@push \$$key\n$procedures{$key}\@pop\n/g;
    }

    foreach my $key (keys %combinators) {
        $combhits{$key} += $s =~ s/$key/\n\@push \%$key\n$combinators{$key}\n\@pop\n/g;
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

sub listhits {
    my $c = '';
    my (%list) = @_;

    foreach my $key (keys %list) {
        $c .= " * $key: $list{$key}\n"
    }

    return $c;
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

END {
    $loc -= $comments;

    print STDERR "\nDone."
        . "\n * $loc lines of code."
        . "\n * $comments comments."
        . "\n * " . (time - $^T) . " second elapsed, "
                  . int(($loc + $comments) * 100 / (time - $^T + 1)) / 100 . " lines/s"
        . "\n * " . (scalar keys %rules) . " rules registered."
        . "\n * " . (scalar keys %combinators) . " combinators registered."
        . "\n * " . (scalar keys %procedures) . " named expressions registered."
        . "\n\nMacro Hits:\n"
        . listhits(%hits)
        . "\n\nCombinator Hits:\n"
        . listhits(%combhits)
        . "\n\nNamed lambda Hits:\n"
        . listhits(%lhits)
    if $flags{'-s'};
}
