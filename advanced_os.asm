[BITS 16]
[ORG 0x7C00]

start:
    mov ax, 0x03
    int 0x10
    
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    
    lgdt [gdt_desc]
    
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    jmp 8:pm_start

[BITS 32]
pm_start:
    mov ax, 16
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov esp, 0x90000
    
    call clear
    
    ; Rainbow header
    mov esi, welcome
    mov edi, 0xB8000
    mov ah, 0x4F ; White on Red
    call print
    
    mov esi, help1
    mov edi, 0xB8000 + 160
    mov ah, 0x2E ; Yellow on Green
    call print
    
    mov esi, help2
    mov edi, 0xB8000 + 320
    mov ah, 0x1B ; Cyan on Blue
    call print
    
    ; Status line
    mov esi, status
    mov edi, 0xB8000 + 480
    mov ah, 0x70 ; Black on White
    call print

loop:
    in al, 0x64
    test al, 1
    jz loop
    
    in al, 0x60
    test al, 0x80
    jnz loop
    
    cmp al, 0x1E ; A
    je do_a
    cmp al, 0x30 ; B
    je do_b
    cmp al, 0x2E ; C
    je do_c
    cmp al, 0x23 ; H
    je do_h
    cmp al, 0x17 ; I
    je do_i
    cmp al, 0x10 ; Q
    je do_q
    cmp al, 0x14 ; T
    je do_t
    cmp al, 0x32 ; M
    je do_m
    cmp al, 0x1F ; S
    je do_s
    jmp loop

do_a:
    mov esi, msg_a
    mov ah, 0x0C ; Red
    call show_color
    jmp loop

do_b:
    mov esi, msg_b
    mov ah, 0x0E ; Yellow
    call show_color
    call beep
    jmp loop

do_c:
    call clear
    jmp pm_start

do_h:
    mov esi, msg_h
    mov ah, 0x0B ; Cyan
    call show_color
    jmp loop

do_i:
    mov esi, msg_i
    mov ah, 0x0A ; Green
    call show_color
    jmp loop

do_q:
    mov esi, msg_q
    mov ah, 0x0D ; Magenta
    call show_color
    jmp loop

do_t:
    mov esi, msg_t
    mov ah, 0x09 ; Blue
    call show_color
    jmp loop

do_m:
    mov esi, msg_m
    mov ah, 0x0F ; White
    call show_color
    jmp loop

do_s:
    mov esi, msg_s
    mov ah, 0x06 ; Brown
    call show_color
    jmp loop

clear:
    mov edi, 0xB8000
    mov ecx, 2000
    mov ax, 0x0720
    rep stosw
    ret

print:
.lp:
    lodsb
    test al, al
    jz .done
    stosb
    mov al, ah
    stosb
    jmp .lp
.done:
    ret

show_color:
    ; Clear message area
    mov edi, 0xB8000 + 1600
    mov ecx, 80
    mov ax, 0x0720
    rep stosw
    ; Show colored message
    mov edi, 0xB8000 + 1600
    call print
    ret

beep:
    mov al, 0xB6
    out 0x43, al
    mov ax, 1000
    out 0x42, al
    mov al, ah
    out 0x42, al
    in al, 0x61
    or al, 3
    out 0x61, al
    mov ecx, 0x8000
.w:
    loop .w
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    ret

gdt:
    dd 0, 0
    dd 0x0000FFFF, 0x00CF9A00
    dd 0x0000FFFF, 0x00CF9200

gdt_desc:
    dw 23
    dd gdt

welcome db 'MyOS Advanced v2.0', 0
help1 db 'A=About B=Beep C=Clear H=Help I=Info', 0
help2 db 'Q=Quit T=Time M=Memory S=System', 0
status db 'Status: 9 Commands Ready!', 0
msg_a db 'Custom OS Built!', 0
msg_b db 'BEEP Sound!', 0
msg_h db '9 Color Commands', 0
msg_i db '32-bit Protected', 0
msg_q db 'Goodbye User!', 0
msg_t db 'System Time OK', 0
msg_m db 'Memory: 640KB', 0
msg_s db 'All Systems GO!', 0

times 510-($-$$) db 0
dw 0xAA55
