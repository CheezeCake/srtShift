#!/usr/bin/perl -w

# srtShift is a simple tool to shift time or resync srt subtitle files (SubRip)

# The MIT License (MIT)
#
# Copyright (c) <2013> <CheezeCake>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

use strict;
#use diagnostics;

my $ARGC = scalar @ARGV;
(($ARGC >= 3) and ($ARGC <= 4)) or die "invalid argument list.\n";

($ARGV[0] =~ /\+|-/) or die "invalid argument: $ARGV[0] (expected + or -).\n";
my $sign = $ARGV[0];

my %units = (
                "h" => "h",
                "m" => "m[^s]",
                "s" => "s",
                "ms" => "ms"
            );
my %values;

while((my $symbol, my $exp) = each %units)
{
    my $val = $ARGV[1];

    $val =~ s/^(\d+\D)*(\d+)$exp.*$/$2/ or $val = 0;
    $values{$symbol} = $val;
}

(-f $ARGV[2]) or die "$ARGV[2]: no such file.\n";
my $in = $ARGV[2];
my $out = ($ARGC == 4) ? $ARGV[3] : "new_".$ARGV[2];


open IN, "< $in" or die "cannot open $in: $!.\n";
while (my $line = <IN>)
{
    ;
}
close IN;
