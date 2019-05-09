class BinaryFormula {
    has $.left;
    has $.op;
    has $.right;

    method Str { '(' ~ $.left.Str ~ " " ~ $.op.Str ~ " " ~ $.right.Str ~ ')' }
}

multi sub compute(BinaryFormula $f) is export {
    my ($left, $right) = compute($f.left), compute($f.right);

    return compute $left, $f.op, $right;
}

multi sub compute($x where Rat|Num|Int) { $x }

multi sub compute($x where .elems == 2) {
    fail "To compute a formula with a cell reference, please provide a table context.";
}

multi sub compute($x, '+', $y) { $x + $y }
multi sub compute($x, '-', $y) { $x - $y }
multi sub compute($x, '*', $y) { $x * $y }
multi sub compute($x, '/', $y) { $x / $y }
multi sub compute($x, '^', $y) { $x ** $y }
