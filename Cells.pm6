unit module Cells;

role Parse {
    method parse (::?CLASS:U: Str $str) {
        my $pattern = $.match;

        $str ~~ /^ <{$pattern}> /;
        .chars, self.fromMatch: $_ with $/
    }
}

class IntCell does Parse {
    my $.match = q{ <[+ -]>? \d+ };

    has Int $.val;

    method Str { $.val.Str }

    method fromMatch ($match) {
        self.new(val => $match.Str.Int)
    }
}

class FloatCell does Parse {
    my $.match = q{ <[+ -]>? \d* \. \d+ };

    has Num $.val;

    method Str { $.val.Str }

    method fromMatch ($match) {
        self.new(val => $match.Str.Num)
    }
}

class EmptyCell does Parse {
    my $.match = "^";

    has $.val = "";

    method Str { "" }

    method fromMatch ($match where $match.Str.chars == 0) { self.new }
}

class StringCell does Parse {
    my regex escaped { [ <-[\" \\]> || \\. ]* };

    has Str $.val;

    method Str { $.val }

    method parse(Str $str) {
        $str ~~ /^ \" (<escaped>) \" / orelse return;

        my ($val, $len) = $/[0].Str, $/.chars;
        $val ~~ s:g/\\(.)/$0/;

        return $len, self.new: val => $val
    }
}

our constant @types = IntCell, FloatCell, EmptyCell, StringCell;
