use v5.32;
use utf8;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Asm;

my $arch = $ARGV[0] || 'x86_64';
my $machine;
if ($arch eq 'x86_64') {
    $machine = MACHINE_X86_64;
} elsif ($arch eq 'aarch64') {
    $machine = MACHINE_AARCH64;
}

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
dw      $machine;       # e_machine
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

if ($machine == MACHINE_X86_64) {
    eval <<MACHINE_X86_64;
use Asm::x64_86;

mov     rax, 60; # sys_exit
mov     rdi, 0;
_syscall;
MACHINE_X86_64
    die "$@" if $@;
};

if ($machine == MACHINE_AARCH64) {
    eval <<MACHINE_AARCH64;
use Asm::aarch64;

mov     x8, 93; # sys_exit
mov     x0, xzr;
svc     0;
MACHINE_AARCH64
    die "$@" if $@;
};

label($end);

output();
