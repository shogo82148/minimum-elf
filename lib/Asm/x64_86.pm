package Asm::x64_86;

use v5.32;
use utf8;
use strict;
use warnings;
use Asm;

use Exporter 'import';
our @EXPORT = qw/rax rdi mov _syscall/;

sub rax() { "rax" }
sub rdi() { "rdi" }

sub mov {
    my ($reg, $imm) = @_;
    $reg ||= "invalid";
    $imm ||= 0;
    if ($reg eq rax) {
        db 0xb8;
        dd $imm;
    } elsif ($reg eq rdi) {
        db 0xbf;
        dd $imm;
    } else {
        die "unknown reg: $reg";
    }
}

sub _syscall() {
    db 0x0f, 0x05;
}

1;
