JUMPS 
 get_min macro val1, val2, res 
 local c1, c2, fnsh 
  push ax 
  mov ax, val1 
  cmp ax, val2 
  jg c1 
  jmp c2 
 c1: 
  mov ax, val2 
  mov res, ax 
  jmp fnsh 
 c2: 
  mov ax, val1 
  mov res, ax 
  jmp fnsh 
 fnsh: 
  pop ax 
 endm get_min 
 
 
 
 mReplace macro src_mas, dest_matrix, start_point, size 
    local rep_loop, end 
  push ax 
  push bx 
  push cx 
  push si 
 
  mov cx, size          
  xor si, si              
  mov bx, start_point   
  cmp size, 0 
  je end 
 
 rep_loop: 
  mov ax, [src_mas + si]  
  mov [dest_matrix + bx], ax  
  add si, 2            
  add bx, 2          
  loop rep_loop 
  jmp end 
 
 end: 
  pop si 
  pop cx 
  pop bx 
  pop ax 
 endm mReplace 
 
 
 
 clrScr macro 
  push ax 
  push bx 
  push cx 
  push dx 
 
  mov ax, 0600h 
      mov bh, 07 
      mov cx, 0 
      mov dx, 184Fh 
 
  int 10h 
  
  pop dx 
  pop cx 
  pop bx 
  pop ax 
 endm clrScr  
 
 outCLR macro 
  push ax 
  push bx 
  push dx 
  push cx 
  mov ax, 0600h 
      mov bh, 07 
      mov cx, 0 
      mov dx, 184Fh 
  int 10h 
  pop cx 
  pop dx 
  pop bx 
  pop ax 
 endm outCLR 
 
 selCLR macro 
  push ax 
  push bx 
  push dx 
  push cx 
  mov ax, 0600h 
      mov bh, 07 
      mov cx, 0 
      mov dx, 184Fh 
  int 10h 
  pop cx 
  pop dx 
  pop bx 
  pop ax 
 endm selCLR 
 
 
 mWriteStr MACRO string 
  push ax 
  push dx 
   
  mov ah, 09h 
  mov dx, offset string 
  int 21h 
 
  pop dx 
  pop ax 
 ENDM mWriteStr  
 
 mSetPos macro row, column 
  push ax 
  push bx 
  push dx 
  mov ah, 02h 
  mov dh, row 
  mov dl, column 
  mov bh, 0h 
  int 10h 
  pop dx 
  pop bx 
  pop ax 
 ENDM mSetPos 
 
 mReadAx macro buffer, size 
  local input, startOfConvert, endOfConvert 
  push bx 
  push cx 
  push dx  
   
  input: 
   mov [buffer], size 
   mov dx, offset [buffer] 
   mov ah, 0Ah 
   int 21h 
    
   mov ah, 02h 
   mov dl, 0Dh 
   int 21h 
   
   mov ah, 02h 
   mov dl, 0ah 
   int 21 
 
   xor ah, ah 
   cmp ah, [buffer][1] 
   jz input 
    
   xor cx, cx 
   mov cl, [buffer][1] 

 
   xor ax, ax 
   xor bx, bx 
   xor dx, dx 
   mov bx, offset [buffer][2] 
 
   cmp [buffer][2], '-' 
   jne startOfConvert 
   inc bx 
   dec cl 
 
  startOfConvert: 
   mov dx, 10 
   mul dx 
   cmp ax, 8000h 
   jae input 
 
   mov dl, [bx] 
   sub dl, '0' 
 
   add ax, dx 
   cmp ax, 8000h 
   jae input 
 
   inc bx 
   loop startOfConvert 
 
   cmp [buffer][2], '-' 
   jne endOfConvert 
   neg ax 
 
  endOfConvert: 
   pop dx 
   pop cx 
   pop bx 
       
 endm mReadVal 
 
 mWriteAx macro 
  local convert, write 
  push ax 
  push bx 
  push cx 
  push dx 
  push di 
   
  mov cx, 10 
  xor di, di 
   
  or ax, ax 
  jns convert 
 
  push ax 
  mov dx, '-' 
 
  mov ah, 02h 
  int 21h 
 
  pop ax 
  neg ax 
   
  convert: 
   xor dx, dx 
   div cx 
   add dl, '0' 
   inc di 
    
   push dx 
    
   or ax, ax 
   jnz convert 
    
  write: 
   pop dx 
    
   mov ah, 02h 
   int 21h 
   dec di 
   jnz write 
    
   pop di 
   pop dx 
   pop cx 
   pop bx 
   pop ax 
 endm mWriteAx 
 
 mReadVector macro vector, row, endl, buffer 
  push bx 
  push cx 
  push si 
  xor si, si 
  mov cx, row 
  entry_loop: 
   mReadAx buffer, 6 
   mov vector[si], ax 
   add si, 2 
   mWriteStr endl 
  loop entry_loop 
  pop si 
  pop cx 
  pop bx 
 endm mReadVector 
 
 mReadMatrix macro matrix, row, col, endl, buffer 
 local rowLoop, colLoop 
  push bx 
  push cx 
 
  push si 
  xor bx, bx 
  mov cx, row 
 
  rowLoop: 
   push cx 
   xor si, si 
   mov cx, col 
 
  colLoop: 
   mReadAX buffer, 6 
   mov matrix[bx][si], ax 
   add si, 2 
   mWriteStr endl 
   loop colLoop 
 
   add bx, col 
   add bx, col 
   pop cx 
   loop rowLoop 
   pop si 
   pop cx 
   pop bx 
 endm mReadMatrix 
 
 mWriteMatrix macro matrix, row, col, tab, endl 
  local rowLoop, colLoop 
  push ax 
  push bx 
  push cx 
  push si 
 
  xor bx, bx 
  mov cx, row 
  rowLoop: 
  push cx 
 
  xor si, si 
  mov cx, col 
  colLoop: 
  mov ax, matrix[bx][si] 
 
  mWriteAX 
  xor ax, ax 
  mWriteStr tab 
 
  add si, 2 
  loop colLoop 
 
  mWriteStr endl 
  add bx, col 
  add bx, col 
  pop cx 
 
  loop rowLoop 
 
  pop si 
  pop cx 
  pop bx 
  pop ax 
 endm mWriteMatrix 
 
 mCopyMatrix macro src, dest, row, col 
  local rowLoop, colLoop 
  push ax 
  push bx 
  push cx 
  push si 
 
  xor bx, bx 
  mov cx, row 
  rowLoop: 
  push cx 
 
  xor si, si 
  mov cx, col 
  colLoop: 
  mov ax, src[bx][si] 
  mov dest[bx][si], ax 
 
  xor ax, ax 
 
  add si, 2 
  loop colLoop 
 
  add bx, col 
  add bx, col 
  pop cx 
  loop rowLoop 
 
  pop si 
  pop cx 
  pop bx 
  pop ax 
 endm mCopyMatrix 
 
 mReplaceZeros macro matrix, row, col, vector, answer 
  local rowLoop, colLoop, repl, next_row 
  mCopyMatrix matrix, answer, row, col 
  push ax 
  push bx 
  push cx 
  push si 
  push dx 
 
  xor bx, bx 
  mov cx, row 

  rowLoop: 
   push cx 
   xor si, si 
   xor ax, ax 
   mov cx, col 
  colLoop: 
   mAbs answer[bx][si], dx 
   add ax, dx 
   add si, 2 
   loop colLoop 
 
   cmp ax, 0 
   je repl 
   jmp next_row 
 
  repl: 
   mReplace vector, answer, bx, col 
    
  next_row: 
   add bx, col 
   add bx, col 
   pop cx 
   loop rowLoop 
 
   pop dx 
   pop si 
   pop cx 
   pop bx 
   pop ax 
 endm mReplaceZeros 
 
 mAbs macro val, dest 
 local c1, fnsh 
  push ax 
  mov ax, val 
  cmp ax, 0 
  jl c1 
  jmp fnsh 
  c1: 
   neg ax 
   jmp fnsh 
  fnsh: 
   mov dest, ax 
   pop ax 
 endm mAbs 
 
 mTransposeMatrix macro matrix, row, col, resMatrix 
  local rowLoop, colLoop 
  push ax 
  push bx 
  push cx 
  push di 
  push si
 
  push dx 
 
  xor di, di 
  mov cx, row 
  rowLoop: 
  push cx 
  xor si, si 
  mov cx, col 
  colLoop: 
  mov ax, col 
  mul di 
  add ax, si 
  mov bx, ax 
  mov ax, matrix[bx] 
  push ax 
 
  mov ax, row 
  mul si 
  add ax, di 
 
  mov bx, ax 
  pop ax 
  mov resMatrix[bx], ax 
 
  add si, 2 
 
  loop colLoop 
 
  add di, 2 
  pop cx 
  loop rowLoop 
 
  pop dx 
  pop si 
  pop di 
  pop cx 
  pop bx 
  pop ax 
 endm mTransposeMatrix 
 
 mTaskA macro matrix, row, col, tab, endl, tempo 
  local rowLoop, colLoop, counter, nextIt 
  push ax 
  push bx 
  push cx 
  push si 
 
  xor bx, bx 
  mov cx, row 
  mWriteStr endl 
 
  rowLoop: 
   push cx 
 
   xor dx, dx 
   xor di, di 
 
   xor si, si 
   mov cx, col 
 
  colLoop: 
   mov ax, matrix[bx][si] 
   cmp ax, tempo 
   jl counter 
   jmp nextIt   
 
   counter: 
    add dx, 1 
 
   nextIt: 
    add si, 2 
    loop colLoop 
   
   push dx 
   push bx 
   xor dx, dx 
   mov ax, bx 
   mov bx, col 
   div bx 
   mov bx, 2 
   div bx 
   inc ax 
   mWriteAX 
   mWriteStr tab 
   pop bx 
   pop dx 
   
  mov ax, dx 
  mWriteAX 
   
  mWriteStr endl 
 
  add bx, col 
  add bx, col 
 
  pop cx 
 
  loop rowLoop 
 
  pop si 
  pop cx 
  pop bx 
  pop ax 
 endm mTaskA 
  
mTaskB macro matrix, row, col, tempo, tab, endl, tempCol, SortCol, min
 local rowLoop, outLoop, inLoop, swap, nextIter 
 push ax 
 push bx 
 push cx 
 push di 
 push si 
  
 mov ax, tempo 
 dec ax 
 mov bx, 2 
 mul bx 
 ;add ax, ax 
 mov bx, ax 
 mov cx, row 
 xor si, si 
 xor di, di 
 xor bx, bx 
 mov si, ax 
    
 rowLoop: 
  mov ax, matrix[bx][si] 
  mov tempCol[di], ax 
   
  add bx, col 
  add bx, col 
  add di, 2 
  loop rowLoop 
 
  
 xor di, di  
 xor si, si 
 mov cx, row 
  
 outLoop: 
  push cx 
  mov cx, row 
  xor si, si 
  mov min, 7FFFh  
  
 inLoop: 
  mov ax, tempCol[si] 
  cmp ax, min 
  jl swap 
  jmp nextIter 
 
 swap: 
  mov ax, min 
  xchg ax, tempCol[si] 
  mov min, ax 
  jmp nextIter 
 
 nextIter: 
  add si, 2 
  loop inLoop 
  mov ax, min 
  mov SortCol[di], ax 
  add di, 2 
  pop cx 
  loop outLoop 
 
 mWriteMatrix SortCol, 1, row, tab, endl 
 mWriteStr endl 
 
 pop si 
 pop di 
 pop cx 
 pop bx 
 pop ax 
endm mTaskB 
 
  
.model small 
.stack 100h 
.data 
 buffer db 6 dup (?) 
 
 matrix dw 256 dup (?) 
 matrix_1 dw 256 dup (?) 
 matrix_2 dw 256 dup (?) 
 tempCol dw 256 dup (?) 
 SortCol dw 256 dup (?) 
 min dw (?) 
 
 clear_matrix_line dw 256 dup (?) 
 
 vector dw 256 dup (?) 
 pos_arr dw 256 dup (?) 
 neg_arr dw 256 dup (?) 
 zero_arr dw 256 dup (?) 
 
 threshold dw (?) 
 tempo dw (?) 
 result dw 256 dup(?) 
 
 menu1 db '1.Input matrix', 13, 10, '$' 
 menu2 db '2.Output matrix', 13, 10, '$' 
 menu3 db '3.Transpose matrix', 13, 10, '$' 
 menu4 db '4.Task 1', 13, 10, '$'  
 menu5 db '5.Task 2', 13, 10, '$'  
 menu6 db '6.Task 3', 13, 10, '$'  
 forTask3 db 'Vvedite stroku(#3)', 13, 10, '$'  
 menu0 db '0.Exit', 13, 10, '$' 
 select db 10, 'Enter num:', '$' 
 
 row_req db 'num row: ', '$' 
 col_req db 'num col: ', '$' 
 
 vector_req db 'Enter row el: ', '$' 
 task1 db 'num for (#1): ', '$' 
 task1Ans db 'row and kol-vo el: ', '$' 
 task2Ans db 'Sorted col: ', '$' 
 task2 db 'num col (#2) for sortirovka: ', '$' 
 
 separator db 50 dup(' '), '$' 
 
 endl db 13, 10, '$' 
 tab db '   ', '$' 
 
 row dw 0 
 col dw 0 
 min_row_col dw 0 
 
 pos_amount dw 0 
 neg_amount dw 0 
 zero_amount dw 0 
 
 temp dw ? 
 
 in_select dw ? 
 
 nclr db 1 
 
.code 
 start: 
  mov ax, @data 
  mov ds, ax 
  xor ax, ax  
 
  cmp nclr, al 
  jnz clr 
  jmp get_menu 
 
  clr: 
   clrScr 
   mov nclr, al 
   jmp start 
 
  get_menu: 
   mSetPos 0000h, 000h 
   mWriteStr menu1 
 
   mSetPos 0001h, 000h 
   mWriteStr menu2 
 
   mSetPos 0002h, 0000h 
   mWriteStr menu3 
 
   mSetPos 0003h, 0000h 
   mWriteStr menu4 
 
   mSetPos 0004h, 0000h 
   mWriteStr menu5 
 
   mSetPos 0005h, 0000h 
   mWriteStr menu6 
 
   mSetPos 0006h, 0000h 
   mWriteStr menu0 
  
  select_loop: 
 
   mSetPos 0008h, 00001h 
   mWriteStr select 
   
   mReadAx buffer, 6 
   mov in_select, ax 
   
   cmp in_select, 1 
   je c1 
   cmp in_select, 2 
   je c2 
   cmp in_select, 3 
   je c3 
   cmp in_select, 4 
   je c4 
   cmp in_select, 5 
   je c5 
   cmp in_select, 6 
   je c6_base 
   cmp in_select, 0 
   je exit 
 
   ;outCLR 
   jmp alert 
 
  alert: 
   ;outCLR 
   selCLR 
   mSetPos 0011h, 0000h 

   jmp select_loop 
 
  exit: 
   ;outCLR 
   mov ax, 4c00h 
   int 21h 
 
  c1: 
   clrScr 
   mSetPos 0000h, 0000h 
   mWriteStr row_req 
   mReadAx buffer, 6 
   mov row, ax 
   cmp row, 0 
   jl c1_recall 
 
   mSetPos 0001h, 0000h 
   mWriteStr col_req 
   mReadAx buffer, 6 
   mov col, ax 
   cmp col, 0 
   jl c1_recall 
 
   get_min row, col, min_row_col 5
   mWriteStr endl

 
   mReadMatrix matrix, row, col, endl, buffer 
 
   clrScr 
   mSetPos 000fh, 0000h 
   jmp start 
 
  c1_recall: 
   clrScr 
   mov ah, 01h 
   int 21h 
   clrScr 
   jmp c1 
 
  c2: 
   cmp row, 0 
   je mne_alert 
 
   clrScr 
   mov bx, 0000h 
 
   mSetPos bh, 0000h 
   mWriteMatrix matrix, row, col, tab, endl 
   add bx, row  
   mov ah, 01h 
   int 21h 
   clrScr 
   jmp start 
 
  c3: 
   cmp row, 0 
   je mne_alert 
 
   clrScr 
   mov bx, 0000h 
   mSetPos bh, 0000h 
   mWriteMatrix matrix, row, col, tab, endl 
   add bx, row  
   mSetPos bl, 0000h 
   mWriteStr separator 
   mTransposeMatrix matrix, row, col, matrix_1 
   inc bx 
   mSetPos bl, 0000h 
   mWriteMatrix matrix_1, col, row, tab, endl 
   add bx, col 
   xor bx, bx 
   mov ah, 01h 
   int 21h 
   clrScr 
   jmp start 
 
  c4: 
   cmp row, 0 
   je mne_alert 
   
   clrScr 
   mov bx, 0000h 
   mSetPos bh, 0000h 
   mWriteMatrix matrix, row, col, tab, endl 
   add bx, row  
   mSetPos bl, 0000h 
   mWriteStr separator 
   inc bx 
    
   mSetPos bl, 0000h 
   mWriteStr task1 
   inc bx 
   mSetPos bl, 0000h 
   mReadAX buffer, 6 
   mov tempo, ax 
 
   inc bx 
   mSetPos bl, 0000h 
   mWriteStr task1Ans 
   inc bx 
   mTaskA matrix, row, col, tab, endl, tempo 
   inc bx 
    
   add bx, col 
   mSetPos bl, 0000h 
   xor bx, bx 
   mov ah, 01h 
   int 21h 
   clrScr 
   jmp start 
    
  c5: 
   cmp row, 0 
   je mne_alert 
   
   clrScr 
   mov bx, 0000h 
   mSetPos bh, 0000h 
   mWriteMatrix matrix, row, col, tab, endl 
   add bx, row  
   mSetPos bl, 0000h 
   mWriteStr separator 
   inc bx 
    
   mSetPos bl, 0000h 
   mWriteStr task2 
   inc bx 
   mSetPos bl, 0000h 
   mReadAX buffer, 6 
   mov tempo, ax 
   inc bx 
   mSetPos bl, 0000h 
   mWriteStr task2Ans 
   inc bx 
   mTaskB matrix, row, col, tempo, tab, endl, tempCol, SortCol, min 
   add bx, 3 
    
   add bx, col 
   mSetPos bl, 0000h 
   xor bx, bx 
   mov ah, 01h 
   int 21h 
   clrScr 
   jmp start 
 
  c6_base: 
  mWriteStr endl
  mWriteStr forTask3
  mWriteStr endl
  enter_vector: 
   cmp row, 0 
   je c6_disabled 
   clrScr 
   mSetPos 0000h, 0000h 
   mWriteStr vector_req 
   mSetPos 0001h, 0000h 
   mReadVector vector, col, endl, buffer
 
   clrScr 
   cmp row, 0 
   je c6_disabled 
   jmp c6_active 
 
  c6_active: 
   clrScr 
   mov bx, 0000h 
   mSetPos bh, 0000h 
   mWriteMatrix matrix, row, col, tab, endl 
   add bx, row  
   mSetPos bl, 0000h 
   mReplaceZeros matrix, row, col, vector, matrix_2 
   mWriteStr separator 
   inc bx 
   mSetPos bl, 0000h 
   mWriteMatrix matrix_2, row, col, tab, endl 
   add bx, row 
   mSetPos bl, 0000h 
   xor bx, bx 
   mov ah, 01h 
   int 21h 
   clrScr 
   mSetPos 000fh, 0000h 
   jmp start 
 
   
   clrScr 
   mSetPos 000fh, 0000h 
   jmp start 
 
  c6_disabled: 
   clrScr 
   mSetPos 0011h, 0000h 
   jmp start 
 
  mne_alert: 
   clrScr 
   mSetPos 0011h, 0000h 
   jmp start 
 
 
NOJUMPS 
end start 
end 