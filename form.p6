use lib '.';
use Formula;

my $f = makeFormula("10 + (.20 - 3.0)- 7");

say $f.Str, ' = ', compute $f;
