#!/opt/perl/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";

my $MODULUS = 20201227;
my $SUBJECT =        7;

chomp (my $card_pkey = <$fh>);
chomp (my $door_pkey = <$fh>);

package Value {
    use Hash::Util::FieldHash qw [fieldhash];
    fieldhash my %value;
    fieldhash my %subject;
    sub new ($class) {bless \do {my $var} => $class}
    sub init ($self, $subject) {
        $subject {$self} = $subject;
        $value   {$self} = 1;
        $self;
    }
    sub loop ($self) {
        $value {$self} = ($value {$self} * $subject {$self}) %
                          $MODULUS;
        $self;
    }
    sub value ($self) {
        $value {$self};
    }
}


my $loop_size = 0;
my $card_loop = 0;
my $door_loop = 0;
my $val1 = Value:: -> new -> init ($SUBJECT);
while (!$card_loop || !$door_loop) {
    $loop_size ++;
    $val1 -> loop;
    $card_loop = $loop_size if $card_pkey == $val1 -> value;
    $door_loop = $loop_size if $door_pkey == $val1 -> value;
}

my  $val2 = Value:: -> new -> init ($door_pkey);
    $val2 -> loop for 1 .. $card_loop;

say "Solution 1: ", $val2 -> value;


__END__
