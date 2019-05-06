unit module Cells;

role Parse {
    method parse (::?CLASS:U: Str $str) {
        $str ~~ m/$($.match)/;
    }
 }

class IntCell does Parse {
    my $.match = q{ <[+ -]>? \d+ };

    has Int $.val;

    method Str { $.val.Str }

    method fromMatch ($match) {
        IntCell.new(val => $match.Str.Int)
    }
}

class FloatCell does Parse {
    my $.match = q{ <[+ -]>? \d* \. \d+ };

    has Num $.val;

    method Str { $.val.Str }

    method fromMatch ($match) {
        FloatCell.new(val => $match.Str.Num)
    }
}

class EmptyCell does Parse {
    my $.match = "^";

    has $.val = "";

    method Str { "" }

    method fromMatch ($match where $match.Str.chars == 0) { EmptyCell.new }
}

our regex escaped is export { [ <-[\" \\]> || \\. ]*  };

class StringCell does Parse {
    my $.match = q! \" (<escaped>) \" !;

    has Str $.val;

    method Str { $.val }

    method fromMatch($match) {
        StringCell.new(val => $match.Str)
    }
}

our @types = IntCell, FloatCell, EmptyCell, StringCell;
