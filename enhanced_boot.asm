[BITS 16]
[ORG 0x7C00]

start:
    ; Initialize segment registers
    cli                     ; Clear interrupts
    xor ax, ax             ; Zero out ax
    mov ds, ax             ; Set data segment
    mov es, ax             ; Set extra segment
    mov ss, ax             ; Set stack segment
    mov sp, 0x7C00         ; Set stack pointer
    sti                    ; Enable interrupts

    ; Display bootloader message
    mov si, msg_bootloader
    call print_string

    ; Small delay to show message
    call short_delay

    ; Display loading message
    mov si, msg_loading
    call print_string

    ; Load kernel from "disk" (simulate reading sectors)
    ; In a real OS, you'd use INT 13h to read disk sectors
    ; For now, the kernel will be appended to our bootloader
    mov si, msg_kernel_loaded
    call print_string
    
    ; Small delay before switching modes
    call short_delay

    ; Switch to protected mode
    cli                    ; Disable interrupts during mode switch
    lgdt [gdt_descriptor]  ; Load GDT

    ; Enable protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Far jump to flush pipeline and enter 32-bit mode
    jmp CODE_SEG:init_32bit

; 16-bit print function
print_string:
    pusha
.loop:
    lodsb                  ; Load byte from SI into AL
    or al, al              ; Check if null terminator
    jz .done
    mov ah, 0x0E           ; BIOS teletype function
    mov bh, 0              ; Page number
    mov bl, 0x07           ; Light gray on black
    int 0x10               ; BIOS video interrupt
    jmp .loop
.done:
    popa
    ret

; Simple delay function
short_delay:
    pusha
    mov cx, 0x0500         ; Delay counter
.delay_loop:
    nop
    nop
    nop
    loop .delay_loop
    popa
    ret

; Messages
msg_bootloader    db 'MyOS Bootloader Starting...', 13, 10, 0
msg_loading       db 'Loading C Kernel from disk...', 13, 10, 0
msg_kernel_loaded db 'Kernel loaded! Switching to 32-bit mode...', 13, 10, 0

; GDT (Global Descriptor Table)
gdt_start:
    ; Null descriptor
    dq 0

gdt_code:
    ; Code segment descriptor
    dw 0xFFFF          ; Limit 0-15
    dw 0x0000          ; Base 0-15
    db 0x00            ; Base 16-23
    db 10011010b       ; Access byte: present, ring 0, code, executable, readable
    db 11001111b       ; Flags + Limit 16-19: 4KB blocks, 32-bit
    db 0x00            ; Base 24-31

gdt_data:
    ; Data segment descriptor  
    dw 0xFFFF          ; Limit 0-15
    dw 0x0000          ; Base 0-15
    db 0x00            ; Base 16-23
    db 10010010b       ; Access byte: present, ring 0, data, writable
    db 11001111b       ; Flags + Limit 16-19: 4KB blocks, 32-bit
    db 0x00            ; Base 24-31

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1    ; GDT size
    dd gdt_start                  ; GDT address

; Constants
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

[BITS 32]
init_32bit:
    ; Set up 32-bit segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000      ; Set stack pointer to safe location

    ; Clear screen in 32-bit mode
    call clear_screen_32

    ; Display mode switch success message
    mov esi, msg_32bit
    mov edi, 0xB8000      ; Video memory
    mov ah, 0x0F          ; White text on black background
    call print_string_32

    ; Display transition message
    mov esi, msg_transition
    mov edi, 0xB8000 + (2*80*2)  ; Line 2
    mov ah, 0x0E                  ; Yellow
    call print_string_32

    ; Jump to C kernel at 0x1000
    ; The C kernel binary will be loaded at this address
    jmp 0x1000

; 32-bit screen clearing
clear_screen_32:
    pusha
    mov edi, 0xB8000      ; Video memory start
    mov ecx, 80*25        ; 80 columns * 25 rows
    mov ax, 0x0720        ; Gray text on black background, space character
    rep stosw             ; Fill screen with spaces
    popa
    ret

; 32-bit string printing
print_string_32:
    pusha
.loop:
    lodsb                 ; Load character from ESI
    or al, al             ; Check for null terminator
    jz .done
    mov [edi], al         ; Write character to video memory
    mov [edi+1], ah       ; Write attribute
    add edi, 2            ; Move to next character position
    jmp .loop
.done:
    popa
    ret

; 32-bit messages
msg_32bit         db 'Successfully entered 32-bit protected mode!', 0
msg_transition    db 'Jumping to C kernel at 0x1000...', 0

; Pad to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xAA55
