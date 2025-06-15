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
    
    mov esi, welcome
    mov edi, 0xB8000
    mov ah, 0x1F
    call print
    
    mov esi, help
    mov edi, 0xB8000 + 160
    mov ah, 0x0E
    call print

loop:
    in al, 0x64
    test al, 1
    jz loop
    
    in al, 0x60
    test al, 0x80
    jnz loop
    
    cmp al, 0x1E
    je do_a
    cmp al, 0x30
    je do_b
    cmp al, 0x2E
    je do_c
    jmp loop

do_a:
    mov esi, msg_a
    call show
    jmp loop

do_b:
    mov esi, msg_b
    call show
    call beep
    jmp loop

do_c:
    call clear
    jmp pm_start

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

show:
    mov edi, 0xB8000 + 1600
    mov ecx, 80
    mov ax, 0x0720
    rep stosw
    mov edi, 0xB8000 + 1600
    mov ah, 0x0C
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
.wait:
    loop .wait
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

welcome db 'MyOS v1.0 - Press A, B, C', 0
help db 'A=About B=Beep C=Clear', 0
msg_a db 'System OK!', 0
msg_b db 'BEEP!', 0

times 510-($-$$) db 0
dw 0xAA55
