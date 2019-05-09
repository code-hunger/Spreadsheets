unit module Cells;

role RegexParse {
    method fromMatch(::?CLASS:U: Match) { ... }

    method parse (::?CLASS:U: Str $str) {
        my $pattern = $.match;

        $str ~~ /^ <{$pattern}> /;
        .chars, self.fromMatch: $_ with $/
    }
}

role Cell is export {
    method fromVal ($val) { self.new(val => $val) }
    method parse (::?CLASS:U: Str $str) { ... }

    method Str { $.val.Str }
    method eval ($context) { return self.Str }
}

class IntCell does Cell does RegexParse {
    my $.match = q{ <[+ -]>? \d+ };

    has Int $.val;

    method fromMatch ($match) {
        $.fromVal($match.Str.Int)
    }
}

class FloatCell does Cell does RegexParse {
    my $.match = q{ <[+ -]>? \d* \. \d+ };

    has Num $.val;

    method fromMatch ($match) {
        $.fromVal($match.Str.Num)
    }
}

class EmptyCell does Cell does RegexParse {
    my $.match = "^";

    has $.val = "";

    method fromMatch ($match where $match.Str.chars == 0) { self.new }
}

class StringCell does Cell {
    my regex escaped { [ <-[\" \\]> || \\. ]* };

    has Str $.val;

    method parse(Str $str) {
        $str ~~ /^ \" (<escaped>) \" / orelse return;

        my ($val, $len) = $/[0].Str, $/.chars;
        $val ~~ s:g/\\(.)/$0/;

        return $len, self.fromVal($val)
    }
}

use Formula;
use FormulaParser;
use ContextFormula;

class FormulaCell does Cell {
    has $.val;

    method parse(Str $str) {
        $str ~~ /^ \= \[ (<-[\[ \]]>+) \] /;
        $/.chars, $.fromMatch($/) if $/;
    }

    method Str { fail 'Do not call Str on a formula cell'; "F := " ~ compute $.val }

    method eval ($context) returns Str(Cool) { compute $.val, $context }

    method fromMatch (Match $match where *.list.elems == 1) {
        with $match[0].Str -> $expr {
            $.fromVal(makeFormula $expr);
        }
    }
}

our constant @types = IntCell, FloatCell, EmptyCell, StringCell, FormulaCell;
