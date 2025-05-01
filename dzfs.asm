	JUMPS
	get_min macro val1, val2, res						;минимальное из двух в третью переменную - res
	local c1, c2, fnsh
		push ax
		mov ax, val1
		cmp ax, val2
		jg c1
		jmp c2
	c1:
		mov ax, val2
		mov res, ax
		jmp fnsh
	c2:
		mov ax, val1
		mov res, ax
		jmp fnsh
	fnsh:
		pop ax
	endm get_min

	clrScr macro						;очистка экрана
		push ax
		push bx
		push cx
		push dx

		mov ax, 0600h
		mov bh, 0Ah				;тут с цветом играться можно, меняй bx и подбери нравящийся цвет
		mov cx, 0000
		mov dx, 184Fh
		int 10h
	
		pop dx
		pop cx
		pop bx
		pop ax
	endm clrScr 

	selCLR macro				;очистка куска под выбором, в целом не особо нужная штука но я так хочу
		push ax
		push bx
		push dx
		push cx
		mov ax, 0600h
		mov bh, 0Ah				;если цвет менять, то тут тоже
		mov cx, 1000h
		mov dx, 184fh
		int 10h
		pop cx
		pop dx
		pop bx
		pop ax
	endm selCLR

	mWriteStr MACRO string			печать строки
		push ax
		push dx
		
		mov ah, 09h
		mov dx, offset string
		int 21h

		pop dx
		pop ax
	ENDM mWriteStr 

	mSetPos macro row, column		;курсор в позицию поставить
		push ax
		push bx
		push dx
		mov ah, 02h
		mov dh, row
		mov dl, column
		mov bh, 0h
		int 10h
		pop dx
		pop bx
		pop ax
	ENDM mSetPos

	mReadAX macro buffer, size				;считать с консоли в ax, макрос из методички
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
			mov dl, 0ah
			int 21

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
						
	endm mReadVal

	mWriteAX macro				;вывести ах в консоль, тоже  с методички
		local convert, write
		push ax
		push bx
		push cx
		push dx
		push di
		
		mov cx, 10
		xor di, di
		
		or ax, ax
		jns convert

		push ax
		mov dx, '-'
		mov ah, 02h
		int 21h

		pop ax
		neg ax
		
		convert:
			xor dx, dx
			div cx
			add dl, '0'
			inc di
			
			push dx
			
			or ax, ax
			jnz convert
			
		write:
			pop dx
			
			mov ah, 02h
			int 21h
			dec di
			jnz write
			
			pop di
			pop dx
			pop cx
			pop bx
			pop ax
	endm mWriteAx

	mReadMatrix macro matrix, row, col, endl, buffer		;считать матрицу с консоли - методичка
	local rowLoop, colLoop
		push bx
		push cx
		push si
		xor bx, bx
		mov cx, row

		rowLoop:
			push cx
			xor si, si
			mov cx, col

		colLoop:
			mReadAX buffer, 6
			mov matrix[bx][si], ax
			add si, 2
			mWriteStr endl
			loop colLoop

			add bx, col
			add bx, col
			pop cx
			loop rowLoop
			pop si
			pop cx
			pop bx
	endm mReadMatrix

	mWriteMatrix macro matrix, row, col, tab, endl			;вывести в консоль - методичка
		local rowLoop, colLoop
		push ax
		push bx
		push cx
		push si

		xor bx, bx
		mov cx, row
		rowLoop:
		push cx

		xor si, si
		mov cx, col
		colLoop:
		mov ax, matrix[bx][si]

		mWriteAX
		xor ax, ax
		mWriteStr tab

		add si, 2
		loop colLoop

		mWriteStr endl
		add bx, col
		add bx, col
		pop cx
		loop rowLoop

		pop si
		pop cx
		pop bx
		pop ax
	endm mWriteMatrix

	mTransposeMatrix macro matrix, row, col, resMatrix		;транспонирование матрицы 
		local rowLoop, colLoop
		push ax
		push bx
		push cx
		push di
		push si
		push dx

		xor di, di
		mov cx, row
		rowLoop:
		push cx
		xor si, si
		mov cx, col
		colLoop:
		mov ax, col
		mul di
		add ax, si
		mov bx, ax
		mov ax, matrix[bx]
		push ax

		mov ax, row
		mul si
		add ax, di

		mov bx, ax
		pop ax
		mov resMatrix[bx], ax

		add si, 2

		loop colLoop

		add di, 2
		pop cx
		loop rowLoop

		pop dx
		pop si
		pop di
		pop cx
		pop bx
		pop ax
	endm mTransposeMatrix

mCheck macro min, max, num, cnt
	push ax
	mov ax, num
	cmp ax, min
	jl exit
	cmp ax, max
	jg exit
	mov ax, cnt
	inc ax
	mov cnt, ax
	exit:
		pop ax
endm mCheck
mTask1 macro matrix, row, col, min, max, cnt, tab
local colLoop, rowLoop
	push ax
	push bx
	push cx
	push di
	push si
	mov cx, col
	xor bx, bx
	xor si, si
	colLoop:
		push cx
		mov cx, row
		
		rowLoop:
			mov ax, matrix[bx][si]
			mCheck min, max, ax, cnt
			add bx, col
			add bx, col
			loop rowLoop
		pop cx
		mov ax, cnt
		mWriteAX
		mWriteSrt tab
		xor bx, bx
		add si, 2
		loop colLoop
	
	pop si
	pop di
	pop cx
	pop bx
	pop ax
endm mTask1

mCheckZeroLine macro matrix, rowToCheck, col, zero, flag
local colLoop, exit, setflag
	push ax
	push bx
	push cx
	push si
	mov cx, col
	mov bx, rowToCheck
	mul bx, col
	add bx, bx
	colLoop:
		mov ax, matrix[bx][si]
		cmp col, zero
		jne setflag
		add si, 2
		loop colLoop
	jmp exit
	setflag:
		mov ax, 1
		mov flag, ax
		jmp exit
	exit:
		pop si
		pop cx
		pop bx
		pop ax
endm mCheckZeroLine
	
mTask2 macro matrix, row, col, avg, sum, zero, flag, rowId, tab, endl
local rowLoop, colLoop, nextIter
	push ax
	push bx
	push cx
	push si
	mov cx, row
	xor bx, bx
	xor si, si
	rowLoop:
		
		push cx
		xor ax, ax
		mov flag, ax
		mov rowId, bx
		mCheckZeroLine matrix, rowId, col, zero, flag
		mov ax, flag
		cmp zero
		jne nextIter
		mov cx, col
		colLoop:
			mov ax, matrix[bx][si]
			add sum, ax
			add si, 2
			loop colLoop
		mov cx, row
		mov ax, sum
		idiv col
		mWriteAX
		mWriteStr tab
		mPrintLine matrix, row, col, rowId, tab, endl
		nextIter:
			pop cx
			add bx, col
			add bx, col
			loop rowLoop
	pop si
	pop cx
	pop bx
	pop ax
endm mTask2

mTask3 macro matrix, row, col, tab, endl
local rowLoop, colLoop, nextIter, found
	push ax
	push bx
	push cx
	push dx
	push si
	xor dx, dx
	xor bx, bx
	xor si, si
	mov cx, row
	rowLoop:
		push cx
		xor si, si
		mov cx, col
		colLoop:
			cmp bx, si
			jbe nextIter
			mov ax, matrix[bx][si]
			cmp ax, 0
			jg found
			jmp nextIter
		nextIter:
			add si,2
			loop colLoop
		pop cx
		add bx, col
		add bx, col
		loop rowLoop
	found:
		mWriteAX
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
			
endm mTask3
			
		
		



mPrintLine macro matrix, row, col, row_to_print, tab, endl			;вывести строку матрицы на экран
local colLoop
	push ax
	push bx
	push cx
	push si
	xor si, si
	mov cx, col
	mov ax, row_to_print
	mov bx, col
	mul bx
	add ax, ax
	mov bx, ax
	colLoop:
		mov ax, matrix[bx][si]
		mWriteAX
		mWriteStr tab
		add si, 2
		loop colLoop
	mWriteStr endl
	pop si
	pop cx
	pop bx
	pop ax
endm mPrintLine	
		

	
.model small
.stack 100h
.data
	buffer db 6 dup (?)

	line db 'Row number $'
	line2 db ': $' 

	max dw (?)
	min dw (?)
	minId dw (?)
	maxId dw (?)
	matrix dw 256 dup (?)
	matrix_1 dw 256 dup (?)
	matrix_2 dw 256 dup (?)

	sortedLine dw 20 dup (?)
	lineId dw (?)
	tempLine dw 20 dup (?)

	menu1 db '1 - Input matrix', 13, 10, '$'
	menu2 db '2 - Print matrix', 13, 10, '$'
	menu3 db '3 - Matrix transposition', 13, 10, '$'
	menu4 db '4 - Task A', 13, 10, '$' 
	menu5 db '5 - Task B', 13, 10, '$' 
	menu6 db '6 - Task C', 13, 10, '$' 
	menu8 db '0 - Exit', 13, 10, '$'
	select db 10, 'Select ->', '$'

	line_to_sort db 'Input number of row to sort: $'
	
	row_req db 'Enter num of rows: ', '$'
	col_req db 'Enter num of columns: ', '$'
	matrix_req db 'Enter matrix elements (element by element): ', '$'
	vector_req db 'Enter vector elements (element by element): ', '$'

	PAK db 'Press any key', '$'
	ENVE db 'Entered negative num exception', '$'
	MNE db 'Matrix not exist' , '$'
	not_err db 'Inputed value is invalid', '$'

	separator db 70 dup('='), '$'

	endl db 13, 10, '$'
	tab db '	', '$'

	sorted_line db 'Sorted line: $'
	cnt dw ?
	row dw 0
	col dw 0
	min_row_col dw 0

	temp dw (?)

	in_select dw ?
	inpMinS 'Input min num: '
	inpMaxS 'Input max num: '
	nclr db 1

.code
	start:
		mov ax, @data
		mov ds, ax
		xor ax, ax 

		cmp nclr, al
		jnz clr
		jmp get_menu

		clr:
			clrScr
			mov nclr, al
			jmp start

		get_menu:
			mSetPos 0007h, 0020h		;вывод меню
			mWriteStr menu1

			mSetPos 0008h, 0020h
			mWriteStr menu2

			mSetPos 0009h, 0020h
			mWriteStr menu3

			mSetPos 000ah, 0020h
			mWriteStr menu4

			mSetPos 000bh, 0020h
			mWriteStr menu5

			mSetPos 000ch, 0020h
			mWriteStr menu6

			mSetPos 000dh, 0020h
			mWriteStr menu8
	
		select_loop:				;ввод и выбор

			mSetPos 000fh, 0023h
			mWriteStr select
		
			mReadAx buffer, 6
			mov in_select, ax
		
			cmp in_select, 1
			je c1
			cmp in_select, 2
			je c2
			cmp in_select, 3
			je c3
			cmp in_select, 4
			je c4
			cmp in_select, 5
			je c5
			cmp in_select, 6
			je c6
			cmp in_select, 0
			je exit

			jmp alert

		alert:				;если число неверное ввели
			selCLR
			mSetPos 0011h, 0000h
			mWriteStr not_err
			jmp select_loop

		
			

		c1:				;если ввод матрицы
			clrScr
			mSetPos 0000h, 0000h
			mWriteStr row_req
			mReadAx buffer, 6
			mov row, ax
			cmp row, 0
			jle c1_recall

			mSetPos 0001h, 0000h
			mWriteStr col_req
			mReadAx buffer, 6
			mov col, ax
			cmp col, 0
			jle c1_recall

			get_min row, col, min_row_col

			mSetPos 0002h, 0000h
			mWriteStr matrix_req
			mSetPos 0003h, 0000h

			mReadMatrix matrix, row, col, endl, buffer

			clrScr
			mSetPos 000fh, 0000h
			jmp start

		c1_recall:				;если в размере матрицы числа <=0
			clrScr
			mSetPos 0000h, 0000h
			mWriteStr ENVE
			mSetPos 0001h, 0000h
			mWriteStr PAK
			mov ah, 01h
			int 21h
			clrScr
			jmp c1

		c2:				;вывод матрицы
			cmp row, 0
			je mne_alert

			clrScr
			mov bx, 0000h
			mSetPos bh, 0000h
			mWriteMatrix matrix, row, col, tab, endl
			add bx, row 
			mSetPos bl, 0000h
			mWriteStr PAK
			mov ah, 01h
			int 21h
			clrScr
			jmp start

		c3:				;транспонирование
			cmp row, 0
			je mne_alert

			clrScr
			mov bx, 0000h
			mSetPos bh, 0000h
			mWriteMatrix matrix, row, col, tab, endl
			add bx, row 
			mSetPos bl, 0000h
			mWriteStr separator
			mTransposeMatrix matrix, row, col, matrix_1
			inc bx
			mSetPos bl, 0000h
			mWriteMatrix matrix_1, col, row, tab, endl
			add bx, col
			mSetPos bl, 0000h
			mWriteStr PAK
			xor bx, bx
			mov ah, 01h
			int 21h
			clrScr
			jmp start

		c4:					;задание 1(А)
			cmp row, 0
			je mne_alert
			clrScr
			mov bh, 0000h
			mSetPos bh, 0000h
			mWriteStr inpMinS
			mReadAX buffer, 3
			mWriteStr endl
			mWriteStr inpMaxS
			mReadAX buffer, 3
			clrScr
			mov bx, 0000h
			mSetPos bh, 0000h
			mWriteMatrix matrix, row, col, tab, endl
			add bx, row 
			mSetPos bl, 0000h
			inc bx
			mSetPos bl, 0000h
			mWriteStr separator
			inc bx
			mSetPos bl, 0000h
			mTask1 macro matrix, row, col, min, max, cnt, tab;task1 matrix, row, col, max, tab
			add bx, row
			mSetPos bl, 0000h
			mWriteStr PAK
			xor bx, bx
			mov ah, 01h
			int 21h
			clrScr
			mSetPos 000fh, 0000h
			jmp start

		c6:					;задание 3(В)
			cmp row, 0
			je mne_alert
			clrScr
			mSetPos 0008h, 0010h
			mWriteStr line_to_sort
			mReadAX buffer, 3
			cmp ax, row
			jg invalid
			cmp ax, 0
			jle invalid
			
			mov lineId, ax
			clrScr
			mov bx, 0000h
			mSetPos bh, 0000h
			mWriteMatrix matrix, row, col, tab, endl
			add bx, row 
			mSetPos bl, 0000h
			mWriteStr separator
			inc bx
			mSetPos bl, 0000h
			mWriteStr sorted_line
			mWriteStr endl
			task3 matrix, row, col, sortedLine, lineId, tempLine, tab, endl, min
			mWriteStr PAK
			xor bx, bx
			mov ah, 01h
			int 21h
			clrScr
			jmp start

		invalid:				;если в 6 выбрали строку неподходящую
			clrScr
			mSetPos 0011h, 0000h
			mWriteStr not_err
			mWriteStr endl
			mWriteStr PAK
			mov ah, 01h
			int 21h
			jmp c6
		c5:					;задание 2(Б)
			clrScr
			mov bx, 0000h
			mSetPos bh, 0000h
			mWriteMatrix matrix, row, col, tab, endl
			add bx, row 
			mSetPos bl, 0000h
			mWriteStr separator
			inc bx
			mSetPos bl, 0000h
			task2 matrix, row, col, max, min, minId, maxId, tab, endl, temp, line, line2
			add bx, row
			mWriteStr endl;mSetPos bl, 0000h
			mWriteStr PAK
			xor bx, bx
			mov ah, 01h
			int 21h
			clrScr
			mSetPos 000fh, 0000h
			jmp start



		mne_alert:		;если матрица не существует
			clrScr
			mSetPos 0011h, 0000h
			mWriteStr MNE
			jmp start
		exit:				;если выход
			mov ax, 4c00h
			int 21h


NOJUMPS
end start
end