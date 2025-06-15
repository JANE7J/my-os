[BITS 16]
[ORG 0x7C00]

start:
    ; Quick setup
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; Show loading message
    mov si, msg_loading
    call print_string

    ; Switch to protected mode
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:protected_mode_start

; 16-bit print function
print_string:
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

; Messages
msg_loading db 'MyOS Keyboard', 0

; GDT setup
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
protected_mode_start:
    ; Set up segments
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    ; Clear screen and show interface
    call clear_screen
    
    mov esi, msg_welcome
    mov edi, 0xB8000
    mov ah, 0x0F
    call print_string_32

    mov esi, msg_keys
    mov edi, 0xB8000 + (2*80*2)
    mov ah, 0x0A
    call print_string_32

clear_screen:
    mov edi, 0xB8000
    mov ecx, 2000
    mov ax, 0x0720
    rep stosw
    ret

main_loop:
    ; Simple keyboard polling
    in al, 0x64          ; Keyboard status
    test al, 1           ; Data available?
    jz main_loop
    
    in al, 0x60          ; Read scancode
    
    ; Simple key handling
    cmp al, 0x1E         ; A key
    je key_a
    cmp al, 0x30         ; B key
    je key_b
    cmp al, 0x2E         ; C key
    je key_c
    cmp al, 0x23         ; H key
    je key_h
    jmp main_loop

key_a:
    mov esi, msg_a
    jmp show_msg
key_b:
    mov esi, msg_b
    jmp show_msg
key_c:
    call clear_screen
    jmp protected_mode_start
key_h:
    mov esi, msg_h
    
show_msg:
    mov edi, 0xB8000 + (22*80*2)
    mov ecx, 80
    mov ax, 0x0720
    rep stosw
    
    mov edi, 0xB8000 + (22*80*2)
    mov ah, 0x0C
    call print_string_32
    jmp main_loop

print_string_32:
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
msg_welcome db 'MyOS Interactive v1.0 - Keyboard Ready!', 0
msg_keys    db 'Press: A=Action B=Beep C=Clear H=Help', 0
msg_a       db 'A pressed: System running OK!', 0
msg_b       db 'B pressed: *BEEP* Sound active!', 0
msg_h       db 'H pressed: Help - Try A,B,C,H keys', 0

times 510-($-$$) db 0
dw 0xAA55
