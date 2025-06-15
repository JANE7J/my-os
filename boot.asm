; Simple bootloader that prints "Hello, OS World!" to the screen
; This code runs in 16-bit real mode when the computer boots

[BITS 16]           ; Tell NASM we're working in 16-bit mode
[ORG 0x7C00]        ; BIOS loads bootloader at memory address 0x7C00

start:
    ; Clear the screen first
    mov ax, 0x0003  ; Set video mode 3 (80x25 color text)
    int 0x10        ; Call BIOS video interrupt
    
    ; Set up segments (important for memory access)
    mov ax, 0x07C0  ; Calculate segment for our code
    mov ds, ax      ; Set data segment
    mov es, ax      ; Set extra segment
    
    ; Print our message
    mov si, message ; Load address of message into SI register
    call print_string
    
    ; Infinite loop to prevent the CPU from executing random memory
hang:
    jmp hang        ; Jump to itself forever

; Function to print a null-terminated string
print_string:
    mov ah, 0x0E    ; BIOS teletype function
.next_char:
    lodsb           ; Load byte from SI into AL, increment SI
    cmp al, 0       ; Check if we reached null terminator
    je .done        ; If null, we're done
    int 0x10        ; Call BIOS to print character in AL
    jmp .next_char  ; Print next character
.done:
    ret             ; Return from function

; Our message data
message db 'Hello, OS World! This is my first bootloader!', 13, 10, 0
; 13 = carriage return, 10 = line feed, 0 = null terminator

; Fill the rest of the 512-byte sector with zeros
times 510-($-$$) db 0

; Boot signature - BIOS looks for this to identify bootable sectors
dw 0xAA55
