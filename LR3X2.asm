.model small
.stack 100h
.data
X1 db 59
X2 db 8Dh
X3 db 245
A db 44
B db 29h
C db 7
D db 3

Sum db 0
Raz db 0
Pr dw 1
Ost db ?
Chas db ?

.code
start:
	mov ax, @data
	mov ds, ax

	;X3
	mov ax, 0
	mov al, X3 ;заносим значение Х1 в al 
	sub al, A ; al = al(X1) - A
	mov Raz, al ; заносим ответ в Raz
	
	add al, B ; al = al + B
	mov Sum, al 

	mov bl, C ; Загружаем C в BL
	mul bl
	mov Pr, ax
	
	xor dx, dx
	xor ax, ax
	mov ax, Pr
	mov bl, D
	div bx ; ax = ax/D
	mov Chas, al ; результат деления в ax, в al - целая часть , в ah - остаток от деления
	mov Ost, dl

	inc al ; al++
	dec ah ; ah--


	mov ax, 4c00h
	int 21h
end start
end