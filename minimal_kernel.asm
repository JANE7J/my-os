; Minimal bootloader that switches to 32-bit mode
[BITS 16]
[ORG 0x7C00]

start:
    ; Initialize segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    
    ; Print loading message
    mov si, msg16
    call print16
    
    ; Switch to protected mode
    cli
    lgdt [gdt_desc]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:pm_start

print16:
    mov ah, 0x0E
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

[BITS 32]
pm_start:
    ; Set up 32-bit segments
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000
    
    ; Print 32-bit message
    mov esi, msg32
    mov edi, 0xB8000
    mov ah, 0x0F
.loop32:
    lodsb
    test al, al
    jz .done32
    stosw
    jmp .loop32
.done32:
    jmp .done32

; GDT
gdt_start:
    dq 0                ; null descriptor
    dw 0xFFFF, 0, 0x9A00, 0x00CF  ; code segment
    dw 0xFFFF, 0, 0x9200, 0x00CF  ; data segment
gdt_end:

gdt_desc:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ 8
DATA_SEG equ 16

msg16: db 'Switching to 32-bit...', 13, 10, 0
msg32: db 'Success! 32-bit kernel running!', 0

times 510-($-$$) db 0
dw 0xAA55
