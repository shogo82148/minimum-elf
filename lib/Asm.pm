package Asm;

use v5.32;
use utf8;
use strict;
use warnings;
use Lazy;

use Exporter 'import';

our @EXPORT = qw/
    executable writable readable
    PT_LOAD PT_PHDR
    MACHINE_X86_64 MACHINE_AARCH64
    label org db dw dd dq output/;

# the flags for segments.
use constant {
    executable => 0x01,
    writable   => 0x02,
    readable   => 0x04,
};

use constant {
    PT_LOAD => 0x01,
    PT_PHDR => 0x06,
};

use constant {
    MACHINE_X86_64  => 62,
    MACHINE_AARCH64 => 183,
};

sub is_string {
    # https://anond.hatelabo.jp/20080303125703
    my $v = shift;
    no feature "bitwise";
    return ($v ^ $v) ne '0';
}

our $pos = 0;
our @output = ();

# label defines a new label
sub label {
    if (@_ == 0) {
        return lazy { 0 };
    }
    my $label = shift;
    $label->set($pos);
}

sub org {
    my $addr = shift;
    $pos = $addr;
}

# output byte sequence
sub db {
    for my $v(@_) {
        if (is_string($v)) {
            push @output, Lazy::lazy { $v };
            $pos += length $v;
        } else {
            push @output, Lazy::lazy { pack("C", $v) };
            $pos++;
        }
    }
}

# output 16 bit integers (little endian)
sub dw {
    for my $v(@_) {
        push @output, Lazy::lazy { pack("S<", $v) };
        $pos += 2;
    }
}

# output 32 bit integers (little endian)
sub dd {
    for my $v(@_) {
        push @output, Lazy::lazy { pack("L<", $v) };
        $pos += 4;
    }
}

# output 64 bit integers (little endian)
sub dq {
    for my $v(@_) {
        push @output, Lazy::lazy { pack("Q<", $v) };
        $pos += 8;
    }
}

sub output {
    print @output;
    1;
}

1;
