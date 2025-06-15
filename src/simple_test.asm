; Simple Test Bootloader - Just display message
[BITS 16]
[ORG 0x7C00]

start:
    ; Initialize segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    
    ; Clear screen
    mov ax, 0x03
    int 0x10
    
    ; Display test message
    mov si, test_msg
    call print_string
    
    ; Infinite loop
hang:
    hlt
    jmp hang

print_string:
    push ax
    push bx
print_loop:
    lodsb
    cmp al, 0
    je print_done
    mov ah, 0x0E
    mov bh, 0x00
    int 0x10
    jmp print_loop
print_done:
    pop bx
    pop ax
    ret

test_msg db 'Simple Bootloader Test - Working!', 13, 10, 0

; Pad to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xAA55
