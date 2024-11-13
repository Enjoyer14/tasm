.model small
.stack 100h
.data
message_1 db 'My name is Sahabiev Stanislav','$'
message_2 db 'My group IUK4 $'
perem_1 db 0ffh
perem_2 dw 3a7fh
perem_3 dd 0f54d567ah
mas db 10 dup (' ')
pole_1 db 5 dup (?)
adr dw perem_3
adr_full dd perem_3
numbers db 11, 34, 56, 23
fin db 'Конец сегмента данных программы $'
.code
start:
	mov ax, @data
	mov ds, ax

	mov ah, 09h
	mov dx, offset message_1
	int 21h 

	mov ah, 09h
	mov dx, offset message_2
	int 21h 

	mov ah, 7h
	int 21h
	mov ax, 4c00h
	int 21h
end start