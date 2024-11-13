.model small
.stack 100h
.data
A db -4d
B db -15d
C db -8d
D db -20d

res1 dw ?
res2 dw ?
.code
start:
	mov ax, @data
	mov ds, ax

	;y = (15-b)*c + a
	mov bl, [B]
	mov al, 15d
	sub al, bl

	imul C ; ax = ax*C
	
	mov bl, [A]
	add al, bl

	mov [res1], ax
	
	;y = ((13*a-b)/c)+a
	mov bl, 13d
	mov al, [A]
	imul bl ; 13*A
	
	mov bl, [B]
	sub al, bl ; al - B

	mov bl, [C]
	idiv bl
	
	add al, [A]
	
	mov [res2], ax 

	mov ax, 4c00h
	int 21h
end start
end