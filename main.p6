#!/usr/bin/env perl6

use lib '.';
use Printer;
use Parse;
use Cells;

my @table;
my Int @column-widths;

sub confirmEdit (Int $x, Int $y, Cell:D $new) {
    my $old := @table[$y][$x]; # Note: this is a reference!
    my $newStr = $new.eval(@table);

    if $old.DEFINITE {
        my $resp = prompt "Will replace '$old.eval(@table)' with '$newStr'";
        return if $resp eq 'n'|'N';
    }

    $old = $new;
    @column-widths[$x] = compute-width @table, $x;
}

my %commands =
    open => sub (Str:D $file) {
        fail "File $file does not exist." unless $file.IO.e;

        @table = parse-file $file;
        @column-widths = compute-widths @table;
    }, print => {
        fail "No file open!" unless @table;

        print-table @table, @column-widths
    }, edit => sub (Int(Str) $x, Int(Str) $y) {
        fail "No file open" unless @table;

        with attempt-parse prompt 'New val: ' -> (Int, Cell:D $new) {
            confirmEdit $x - 1, $y - 1, $new
        }
    }

sub run-command ($command, @params) {
    fail "No command $command" unless $command ~~ %commands;

    my &action = %commands{$command};
    my $arity = &action.arity;

    fail "\"$command\" needs $arity params!" unless $arity == @params;

    &action(|@params);
    CATCH { default { say "Error executing command: $_"  } }
}

loop {
    my $command = prompt '> ' orelse last;
    $command .= trim;
    redo unless $command.chars;
    last if $command eq 'exit';

    my ($action, @params) = $command.words;
    run-command $action, @params;

    CATCH { default { say "Error occured: $_"; .resume } }
}

say 'Exitting!'
