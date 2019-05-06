use Formula;

my @ops = '+', '-', '*', '/', '^';

my regex float { \-? \d* \.? \d+ }

multi fromString (Str $str where /^ <float> $/) { return $str.Rat }

multi fromString (Str $str where /^R(\N)C(\N)$/) { return ($0 - 1, $1 - 1) }

multi fromTermAndRest (Str $left where *.trim.chars > 0, Str $rest where .trim.chars > 0) {
    with trim $rest {
        my $op = .substr(0, 1);
        fail "Expected operator, found '$op' after $left" if $op ne any @ops;

        return Formula.new(
            left => fromString(trim $left),
            :$op,
            right => fromString .substr(1).trim)
    }
}

multi fromTermAndRest (Str $left, Str $rest where .trim.chars == 0) {
    fromString trim $left
 }

multi fromTermAndRest (Str $left where .trim.chars == 0, Str $rest) {
    fail "Left term empty at '$rest'"
}

sub read-term (Str:D $str) returns Int {
    my Int $depth = 0;

    for $str.comb.kv -> Int $i, $c {
        if $c eq '(' {
            if $depth == 0 and $i != 0 {
                warn "Opening brace met, operator expected at char $i in $str";
                return $i
            }
            ++$depth
        }

        if $c eq ')' {
            --$depth;
            warn "Unmatched closing brace" and return $i if $depth < 0;

            if $depth == 0 {
                fail "Illegal zero depth after closing brace" unless $str ~~ /^\(/;

                return $i + 1
            }
        }

        if $depth == 0 and $c eq any @ops {
            return $i
        }

        LAST {
            fail "Unbalanced braces in $str" unless $depth == 0;
            return $i
        }
    }
}

multi fromString (Str $str where *.trim.chars > 0) returns Formula {
    given read-term $str -> $n {
        my $term = $str.substr(0..^$n).trim;
        my $rest = $str.substr($n).trim;

        $term ~~ s/^ \( (.*) \) $/$0/;

        return fromTermAndRest $term, $rest;
    }
}

sub makeFormula (Str $str) is export returns Formula { return fromString trim $str }
