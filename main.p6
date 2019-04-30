#!/usr/bin/env perl6

class IntCell {
    my $.match = q{< + - >? \d+};

    has Int $.val;

    method Str { $.val }

    method fromMatch ($match) {
        IntCell.new(val => $match.Str.Int);
    }
}

class FloatCell  {
    my $.match = q{ <[+ -]>? \d* \. \d+ };

    has Num $.val;

    method Str { $.val }

    method fromMatch ($match) {
        FloatCell.new(val => $match.Str.Num);
    }
}

class EmptyCell { 
    has $.val = "";

    method Str { "" }
}

sub parce-cell-int (Str:D $str) {
    $str ~~ /^<$(IntCell.match)>/;
    $/ andthen ($/.Str, IntCell.fromMatch($/))
}

sub parce-cell-float (Str:D $str) {
    $str ~~ /^<$(FloatCell.match)>/;
    $/ andthen ($/.Str, FloatCell.fromMatch($/))
}

sub parce-cell-empty (Str) { "", EmptyCell }

my @parcers = &parce-cell-int, &parce-cell-float, &parce-cell-empty;

sub attempt-parce (Str:D $str) {
    for @parcers {
        my ($match, $cell) = $_($str) // next;
        if $match.chars == $str.chars or $str.comb[$match.chars] eq ',' {
            return $match, $cell;
        }
    }
}

my @table;

for 'sample'.IO.lines -> $str is copy {
    my @row;
    while ($str .= trim).chars {
        my ($match, $cell) = (attempt-parce $str) // do {
            $*ERR.say: "Error parsing on line {1+@table}: $str";
            last
        };

        push @row, $cell;
        $str = $str.substr($match.chars);
        $str ~~ s/^\s*\,\s*//;
    }
    push @table, @row
}

for @table -> @row {
    @row.map(*.Str).join(", ").say;
}
