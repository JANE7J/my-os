[org 0x7c00]
[bits 16]

start:
    mov si, msg
    call print
    jmp $

print:
    mov ah, 0x0e
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

msg db 'HELLO FROM BOOTLOADER!', 0

times 510-($-$$) db 0
dw 0xAA55
