.model small
.stack 100h
.data
A db ?
B db ?
C db ?
D db ?
.code
start:
	mov ax, @data
	mov dx, ax

	mov A, 7h
	mov B, 12
	mov C, 1Dh
	mov D, 9

	mov al, A
	mov ah, B
	xchg al, ah
	mov bx, 3E10h
	mov cx, bx

	push bx
	push cx
	push ax

	lea si, C
	mov ax, si

	lea di, D
	mov bx, di

	pop ax
	pop cx
	pop bx

	mov A, al
	mov B, ah
	mov C, 0

	mov ax, 4c00h
	int 21h
end start
end
