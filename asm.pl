use v5.32;
use utf8;
use strict;
use warnings;

{
    package Lazy;

    sub lazy(&) {
        return Lazy->new($_[0]);
    }

    use overload
        '""' => sub {
            my $s = shift->{sub}->();
            return "$s";
        },
        "0+" => sub { int(shift->{sub}->()) },
        "+" => sub {
            my ($self, $other, $reverse) = @_;
            return $reverse ?
                lazy { int($other) + int($self) }:
                lazy { int($self) + int($other) };
        },
        "-" => sub {
            my ($self, $other, $reverse) = @_;
            return $reverse ?
                lazy { int($other) - int($self) }:
                lazy { int($self) - int($other) };
        };
    sub new {
        my ($class, $sub) = @_;
        return bless { sub => $sub }, $class;
    }
    sub set {
        my ($self, $v) = @_;
        $self->{sub} = sub { $v };
    }
}

sub is_string {
    # https://anond.hatelabo.jp/20080303125703
    my $v = shift;
    no feature "bitwise";
    return ($v ^ $v) ne '0';
}

my $pos = 0;
my @output = ();

sub org {
    my $addr = shift;
    $pos = $addr;
}

sub label {
    if (@_ == 0) {
        return Lazy::lazy { 0 };
    }
    my $label = shift;
    $label->set($pos);
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

sub rax() { "rax" }
sub rdi() { "rdi" }

sub mov {
    my ($reg, $imm) = @_;
    if ($reg eq rax) {
        db 0xb8;
        dd $imm;
    } elsif ($reg eq rdi) {
        db 0xbf;
        dd $imm;
    }
}

sub asm_syscall() {
    db 0x0f, 0x05;
}

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

my $start = label();
my $end = label();
my $elf_start = label();
my $elf_end = label();
my $seg_start = label();
my $seg_end = label();
my $phdr1 = label();
my $phdr2 = label();
my $entrypoint = label();

org(0x400000);

# ELF Header
label($start);
my $file_size = $end - $start;

label($elf_start);
my $elf_size = $elf_end - $elf_start;
db      0x7F, "ELF";    # e_ident
db      2;              # 64-bit architecture.
db      1;              # 2's complement little-endian.
db      1;              # ei_version ABI Version: Current
db      0;              # ei_osabi UNIX System V ABI
db      0;              # ei_abiversion ABI Version
db      0;              # padding
dw      0, 0, 0;        # padding
dw      2;              # e_type: executable
dw      0x3e;           # e_machine: x86-64
dd      1;              # e_version
dq      $entrypoint;    # e_entry
dq      $phdr1-$start;  # e_phoff
dq      0;              # e_shoff
dd      0;              # e_flags
dw      $elf_size;      # e_ehsize
dw      0x38;           # e_phentsize
dw      2;              # e_phnum
dw      0x40;           # e_shentsize
dw      0;              # e_shnum
dw      0;              # e_shstrndx
label($elf_end);

label($seg_start);

# Program Header 1
label($phdr1);
my $seg_size = $seg_end - $seg_start;
dd      PT_PHDR;        # p_type
dd      readable;       # p_flags
dq      $phdr1-$start;  # p_offset
dq      $phdr1;         # p_vaddr
dq      $phdr1;         # p_paddr
dq      $seg_size;      # p_filesz
dq      $seg_size;      # p_memsz
dq      0x80;           # p_align

# Program Header 2
label($phdr2);

dd      PT_LOAD;        # p_type
dd      readable | executable; # p_flags
dq      0;              # p_offset
dq      $start;         # p_vaddr
dq      $start;         # p_paddr
dq      $file_size;     # p_filesz
dq      $file_size;     # p_memsz
dq      0x200000;       # p_align

label($seg_end);

label($entrypoint);

mov     rax, 60; # sys_exit
mov     rdi, 0;
asm_syscall;

label($end);

print @output;
