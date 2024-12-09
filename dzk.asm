printstr macro msg
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, msg           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax
endm

mWriteAX macro               
local convert, write 
    push ax      ; Сохранение регистров, используемых в макросе, в стек 
    push bx 
    push cx 
    push dx 
    push di 
 
    mov cx, 10   ; cx - основание системы счисления 
    xor di, di   ; di - количество цифр в числе 
 
    or ax, ax    ; Проверяем, равно ли число в ax нулю и устанавливаем флаги 
    jns convert  ; Переход к конвертированию, если число в ax положительное 
          
    push ax 
 
    mov dx, '-' 
    mov ah, 02h  ; 02h - функция вывода символа на экран 
    int 21h      ; Вывод символа "-" 
 
    pop ax      
    neg ax       ; Инвертируем отрицательное число 
     
convert:   
    xor dx, dx 
 
    div cx       ; После деления dl = остатку от деления ax на cx 
    add dl, '0'  ; Перевод в символьный формат 
    inc di       ; Увеличиваем количество цифр в числе на 1   
 
    push dx      ; Складываем в стек 
 
    or ax, ax    ; Проверяем, равно ли число в ax нулю и устанавливаем флаги 
    jnz convert  ; Переход к конвертированию, если число в ax не равно нулю  
 
write:           ; Вывод значения из стека на экран 
    pop dx       ; dl = очередной символ 
 
    mov ah, 02h 
    int 21h      ; Вывод очередного символа 
    dec di       ; Повторяем, пока di <> 0 
    jnz write   
 
; Перенос сохранённых значений обратно в регистры  
pop di       
pop dx 
pop cx 
pop bx 
pop ax 
endm mWriteAX 

mCopyMatrix macro matrix1, matrix2, row, col
local rowLoop, colLoop
    push ax       ; Сохранение регистров, используемых в макросе, в стек
    push bx
    push cx
    push si
    push di

    xor bx, bx    ; Обнуляем смещение по строкам
    mov cx, row   ; Устанавливаем количество строк
rowLoop:
    push cx

    xor si, si    ; Обнуляем смещение по столбцам
    mov cx, col   ; Устанавливаем количество столбцов
colLoop:
    mov ax, matrix1[bx][si] ; Загружаем элемент из исходной матрицы
    mov matrix2[bx][si], ax ; Копируем элемент в целевую матрицу
    add si, 2                 ; Переходим к следующему элементу (размером в слово)
    loop colLoop

    add bx, col       ; Увеличиваем смещение по строкам исходной матрицы
    add bx, col
    pop cx
    loop rowLoop

    pop di            ; Восстанавливаем регистры
    pop si
    pop cx
    pop bx
    pop ax
endm

mReadAX macro buffer, size
	local input, startOfConvert, endOfConvert
	push bx
	push cx
	push dx

input:
	mov [buffer], size
	mov dx, offset [buffer]
	mov ah, 0Ah
	int 21h

	mov ah, 02h
	mov dl, 0Dh
	int 21h
	
	mov ah, 02h
	mov dl, 0Ah
	int 21h

	xor ah, ah
	cmp ah, [buffer][1]
	jz input

	xor cx, cx
	mov cl, [buffer][1]

	xor ax, ax
	xor bx, bx
	xor dx, dx
	mov bx, offset [buffer][2]

	cmp [buffer][2], '-'
	jne startOfConvert
	inc bx
	dec cl

startOfConvert:
	mov dx, 10
	mul dx
	cmp ax, 8000h
	jae input

	mov dl, [bx]
	sub dl, '0'

	add ax, dx
	cmp ax, 8000h
	jae input

	inc bx
	loop startOfConvert

	cmp [buffer][2], '-'
	jne endOfConvert
	neg ax

endOfConvert:
	pop dx
	pop cx
	pop bx
endm

mReadMatrix macro matrix, row, col, matr1     
local rowLoop, colLoop  
JUMPS             ; Директива, делающая возможным большие прыжки 
    push bx       ; Сохранение регистров, используемых в макросе, в стек 
    push cx 
    push si 
 
    xor bx, bx    ; Обнуляем смещение по строкам 
    mov cx, row 
rowLoop:          ; Внешний цикл, проходящий по строкам 
    push cx 
 
    xor si, si    ; Обнуляем смещение по столбцам 
    mov cx, col  
colLoop:              ; Внутренний цикл, проходящий по столбцам 
    mReadAX buffer, 5  ; Макрос ввода значения регистра AX с клавиатуры  
                      ; [Приложение 1] 
 
    mov matrix[bx][si], ax 
    mov matr1[bx][si], ax
    add si, 2         ; Переходим к следующему элементу (размером в слово) 
    loop colLoop 

    add bx, col       ; Увеличиваем смещение по строкам  
    add bx, col       ; (дважды, так как размер каждого элемента - слово) 
 
    pop cx 
    loop rowLoop 
 
    pop si            ; Перенос сохранённых значений обратно в регистры  
    pop cx 
    pop bx 
NOJUMPS               ; Прекращение действия директивы JUMPS 
endm mReadMatrix 

mWriteMatrix macro matrix, row, col      
local rowLoop, colLoop  
    push ax       ; Сохранение регистров, используемых в макросе, в стек 
    push bx 
    push cx 
    push si 
 
    xor bx, bx    ; Обнуляем смещение по строкам 
    mov cx, row 
rowLoop:          ; Внешний цикл, проходящий по строкам 
    push cx  
 
    xor si, si    ; Обнуляем смещение по столбцам 
    mov cx, col 
colLoop:                    ; Внутренний цикл, проходящий по столбцам 
    mov ax, matrix[bx][si]  ; bx - смещение по строкам, si - по столбцам 
 
    mWriteAX      ; Макрос вывода значения регистра AX на экран [Приложение 2] 
                  ; Вывод текущего элемента матрицы 
    xor ax, ax 
    printstr tab; Макрос вывода строки на экран Приложение 3

    add si, 2         ; Переходим к следующему элементу (размером в слово) 
    loop colLoop 
    
    printstr endl   ; Макрос вывода строки на экран Приложение 3                ; Перенос курсора и каретки на следующую строку 
    
    add bx, col       ; Увеличиваем смещение по строкам  
    add bx, col       ; (дважды, так как размер каждого элемента - слово) 
    pop cx 
    loop rowLoop 
 
    pop si            ; Перенос сохранённых значений обратно в регистры  
    pop cx 
    pop bx 
    pop ax 
endm mWriteMatrix 

mTransposeMatrix macro matrix, row, col, resMatrix    
local rowLoop, colLoop  
    push ax         ; Сохранение регистров, используемых в макросе, в стек 
    push bx 
    push cx 
    push di 
    push si 
    push dx 
 
    xor di, di            ; Обнуляем смещение по строкам 
    mov cx, row 
rowLoop:                  ; Внешний цикл, проходящий по строкам 
    push cx 
    xor si, si            ; Обнуляем смещение по столбцам 
    mov cx, col 
colLoop:                  ; Внутренний цикл, проходящий по столбцам 
    mov ax, col 
    mul di                ; Устанавливаем смещение по строкам 
    add ax, si            ; Устанавливаем смешение по столбцам 
    mov bx, ax 
    mov ax, matrix[bx] 
    push ax               ; Заносим текущий элемент в стек 
 
    mov ax, row          
    mul si                ; Устанавливаем смещение по строкам 
    add ax, di            ; Устанавливаем смешение по столбцам 
                          ;  (смещения по строкам и столбцам меняются      
                          ;   местами по сравнению с оригинальной матрицей) 
    mov bx, ax 
    pop ax 
    mov resMatrix[bx], ax  ; Заносим в новую матрицу элемент,               
                          ; сохранённый в стеке 
    
    add si, 2             ; Переходим к следующему элементу             
                          ;  (размером в слово) 
    loop colLoop 
     
    add di, 2             ; Переходим к следующей строке 
    pop cx 
    loop rowLoop 
 
    pop dx                ; Перенос сохранённых значений обратно в регистры  
    pop si 
    pop di 
    pop cx 
    pop bx 
    pop ax 
endm

wipescreen macro
	push ax
	push bx
	push cx
	push dx
	mov ax, 0600h
	mov bh, 07
	mov cx, 0
	mov dx, 184Fh
	int 10h
	pop dx
	pop cx
	pop bx
	pop ax
endm

mTask1 macro matr, row, col, matrT1
local rowLoop, colLoop1, colLoop2, toNextCycle, next1, skipRow

    push ax       ; Сохранение регистров
    push bx 
    push cx 
    push dx
    push si
    push di

    xor bx, bx    ; Обнуляем смещение по строкам
    mov cx, row   ; Количество строк в матрице
rowLoop:          ; Внешний цикл, проходящий по строкам
    push cx

    xor si, si    ; Обнуляем смещение по столбцам
    mov cx, col   ; Количество столбцов
colLoop1:         ; Поиск минимального элемента в строке
    mov ax, matr[bx][si] ; Загружаем текущий элемент
    cmp ax, 0
    je next1     ; Если текущий элемент больше или равен, переходим дальше
    mov di, ax    ; Обновляем минимальный элемент
    jmp toNextCycle
next1:
    add si, 2     ; Переходим к следующему элементу
    loop colLoop1

    ; Проверяем минимальный элемент на ноль
    cmp di, 0
    je skipRow    ; Пропускаем строку, если минимальный элемент равен нулю

toNextCycle:
    xor si, si    ; Сбрасываем смещение для деления строки на минимальный элемент
    mov cx, col   ; Повторно итерируем по столбцам
colLoop2:
    mov ax, matr[bx][si] ; Загружаем текущий элемент
    cwd                 ; Расширяем знак из AX в DX (важно для отрицательных чисел)
    idiv di             ; Делим на минимальный элемент
    mov matrT1[bx][si], ax ; Сохраняем результат
    add si, 2            ; Переходим к следующему элементу
    loop colLoop2

skipRow:
    add bx, col          ; Переходим к следующей строке (смещение увеличиваем)
    add bx, col          ; Учитывая размер каждого элемента (слово = 2 байта)
    pop cx
    loop rowLoop

    pop di               ; Восстанавливаем сохраненные регистры
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

endm

mCopyMatrix macro matrix1, matrix2, row, col
local rowLoop, colLoop
    push ax       ; Сохранение регистров, используемых в макросе, в стек
    push bx
    push cx
    push si
    push di

    xor bx, bx    ; Обнуляем смещение по строкам
    mov cx, row   ; Устанавливаем количество строк
rowLoop:
    push cx

    xor si, si    ; Обнуляем смещение по столбцам
    mov cx, col   ; Устанавливаем количество столбцов
colLoop:
    mov ax, matrix1[bx][si] ; Загружаем элемент из исходной матрицы
    mov matrix2[bx][si], ax ; Копируем элемент в целевую матрицу
    add si, 2                 ; Переходим к следующему элементу (размером в слово)
    loop colLoop

    add bx, col       ; Увеличиваем смещение по строкам исходной матрицы
    add bx, col
    pop cx
    loop rowLoop

    pop di            ; Восстанавливаем регистры
    pop si
    pop cx
    pop bx
    pop ax
endm

mTask2 macro matr, row, col
local rowLoop, colLoop, colLoop1, next_it, skipRow
JUMPS
    push ax
    push bx ; смещение по началу в строчку
    push cx
    push dx
    push si  ; смещение по началу в столбик
    push di  ; смещение с конца в столбик

    printstr sOutput1
    printstr endl

    xor bx, bx
    mov cx, row

rowLoop:
    push cx
    push bx
    mov ax, col
    mov bx, 1d
    sub ax, bx
    mov bx, 2d
    mul bx
    mov di, ax    ; - нашли конечное смещение в строчке по столбикам

    mov ax, col
    div bx
    pop bx

    xor si, si
    mov cx, ax
colLoop:
    mov ax, matr[bx][si]
    push si
    mov si, di
    mov dx, matr[bx][si]
    pop si
    cmp ax, dx
    jne skipRow

next_it:
    add si, 2
    sub di, 2
    loop colLoop
    xor si, si
    mov cx, col
colLoop1:
    mov ax, matr[bx][si]
    mWriteAX 
    xor ax, ax 
    printstr tab
    add si, 2
    loop colLoop1
    printstr endl
skipRow:
    add bx, col
    add bx, col
    pop cx
    loop rowLoop


    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
NOJUMPS
endm

mTask3 MACRO matrix, rows, cols
    LOCAL OuterLoop, InnerLoop, SwapLoop, SkipSwap, loop1
    push ax
    push bx ; смещение по началу в строчку
    push cx
    push dx
    push si  ; смещение по началу в столбик
    push di  ; смещение с конца в столбик

    mov cx, row
loop1:
    mov si, 0
OuterLoop:
    mov ax, cols
    add ax, ax
    cmp si, ax              ; Проверка: si < cols
    jae EndSort               ; Если все столбцы обработаны, выйти

    mov di, cols
    add di, di

    ; Для каждой строки в столбце
    xor bx, bx
InnerLoop:
    mov ax, rows
    mul cols
    add ax, ax
    cmp bx, ax             ; Проверка: bx < rows - 1
    jae NextColumn            ; Если строки закончились, перейти к следующему столбцу
    xor ax, ax
    ; Сравнить элементы bx и bx+1 в текущем столбце (si)
    mov ax, matrix[bx][si]    ; Загружаем текущий элемент в AX
    push bx
    add bx, di
    mov dx, matrix[bx][si]  ; Загружаем следующий элемент в DX (bx+1)
    pop bx
    cmp ax, dx                ; Сравниваем AX и DX
    jle SkipSwap              ; Если AX <= DX, пропустить обмен

    ; Обмен значений
    mov matrix[bx][si], dx    ; matrix[bx][si] = DX
    push bx
    add bx, di
    mov matrix[bx][si], ax  ; matrix[bx+1][si] = AX
    pop bx

SkipSwap:
    add bx, col
    add bx, col
    jmp InnerLoop             ; Возврат к началу внутреннего цикла

NextColumn:
    add si, 2
    jmp OuterLoop             ; Переход к следующему столбцу

EndSort:
    loop loop1
    pop di               ; Восстанавливаем сохраненные регистры
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
ENDM



pause macro 
    printstr endl
    mov ah, 08h
    int 21h
endm
setCursor macro row, col
    push ax
    push bx
    push dx
    mov ah, 02h        ; Функция установки позиции курсора
    xor bh, bh         ; Указываем номер страницы (обычно 0)
    mov dh, row        ; Устанавливаем строку курсора
    mov dl, col        ; Устанавливаем столбец курсора
    int 10h            ; Вызов прерывания BIOS
    pop dx
    pop bx
    pop ax
endm


.model small
.stack 100h
.data
matr dw 15 dup(15 dup (?))
tMatr dw 15 dup(15 dup(?))
matrn1 dw 15 dup(15 dup (?))
row dw ?
col dw ?
trow dw ?
tcol dw ?
Nt2 dw ?
tab db '	$'
endl db 0Dh, 0Ah, '$'
buffer db ?
sTask1 db '         Transposed matrix: $'
sMatr db 'The original matrix: $'
sTask2A db 'Division by the first is non zero: $'
sMenu db '1. Input matrix', 0Dh, 0Ah, '2. Matrix output', 0Dh, 0Ah, '3. Matrix transposition', 0Dh, 0Ah, '4. Division by the first is non zero', 0Dh, 0Ah, '5. Semetry relative to the center', 0Dh, 0Ah, '6. Sort in ascending order', 0Dh, 0Ah,'0. Exit', 0Dh, 0Ah, '$'
sChoose db 'Enter the item number: $'
sError db 'Incorrect value, try again $'
sInputMatr db 'Enter the elements of the matrix: $'
sInputR db 'Enter number of rows: $'
sInputC db 'Enter number of cols: $'
sOutput1 db 'Symmetric strings: $'
sOutput3 db 'Sorted columns: $'
el1 dw 0

.code
start:
    mov ax, @data
    mov ds, ax

    wipescreen
    xor ax, ax
    printstr sInputR
    mReadAX buffer, 3
    mov row, ax
    mov tcol, ax
    xor ax, ax
    printstr sInputC
    mReadAX buffer, 3
    mov col, ax
    mov trow, ax
    xor ax, ax
    printstr sInputMatr
    printstr endl
    mReadMatrix matr, row, col

menuLoop:
    wipescreen
    setCursor 4, 0    ; Установить курсор в строку 5, столбец 10
    printstr sMenu
    printstr endl
    printstr sChoose

    mReadAX buffer, 2

    JUMPS
    cmp ax, 1
    je enterMatr
    cmp ax, 2
    je printMatr
    cmp ax, 3
    je taskTranspose
    cmp ax, 4
    je taskN1
    cmp ax, 5
    je taskN2
    cmp ax, 6
    je taskN3
    cmp ax, 0
    je exitProgram
    jmp menuLoop
enterMatr:
    xor ax, ax
    printstr sInputR
    mReadAX buffer, 3
    mov row, ax
    mov tcol, ax
    xor ax, ax
    printstr sInputC
    mReadAX buffer, 3
    mov col, ax
    mov trow, ax
    xor ax, ax
    printstr sInputMatr
    printstr endl
    mReadMatrix matr, row, col
    jmp menuLoop

printMatr:
    printstr endl
    printstr sMatr
    printstr endl
    mWriteMatrix matr, row, col
    printstr endl
    pause
    jmp menuLoop

taskTranspose:
    printstr endl
    printstr sMatr
    printstr endl
    mWriteMatrix matr, row, col
    printstr endl

    printstr sTask1
    printstr endl
    mTransposeMatrix matr, row, col, tMatr
    mWriteMatrix tMatr, trow, tcol

    pause
    jmp menuLoop

taskN1:
    printstr endl
    printstr sMatr
    printstr endl
    mWriteMatrix matr, row, col
    printstr endl

    printstr sTask2A
    printstr endl
    mTask1 matr, row, col, matrn1
    mWriteMatrix matrn1, row, col
    printstr endl

    pause
    jmp menuLoop

taskN2:
JUMPS
    printstr endl
    printstr sMatr
    printstr endl
    mWriteMatrix matr, row, col
    printstr endl

    mTask2 matr ,row, col

    printstr endl

    pause
    jmp menuLoop

taskN3:
    printstr endl
    printstr sMatr
    printstr endl
    mWriteMatrix matr, row, col
    printstr endl
    printstr sOutput3
    printstr endl
    mCopyMatrix matr, matrn1, row, col
    mTask3 matrn1, row, col
    mWriteMatrix matrn1, row, col
    pause
    jmp menuLoop
exitProgram:
NOJUMPS
    mov ax, 4c00h
    int 21h
end start
