use Formula;

multi sub compute(BinaryFormula $f, $context) is export {
    my $left  = compute $f.left, $context orelse fail "Can't compute left " ~ $f.left;
    my $right = compute $f.right, $context orelse fail "Can't compute right " ~ $f.right;

    return compute $left, $f.op, $right;
}

multi sub compute($x where Rat|Num|Int, $context) { $x }

multi sub compute (Str $x) {
    return $0.Rat if $x ~~ /^([\d*\.]?\d+)/;

    warn "Can't parse '$x' in formula. Will use '0'.";
    return 0
}

multi sub compute($cell where .elems == 2, $context) {
    compute $context[$cell[0]][$cell[1]].val
 }
