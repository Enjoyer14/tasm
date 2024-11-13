printstr macro msg
	mov ah, 09h
	mov dx, msg
	int 21h
endm

inputchr macro var
	mov ah, 01h
	int 21h
	mov var, al
endm

mAbs macro
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

mReadMatrix macro matrix, row, col       
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
    push bx
    mov bx, offset tab
    printstr bx ; Макрос вывода строки на экран Приложение 3
    pop bx         ; Вывод на экран табуляции, разделяющей элементы строки 
 
    add si, 2         ; Переходим к следующему элементу (размером в слово) 
    loop colLoop 
    
    push bx
    mov bx, offset endl
    printstr bx   ; Макрос вывода строки на экран Приложение 3
    pop bx                  ; Перенос курсора и каретки на следующую строку 
    
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


setcursor macro var1, var2, var3, var4
	push ax
	push dx
	push bx
	
	mov ah, var1 установка курсора
	mov dh, var2 строка
	mov dl, var3 ;столбец
	mov bh, var4   ; страница
	int 10h

	pop bx
	pop dx
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
    push di      ; Для хранения суммы
    xor bx, bx    ; Обнуляем смещение по строкам 
    mov cx, row 
rowLoop:          ; Внешний цикл, проходящий по строкам 
    push cx  
    mov foundNegative, 0  ; сбрасываем флаг нахождения отрицательного
    xor si, si    ; Обнуляем смещение по столбцам 
    mov cx, col
    xor di, di    ; Обнуляем сумму для текущей строки
colLoop:          ; Внутренний цикл, проходящий по столбцам 
    mov ax, matr[bx][si]  ; bx - смещение по строкам, si - по столбцам 
    cmp ax, 0      ; Проверяем, отрицательное ли число
    jl foundNeg    ; Если отрицательное, переходим к обработке
    cmp foundNegative, 0    ; Если отрицательное число найдено, начинаем суммировать
    je skipSum
    jmp sumLoop ; Если нашли отрицательное, начинаем суммировать модули чисел после первого отрицательного
foundNeg:
    cmp foundNegative, 1
    je sumLoop
    mov foundNegative, 1   ; Устанавливаем флаг, что нашли отрицательное число
    jmp skipSum
sumLoop:
    mov ax, matr[bx][si]; Суммируем модули чисел после первого отрицательного элемент
    mAbs             ; Находим модуль числа
    add di, ax          ; Добавляем к сумме
skipSum:
    add si, 2           ; Переходим к следующему элементу (размером в слово) 
    loop colLoop 
    mov ax, di          ; Переносим сумму в регистр AX
    mWriteAX ; Вывод суммы для текущей строки
    add bx, col         ; Увеличиваем смещение по строкам; Переход к следующей строке  
    add bx, col         ; (дважды, так как размер каждого элемента - слово) 
    push bx
    mov bx, offset endl
    printstr bx      ; Перенос строки
    pop bx
    pop cx 
    loop rowLoop 
    pop si              ; Перенос сохранённых значений обратно в регистры  
    pop di
    pop cx 
    pop bx 
    pop ax 
NOJUMPS
endm


mIsAlternatesSigns macro matr, row, col, inputRow, foundNegative
local colLoop, negative, makeNeg, positive, makePos, nextIter, exit, falseExit
JUMPS
    push ax       ; Сохранение регистров, используемых в макросе, в стек 
    push bx 
    push cx 
    push si 

    xor bx, bx    ; Обнуляем смещение по строкам 
    mov ax, inputRow   ; Загружаем номер строки в регистр ax
    imul col         ; Умножаем на количество столбцов, получаем смещение
    add ax, si         ; Добавляем индекс столбца
    mov bx, ax

    xor si, si    ; Обнуляем смещение по столбцам 
    mov cx, col 
    mov foundNegative, 0  ; Сбрасываем флаг чередования

colLoop:                    ; Внутренний цикл, проходящий по столбцам 
    mov ax, matr[bx][si]  ; bx - смещение по строкам, si - по столбцам 
    or ax, ax
    js negative           ; Если число отрицательное, переходим к метке negative
    jmp positive           ; Если число положительное, переходим к метке positive

negative:
    cmp foundNegative, 0   ; Если первый элемент, запоминаем его как отрицательное
    jge makeNeg            ; Если еще не встретили отрицательное, устанавливаем флаг
    cmp foundNegative, 1   ; Если предыдущий элемент был положительным, а текущий отрицателен
    je nextIter            ; Если чередование знаков соблюдается, идем к следующему элементу
    jmp falseExit          ; Если знаки не чередуются, выводим false и выходим

makeNeg:
    mov foundNegative, -1  ; Устанавливаем флаг для отрицательного числа
    jmp nextIter

positive:
    cmp foundNegative, 0   ; Если первый элемент, запоминаем его как положительное
    jle makePos            ; Если еще не встретили положительное, устанавливаем флаг
    cmp foundNegative, -1  ; Если предыдущий элемент был отрицательным, а текущий положителен
    je nextIter            ; Если чередование знаков соблюдается, идем к следующему элементу
    jmp falseExit          ; Если знаки не чередуются, выводим false и выходим

makePos:
    mov foundNegative, 1   ; Устанавливаем флаг для положительного числа
    jmp nextIter

nextIter:
    add si, 2         ; Переходим к следующему элементу (размером в слово) 
    loop colLoop 

    ; Если чередование знаков не нарушилось, выводим true
    mov bx, offset sTrue
    printstr bx
    jmp exit

falseExit:
    ; Если знаки не чередуются, выводим false
    mov bx, offset sFalse
    printstr bx

exit:
    pop si            ; Перенос сохранённых значений обратно в регистры  
    pop cx 
    pop bx 
    pop ax 
NOJUMPS
endm



mFindFirstNonZero macro matr, row, col
local
JUMPS

NOJUMPS
endm

.model small
.stack 100h
.data
matr dw 5 dup(5 dup (?))
tMatr dw 5 dup(5 dup(?))
row dw 5d
col dw 5d
tab db '	$'
endl db 0Dh, 0Ah, '$'
buffer db ?
sTask1 db 'Transpose matrix: $'
sMatr db 'Matrix: $'
sTask2A db 'Summa(po strokam): $'
sTask2b db 'Enter row: $'
inputRow dw ?
foundNegative db ?
sum dw 0
sTrue db 'True $'
sFalse db 'False $'
.code
start:
	mov ax, @data
	mov ds, ax

	wipescreen

	setcursor 0, 0, 0, 0

	mReadMatrix matr, row, col

    mov bx, offset sMatr
    printstr bx
    mov bx, offset endl
    printstr bx
	mWriteMatrix matr, row, col

    mov bx, offset sTask1
    printstr bx
    mov bx, offset endl
    printstr bx
	mTransposeMatrix matr, row, col, tMatr
	
	mWriteMatrix tMatr, row, col

    mov bx, offset sTask2A
    printstr bx
    mov bx, offset endl
    printstr bx

    mSumAfterNeg matr, row, col, foundNegative

    mov bx, offset sTask2b
    printstr bx
    mReadAX buffer, 3
    mov inputRow, ax
    mIsAlternatesSigns matr, row, col, inputRow, foundNegative

    mov ax, 4c00h
	int 21h
end start
