class Formula {
    has $.left;
    has $.op;
    has $.right;

    method Str { $.left.Str ~ " " ~ $.op.Str ~ " " ~ $.right.Str }
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

multi fromString ($str where /^ <float> $/) { return $str.Num }

multi fromString ($str where /^R(\N)C(\N)$/) { return ($0, $1) }

multi fromString ($str where /\D/) {
    say "Calling from string with $str";
    my @chars = $str.comb;

    my Str $term = "";

    for @chars.kv -> Int $i, $c {
        if $c eq any @ops {
            my $left = fromString $term.trim;
            my $right = fromString $str.substr($i + 1).trim;

            return Formula.new: :$left, op => $c, :$right;
        }

        $term ~= $c
    }
}

sub makeFormula (Str $str) is export { return fromString trim $str }
