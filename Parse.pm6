unit module Parse;

use Cells;

multi sub attempt-parse (Str:D $str, Cell $cell-type) {
    with $cell-type.parse: $str -> ($len, $cell) {
        if $str.substr($len).trim ~~ /^ \s* [\, || $$] / {
            return $len, $cell
        }
    }
}

sub parse-unquoted-str (Str:D $str) {
    $str ~~ /^ (<-[,]>+) /;

    return $/.chars, Cells::StringCell.new: val => $/.Str
}

multi sub attempt-parse ($str) is export {
    for @Cells::types -> $c {
        return $_ with attempt-parse $str, $c
    }

    return parse-unquoted-str $str
}

sub parse-file (Str:D $fname) is export {
    my @table;

    for $fname.IO.lines -> $str is copy {
        my Cell @row;

        while ($str .= trim).chars {
            my (Int $len, Cell $cell) = attempt-parse($str) // do {
                $*ERR.say: "Error parsing on line {1+@table}: $str";
                last
            }

            push @row, $cell;

            $str = $str.substr: $len;
            $str ~~ s/^\s*\,\s*//
        }

        push @table, @row
    }

    return @table
}

