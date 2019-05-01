#!/usr/bin/env perl6

use lib '.';
use Printer;
use Parse;

my ($table, $column-widths) = parse-file 'sample';
print-table($table, $column-widths);
