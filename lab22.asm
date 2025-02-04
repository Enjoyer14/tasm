.model small
.stack 200h
.data
den db 14d
qwer dw 4321h
mes dw 1d

mas_1 db 14d dup(19)

mas_2 dw 4*5 dup(?)

stroka db 'Sahabiev', '$'
.code
start:
	mov ax, @data ; инициализация сегмента данных
	mov dx, ax

	mov di, 7D5h ; 7D5h = 2005d, загружаем его в di
	mov al, den ; загружаем den в регистр al
	mov cx, mes ; загружаем mes в регистр cx

	mov den, cx
	mov mes, al

	mov ax, mes ; загружаем mes в регистр es через промежуточный регистр
	mov es, ax ; т.к. в es напрямую нельзя
	
	push ax ; загружаем в стек al(den)
	push cx ; загружаем в стек cx(mes)

	mov ax, qwer ; Используем промежуточный регистр для обмена
	xchg ax, mes
	mov qwer, ax

	mov si, offset den ; помещаем в si адрес den

	pop dx ; вытаскиваем из стека LIFO то есть здесь сейчас mes
	pop cx ; а тут den
	
	mov ah, 09h
	mov dx, offset stroka
	int 21h

	mov ax, 4c00h
	int 21h
end start
end
