#!/opt/perl/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

my $NONE     = 0;
my $EMPTY    = 1;
my $OCCUPIED = 2;
my $WALL     = 3;

my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";

my $grid;
while (<$fh>) {
    chomp;
    push @$grid  => [map {$_ eq "." ? $NONE : $EMPTY} split //];
}

#
# Add a column of "$WALL" to the right, and a row of "$WALL" 
# to the bottom, so we can avoid having to test boundary 
# conditions. Note that an index of -1 means the last element
# of an array, so we just add WALLs to the right and bottom.
#
# In effect, we make this a torus, with seams of all $WALLs.
#
push @$_    =>   $WALL for @$grid;
push @$grid => [($WALL) x scalar @{$$grid [0]}];


#
# Sizes
#
my $WIDTH  = @{$$grid [0]};
my $HEIGHT = @$grid;

#
# Cardinal direction, given in [x, y] values, x, y in {-1, 0, 1}
#
my @directions = ([-1, -1], [-1,  0], [-1,  1],
                  [ 0, -1],           [ 0,  1],
                  [ 1, -1], [ 1,  0], [ 1,  1]);

#
# Run the rules on the grid, until the situation stabilizes.
# Then return the number of occupied seats.
#
sub run ($grid, $tolerance, $beam = 0) {
    my $stable;
    do {
        my $new_grid;
        $stable = 1;
        for my $x (keys @$grid) {
            for my $y (keys @{$$grid [$x]}) {
                my $cell = $$grid [$x] [$y];
                if ($cell == $OCCUPIED || $cell == $EMPTY) {
                    #
                    # Count the number of occupied seats which
                    # can be seen from the seat at position $x, $y.
                    #
                    my $neighbours = 0;
                    foreach my $d (@directions) {
                        my ($dx, $dy) = @$d;
                        #
                        # Find the seat, if any, we need to inspect.
                        # For task 1, that's the position directly
                        # next to the current spot. For part 2, we
                        # shoot a beam until it hits a seat or a wall.
                        #
                        my ($tx, $ty) = ($x + $dx, $y + $dy);

                        if ($beam) {
                            ($tx, $ty) = ($tx + $dx, $ty + $dy) while
                                $$grid [$tx] [$ty] == $NONE;
                        }

                        $neighbours ++
                            if $$grid [$tx] [$ty] == $OCCUPIED;
                    }

                    #
                    # Apply the rules
                    #
                    if ($cell == $EMPTY && $neighbours == 0) {
                        $cell = $OCCUPIED;
                        $stable = 0;
                    }
                    elsif ($cell == $OCCUPIED && $neighbours >= $tolerance) {
                        $cell = $EMPTY;
                        $stable = 0;
                    }
                }
                $$new_grid [$x] [$y] = $cell;
            }
        }
        $grid = $new_grid;
    } until $stable;

    #
    # After stabilization, count the number of occupied seats.
    #
    use List::Util 'sum';
    sum map {scalar grep {$_ == $OCCUPIED} @$_} @$grid;
}

say "Solution 1: ", run $grid, 4, 0;
say "Solution 2: ", run $grid, 5, 1;

__END__
