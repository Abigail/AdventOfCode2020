#!/opt/perl/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

#
# Given a set of ranges, return a sub which returns 1 if
# a given value falls in one of the ranges -- 0 otherwise.
#
sub in_ranges (@ranges) {
    sub ($value) {
        foreach my $range (@ranges) {
            return 1 if $$range [0] <= $value <= $$range [1]
        }
        return 0;
    }
}

#
# Read the input, and parse the sections
#
my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";

#
# First, parse the rules; turn the ranges into a closure which
# returns true if a give values falls in at least one range.
#
my %fields;
while (<$fh>) {
    last unless /\S/;
    my ($field, $ranges) = split /\s*:\s*/;
    my  @ranges = map {[split/-/]} split /\s+or\s+/ => $ranges;
    $fields {$field} = in_ranges (@ranges);
}

#
# Read our ticket.
#
<$fh>;  # "your ticket"
my @ticket = <$fh> =~ /[0-9]+/g;

#
# Read the nearby tickets.
#
<$fh>;  # Blank line
<$fh>;  # "nearby tickets"
my @nearby_tickets = map {[/[0-9]+/g]} <$fh>;


my $invalid = 0;  # Accumulator of the values of all fields which
                  # cannot be valid. (Part 1)

#
# For each position $p in the ticket, $possibilities [$p] contains a
# hash of what the field(s) may be on position $p. Initially, each
# field is a possibility everywhere.
#
my @possibilities = map {{map {$_ => 1} keys %fields}} @ticket;


foreach my $nearby_ticket (@nearby_tickets) {
    #
    # First check if the ticket contains any fields which
    # cannot be valid regardless of the field. If so,
    # invalidate the ticket, and add the value of the field
    # to the invalid accumulator.
    #
    # We are making the assumption that a ticket may contain
    # more than one entry which cannot be valid; if so, we add
    # each such entry to the accumulator.
    #
    my $is_valid_ticket = 1;
    foreach my $index (keys @$nearby_ticket) {
        my $value = $$nearby_ticket [$index];
        if (!grep {$_ -> ($value)} values %fields) {
            $invalid += $value;
            $is_valid_ticket = 0;
        }
    }
    #
    # Don't continue if the ticket is not valid.
    #
    next unless $is_valid_ticket;

    #
    # Now, check each variable again, against what still is
    # possible. Cross off posibilities which aren't valid.
    #
    foreach my $index (keys @$nearby_ticket) {
        my $value = $$nearby_ticket [$index];
        foreach my $field (keys %{$possibilities [$index]}) {
            delete $possibilities [$index] {$field} unless
                   $fields {$field} -> ($value);
        }
    }
}

#
# Now, trim down the number of possibilities.
# For all positions we have one possibile field left, remove
# that field from all other positions as a posibility.
#
my @todo = grep {keys %{$possibilities [$_]} == 1} keys @possibilities;

while (@todo) {
    my  $index  = shift @todo;
    my ($field) = keys %{$possibilities [$index]};
    foreach my $i (keys @possibilities) {
        next if $i == $index || !$possibilities [$i] {$field};
        delete $possibilities [$i] {$field};
        push @todo => $i if keys %{$possibilities [$i]} == 1;
    }
}

#
# Magically, we have one field per positions left, and creating the
# final answer is easy.
#

use List::Util qw [product];

say "Solution 1: ", $invalid;
say "Solution 2: ", product map  {$ticket [$_]}
                            grep {my ($field) = keys %{$possibilities [$_]};
                                  $field =~ /^departure/}
                            keys @ticket;


__END__
