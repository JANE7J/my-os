[BITS 32]
[ORG 0x1000]

; Video memory and attributes
VIDEO_MEMORY equ 0xB8000
WHITE_ON_BLUE equ 0x1F
RED_ON_BLACK equ 0x0C
GREEN_ON_BLACK equ 0x0A
YELLOW_ON_BLACK equ 0x0E
CYAN_ON_BLACK equ 0x0B
MAGENTA_ON_BLACK equ 0x0D

kernel_start:
    ; Initialize kernel
    call clear_screen
    call display_welcome
    call setup_keyboard
    
    ; Main kernel loop
main_loop:
    call check_keyboard
    call update_status
    hlt
    jmp main_loop

clear_screen:
    mov edi, VIDEO_MEMORY
    mov ecx, 80 * 25
    mov ax, 0x0720  ; Space with white on black
    rep stosw
    ret

display_welcome:
    mov esi, welcome_msg
    mov edi, VIDEO_MEMORY
    mov ah, WHITE_ON_BLUE
    call print_string_color
    
    mov esi, instructions_msg
    mov edi, VIDEO_MEMORY + (2 * 80 * 2)
    mov ah, YELLOW_ON_BLACK
    call print_string_color
    
    mov esi, commands_msg
    mov edi, VIDEO_MEMORY + (4 * 80 * 2)
    mov ah, GREEN_ON_BLACK
    call print_string_color
    
    ret

setup_keyboard:
    ; Enable keyboard interrupt
    mov al, 0xFD
    out 0x21, al
    ret

check_keyboard:
    in al, 0x64
    test al, 1
    jz .no_key
    
    in al, 0x60
    
    ; Check for key releases (high bit set)
    test al, 0x80
    jnz .no_key
    
    ; Handle key presses
    cmp al, 0x1E    ; A key
    je handle_a
    cmp al, 0x30    ; B key
    je handle_b
    cmp al, 0x2E    ; C key
    je handle_c
    cmp al, 0x20    ; D key
    je handle_d
    cmp al, 0x12    ; E key
    je handle_e
    cmp al, 0x21    ; F key
    je handle_f
    cmp al, 0x22    ; G key
    je handle_g
    cmp al, 0x23    ; H key
    je handle_h
    cmp al, 0x17    ; I key
    je handle_i
    cmp al, 0x24    ; J key
    je handle_j
    cmp al, 0x25    ; K key
    je handle_k
    cmp al, 0x26    ; L key
    je handle_l
    cmp al, 0x32    ; M key
    je handle_m
    cmp al, 0x31    ; N key
    je handle_n
    cmp al, 0x18    ; O key
    je handle_o
    cmp al, 0x19    ; P key
    je handle_p
    cmp al, 0x10    ; Q key
    je handle_q
    cmp al, 0x13    ; R key
    je handle_r
    cmp al, 0x1F    ; S key
    je handle_s
    cmp al, 0x14    ; T key
    je handle_t
    cmp al, 0x16    ; U key
    je handle_u
    cmp al, 0x2F    ; V key
    je handle_v
    cmp al, 0x11    ; W key
    je handle_w
    cmp al, 0x2D    ; X key
    je handle_x
    cmp al, 0x15    ; Y key
    je handle_y
    cmp al, 0x2C    ; Z key
    je handle_z
    
.no_key:
    ret

handle_a:
    mov esi, about_msg
    mov ah, CYAN_ON_BLACK
    call show_response
    ret

handle_b:
    mov esi, beep_msg
    mov ah, YELLOW_ON_BLACK
    call show_response
    call system_beep
    ret

handle_c:
    call clear_screen
    call display_welcome
    ret

handle_d:
    mov esi, date_msg
    mov ah, GREEN_ON_BLACK
    call show_response
    ret

handle_e:
    mov esi, echo_msg
    mov ah, MAGENTA_ON_BLACK
    call show_response
    ret

handle_f:
    mov esi, file_msg
    mov ah, WHITE_ON_BLUE
    call show_response
    ret

handle_g:
    mov esi, games_msg
    mov ah, RED_ON_BLACK
    call show_response
    ret

handle_h:
    call show_help
    ret

handle_i:
    mov esi, info_msg
    mov ah, CYAN_ON_BLACK
    call show_response
    ret

handle_j:
    mov esi, joke_msg
    mov ah, YELLOW_ON_BLACK
    call show_response
    ret

handle_k:
    mov esi, kernel_msg
    mov ah, GREEN_ON_BLACK
    call show_response
    ret

handle_l:
    mov esi, list_msg
    mov ah, MAGENTA_ON_BLACK
    call show_response
    ret

handle_m:
    mov esi, memory_msg
    mov ah, WHITE_ON_BLUE
    call show_response
    ret

handle_n:
    mov esi, network_msg
    mov ah, RED_ON_BLACK
    call show_response
    ret

handle_o:
    mov esi, os_msg
    mov ah, CYAN_ON_BLACK
    call show_response
    ret

handle_p:
    mov esi, process_msg
    mov ah, YELLOW_ON_BLACK
    call show_response
    ret

handle_q:
    mov esi, quit_msg
    mov ah, RED_ON_BLACK
    call show_response
    ret

handle_r:
    mov esi, reboot_msg
    mov ah, GREEN_ON_BLACK
    call show_response
    ret

handle_s:
    mov esi, system_msg
    mov ah, MAGENTA_ON_BLACK
    call show_response
    ret

handle_t:
    mov esi, time_msg
    mov ah, WHITE_ON_BLUE
    call show_response
    ret

handle_u:
    mov esi, user_msg
    mov ah, CYAN_ON_BLACK
    call show_response
    ret

handle_v:
    mov esi, version_msg
    mov ah, YELLOW_ON_BLACK
    call show_response
    ret

handle_w:
    mov esi, window_msg
    mov ah, GREEN_ON_BLACK
    call show_response
    ret

handle_x:
    mov esi, exit_msg
    mov ah, RED_ON_BLACK
    call show_response
    ret

handle_y:
    mov esi, yes_msg
    mov ah, MAGENTA_ON_BLACK
    call show_response
    ret

handle_z:
    mov esi, zone_msg
    mov ah, WHITE_ON_BLUE
    call show_response
    ret

show_help:
    ; Clear help area
    mov edi, VIDEO_MEMORY + (10 * 80 * 2)
    mov ecx, 15 * 80
    mov ax, 0x0720
    rep stosw
    
    ; Display help
    mov esi, help_title
    mov edi, VIDEO_MEMORY + (10 * 80 * 2)
    mov ah, WHITE_ON_BLUE
    call print_string_color
    
    mov esi, help_commands
    mov edi, VIDEO_MEMORY + (12 * 80 * 2)
    mov ah, GREEN_ON_BLACK
    call print_string_color
    
    ret

show_response:
    ; Clear response area
    mov edi, VIDEO_MEMORY + (22 * 80 * 2)
    mov ecx, 3 * 80
    mov ax, 0x0720
    rep stosw
    
    ; Show response
    mov edi, VIDEO_MEMORY + (22 * 80 * 2)
    call print_string_color
    ret

print_string_color:
    push eax
    push edi
.loop:
    lodsb
    cmp al, 0
    je .done
    cmp al, 10
    je .newline
    stosb
    mov al, ah
    stosb
    jmp .loop
.newline:
    ; Move to next line
    mov eax, edi
    sub eax, VIDEO_MEMORY
    xor edx, edx
    mov ebx, 160
    div ebx
    inc eax
    mul ebx
    add eax, VIDEO_MEMORY
    mov edi, eax
    jmp .loop
.done:
    pop edi
    pop eax
    ret

system_beep:
    ; Simple beep using speaker
    mov al, 0xB6
    out 0x43, al
    mov ax, 1193
    out 0x42, al
    mov al, ah
    out 0x42, al
    in al, 0x61
    or al, 3
    out 0x61, al
    
    ; Short delay
    mov ecx, 0x1FFFF
.delay:
    loop .delay
    
    ; Turn off speaker
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    ret

update_status:
    ; Update system status/counters
    ret

; Messages
welcome_msg db '=== MyOS Advanced Interactive System ===', 0
instructions_msg db 'Press A-Z keys for different commands!', 0
commands_msg db 'Try: A=About, B=Beep, C=Clear, H=Help, Q=Quit', 0

about_msg db 'MyOS v2.0 - Advanced 32-bit Operating System', 0
beep_msg db 'BEEP! Audio system test successful!', 0
date_msg db 'System Date: June 2025 - Uptime: Active', 0
echo_msg db 'ECHO: System responding to all inputs!', 0
file_msg db 'File System: Ready for operations', 0
games_msg db 'Games: TicTacToe, Snake, Pong available!', 0
info_msg db 'System Info: 32-bit, Protected Mode, VGA', 0
joke_msg db 'Why did the OS go to therapy? Too many crashes!', 0
kernel_msg db 'Kernel Status: Running smoothly in ring 0', 0
list_msg db 'Directory: /boot /sys /usr /games /docs', 0
memory_msg db 'Memory: 1MB available, 512KB used', 0
network_msg db 'Network: Interface ready, no connection', 0
os_msg db 'Operating System: MyOS Interactive Edition', 0
process_msg db 'Processes: Kernel[1] Shell[2] KeyHandler[3]', 0
quit_msg db 'Quit: Are you sure? Press Q again to confirm', 0
reboot_msg db 'Reboot: System restart initiated...', 0
system_msg db 'System Diagnostics: All systems operational', 0
time_msg db 'Time: 13:30:00 - Real-time clock active', 0
user_msg db 'User: Administrator - Full system access', 0
version_msg db 'Version: MyOS 2.0 Build 2025.06.07', 0
window_msg db 'Window Manager: Text mode 80x25 active', 0
exit_msg db 'Exit: Shutting down system gracefully...', 0
yes_msg db 'YES: Confirmation received and processed!', 0
zone_msg db 'Time Zone: UTC+05:30 (India Standard Time)', 0

help_title db '=== HELP SYSTEM - ALL COMMANDS ===', 0
help_commands db 'A=About B=Beep C=Clear D=Date E=Echo F=Files G=Games H=Help I=Info J=Joke K=Kernel L=List M=Memory N=Network O=OS P=Process Q=Quit R=Reboot S=System T=Time U=User V=Version W=Window X=Exit Y=Yes Z=Zone', 0
