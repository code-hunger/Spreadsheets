#!/usr/bin/env perl6
use lib '.';
use Printer;

class IntCell {
    my $.match = q{< + - >? \d+};

    has Int $.val;

    method Str { $.val.Str }

    method fromMatch ($match) {
        IntCell.new(val => $match.Str.Int)
    }
}

class FloatCell  {
    my $.match = q{ <[+ -]>? \d* \. \d+ };

    has Num $.val;

    method Str { $.val.Str }

    method fromMatch ($match) {
        FloatCell.new(val => $match.Str.Num)
    }
}

class EmptyCell { 
    my $.match = "^";

    has $.val = "";

    method Str { "" }

    method fromMatch ($match where $match.Str.chars == 0) { EmptyCell.new }
}

class StringCell {
    my $.match = q{ \" <-["]>* \"  ||  .+? };

    has Str $.val;

    method Str { $.val }

    method fromMatch($match) {
        StringCell.new(val => $match.Str)
    }
}

my @cell-types = IntCell, FloatCell, EmptyCell, StringCell;

multi sub attempt-parce (Str:D $str, $cell-type where * (elem) @cell-types) {
    $str ~~ m/^ <$($cell-type.match)> <?before \s* [$$ | ',']>/ or return;

    return $/.Str, $cell-type.fromMatch: $/
}

multi sub attempt-parce ($str) {
    for @cell-types -> $c {
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
