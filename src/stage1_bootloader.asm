; Stage 1 Bootloader - Debug Version with Status Messages
; This version shows what's happening during the loading process

[org 0x7c00]
[bits 16]

; Constants
kernel_segment  equ 0x1000      ; Where to load kernel in memory
kernel_sectors  equ 2           ; How many sectors to read (1024 bytes = 2 sectors)

start:
    ; Initialize segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00          ; Stack grows downward from bootloader
    
    ; Clear screen
    mov ax, 0x0003
    int 0x10
    
    ; Show initial message
    mov si, boot_msg
    call print_string
    
    ; Load kernel from disk
    mov si, loading_msg
    call print_string
    
    ; Set up disk read
    mov ah, 0x02            ; Read sectors function
    mov al, kernel_sectors  ; Number of sectors to read
    mov ch, 0x00            ; Cylinder 0
    mov cl, 0x02            ; Sector 2 (sector 1 is bootloader)
    mov dh, 0x00            ; Head 0
    mov dl, 0x80            ; Drive 0 (first hard drive)
    mov bx, kernel_segment  ; Where to load (ES:BX = 0x0000:0x1000)
    
    int 0x13                ; BIOS disk interrupt
    jc disk_error           ; Jump if carry flag set (error)
    
    ; Show success message
    mov si, success_msg
    call print_string
    
    ; Show about to jump message
    mov si, jump_msg
    call print_string
    
    ; Jump to kernel
    jmp 0x0000:kernel_segment   ; Jump to 0x0000:0x1000
    
disk_error:
    mov si, error_msg
    call print_string
    ; Show error code
    mov ah, 0x0E
    mov al, ah              ; Show error code
    add al, '0'
    int 0x10
    jmp $                   ; Infinite loop

print_string:
    mov ah, 0x0E            ; Teletype output
    mov bh, 0x00            ; Page 0
.loop:
    lodsb                   ; Load byte from SI into AL
    test al, al             ; Test for null terminator
    jz .done
    int 0x10                ; Print character
    jmp .loop
.done:
    ret

; Messages
boot_msg     db 'Stage 1: MyOS Bootloader Starting...', 0x0D, 0x0A, 0
loading_msg  db 'Stage 1: Loading kernel from disk...', 0x0D, 0x0A, 0
success_msg  db 'Stage 1: Kernel loaded successfully!', 0x0D, 0x0A, 0
jump_msg     db 'Stage 1: Jumping to kernel...', 0x0D, 0x0A, 0
error_msg    db 'Stage 1: DISK ERROR! Code: ', 0

; Boot signature
times 510-($-$$) db 0
dw 0xAA55
