.486
.model use16 small
.stack 100h
.data
	b dw 175
	k1 dw 1
	x dw ?
	ang dw 180
	pi dw ?
	y dw ?
	axis dw ?
	k2 dw 20
	two dw 2
	one dw 1
	x_correction dw 319
	y_correction dw 174
	n6 dw 6
	n3 dw 3

	first dd ?
	second dd ?
	third dw ?
.code

start:
JUMPS
	mov ax, @data
	mov ds, ax
	xor ax, ax
	mov al, 10h
	int 10h

	mov ax, 0600h
	mov bh, 15
	mov cx, 0000b
	mov dx, 184Fh
	int 10h
	mov ah, 0Ch
	mov al, 10
	mov bh, 0h
	mov cx, 400
metka1:
	push cx
	mov axis, cx
	mov dx, axis
	mov cx, 319
	int 10h
	mov cx, 0
	pop cx
	loop metka1
	mov ah, 0ch
	mov al, 30
	mov cx, 639
	mov bh, 0h
	mov dx, 174
metka2:
	int 10h
	loop metka2
	mov cx, 639
metka3:
	finit
	sub cx, x_correction
	mov x, cx
	add cx, x_correction
	mov ax, cx
	mul k1
	mov cx, ax
	cmp cx, 319
	jl v1
	jmp branch
	v1:
		fild x
		fimul x
		fstp first
		fild x
		fimul x
		fimul x
		fimul x
		fiadd one
		fstp second
		fld first
		fdiv second
		fiadd one
		fstp first
		fld first
		fsqrt
		fimul k2
		fchs
		frndint
		fistp y 
		mov al, 1
		jmp point
	branch:
		cmp cx, 350
		jl v2
		jmp v3
	v2:
		fldpi
		fistp pi
		fild x
		fimul pi
		fidiv ang
		fsin
		fst first
		fmul first
		fmul first
		fimul two
		fimul k2
		fchs
		frndint
		fistp y 
		mov al, 0
		jmp point
	v3:
		fldpi
		fistp pi
		fild x
		fimul pi
		fidiv ang
		fimul n6
		fcos
		fimul two
		fabs
		fsqrt
		fiadd one
		fsqrt
		fimul k2
		fchs
		frndint
		fistp y 
		mov al, 3
		jmp point

	point:
		mov ah, 0ch
		mov bh, 0h
		mov dx, y
		add dx, y_correction
		int 10h
		pusha
            mov  si, 1
            mov  ah, 0
            int  1ah
            mov  bx, dx
            add  bx, si
		; delay_loop:
        ;     int  1ah
        ;     cmp  dx, bx
        ;     jne  delay_loop
		popa
		jmp fnsh_iter
	fnsh_iter:
		loop metka3
fnsh:
	mov ah, 8h
	int 21h
	mov ax, 4c00h
	int 21h
end start
end