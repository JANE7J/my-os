; Fixed bootloader with proper string printing
[BITS 16]
[ORG 0x7C00]

start:
    ; Initialize segments properly
    xor ax, ax      ; Set AX to 0
    mov ds, ax      ; Set data segment to 0
    mov es, ax      ; Set extra segment to 0
    mov ss, ax      ; Set stack segment to 0
    mov sp, 0x7C00  ; Set stack pointer below our code
    
    ; Clear screen
    mov ax, 0x0003
    int 0x10
    
    ; Print our message character by character (more reliable)
    mov si, message
    
print_loop:
    lodsb           ; Load byte from DS:SI into AL, increment SI
    test al, al     ; Check if AL is zero (end of string)
    jz done         ; If zero, we're done
    
    mov ah, 0x0E    ; BIOS teletype function
    mov bh, 0       ; Page 0
    mov bl, 0x07    ; Light gray on black
    int 0x10        ; Print character
    
    jmp print_loop  ; Continue with next character

done:
    ; Infinite loop
    jmp done

; Message data (closer to code for better addressing)
message: db 'Hello, OS World! My bootloader works!', 13, 10, 0

; Pad to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xAA55
