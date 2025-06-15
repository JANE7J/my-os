; Very simple bootloader for debugging
[BITS 16]
[ORG 0x7C00]

start:
    ; Print a single character 'H' to test if BIOS calls work
    mov ah, 0x0E    ; BIOS teletype function
    mov al, 'H'     ; Character to print
    mov bh, 0       ; Page number
    mov bl, 0x07    ; Color (light gray on black)
    int 0x10        ; Call BIOS interrupt
    
    ; Print 'I' to confirm it's working
    mov al, 'I'
    int 0x10
    
    ; Infinite loop
hang:
    jmp hang

; Fill rest with zeros and add boot signature
times 510-($-$$) db 0
dw 0xAA55
