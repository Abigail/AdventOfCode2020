#!/opt/perl/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";

my %ingredients;             # Counts how often an ingredient is listed.
my %allergen_possibilities;  # Possible ingredients an allergen may
                             # be contained in.

while (<$fh>) {
    #
    # Parse the input, extract the ingredients and allergens.
    #
    /^(?<ingredients>[a-z ]+) \s+
      \(contains \s+ (?<allergens>[a-z, ]+) \) \s* $/x
      or die "Failed to parse: $_";
    my %this_ingredients = map {$_ => 1} split  /\s+/ => $+ {ingredients};
    my @this_allergens   =               split /,\s*/ => $+ {allergens};

    #
    # Foreach of the allergens, record the ingredients it may
    # occur in. The first time an allergen is listed, any of
    # the ingredients may contain that allergen. For a subsequent
    # listing, we can cross off any of the existing possibilities
    # if they aren't listed on the current line.
    #
    foreach my $allergen (@this_allergens) {
        $allergen_possibilities {$allergen} ||= {%this_ingredients};
        foreach my $ingredient (keys %{$allergen_possibilities {$allergen}}) {
            delete $allergen_possibilities {$allergen} {$ingredient}
                    unless $this_ingredients {$ingredient};
        }
    }

    #
    # Count how often an ingredient occurs
    #
    $ingredients {$_} ++ for keys %this_ingredients;
}

#
# The combination of all the possibilities left for all the allergens.
#
my %possibilities = map {$_ => 1} map {keys %$_} values %allergen_possibilities;

#
# Now, take any allergen with just one possibility left,
# cross it off from any other allergen, rinse and repeat.
#
my @todo = grep {keys %{$allergen_possibilities {$_}} == 1} keys %allergen_possibilities;
while (@todo) {
    my $allergen = shift @todo;
    my ($ingredient) = keys %{$allergen_possibilities {$allergen}};
    foreach my $other_allergen (keys %allergen_possibilities) {
        next if $other_allergen eq $allergen;
        if ($allergen_possibilities {$other_allergen} {$ingredient}) {
            delete $allergen_possibilities {$other_allergen} {$ingredient};
            if (keys %{$allergen_possibilities {$other_allergen}} == 1) {
                push @todo => $other_allergen;
            }
        }
    }
}


#
# For part 1, we find the ingredients which aren't listed as one of
# the possibilities, and we count how often they appear.
#
use List::Util 'sum';
my $solution1 = sum map   {$ingredients   {$_}}
                    grep {!$possibilities {$_}}
                    keys   %ingredients;


#
# We now have one possibility for each allergen left
#
my $solution2 = join "," => do {
    #
    # Create mapping "ingredient" => "allergen"
    #
    my @allergens   = keys %allergen_possibilities;
    my @ingredients = map {keys %$_} values %allergen_possibilities;
    my %ingredients;
       @ingredients {@ingredients} = @allergens;

    #
    # Sort the keys, and return them
    #
    sort {$ingredients {$a} cmp $ingredients {$b}} keys %ingredients;
};


say "Solution 1: ", $solution1;
say "Solution 2: ", $solution2;
    


__END__
