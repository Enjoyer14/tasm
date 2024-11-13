.model small
.stack 100h
.data
X1 db 59
X2 db 8Dh
X3 db 245
A db 44
B db 29h
C db 7
D db 3d

Sum db 0
Raz db 0
Pr dw 1
Ost db ?
Chas db ?

.code
start:
	mov ax, @data
	mov ds, ax

	;X1
	mov ax, 0000
	mov al, X1 ;заносим значение Х1 в al 
	sub al, A ; al = al(X1) - A
	mov Raz, al ; заносим ответ в Raz
	
	add al, B ; al = al + B
	mov Sum, al 

	mul C ; ax = ax*C
	mov Pr, ax
	
	div D ; ax = ax/D
	mov Chas, al ; результат деления в ax, в al - целая часть , в ah - остаток от деления
	mov Ost, ah 

	inc al ; al++
	dec ah ; ah--

	;X2
	mov ax, 0
	mov al, X2 ;заносим значение Х1 в al 
	sub al, A ; al = al(X1) - A
	mov Raz, al ; заносим ответ в Raz
	
	add al, B ; al = al + B
	mov Sum, al 

	mov bl, C ; Загружаем C в BL
	mul bl ; AX = AX * BL
	mov Pr, ax        

	;div D   ; Делим AX на D
	mov Chas, al ; Сохраняем целую часть в Chas
	mov Ost, ah  ; Сохраняем остаток в Ost

	inc ax ; al++
	dec ah ; ah--

	;X3
	mov ax, 0
	mov al, X3 ;заносим значение Х1 в al 
	sub al, A ; al = al(X1) - A
	mov Raz, al ; заносим ответ в Raz
	
	add al, B ; al = al + B
	mov Sum, al 

	mul C ; ax = ax*C
	mov Pr, ax
	
	mov cl, D
	div cx ; ax = ax/D
	mov Chas, al ; результат деления в ax, в dx - остаток от деления
	mov Ost, dl 

	inc ax ; al++
	dec dl ; ah--


	mov ax, 4c00h
	int 21h
end start
end