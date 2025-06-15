; Stage 1 Bootloader - QEMU Compatible Version
[BITS 16]
[ORG 0x7C00]

start:
    ; Initialize segments
    xor ax, ax          ; Clear AX
    mov ds, ax          ; Set DS = 0
    mov es, ax          ; Set ES = 0
    mov ss, ax          ; Set SS = 0
    mov sp, 0x7C00      ; Set stack pointer

    ; Clear direction flag
    cld

    ; Display loading message
    mov si, loading_msg
    call print_string

    ; Load Stage 2 kernel from disk
    ; Read 4 sectors (2048 bytes) starting from sector 2
    mov ah, 0x02        ; BIOS read sectors function
    mov al, 4           ; Number of sectors to read (2048 bytes = 4 sectors)
    mov ch, 0           ; Cylinder/track = 0
    mov cl, 2           ; Sector = 2 (sector 1 is bootloader)
    mov dh, 0           ; Head = 0
    mov dl, 0x00        ; Drive = 0x00 (QEMU boot drive - FIXED!)
    mov bx, 0x1000      ; Load address = 0x1000
    mov es, bx          ; Set ES = 0x1000
    mov bx, 0           ; BX = 0 (ES:BX = 0x1000:0x0000)

    int 0x13            ; Execute disk read
    jc disk_error       ; Jump if carry flag set (error)

    ; Display success message
    mov si, success_msg
    call print_string

    ; Jump to Stage 2 kernel
    jmp 0x1000:0x0000

disk_error:
    mov si, error_msg
    call print_string
    hlt

print_string:
    push ax
    push bx
print_loop:
    lodsb
    cmp al, 0
    je print_done
    mov ah, 0x0E
    mov bh, 0x00
    int 0x10
    jmp print_loop
print_done:
    pop bx
    pop ax
    ret

; Messages
loading_msg db 'Loading MyOS...', 13, 10, 0
success_msg db 'Kernel loaded! Starting...', 13, 10, 0
error_msg   db 'Disk read error!', 13, 10, 0

; Pad to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xAA55
