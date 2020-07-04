.486
;макровизначення для обчислення масштабу
; y=cos(sin(x))
scale  macro  p1
;обчислення масштабного коефіцієнта по осі pl
  fld  max_&p1		; st0=max_&p1; top=7
  fsub  min_&p1		; st0=max_&p1 - min_&p1; ;top=7
  fild  p1&_result		; st0=max_crt_&p1, 
; st1=max_&p1-min_&p1; top=6
fdivp  st(1), st(0)	; 1-й крок st1=st1/st0
  ; 2-й крок st1 стає st0; top=7
; і містить масштаб
  fstp  scale_&p1
endm

x_result_  equ  320
y_result_  equ  200

_data  segment  use16
;обчислення масштабних коефіцієнтів 
  min_x  dq  -6.283
  max_x  dq  6.283
  x_result  dw  x_result_
  crt_x  dw  ?
  scale_x  dq  ?

  min_y  dq  -3.0
  max_y  dq  3.0
  y_result  dw  y_result_
  crt_y  dw  ?
  scale_y  dq  ?
  step  dq  0.001
  tmp  dw  ?
_data  ends

_code  segment  use16
  assume  cs:_code, ds:_data

get_y  proc
  fsub  min_y   ;віднімання
  fdiv  scale_y ;ділення
  frndint       ;округлення
  fistp  crt_y		;збереження вершини стеку	
  mov  ax, y_result;
  sub  ax, crt_y
  mov  crt_y, ax
  ret
get_y  endp

get_x  proc
  fsub  min_x       ;відніманя
  fdiv  scale_x     ;ділення
  frndint           ;округлення			
  fistp  crt_x		; збереження вершини стеку
  ret
get_x  endp
  
graph  proc
  push  bp
  mov  bp, sp
  fld  min_x        ;завантаження змінної в стек
draw:
  fld  st(0)        ;завантаження st(0) в стек
  fld  st(0)        ;завантаження st(0) в стек
  call  get_x
  fst st(2)         ;зберегти верхівку стека
  fsin              ;використання синуса
  fcos              ;використання косинуса
  call  get_y
  push  14          ;визначення кольору
  call  draw_point  ;виведення точки графіка
  add  sp, 2
  fld  step     ;завантаження змінної в стек
  faddp  st(1), st(0);додавання цілого числа з витісненням із стека  st(1), st(0)
  fcom  max_x   ;порівняння
  fstsw  ax;    збереження SR в AX
  sahf          ;заповнення флагів
  jna  draw
  ffree  st(0)  ;звільнення регістра даних
  pop  bp
  ret
graph  endp



draw_point  proc
  push  bp
  mov  bp, sp
  mov  ax, 0A000h   ;визначення місця у відеопам'яті
  mov  es, ax
  mov  si, crt_y
  mov  di, crt_x
  cmp  si, y_result_
  jae  end1
  cmp  di, x_result_	
  jae  end1
  mov  ax, x_result_			; обчислення байта у графічній відеопам'яті
  mul  si
  add  ax, di
  mov  bx, ax
  mov  dx, [bp+4]			;встановлення позиції 
  mov  byte ptr es:[bx], dl ; вивід точки на екран
end1:
  pop  bp
  ret
draw_point  endp

draw_axis  proc
  fldz          ;у верх стека 0 
  call  get_y
  mov  crt_x, 0
  mov  cx, x_result_
axis_x:
  push  15
  call  draw_point
  add  sp, 2
  inc  crt_x
  loop  axis_x
  fld  max_x    ;завантаження max_x в стек
  fsub  min_x   ;віднімання min_x в стек
  frndint       ;округлення
  fistp  tmp    ; збереження вершини стеку
  mov  cx, tmp
  fld  min_x
  frndint       ;округлення
  dec  crt_y
line_x:
  fld  st(0)    ;завантаження st(0) в стек
  call  get_x
  push  15      ;встановлення кольору
  call  draw_point
  add  sp, 2
  fld1          ;занесення в стек 1
  faddp  st(1), st(0);додавання цілого числа з витісненням із стека  st(1), st(0)
  loop  line_x
  ffree  st(0)  ;звільнення регістра даних
  fldz          ;у верх стека 0
  call  get_x
  mov  crt_y, 0
  mov  cx, y_result_
axis_y:
  push  15      ;встановлення кольору
  call  draw_point
  add  sp, 2
  inc  crt_y
  loop  axis_y
  fld  max_y    ;завантаження max_y в стек
  fsub  min_y   ;віднімання min_y в стек
  frndint       ;округлення
  fistp  tmp    ; збереження вершини стеку
  mov  cx, tmp
  fld  min_y    ;завантаження min_y в стек
  frndint       ;округлення
  dec  crt_x
line_y:
  fst  st(1)
  call  get_y
  push  15
  call  draw_point
  add  sp, 2  
  fld1          ;занесення в стек 1
  faddp  st(1), st(0);додавання цілого числа з витісненням із стека  st(1), st(0)
  fcom  max_y   ;порівняння
  loop  line_y
  ffree  st(0)  ;звільнення регістра даних
  ret
draw_axis  endp

begin:
  mov  ax, _data
  mov  ds, ax
  mov  ax, 13h		;задання графічного режиму
  int  10h			;відводиться один сегмент для відеоконтроллера
  finit				; ініціалізація співпроцесора
  scale  x			; обчислення функцій
  scale  y
  call  draw_axis   ;виведення осей
  call  graph       ;виведення графіків
  mov  ah, 8
  int  21h
  mov  ax, 3
  int  10h
  mov  ax, 4C00h
  int  21h
_code  ends

  end  begin