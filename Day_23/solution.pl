#!/opt/perl/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

my $RUNS_1 =        100;
my $RUNS_2 = 10_000_000;
my $SIZE_2 =  1_000_000;

my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";

chomp (my $labels = <$fh>);
my @cups = split // => $labels;


package CupSet {
    use Hash::Util::FieldHash qw [fieldhash];

    fieldhash my %set;
    fieldhash my %max;
    fieldhash my %min;
    fieldhash my %current;

    #
    # Create and initialize the object.
    #
    sub new  ($class) {bless \do {my $var} => shift}
    sub init ($self, @cups) {
        my @list;
        $list [0] = 0;
        for (my $i = 0; $i < @cups - 1; $i ++) {
            $list [$cups [$i]] = $cups [$i + 1];
        }
        $list [$cups [@cups - 1]] = $cups [0];

        $max     {$self} =  @cups;    
        $min     {$self} =      1;
        $set     {$self} = \@list;
        $current {$self} =  $cups [0];
        $self;
    }

    #
    # Find the value below the given value, which cannot be
    # in the pickup, and wraps around.
    #
    sub minus ($self, $value, @exclude) {
        $value --;
        $value = $max {$self} if $value < $min {$self};
        grep ({$_ == $value} @exclude) ? $self -> minus ($value, @exclude)
                                       :                 $value;
    }

    #
    # Return a sequence, starting from the given value --
    # if no value is given, start from the current cup.
    #
    sub sequence ($self, $start = $current {$self}) {
        my $value = $start;
        my @sequence;
        do {
            push @sequence => $value;
            $value = $set {$self} [$value];
        } until $value == $start;
        @sequence;
    }

    sub play_round ($self) {
        my $current = $current {$self};
        my $set     = $set     {$self};
        #
        # Pickup are the 3 values following the current cup.
        #
        my @pickup  = (              $$set [$current],
                              $$set [$$set [$current]],
                       $$set [$$set [$$set [$current]]]);
        #
        # Find the destination
        #
        my $destination = $self -> minus ($current, @pickup);

        #
        # Remove the pickup, and put it after the destination.
        #
        $$set [$current]     = $$set [$pickup [-1]];
        $$set [$pickup [-1]] = $$set [$destination];
        $$set [$destination] =        $pickup [0];

        #
        # Update the current cup.
        #
        $current {$self} = $$set [$current];
    }
}

{
    #
    # Part 1 with the small set, and low number of rounds.
    #
    my $set = CupSet:: -> new -> init (@cups);
    $set -> play_round for 1 .. $RUNS_1;
    my @s = $set -> sequence;
    say "Solution 1: ", join "" => @s [1 .. $#s];
}

{
    #
    # Part 2 with a larger set, and more rounds.
    #
    my $set = CupSet:: -> new -> init (@cups, 10 .. $SIZE_2);
    $set -> play_round for 1 .. $RUNS_2;
    my @s = $set -> sequence (1);
    say "Solution 2: ", $s [1] * $s [2];
}


__END__
