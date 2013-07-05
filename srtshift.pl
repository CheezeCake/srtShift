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

foreach my $exp (@units)
{
    my $val = $ARGV[1];

    $val =~ s/^(\d+\D+)*(\d+)$exp.*$/$2/ or $val = 0;
    push @values, $val;
}

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
        my @tokens = split "#", $line;
        my $nline = "";
        for(my $i = 4; $i >= 0; $i -= 4)
        {
            my $carry = 0;
            $nline = (($i == 0) ? ' --> ' : $tokens[8]).$nline;
            for(my $j = 3; $j >= 0; $j--)
            {
                my $n = ($sign eq '-') ? -$values[$j] : $values[$j];
                my $val = $tokens[$i+$j]+$n+$carry;
                $carry = 0;

                if($j == 3)
                {
                    if($val > 999)
                    {
                        $carry = int($val/1000);
                        $val = $val%1000;
                    }

                    my $length = length $val;
                    if($length != 3) { $val = ('0'x(3-$length)).$val; }

                    $nline = $val.$nline;
                }
                else
                {
                    if(($j != 1) and ($val > 60)) #not for hours
                    {
                        $carry = $val/60;
                        $val = $val%60;
                    }

                    if(length $val == 1) { $val = '0'.$val; }

                    my $s = ':';
                    if($j == 2) { $s = ','; }
                    $nline = $val.$s.$nline;
                }
            }
        }

        print OUT $nline, "\n";
    }
    else
    {
        print OUT $line;
    }
}

close IN;
close OUT;
