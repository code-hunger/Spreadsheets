use lib '.';
use Formula;
use FormulaParser;

my $f = makeFormula("10 + (.20 - 3.0)- 7 / 2 ^ 2");

say $f.Str, ' = ', compute $f;
