#!/usr/bin/env perl6

use lib '.';
use Printer;
use Parse;

my @table;
my Int @column-widths;

my %commands =
    open => sub (Str:D $file) {
        fail "File $file does not exist." unless $file.IO.e;

        @table = parse-file $file;
        @column-widths = compute-widths @table;
    }, print => {
        fail "No file open!" unless @table;

        print-table @table, @column-widths
    }, edit => sub (Int(Str) $y, Int(Str) $x) {
        fail "No file open" unless @table;

        with attempt-parse prompt 'New val: ' -> ($len, $new) {
            fail without $new;

            my $old := @table[$x-1][$y-1]; # Note: this is a reference!
            if $old.DEFINITE {
                my $resp = prompt "Will replace '$old.eval(@table)' with '$new.eval(@table)'";
                return if $resp eq 'n'|'N';
            }

            $old = $new;
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
