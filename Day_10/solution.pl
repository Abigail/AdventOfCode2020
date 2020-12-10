#!/opt/perl/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

my $max_jump = 3;

#
# Read the input, and put the adapters into an array after sorting. Add the
# outlet and build-in adaptor as well.
#
my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";
chomp (my @adapters = sort {$a <=> $b} <$fh>);
unshift @adapters => 0;
push    @adapters => $max_jump + $adapters [-1];

#
# Count the jumps.
#
my @jumps;
for (my $i = 1; $i < @adapters; $i ++) {
    $jumps [$adapters [$i] - $adapters [$i - 1]] ++;
}
my $solution1 = $jumps [1] * $jumps [3];


#
# For the number of possible permutations, just count backwards.
# From the final adapter (the build-in), to the final adapter, there
# is of course just 1 way.
# Other wise, it's just the sum of the next three (next in chain, the
# previous three calculated), provided the jumps aren't more than 3,
# and we're not past the chain.
#
use List::Util qw [sum];

my @counts;
$counts [@adapters - 1] = 1;
for (my $i = @adapters - 2; $i >= 0; $i --) {
    $counts [$i] = sum map {
        $i + $_ >= @adapters || $adapters [$i + $_] >
                                $adapters [$i] + $max_jump
        ? 0 : $counts [$i + $_]} 1 .. $max_jump;
}
                                   

my $solution2 = $counts [0];

say "Solution 1: ", $solution1;
say "Solution 2: ", $solution2;

__END__
