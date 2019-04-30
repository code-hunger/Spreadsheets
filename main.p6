#!/usr/bin/env perl6

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
    my $.match = q{ \" <-["]>* \" };

    has Str $.val;

    method Str { $.val }

    method fromMatch($match) {
        StringCell.new(val => $match.Str)
    }
}

my @cell-types = IntCell, FloatCell, StringCell, EmptyCell;

sub attempt-parce (Str:D $str) {
    for @cell-types -> $cell-type {
        my $pattern = $cell-type.match;
        $str ~~ m/^<$pattern>/ or next;

        my ($match, $cell) = $/.Str, $cell-type.fromMatch: $/;
        if $match.chars == $str.chars or $str.comb[$match.chars] eq ',' {
            return $match, $cell
        }
    }
}

sub parse-file (Str:D $fname) {
    my @table;
    my Int @column-widths;

    for $fname.IO.lines -> $str is copy {
        my @row;

        while ($str .= trim).chars {
            my ($match, $cell) = (attempt-parce $str) // do {
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

sub print-long (Str:D $str, Int:D $length where * ≥ $str.chars) {
    sprintf " %{$length}s ", $str
}

sub map-join (@arr, &c, Str:D $del) {
    $del ~ .join($del) ~ $del with @arr.map: &c
}

sub print-row (@row, Int:D @widths where *.elems ≥ @row.elems, Str:D $del = '|') {
    map-join @row, { print-long $_.Str, @widths[$++] }, $del
}

sub print-table (@table, @widths) {
    my $row-delimiter = map-join @widths, '-' x (2 + *), '+';

    for @table -> @row {
        next unless @row.elems;

        once {
            say $row-delimiter;
            say print-row 1..@widths, @widths;
            say $row-delimiter for 1..2
        }

        say print-row @row, @widths;

        say $row-delimiter
    }
}

my ($table, $column-widths) = parse-file 'sample';
print-table($table, $column-widths);
