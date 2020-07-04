.386
data    SEGMENT
    dvalue  dw  0241h
    tmp     dw  0
    row     dw  0
    col     dw  0
    cond    db  0
    pos     dw  0

data    ENDS

code    SEGMENT     USE16
        ASSUME  cs:code,ds:data

    prmaus 	proc 	far
    push    ax
    pusha
    push    0b800h
    pop     es

    test    bx,1b                                  
    jnz     L                                               
    test    bx,10b                                   
    jnz     R                                                                                        
    jz      E
    L:

    mov     row,dx
    mov     col,cx

    xor     di,di
    mov     di,pos
    mov     ax,0f20h
    mov     es:[di],ax


    mov     cond,2

    jmp     E

    R:
        mov cond,1
    E:
    popa
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

    
    mov     cx,1010b
    mov     dx,0

   
    mov     dx, offset prmaus
    int     33h

    mov     ax,01h
    int     33h

    L2:

    cmp     cond,2
    jne     draw

    push    0b800h
    pop     es

    mov     dx,row
    mov     tmp,dx
    mov     cond,0
    mov     dx,0
    mov     ax,col
    mov     bx,8
    div     bx

    mov     cx,ax

    mov     dx,0
    mov     ax,tmp
    mov     bx,8
    div     bx

    mov     dx,ax  

    imul    dx,160
    imul    cx,2
    add     dx,cx
    mov     di,dx
    mov     ax,0241h
    mov     es:[di],ax

    mov     pos,di

    

    draw:  

    cmp     cond,1
    je      xt
    jmp     L2
    
    xt:
    mov     ax,0Ch
    mov     cx,0
    int     33h
    exit:
	mov	ax,4c00h
	int	21h

code    ENDS
        END     begin