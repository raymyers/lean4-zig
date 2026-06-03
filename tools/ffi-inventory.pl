#!/usr/bin/env perl
# Compare the FFI surface of lean.h against the declarations in src/lean.zig.
#
# Usage: ffi-inventory.pl <lean.h> <lean.zig> [allowlist.txt]
#
# Exits non-zero if any inline function or LEAN_EXPORT extern from lean.h is
# missing from lean.zig and not covered by the allowlist, so CI can gate on
# completeness.
use strict;
use warnings;

my ($header, $zig, $allowlist_path) = @ARGV;
die "usage: $0 <lean.h> <lean.zig> [allowlist.txt]\n" unless $header && $zig;

sub slurp {
    my ($path) = @_;
    open my $fh, '<', $path or die "cannot open $path: $!\n";
    local $/;
    return <$fh>;
}

my $src = slurp($header);
$src =~ s{/\*.*?\*/}{}gs;    # strip block comments
$src =~ s{//[^\n]*}{}g;      # strip line comments

my (%inline, %extern);
while ($src =~ /\bstatic\s+inline\s+[^(){};]*?\b(\w+)\s*\([^;{]*\)\s*\{/gs) {
    $inline{$1} = 1;
}
while ($src =~ /\bLEAN_EXPORT\s+[^;{]*?\b(\w+)\s*\([^;{]*\)\s*;/gs) {
    $extern{$1} = 1;
}

my $z = slurp($zig);
my %zdecl;
while ($z =~ /pub (?:extern )?fn (\w+)/g) { $zdecl{$1} = 1; }

my %allow;
if ($allowlist_path) {
    for my $line (split /\n/, slurp($allowlist_path)) {
        $line =~ s/#.*//;
        $line =~ s/^\s+|\s+$//g;
        $allow{$line} = 1 if length $line;
    }
}

my @missing_inline = grep { !$zdecl{$_} && !$allow{$_} } sort keys %inline;
my @missing_extern = grep { !$zdecl{$_} && !$allow{$_} } sort keys %extern;

printf "lean.h inline fns: %d  (missing from bindings: %d)\n",
    scalar(keys %inline), scalar(@missing_inline);
printf "lean.h LEAN_EXPORT externs: %d  (missing from bindings: %d)\n",
    scalar(keys %extern), scalar(@missing_extern);

if (@missing_inline) {
    print "\n== missing inline translations ==\n";
    print "  $_\n" for @missing_inline;
}
if (@missing_extern) {
    print "\n== missing extern declarations ==\n";
    print "  $_\n" for @missing_extern;
}

if (@missing_inline || @missing_extern) {
    print "\nFAIL: FFI surface incomplete (see lists above; intentional gaps belong in the allowlist)\n";
    exit 1;
}
print "OK: FFI surface complete (modulo allowlist)\n";
