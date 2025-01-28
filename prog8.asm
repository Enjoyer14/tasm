.486
model use16 small
.stack 100h
.data
n_5 dw -5
n10 dw 1
n120 dw 213
n240 dw 213
n2 dw 2
n6 dw 6
n3 dw 3
b dw 330 ;
k1 dw 10 ;ставим коэффициент K сжатия -
;растяжения по оси Ох
x dw ?
pi dw 180 ;задаѐм число пи в радианах
y dw ?
axis dw ? ;задаѐм ось
k2 dw 50 ;ставим коэффициент K сжатия-
;растяжения по оси Оy
two dw 2
music1 dw 3322, 2217, 2637, 2349, 3322, 2217, 3322, 3322, 3322, 2217, 2637, 2349, 2093, 3729, 2959, 3729, 2959, 2793, 2637, 2349, 3951, 3322, 3136, 3322, 3136, 2793, 2349, 2637, 2217
chast dw 15000
len_music dw 29
pointer dw ?
music2 dw 659, 659, 659, 523, 659, 783, 391, 523, 391, 329, 440, 493, 466, 440, 391, 659, 783, 880, 698, 783, 659, 523, 587, 987, 783, 680, 698, 622, 680, 415, 466, 523, 440, 523, 587, 783, 739, 729, 587, 659, 1046, 1046, 1046
.code
Start:
 mov ax, @data
 mov ds, ax
 lea ax, music1
 mov pointer, ax
 xor ax, ax
 mov al, 10h
 int 10h
 ;Фон
 mov ax, 0600h ; ah = 06 - прокрутка вверх
 mov bh, 15 ;белый
 mov cx, 0000b ; ah = 00 - строка верхнуго левого угла
 mov dx, 184Fh
 int 10h
 mov ah, 0Ch ;установка графической точки
 mov al, 20 ;загружаем зелѐный цвет для вертикальной линии
 mov bh, 0h ;установка номера видеостраницы
 mov cx, 400 ;количество итераций сверху вниз для вертикальной линии
@metka1: ;прорисовка вертикальной линии
    push cx
    mov axis, cx ;в начало оси записываем 0
    mov dx, axis ;установка курсора
    mov cx, 213 ;вывод вертикальной оси, со сдвигом на 319 вправо
    int 10h
    pop cx ;400 итераций, ставит в 400 колонку, и идѐт до 0
    loop @metka1
    mov ah, 0ch ;установка графической точки
    mov al, 21 ;зелѐный цвет
    mov cx, 639 ;639 итераций, ставит в 639 колонку, и идѐт до 0
    mov bh, 0h ;установка номера видеостраницы
    mov dx, 330 ;ставит в 174 строку
@metka2: ;цикл вывода горизонтальной оси
    int 10h ;вывод горизонтальной линии
    loop @metka2
    mov cx, 639 ;начинаем рассчитывать функцию
    xor di, di
@metka3: ;отвечает за вывод графа
    mov x, cx ;помещаем в x 639
    fild x
    fild x
    fild n120
    fsub
    fild n240
    fdiv

    fxch st(1)
    fild n10
    fdiv
    frndint
    fistp x


    FLD st(0)           ; Загружаем x в FPU
    FLDz         ; Загружаем 0
    FCOM             ; Сравниваем x с 0
    FSTSW AX         ; Сохраняем статусное слово
    SAHF             ; Загружаем флаги
    Ja LESS_THAN_0   ; Если x < 0, перейти на блок вычислений
    jmp CHECK_0_1  
LESS_THAN_0:
    mov [chast], 300 
    fld st(1)
    fabs
    fld st(2)
    fld st(0)
    fmul 
    fld1
    fadd
    fdiv

    fld st(2)
    fild n_5
    fmul

    FLDL2E
    fmul
    fld     st
    frndint
    fsub    st(1), st
    fxch    st(1)
    f2xm1
    fld1
    faddp   st(1), st
    fscale
    fstp    st(1)
    fmul
    jmp calc

CHECK_0_1:
    fld st(1)
    fld1   
    fsub
    fldz
    FCOM             ; Сравниваем x с 0
    FSTSW AX         ; Сохраняем статусное слово
    SAHF             ; Загружаем флаги
    Ja M_0_1   ; Если x < 0, перейти на блок вычислений
    jmp greater_1
M_0_1:
    mov [chast], 10000
    fld st(3)
    fld st(0)
    fmul
    fld st(0)
    fmul
    fld1
    fadd 
    fsqrt
    jmp calc
greater_1:
    mov [chast], 15000
    fld st(3)
    fld st(0)
    fldpi
    fmul
    fcos
    fld1
    fadd
    fld st(1)
    fild n6
    fadd 
    fdiv
    fxch st(1)
    fild n3
    fmul
    fadd
    jmp calc
calc:
    fimul k2 ;st(0) = (pi*639*70) / (180*2)
    fchs ;st(0) = -(pi*639*70) / (180*2)
    fiadd b ;st(0) = 200 - (pi*639*70) / (180*2)
    frndint ;округляем st(0) до целого числа
    fistp y ;st(0) = 0,
    ;y = 200 - (pi*639*70)/(180*2)
    push cx
    mov cx, x
    mov ah, 0ch ;установка графической точки
    mov bh, 0h ;ставим в нулевое окно
    mov dx, y ;ставим в y строку
    mov al, 0 ;цвет черный
    int 10h
    pop cx

    push cx 
    mov cx, 1
    d12: 
    push cx 
    xor cx,cx 
    d11: 
    nop 
    loop d11 
    pop cx 
    loop d12 
    pop cx 
 

    mov al, 10110110b ;управляющее слово: канал 2, режим 3
    out 43h, al
    push di
    push si
    mov di, pointer
    add si, di
    mov ax, [si]
    pop si
    pop di
    add di, 2
    cmp di, 30
    jge di_eq
    jmp m_el
di_eq:
    xor di, di
    add si, 2
    cmp si, 58
    je equl_m
    jmp m_el
equl_m:
    mov si, 0
m_el:
    out 42h, al
    mov al, ah        
    out 42h, al 
    ;включаем динамик
    in al, 61h ; читаем порт управления
    or al, 00000011b ;устанавливаем биты для включения канала 2
    out 61h, al      

    ; Проверка нажатия клавиши
    mov ah, 01h        ; Проверка наличия нажатия клавиши (INT 16h, функция 01h)
    int 16h
    jz @skip_keycheck  ; Если клавиша не нажата, пропустить проверку

    mov ah, 00h        ; Чтение символа с клавиатуры (INT 16h, функция 00h)
    int 16h
    cmp al, '0'        ; Сравнить с символом '0'
    je @exit_program   ; Если нажата '0', выйти из программы
    cmp al, '1'
    je p1_music
    cmp al, '2'
    je p2_music
p1_music:
    lea ax, music1
    mov pointer, ax
    jmp @skip_keycheck
p2_music:
    lea ax, music2
    mov pointer, ax


@skip_keycheck:
    dec cx
    jnz @metka3

@exit_program:
    ; Завершение программы

    in al, 61h    
    and al, 0FCh
    out 61h, al

    mov ah, 4Ch
    int 21h
end Start
end