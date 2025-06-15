; MyOS Kernel v2.0 - Fixed Version
; Professional Structure - No Label Conflicts

[BITS 16]
[ORG 0x7C00]

jmp start

start:
    ; Initialize
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    
    ; Set up colorful interface
    call setup_screen
    
    ; Display header
    call show_header
    
    ; Main command loop
main_loop:
    xor ah, ah
    int 0x16        ; Get keystroke
    
    ; Check commands
    cmp al, 'a'
    je cmd_about
    cmp al, 'A'
    je cmd_about
    
    cmp al, 'b'
    je cmd_beep
    cmp al, 'B'
    je cmd_beep
    
    cmp al, 'c'
    je cmd_clear
    cmp al, 'C'
    je cmd_clear
    
    cmp al, 'h'
    je cmd_help
    cmp al, 'H'
    je cmd_help
    
    cmp al, 'i'
    je cmd_info
    cmp al, 'I'
    je cmd_info
    
    cmp al, 'q'
    je cmd_quit
    cmp al, 'Q'
    je cmd_quit
    
    cmp al, 't'
    je cmd_time
    cmp al, 'T'
    je cmd_time
    
    jmp main_loop

; Commands
cmd_about:
    mov bl, 0x0C        ; Red
    mov si, msg_about
    call print_color
    jmp main_loop

cmd_beep:
    mov bl, 0x0E        ; Yellow
    mov si, msg_beep
    call print_color
    call make_beep
    jmp main_loop

cmd_clear:
    call setup_screen
    call show_header
    jmp main_loop

cmd_help:
    mov bl, 0x0B        ; Cyan
    mov si, msg_help
    call print_color
    jmp main_loop

cmd_info:
    mov bl, 0x0A        ; Green
    mov si, msg_info
    call print_color
    jmp main_loop

cmd_quit:
    mov bl, 0x0D        ; Magenta
    mov si, msg_quit
    call print_color
    hlt

cmd_time:
    mov bl, 0x09        ; Blue
    mov si, msg_time
    call print_color
    jmp main_loop

; Functions
setup_screen:
    mov ax, 0x0003      ; Clear screen
    int 0x10
    ret

show_header:
    ; Line 1: White on Red
    mov bl, 0x4F
    mov si, header1
    call print_color
    call newline
    
    ; Line 2: Yellow on Green
    mov bl, 0x2E
    mov si, header2
    call print_color
    call newline
    
    ; Line 3: Cyan on Blue
    mov bl, 0x1B
    mov si, header3
    call print_color
    call newline
    call newline
    ret

print_color:
    mov ah, 0x09
    mov bh, 0
    mov cx, 1
print_char_loop:
    lodsb
    test al, al
    jz print_done
    int 0x10
    
    ; Move cursor
    mov ah, 0x03
    int 0x10
    inc dl
    mov ah, 0x02
    int 0x10
    
    mov ah, 0x09
    jmp print_char_loop
print_done:
    ret

make_beep:
    mov ah, 0x0E
    mov al, 0x07        ; Bell character
    int 0x10
    ret

newline:
    mov bl, 0x07        ; Normal color for newline
    mov si, crlf
    call print_color
    ret

; Messages
header1     db 'MyOS Color v2.0', 0
header2     db 'A=About B=Beep C=Clear H=Help', 0
header3     db 'I=Info Q=Quit T=Time', 0

msg_about   db 'Mini OS!', 13, 10, 0
msg_beep    db 'BEEP!', 13, 10, 0
msg_help    db 'Help OK', 13, 10, 0
msg_info    db '32-bit', 13, 10, 0
msg_quit    db 'Bye!', 13, 10, 0
msg_time    db 'OK', 13, 10, 0

crlf        db 13, 10, 0

; Pad to 512 bytes and add boot signature
times 510-($-$$) db 0
dw 0xAA55
