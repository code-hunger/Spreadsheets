#!/usr/bin/env perl6

class IntCell {
    my $.match = q{< + - >? \d+};

    has Int $.val;

    method Str { $.val.Str }

    method fromMatch ($match) {
        IntCell.new(val => $match.Str.Int);
    }
}

class FloatCell  {
    my $.match = q{ <[+ -]>? \d* \. \d+ };

    has Num $.val;

    method Str { $.val.Str }

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
my Int @column-widths;

for 'sample'.IO.lines -> $str is copy {
    my @row;
    while ($str .= trim).chars {
        my ($match, $cell) = (attempt-parce $str) // do {
            $*ERR.say: "Error parsing on line {1+@table}: $str";
            last
        };

        push @row, $cell;

        @column-widths[@row.elems-1] max= $cell.val.chars;

        $str = $str.substr($match.chars);
        $str ~~ s/^\s*\,\s*//;
    }
    push @table, @row;
}

my $row-delimiter = '+' x (@column-widths*3 + sum @column-widths) ~ '+';

sub print-long (Str:D $str, Int:D $length where * ≥ $str.chars) {
    sprintf " %{$length}s ", $str
}

say $row-delimiter;
for @table -> @row {
    next unless @row.elems;

    once {
        say '|' ~ .join('|') ~ '|'
            given (^@column-widths).map: { print-long ($_+1).Str, @column-widths[$_] };
        say $row-delimiter for 1..2;
    }

    my $i = 0;
    say '|' ~ .join("|") ~ '|'
        given @row.map: { print-long $^a.Str, @column-widths[$i++]; };

    say $row-delimiter;
}
