	; Interactive bootloader with colors and keyboard input
[BITS 16]
[ORG 0x7C00]

start:
    ; Initialize segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    
    ; Clear screen
    mov ax, 0x0003
    int 0x10
    
    ; Print welcome message in bright green
    mov si, welcome_msg
    mov bl, 0x0A        ; Bright green color
    call print_string_color
    
    ; Print instruction message in yellow
    mov si, instruction_msg
    mov bl, 0x0E        ; Yellow color
    call print_string_color
    
main_loop:
    ; Wait for keypress
    mov ah, 0x00        ; BIOS keyboard input function
    int 0x16            ; Wait for key press (AL = ASCII, AH = scan code)
    
    ; Check what key was pressed
    cmp al, 'q'         ; Check if 'q' was pressed
    je quit_msg
    cmp al, 'c'         ; Check if 'c' was pressed  
    je color_demo
    cmp al, 'h'         ; Check if 'h' was pressed
    je show_help
    cmp al, 13          ; Check if Enter was pressed
    je new_line
    
    ; Echo the character back in white
    mov ah, 0x0E
    mov bl, 0x0F        ; Bright white
    mov bh, 0
    int 0x10
    
    jmp main_loop

quit_msg:
    mov si, goodbye_msg
    mov bl, 0x0C        ; Bright red
    call print_string_color
    jmp hang

color_demo:
    mov si, color_msg
    mov bl, 0x0B        ; Bright cyan
    call print_string_color
    
    ; Demo different colors
    mov si, red_text
    mov bl, 0x0C
    call print_string_color
    
    mov si, green_text  
    mov bl, 0x0A
    call print_string_color
    
    mov si, blue_text
    mov bl, 0x09
    call print_string_color
    
    jmp main_loop

show_help:
    mov si, help_msg
    mov bl, 0x0F        ; White
    call print_string_color
    jmp main_loop

new_line:
    mov ah, 0x0E
    mov al, 13          ; Carriage return
    int 0x10
    mov al, 10          ; Line feed
    int 0x10
    jmp main_loop

; Function to print colored string
print_string_color:
    push ax
    push bx
    mov ah, 0x0E        ; BIOS teletype function
    mov bh, 0           ; Page 0
.next_char:
    lodsb               ; Load character from SI
    test al, al         ; Check if end of string
    jz .done
    int 0x10            ; Print character with color in BL
    jmp .next_char
.done:
    pop bx
    pop ax
    ret

hang:
    jmp hang

; Messages
welcome_msg:     db 'Welcome to MyOS Bootloader v1.0!', 13, 10, 0
instruction_msg: db 'Press keys: (h)elp, (c)olors, (q)uit, or type anything!', 13, 10, 0
help_msg:        db 13, 10, 'Commands:', 13, 10
                 db '  h - Show this help', 13, 10
                 db '  c - Color demonstration', 13, 10  
                 db '  q - Quit with message', 13, 10
                 db '  Enter - New line', 13, 10, 0
color_msg:       db 13, 10, 'Color Demo:', 13, 10, 0
red_text:        db 'This is RED! ', 0
green_text:      db 'This is GREEN! ', 0  
blue_text:       db 'This is BLUE!', 13, 10, 0
goodbye_msg:     db 13, 10, 'Goodbye from MyOS! System halted.', 13, 10, 0

; Pad and boot signature
times 510-($-$$) db 0
dw 0xAA55
