; MyOS Stage 2 Kernel - Fixed Calculator
; Fixed number display and arithmetic operations

[BITS 16]
[ORG 0x1000]

start:
    ; Clear screen
    mov ax, 0x0003
    int 0x10
    
    ; Display welcome message
    mov si, welcome_msg
    call print_string
    
    ; Display menu
    mov si, menu_msg
    call print_string

main_loop:
    ; Get user input
    call get_char
    
    ; Convert to uppercase
    cmp al, 'a'
    jl check_commands
    cmp al, 'z'
    jg check_commands
    sub al, 32
    
check_commands:
    cmp al, 'H'
    je show_help
    cmp al, 'T'
    je show_time
    cmp al, 'C'
    je clear_screen
    cmp al, 'K'
    je calculator
    cmp al, 'M'
    je memory_info
    cmp al, 'G'
    je mini_game
    cmp al, 'Q'
    je quit_os
    
    ; Invalid command
    mov si, invalid_msg
    call print_string
    jmp main_loop

show_help:
    mov si, help_msg
    call print_string
    jmp main_loop

show_time:
    mov si, time_msg
    call print_string
    jmp main_loop

clear_screen:
    mov ax, 0x0003
    int 0x10
    mov si, welcome_msg
    call print_string
    mov si, menu_msg
    call print_string
    jmp main_loop

; FIXED CALCULATOR - Proper number handling
calculator:
    mov si, calc_start_msg
    call print_string
    
    ; Get first number
    mov si, first_num_msg
    call print_string
    call get_digit
    mov [first_num], al    ; Store the actual digit (0-9)
    
    ; Display the entered number
    add al, '0'            ; Convert back to ASCII for display
    call print_char
    call print_newline
    
    ; Get operation
    mov si, operation_msg
    call print_string
    call get_operation
    mov [operation], al
    call print_char
    call print_newline
    
    ; Get second number
    mov si, second_num_msg
    call print_string
    call get_digit
    mov [second_num], al   ; Store the actual digit (0-9)
    
    ; Display the entered number
    add al, '0'            ; Convert back to ASCII for display
    call print_char
    call print_newline
    
    ; Perform calculation
    call do_calculation
    jmp main_loop

; Get a single digit (0-9) and return actual number
get_digit:
.wait_digit:
    call get_char
    cmp al, '0'
    jl .invalid_digit
    cmp al, '9'
    jg .invalid_digit
    sub al, '0'            ; Convert ASCII to actual number (0-9)
    ret
.invalid_digit:
    mov ah, 0x0E
    mov al, 7              ; Beep
    int 0x10
    jmp .wait_digit

; Get a valid operation (+, -, *, /)
get_operation:
.wait_op:
    call get_char
    cmp al, '+'
    je .valid_op
    cmp al, '-'
    je .valid_op
    cmp al, '*'
    je .valid_op
    cmp al, '/'
    je .valid_op
    ; Invalid operation
    mov ah, 0x0E
    mov al, 7              ; Beep
    int 0x10
    jmp .wait_op
.valid_op:
    ret

; Perform the actual calculation
do_calculation:
    mov si, result_msg
    call print_string
    
    ; Display: first_num operation second_num = result
    mov al, [first_num]
    add al, '0'
    call print_char
    
    mov al, ' '
    call print_char
    
    mov al, [operation]
    call print_char
    
    mov al, ' '
    call print_char
    
    mov al, [second_num]
    add al, '0'
    call print_char
    
    mov si, equals_msg
    call print_string
    
    ; Do the math
    mov al, [first_num]    ; Get actual number (0-9)
    mov bl, [second_num]   ; Get actual number (0-9)
    mov cl, [operation]
    
    cmp cl, '+'
    je .add
    cmp cl, '-'
    je .subtract
    cmp cl, '*'
    je .multiply
    cmp cl, '/'
    je .divide

.add:
    add al, bl
    jmp .show_result

.subtract:
    sub al, bl
    jmp .show_result

.multiply:
    mul bl                 ; Result in AL
    jmp .show_result

.divide:
    cmp bl, 0
    je .div_by_zero
    mov ah, 0
    div bl                 ; Result in AL
    jmp .show_result

.div_by_zero:
    mov si, div_zero_msg
    call print_string
    call print_newline
    ret

.show_result:
    ; Convert result to string and display
    call print_number
    call print_newline
    call print_newline
    ret

; Print a number (0-99)
print_number:
    mov ah, 0
    mov bl, 10
    div bl                 ; AL = tens, AH = ones
    
    cmp al, 0
    je .print_ones         ; If no tens, just print ones
    
    add al, '0'            ; Convert tens to ASCII
    call print_char
    
.print_ones:
    mov al, ah
    add al, '0'            ; Convert ones to ASCII
    call print_char
    ret

memory_info:
    mov si, memory_msg
    call print_string
    jmp main_loop

mini_game:
    mov si, game_msg
    call print_string
    call get_char
    mov si, game_result_msg
    call print_string
    jmp main_loop

quit_os:
    mov si, quit_msg
    call print_string
    cli
    hlt

; Utility functions
print_string:
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0x0E
    int 0x10
    ret

print_newline:
    mov ah, 0x0E
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    ret

get_char:
    mov ah, 0x00
    int 0x16
    ret

; Data section
welcome_msg db '=== MyOS v2.0 - Multi-Stage Operating System ===', 13, 10, 0
menu_msg db 'Commands: [H]elp [T]ime [C]lear [K]alc [M]emory [G]ame [Q]uit', 13, 10, '> ', 0
help_msg db 'Available Commands:', 13, 10
         db 'H - Show this help', 13, 10
         db 'T - Show system time', 13, 10
         db 'C - Clear screen', 13, 10
         db 'K - Calculator', 13, 10
         db 'M - Memory information', 13, 10
         db 'G - Mini game', 13, 10
         db 'Q - Quit OS', 13, 10, 13, 10, 0

time_msg db 'System Time: 12:34:56 (simulated)', 13, 10, 0
invalid_msg db 'Invalid command! Type H for help.', 13, 10, 0

; Calculator messages
calc_start_msg db '=== CALCULATOR ===', 13, 10, 0
first_num_msg db 'First number (0-9): ', 0
operation_msg db 'Operation (+,-,*,/): ', 0
second_num_msg db 'Second number (0-9): ', 0
result_msg db 'Result: ', 0
equals_msg db ' = ', 0
div_zero_msg db 'ERROR: Cannot divide by zero!', 0

memory_msg db 'Memory: 640KB Base, 15MB Extended (simulated)', 13, 10, 0

game_msg db 'Mini Game: Press any key to roll dice!', 13, 10, 0
game_result_msg db 'You rolled a 6! Lucky!', 13, 10, 0

quit_msg db 'Shutting down MyOS...', 13, 10, 0

; Calculator variables
first_num db 0
second_num db 0
operation db 0

; Padding to fill 2048 bytes
times 2048-($-$$) db 0
