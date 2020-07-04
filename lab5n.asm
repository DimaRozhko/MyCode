.386
data    SEGMENT  
    row     dw  0
    ASCII   dw  0f41h  
    flagl   db  1
    flagr   db  1
data    ENDS

code    SEGMENT     USE16
    ASSUME  cs:code,ds:data
    prmaus 	proc 	far

    push    ax
    push    ds
    push    0b800h
    pop     es
    

    mov     ax,data
    mov     ds,ax
        
    xor     di,di

    mov     bx,cx

    mov     si,0

    mov     bx,0
    mov     ax, 0003h                                       ;
    int     33h                                             ;Получаем информацию о мышке
    test    bx, 00000001b                                   ;Проверяем, если нажата Левая Кнопка Мыши, то на метку L
    jnz     L                                               ;
    test    bx, 00000010b                                   ;Проверяем, если нажата Правая Кнопка Мыши, то на метку R
    jnz     R                                               ;
   

    L:
    mov     byte ptr row,0

    cmp     flagl,1
    jne     L4    
    mov     ASCII,0141h  
    jmp     L5
    L4:
    mov     ASCII,0f20h
    L5:

    cmp     flagl,0
    jne     L1
    inc     flagl
    jmp     L3
    L1:
    dec     flagl
    L3:
    jmp     L2


    R:

    mov     byte ptr row,1
    cmp     flagr,1
    jne     R4
    mov     ASCII,0244h
    jmp     R5
    R4:
    mov     ASCII,0f20h
    R5:
    cmp     flagr,0
    jne     R1
    inc     flagr
    jmp     R2
    R1:
    dec     flagr
    R2:

    L2:

    cmp     flagl,1
    jne     F1
    cmp     flagr,1
    jne     F2
    jmp     F3
    F1:
    F2:
    cmp     flagl,0
    jne     F4
    cmp     flagr,0
    jne     F5
    jmp     F6
    F4:
    F5:
    F6:
    F3:
    mov     di,160
    imul    di,word ptr row
    mov     cx,80
    mov     ax,word ptr ASCII

    W:
    mov     bx,di
    rep stosw
    mov     cx,80
    add     di,160
    cmp     di,4096
    jle     W

    mov     si,0
    mov     cx,bx
    pop     ds
    pop     ax
    retf
    prmaus	endp


begin:

    mov     ax,03h
    int     10h

    push    0b800h
    pop     es

    mov     di,0
    mov     cx,80

    Wb:
    mov     ax,0141h
    rep stosw
    mov     cx,80
    mov     ax,0244h
    rep stosw
    mov     cx,80
    cmp     di,4096
    jle     Wb

    mov     ax,00h
    int     33h
    test    ax,ax
    jz      exit

    mov     ax,0Ch
    push    cs
    pop     es
    mov     cx,1010b
    mov     dx,0

    mov     dx, offset prmaus
    int     33h

    mov     ax,01h
    int     33h

    mov     ah,01h
    int     21h

    mov     ax,0Ch
    mov     cx,0
    int     33h

    exit:
	mov	ax,4c00h
	int	21h

code    ENDS
        end     begin
