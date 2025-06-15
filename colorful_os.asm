[BITS 16]
[ORG 0x7C00]

start:
    mov ax, 0x03
    int 0x10
    
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    
    lgdt [gdt_desc]
    
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    jmp 8:pm_start

[BITS 32]
pm_start:
    mov ax, 16
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov esp, 0x90000
    
    call clear
    
    ; Colorful header
    mov esi, welcome
    mov edi, 0xB8000
    mov ah, 0x4F
    call print
    
    mov esi, help1
    mov edi, 0xB8000 + 160
    mov ah, 0x2E
    call print
    
    mov esi, help2
    mov edi, 0xB8000 + 320
    mov ah, 0x1B
    call print

loop:
    in al, 0x64
    test al, 1
    jz loop
    
    in al, 0x60
    test al, 0x80
    jnz loop
    
    cmp al, 0x1E ; A
    je do_a
    cmp al, 0x30 ; B
    je do_b
    cmp al, 0x2E ; C
    je do_c
    cmp al, 0x23 ; H
    je do_h
    cmp al, 0x17 ; I
    je do_i
    cmp al, 0x10 ; Q
    je do_q
    cmp al, 0x14 ; T
    je do_t
    jmp loop

do_a:
    mov esi, msg_a
    mov ah, 0x0C
    call show_color
    jmp loop

do_b:
    mov esi, msg_b
    mov ah, 0x0E
    call show_color
    call beep
    jmp loop

do_c:
    call clear
    jmp pm_start

do_h:
    mov esi, msg_h
    mov ah, 0x0B
    call show_color
    jmp loop

do_i:
    mov esi, msg_i
    mov ah, 0x0A
    call show_color
    jmp loop

do_q:
    mov esi, msg_q
    mov ah, 0x0D
    call show_color
    jmp loop

do_t:
    mov esi, msg_t
    mov ah, 0x09
    call show_color
    jmp loop

clear:
    mov edi, 0xB8000
    mov ecx, 2000
    mov ax, 0x0720
    rep stosw
    ret

print:
.lp:
    lodsb
    test al, al
    jz .done
    stosb
    mov al, ah
    stosb
    jmp .lp
.done:
    ret

show_color:
    mov edi, 0xB8000 + 1600
    mov ecx, 80
    mov ax, 0x0720
    rep stosw
    mov edi, 0xB8000 + 1600
    call print
    ret

beep:
    mov al, 0xB6
    out 0x43, al
    mov ax, 1000
    out 0x42, al
    mov al, ah
    out 0x42, al
    in al, 0x61
    or al, 3
    out 0x61, al
    mov ecx, 0x8000
.w:
    loop .w
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    ret

gdt:
    dd 0, 0
    dd 0x0000FFFF, 0x00CF9A00
    dd 0x0000FFFF, 0x00CF9200

gdt_desc:
    dw 23
    dd gdt

welcome db 'MyOS Color v2.0', 0
help1 db 'A=About B=Beep C=Clear H=Help', 0
help2 db 'I=Info Q=Quit T=Time', 0
msg_a db 'Custom OS!', 0
msg_b db 'BEEP!', 0
msg_h db '7 Colors', 0
msg_i db '32-bit', 0
msg_q db 'Bye!', 0
msg_t db 'OK', 0

times 510-($-$$) db 0
dw 0xAA55
