#!/opt/perl/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

#
# Blog: https://wp.me/pcxd30-aq
#

#
# Challenge:
#
#    Given a map of open squares (.) and trees (#), determine the
#    number of trees you hit if you go down the map in a straight,
#    sloped line. The map is on a cylinder, that is, if you run off
#    from one side, you reappear on the other.
#
#    We need to determine the number of trees hit when using slopes of:
#
#       [right 1, down 1],
#       [right 3, down 1],
#       [right 5, down 1],
#       [right 7, down 1],
#       [right 1, down 2],
#
#    We only count the trees if we hit an integer square.
#
#    For part 1, count the trees hit by slope [right 3, down 1].
#    For part 2, return the product of the number of trees hit
#                by travelling down all the slopes.
#

#
# We will solve this by processing all the lines one-by-one; we
# count the number of trees hit on that line for all the slopes.
# Hence, we don't need to read in all the lines, we can discard
# a line before reading the next.
#
# Given a Nth line (0-based), and a slope [x, y] (that is, move
# right x steps, and down y steps), which position we need to
# examine? 
#
# First, we need to determine whether we need to examine the line.
# If the slope goes y rows down in each step, we only need to 
# check each yth line (this assumes the right/down ratio given for
# the slope are for right, down which are relative prime, which they
# are for the challenge). Perl uses $. to tell you the line number
# of the read input, but it's 1-based. So, we don't look for a tree
# if, for a given slope ($x, $y) and line number $., ($. - 1) % $y.
#
# Now we need to find the position in the string. We calculate how
# far to the right we are, which is ($x * (($. - 1) / $y), as we
# are moving $x positions to the right, for each $y rows going down.
# Then, since we are on a cylinder, we have to mod this with the
# length of the string.
#

use List::Util qw [product];

my $input = shift // "input";

open my $fh, "<", $input or die "open: $!";

my @slopes = ([1, 1], [3, 1], [5, 1], [7, 1], [1, 2]); # Given.
my @trees  = (0) x @slopes;

while (<$fh>) {
    chomp;
    foreach my $index (keys @slopes) {
        my ($x, $y) = @{$slopes [$index]};
        next if ($. - 1) % $y;  # Only check every y-th row.
        $trees [$index] ++
              if substr ($_, ($x * (($. - 1) / $y)) % length, 1) eq "#";
    }
}


say "Solution 1: ", $trees [1];
say "Solution 2: ", product @trees;


__END__
