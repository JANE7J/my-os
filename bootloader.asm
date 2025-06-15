[BITS 16]
[ORG 0x7C00]

start:
    ; Clear screen and set up segments
    mov ax, 0x03
    int 0x10
    
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    
    ; Display boot message
    mov si, boot_msg
    call print_string
    
    ; Load kernel sectors from disk
    mov ah, 0x02      ; Read sectors
    mov al, 4         ; Number of sectors to read (kernel)
    mov ch, 0         ; Cylinder 0
    mov dh, 0         ; Head 0
    mov cl, 2         ; Start from sector 2 (after boot sector)
    mov bx, 0x1000    ; Load kernel at 0x1000
    int 0x13
    
    jc disk_error
    
    ; Set up GDT
    cli
    lgdt [gdt_descriptor]
    
    ; Enable protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    ; Jump to protected mode
    jmp CODE_SEG:protected_mode

disk_error:
    mov si, disk_error_msg
    call print_string
    hlt

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

[BITS 32]
protected_mode:
    ; Set up data segments
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    ; Set up stack
    mov esp, 0x90000
    
    ; Jump to kernel
    jmp 0x1000

; GDT
gdt_start:
    ; Null descriptor
    dd 0x0
    dd 0x0

    ; Code segment
    dw 0xFFFF       ; Limit
    dw 0x0          ; Base (low)
    db 0x0          ; Base (middle)
    db 10011010b    ; Access byte
    db 11001111b    ; Granularity
    db 0x0          ; Base (high)

    ; Data segment
    dw 0xFFFF       ; Limit
    dw 0x0          ; Base (low)
    db 0x0          ; Base (middle)
    db 10010010b    ; Access byte
    db 11001111b    ; Granularity
    db 0x0          ; Base (high)

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_start + 8
DATA_SEG equ gdt_start + 16

boot_msg db 'Loading MyOS Kernel...', 13, 10, 0
disk_error_msg db 'Disk read error!', 13, 10, 0

times 510-($-$$) db 0
dw 0xAA55
