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

printstr macro msg
	push ax
	push dx

	mov ah, 09h
	mov dx, msg
	int 21h

	pop dx
	pop ax
endm

.model small
.stack 100h
.data
message_1 db 'Hard is the first step', '$'
message_2 db 'Varro, Mark Terence $'
message_3 db '116-27 years. BC $'
surname_1 db 'Sakhabiev S.O. $'
group_1 db 'IUK4-32B $'
facult_1 db 'IUK $'
sign_1 db '!!!! $'
.code
start:
	mov ax, @data
	mov ds, ax

	mov ax, 0600h 
	mov bh, 15h ; cиний фон - 1, фиол буквы - 5
	mov cx, 0
	mov dx, 184fh
	int 10h
	
	setcursor 2, 10, 24, 0
	mov bx, offset message_1
	printstr bx

	setcursor 2, 11, 24, 0
	mov bx, offset message_2
	printstr bx

	setcursor 2, 12, 24, 0
	mov bx, offset message_3
	printstr bx
	
	
	setcursor 2, 0, 72, 0
	mov bx, offset group_1
	printstr bx

	setcursor 2, 23, 76, 0
	mov bx, offset facult_1
	printstr bx

	setcursor 2, 0, 0, 0
	mov bx, offset surname_1
	printstr bx

	setcursor 2, 23, 0, 0
	mov bx, offset sign_1
	printstr bx

	mov ah, 7h
	int 21h

	mov ax, 4c00h
	int 21h
end start