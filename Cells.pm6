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
    method Str { $.val.Str }
    method parse (::?CLASS:U: Str $str) { ... }
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

class FormulaCell does Cell {
    has Str $.val;

    method parse(Str $str) {
        $str ~~ /^ \= \[ (<-[\[ \]]>+) \] /;
        $/.chars, $.fromMatch($/) if $/;
    }

    method fromMatch (Match $match where *.list.elems == 1) {
        my $formula = $match[0].Str orelse fail("No formula in match");

        $.fromVal($formula);
    }
}

our constant @types = IntCell, FloatCell, EmptyCell, StringCell, FormulaCell;
