[BITS 16]
[ORG 0x7C00]

start:
    ; Test basic functionality first
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; Test 16-bit print first
    mov si, msg_test
    call print_string_16

    ; Wait a moment
    mov cx, 0xFFFF
wait_loop:
    loop wait_loop

    ; Try protected mode
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:protected_mode

; 16-bit print function
print_string_16:
    pusha
.loop:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10
    jmp .loop
.done:
    popa
    ret

msg_test db 'Testing 16-bit mode...', 13, 10, 0

; Minimal GDT
gdt_start:
    dq 0                 ; Null descriptor

gdt_code:
    dw 0xFFFF           ; Limit
    dw 0x0000           ; Base low
    db 0x00             ; Base mid
    db 10011010b        ; Access
    db 11001111b        ; Flags + Limit high
    db 0x00             ; Base high

gdt_data:
    dw 0xFFFF           ; Limit
    dw 0x0000           ; Base low
    db 0x00             ; Base mid
    db 10010010b        ; Access
    db 11001111b        ; Flags + Limit high
    db 0x00             ; Base high

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

    ; Clear screen in 32-bit mode
    mov edi, 0xB8000
    mov ecx, 2000
    mov ax, 0x0F20      ; White space
    rep stosw

    ; Display simple message
    mov edi, 0xB8000
    mov esi, msg_32bit
    mov ah, 0x0F
    call print_32

    ; Simple loop
hang:
    jmp hang

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

msg_32bit db 'Hello from 32-bit mode!', 0

; Fill to 510 bytes
times 510-($-$$) db 0
dw 0xAA55
