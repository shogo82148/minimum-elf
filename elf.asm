; based on κeen's minimal ELF
; https://keens.github.io/blog/2020/04/12/saishougennoelf/

BITS 64
        org     0x400000
        db      0x7F, "ELF"	; e_ident
        db      2               ; 64-bit architecture.
        db      1               ; 2's complement little-endian.
        db      1               ; ei_version ABI Version: Current
        db      0               ; ei_osabi UNIX System V ABI
        db      0               ; ei_abiversion ABI Version
        db      0               ; padding
        dw      0, 0, 0         ; padding
        dw      2               ; e_type: executable
        dw      62              ; e_machine: x86-64
        dd      1               ; e_version
        dq      _start          ; e_entry
        dq      phdr1 - $$      ; e_phoff
        dq      0               ; e_shoff
        dd      0               ; e_flags
        dw      64              ; e_ehsize
        dw      56              ; e_phentsize
        dw      2               ; e_phnum
        dw      64              ; e_shentsize
        dw      0               ; e_shnum
        dw      0               ; e_shstrndx

phdr1:  dd      6               ; p_type: PT_PHDR
        dd      4               ; p_flags: read
        dq      phdr1 - $$      ; p_offset
        dq      phdr1           ; p_vaddr
        dq      phdr1           ; p_paddr
        dq      segsize         ; p_filesz
        dq      segsize         ; p_memsz
        dq      0x80            ; p_align

phdr2:  dd      1               ; p_type: PT_LOAD
        dd      5               ; p_flags: read + executable
        dq      0               ; p_offset
        dq      $$              ; p_vaddr
        dq      $$              ; p_paddr
        dq      filesize        ; p_filesz
        dq      filesize        ; p_memsz
        dq      0x200000
segsize equ $ - phdr1

_start:
        mov     rax, 60         ; sys_exit
        mov     rdx, 0          ; return 0
        syscall

filesize equ $ - $$
