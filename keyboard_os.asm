[BITS 16]
[ORG 0x7C00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; Show loading message
    mov si, msg_loading
    call print_16

    ; Switch to protected mode
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:protected_mode

print_16:
    pusha
.loop:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .loop
.done:
    popa
    ret

msg_loading db 'MyOS Loading...', 13, 10, 0

; GDT
gdt_start:
    dq 0

gdt_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

[BITS 32]
protected_mode:
    ; Set up segments
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    ; Clear screen
    mov edi, 0xB8000
    mov ecx, 2000
    mov ax, 0x0720
    rep stosw

    ; Show welcome interface
    mov esi, welcome_msg
    mov edi, 0xB8000
    mov ah, 0x0F
    call print_32

    mov esi, keys_msg
    mov edi, 0xB8000 + (2*80*2)
    mov ah, 0x0A
    call print_32

    mov esi, status_msg
    mov edi, 0xB8000 + (4*80*2)
    mov ah, 0x0E
    call print_32

keyboard_loop:
    ; Check for keypress
    in al, 0x64
    test al, 1
    jz keyboard_loop
    
    ; Read the key
    in al, 0x60
    
    ; Handle different keys
    cmp al, 0x1E    ; A key pressed
    je handle_a
    cmp al, 0x30    ; B key pressed  
    je handle_b
    cmp al, 0x2E    ; C key pressed
    je handle_c
    cmp al, 0x23    ; H key pressed
    je handle_h
    
    ; Unknown key - show message
    mov esi, unknown_msg
    jmp show_response

handle_a:
    mov esi, response_a
    jmp show_response

handle_b:
    mov esi, response_b
    jmp show_response

handle_c:
    ; Clear screen and restart
    jmp protected_mode

handle_h:
    mov esi, response_h
    jmp show_response

show_response:
    ; Clear status line
    mov edi, 0xB8000 + (20*80*2)
    mov ecx, 80
    mov ax, 0x0720
    rep stosw
    
    ; Show response
    mov edi, 0xB8000 + (20*80*2)
    mov ah, 0x0C
    call print_32
    
    jmp keyboard_loop

print_32:
.loop:
    lodsb
    or al, al
    jz .done
    mov [edi], al
    mov [edi+1], ah
    add edi, 2
    jmp .loop
.done:
    ret

; Messages
welcome_msg  db 'MyOS v1.0', 0
keys_msg     db 'A=Action B=Beep C=Clear H=Help', 0
status_msg   db 'Ready...', 0
response_a   db 'A: System OK!', 0
response_b   db 'B: *BEEP*', 0
response_h   db 'H: Try A,B,C,H', 0
unknown_msg  db 'Unknown key', 0

times 510-($-$$) db 0
dw 0xAA55
