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
    
    mov dword [num], 0
    
    call clear
    
    mov esi, welcome
    mov edi, 0xB8000
    mov ah, 0x4F
    call print
    
    mov esi, help1
    mov edi, 0xB8000 + 160
    mov ah, 0x2E
    call print
    
    mov esi, help2
    mov edi, 0xB8000 + 320
    mov ah, 0x1B
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
    cmp al, 0x02 ; 1
    je add_1
    cmp al, 0x03 ; 2
    je add_2
    cmp al, 0x04 ; 3
    je add_3
    cmp al, 0x1C ; Enter
    je show_total
    jmp loop

do_a:
    mov esi, msg_a
    mov ah, 0x0C
    call show_color
    jmp loop

do_b:
    mov esi, msg_b
    mov ah, 0x0E
    call show_color
    call beep
    jmp loop

do_c:
    mov dword [num], 0
    call clear
    jmp pm_start

do_h:
    mov esi, msg_h
    mov ah, 0x0B
    call show_color
    jmp loop

add_1:
    add dword [num], 1
    mov esi, msg_1
    mov ah, 0x0A
    call show_color
    jmp loop

add_2:
    add dword [num], 2
    mov esi, msg_2
    mov ah, 0x0D
    call show_color
    jmp loop

add_3:
    add dword [num], 3
    mov esi, msg_3
    mov ah, 0x09
    call show_color
    jmp loop

show_total:
    mov eax, [num]
    cmp eax, 10
    jl small_num
    mov esi, msg_big
    jmp show_result
small_num:
    mov esi, msg_small
show_result:
    mov ah, 0x0F
    call show_color
    call beep
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
    mov edi, 0xB8000 + 1600
    mov ecx, 80
    mov ax, 0x0720
    rep stosw
    mov edi, 0xB8000 + 1600
    call print
    ret

beep:
    mov al, 0xB6
    out 0x43, al
    mov ax, 1200
    out 0x42, al
    mov al, ah
    out 0x42, al
    in al, 0x61
    or al, 3
    out 0x61, al
    mov ecx, 0x6000
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

num dd 0

welcome db 'MyOS Calc v3.0', 0
help1 db 'A=About B=Beep C=Clear H=Help', 0
help2 db 'Math: 1 2 3 (add) Enter=Total', 0
msg_a db 'Calc OS!', 0
msg_b db 'BEEP!', 0
msg_h db 'Math Fun!', 0
msg_1 db 'Added 1', 0
msg_2 db 'Added 2', 0
msg_3 db 'Added 3', 0
msg_small db 'Small Total!', 0
msg_big db 'Big Total!', 0

times 510-($-$$) db 0
dw 0xAA55
