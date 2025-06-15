[BITS 16]
[ORG 0x7C00]

start:
    ; Clear screen
    mov ax, 0x03
    int 0x10
    
    ; Set up segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    
    ; Test message in 16-bit mode
    mov si, boot_msg
    call print_16
    
    ; Wait a moment
    mov cx, 0xFFFF
wait_loop:
    loop wait_loop
    
    ; Set up GDT
    cli
    lgdt [gdt_descriptor]
    
    ; Enable protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    ; Jump to 32-bit mode
    jmp CODE_SEG:protected_mode

print_16:
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

[BITS 32]
protected_mode:
    ; Set up segments
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    ; Set up stack
    mov esp, 0x90000
    
    ; Test 32-bit mode
    mov edi, 0xB8000
    mov esi, protected_msg
    mov ah, 0x0F  ; White on black
    
print_32:
    lodsb
    cmp al, 0
    je setup_keyboard
    stosb
    mov al, ah
    stosb
    jmp print_32

setup_keyboard:
    ; Simple keyboard test
    mov edi, 0xB8000 + (3 * 80 * 2)  ; Line 3
    mov esi, key_msg
    mov ah, 0x0E  ; Yellow on black
    
print_key_msg:
    lodsb
    cmp al, 0
    je main_loop
    stosb
    mov al, ah
    stosb
    jmp print_key_msg

main_loop:
    ; Check for keyboard input
    in al, 0x64
    test al, 1
    jz main_loop
    
    in al, 0x60
    
    ; Ignore key releases
    test al, 0x80
    jnz main_loop
    
    ; Simple key test - just show scan code
    mov edi, 0xB8000 + (5 * 80 * 2)  ; Line 5
    
    ; Clear line first
    mov ecx, 80
    mov ax, 0x0720
    rep stosw
    
    ; Show "Key pressed: XX"
    mov edi, 0xB8000 + (5 * 80 * 2)
    mov esi, key_pressed_msg
    mov ah, 0x0C  ; Red on black
    
print_key_pressed:
    lodsb
    cmp al, 0
    je show_scancode
    stosb
    mov al, ah
    stosb
    jmp print_key_pressed

show_scancode:
    ; Convert scan code to hex and display
    mov bl, al  ; Save scan code
    mov al, bl
    shr al, 4
    add al, '0'
    cmp al, '9'
    jle .first_digit
    add al, 7
.first_digit:
    stosb
    mov al, 0x0C
    stosb
    
    mov al, bl
    and al, 0x0F
    add al, '0'
    cmp al, '9'
    jle .second_digit
    add al, 7
.second_digit:
    stosb
    mov al, 0x0C
    stosb
    
    jmp main_loop

; GDT
gdt_start:
    ; Null descriptor
    dd 0x0
    dd 0x0

    ; Code segment
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

    ; Data segment
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_start + 8
DATA_SEG equ gdt_start + 16

boot_msg db 'Booting MyOS Debug...', 13, 10, 0
protected_msg db 'Protected mode OK!', 0
key_msg db 'Press any key to test...', 0
key_pressed_msg db 'Key pressed: ', 0

times 510-($-$$) db 0
dw 0xAA55
