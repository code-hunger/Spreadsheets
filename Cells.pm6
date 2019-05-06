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
    method Str { $.val.Str }
    method parse (::?CLASS:U: Str $str) { ... }
}

class IntCell does Cell does RegexParse {
    my $.match = q{ <[+ -]>? \d+ };

    has Int $.val;

    method fromMatch ($match) {
        self.new(val => $match.Str.Int)
    }
}

class FloatCell does Cell does RegexParse {
    my $.match = q{ <[+ -]>? \d* \. \d+ };

    has Num $.val;

    method fromMatch ($match) {
        self.new(val => $match.Str.Num)
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

        return $len, self.new: val => $val
    }
}

our constant @types = IntCell, FloatCell, EmptyCell, StringCell;
