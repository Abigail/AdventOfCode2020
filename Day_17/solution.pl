#!/opt/perl/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

#
# Challenge description: ./challenge.md
#


my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";
my $field = do {local $/; <$fh>};

my $GENERATIONS = 6;

package Universe {
    use Hash::Util::FieldHash qw [fieldhash];

    fieldhash my %universe;
    fieldhash my %dimension;
    fieldhash my %offsets;

    #
    # Create an empty universe
    #
    sub new  ($class) {bless \do {my $var} => $class}

    #
    # Initialize
    #
    sub init ($self, $dimension, $field) {
        $dimension {$self} = $dimension;
        my @lines = split /\n/ => $field;
        foreach my $x (keys @lines) {
            my @chars = split // => $lines [$x];
            foreach my $y (keys @chars) {
                $self -> set_alive (join $; => $x, $y, (0) x ($dimension - 2))
                                if $chars [$y] eq '#';
            }
        }

        #
        # Calculate the offsets for the neighbourhood.
        #
        my $pattern = join "," => ("{-1,0,1}") x $dimension;
        foreach my $offset (glob $pattern) {
            next unless $offset =~ /1/;
            push @{$offsets {$self}} => [split /,/ => $offset];
        }

        $self;
    }


    #
    # Given a cell, return all its neighbours. We're using cache,
    # for most cells, we will want the neighbourhood more than once.
    #
    sub neighbourhood ($self, $cell) {
        state $cache;
        @{$$cache {$cell} //= do {
            my @coordinates = split $; => $cell;
            [map {my $offset = $_;
                  join $; => map {$coordinates [$_] +
                                 $$offset [$_]} keys @$offset;
            } @{$offsets {$self}}];
        }}
    }



    #
    # Set a particular cell alive
    #
    sub set_alive ($self, $cell) {
        $universe {$self} {$cell} = 1;
        $self;
    }

    #
    # Returns true of the given cell is alive
    #
    sub is_alive ($self, $cell) {
        $universe {$self} {$cell};
    }


    #
    # Given a set of coordinates, return true if the cell
    # at that location should be alive in the next generation.
    # Return false otherwise.
    #
    sub will_live ($self, $cell) {
        my $alive_neighbours = 0;
        foreach my $neighbour ($self -> neighbourhood ($cell)) {
            $alive_neighbours ++ if $self -> is_alive ($neighbour);
        }
        $alive_neighbours == 3 ||
        $alive_neighbours == 2 && $self -> is_alive ($cell);
    }

    #
    # Return the living cells of the universe
    #
    sub alive_cells ($self) {
        keys %{$universe {$self}}
    }

    #
    # Calculate the next generation.
    #
    sub tick ($self) {
        my $new_universe;
        my %done;
        foreach my $alive_cell ($self -> alive_cells) {
            for my $cell ($alive_cell, $self -> neighbourhood ($alive_cell)) {
                next if $done {$cell} ++;
                my ($x, $y, $z) = split $; => $cell;
                $$new_universe {$cell} = 1 if $self -> will_live ($cell);
            }
        }
        $universe {$self} = $new_universe;
        $self;
    }
}

my $universe3 = Universe:: -> new -> init (3, $field);
my $universe4 = Universe:: -> new -> init (4, $field);

   $universe3 -> tick for 1 .. $GENERATIONS;
   $universe4 -> tick for 1 .. $GENERATIONS;

say "Solution 1: ", scalar $universe3 -> alive_cells;
say "Solution 2: ", scalar $universe4 -> alive_cells;


__END__
