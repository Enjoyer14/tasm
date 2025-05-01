printstr macro msg
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, msg           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax
endm

mAbs macro
local makePositive, doneAbs
    or ax, ax
    js  makePositive
    jmp doneAbs
makePositive:
    neg ax
doneAbs:
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

mTask1 macro matrix2, row, col, maxIndex, minIndex, maxEl, minEl
local rowLoop, colLoop1, colLoop2, newMax, newMin, nextCol1, nextCol2, toNextCycle, doNothing, skipRow
    JUMPS
    push ax       ; Сохранение регистров
    push bx 
    push cx 
    push dx
    push si
    push di

    xor si, si
    xor bx, bx    ; Обнуляем смещение по строкам
    xor di, di
    ;int 03h
    mov cx, row   ; Количество строк в матрице
rowLoop:          ; Внешний цикл, проходящий по строкам
    push cx
    xor si, si    ; Обнуляем смещение по столбцам
    xor di, di

    mov ax, matrix2[bx][si] ; Загружаем текущий элемент
    mov minEl, ax
    mov maxEl, ax
    mov maxIndex, si
    mov minIndex, si

    mov cx, col   ; Количество столбцов
colLoop1:         ; Поиск минимального элемента в строке
    mov ax, matrix2[bx][si] ; Загружаем текущий элемент
    cmp ax, minEl
    jle newMin

    cmp ax, maxEl
    jge newMax

    jmp nextCol1

newMin:
    mov minEl, ax
    mov minIndex, si
    jmp nextCol1

newMax:
    mov maxEl, ax
    mov maxIndex, si

nextCol1:
    add si, 2     ; Переходим к следующему элементу
    loop colLoop1

toNextCycle:
    ;int 03h
    mov ax, maxIndex
    cmp ax, minIndex
    je skipRow
    jg doNothing
    mov ax, maxIndex
    mov dx, minIndex
    mov maxIndex, dx
    mov minIndex, ax

doNothing:
    mov ax, maxIndex
    sub ax, minIndex
    push bx
    mov bx, 2d
    xor dx, dx
    idiv bx
    sub ax, 1d
    mov bx, 2d
    xor dx, dx
    idiv bx
    pop bx
    xor dx, dx
    mov si, minIndex
    mov di, maxIndex
    add si, 2
    sub di, 2
    ;int 03h
    mov cx, ax
colLoop2:
    mov ax, matrix2[bx][si] ; Загружаем текущий элемент
    mov dx, matrix2[bx][di]
    mov matrix2[bx][si], dx
    mov matrix2[bx][di], ax
nextCol2:
    add si, 2
    sub di, 2
    loop colLoop2

skipRow:
    add bx, col          ; Переходим к следующей строке (смещение увеличиваем)
    add bx, col          ; Учитывая размер каждого элемента (слово = 2 байта)
    pop  cx
    int 03h
    loop rowLoop

    pop di               ; Восстанавливаем сохраненные регистры
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
NOJUMPS
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
local rowLoop, colLoop, skipRow, ItFalse, ItTrue, ex1
JUMPS
    push ax
    push bx ; смещение по началу в строчку
    push cx
    push dx
    push si  ; смещение по началу в столбик
    push di  ; смещение с конца в столбик

    printstr sTask2Ans

    mov ax, col
    mov bx, 1d
    sub ax, bx
    mov bx, 2d
    mul bx
    mov di, ax    ; - нашли конечное смещение в строчке по столбикам

    xor si, si
    xor bx, bx
    mov cx, row
rowLoop:
    push cx
    mov ax, matr[bx][si]
    cmp ax, matr[bx][di]
    jne ItFalse

skipRow:
    add bx, col
    add bx, col
    pop cx
    loop rowLoop
ItTrue:
    printstr sTrue
    jmp ex1

ItFalse:
    printstr sFalse

ex1:

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
NOJUMPS
endm

mTask3 macro matr, row, col, countEven
local rowLoop, colLoop, skipEl
    push ax
    push bx 
    push cx 
    push si 
    push dx
    push di

    printstr sTask3Ans

    xor bx, bx    ; Обнуляем смещение по строкам
    mov cx, row   ; Устанавливаем количество строк
rowLoop:
    push cx

    xor si, si    ; Обнуляем смещение по столбцам
    mov cx, col   ; Устанавливаем количество столбцов
colLoop:
    mov ax, matr[bx][si] ; Загружаем элемент из исходной матрицы
    xor dx, dx
    push bx
    mov bx, 2d
    div bx
    pop bx
    cmp dx, 1d
    je skipEl
    mov ax, countEven
    inc ax
    mov countEven, ax

skipEl:
    add si, 2                 ; Переходим к следующему элементу (размером в слово)
    loop colLoop

    add bx, col       ; Увеличиваем смещение по строкам исходной матрицы
    add bx, col
    pop cx
    loop rowLoop


    mov ax, countEven
    mWriteAX

    pop di
    pop dx
    pop si            ; Перенос сохранённых значений обратно в регистры  
    pop cx 
    pop bx 
    pop ax 

endm

pause macro 
    printstr endl
    mov ah, 08h
    int 21h
endm

.model small
.stack 100h
.data
matr dw 15 dup(15 dup (?))
tMatr dw 15 dup(15 dup(?))
row dw ?
col dw ?
trow dw ?
tcol dw ?
tab db '	$'
endl db 0Dh, 0Ah, '$'
buffer db ?
sTask1 db '      Transpose matrix: $'
sMatr db 'Matrix: $'
sMenu db '1. Vvod matrix', 0Dh, 0Ah, '2. Vivod matrix', 0Dh, 0Ah, '3. Transpose matrix', 0Dh, 0Ah, '4. Swap between min and max', 0Dh, 0Ah, '5. Are the first and last cols the same', 0Dh, 0Ah, '6. Quantity of even number', 0Dh, 0Ah,'0. Exit', 0Dh, 0Ah, '$'
sChoose db 'Enter your choice: $'
sError db 'Incorrect value, try again $'
sInputMatr db 'Enter Matr: $'
sInputR db 'Enter number of rows: $'
sInputC db 'Enter number of cols: $'

sTask2Ans db 'Is The Same: $'
sTrue db 'True $'
sFalse db 'False $'
sTask3Ans db 'Quantity of Even Elements: $'
countEven dw 0

minEl dw 0
minIndex dw 0
maxEl dw 0
maxIndex dw 0
matr2 dw 15 dup(15 dup (?))

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
    mWriteMatrix matr, row, col
    printstr endl

    mCopyMatrix matr, matr2, row, col

    mTask1 matr2, row, col, maxIndex, minIndex, maxEl, minEl

    printstr endl

    mWriteMatrix matr2, row, col
    printstr endl
    int 03h
    pause
    jmp menuLoop

taskN2:
JUMPS
    printstr endl
    mWriteMatrix matr, row, col
    printstr endl

    mTask2 matr ,row, col

    printstr endl

    pause
    jmp menuLoop

taskN3:
    printstr endl
    mWriteMatrix matr, row, col
    printstr endl

    mTask3 matr, row, col, countEven

    printstr endl

    pause
    jmp menuLoop
exitProgram:
NOJUMPS
    mov ax, 4c00h
    int 21h
end start
