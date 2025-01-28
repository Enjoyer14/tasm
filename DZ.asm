mPrintStr macro msg
    push ax               ; ��������� �������� AX � DX
    push dx
    lea dx, msg           ; ��������� ����� ������ � DX
    mov ah, 09h           ; ������� DOS ��� ������ ������
    int 21h               ; ����� DOS-����������
    pop dx                ; ��������������� �������� DX � AX
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
    push ax      ; ���������� ���������, ������������ � �������, � ���� 
    push bx 
    push cx 
    push dx 
    push di 
 
    mov cx, 10   ; cx - ��������� ������� ��������� 
    xor di, di   ; di - ���������� ���� � ����� 
 
    or ax, ax    ; ���������, ����� �� ����� � ax ���� � ������������� ����� 
    jns convert  ; ������� � ���������������, ���� ����� � ax ������������� 
          
    push ax 
 
    mov dx, '-' 
    mov ah, 02h  ; 02h - ������� ������ ������� �� ����� 
    int 21h      ; ����� ������� "-" 
 
    pop ax      
    neg ax       ; ����������� ������������� ����� 
     
convert:   
    xor dx, dx 
 
    div cx       ; ����� ������� dl = ������� �� ������� ax �� cx 
    add dl, '0'  ; ������� � ���������� ������ 
    inc di       ; ����������� ���������� ���� � ����� �� 1   
 
    push dx      ; ���������� � ���� 
 
    or ax, ax    ; ���������, ����� �� ����� � ax ���� � ������������� ����� 
    jnz convert  ; ������� � ���������������, ���� ����� � ax �� ����� ����  
 
write:           ; ����� �������� �� ����� �� ����� 
    pop dx       ; dl = ��������� ������ 
 
    mov ah, 02h 
    int 21h      ; ����� ���������� ������� 
    dec di       ; ���������, ���� di <> 0 
    jnz write   
 
; ������� ����������� �������� ������� � ��������  
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
JUMPS             ; ���������, �������� ��������� ������� ������ 
    push bx       ; ���������� ���������, ������������ � �������, � ���� 
    push cx 
    push si 
 
    xor bx, bx    ; �������� �������� �� ������� 
    mov cx, row 
rowLoop:          ; ������� ����, ���������� �� ������� 
    push cx 
 
    xor si, si    ; �������� �������� �� �������� 
    mov cx, col  
colLoop:              ; ���������� ����, ���������� �� �������� 
    mReadAX buffer, 5  ; ������ ����� �������� �������� AX � ����������  
                      ; [���������� 1] 
 
    mov matrix[bx][si], ax 
    add si, 2         ; ��������� � ���������� �������� (�������� � �����) 
    loop colLoop 

    add bx, col       ; ����������� �������� �� �������  
    add bx, col       ; (������, ��� ��� ������ ������� �������� - �����) 
 
    pop cx 
    loop rowLoop 
 
    pop si            ; ������� ����������� �������� ������� � ��������  
    pop cx 
    pop bx 
NOJUMPS               ; ����������� �������� ��������� JUMPS 
endm mReadMatrix 

mWriteMatrix macro matrix, row, col      
local rowLoop, colLoop  
    push ax       ; ���������� ���������, ������������ � �������, � ���� 
    push bx 
    push cx 
    push si 
 
    xor bx, bx    ; �������� �������� �� ������� 
    mov cx, row 
rowLoop:          ; ������� ����, ���������� �� ������� 
    push cx  
 
    xor si, si    ; �������� �������� �� �������� 
    mov cx, col 
colLoop:                    ; ���������� ����, ���������� �� �������� 
    mov ax, matrix[bx][si]  ; bx - �������� �� �������, si - �� �������� 
 
    mWriteAX      ; ������ ������ �������� �������� AX �� ����� [���������� 2] 
                  ; ����� �������� �������� ������� 
    xor ax, ax 
    mPrintStr tab; ������ ������ ������ �� ����� ���������� 3

    add si, 2         ; ��������� � ���������� �������� (�������� � �����) 
    loop colLoop 
    
    mPrintStr endl   ; ������ ������ ������ �� ����� ���������� 3                ; ������� ������� � ������� �� ��������� ������ 
    
    add bx, col       ; ����������� �������� �� �������  
    add bx, col       ; (������, ��� ��� ������ ������� �������� - �����) 
    pop cx 
    loop rowLoop 
 
    pop si            ; ������� ����������� �������� ������� � ��������  
    pop cx 
    pop bx 
    pop ax 
endm mWriteMatrix 

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

mPrintLine macro matrix, row, col, row_to_print			;������� ������ ������� �� �����
local colLoop
	push ax
	push bx
	push cx
	push si
	xor si, si
	mov cx, col
	mov ax, row_to_print
	;mov bx, col
	;mul bx
	;add ax, ax
	mov bx, row_to_print
	colLoop:
		mov ax, matrix[bx][si]
		mWriteAX
		mPrintStr tab
		add si, 2
		loop colLoop
	mPrintStr endl
	pop si
	pop cx
	pop bx
	pop ax
endm mPrintLine	

mTransposeMatrix macro matrix, row, col, resMatrix    
local rowLoop, colLoop  
    push ax         ; ���������� ���������, ������������ � �������, � ���� 
    push bx 
    push cx 
    push di 
    push si 
    push dx 
 
    xor di, di            ; �������� �������� �� ������� 
    mov cx, row 
rowLoop:                  ; ������� ����, ���������� �� ������� 
    push cx 
    xor si, si            ; �������� �������� �� �������� 
    mov cx, col 
colLoop:                  ; ���������� ����, ���������� �� �������� 
    mov ax, col 
    mul di                ; ������������� �������� �� ������� 
    add ax, si            ; ������������� �������� �� �������� 
    mov bx, ax 
    mov ax, matrix[bx] 
    push ax               ; ������� ������� ������� � ���� 
 
    mov ax, row          
    mul si                ; ������������� �������� �� ������� 
    add ax, di            ; ������������� �������� �� �������� 
                          ;  (�������� �� ������� � �������� ��������      
                          ;   ������� �� ��������� � ������������ ��������) 
    mov bx, ax 
    pop ax 
    mov resMatrix[bx], ax  ; ������� � ����� ������� �������,               
                          ; ����������� � ����� 
    
    add si, 2             ; ��������� � ���������� ��������             
                          ;  (�������� � �����) 
    loop colLoop 
     
    add di, 2             ; ��������� � ��������� ������ 
    pop cx 
    loop rowLoop 
 
    pop dx                ; ������� ����������� �������� ������� � ��������  
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
    mPrintStr endl
    mov ah, 08h
    int 21h
endm

;================zadanie1==============
mTask1 macro matrix, row, col
local outer_loop, inner_loop, skip_increment,m1,m2
JUMPS
    push ax
	push bx
	push cx
	push dx
	push di
	push si

    xor bx, bx    
    xor dx, dx   
    xor si, si  
    mov cx,row
outer_loop:

    push cx
    xor si, si
    xor dx, dx        ; ����� �������� ��������� ��������� ��� �������� �������
    mov cx, col       ; ������������� ���������� ��������
inner_loop:
    ; �������� �������� �������� �������
    mov ax, matrix[bx][si]
    
    ; ���������, �������� �� ������� ���������
    cmp ax, 0
    je skip_increment  ; ���� ������� ����� 0, ���������� ���������

    ; ����������� ������� ��������� ���������
    inc dx

skip_increment:
    xor ax,ax
    add si,2
   
    loop inner_loop    ; ��������� ��� ���� �����

    xor ax,ax
    mov ax, dx         ; ��������� ���������� ��������� ��������� � ax
    mWriteAX
    mPrintStr tab
    xor ax,ax 
    xor dx,dx

    ; ��������� � ���������� �������

    add bx,col             ; ��������� � ��������� ������
    add bx,col
    pop cx
    loop m1     ; ���� ���, ����������
    jmp m2
    m1:
        jmp outer_loop 
    m2:
        pop si
        pop di
        pop dx
        pop cx
        pop bx
        pop ax

endm mTask1

;================zadanie2 (�� �������)==============
mTask2 macro matr, row, col, t2buffer
local loopDiog, itisEqual, nonEqual, endT2
JUMPS
    push ax
    push bx ; смещение по началу в строчку
    push cx
    push dx ; смещение с конца в строку
    push si  ; смещение по началу в столбик
    push di  ; смещение с конца в столбик

    mov cx, row
    mov dx, col
    cmp cx,dx
    jne nonEqual

    mov ax, col
    sub ax, 1d
    mov bx, 2
    mul bx
    mov di, ax ; нашли конечное смещение по столбцам

    mov ax, row
    sub ax, 1d
    mov bx, 2d
    mul bx
    mov bx, col
    mul bx
    mov dx, ax ; конечное смещение по строчкам

    push dx

    xor dx, dx
    mov ax, col
    mov bx, 2d
    div bx
    pop dx

    xor bx, bx       ; Обнулить BX (только после деления)

    int 03h
    mov cx, ax
loopDiog:
    mov ax, matr[bx][si]
    mov t2buffer, ax
    push bx
    push si
    mov bx, dx
    mov si, di
    mov ax, matr[bx][si]
    pop si
    pop bx
    
    cmp ax, t2buffer
    jne nonEqual

    add si, 2
    sub di, 2

    add bx, col
    add bx, col

    sub dx, col
    sub dx, col

    loop loopDiog

itisEqual:
    mPrintStr sSymmetric
    jmp endT2

nonEqual:
    mPrintStr endl
    mPrintStr sNotSymmetric
    mPrintStr endl

endT2:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
NOJUMPS
endm mTask2

;====�� �� �������====
mTask3 macro matrix, row, col, minElem, minIndex
local rowLoop, colLoop, nextRow, rowInnerLoop, nextInnerRow
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
    xor bx, bx    ;сбрасываем смещение по строкам
    mov ax, matr[bx][si]
    mAbs
    mov minElem, ax
    mov minIndex, bx
    mov cx, row
    
rowLoop: 
    mov ax, matr[bx][si]  ; bx - смещение по строкам, si - по столбцам 
    mAbs
    cmp ax, minElem
    jge nextRow  
    mov minElem, ax
    mov minIndex, bx

nextRow:
    add bx, col
    add bx, col
    loop rowLoop

    xor bx, bx
    mov di, 1
    mov cx, row
rowInnerLoop:
    cmp bx, minIndex
    jle nextInnerRow
    mov ax, matr[bx][si]
    imul di
    mov di, ax
nextInnerRow:
    add bx, col
    add bx, col
    loop rowInnerLoop

    mov ax, di
    mWriteAX
    mPrintStr tab

    add si, 2
    pop cx 
    loop colLoop 
    pop si   
    pop di
    pop cx 
    pop bx 
    pop ax 
NOJUMPS
endm mTask3

.model small
.stack 100h
.data
matr dw 15 dup(15 dup (?))
tMatr dw 15 dup(15 dup(?))
matrT2 dw 15 dup(15 dup(?))
diag dw 15 dup(0)
count dw 15 dup(0)
row dw ?
col dw ?
trow dw ?
tcol dw ?
tab db '	$'
endl db 0Dh, 0Ah, '$'
sTask1 db '      Transpose matrix: $'
sMatr db 'Matrix: $'
sMenu db '1. Input matrix', 0Dh, 0Ah, '2. Print matrix', 0Dh, 0Ah, '3. Transpose matrix', 0Dh, 0Ah, '4. Find non-zero elements of each column #1', 0Dh, 0Ah, '5. Check if diagonal is symmetric #2', 0Dh, 0Ah, '6. Find first positive number below diagonal #3', 0Dh, 0Ah,'0. Exit', 0Dh, 0Ah, '$'
sChoose db 'Enter number: $'
sInputR db 'Enter number of rows: $'
sInputC db 'Enter number of cols: $'
sError db 'Incorrect value $'
sInputMatr db 'Enter Matrix: $'
sNotSquare db 'Matrix isnt N*N $'
sNotSymmetric db 'Diagonal isnt symmetric $'
sSymmetric db 'Diagonal symmetric $'
buffer db ?
t2buffer dw ?
minElem dw ?
minIndex dw ?


.code
; ������������ ��� ������ �����
PrintNumber proc
    ; ax �������� �����, ������� ����� �������
    xor cx, cx          ; ������� ����
    mov bx, 10          ; �������� ��� ��������� ����
    cmp ax, 0
    je print_zero       ; ���� ax ����� 0, ��������� � ������ 0

convert_loop:
    xor dx, dx          ; �������� dx ����� ��������
    div bx               ; ����� ax �� 10
    push dx              ; ��������� ������� (�����)
    inc cx               ; ����������� ������� ����
    test ax, ax         ; ���������, �� ���� �� ax
    jnz convert_loop     ; ���� �� ����, ����������

print_loop:
    pop dx               ; �������� ��������� �����
    add dl, '0'          ; ����������� � ������
    mov ah, 02h         ; ������� ������ �������
    int 21h             ; ������� ������
    loop print_loop      ; ��������� ��� ���� ����

    ret
print_zero:
    ; ������� '0', ���� ax ����� 0
    mov dl, '0'
    mov ah, 02h         ; ������� ������ �������
    int 21h             ; ������� ������
    ret
endp PrintNumber 


start:
 mov ax,@data
 mov ds,ax

menuLoop:
    wipescreen
    mPrintStr sMenu
    mPrintStr endl
    mPrintStr sChoose

    mReadAX buffer, 2

    JUMPS
    cmp ax, 1
    je enterMatr
    cmp ax, 2
    je printMatr
    cmp ax, 3
    je taskTranspose
    cmp ax, 4
    je task1
    cmp ax, 5
    je task2
    cmp ax, 6
    je qwezxc
    cmp ax, 0
    je exitProgram
    jmp menuLoop
enterMatr:
    xor ax, ax
    mPrintStr sInputR
    mReadAX buffer, 3
    mov row, ax
    mov tcol, ax
    xor ax, ax
    mPrintStr sInputC
    mReadAX buffer, 3
    mov col, ax
    mov trow, ax
    xor ax, ax
    mPrintStr sInputMatr
    mPrintStr endl
    mReadMatrix matr, row, col
    jmp menuLoop
printMatr:
    mPrintStr endl
    mPrintStr sMatr
    mPrintStr endl
    mWriteMatrix matr, row, col
    mPrintStr endl
    pause
    jmp menuLoop
taskTranspose:
    mPrintStr endl
    mWriteMatrix matr, row, col
    mPrintStr endl

    mPrintStr sTask1
    mPrintStr endl
    mTransposeMatrix matr, row, col, tMatr
    mWriteMatrix tMatr, trow, tcol
    pause
    jmp menuLoop

task1:
    mPrintStr endl
    mWriteMatrix matr, row, col
    mPrintStr endl
    mTransposeMatrix matr, row, col, tMatr
    mTask1 tmatr, row, col
    mPrintStr endl
    pause
    jmp menuLoop

task2:
    mPrintStr endl
    mWriteMatrix matr, row, col
    mPrintStr endl

    mTask2 matr, row, col, t2buffer

    mPrintStr endl
    pause
    jmp menuLoop
qwezxc:
    mPrintStr endl
    mWriteMatrix matr, row, col
    mPrintStr endl
    mTask3 matr, row, col, minElem, minIndex
    mPrintStr endl
    pause
    jmp menuLoop


exitProgram:
NOJUMPS
    mov ax, 4c00h
    int 21h

end start