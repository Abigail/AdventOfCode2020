#!/opt/perl/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";

while (<$fh>) {
    last unless /\S/;
    my ($field, $ranges) = split /\s*:\s*/;
    my  @ranges = split /\s+or\s+/ => $range;

__END__
