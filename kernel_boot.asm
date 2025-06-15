; Bootloader that switches to 32-bit mode and loads a C kernel
[BITS 16]
[ORG 0x7C00]

KERNEL_OFFSET equ 0x1000    ; Memory address where we'll load our kernel

start:
    ; Initialize segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000      ; Set stack well away from our code
    
    ; Print loading message
    mov si, loading_msg
    call print_string_16
    
    ; Load kernel from "disk" (in our case, we'll append it to the bootloader)
    call load_kernel
    
    ; Switch to 32-bit protected mode
    call switch_to_pm
    
    jmp $   ; Should never reach here

; 16-bit print function
print_string_16:
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x0F
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

; Load kernel (simplified - normally would read from disk)
load_kernel:
    mov si, kernel_loaded_msg
    call print_string_16
    ret

; Switch to 32-bit protected mode
switch_to_pm:
    cli                 ; Disable interrupts
    lgdt [gdt_descriptor] ; Load Global Descriptor Table
    
    ; Enable protected mode
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    
    ; Far jump to flush CPU pipeline and enter 32-bit mode
    jmp CODE_SEG:init_pm

[BITS 32]
init_pm:
    ; Set up 32-bit segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    ; Set up stack
    mov ebp, 0x90000
    mov esp, ebp
    
    ; Print success message in 32-bit mode
    mov esi, pm_success_msg
    call print_string_pm
    
    ; Jump to our kernel
    call KERNEL_OFFSET
    
    jmp $

; 32-bit print function (writes directly to video memory)
print_string_pm:
    pusha
    mov edx, 0xB8000    ; Video memory address
.loop:
    mov al, [esi]       ; Get character
    mov ah, 0x0F        ; White on black
    
    cmp al, 0
    je .done
    
    mov [edx], ax       ; Write to video memory
    add esi, 1          ; Next character
    add edx, 2          ; Next video memory position
    
    jmp .loop
.done:
    popa
    ret

; Global Descriptor Table
gdt_start:
gdt_null:               ; Mandatory null descriptor
    dd 0x0
    dd 0x0

gdt_code:               ; Code segment descriptor
    dw 0xFFFF           ; Limit (bits 0-15)
    dw 0x0              ; Base (bits 0-15)
    db 0x0              ; Base (bits 16-23)
    db 10011010b        ; Access byte
    db 11001111b        ; Granularity byte
    db 0x0              ; Base (bits 24-31)

gdt_data:               ; Data segment descriptor
    dw 0xFFFF           ; Limit (bits 0-15)
    dw 0x0              ; Base (bits 0-15)
    db 0x0              ; Base (bits 16-23)
    db 10010010b        ; Access byte
    db 11001111b        ; Granularity byte
    db 0x0              ; Base (bits 24-31)

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; GDT size
    dd gdt_start                ; GDT address

; Constants for GDT segment selectors
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; Messages
loading_msg:        db 'Loading MyOS Kernel...', 13, 10, 0
kernel_loaded_msg:  db 'Kernel loaded! Switching to 32-bit mode...', 13, 10, 0
pm_success_msg:     db 'Successfully entered 32-bit Protected Mode!', 0

; Pad to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xAA55

; Simple kernel code starts here (this will be at KERNEL_OFFSET)
[BITS 32]
kernel_start:
    ; Simple kernel that just prints a message
    mov esi, kernel_msg
    mov edi, 0xB8000 + 160*5    ; Row 5 of screen
    mov ah, 0x0A                ; Light green color
    
kernel_print_loop:
    mov al, [esi]
    cmp al, 0
    je kernel_done
    mov [edi], ax
    inc esi
    add edi, 2
    jmp kernel_print_loop
    
kernel_done:
    jmp $

kernel_msg: db 'Hello from the C Kernel! (Well, assembly for now)', 0

; Pad the entire sector
times 1024-($-$$) db 0
