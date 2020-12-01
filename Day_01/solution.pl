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
#   Part 1
#
#     Given a list of numbers, find a pair which sums to 2020,
#     and return their product.
#
#   Part 2
#
#     Using the same list, find a triple which sums to 2020,
#     and return their product.
#

my $input = shift // "input";

my ($solution1, $solution2);

my $YEAR = 2020;

# 
# Read in the data
#
my %numbers = do {
    open my $fh, "<", $input or die "Failed to open $input: $!";
    map {chomp; ($_ => 1)} <$fh>;
};

#
# Sort the keys
#
my @numbers = sort {$a <=> $b} keys %numbers;

#
# Calculate the product of the pair:
#
#   Loop over the numbers, check whether there's another number
#   so both of them sum to 2020. This is a simple lookup.
#   If found, calculate the product and exit.
#
foreach my $N (@numbers) {
    if ($numbers {$YEAR - $N}) {
        $solution1 = $N * ($YEAR - $N);
        last;
    }
}

#
# Calculate the product of the triple:
#
#    Loop over the numbers. For each number, make a second loop,
#    starting from the first number. Exit inner loop if the two
#    numbers sum to something which exceeds two thirds of 2020
#   (as there won't be a triple with a third, larger, number).
#    Then do a lookup to see whether there is a third number
#    so we have a triple summing to 2020. If so, calculate the
#    product, and exit the outer loop.
#
OUTER:
  for (my $i = 0; $i < @numbers; $i ++) {
    for (my $j = $i + 1; $j < @numbers; $j ++) {
        next OUTER if $numbers [$i] + 2 * $numbers [$j] > $YEAR;
        if ($numbers {$YEAR - $numbers [$i] - $numbers [$j]}) {
            $solution2 = $numbers [$i] *
                         $numbers [$j] *
                        ($YEAR - $numbers [$i] - $numbers [$j]);
            last OUTER;
        }
    }
}


say "Solution 1: ",  $solution1;
say "Solution 2: ",  $solution2;

__END__
