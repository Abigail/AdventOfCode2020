#!/opt/perl/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";

my $NS1 =   0;        # Distance travelled NS, part 1
my $EW1 =   0;        # Distance travelled EW, part 1
my $NS2 =   0;        # Distance travelled NS, part 2
my $EW2 =   0;        # Distance travelled EW, part 2
my @HD  = ( 0,  1);   # Heading. N = (-1, 0), E = (0, 1), etc.
my @WP  = (-1, 10);   # Waypoint.
my $X   =   0;        # N-S index for @HD and @WP.
my $Y   =   1;        # E-W index for @HD and @WP.
while (<$fh>) {
    /^(?<action>[NSWELRF]) \s*
      (?<distance>[0-9]+)/x or die "Failed to parse: $_";
    my ($action, $distance) = @+ {qw [action distance]};

    #
    # Change turning left by X degrees into turning right by 360 - X degrees
    #
    if ($action eq 'L') {
        $action   = 'R';
        $distance =  360 - $distance;
    }

    if    ($action eq 'N') {$NS1    -= $distance;
                            $WP [0] -= $distance;}
    elsif ($action eq 'E') {$EW1    += $distance;
                            $WP [1] += $distance;}
    elsif ($action eq 'S') {$NS1    += $distance;
                            $WP [0] += $distance;}
    elsif ($action eq 'W') {$EW1    -= $distance;
                            $WP [1] -= $distance;}
    elsif ($action eq 'F') {$NS1    += $distance * $HD [0];
                            $EW1    += $distance * $HD [1];
                            $NS2    += $distance * $WP [0];
                            $EW2    += $distance * $WP [1];}
    elsif ($action eq 'R') {
        while ($distance) {
            @HD = ($HD [1], -$HD [0]);
            @WP = ($WP [1], -$WP [0]);
            $distance -= 90;
        }
    }
    else {
        die "Unknown action '$action'"
    }
}

say "Solution 1: ", abs ($NS1) + abs ($EW1);
say "Solution 2: ", abs ($NS2) + abs ($EW2);

__END__
