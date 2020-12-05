#!/opt/perl/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

#
# Challenge
#
#   You are given a list of boarding passes.
#
#   Instead of zones or groups, this airline uses binary space
#   partitioning to seat people. A seat might be specified like FBFBBFFRLR,
#   where F means "front", B means "back", L means "left", and R means
#   "right".
# 
#   The first 7 characters will either be F or B; these specify exactly
#   one of the 128 rows on the plane (numbered 0 through 127). Each
#   letter tells you which half of a region the given seat is in. Start
#   with the whole list of rows; the first letter indicates whether the
#   seat is in the front (0 through 63) or the back (64 through 127).
#   The next letter indicates which half of that region the seat is in,
#   and so on until you're left with exactly one row.
#
#   Task 1
#
#      What is the highest seat ID on a boarding pass.
#
#   Task 2
#
#      Find your seat. There may be seats missing at the front or
#      back of the plane. Your seat ID will be missing from the
#      list, but the ids ID+1 and ID-1 will be in the list.
#

#
# Note: The seat IDs are just binary numbers, where B and R are 1,
#       and F and L are 0.
#

my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";
my ($min, $max) = ((1 << 63) - 1, 0);
my  $seat;
my @ids;
while (<$fh>) {
    chomp;
    #
    # Get the numeric id: substitute B/R with 1, F/L with 0,
    # then treat it as a binary number.
    #
    my $id = eval "0b" . y/BFRL/1010/r;

    #
    # Find the minimum and maximum ids, and tick off all found ids.
    #
    $max = $id if $id > $max;
    $min = $id if $id < $min;
    $ids [$id] = 1;
}

#
# For task 2, find an id which isn't on the list, but the ids +/- 1 are.
# This obviously has to be between $min and $max.
#
foreach my $id ($min + 1 .. $max - 1) { 
    if ($ids [$id - 1] && !$ids [$id] && $ids [$id + 1]) {
        $seat = $id;
        last;
    }
}

say "Solution 1: ", $max;
say "Solution 2: ", $seat;

__END__
