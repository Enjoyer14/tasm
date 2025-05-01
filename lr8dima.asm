.486
JUMPS
model use16 small
.stack 100h
clrScr macro
		push ax
		push bx
		push cx
		push dx

		mov ax, 0600h
		mov bh, 0Fh
		mov cx, 0000
		mov dx, 184Fh
		int 10h
	
		pop dx
		pop cx
		pop bx
		pop ax
	endm clrScr 
delay macro time 
local ext,iter 
;макрос задержки 
;На входе - значение переменной задержки (в мкс) 
 push cx 
 mov cx,time 
ext: 
 push cx 
;в cx одна мкс[FA1],это значение можно 
;поменять в зависимости от производительности процессора 
 mov cx,5000 
iter: 
 loop iter 
 pop cx 
 loop ext 
 pop cx 
endm ;конец макроса 
.data
chastota dw 70
tonelow dw 2651  ;нижняя граница звучания 450 Гц 
cnt db 0   ;счѐтчик для выхода из программы 
temp dw ?   ;верхняя граница звучания 
old_off8 dw 0  ;для хранения старых значений вектора 
old_seg8 dw 0  ;сегмент и смещение 
old_09h dw 0
time_1ch dw 0  ;переменная для пересчета 
b dw 175 ;
k1 dw 1 ;ставим коэффициент K сжатия -
;растяжения по оси Ох
x dw ?
middle dw ?
pi dw 180 ;задаѐм число пи в радианах
y dw ?
delay_factor dw 5d
exit_flag db 0
trigger_flag db -1
down_flag db 0
axis dw ? ;задаѐм ось
k2 dw 40 ;ставим коэффициент K сжатия-
two dw 2
x7 dq 7.0
x07 dq 0.7
x174 dq 174.0
x4 dq 4.0
d07 dq -0.7
x5 dq 5.0
x13 dq 0.33
buff1 dq ?
buff2 dq ?
.code     ;начало сегмента кода 
off_1ch equ 1ch*4  ;смещение вектора 1ch в ТВП 
off_0ffh equ 0ffh*4  ;смещение вектора ffh в ТВП 
NEW_1CH proc  ;новый обработчик прерывания от таймера 
 push ax 
 push bx 
 push es 
 push ds 
 push dx
 push cx
;настройка ds на cs 
 ;push cs 
 ;pop ds 
;запись в es адреса начала видеопамяти - B800:0000 
 ;mov ax,0b800h 
 ;mov es,ax 
 ;mov ah, 0bh
 ;int 21h
 ;cmp al, 0
 



 ;mov dl, al
 ;add dl, 30
 ;mov ah, 06h
 ;int 21h

 mov al, 10110110b ;управляющее слово: канал 2, режим 3
    out 43h, al

    mov ax, [chastota]
    out 42h, al
    mov al, ah        
    out 42h, al 
    ;включаем динамик
    in al, 61h ; читаем порт управления
    or al, 00000011b ;устанавливаем биты для включения канала 2
    out 61h, al   

   
    mov ax, [chastota]
    add ax, 25       ; Уменьшаем частоту на 100
    cmp ax, 3000       ; Проверяем границу (не ниже 300)
    jb freq_ok
    mov ax, 300      ; Сбросить на максимальную частоту
freq_ok:
    mov [chastota], ax      ; Сохраняем новую частоту
 mov ah, 0bh
 int 21h
  cmp al, 0
 je continue
 jne change_delay
 change_delay:
    mov ah, 07h
    int 21h
    ;mov dl, al
    ;mov ah, 06h
    ;int 21h
    sub al, '0'
    cmp al, 0
    je exit
    cmp al, 1
    je trigger
    
   ; mov bl, 29d
   ; mul bl
   ; mov delay_factor, ax
    jmp continue
 exit:
    inc exit_flag
    jmp continue
trigger:
	neg trigger_flag
	jmp continue
 continue:

;восстановление используемых регистров: 
pop cx
pop dx
 pop ds 
 pop es 
 pop bx 
 pop ax 

 iret    ;возврат из прерывания 
NEW_1CH endp   ;конец обработчика 
 



Start:
 mov ax, @data
 mov ds, ax
 xor ax, ax
 cli  ;запрет аппаратных прерываний на время 
;замены векторов  [FA2] прерываний 
;замена старого вектора 1ch на адрес new_1ch 
;настройка es на начало таблицы векторов 
;прерываний - в реальном режиме: 
 mov ax,0 
 mov es,ax 
;сохранить старый вектор 
 mov ax,es:[off_1ch] ;смещение старого вектора 1ch в ax 
 mov old_off8,ax  ;сохранение смещения в old_off8 
 mov ax,es:[off_1ch+2] ;сегмент старого вектора 1ch в ax 
 mov old_seg8,ax  ;сохранение сегмента в old_seg8 
; mov ax, es:[off_09h]
 
;записать новый вектор в таблицу векторов прерываний 
mov ax,offset new_1ch ;смещение нового обработчика в ax 
 mov es:off_1ch,ax 
 push cs 
 pop ax ;  настройка ax на cs 
 mov es:off_1ch+2,ax ;запись сегмента 
;нициализировать вектор пользовательского прерывания 0ffh 
 ;mov ax,offset new_0ffh 
 ;mov es:off_0ffh,ax ;прерывание 0ffh 
 ;push cs 
 ;pop ax 
 ;mov es:off_0ffh+2,ax 
 
 sti   ;разрешение аппаратных прерываний 
 ;mov al, 10h
 ;int 10h
 ;int 0ffh
 xor ax, ax
 mov al, 10h
 int 10h
 ;Фон
 mov ax, 0600h ; ah = 06 - прокрутка вверх
 mov bh, 0 ;белый
 mov cx, 0000b ; ah = 00 - строка верхнуго левого угла
 mov dx, 184Fh
 int 10h
 mov ah, 0Ch ;установка графической точки
 mov al, 15 ;загружаем зелѐный цвет для
;вертикальной линии
 mov bh, 0h ;установка номера видеостраницы
 mov cx, 400 ;количество итераций сверху вниз
;для вертикальной линии
@metka1: ;прорисовка вертикальной линии
 push cx
 mov axis, cx ;в начало оси записываем 0
 mov dx, axis ;установка курсора
 mov cx, 319 ;вывод вертикальной оси, со
;сдвигом на 319 вправо
 int 10h
  pop cx ;400 итераций, ставит в 400
;колонку, и идѐт до 0
 loop @metka1
 mov ah, 0ch ;установка графической точки
 mov al, 15 ;зелѐный цвет
 mov cx, 639 ;639 итераций, ставит в 639
;колонку, и идѐт до 0
 mov bh, 0h ;установка номера видеостраницы
 mov dx, 174 ;ставит в 174 строку
@metka2: ;цикл вывода горизонтальной оси
 int 10h ;вывод горизонтальной линии
 loop @metka2
 mov cx, 639 ;начинаем рассчитывать функцию
 mov ax, cx
 xor dx, dx
	mov cx, 2
	cwd
	div cx

mov middle, ax
;int 0ffh
mov cx, 639
;int 0ffh
@metka3: ;отвечает за вывод графа
	

 mov x, cx ;помещаем в x 639
 cmp exit_flag, 0
 jne exit_program
 cmp trigger_flag, 1
 je stop
 mov ax, middle
 sub x, ax
 mov ax, x
 finit
 cmp ax, 0
 jg positive
 jmp negative
 negative:
 fild x
 fsin
 fld st(0)
 fmul
 fstp buff1

 fild x
 fld st(0)
 fmul
 fld x5
 fmul
 fld1
 fadd
 fld buff1
 fsub
 fsqrt
 frndint
 fistp y
 jmp draw

 positive:
	fild x
	fld x7
	fadd
	fld st(0)
	fmul
	fstp buff1
	fild x
	fld x07
	fmul

	;==========================ЭКСПОНЕНТА РАБОТАЕТ АААААААААААААААА===============
	fldl2e; log2e
	fmul; (x-a)*log2e
	fld st(0)

	frndint; st(0) - целое, st(1) - дробное
	fsub st(1),st(0)
	fld1
	fscale
	fstp buff2
	
	fxch st(1)
	
	f2xm1
	fld1
	fadd
	fld buff2
	fmul
	;fld1
	;fadd
	fstp buff2; buff3 = e^(x-a)
	;================ЭКСПОНЕНТА РАБОТАЕТ АААААААААААААААААААААААААААА====================
	fld x4
	fadd

	fld x13
	fld st(1)
	fyl2x
	fld st(0)

	frndint; st(0) - целое, st(1) - дробное
	fsub st(1),st(0)
	fld1
	fscale
	fstp buff2
	
	fxch st(1)
	
	f2xm1
	fld1
	fadd
	fld buff2
	fmul
	;fld1
	;fadd
	fstp buff2; buff3 = e^(x-a)
	fld buff1
	fdivr
	frndint
	fistp y
	mov ax, y
 mov bx, k2
 xor dx, dx
 cwd
 idiv bx
 mov y, ax
	jmp draw

	draw:
	
 ;mov y, ax
 ;fld y
 ;fld x174
 ;fsub
 
 sub y, 174
 neg y
 
 ;fchs
 ;fstp y
 
 
 mov ah, 0Ch ;установка графической точки
 mov bh, 0h ;ставим в нулевое окно
 mov dx, y ;ставим в y строку
 cmp x, 0
 jge BLUESCREEN
 mov al, 0Bh
 jmp someStrangeMetka
 BLUESCREEN:
 mov al, 0Ah ;цвет черный
 someStrangeMetka:
 int 10h
 delay delay_factor
 loop @metka3 ;уменьшаем сx
 ;jmp exit_program
 stop:
 ;call NEW_0FFH
	stopLoop:
	cmp exit_flag, 0
	jne exit_program
	cmp trigger_flag, 1
	
	je stopLoop
	
	jmp @metka3
;mov ah, 8h ;выход из программы при нажатии любой
;клавиши
; int 21h
exit_program:
  cli    ;запрет аппаратных прерываний 
 xor ax,ax   
mov es,ax   
mov ax,old_off8  
mov es:off_1ch,ax  
mov ax,old_seg8  
mov es:off_1ch+2,ax 
sti  
  in al, 61h    
    and al, 0FCh
    out 61h, al
 mov ax,4c00h 
 int 21h 
end Start
end