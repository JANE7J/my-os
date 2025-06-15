; Stable bootloader with proper kernel
[BITS 16]
[ORG 0x7C00]

start:
    ; Initialize segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000
    
    ; Clear screen first
    mov ax, 0x0003
    int 0x10
    
    ; Print loading message
    mov si, loading_msg
    call print_string_16
    
    ; Small delay to see the message
    call delay
    
    ; Switch to 32-bit protected mode
    call switch_to_pm
    
    jmp $   ; Should never reach here

; 16-bit print function
print_string_16:
    mov ah, 0x0E
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

; Simple delay function
delay:
    mov cx, 0x8000
.delay_loop:
    loop .delay_loop
    ret

; Switch to 32-bit protected mode
switch_to_pm:
    cli                 ; Disable interrupts
    lgdt [gdt_descriptor] ; Load GDT
    
    ; Enable protected mode
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    
    ; Far jump to 32-bit code
    jmp CODE_SEG:init_pm

[BITS 32]
init_pm:
    ; Set up 32-bit segments
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    ; Set up stack
    mov ebp, 0x90000
    mov esp, ebp
    
    ; Print simple kernel message
    mov edi, 0xB8000
    mov esi, kernel_msg
    mov ah, 0x0F
.print_loop:
    lodsb
    test al, al
    jz .kernel_loop
    stosw
    jmp .print_loop
    
.kernel_loop:
    jmp .kernel_loop

; Global Descriptor Table
gdt_start:
gdt_null:
    dd 0x0, 0x0

gdt_code:
    dw 0xFFFF, 0x0
    db 0x0, 10011010b, 11001111b, 0x0

gdt_data:
    dw 0xFFFF, 0x0
    db 0x0, 10010010b, 11001111b, 0x0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; Messages
loading_msg:     db 'Loading MyOS Kernel...', 13, 10, 0
kernel_msg:      db 'MyOS Kernel Running in 32-bit Mode!', 0

; Fill boot sector
times 510-($-$$) db 0
dw 0xAA55
