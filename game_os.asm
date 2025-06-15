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
    
    ; Generate random number 1-9
    mov eax, 0x12345678
    mov [secret], eax
    and eax, 7
    inc eax
    mov [secret], eax
    
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
    cmp al, 0x22 ; G
    je do_g
    ; Number keys 1-9
    cmp al, 0x02 ; 1
    je guess_1
    cmp al, 0x03 ; 2
    je guess_2
    cmp al, 0x04 ; 3
    je guess_3
    cmp al, 0x05 ; 4
    je guess_4
    cmp al, 0x06 ; 5
    je guess_5
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
    call clear
    jmp pm_start

do_h:
    mov esi, msg_h
    mov ah, 0x0B
    call show_color
    jmp loop

do_g:
    mov esi, msg_g
    mov ah, 0x0D
    call show_color
    jmp loop

guess_1:
    mov eax, 1
    call check_guess
    jmp loop

guess_2:
    mov eax, 2
    call check_guess
    jmp loop

guess_3:
    mov eax, 3
    call check_guess
    jmp loop

guess_4:
    mov eax, 4
    call check_guess
    jmp loop

guess_5:
    mov eax, 5
    call check_guess
    jmp loop

check_guess:
    cmp eax, [secret]
    je win_game
    jl too_low
    ; too high
    mov esi, msg_high
    mov ah, 0x0C
    call show_color
    ret

too_low:
    mov esi, msg_low
    mov ah, 0x09
    call show_color
    ret

win_game:
    mov esi, msg_win
    mov ah, 0x0A
    call show_color
    call beep
    call beep
    ; Generate new number
    mov eax, [secret]
    add eax, 12345
    and eax, 7
    inc eax
    mov [secret], eax
    ret

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
    mov ax, 1500
    out 0x42, al
    mov al, ah
    out 0x42, al
    in al, 0x61
    or al, 3
    out 0x61, al
    mov ecx, 0x4000
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

secret dd 0

welcome db 'MyOS Game v3.0', 0
help1 db 'A=About B=Beep C=Clear H=Help G=Game', 0
help2 db 'Game: Guess 1-5 (Press number keys)', 0
msg_a db 'Game OS!', 0
msg_b db 'BEEP!', 0
msg_h db 'Fun OS!', 0
msg_g db 'Guess 1-5!', 0
msg_win db 'WIN! New game!', 0
msg_high db 'Too high!', 0
msg_low db 'Too low!', 0

times 510-($-$$) db 0
dw 0xAA55
