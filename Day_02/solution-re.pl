#!/opt/perl/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';
no  warnings 'experimental::regex_sets';

use experimental 'signatures';
use experimental 'lexical_subs';

#
# For the challenge description, see solution.pl.
#
# This is alternative solution, using just a regular expressions.
#

my $input = shift // "input";

my $valid1 = 0;
my $valid2 = 0;

open my $fh, "<", $input or die "open: $!";
while (<$fh>) {
    $valid1 ++ if /^(?<min>    [0-9]+) \s* - \s*
                    (?<max>    [0-9]+) \s+
                    (?<letter> [a-z])  \s* : \s*
                    (??{ "(?<notletters>  (?[ [a-z] &  [^$+{letter}]])* )
                          (?: $+{letter} (?&notletters)){$+{min},$+{max}}
                          (?&notletters)" })
                 $/x;

    $valid2 ++ if /^(?<min>    [0-9]+) \s* - \s*
                    (?<max>    [0-9]+) \s+
                    (?<letter> [a-z])  \s* : \s*
                    (??{ "[a-z]{@{[$+{min}-1]}}
                          (?:$+{letter}
                              (?<minmax>    [a-z]{@{[$+{max}-$+{min}-1]}})
                              (?<notletter> (?[ [a-z] & [^$+{letter}]]))   |
                            (?&notletter)
                              (?&minmax)
                              $+{letter})
                          [a-z]*" }) $/x;
}

say "Solution 1: ", $valid1;
say "Solution 2: ", $valid2;


__END__
