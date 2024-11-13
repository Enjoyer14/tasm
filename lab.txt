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
	
	mov ah, 2   ; установка курсора
	mov dh, 10   ; строка
	mov dl, 24  ; столбец
	mov bh, 0   ; страница
	int 10h

	mov ah, 09h
	mov dx, offset message_1
	int 21h

	mov ah, 2
	mov dh, 11
	mov dl, 24
	mov bh, 0
	int 10h

	mov ah, 09h
	mov dx, offset message_2
	int 21h

	mov ah, 2
	mov dh, 12
	mov dl, 24
	mov bh, 0
	int 10h

	mov ah, 09h
	mov dx, offset message_3
	int 21h
	

	mov ah, 2 ; курсор для группы
	mov dh, 0
	mov dl, 72
	mov bh, 0
	int 10h

	mov ah, 09h
	mov dx, offset group_1
	int 21h

	mov ah, 2 ; курсор для факультета
	mov dh, 23
	mov dl, 76
	mov bh, 0
	int 10h

	mov ah, 09h
	mov dx, offset facult_1
	int 21h

	mov ah, 2 ; курсор для имени
	mov dh, 0
	mov dl, 0
	mov bh, 0
	int 10h

	mov ah, 09h
	mov dx, offset surname_1
	int 21h

	mov ah, 2 ; курсор для !
	mov dh, 23
	mov dl, 0
	mov bh, 0
	int 10h
	
	mov ah, 09h
	mov dx, offset sign_1
	int 21h

	mov ah, 7h
	int 21h

	mov ax, 4c00h
	int 21h
end start