[BITS 16]
[ORG 0x7C00]

start:
    ; Quick setup
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; Show loading message
    mov si, msg_loading
    call print_string

    ; Switch to protected mode quickly
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:protected_mode_start

; 16-bit print function
print_string:
    pusha
.loop:
    lodsb                  ; Load byte from SI into AL
    or al, al              ; Check if null terminator
    jz .done
    mov ah, 0x0E           ; BIOS teletype function
    mov bh, 0              ; Page number
    mov bl, 0x07           ; Light gray on black
    int 0x10               ; BIOS video interrupt
    jmp .loop
.done:
    popa
    ret

; Messages
msg_loading       db 'MyOS Loading...', 13, 10, 0

; GDT (Global Descriptor Table)
gdt_start:
    ; Null descriptor
    dq 0

gdt_code:
    ; Code segment descriptor
    dw 0xFFFF          ; Limit 0-15
    dw 0x0000          ; Base 0-15
    db 0x00            ; Base 16-23
    db 10011010b       ; Access byte
    db 11001111b       ; Flags + Limit 16-19
    db 0x00            ; Base 24-31

gdt_data:
    ; Data segment descriptor  
    dw 0xFFFF          ; Limit 0-15
    dw 0x0000          ; Base 0-15
    db 0x00            ; Base 16-23
    db 10010010b       ; Access byte
    db 11001111b       ; Flags + Limit 16-19
    db 0x00            ; Base 24-31

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

[BITS 32]
protected_mode_start:
    ; Set up 32-bit segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000      ; Set stack pointer

    ; Clear screen and show messages
    call clear_screen_32
    mov esi, msg_success
    mov edi, 0xB8000
    mov ah, 0x0F
    call print_string_32

    mov esi, msg_kernel
    mov edi, 0xB8000 + (2*80*2)
    mov ah, 0x0A
    call print_string_32

    ; Simple counter loop
    mov ebx, 0
main_loop:
    mov esi, msg_counter
    mov edi, 0xB8000 + (4*80*2)
    mov ah, 0x0E
    call print_string_32
    
    test ebx, 1
    jz even
    mov esi, msg_odd
    jmp show
even:
    mov esi, msg_even
show:
    mov edi, 0xB8000 + (4*80*2) + 18
    mov ah, 0x0C
    call print_string_32
    
    inc ebx
    call delay_32
    jmp main_loop

clear_screen_32:
    mov edi, 0xB8000
    mov ecx, 2000
    mov ax, 0x0720
    rep stosw
    ret

print_string_32:
.loop:
    lodsb
    or al, al
    jz .done
    mov [edi], al
    mov [edi+1], ah
    add edi, 2
    jmp .loop
.done:
    ret

delay_32:
    mov ecx, 0x1FFFFFF
.delay:
    loop .delay
    ret

; Messages
msg_success  db '32-bit Mode Active!', 0
msg_kernel   db 'MyOS Kernel Running', 0
msg_counter  db 'Counter: ', 0
msg_even     db 'EVEN', 0
msg_odd      db 'ODD ', 0

; Pad to boot sector size
times 510-($-$$) db 0
dw 0xAA55
