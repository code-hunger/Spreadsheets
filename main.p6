#!/usr/bin/env perl6

use lib '.';
use Printer;
use Cells;

multi sub attempt-parce (Str:D $str, $cell-type where * (elem) @Cells::types) {
    $str ~~ m/^ <$($cell-type.match)> <?before \s* [$$ | ',']>/ or return;

    return $/.Str, $cell-type.fromMatch: $/
}

multi sub attempt-parce ($str) {
    for @Cells::types -> $c {
        return $_ with attempt-parce $str, $c
    }
}

sub parse-file (Str:D $fname) {
    my @table;
    my Int @column-widths;

    for $fname.IO.lines -> $str is copy {
        my @row;

        while ($str .= trim).chars {
            my ($match, $cell) = attempt-parce($str) // do {
                $*ERR.say: "Error parsing on line {1+@table}: $str";
                last
            }

            push @row, $cell;

            @column-widths[@row.elems-1] max= $cell.val.chars;

            $str = $str.substr($match.chars);
            $str ~~ s/^\s*\,\s*//
        }

        push @table, @row
    }

    return @table, @column-widths
}

my ($table, $column-widths) = parse-file 'sample';
print-table($table, $column-widths);
