#!/opt/perl/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

my $input = shift // "input";

my $valid1 = 0;
my $valid2 = 0;

open my $fh, "<", $input or die "open: $!";
while (<$fh>) {
    chomp;
    #
    # Parse a line of input.
    #
    /^(?<min>      [0-9]+) -
      (?<max>      [0-9]+)   \s+
      (?<letter>   [a-z])  : \s+
      (?<password> [a-z]+)   \s*$/x or die "Failed to parse '$_'";

    #
    # Save values from %+ before they're overwritten
    #
    my ($min, $max, $letter, $password) = @+ {qw [min max letter password]};

    #
    # Count the number of times the letter appears in the password.
    # Ideally, we use tr///, but tr/// doesn't do interpolation.
    # We could use an eval to get around that, but we opt to use an m//g
    # instead.
    #
    # Note that we first assign the result of the match to an empty list,
    # to force the match to occur in list context. We're not putting anything
    # in the list, but we do want to know the number of items which would
    # have been put in the list -- which is exactly what list assignment
    # in scalar context returns.
    #
    my $count = () = $password =~ /$letter/g;
    $valid1 ++ if $min <= $count && $count <= $max;

    #
    # Count the number of times if the given letter appears on exactly
    # one of the given positions: xor will return true if one, but not
    # both, of its operands is true.
    # We also check whether the password is long enough -- although with
    # the given input, this isn't really required.
    #
    $valid2 ++ if (length ($password) >= $min &&
                   substr ($password,    $min - 1, 1) eq $letter) 
              xor (length ($password) >= $max &&
                   substr ($password,    $max - 1, 1) eq $letter);

}

say "Solution 1: ", $valid1;
say "Solution 2: ", $valid2;

__END__
