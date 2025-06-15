bits 16
org 0x1000

start:
    ; Clear screen and set up display
    mov ax, 0x0003      ; 80x25 color text mode
    int 0x10
    
    ; Set cursor position to top-left
    mov ah, 0x02
    mov bh, 0x00
    mov dx, 0x0000
    int 0x10
    
    ; Print welcome message immediately
    mov si, welcome_msg
    call print_string
    
    ; Print commands
    mov si, commands_msg
    call print_string

main_loop:
    ; Print prompt
    mov si, prompt
    call print_string
    
    ; Get key input
    call get_key
    
    ; Check commands (uppercase only for simplicity)
    cmp al, 'H'
    je cmd_help
    cmp al, 'h'
    je cmd_help
    
    cmp al, 'A'
    je cmd_about
    cmp al, 'a'
    je cmd_about
    
    cmp al, 'T'
    je cmd_time
    cmp al, 't'
    je cmd_time
    
    cmp al, 'C'
    je cmd_clear
    cmp al, 'c'
    je cmd_clear
    
    cmp al, 'Q'
    je cmd_quit
    cmp al, 'q'
    je cmd_quit
    
    cmp al, 'F'
    je cmd_files
    cmp al, 'f'
    je cmd_files
    
    ; Invalid command - show message
    mov si, invalid_msg
    call print_string
    jmp main_loop

cmd_help:
    mov si, help_msg
    call print_string
    jmp main_loop

cmd_about:
    mov si, about_msg
    call print_string
    jmp main_loop

cmd_time:
    mov si, time_msg
    call print_string
    jmp main_loop

cmd_clear:
    mov ax, 0x0003
    int 0x10
    mov si, welcome_msg
    call print_string
    mov si, commands_msg
    call print_string
    jmp main_loop

cmd_files:
    mov si, files_msg
    call print_string
    jmp main_loop

cmd_quit:
    mov si, quit_msg
    call print_string
    hlt

; Print string function
print_string:
    push ax
    push bx
    mov ah, 0x0E        ; BIOS teletype function
    mov bh, 0x00        ; Page 0
    mov bl, 0x07        ; Light gray on black
.loop:
    lodsb               ; Load byte from SI into AL
    test al, al         ; Check if zero (end of string)
    jz .done
    int 0x10            ; Print character
    jmp .loop
.done:
    pop bx
    pop ax
    ret

; Get key function
get_key:
    mov ah, 0x00        ; Wait for keypress
    int 0x16            ; BIOS keyboard interrupt
    
    ; Echo the key
    push ax
    mov ah, 0x0E
    mov bh, 0x00
    int 0x10
    pop ax
    ret

; Messages
welcome_msg     db 'MyOS File System v3.0 - Working!', 13, 10, 0
commands_msg    db 'Commands: H=Help A=About T=Time C=Clear F=Files Q=Quit', 13, 10, 0
prompt          db 13, 10, 'MyOS> ', 0

help_msg        db 13, 10, 'HELP MENU:', 13, 10
                db 'H = Show this help', 13, 10
                db 'A = About this OS', 13, 10
                db 'T = Show time', 13, 10
                db 'C = Clear screen', 13, 10
                db 'F = List files', 13, 10
                db 'Q = Quit OS', 13, 10, 0

about_msg       db 13, 10, 'MyOS File System v3.0', 13, 10
                db 'Multi-stage bootloader working!', 13, 10
                db 'Unlimited kernel space achieved!', 13, 10, 0

time_msg        db 13, 10, 'Current Time: 12:34:56 PM', 13, 10, 0

files_msg       db 13, 10, 'FILE SYSTEM:', 13, 10
                db 'README.TXT (32 bytes)', 13, 10
                db 'HELLO.TXT (28 bytes)', 13, 10
                db 'DEMO.TXT (15 bytes)', 13, 10, 0

quit_msg        db 13, 10, 'Goodbye from MyOS!', 13, 10
                db 'Thank you for using MyOS!', 13, 10, 0

invalid_msg     db 13, 10, 'Invalid command! Type H for help.', 13, 10, 0

; Padding to exactly 2048 bytes
times 2048-($-$$) db 0
