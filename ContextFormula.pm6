use Formula;

multi sub compute(BinaryFormula $f, $context) is export {
    my $left  = compute $f.left, $context orelse fail "Can't compute left " ~ $f.left;
    my $right = compute $f.right, $context orelse fail "Can't compute right " ~ $f.right;

    return compute $left, $f.op, $right;
}

multi sub compute($x where Rat|Num|Int, $context) { $x }

multi sub compute($cell where .elems == 2, $context) {
    compute $context[$cell[0]][$cell[1]].val
 }
