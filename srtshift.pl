#!/usr/bin/perl

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

my $ARGC = scalar @ARGV;
(($ARGC == 3) or ($ARGC == 4)) or die "invalid argument list.\n";

($ARGV[0] =~ /\+|-/) or die "invalid argument: $ARGV[0] (expected + or -).\n";
my $sign = $ARGV[0];

my @units = ("h", "m([^s]|\$)", "s", "ms");
my @values;
my $diff = 0;

foreach my $exp (@units)
{
    my $val = $ARGV[1];

    $val =~ s/^(\d+\D+)*(\d+)$exp.*$/$2/ or $val = 0;
    push @values, $val;
}

for(my $i = 0; $i <= 3; $i++)
{
    my $n =  $values[$i];

    if($i == 0) { $n *= 3600; }
    elsif ($i == 1) { $n *= 60; }
    elsif ($i == 3) { $n /= 1000; }
    $diff += $n;
}

if($sign eq '-') { $diff = -$diff; }

(-f $ARGV[2]) or die "$ARGV[2]: no such file.\n";
my $in = $ARGV[2];
my $out = ($ARGC == 4) ? $ARGV[3] : "new_".$ARGV[2];


open IN, "< $in" or die "cannot open $in: $!.\n";
open OUT, "> $out" or die "cannot create the file $out: $!.\n";
while(my $line = <IN>)
{
    if($line =~ s/^(\d\d):(\d\d):(\d\d),(\d{3}).*(\d\d):(\d\d):(\d\d),(\d{3})(.*)$/$1#$2#$3#$4#$5#$6#$7#$8#$9/)
    {
        chomp $line;
        my @tokens = split '#', $line;
        my $nline = '';
        for(my $i = 0; $i <= 4; $i += 4)
        {
            if($i == 4) { $nline .= ' -- > '; }
            my $val = 0.0;

            for(my $j = 0; $j <= 3; $j++)
            {
                my $n = $tokens[$i+$j];

                if($j == 0) { $n *= 3600; }
                elsif ($j == 1) { $n *= 60; }
                elsif ($j == 3) { $n /= 1000; }
                $val += $n;
            }

            my $new = $val+$diff;
            if($new < 0) { $new = 0; }
            my $tmp;

            $tmp = int($new/3600);
            $nline .= sprintf('%.2d', $tmp).':';
            $new -= $tmp*3600;

            $tmp = int($new/60);
            $nline .= sprintf('%.2d', $tmp).':';
            $new -= $tmp*60;

            $tmp = int($new);
            $nline .= sprintf('%.2d', $tmp).',';
            my $v = int($new);
            $new *= 1000;
            $new -= $v*1000;

            $nline .= sprintf('%.3d', $new);
        }

        $nline .= $tokens[8];
        print OUT $nline, "\n";
    }
    else
    {
        print OUT $line;
    }
}

close IN;
close OUT;
