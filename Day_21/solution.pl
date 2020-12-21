#!/opt/perl/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

my $input = shift // "input";
   $input = "test";
open my $fh, "<", $input or die "open: $!";

my %ingredients;
my %allergens;

while (<$fh>) {
    /^(?<ingredients>[a-z ]+) \s+
      \(contains \s+ (?<allergens>[a-z, ]+) \) \s* $/x
      or die "Failed to parse: $_";
    my @ingredients = split ' ' => $+ {ingredients};
    my @allergens   = split /,\s*/ => $+ {allergens};

    foreach my $allergen (@allergens) {
        $allergens {$allergen} ||= {map {$_ => 1} @ingredients};
    }

    $ingredients {$_} ++ for @ingredients;
  # $allergens   {$_} ++ for @allergens;
}

use YAML;
print Dump \%ingredients;
print Dump \%allergens;

__END__
