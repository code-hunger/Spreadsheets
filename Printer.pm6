unit module Printer;

sub print-long (Str:D $str, Int:D $length where * ≥ $str.chars) {
    sprintf " %{$length}s ", $str
}

sub map-join (@arr, &c, Str:D $del) {
    $del ~ .join($del) ~ $del with @arr.map: &c
}

multi print-row (@row, Int:D @widths where *.elems ≥ @row.elems, Str:D $del = '|') {
    map-join @row, { print-long $_.Str, @widths[$++] }, $del
}

multi print-row (@context, @row, Int:D @widths where *.elems ≥ @row.elems, Str:D $del = '|') {
    map-join @row, { print-long $_.eval(@context), @widths[$++] }, $del
}

sub print-table (@table, @widths) is export {
    my $row-delimiter = map-join @widths, '-' x (2 + *), '+';

    for @table -> @row {
        next unless @row.elems;

        once {
            say $row-delimiter;
            say print-row 1..@widths, @widths;
            say $row-delimiter for 1..2
        }

        say print-row @table, @row, @widths, "|";

        say $row-delimiter
    }
}

sub compute-widths (@table) is export {
    my Int @column-widths;

    for @table -> @row {
        for @row.kv -> $i, $cell {
            @column-widths[$i] max= $cell.eval(@table).chars
        }
    }

    return @column-widths
}
