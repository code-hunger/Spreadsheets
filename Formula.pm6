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

multi sub compute($x where Num) { $x }

multi sub compute($x, '+', $y) { $x + $y }
multi sub compute($x, '-', $y) { $x - $y }
multi sub compute($x, '*', $y) { $x * $y }
multi sub compute($x, '/', $y) { $x / $y }
multi sub compute($x, '^', $y) { $x ** $y }
