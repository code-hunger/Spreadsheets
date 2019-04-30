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
    my $.match = "^";

    has $.val = "";

    method Str { "" }

    method fromMatch ($match where $match.Str.chars == 0) { EmptyCell.new }
}

my @cell-types = IntCell, FloatCell, EmptyCell;

sub attempt-parce (Str:D $str) {
    for @cell-types {
        my $pattern = $($_.match);
        $str ~~ m/^<$pattern>/ or next;

        my ($match, $cell) = ($/.Str, $_.fromMatch($/));
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
