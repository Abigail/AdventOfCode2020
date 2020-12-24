#!/opt/perl/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

my $DAYS = 100;

my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";

#
# We're opting to use the axial coordinate system from 
# https://www.redblobgames.com/grids/hexagons/#coordinates-axial,
# but we skew the axis, so we have a north-south and an east-west
# axis -- and we have neigbhours on the ne-sw axis.
#
#    North:  Negative y
#    South:  Positive y
#    East:   Positive x
#    West:   Negative x
#

my %tiles;

while (<$fh>) {
    chomp;
    #
    # Turn 'nw' to 'n', and 'se' to 's'.
    #
    s [(?|(n)w|(s)e)] [$1]g;
    my @p = (0, 0);
    foreach my $step (split //) {
        if    ($step eq 'e') {$p [0] ++}
        elsif ($step eq 'w') {$p [0] --}
        elsif ($step eq 'n') {$p [1] --}
        elsif ($step eq 's') {$p [1] ++}
    }
    if ($tiles {"@p"}) {
        delete $tiles {"@p"}
    }
    else {
        $tiles {"@p"} ++;
    }
}

say "Solution 1: ", scalar keys %tiles;

sub neighbours ($cell) {
    my ($x, $y) = split / / => $cell;
    map {join $", @$_} [$x,     $y + 1],     # South
                       [$x,     $y - 1],     # North
                       [$x + 1, $y],         # East
                       [$x - 1, $y],         # West
                       [$x + 1, $y - 1],     # North-East
                       [$x - 1, $y + 1];     # South-West
}
    

#
# Let's play the game of life again!
#
foreach my $day (1 .. $DAYS) {
    my %count;
    foreach my $cell (keys %tiles) {
        $count {$cell} ||= 0; # Make sure the current cell is there as well.
        foreach my $neighbour (neighbours $cell) {
            $count {$neighbour} ++;
        }
    }
    my %new_tiles = %tiles;
    foreach my $cell (keys %count) {
        if ($count {$cell} == 2 && !$tiles {$cell}) {
            $new_tiles {$cell} = 1;
        }
        if ($tiles {$cell} && (!$count {$cell} || $count {$cell} > 2)) {
            delete $new_tiles {$cell};
        }
    }
    %tiles = %new_tiles;
}

say "Solution 2: ", scalar keys %tiles;


__END__
