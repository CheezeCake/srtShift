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

sub add_leading_zeros
{
    my ($val, $n) = @_;

    for(my $i = 0; $i < $n; $i++)
    {
        $val = '0'.$val;
    }

    return $val;
}

my $ARGC = scalar @ARGV;
(($ARGC >= 3) and ($ARGC <= 4)) or die "invalid argument list.\n";

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

foreach my $n (@values)
{
    print $n, "\n";
}
print "\n";

(-f $ARGV[2]) or die "$ARGV[2]: no such file.\n";
my $in = $ARGV[2];
my $out = ($ARGC == 4) ? $ARGV[3] : "new_".$ARGV[2];


open IN, "< $in" or die "cannot open $in: $!.\n";
while(my $line = <IN>)
{
    if($line =~ s/^(\d\d):(\d\d):(\d\d),(\d{3}).*(\d\d):(\d\d):(\d\d),(\d{3})(.*)$/$1#$2#$3#$4#$5#$6#$7#$8#$9/)
    {
        chomp $line;
        my @tokens = split "#", $line;
        my $nline = "";
        for(my $i = 4; $i >= 0; $i -= 4)
        {
            $nline = (($i == 0) ? ' --> ' : $tokens[8]).$nline;
            for(my $j = 3; $j >= 0; $j--)
            {
                my $n = ($sign eq '-') ? -$values[$j] : $values[$j];
                my $val = $tokens[$i+$j]+$n;

                if($j == 2)
                {
                    if(length $val == 1) { $val = &add_leading_zeros($val, 1); }
                    $nline = $val.','.$nline;
                }
                elsif($j != 3)
                {
                    if(length $val == 1) { $val = &add_leading_zeros($val, 1); }
                    $nline = $val.':'.$nline;
                }
                else
                {
                    my $length = length $val;
                    if($length != 3) { $val = &add_leading_zeros($val, 3-$length); }
                    $nline = $val.$nline;
                }
            }
        }

        print $nline, "\n";
    }
    else
    {
        print $line;
    }
}
close IN;
