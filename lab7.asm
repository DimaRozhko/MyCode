.386
;Варіант 14 (реалізувати грфік функції y=sin(x)/x)
x_result_  EQU  320
y_result_  EQU  200
;макровизначення для обчислення масштабу
scale  MACRO  p1
;обчислення масштабного коефіцієнта по осі pl
  fld     max_&p1		    ; st0=max_&p1; top=7
  fsub    min_&p1		    ; st0=max_&p1 - min_&p1; ;top=7
  fild    p1&_result		; st0=max_crt_&p1, 
;                         st1=max_&p1-min_&p1; top=6
  fdivp   st(1), st(0)	; 1-й крок st1=st1/st0
;                         2-й крок st1 стає st0; top=7
;                         і містить масштаб
  fstp    scale_&p1
endm

data  SEGMENT  USE16
;обчислення масштабних коефіцієнтів 
  min_x     dq    -6.283
  max_x     dq    6.283
  min_y     dq    -3.0
  max_y     dq    3.0
  x_result  dw    x_result_
  y_result  dw    y_result_
  crt_x     dw    ?
  crt_y     dw    ?
  scale_x   dq    ?
  scale_y   dq    ?
  step      dq    0.001
  tmp       dw    ?
data  ends

code  SEGMENT  USE16
  ASSUME  cs:code, ds:data

  create_x  proc          ; <процедура відшування значення x>
  fsub      min_x         ; віднімання війсних чисел
  fdiv      scale_x       ; ділення війсних чисел
  frndint			            ; округлення
  fistp     crt_x		      ; збереження вершини стеку
  ret
  create_x  endp

  create_y  proc          ; <процедура відшування значення y>
  fsub      min_y         ; віднімання війсних чисел
  fdiv      scale_y       ; ділення війсних чисел
  frndint                 ; округлення
  fistp     crt_y         ; збереження вершини стеку			
  mov       ax, y_result  ; запис в ax результату
  sub       ax, crt_y     ; віднімання від ax значення що зберігалося у вершині стека
  mov       crt_y, ax
  ret
  create_y  endp

  schedule  proc          ; <процедура створення графіка y = sin(x)/x>
  push      bp          
  mov       bp, sp
  fld       min_x         ; завантаження до верхфівки стека min_x
continue_draw:  
  fld       st(0)         ; завантаження до верхфівки стека st(0)
  fld       st(0)
  call      create_x      ; встановлення позиції x
  fst       st(1)         ; зберегти верхівку стека в st(1)
  fsin                    ; взяття синуса з st(0) і утворено умовно названого значення st'(0) 
  ;                         (пересаписана вершина стека, перетворена в синус), 
  fdiv      st(0),st(1)   ; ділення верхівки стека st'(0) (перетворене sin(st(0))) на st(1) 
  ;                         (перетворене з вихідного st(0)). Іншими словами кінцева реалізація sin(x)/x
  call      create_y      ; встановлення позиції y
  push      10            ; задання точкам для виводу салатового кольору 
  call      markup        ; вивід точки відповідно до координат
  add       sp, 2
  fld       step          ; завантаження до верхфівки стека step
  
  faddp     st(1), st(0)  ; додавання цілого числа з подальшим виштовхуванням із стека
  fcom      max_x         ; порівняння чисел з плаваючою тчкою st(0) з max_x
  fstsw     ax            ; збереження поточного стану регістра sr у приймач ax з подальшим переходом
  sahf                    ; завантаження в значення флагів SF, ZF, AF, PF и CF значеннями з регистра ah, 
  ;                         з бітів 7, 6, 4, 2 и 0 відповідно
  jna       continue_draw
  ffree     st(0)         ; звільнення регістра даних
  pop       bp
  ret
schedule  endp

axis      proc            ; <процедура створення осей>
  fldz                    ; запис у верхівку стека 0
  call    create_x        ; встановлення позиції x
  mov     crt_y, 0
  mov     cx, y_result_
  point_y:
  push    15
  call    markup          ; вивід точки відповідно до координат
  add     sp, 2
  inc     crt_y
  loop    point_y
  fld     max_y           ; завантаження до верхфівки стека max_y
  fsub    min_y           ; віднімання від верхфівки стека min_y
  frndint                 ; округлення значень в st до цілого відповідно 
  ;                         до установки поля режима округлення RC в керуючому слові FPU
  fistp   tmp             ; збереженням цілого значення з витягуванням із стека
  mov     cx, tmp
  fld     min_y           ; завантаження до верхфівки стека min_y
  frndint                 ; округлення значень в st до цілого відповідно 
  ;                         до установки поля режима округлення RC в керуючому слові FPU
  dec     crt_x
  axis_y:
  fst     st(1)
  call    create_y        ; встановлення позиції y
  push    2
  call    markup
  add     sp, 2  
  fld1                    ; запис у верхівку стека 1
  faddp   st(1), st(0)    ; додавання цілого числа з подальшим виштовхуванням із стека
  fcom    max_y           ; порівняння чисел з плаваючою тчкою st(0) з max_y
  loop    axis_y
  ffree   st(0)           ; звільнення регістра даних
  fldz                    ; запис у верхівку стека 0
  call    create_y        ; встановлення позиції y
  mov     crt_x, 0
  mov     cx, x_result_
  point_x:
  push    15
  call    markup          ; вивід точки відповідно до координат
  add     sp, 2
  inc     crt_x
  loop    point_x
  fld     max_x           ; завантаження до верхфівки стека max_x
  fsub    min_x           ; віднімання від верхфівки стека min_x
  frndint                 ; округлення значень в st до цілого відповідно 
  ;                         до установки поля режима округлення RC в керуючому слові FPU
  fistp   tmp             ; збереженням цілого значення з витягуванням із стека
  mov     cx, tmp
  fld     min_x           ; завантаження до верхфівки стека min_x
  frndint                 ; округлення значень в st до цілого відповідно 
  ;                         до установки поля режима округлення RC в керуючому слові FPU
  dec     crt_y
  axis_x:
  fld     st(0)           ; завантаження до верхфівки стека st(0)
  call    create_x        ; встановлення позиції x
  push    2
  call    markup          ; вивід точки відповідно до координат 
  add     sp, 2
  fld1                    ; запис у верхівку стека 1
  faddp   st(1), st(0)    ; додавання цілого числа з подальшим виштовхуванням із стека
  loop    axis_x
  ffree   st(0)           ; звільнення регістра даних
  ret
axis      endp

markup    proc
  push    bp
  mov     bp, sp
  mov     ax, 0A000h      ; встановлення початку відеопам'яті виводу
  mov     es, ax
  mov     si, crt_y
  mov     di, crt_x
  cmp     si, y_result_
  jae     end1
  cmp     di, x_result_	
  jae     end1
  mov     ax, x_result_	  ; обчислення байта у графічній відеопам'яті
  mul     si
  add     ax, di
  mov     bx, ax          ; завершення обрахунку позиції виводу
  mov     dx, [bp+4]		  ; виведення точки на екран
  mov     byte ptr es:[bx], dl
end1:
  pop     bp
  ret
markup    endp


begin:
  mov     ax, data
  mov     ds, ax
  mov     ax, 13h		;задання графічного режиму
  int     10h			;відводиться один сегмент для відеоконтроллера
  finit				; ініціалізація співпроцесора
  scale   x			; обчислення функцій
  scale   y
  call    axis
  call    schedule
  mov     ah, 8
  int     21h
  mov     ax, 3
  int     10h
  mov     ax, 4C00h
  int     21h


code      ends
  end     begin