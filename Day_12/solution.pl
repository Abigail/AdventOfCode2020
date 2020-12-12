#!/opt/perl/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";

my @P1 = ( 0,  0);   # Boat position for part 1
my @P2 = ( 0,  0);   # Boat position for part 2
my @HD = ( 0,  1);   # Heading. N = (-1, 0), E = (0, 1), etc.
my @WP = (-1, 10);   # Waypoint.
my $X  =   0;        # N-S index for @HD and @WP.
my $Y  =   1;        # E-W index for @HD and @WP.

while (<$fh>) {
    /^(?<action>[NSWELRF]) \s*
      (?<distance>[0-9]+)/x or die "Failed to parse: $_";
    my ($action, $distance) = @+ {qw [action distance]};

    #
    # Move the boat (part 1), or move the waypoint (part 2)
    #
    if ($action eq 'N') {$P1 [$X] -= $distance; $WP [$X] -= $distance;}
    if ($action eq 'E') {$P1 [$Y] += $distance; $WP [$Y] += $distance;}
    if ($action eq 'S') {$P1 [$X] += $distance; $WP [$X] += $distance;}
    if ($action eq 'W') {$P1 [$Y] -= $distance; $WP [$Y] -= $distance;}

    #
    # Move the boat, either in the way we're heading (part 1).
    # or in the direction of the way point (part 2).
    #
    if ($action eq 'F') {$P1 [$X] += $distance * $HD [$X];
                         $P1 [$Y] += $distance * $HD [$Y];
                         $P2 [$X] += $distance * $WP [$X];
                         $P2 [$Y] += $distance * $WP [$Y];}

    if ($action eq 'L') {
        #
        # Change turning left by X degrees into turning right by 360 - X degrees
        #
        $action   = 'R';
        $distance =  360 - $distance;
    }
    #
    # Rotate the heading (part 1), or waypoint (part 2)
    #
    if ($action eq 'R') {
        while ($distance) {
            @HD = ($HD [$Y], -$HD [$X]);
            @WP = ($WP [$Y], -$WP [$X]);
            $distance -= 90;
        }
    }
}

say "Solution 1: ", abs ($P1 [$X]) + abs ($P1 [$Y]);
say "Solution 2: ", abs ($P2 [$X]) + abs ($P2 [$Y]);

__END__
