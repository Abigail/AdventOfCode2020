#!/opt/perl/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";

my $EQUAL   = 1;
my $SWAPPED = 2;

use List::Util 'sum';

chomp (my @expressions = <$fh>);

#
# Calculate an expression without parenthesis
#
sub cal_simple ($expression, $priorities) {
    local $_ = $expression;
    my @ops = $priorities == $EQUAL ? ("+*") : ("+", "*");
    foreach my $op (@ops) {
        1 while s [([0-9]+) \s* ([$op]) \s* ([0-9]+) \s*] ["$1 $2 $3"]eex;
    }
    return $_;
}


#
# Calculate the value of an expression.
#
sub cal_expression ($expression, $priorities) {
    local $_ = $expression;
    1 while s [\( ([^()]+) \)] [cal_simple $1, $priorities]ex;
    cal_simple $_, $priorities;
}

# say cal_expression "2 * 3 + (4 * 5)", 1;

# __END__

say "Solution 1: ", sum map {cal_expression $_, $EQUAL}   @expressions;
say "Solution 2: ", sum map {cal_expression $_, $SWAPPED} @expressions;


__END__
