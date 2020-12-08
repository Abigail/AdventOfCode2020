#!/opt/perl/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

#
# Blog: https://wp.me/pcxd30-dZ
#

my $input = shift // "input";
open my $fh, "<", $input or die "open: $!";

my $program;  # This will contain a list of instructions.

#
# Statement indices
#
my $INSTRUCTION = 0;
my $ARGUMENT    = 1;

#
# Instructions
#
my $NOP         = 0;
my $JMP         = 1;
my $ACC         = 2;

#
# Reasons a program run ends
#
my $LOOPS       = 0;
my $TERMINATES  = 1;

#
# Parse the input, and create the program.
#
while (<$fh>) {
    chomp;
    /^(?<instruction>nop|acc|jmp) \s+
      (?<argument>[-+][0-9]+)     \s* $/x or die "Failed to parse: $_";

    my $statement = [];
    $$statement [$INSTRUCTION] = $+ {instruction} eq 'nop' ? $NOP
                               : $+ {instruction} eq 'jmp' ? $JMP
                               : $+ {instruction} eq 'acc' ? $ACC
                               : die "Unknown instruction ", $+ {instruction};
    $$statement [$ARGUMENT]    = $+ {argument};

    push @$program => $statement;
}


#
# Run the given program, and return the accumulater when it ends.
# A second return parameter gives the reason the program ends:
#   - either the program loops,
#   - or it runs till the end
#
sub run_program ($program) {
    my $acc = 0;
    my $PC  = 0;
    my @been_here;  # Keep track of where we have been.
    while (!$been_here [$PC] ++ && 0 <= $PC < @$program) {
        my ($instruction, $argument) =
                       @{$$program [$PC ++]} [$INSTRUCTION, $ARGUMENT];

        $acc += $argument,     next if $instruction == $ACC;
        $PC  += $argument - 1, next if $instruction == $JMP;
    }
    return $acc, 0 <= $PC < @$program ? $LOOPS : $TERMINATES;
}

#
# Part 1 just wants the result of the unmodified program
#

my ($solution1) = run_program $program;

#
# For part 2, just brute force our way, replacing nops/jmps one
# statement at a time.
#
my  $solution2;
foreach my $i (keys @$program) {
    next unless $$program [$i] [$INSTRUCTION] == $NOP ||
                $$program [$i] [$INSTRUCTION] == $JMP;
    #
    # Ha! One of the "good" uses of local -- can't do this with my.
    #
    local $$program [$i] [$INSTRUCTION] = 
          $$program [$i] [$INSTRUCTION] == $NOP ? $JMP : $NOP;
    my ($acc, $reason) = run_program $program;
    if ($reason == $TERMINATES) {
        $solution2 = $acc;
        last;
    }
}


say "Solution 1: ", $solution1;
say "Solution 2: ", $solution2;

__END__
