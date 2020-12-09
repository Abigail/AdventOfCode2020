#!/opt/perl/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

use Getopt::Long;

#
# Blog: https://wp.me/pcxd30-ew
#

#
# For the challenge, see challenge.md
#

#
# Parameter for buffer-size, so we can use the test example
#
GetOptions (
    'buffer-size=i'  => \(my $BUFFER_SIZE = 25),
);


#
# Read the input, store the numbers in an array.
#
my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";
chomp (my @numbers = <$fh>);

#
# Object to keep track of the previous $BUFFER_SIZE numbers,
# and the sums they can form.
#
package Buffer {
    use Hash::Util::FieldHash qw [fieldhash];

    fieldhash my %size;
    fieldhash my %buffer;
    fieldhash my %sums;

    #
    # Constructor
    #
    sub new  ($class) {bless \do {my $var} => $class};

    #
    # Initialize the object with a buffer size.
    #
    sub init ($self, $size) {
        $size   {$self} = $size;
        $buffer {$self} = [];
        $sums   {$self} = {};

        $self;
    }

    #
    # Add a new number to the buffer. If the buffer is full, first
    # remove its oldest member, and the sums it is part off. Then add
    # the number to the buffer, and calculate all the sums it can make.
    #
    sub add ($self, $new) {
        my $size   = $size   {$self};
        my $buffer = $buffer {$self};
        my $sums   = $sums   {$self};
        #
        # Remove a number if the buffer is full
        #
        while (@$buffer > $size) {
            my $old = shift @$buffer;
            $$sums {$_} -- for map {$_ + $old} @$buffer;
        }
        #
        # Add sums, and add to buffer
        #
        $$sums {$_} ++ for map {$_ + $new} @$buffer;
        push @$buffer => $new;

        $self;
    }

    #
    # Return true if the given parameter equals a sum of a pair
    # of numbers in the buffer.
    #
    sub is_sum ($self, $sum) {
        $sums {$self} {$sum}
    }
}

#
# Create an empty buffer
#
my $buffer = Buffer:: -> new -> init ($BUFFER_SIZE);

my $solution1;
#
# Iterate over all numbers of the input
#
foreach my $index (keys @numbers) {
    my $number = $numbers [$index];
    #
    # If it's not one of the first $BUFFER_SIZE numbers, and it
    # cannot formed by summing a pair of numbers found in the
    # previous $BUFFER_SIZE numbers, we have a winner.
    #
    if ($index >= $BUFFER_SIZE && !$buffer -> is_sum ($number)) {
        $solution1 = $number;
        last;
    }
    #
    # Add the new number to the buffer. This will delete any old
    # numbers if the buffer is full.
    #
    $buffer -> add ($number);
}
die "No solution for part 1" unless defined $solution1;

#
# Find a range of consecutive integers which sum to $solution1.
# We keep a running total, starting with the sum of the first 
# two numbers. If the sum is smaller than $solution1, we increase
# range; if it's larger than $solution1, we decrease the range.
#
my ($min_index, $max_index) = (0, 1);
my  $sum = $numbers [$min_index] + $numbers [$max_index];
while ($sum != $solution1 && $min_index < @numbers - 1) {
    #
    # If the sum is too small, *or* if $max_index == $min_index + 1,
    # increment $max_index.
    # Else, increment $min_index. Update $sum either way.
    #
    if ($sum < $solution1 || $max_index == $min_index - 1) {
        last if ++ $max_index >= @numbers;
        $sum += $numbers [$max_index];
    }
    else {
        $sum -= $numbers [$min_index ++];
    }
}
die "No solution found for part 2" unless $sum == $solution1;

#
# Find the answer to part 2 by summing the minimum and maximim
# values found in the range.
#
use List::Util qw [min max];
my $solution2 = min (@numbers [$min_index .. $max_index]) +
                max (@numbers [$min_index .. $max_index]);


say "Solution 1: ", $solution1;
say "Solution 2: ", $solution2;

__END__
