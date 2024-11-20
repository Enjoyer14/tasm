.model small
.stack 100h
.data

a db 01001101b

.code
start:
	mov ax, @data
	mov ds, ax

    ;Task1
    xor ax, ax ; очищаем ax
	mov al, 8Fh ; заносим число 8F в al
    
    shr al, 3 ; сдвигаем al вправо на 3

    and al, 3Ch ; al = al and 3Ch

    mov bl, 60 ; заносим 60 в bl
    not bl   ; инвертируем
    xor al, bl ; al^bl

    ;Task 2
    
    mov al, a ; заносим двоичное число в al
    and al, 28d ; логические умножаем al на 28
    not al ; инвертируем результат
    shl al, 2 ; 2 сдвига влево (умножение на 4)
    xor al, 00011100b ; инвертируем по маске значения 4, 5, 6 разряда


	mov ax, 4c00h
	int 21h
end start