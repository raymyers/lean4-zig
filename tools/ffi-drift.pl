#!/usr/bin/env perl
# Detect semantic drift between two versions of lean.h.
#
# Usage: ffi-drift.pl <old/lean.h> <new/lean.h>
#
# Compares the normalized body of every `static inline` function and the
# normalized signature of every LEAN_EXPORT extern that appears in both
# versions, and lists functions that were removed. The linker catches removed
# extern *symbols*; it can NOT catch a changed inline body or a changed extern
# signature - this tool exists for those. Run it on every toolchain bump and
# audit each listed function against its translation in src/lean.zig.
use strict;
use warnings;

my ($old_h, $new_h) = @ARGV;
die "usage: $0 <old/lean.h> <new/lean.h>\n" unless $old_h && $new_h;

sub extract {
    my ($path) = @_;
    open my $fh, '<', $path or die "cannot open $path: $!\n";
    my $src = do { local $/; <$fh> };
    $src =~ s{/\*.*?\*/}{}gs;
    $src =~ s{//[^\n]*}{}g;
    my (%inline, %extern);
    while ($src =~ /\bstatic\s+inline\s+([^(){};]*?\b(\w+)\s*\([^;{]*\))\s*\{/gs) {
        my ($sig, $name) = ($1, $2);
        my $start = pos($src) - 1;    # at the '{'
        my $depth = 0;
        my $i     = $start;
        for (; $i < length($src); $i++) {
            my $c = substr($src, $i, 1);
            $depth++ if $c eq '{';
            if ($c eq '}') { $depth--; last if $depth == 0; }
        }
        my $body = substr($src, $start, $i - $start + 1);
        for ($sig, $body) { s/\s+/ /g; }
        $inline{$name} = "$sig $body";
    }
    while ($src =~ /\bLEAN_EXPORT\s+([^;{]*?\b(\w+)\s*\([^;{]*\))\s*;/gs) {
        my ($sig, $name) = ($1, $2);
        $sig =~ s/\s+/ /g;
        $extern{$name} = $sig;
    }
    return (\%inline, \%extern);
}

my ($oi, $oe) = extract($old_h);
my ($ni, $ne) = extract($new_h);

my @changed_inline = grep { exists $ni->{$_} && $oi->{$_} ne $ni->{$_} } sort keys %$oi;
my @removed_inline = grep { !exists $ni->{$_} } sort keys %$oi;
my @changed_extern = grep { exists $ne->{$_} && $oe->{$_} ne $ne->{$_} } sort keys %$oe;
my @removed_extern = grep { !exists $ne->{$_} } sort keys %$oe;

print "== inline fns with CHANGED bodies (" . scalar(@changed_inline) . ") - audit each vs src/lean.zig ==\n";
for my $n (@changed_inline) {
    print "  $n\n    old: $oi->{$n}\n    new: $ni->{$n}\n";
}
print "== inline fns REMOVED (" . scalar(@removed_inline) . ") ==\n";
print "  $_\n" for @removed_inline;
print "== externs with CHANGED signatures (" . scalar(@changed_extern) . ") - ABI hazard! ==\n";
for my $n (@changed_extern) {
    print "  $n\n    old: $oe->{$n}\n    new: $ne->{$n}\n";
}
print "== externs REMOVED (" . scalar(@removed_extern) . ") ==\n";
print "  $_\n" for @removed_extern;

my $issues = @changed_inline + @removed_inline + @changed_extern + @removed_extern;
print "\n", ($issues ? "$issues function(s) need auditing" : "no drift detected"), "\n";
exit($issues ? 1 : 0);
