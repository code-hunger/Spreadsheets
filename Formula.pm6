class Formula {
    has $.left;
    has $.op;
    has $.right;

    method Str { '(' ~ $.left.Str ~ " " ~ $.op.Str ~ " " ~ $.right.Str ~ ')' }
}

multi sub compute(Formula $f) is export {
    my ($left, $right) = compute($f.left), compute($f.right);

    return compute $left, $f.op, $right;
}

multi sub compute($x) { $x }

multi sub compute($x, '+', $y) { $x + $y }
multi sub compute($x, '-', $y) { $x - $y }
multi sub compute($x, '*', $y) { $x * $y }
multi sub compute($x, '/', $y) { $x / $y }
multi sub compute($x, '^', $y) { $x ** $y }

my @ops = '+', '-', '*', '/', '^';

my regex float { \-? \d* \.? \d+ }

multi fromString ($str where /^ <float> $/) { return $str.Rat }

multi fromString ($str where /^R(\N)C(\N)$/) { return ($0, $1) }

multi fromString (Str $left, Str $rest) {
    with trim $rest {
        return fromString $left if .comb == 0;

        my $op = .substr(0, 1);
        fail "Expected operator, found '$op'" if $op ne any @ops;

        return Formula.new(
            left => fromString(trim $left),
            :$op,
            right => fromString .substr(1).trim)
    }
}

multi fromString ($str where /\D/) {
    say "Calling from string with $str";
    my @chars = $str.comb;

    my Str $term = "";
    my Int $depth = 0;

    for @chars.kv -> Int $i, $c {
        say "Term: $term: Depth: $depth";

        if $c eq '(' {
            if $depth == 0 and $i != 0 {
                fail "Opening brace met, operator expected at char $i"
            }
            ++$depth
        }

        if $c eq ')' {
            --$depth;
            if $depth == 0 {
                fail "Illegal zero depth after closing brace" unless $term ~~ /^\(/;

                return fromString $term.substr(1), $str.substr($i + 1)
            }
        }

        if $depth == 0 and $c eq any @ops {
            return fromString $term, $str.substr($i)
        }

        $term ~= $c
    }

    fail "Unbalanced braces" if $depth > 0;
    fail "Can't parse $str";
}

sub makeFormula (Str $str) is export { return fromString trim $str }
