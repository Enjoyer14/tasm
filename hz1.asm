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

mTask4 macro matrix, row, col, flagNegative, matrixRes, col2
local rowLoop, colLoop, nextCol, nextRow, push_back
 int 3h  
    push ax       ; Сохранение регистров, используемых в макросе, в стек 
    push bx 
    push cx 
    push si 

    xor di, di
    xor bx, bx    ; Обнуляем смещение по строкам 
    mov cx, row 
rowLoop:
    push cx  
    mov flagNegative, 0
    xor si, si    ; Обнуляем смещение по столбцам 
    mov cx, col 
colLoop:                    ; Внутренний цикл, проходящий по столбцам 
    mov ax, matrix[bx][si]  ; bx - смещение по строкам, si - по столбцам 
    
    cmp ax, 0
    jge push_back

    cmp flagNegative, 1
    je push_back

    mov flagNegative, 1
    jmp nextCol

push_back:
    mov [matrixRes + di], ax
    xor ax, ax
    add di, 2
    jmp nextCol
nextCol:
    add si, 2         ; Переходим к следующему элементу (размером в слово) 
    loop colLoop 
nextRow: 
    add bx, col       ; Увеличиваем смещение по строкам  
    add bx, col       ; (дважды, так как размер каждого элемента - слово) 
    pop cx 
    loop rowLoop 
    
    pop si            ; Перенос сохранённых значений обратно в регистры  
    pop cx 
    pop bx 
    pop ax 
endm

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


pause macro 
    printstr endl
    mov ah, 08h
    int 21h
endm

.model small
.stack 100h
.data
matr dw 15 dup(15 dup (?))
matr1 dw 15 dup(15 dup (?)) 
tMatr dw 15 dup(15 dup(?))
maxMatr dw 15 dup(15 dup(?))
row dw ?
col dw ?
col2 dw ?
trow dw ?
tcol dw ?
flag1 dw ?
tab db '	$'
endl db 0Dh, 0Ah, '$'
buffer db ?
sTask1 db '      Transpose matrix: $'
sMatr db 'Matrix: $'
sTask2A db 'Summa(po strokam): $'
sTask2B db 'Negative max el in row: $'
sMenu db '1. Enter matrix', 0Dh, 0Ah, '2. Print matrix', 0Dh, 0Ah, '3. Transpose matrix', 0Dh, 0Ah, '4. Sum after negative', 0Dh, 0Ah, '5. Compare rows', 0Dh, 0Ah, '6. Replace max with negative', 0Dh, 0Ah,'0. Exit', 0Dh, 0Ah, '$'
sChoose db 'Enter your choice: $'
sError db 'Invalid choice! Try again. $'
sRowsEqual db 'Rows equal $'
sRowsNotEqual db 'Rows not equal $'
sInputMatr db 'Enter Matr $'
sInputR db 'Enter number of rows: $'
sInputC db "Enter number of cols: $"
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
    sub ax, 1
    mov col2, ax
    mov trow, ax
    xor ax, ax
    printstr sInputMatr
    printstr endl
    mReadMatrix matr, row, col, maxMatr

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
    je taskCompareRows
    cmp ax, 6
    je taskReplaceMax
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
    sub ax, 1
    mov col2, ax
    mov trow, ax
    xor ax, ax
    printstr sInputMatr
    printstr endl
    mReadMatrix matr, row, col, maxMatr
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

    ;mCopyMatrix matr, matr1, row, col
int 3h
    mTask4 matr, row, col, flag1, matr1, col2

    mWriteMatrix matr1, row, col2
    pause
    jmp menuLoop
taskCompareRows:
    printstr endl
    mWriteMatrix matr, row, col
    printstr endl
    printstr endl
    mCompareRows matr, row, col
    pause
    jmp menuLoop
taskReplaceMax:
    printstr endl
    mWriteMatrix matr, row, col
    printstr endl

    printstr sTask2B
    printstr endl
    mReplaceMaxNeg maxMatr, row, col
    mWriteMatrix maxMatr, row, col
    pause
    jmp menuLoop
exitProgram:
NOJUMPS
    mov ax, 4c00h
    int 21h
end start
