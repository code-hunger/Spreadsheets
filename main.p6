#!/usr/bin/env perl6

use lib '.';
use Printer;
use Parse;

my @buffer;
my Int @column-widths;

my %commands =
    open => sub (Str:D $file) {
        fail "File $file does not exist." unless $file.IO.e;

        @buffer = parse-file $file;

        for @buffer -> @row {
            for @row.kv -> $i, $cell {
                @column-widths[$i] max= $cell.eval(@buffer).chars
            }
        }
    }, print => {
        fail "No file open!" unless @buffer;

        print-table @buffer, @column-widths
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
