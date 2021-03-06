#!/opt/perl/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";

local $/ = "";
my ($player1, $player2) = <$fh>;
my    @cards1 = split /\n/ => $player1;
my    @cards2 = split /\n/ => $player2;
shift @cards1;
shift @cards2;


sub play_game ($cards1, $cards2, $recursive = 0) {
    my %seen;
    while (@$cards1 && @$cards2) {
        #
        # Prevent looping
        #
        return [@$cards1, @$cards2], [] if $seen {"@$cards1;@$cards2"} ++;

        my $card1 = shift @$cards1;
        my $card2 = shift @$cards2;
        #
        # Recurse if need to, else just compare cards.
        #
        my $p1_wins = $recursive && $card1 <= @$cards1 && $card2 <= @$cards2 
            ?  @{(play_game ([@$cards1 [0 .. $card1 - 1]],
                             [@$cards2 [0 .. $card2 - 1]], $recursive)) [0]}
            :  $card1 > $card2;
        push @$cards1 => $card1, $card2 if  $p1_wins;
        push @$cards2 => $card2, $card1 if !$p1_wins;
    }
    ($cards1, $cards2);
}


my @all_cards1 = reverse map {@$_} play_game [@cards1], [@cards2], 0;
my @all_cards2 = reverse map {@$_} play_game [@cards1], [@cards2], 1;

use List::Util 'sum';

say "Solution 1: ", sum map {($_ + 1) * $all_cards1 [$_]} keys @all_cards1;
say "Solution 2: ", sum map {($_ + 1) * $all_cards2 [$_]} keys @all_cards2;


__END__
