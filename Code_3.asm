assume cs:code1, ds:data1

data1	segment

cmdline					db 	127 dup ('$')
syntax_error_msg		db "Wrong Syntax!",13,10, "Correct input syntax:",13,10, "SHAPES {shape} {color} {size}",13,10,"shape: 1-square, 2-circle, 3-cross",13,10,"color:<0-255>",13,10,"size(1-199)",13, 10,'$'	
color_string			db 4 dup ('$')
size_string				db 4 dup ('$')
color_num				dw 0
size_num				dw 0
new_line				db 13,10,'$'
r						dw ?
x						dw 0
y						dw 0


data1	ends




code1	segment

print_string:		
	mov		ah, 9h
	int		21h
ret
	

;RETRIEVE CMDLINE FROM MEMORY TO A VARIABLE
get_cmdline:
	mov		cl, byte ptr es:[80h]		
	cmp		cl,0
	je		syntax_error
	dec		cl
	
	xor		si, si
	
	lp:
		mov	al,byte ptr es:[82h+si]
		mov	byte ptr ds:[cmdline+si],al
		inc	si
	loop	lp							
ret

get_atributes:

	xor 	si, si
	xor		bx, bx

	col:
		cmp		ds:[cmdline+2+si], '0'
		jb		syntax_error
		cmp		ds:[cmdline+2+si], '9'
		ja		syntax_error
		
		mov		al, byte ptr ds:[cmdline+2+si]
		mov		byte ptr ds:[color_string+bx], al
		
		inc		bx
		cmp		bx, 4
		je		syntax_error
		
		inc		si
		cmp  	ds:[cmdline+2+si], ' '
	jne		col
	
	
	
	inc 	si
	xor		bx, bx
		
		
	num:
		cmp		ds:[cmdline+2+si], '0'
		jb		syntax_error
		cmp		ds:[cmdline+2+si], '9'
		ja		syntax_error
		
		mov		al, byte ptr ds:[cmdline+2+si]
		mov		byte ptr ds:[size_string+bx], al
		inc		si
		inc		bx
		cmp		bx, 4
		je		syntax_error
		cmp  	ds:[cmdline+2+si], '$'
	jne		num
	
		
ret



color_to_int:
	xor		ax, ax
	mov		si, 3
	
	cm:
		dec	si
		cmp	ds:[color_string+si], '$'
	je	cm
	
	mov		al, byte ptr ds:[color_string+si]
	sub		al, 30h
	add		ds:[color_num], ax
	
	dec		si
	cmp		si, -1
	je		kon1
	
	xor 	ax, ax
	
	mov		al, byte ptr ds:[color_string+si]
	sub		al, 30h
	
	mov		dl, 10
	mul		dl
	
	add		ds:[color_num], ax

	dec		si
	cmp		si, -1
	je		kon1
	
	xor 	ax, ax
	
	mov		al, byte ptr ds:[color_string+si]
	sub		al, 30h
	
	mov		dl, 100
	mul		dl
	
	add		ds:[color_num], ax
	
	kon1:
ret
	
	
size_to_int:
	xor		ax, ax
	mov		si, 3
	
	cm1:
		dec	si
		cmp	ds:[size_string+si], '$'
	je	cm1
	
	mov		al, byte ptr ds:[size_string+si]
	sub		al, 30h
	add		ds:[size_num], ax
	
	dec		si
	cmp		si, -1
	je		kon2
	
	xor 	ax, ax
	
	mov		al, byte ptr ds:[size_string+si]
	sub		al, 30h
	
	mov		dl, 10
	mul		dl
	
	add		ds:[size_num], ax
	
	dec		si
	cmp		si, -1
	je		kon2
	
	xor 	ax, ax
	
	mov		al, byte ptr ds:[size_string+si]
	sub		al, 30h
	
	mov		dl, 100
	mul		dl
	
	add		ds:[size_num], ax
	
	kon2:
ret

enter_vga:
	mov	al,13h  ; tryb graficzny 320x200, 256 kol
	mov	ah,0  ;zmiana trybu vga
	int	10h
ret

exit_vga:
	mov	al,3 
	mov	ah,0  
	int	10h
ret

draw_square:

	mov	cx, 160
	mov	dx, 100
	
	mov	al, byte ptr ds:[size_num]
	mov	bl, 2
	div	bl
	
	xor	ah, ah
	
	sub cx, ax
	sub dx, ax
	
	mov	al, byte ptr ds:[color_num]
	xor	bx, bx
	mov	ah, 0Ch
	int 10h
	
	mov	si, ds:[size_num]
	
	draw1:
		inc	cx
		int	10h
		dec	si
		cmp	si,0
	jne	draw1
	
	mov	si, ds:[size_num]
	draw2:
		inc	dx
		int	10h
		dec	si
		cmp	si,0
	jne	draw2
	
	mov	si, ds:[size_num]
	draw3:
		dec	cx
		int	10h
		dec	si
		cmp	si,0
	jne	draw3
	
	mov	si, ds:[size_num]
	draw4:
		dec	dx
		int	10h
		dec	si
		cmp	si,0
	jne	draw4
	

ret

draw_cross:

	mov	cx, 160
	mov	dx, 100
	
	mov	al, byte ptr ds:[size_num]
	mov	bl, 2
	div	bl
	
	xor	ah, ah
	
	sub cx, ax
	sub dx, ax
	
	mov	al, byte ptr ds:[color_num]
	xor	bx, bx
	mov	ah, 0Ch
	int 10h
	
	
	mov	si, ds:[size_num]
	draw5:
		inc cx
		inc	dx
		int	10h
		dec	si
		cmp	si, 0
	jne	draw5
	
	sub dx, ds:[size_num]
	
	mov	si, ds:[size_num]
	draw6:
		dec cx
		inc	dx
		int	10h
		dec	si
		cmp	si, 0
	jne	draw6
		
ret


draw_circle:
	xor	bx, bx
	mov	si, ds:[size_num]

	mov	al, byte ptr ds:[size_num]
	mov	bl, 2
	div	bl
	
	xor	ah, ah
	
	mov	ds:[r], ax
	

	sub	ds:[x], ax
	
	
	finit
	fild word ptr ds:[r]
	fmul st, st(0)
	
	draw7:
		fild word ptr ds:[x]
		fmul st, st(0)
		fsub st, st(1)
		fchs
		fsqrt
		frndint
		fistp word ptr ds:[y]
		
		mov	cx, ds:[x]
		add	cx, 160
		
		mov	dx, ds:[y]
		add	dx, 100
		
		mov	ah, 0Ch
		mov	al, byte ptr ds:[color_num]
		
		int	10h
		
		neg ds:[y]
		
		mov	cx, ds:[x]
		add	cx, 160
		
		mov	dx, ds:[y]
		add	dx, 100
		
		mov	ah, 0Ch
		mov	al, byte ptr ds:[color_num]
		
		int	10h
		
					
		inc	ds:[x]
		dec	si
		cmp	si, 0
		jne	draw7
		
		mov	si, ds:[size_num]
	
	
	
	mov	ds:[y],0
	mov	ax, ds:[r]
	sub ds:[y],ax




draw8:
	
		fild word ptr ds:[y]
		fmul st, st(0)
		fsub st, st(1)
		fchs
		fsqrt
		frndint
		fistp word ptr ds:[x]
		
		mov	dx, ds:[y]
		add	dx, 100
		
		mov	cx, ds:[x]
		add	cx, 160
		
		mov	ah, 0Ch
		mov	al, byte ptr ds:[color_num]
		
		int	10h
		
		neg ds:[x]
		
		mov	dx, ds:[y]
		add	dx, 100
		
		mov	cx, ds:[x]
		add	cx, 160
		
		mov	ah, 0Ch
		mov	al, byte ptr ds:[color_num]
		
		int	10h
		
		
		inc	ds:[y]
		dec	si
		cmp	si, 0
		jne	draw8
	
ret
		
	
	


start:

	mov		ax, seg stack1
	mov		ss, ax
	mov		sp, offset top

	mov		ax, seg data1
	mov		ds, ax
	
	
	call	get_cmdline
	
	cmp		ds:[cmdline], '3'
	ja		syntax_error
	
	cmp		ds:[cmdline], '1'
	jb		syntax_error
	
	cmp		ds:[cmdline+1], ' '
	jne		syntax_error
	
	call	get_atributes
	
	
	call	color_to_int
	call	size_to_int
	
	cmp		ds:[color_num], 256
	jae		syntax_error
	
	cmp		ds:[size_num], 2
	jb		syntax_error
	
	cmp		ds:[size_num], 199
	jae		syntax_error
	

	
	cmp		ds:[cmdline], '1'
	je		square
	
	cmp		ds:[cmdline], '2'
	je		circle
	
	cmp		ds:[cmdline], '3'
	je		cross
	
	
square:
	call	enter_vga
	call	draw_square
	
	xor		ax, ax
	int		16h
	call	exit_vga
	
	jmp		terminate
		
circle:
	
	call	enter_vga
	call	draw_circle
	
	xor		ax, ax
	int		16h
	call	exit_vga
	
	jmp		terminate
	
	
cross:
	
	call	enter_vga
	call	draw_cross

	xor		ax, ax
	int		16h
	
	call	exit_vga
	
	
	jmp		terminate
	
	
	
syntax_error:
	mov		dx, offset syntax_error_msg
	call 	print_string
	
	
	
terminate:
	

	mov ah, 4Ch
	int	21h


code1	ends


stack1	segment stack
	dw		200 dup(?)
top	dw		?
stack1	ends

end start
