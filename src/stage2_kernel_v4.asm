; Stage 2 Kernel - Clean Version with 7 Essential Commands
; Removed F and S commands that were causing issues

[org 0x1000]
[bits 16]

start:
    ; Set up segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    
    ; Clear screen and set nice colors
    mov ax, 0x0003
    int 0x10
    
    ; Show welcome screen
    call show_welcome
    
    ; Main command loop
main_loop:
    mov si, prompt
    call print_string
    
    ; Get command
    call get_command
    
    ; Process command
    cmp al, 'h'
    je cmd_help
    cmp al, 'H'
    je cmd_help
    
    cmp al, 'a'
    je cmd_about
    cmp al, 'A'
    je cmd_about
    
    cmp al, 't'
    je cmd_time
    cmp al, 'T'
    je cmd_time
    
    cmp al, 'c'
    je cmd_clear
    cmp al, 'C'
    je cmd_clear
    
    cmp al, 'm'
    je cmd_memory
    cmp al, 'M'
    je cmd_memory
    
    cmp al, 'g'
    je cmd_game
    cmp al, 'G'
    je cmd_game
    
    cmp al, 'q'
    je cmd_quit
    cmp al, 'Q'
    je cmd_quit
    
    ; Unknown command
    call print_newline
    mov si, unknown_msg
    call print_string
    jmp main_loop

; Commands
cmd_help:
    call print_newline
    mov si, help_msg
    call print_string
    jmp main_loop

cmd_about:
    call print_newline
    mov si, about_msg
    call print_string
    jmp main_loop

cmd_time:
    call print_newline
    mov si, time_msg
    call print_string
    call get_time
    jmp main_loop

cmd_clear:
    mov ax, 0x0003
    int 0x10
    call show_welcome
    jmp main_loop

cmd_memory:
    call print_newline
    mov si, memory_msg
    call print_string
    call show_memory
    jmp main_loop

cmd_game:
    call print_newline
    call number_game
    jmp main_loop

cmd_quit:
    call print_newline
    mov si, quit_msg
    call print_string
    hlt

; Functions
show_welcome:
    mov si, welcome_msg
    call print_string
    ret

get_command:
    mov ah, 0x00
    int 0x16
    ; Echo the character
    mov ah, 0x0E
    mov bh, 0x00
    int 0x10
    ret

get_time:
    ; Get system time
    mov ah, 0x02
    int 0x1A
    ; DH = seconds, CL = minutes, CH = hours
    mov si, time_display
    call print_string
    ; Convert and display hours
    mov al, ch
    call print_hex
    mov al, ':'
    call print_char
    ; Convert and display minutes  
    mov al, cl
    call print_hex
    mov al, ':'
    call print_char
    ; Convert and display seconds
    mov al, dh
    call print_hex
    call print_newline
    ret

show_memory:
    mov si, mem_info
    call print_string
    ; Show available memory (simplified)
    mov ax, 0x0040
    mov es, ax
    mov ax, [es:0x13]  ; Memory size in KB
    call print_decimal
    mov si, kb_msg
    call print_string
    call print_newline
    ret

number_game:
    mov si, game_msg
    call print_string
    call print_newline
    mov si, game_prompt
    call print_string
    
    ; Simple number guessing game
    mov bl, 7  ; Secret number
    mov cl, 3  ; Attempts
    
game_loop:
    mov ah, 0x00
    int 0x16
    mov ah, 0x0E
    int 0x10
    
    sub al, '0'  ; Convert to number
    cmp al, bl
    je game_win
    
    dec cl
    jz game_lose
    
    mov si, try_again
    call print_string
    jmp game_loop

game_win:
    call print_newline
    mov si, win_msg
    call print_string
    ret

game_lose:
    call print_newline
    mov si, lose_msg
    call print_string
    ret

print_string:
    mov ah, 0x0E
    mov bh, 0x00
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0x0E
    mov bh, 0x00
    int 0x10
    ret

print_newline:
    mov ah, 0x0E
    mov bh, 0x00
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    ret

print_hex:
    push ax
    shr al, 4
    call print_hex_digit
    pop ax
    and al, 0x0F
    call print_hex_digit
    ret

print_hex_digit:
    cmp al, 9
    jle .digit
    add al, 7
.digit:
    add al, '0'
    call print_char
    ret

print_decimal:
    ; Simple decimal print (for small numbers)
    mov bl, 10
    xor cx, cx
.divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .divide
.print:
    pop ax
    add al, '0'
    call print_char
    loop .print
    ret

; Data section
welcome_msg db '=== MyOS Clean v4.1 ===', 0x0D, 0x0A
           db 'Multi-stage OS with 7 essential commands!', 0x0D, 0x0A
           db 'Type H for help, Q to quit', 0x0D, 0x0A, 0x0D, 0x0A, 0

prompt db 'MyOS> ', 0

help_msg db 'Available Commands:', 0x0D, 0x0A
        db 'H - Show this help', 0x0D, 0x0A
        db 'A - About this OS', 0x0D, 0x0A  
        db 'T - Show current time', 0x0D, 0x0A
        db 'C - Clear screen', 0x0D, 0x0A
        db 'M - Memory information', 0x0D, 0x0A
        db 'G - Play number game', 0x0D, 0x0A
        db 'Q - Quit', 0x0D, 0x0A, 0x0D, 0x0A, 0

about_msg db 'MyOS Clean v4.1', 0x0D, 0x0A
         db 'A custom operating system written in Assembly', 0x0D, 0x0A
         db 'Features: Multi-stage bootloader, unlimited kernel space', 0x0D, 0x0A
         db 'Commands: 7 essential functions that all work perfectly!', 0x0D, 0x0A, 0x0D, 0x0A, 0

time_msg db 'Current System Time: ', 0
time_display db '', 0

memory_msg db 'Memory Information:', 0x0D, 0x0A, 0
mem_info db 'Available RAM: ', 0
kb_msg db ' KB', 0

game_msg db 'Number Guessing Game!', 0x0D, 0x0A
        db 'I am thinking of a number between 1-9', 0
game_prompt db 'Enter your guess: ', 0
try_again db '  Wrong! Try again: ', 0
win_msg db '  Correct! You win!', 0x0D, 0x0A, 0x0D, 0x0A, 0
lose_msg db '  Game over! The number was 7', 0x0D, 0x0A, 0x0D, 0x0A, 0

unknown_msg db 'Unknown command. Type H for help.', 0x0D, 0x0A, 0
quit_msg db 'Thank you for using MyOS! Shutting down...', 0x0D, 0x0A, 0

; Pad to full size
times 2048-($-$$) db 0
