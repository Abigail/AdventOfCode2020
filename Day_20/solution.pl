#!/opt/perl/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

my $input = shift // "input";
# $input = "test";
open my $fh, "<", $input or die "open: $!";
$/ = "";

my %tiles;

while (my $tile = <$fh>) {
    $tile =~ s/^Tile (?<id>[0-9]+):\n// or die "Failed to parse $tile";
    my $tile_id = $+ {id};
    my @rows   = map {[map {$_ eq "#" ? 1 : 0} split //]} split /\n/ => $tile;
    my $top    = join "" => @{$rows [0]};
    my $bottom = join "" => @{$rows [-1]};
    my $left   = join "" => map {$$_ [0]}  @rows;
    my $right  = join "" => map {$$_ [-1]} @rows;
    $tiles {$tile_id} {sides} = {
        $top    => 1,
        $bottom => 1,
        $left   => 1,
        $right  => 1,
    }
}

my @tile_ids = keys %tiles;
for (my $i = 0; $i < @tile_ids; $i ++) {
    my $id_i = $tile_ids [$i];
    for (my $j = $i + 1; $j < @tile_ids; $j ++) {
        my $id_j = $tile_ids [$j];
        foreach my $side (keys %{$tiles {$id_i} {sides}}) {
            if ($tiles {$id_j} {sides} {$side} ||
                $tiles {$id_j} {sides} {reverse $side}) {
                push @{$tiles {$id_i} {neighbours}} => $id_j;
                push @{$tiles {$id_j} {neighbours}} => $id_i;
            }
        }
    }
}

use List::Util qw [product];

say "Solution 1: ", product grep {@{$tiles {$_} {neighbours}} == 2} @tile_ids;

my @counts;

foreach my $id (@tile_ids) {
    $counts [@{$tiles {$id} {neighbours}}] ++;
}

use YAML;
print Dump \@counts;

__END__

foreach my $id (@tile_ids) {
    if (!$tiles {$id} {neighbours}) {
        say "No match for id $id";
        next;
    }
    if (@{$tiles {$id} {neighbours} || []} == 2) {
        say $id;
    }
}


__END__
