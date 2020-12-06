#!/opt/perl/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

#
# Blog: https://wp.me/pcxd30-dk
#

my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";
$/ = "";

my $count1 = 0;
my $count2 = 0;

while (my $answer_set = <$fh>) {
    my %yes;
    my @answers = split /\n/ => $answer_set;
    foreach my $answer (@answers) {
        1 while $answer =~ s/(.)(.*)\K\g{1}//;  # Remove duplicates
        $yes {$_} ++ for split // => $answer;
    }
    $count1 += keys %yes;
    $count2 += grep {$_ == @answers} values %yes;
}


say "Solution 1: ", $count1;
say "Solution 2: ", $count2;

__END__
