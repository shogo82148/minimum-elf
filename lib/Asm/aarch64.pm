package Asm::aarch64;

use v5.32;
use utf8;
use strict;
use warnings;
use Asm;

use Scalar::Util 'blessed';

use Exporter 'import';
our @EXPORT = qw/x0 x8 xzr mov svc/;

{
    package Register;
    sub new {
        my ($class, $num) = @_;
        return bless {
            num => $num,
        }, $class;
    }
}

sub is_reg {
    my $x = shift;
    return blessed($x) && $x->isa('Register')
}

sub x0() { Register->new(0) }
sub x8() { Register->new(8) }
sub xzr() { Register->new(31) }

sub oor {
    my ($xd, $xn, $xm) = @_;
    my $op = 0b1010_1010_0000_0000_0000_0000_0000_0000;
    $op |= $xd->{num};
    $op |= $xn->{num} << 5;
    $op |= $xm->{num} << 16;
    dd $op;
}

sub movz {
    my ($xd, $imm16) = @_;
    my $op = 0b1101_0010_1000_0000_0000_0000_0000_0000;
    $op |= $xd->{num};
    $op |= $imm16 << 5;
    dd $op;
}

sub mov {
    my ($dst, $src) = @_;
    if (is_reg($src)) {
        oor $dst, xzr, $src;
    } else {
        movz $dst, $src;
    }
}

sub svc {
    my ($imm16) = @_;
    my $op = 0b1101_0100_0000_0000_0000_0000_0000_0001;
    $op |= $imm16 << 5;
    dd $op;
}

1;
