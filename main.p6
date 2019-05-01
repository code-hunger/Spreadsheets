#!/usr/bin/env perl6

use lib '.';
use Printer;
use Parse;

my $buffer;

my %commands = 
    open => sub (Str:D $file) {
        fail "File $file does not exist." unless $file.IO.e;

        $buffer = parse-file $file; 
    }, print => {
        fail "No file open!" unless $buffer;

        print-table $buffer[0], $buffer[1];
    }

sub run-command ($command, @params) {
    fail "No command $command" unless $command ~~ %commands;

    my &action = %commands{$command};
    my $arity = &action.arity;

    fail "\"$command\" needs $arity params!" unless $arity == @params;

    &action(|@params);
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
