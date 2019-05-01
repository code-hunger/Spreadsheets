#!/usr/bin/env perl6

use lib '.';
use Printer;
use Parse;

my $buffer;

my %commands = o => sub (Str:D $file) {
    say "OPEN";
    fail "$file does not exist." unless $file.IO.e;
    $buffer = parse-file $file; 
}

sub run-command ($command, @params) {
    fail "No command $command" unless $command ~~ %commands;

    my &action = %commands{$command};

    say "Execute " ~ &action.perl ~ " with params ", @params.perl;
    &action(|@params);
}

loop {
    my $command = prompt '> ' orelse last;
    $command .= trim;
    redo unless $command.chars;
    last if $command eq 'last';

    my ($action, @params) = $command.words;
    run-command $action, @params orelse say "Err! $_";
}

say 'Exitting!'
