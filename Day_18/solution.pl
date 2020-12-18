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
    if    ($priorities == $EQUAL) {
        1 while s [([0-9]+) \s* ([*+]) \s* ([0-9]+) \s*] ["$1 $2 $3"]eex;
    }
    elsif ($priorities == $SWAPPED) {
        1 while s [([0-9]+) \s* ([+])  \s* ([0-9]+) \s*] ["$1 $2 $3"]eex;
        1 while s [([0-9]+) \s* ([*])  \s* ([0-9]+) \s*] ["$1 $2 $3"]eex;
    }
    return $_;
}


sub cal_expression ($expression, $priorities) {
    1 while $expression =~ s/[(] ([^()]+) [)]/cal_simple $1, $priorities/ex;
    cal_simple $expression, $priorities;
}


my $sum1 = sum map {cal_expression $_, $EQUAL}   @expressions;
my $sum2 = sum map {cal_expression $_, $SWAPPED} @expressions;


say "Solution 1: ", $sum1;
say "Solution 2: ", $sum2;

__END__
