#!/opt/perl/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

#
# Challenge
#
#   We are given passports which we need to validate. Passports
#   are given as records, separated by blank lines. Each record
#   consists of a number of key/value pairs, the pairs separated
#   by whitespace (could be newlines), the keys and values by colons.
#
#   For both parts, we need to count the number of valid passports.
#
#   For part 1, a passport is valid if it has all of the following fields:
#
#     - byr (Birth Year)
#     - iyr (Issue Year)
#     - eyr (Expiration Year)
#     - hgt (Height)
#     - hcl (Hair Color)
#     - ecl (Eye Color)
#     - pid (Passport ID)
#
#   There may be a 'cid' field, but it's not required.
#
#   For part 2, not only does the passport need those fields, the values
#   of those fields need to follow some rules:
#
#      - byr (Birth Year) - four digits; at least 1920 and at most 2002.
#      - iyr (Issue Year) - four digits; at least 2010 and at most 2020.
#      - eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
#      - hgt (Height) - a number followed by either cm or in:
#         -  If cm, the number must be at least 150 and at most 193.
#         -  If in, the number must be at least 59 and at most 76.
#      - hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
#      - ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
#      - pid (Passport ID) - a nine-digit number, including leading zeroes.
#

#
# Open the input, and prepare it for reading in paragraph mode.
#
my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";
$/ = "";

#
# Validating rules, expressed as regular expression; no post processing
# needed. For part 1, a field just have to be present.
# For part 2, the field must validate the pattern.
#
my %fields = (
    byr    =>  qr /19[2-9][0-9] | 200[012]/x,           # 1920 <= byr <= 2002
    iyr    =>  qr /20(?: 1[0-9] | 20)/x,                # 2010 <= iyr <= 2020
    eyr    =>  qr /20(?: 2[0-9] | 30)/x,                # 2020 <= eyr <= 2030
    hgt    =>  qr /(?:1 (?:[5-8][0-9] | 9[0-3])) cm |   # 150-193 cm
                   (?:59 | 6[0-9] | 7[0-6])      in/x,  #  53- 76 in
    hcl    =>  qr /\# [0-9a-f]{6}/x,                    # 6 digit hex number
    ecl    =>  qr /amb | blu | brn | gry | grn | hzl | oth/x,
    pid    =>  qr /[0-9]{9}/x,                          # 9 digits
);
                   
my $valid1 = 0;
my $valid2 = 0;

PASSPORT:
  while (<$fh>) {
    chomp;
    #
    # Read in a passport: split on whitespace, split the result
    # on colons (which separate the key from the value).
    my %record    = map {split /:/} split;

    #
    # Keep track of whether all the fields in a passport validate
    #
    my $validates = 1;
    foreach my $field (keys %fields) {
        #
        # If the field doesn't exist, it's not valid for
        # either part 1 or part 2.
        #
        next PASSPORT unless exists $record {$field};

        #
        # Check whether the field validates. (But don't bother
        # if we already know the passport is failing part 2).
        #
        my $pattern = $fields {$field};
        $validates &&= $record {$field} =~ /^(?:$pattern)$/;
    }
    $valid1 ++;
    $valid2 ++ if $validates;
}

say "Solution 1: ", $valid1;
say "Solution 2: ", $valid2;


__END__
