ORG 0x7e00          ; Dirección de inicio del código


;; Definición de variables

playerX     equ 0FA00h
playerY     equ 0FA04h
col         equ 0FA08h
row         equ 0FA09h
s_names     equ 0FA0Ah
sprites     equ 0FA0Ah

;; Constantes
; pantalla
SCREEN_WIDTH        equ 320     ; Ancho en pixeles
SCREEN_HEIGHT       equ 200     ; Alto en pixeles
VIDEO_MEMORY        equ 0xA000
; sprites
SPRITE_HEIGHT       equ 8
SPRITE_WIDTH        equ 8       
SPRITE_WIDTH_PIXELS equ 16      

; Colors
NAMES_COLOR           equ 0Eh   ; blanco     ;; para imprimir texto

;; SETUP 
mov ah, 0x3c          ; Establece el contador inicial en 10
mov ax, 0013h         ; establece el modo de video VGA 13h
int 10h               ; interrupcion invoca servicios de vídeo de la ROM BIOS

;; Set up video memory
push VIDEO_MEMORY
pop es          

;; Move data incial del sprite
mov di, sprites
mov si, sprite_bitmaps
mov cl, 6
rep movsw

push es
pop ds

welcome_loop:
    xor ax, ax      ; Limpia la pantalla a color negro
    xor di, di
    mov cx, SCREEN_WIDTH*SCREEN_HEIGHT
    rep stosb   

    call print_welcome

    get_start:
        ; Habilita keyboard interrupt
        mov ah, 0x00        
        int 0x16            ; Llama keyboard interrupt
        jc game_loop        
        
        ; Revisa si se preciona espacio para inciar el juego
        cmp al, 0x20       
        je game_loop      ; Salta al game_loop para inciar el juego
        jmp welcome_loop

;; -------------------------------------------------------------------
;; PRINT INFO JUEGO
;; -------------------------------------------------------------------

print_welcome:

  ret

game_loop:
    xor ax, ax     ; Limpia la pantalla a color negro
    xor di, di
    mov cx, SCREEN_WIDTH*SCREEN_HEIGHT
    rep stosb   

    ;; Dibujar nombres
    mov al, [playerX]
    push si
    mov si, s_names
    mov ah, [playerY]
    xchg ah, al
    mov bl, NAMES_COLOR    

    call draw_sprite

    get_input:
        ; Habilitar la interrupción del teclado
        mov ah, 0x00        
        int 0x16            ; Llama a la interrupción del teclado. Invoca los servicios estándar del teclado de la ROM BIOS
        ;jc game_loop        
        
        ; Comprobar si se presionó una tecla de flecha
        cmp ah, 0x48        ; Comprobar si la tecla presionada es la flecha hacia arriba
        je rot_180_up       ; Si es así, salta a la etiqueta rot_180_up
        cmp ah, 0x50        ; Comprobar si la tecla presionada es la flecha hacia abajo
        je rot_180_down       ; Si es así, salta a la etiqueta rot_180_down
        cmp ah, 0x4B        ; Comprobar si la tecla presionada es la flecha hacia la izquierda
        je rot_90_left        ; Si es así, salta a la etiqueta rot_90_left
        cmp ah, 0x4D        ; Comprobar si la tecla presionada es la flecha hacia la derecha
        je rot_90_rigth        ; Si es así, salta a la etiqueta rot_90_rigth
                
        ; Comprobar si se presionó la tecla Z o X
        cmp al, 'x'         ; Comprobar si la tecla presionada es la tecla X
        je restart          ; Si es así, salta a la etiqueta restart
        
        cmp al, 0x0D        ; Comprobar si la tecla presionada es la tecla Enter
        je finish_game       ; Si es así, salta a la etiqueta finish_game

        jmp game_loop

        ;Flecha arriba 
        rot_180_up:

            jmp game_loop

        ;Flecha abajo
        rot_180_down:

            jmp game_loop

        ;Flecha izquierda
        rot_90_left:

            jmp game_loop

        ;Flecha derecha
        rot_90_rigth:

            jmp game_loop

        ;tecla X
        restart:
            jmp game_loop

        ;tecla Enter (finish game)
        finish_game:
            ; Restaurar el modo de video original
            mov ax, 0x03 ; Restaurar modo de video original
            int 0x10

            ; Salir del programa
            mov ax, 0x4C00 ; Salir del programa
            int 0x21 ;Invoca a todos los servicios de llamada a función DOS



;; -------------------------------------------------------------------
;; DIBUJAR NOMBRES 
;; -------------------------------------------------------------------

draw_sprite:
    call get_screen_position    ; Obtiene X y Y
    mov cl, SPRITE_HEIGHT
    .next_line:
        push cx
        lodsb                   
        xchg ax, dx             
        mov cl, SPRITE_WIDTH    ; cantidad de pixeles para el sprite
        .next_pixel:
            xor ax, ax          
            dec cx
            bt dx, cx           
            cmovc ax, bx        
            mov ah, al          
            mov [di+SCREEN_WIDTH], ax
            stosw                   
        jnz .next_pixel                               

        add di, SCREEN_WIDTH*2-SPRITE_WIDTH_PIXELS
        pop cx
    loop .next_line

    ret

get_screen_position:
    mov dx, ax      ; Guarda valores de Y/X 
    cbw             
    imul di, ax, SCREEN_WIDTH*2  
    mov al, dh      
    shl ax, 1      
    add di, ax      

    ret

;; DATA =================================
    db 40           ;PlayerX
    db 0            ;PlayerY
    db 0            ;Col
    db 0            ;Row

    db 0            ;Paint

sprite_bitmaps:
    db 00111100b  ; ..@@@@..
    db 01000000b  ; .@......
    db 00111100b  ; ..@@@@..
    db 00000010b  ; ......@.
    db 00000010b  ; ......@.
    db 01000000b  ; .@......
    db 00111100b  ; ..@@@@..
    db 00000000b  ; ........

    db 00111100b  ; ..@@@@..
    db 01000010b  ; .@....@.
    db 01000010b  ; .@....@.
    db 01111110b  ; .@@@@@@.
    db 01000010b  ; .@....@.
    db 01000010b  ; .@....@.
    db 00111100b  ; ..@@@@..
    db 00000000b  ; ........

    db 01000010b  ; .@....@.
    db 01100010b  ; .@@..@..
    db 01010010b  ; .@.@.@..
    db 01001010b  ; .@..@.@.
    db 01000110b  ; .@...@@.
    db 01000010b  ; .@....@.
    db 01000010b  ; .@....@.
    db 00000000b  ; ........

    db 00111100b  ; ..@@@@..
    db 00010000b  ; ....@...
    db 00010000b  ; ....@...
    db 00010000b  ; ....@...
    db 00010000b  ; ....@...
    db 00010000b  ; ....@...
    db 00010000b  ; ....@...
    db 00000000b  ; ........

    db 00111100b  ; ..@@@@..
    db 00010000b  ; ....@...
    db 00010000b  ; ....@...
    db 00010000b  ; ....@...
    db 00010000b  ; ....@...
    db 00010000b  ; ....@...
    db 00111100b  ; ..@@@@..
    db 00000000b  ; ........

    db 00111100b  ; ..@@@@..
    db 01000010b  ; .@....@.
    db 01000010b  ; .@....@.
    db 01111110b  ; .@@@@@@.
    db 01000010b  ; .@....@.
    db 01000010b  ; .@....@.
    db 00111100b  ; ..@@@@..
    db 00000000b  ; ........

    db 00111100b  ; ..@@@@..
    db 01000000b  ; .@......
    db 01000000b  ; .@......
    db 01001110b  ; .@..@@@.
    db 01000110b  ; .@...@@.
    db 01000010b  ; .@....@.
    db 00111100b  ; ..@@@@..
    db 00000000b  ; ........

    db 00111100b  ; ..@@@@..
    db 01000010b  ; .@....@.
    db 01000010b  ; .@....@.
    db 01000010b  ; .@....@.
    db 01000010b  ; .@....@.
    db 01000010b  ; .@....@.
    db 00111100b  ; ..@@@@..
    db 00000000b  ; ........

    db 00111100b  ; ..@@@@..
    db 01000000b  ; .@......
    db 01000000b  ; .@......
    db 01000000b  ; .@......
    db 01000000b  ; .@......
    db 01000000b  ; .@......
    db 00111100b  ; ..@@@@..
    db 00000000b  ; ........

    db 00111100b  ; ..@@@@..
    db 01000000b  ; .@......
    db 01000000b  ; .@......
    db 01111100b  ; .@@@@@..
    db 01001000b  ; .@..@...
    db 01000100b  ; .@...@..
    db 01000010b  ; .@....@.
    db 00000000b  ; ........

    db 00111100b  ; ..@@@@..
    db 00010000b  ; ....@...
    db 00010000b  ; ....@...
    db 00010000b  ; ....@...
    db 00010000b  ; ....@...
    db 00010000b  ; ....@...
    db 00111100b  ; ..@@@@..
    db 00000000b  ; ........

    db 00111100b  ; ..@@@@..
    db 01000000b  ; .@......
    db 00111100b  ; ..@@@@..
    db 00000010b  ; ......@.
    db 00000010b  ; ......@.
    db 01000000b  ; .@......
    db 00111100b  ; ..@@@@..
    db 00000000b  ; ........