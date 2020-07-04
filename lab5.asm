.386
data    SEGMENT 
    msg     db  10 dup('0')
    col     dw  0
    row     dw  0
    pos     dw  0
    posc    dw  0
    len     dw  0
    srow    dw  0
    scol    dw  0
    lenw    dw  22
    highw   dw  6
data    ENDS

code    SEGMENT     USE16
    ASSUME  cs:code,ds:data

    drawMark:
    mov     pos,ax
    mov     si,pos
    mov     ax,202ah
    mov     es:[si],ax
    ret

    convertNum:
    mov     bx, 10 ;делитель
    mov     cx, 0   
    @d:
    xor     dx,dx
    div     bx     ; ax / 10
    push dx    ; в стек остаток
    inc     cx     ; подсчитываем число разрядов (в стеке)
    inc     len
    cmp     ax, 0  ; выход если разряды закончились
    jnz     @d

    ;вывод цифер

    mov     di,0
    L1:
    inc     di
    mov     msg[di],02h
    cmp     di,10
    jle     L1



    mov     di,0

    @b:
    pop     dx      ; достали из стека   
    add     dl, '0' ; превращаем в ASCII символ цифры
    mov     msg[di],dl
    inc     di
    mov     msg[di],20h
    inc     di 
    loop    @b

    mov	si,offset msg		
	mov	di,pos

	mov	cx,len
	cld
	rep movsw			;виведення на екран

    mov     len,0
    ret

    prmaus 	proc 	far
    push    ax
    push    ds
    pusha
    push    0b800h
    pop     es
    push    data
    pop     ds
                                           
    test    bx,10b                                   
    jnz     R                                               
    jz      E
    R:

    mov     col,cx
    mov     row,dx

    mov     dx,0
    mov     ax,col
    mov     bx,8
    idiv    bx

    mov     col,ax
    
    mov     dx,0
    mov     ax,row
    mov     bx,8
    idiv    bx  

    mov     row,ax  
    mov     di,160
    imul    di,srow
    add     di,scol
    mov     pos,di
    mov     cx,lenw
    mov     ax,2020h
    mov     dx,0

    W:
    mov     bx,di
    rep stosw
    mov     cx,lenw
    add     di,160
    sub     di,lenw
    sub     di,lenw
    inc     dx
    cmp     dx,highw
    jl      W

    add     pos,166
    mov     ax,pos
    mov     posc,ax
    call    drawMark
    add     si,2
    mov     ax,2058h
    mov     es:[si],ax
    add     si,2
    mov     ax,202dh
    mov     es:[si],ax
    add     si,2
    mov     pos,si

    mov     ax, col
    call    convertNum
    mov     len,0

    

    mov     ax,posc
    add     ax,18
    mov     pos,ax
    mov     si,pos
    mov     ax,2059h
    mov     es:[si],ax
    add     si,2
    mov     ax,202dh
    mov     es:[si],ax
    add     si,2

    mov     pos,si
    mov     ax,row
    call    convertNum

    add     posc,160
    mov     ax,posc
    call    drawMark
    add     si,2
    mov     ax,204ch
    mov     es:[si],ax
    add     si,2
    mov     ax,2065h
    mov     es:[si],ax
    add     si,2
    mov     ax,206eh
    mov     es:[si],ax
    add     si,2
    mov     ax,2067h
    mov     es:[si],ax
    add     si,2
    mov     ax,2074h
    mov     es:[si],ax
    add     si,2
    mov     ax,2068h
    mov     es:[si],ax
    add     si,2
    mov     ax,202dh
    mov     es:[si],ax
    mov     pos,si
    add     pos,2
    mov     ax,lenw
    call    convertNum

    add     posc,160
    mov     ax,posc
    call    drawMark

    add     pos,2
    add     si,2
    mov     ax,2048h
    mov     es:[si],ax
    add     si,2
    mov     ax,2069h
    mov     es:[si],ax
    add     si,2
    mov     ax,2067h
    mov     es:[si],ax
    add     si,2
    mov     ax,2068h
    mov     es:[si],ax
    add     si,2
    mov     ax,202dh
    mov     es:[si],ax

    mov     pos,si
    add     pos,2
    mov     ax,highw
    call    convertNum
    mov     cx,0
    mov     dx,0
    mov     col,cx
    mov     row,dx

    mov     len,0

    E:
    popa
    pop     ds
    pop     ax
    retf
    prmaus	endp


begin:

    mov     ax,03h
    int     10h

    push    0b800h
    pop     es

    mov     ax,00h
    int     33h
    test    ax,ax
    jz      exit

    mov     ax,0Ch
    push    cs
    pop     es
    mov     cx,1000b
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
