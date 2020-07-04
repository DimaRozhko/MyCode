.386
; y=cos^2(x)
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

data  segment  use16
; вычисление масштабных коефициентов
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
data  ends

code  segment  use16
  assume  cs:code, ds:data

  
graph  proc
  push  bp
  mov  bp, sp
  fld  min_x  ; записть  в вершину стека  min_x
  draw_graph:
  fld  st(0)  ; записть  в вершину стека  st(0)
  fld  st(0)  ; записть  в вершину стека  st(0)
  call  get_x
  fcos        ; применить косенус к вершине стека
  fmul  st(0),st(0) ;умножения вершины стека на вершину стека
  call  get_y
  push  4    ; значения цвета
  call  draw_point
  add  sp, 2
  fld  step   ; записть  в вершину стека  step
  faddp  st(1), st(0)  ; сумирования целого числа с  выталкиваниям из стека в последствии
  fcom  max_x ; сравнение чисел с плавающей точкой st0 и max_x
  fstsw  ax   ; сохранения текущего состояния sr в ax с дальнейшей
  sahf        ; запись значений флагов из ah
  jna  draw_graph
  ffree  st(0) ; освобождения регистра данных
  pop  bp
  ret
graph  endp

create_axis  proc
  fldz        ; записть  в вершину стека 0
  call  get_y
  mov  crt_x, 0
  mov  cx, x_result_
  axis_x:
  push  15
  call  draw_point
  add  sp, 2
  inc  crt_x
  loop  axis_x
  fld  max_x ; записть  в вершину стека max_x
  fsub  min_x ; отнимания от вершины стека min_x
  frndint ;округление
  fistp  tmp ;  сохранения целого значения  с извлечениям из стека
  mov  cx, tmp
  fld  min_x  ; записть  в вершину стека  min_x
  frndint ;округление
  dec  crt_y
  line_x:
  fld  st(0) ; записть  в вершину стека  st(0)
  call  get_x
  push  15
  call  draw_point
  add  sp, 2
  fld1      ; записть  в вершину стека 1
  faddp  st(1), st(0)  ; сумирования целого числа с  выталкиваниям из стека в последствии
  loop  line_x
  ffree  st(0) ; освобождения регистра данных
  fldz        ; записть  в вершину стека 0
  call  get_x
  mov  crt_y, 0
  mov  cx, y_result_
  axis_y:
  push  15
  call  draw_point
  add  sp, 2
  inc  crt_y
  loop  axis_y
  fld  max_y  ; записать  в вершину стека max_y
  fsub  min_y ; отнимания от вершины стека min_y
  frndint ;округление
  fistp  tmp ;  сохранения целого значения  с извлечениям из стека
  mov  cx, tmp
  fld  min_y  ; записать  в вершину стека min_y
  frndint ;округление
  dec  crt_x
line_y:
  fst  st(1)
  call  get_y
  push  15
  call  draw_point
  add  sp, 2  
  fld1
  faddp  st(1), st(0)  ; сумирования целого числа с  выталкиваниям из стека в последствии
  fcom  max_y   ; сравнения st0 и max_y
  loop  line_y
  ffree  st(0) ; освобождения регистра данных
  ret
create_axis  endp

draw_point  proc
  push  bp
  mov  bp, sp
  mov  ax, 0A000h ; установка начала видеопамяти вывода
  mov  es, ax
  mov  si, crt_y
  mov  di, crt_x
  cmp  si, y_result_
  jae  brake
  cmp  di, x_result_	
  jae  brake
  mov  ax, x_result_			; вычисления байта в графической видеопамяти
  mul  si
  add  ax, di
  mov  bx, ax
  mov  dx, [bp+4]			 
  mov  byte ptr es:[bx], dl ; вывод точки на екран
  brake:
  pop  bp
  ret
draw_point  endp

get_x  proc
  fsub  min_x ;отнимания от st0 min_x
  fdiv  scale_x ; деления st0 на scale_x 
  frndint ;округление
  fistp  crt_x		; сохранения в вершине стека
  ret
get_x  endp

get_y  proc
  fsub  min_y ;отнимания от st0 min_y
  fdiv  scale_y ; деления st0 на scale_y
  frndint ;округление
  fistp  crt_y			; сохранения в вершине стека
  mov  ax, y_result
  sub  ax, crt_y
  mov  crt_y, ax
  ret
get_y  endp


begin:
  mov  ax, data
  mov  ds, ax
  mov  ax, 13h		;инициализация графического режима
  int  10h			; выделения одного сегмента видеоконтроллера
  finit				; инициализация сопроцесора
  scale  x			; вычисление функций
  scale  y
  call  create_axis; вывод осей на екран
  call  graph     ;вывод графика на екран
  mov  ah, 8
  int  21h
  mov  ax, 3
  int  10h
  mov  ax, 4C00h
  int  21h

code  ends

  end  begin