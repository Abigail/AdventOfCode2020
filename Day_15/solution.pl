#!/opt/perl/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

#
# The two target numbers
#
my $TARGET1 =     2020;
my $TARGET2 = 30000000;

#
# Get the input
#
my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";
my @numbers = <$fh> =~ /[0-9]+/g;

my $turn = 0;  # Turn counter.
my %spoken;    # For each number, record the last time it was spoken.
               # Note we record up to "current turn - 2".

#
# Initialize; add all, but the last, number in %spoken.
#
foreach my $number (@numbers [0 .. $#numbers - 1]) {
    $spoken {$number} = ++ $turn;
}
$turn ++;

#
# Count..., updating %spoken, and setting $solution1 and $solutuon2
# if we're hitting the targets.
#
my $solution1;
my $solution2;
my $last_number = $numbers [-1];
while ($turn < $TARGET2) {
    my $new_number = $spoken {$last_number} ?
             $turn - $spoken {$last_number} : 0;

    #
    # We can now update the last time we saw the previous number --
    # which was on the previous turn.
    #
    $spoken {$last_number} = $turn ++;

    $last_number = $new_number;
    $solution1   = $new_number if $turn == $TARGET1;
    $solution2   = $new_number if $turn == $TARGET2;
}

say "Solution 1: ", $solution1;
say "Solution 2: ", $solution2;

__END__
