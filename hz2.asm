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

mSumAfterNeg macro matr, row, col, foundNegative
local rowLoop, colLoop, sumLoop
JUMPS
    push ax       ; Сохранение регистров, используемых в макросе, в стек 
    push bx 
    push cx 
    push si 
    push di
    xor bx, bx
    xor si, si    ; Счетчик столбцов
    mov cx, col 
colLoop:
    push cx       ; Сохраняем текущий счетчик столбцов
    mov foundNegative, 0  ; сбрасываем флаг нахождения отрицательног
    xor bx, bx    ;сбрасываем смещение по строкам
    mov cx, row
    xor di, di    ; обнуляем сумму для текущей строки
rowLoop: 
    mov ax, matr[bx][si]  ; bx - смещение по строкам, si - по столбцам 
    cmp ax, 0      ;Проверяем отрицательное ли число
    jl foundNeg    ;если отрицательное то обрабатываем
    cmp foundNegative, 0    ; проверка флага на отрицательность 
    je skipSum
    jmp sumLoop ; Если нашли отрицательное 
foundNeg:
    cmp foundNegative, 1 ; проверка флага на отрицательность 
    je sumLoop
    mov foundNegative, 1  ;устанавливаем флаг отрицательного числа
    jmp skipSum
sumLoop:
    mov ax, matr[bx][si]
    add di, ax          ;Добавляем элемент к сумме
skipSum:
    add bx, col
    add bx, col
    loop rowLoop 
    mov ax, di  
    mWriteAX    ;вывод суммы для текущей строки
    add si, 2
    printstr endl
    pop cx 
    loop colLoop 
    pop si   
    pop di
    pop cx 
    pop bx 
    pop ax 
NOJUMPS
endm

mSwapTwoRows macro matr, row, col, row1, row2, resMatr
local
    push ax       ; Сохранение регистров, используемых в макросе, в стек 
    push bx 
    push cx 
    push si 
    push di
 
    xor bx, bx    ; Обнуляем смещение по строкам 
    xor di, di
    
    mov ax, row1 ; высчитываем смещение для двух строк
    mov bx, 2
    mul col
    mul bx
    push ax
    mov ax, row2
    mul col
    mul bx
    
    xor bx, bx
    xor si, si    ; Обнуляем смещение по столбцам 
    mov cx, col 
    pop di ; тут смещение для первой строки
    mov bx, ax ; тут для второй
colLoop:                    ; Внутренний цикл, проходящий по столбцам 
    mov ax, matr[bx][si]  ; bx - смещение по строкам, si - по столбцам
    push bx
    mov bx, di
    mov dx, matr[bx][si]
    mov resMatr[bx][si], ax
    pop bx
    mov resMatr[bx][si], dx

    add si, 2         ; Переходим к следующему элементу (размером в слово) 
    loop colLoop 
    
    pop di
    pop si            ; Перенос сохранённых значений обратно в регистры  
    pop cx 
    pop bx 
    pop ax 
endm

mFindFirstNegInTriangle macro matr, row, col
local rowLoop, colLoop, next_it, foundNeg, exitTask2C
    push ax
    push bx 
    push cx 
    push si 
    push dx
    push di
    xor bx, bx
    xor dx, dx ; счетчик строк
    mov dx, -1
    mov cx, row 
rowLoop: 
    inc dx
    push cx
    xor di, di  ; счетчик столбцов
    xor si, si
    mov di, -1
    mov cx, col 
colLoop:
    inc di
    mov ax, matr[bx][si]
    cmp dx, di
    jg next_it
    or ax, ax         ; Проверить знаковый бит 
    js foundNeg

next_it:
    add si, 2       
    loop colLoop 
    
    add bx, col       ; Увеличиваем смещение по строкам  
    add bx, col       ; (дважды, так как размер каждого элемента - слово) 
    pop cx 
    loop rowLoop 
    jmp exitTask2C

foundNeg:
    printstr sTask2C1
    mWriteAX
    printstr endl
    printstr sTask2C2
    mov ax, dx
    mWriteAX
    printstr endl
    printstr sTask2C3
    mov ax, di
    mWriteAX
    printstr endl
 
exitTask2C:
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
;задание а = в
.model small
.stack 100h
.data
matr dw 15 dup(15 dup (?))
tMatr dw 15 dup(15 dup(?))
rowMatr dw 15 dup(15 dup(?))
row dw ?
col dw ?
trow dw ?
tcol dw ?
tab db '	$'
endl db 0Dh, 0Ah, '$'
buffer db ?
sTask1 db '      Transpose matrix: $'
sMatr db 'Matrix: $'
sTask2A db 'Sum(po sctolbikam): $'
sMenu db '1. Vvod matrix', 0Dh, 0Ah, '2. Vivod matrix', 0Dh, 0Ah, '3. Transpose matrix', 0Dh, 0Ah, '4. Summa po stolbikam', 0Dh, 0Ah, '5. Swap 2 rows', 0Dh, 0Ah, '6. Find first negative number in triangle', 0Dh, 0Ah,'0. Exit', 0Dh, 0Ah, '$'
sChoose db 'Enter your choice: $'
sError db 'Incorrect value, try again $'
sInputMatr db 'Enter Matr: $'
sInputR1 db 'Enter rows #1: $'
sInputR2 db "Enter rows #2: $"
sInputR db 'Enter number of rows: $'
sInputC db 'Enter number of cols: $'
sTask2C1 db 'Element: $'
sTask2C2 db 'In row: $'
sTask2C3 db 'In col: $'
row1 dw ?
row2 dw ?

foundNegative db ?
sum dw 0
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
    mReadMatrix matr, row, col, rowMatr

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
    je taskSumAfterNegative
    cmp ax, 5
    je task2
    cmp ax, 6
    je task3
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
    mReadMatrix matr, row, col, rowMatr
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

taskSumAfterNegative:
    printstr endl
    mWriteMatrix matr, row, col
    printstr endl

    printstr sTask2A
    printstr endl
    mSumAfterNeg matr, row, col, foundNegative
    pause
    jmp menuLoop

task2:
JUMPS
    printstr endl
    printstr sInputR1
    mReadAX buffer, 3
    mov row1, ax
    cmp ax, 0
    jl nCorrect
    cmp ax, row
    jge nCorrect
    printstr sInputR2
    mReadAX buffer, 3
    mov row2, ax
    cmp ax, 0
    jl nCorrect
    cmp ax, row
    jge nCorrect
    jmp ifCorrect
nCorrect:
    printstr sError
    jmp exitTask2
ifCorrect:
    mWriteMatrix matr, row, col
    printstr endl
    mSwapTwoRows matr, row, col, row1, row2, rowMatr
    mWriteMatrix rowMatr, row, col
    mCopyMatrix matr, rowMatr, row, col
    printstr endl
exitTask2:
    pause
    jmp menuLoop

task3:
    printstr endl
    mWriteMatrix matr, row, col
    printstr endl
    mFindFirstNegInTriangle matr, row, col
    printstr endl
    pause
    jmp menuLoop
exitProgram:
NOJUMPS
    mov ax, 4c00h
    int 21h
end start
