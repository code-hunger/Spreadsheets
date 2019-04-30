#!/usr/bin/env perl6

class IntCell {
    has Int $.val;

    method Str { $.val }
}

class FloatCell  {
    has Num $.val;

    method Str { $.val }
}

class EmptyCell { 
    has $.val = "";

    method Str { "" }
}

sub parce-cell-int (Str:D $str) {
    $str ~~ /^ < + - >? \d+ /;
    $/ andthen ($/.Str, IntCell.new(val => $/.Str.Int))
}

sub parce-cell-float (Str:D $str) {
    $str ~~ /^ < + - >? [\d+]? \. \d+/;
    $/ andthen ($/.Str, FloatCell.new(val => $/.Str.Num))
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
        with attempt-parce $str -> ($match, $cell) {
            push @row, $cell;
            $str = $str.substr($match.chars);
            $str ~~ s/^\s*\,\s*//;
        } else {
            $*ERR.say: "Can't parce string on line {1+@table}!";
            last;
        }
    }
    push @table, @row
}

for @table -> @row {
    print $_.Str ~ ", " for @row;
    say();
}
