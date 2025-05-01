.model small
.stack 100h
.data
	CR = 0Dh
	LF = 0Ah
	FileName db "sentence.txt0", "$"
	FDescr dw ?
	NewFile db "newfile.txt0", "$"
	FDescrNew dw ?
	Buffer dw ?
	Text db 1000 dup(0)
	String db 1000 dup(0)
	Bufstr db 1000 dup(0)
	len dw 0
	prString dw ?
	temp dw 0
	index dw 0
	rb dw 0
	re dw 0
	n dw 2
	empty_line db 10, '$'
	MessageError1 db CR, LF, "File was not opened !", 10, "$"
	MessageError2 db CR, LF, "File was not read !", 10, "$"
	MessageError3 db CR, LF, "File was not founded!", 10, "$"
	MessageError4 db CR, LF, "File was not created!", 10, "$"
	MessageError5 db CR, LF, "Error in writing in the file!", 10, "$"
	MessageEnd db CR, LF, "Program was successfully finished!", 10, "$"
.code
JUMPS

print_string macro
	mov ah, 09h
	int 21h
endm

mWriteAx macro
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

start:
	mov ax, @data
	mov ds, ax
	mov es, ax
	mov ah, 3Dh
	xor al, al
	mov dx, offset FileName
	xor cx, cx
	int 21h
	mov FDescr, ax 
	jnc M1 
	jmp Er1 

M1:
	mov ah, 3ch
	xor cx, cx
	mov dx, offset NewFile 
	int 21h 
	mov FDescrNew, ax 
	jnc M2
	jmp Er3 
M2:
	mov ah, 3fh
	mov bx, FDescr
	mov cx, 1
	mov dx, offset Buffer
	int 21h
	jnc M3
	jmp Er2
 M3:
	cmp ax, 0
	je M4
	mov ax, Buffer
	mov bx, index
	mov Text[bx], al
	inc bx
	mov index, bx
	jmp M2
M4:
	cld
	mov di, offset Text
	add di, index
	mov al, LF
	stosb
	mov al, '$'
	stosb

	xor di, di
	xor si, si
	xor bx, bx
	mov bx, 0001h
	mov si, offset Text
	mov di, offset String
	xor ah, ah

	reading_string:
		cld
		lodsb
		cmp al, LF
		je processing
		cmp al, '$'
		je M5
		stosb
		inc ah
		jmp reading_string

	processing:
		mov al, 10
		stosb
		mov al, '$'
		stosb

		push di
		push si
		push ax
		push bx

		mov si, offset String
		mov di, offset Bufstr
		cld
		mov cl, ah
		
		int 03h
		xor ah, ah
		cloop:
			lodsb
			cmp al, 65 
			jl not_letter
			jmp skip
			not_letter:
				mov al, ' '
				jmp skip
			skip:
			stosb
		loop cloop

		mov al, 10
		stosb
		mov al, '$'
		stosb
		pop bx
		pop ax

		mov cx, index
		mov di, offset String
		mov si, offset Bufstr
			
		rep movsb

		pop si
		pop di

		lea dx, String
		print_string

		mov ah, 07h
		int 21h

		jmp wrt

	wrt:
		xor dx, dx
		xor ax, ax
		push bx
		mov ah, 40h
		mov bx, FDescrNew

		push di
		mov cx,0FFFFh
		mov al, '$'
		lea di, String
		repne scasb
		not cx
		dec cx
		pop di

		xor al, al

		mov dx, offset String
		int 21h
		pop bx
		
		mov di, offset String
		jmp reading_string

		jnc M5
		jmp Er4
M5:
	mov ah, 3eh
	mov bx, FDescr
	int 21h
	mov ah, 3eh
	mov bx, FDescrNew
	int 21h
	mov dx, offset MessageEnd
	print_string
	jmp Exit 

Er1:
	cmp ax, 02h
	jne M6
	lea dx, MessageError3
	print_string
	jmp Exit

M6:
	lea dx, MessageError1
	print_string
	jmp Exit

Er2:
	lea dx, MessageError2
	print_string
	jmp Exit

Er3:
	lea dx, MessageError4
	print_string
	jmp Exit

Er4:
	lea dx, MessageError5
	print_string
	jmp Exit

Exit:
	mov ah, 07h
	int 21h

	mov ax, 4c00h
	int 21h

end start