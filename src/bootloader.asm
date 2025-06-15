; Stage 1 Bootloader - Loads main kernel
; This will be the future multi-stage bootloader

[BITS 16]
[ORG 0x7C00]

; This will load Stage 2 kernel from disk
; For now, it's a placeholder

jmp 0x0000:start

start:
    ; Initialize segments
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    
    ; Display loading message
    mov si, loading_msg
    call print_string
    
    ; TODO: Load Stage 2 kernel from disk
    ; For now, just continue with embedded code
    
    ; Jump to main kernel code
    ; (This will change when we implement disk loading)
    
    hlt

print_string:
    mov ah, 0x0E
    mov bh, 0
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

loading_msg db 'Loading MyOS Kernel...', 13, 10, 0

; Boot sector signature
times 510-($-$$) db 0
dw 0xAA55
