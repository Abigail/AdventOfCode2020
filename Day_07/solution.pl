#!/opt/perl/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

#
# Blog: https://wp.me/pcxd30-du
#

#
# See https://adventofcode.com/2020/day/7 for the challenge description.
#   

my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";

my %graph;
my %rev_graph;

my $START_COLOUR = "shiny gold";

#
# Parse the input, and construct a DAG (%graph), and its reverse (%rev_graph).
# That is, if "XXX bag contains N YYY bags, M ZZZ bags.", then
#
#     $graph     {XXX} {YYY} = N
#     $graph     {XXX} {ZZZ} = M
#     $rev_graph {YYY} {XXX} = N
#     $rev_graph {ZZZ} {XXX} = M
#

while (<$fh>) {
    /^(?<colour>.*?) \s+ bags \s+ contain \s+ (?<content> .* \.)$/x
        or die "Failed to parse $_";
    my ($colour, $content) = @+ {qw [colour content]};

    $graph {$colour} //= {};

    while ($content =~ s/^\s* (?<amount>       [0-9]+)   \s+
                              (?<inner_colour> [a-z\h]+) \s+
                              bags? [,.]\s*//x) {
        my ($amount, $inner_colour) = @+ {qw [amount inner_colour]};

        $graph     {$colour} {$inner_colour} = $amount;
        $rev_graph {$inner_colour} {$colour} = $amount;
    }
    if ($content && $content ne "no other bags.") {
        die "Failed to parse $_";
    }
}

#
# For part 1, we do a breath first search in %rev_graph, starting
# from "shiny gold", and keeping track of what we can reach.
#

my @todo = keys %{$rev_graph {$START_COLOUR}};
my %seen;

while (@todo) {
    $seen {my $colour = shift @todo} ++;
    push @todo => keys %{$rev_graph {$colour}};
}

#
# For part 2, we do a recursive depth first search in %graph, starting from
# "shiny gold". We return the number of bags when we return from recursion,
# *including* the current bag.
#
sub contains_bags;
sub contains_bags ($colour) {
    use List::Util qw [sum0];
    state $cache;
    $$cache {$colour} //= 
           1 + sum0 map {$graph {$colour} {$_} * contains_bags ($_)}
                  keys %{$graph {$colour}};
}


say "Solution 1: ", scalar keys %seen;
say "Solution 2: ", contains_bags ($START_COLOUR) - 1;


__END__
