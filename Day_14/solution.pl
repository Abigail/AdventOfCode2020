#!/opt/perl/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

#
# Blog: https://wp.me/pcxd30-hD
#

#
# Challenge description: ./challenge.md
#

my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";

my $mask_and = "1" x 36;
my $mask_or  = "0" x 36;
my $mask     = "X" x 36;
my %memory1;
my %memory2;

#
# Given an address, and a mask, return a set of addresses.
# This is a bitwise compare:
#      - if the mask bit is 0, we leave the bit in the address as is,
#      - if the mask bit is 1, we set the bit in the address to 1,
#      - if the mask bit is X, we double the set of addresses, using
#                                 both a 0 and 1.
#
# We do this by creating a glob pattern. For the first two cases, we just
# put a 0 or 1 in the pattern; in case of an X, we put '{0,1}' in the
# pattern: the result of that will be two addresses, one with a 0 in
# that spot, one with a 1.
#
sub addresses ($base_address, $mask) {
    no warnings 'portable';
    my @base_bits = split // => sprintf "%036b" => $base_address;
    my @mask_bits = split // => $mask;

    my @result = map {$mask_bits [$_] eq "0" ? $base_bits [$_]
                   :  $mask_bits [$_] eq "1" ? 1
                   :  $mask_bits [$_] eq "X" ? "{0,1}"
                   :  die "Unexpected mask bit ", $mask_bits [$_]}
                 keys @mask_bits;

    map {eval "0b$_"} glob join "" => @result;
}

#
# Parse the input, update the memory for both part 1 and part 2
#
while (<$fh>) {
    if (/^mask \s+ = \s+ (?<mask>[01X]+) \s* $/x) {
        no warnings 'portable';
        $mask     =               $+ {mask};
        #
        # For part 1, we keep two masks, one to "AND" the value
        # with -- this sets each 0 in the mask to a 0 in the result,
        # and one mask to "OR" the value with -- this sets each 1
        # in the mask to a 1 in the result. 
        # We create those two masks by setting each X to 1 and 0 respectively.
        #
        $mask_and = eval ("0b" . ($+ {mask} =~ y/X/1/r));
        $mask_or  = eval ("0b" . ($+ {mask} =~ y/X/0/r));
        next;
    }
    if (/^mem \s* \[ (?<address>[0-9]+ )\]
              \s* = \s* (?<value>[0-9]+) \s*$/x) {

        #
        # Part one, a single memory update, after applying the two masks.
        #
        $memory1 {$+ {address}} = $+ {value} & $mask_and | $mask_or;

        #
        # Part two, first get the set of addresses, then update each address
        #
        my @addresses = addresses $+ {address}, $mask;
        $memory2 {$_} = $+ {value} for @addresses;
    }
}

use List::Util qw [sum];

say "Solution 1: ", sum values %memory1;
say "Solution 2: ", sum values %memory2;

__END__
