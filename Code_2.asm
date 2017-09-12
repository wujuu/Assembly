assume cs:code1, ds:data1

data1	segment

cmdline					db 	127 dup(0)
filename				db	127 dup(0)
syntax_error_msg		db	"Syntax error!, input -> editor -h for help$"	
help_msg				db	"Welcome to my editor! You will be writing in 80x24 window with footer",13,10
						db  "Press ctrl+x to exit, ctrl+s to save",13,10,13,10
						db	"Correct syntax:editor (-r/-d/-h )'filename'",13,10
						db	"No option: edit existing file/create new",13,10
						db	"-r: open file in ready only mode",13,10
						db	"-d: display footer -> file name + cursor position",13,10
						db	"-h: display help",'$'
no_file_msg				db	"There is no such file, input editor -h for help$"
file_handle				dw	?
buffor					db	2000 dup (0)
cursor_pos				dw	0
read_only_stopka_msg 	db 	"You are in read only mode, press ctrl+x to exit",0
not_saved_once			db  1

data1	ends


	

code1	segment

;**************************************FUNCTIONS******************************

;PRINT VARIOUS STRINGS
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

;RETRIEVE A FILENAME FROM MEMORY TO A VARIABLE
get_filename:
	xor		cx, cx
	mov		cl, byte ptr es:[80h]
	sub		cl, al
	
	xor		si, si
	
	filename_to_string:
		mov		al,	byte ptr es:[bx+si]
		mov		byte ptr ds:[filename+si], al
		inc		si
	loop 	filename_to_string
ret


;OPEN A FILE IN READ ONLY MODE
open_file:
	mov		dx, offset ds:[filename]
	mov		ah, 3Dh
	int		21h
ret


to_buffor:
	mov		bx, ds:[file_handle]
	mov		cx, 2000
	mov		dx, offset ds:[buffor]
	mov		ah, 3Fh
	int		21h
ret

close_file:
	mov		bx, ds:[file_handle]
	mov		ah,	3Eh
	int		21h
ret

;CREATE A NEW FILE 
create_file:
	mov		dx, offset ds:[filename]
	xor		cx, cx
	mov		ah, 3Ch
	int		21h
ret

;WRITE TO FILE
write_to_file:
	push	bx
		
	xor		bx, bx
	xor		si, si
	
	write:
		mov		al, byte ptr es:[bx]
		mov		byte ptr ds:[buffor+si], al
		inc		si
		add		bx, 2
		cmp		bx, 4000
	jne		write
	
	
	xor		al, al
	mov		bx, ds:[file_handle]
	xor		cx, cx
	xor		dx, dx
	mov		ah, 42h
	int		21h
	
	
	mov		bx, ds:[file_handle]
	mov		cx, 2000
	mov		dx, offset ds:[buffor]
	mov		ah, 40h
	int		21h
	
	pop		bx
	
	mov		byte ptr ds:[not_saved_once], 0
ret	
	



;CLEAR THE WHOLE SCREEN BEFORE EXITING
clear_screen:
	xor		bx, bx
	
	clear:
	mov		byte ptr es:[bx], ' '
	mov		byte ptr es:[bx+1], 0000111b
	add		bx, 2
	cmp		bx, 4000
	jne		clear
ret

print_buffor_from_pos:
	xor		si, si
	print:
		mov	dl, byte ptr ds:[buffor+bx+si]
		mov	ah, 02h
		int	21h
		inc	si
		cmp	si, cx
	jne print	
	
	jmp		terminate
ret


read_only_stopka:
	xor		si, si
	mov		bx, 3840
	disp:
		mov		al, byte ptr ds:[read_only_stopka_msg+si]
		mov		byte ptr es:[bx], al
		inc		si
		add		bx, 2
		cmp     byte ptr ds:[read_only_stopka_msg+si], 0
	jne		disp
ret
	

;MAIN EDITOR
ready_editor:	

	mov		al, 3
	mov		ah, 0
	int		10h
	
	;MOVE ADRESS OF THE WORKING SPACE TO ES
	mov		ax,	0B800h
	mov		es,ax
	
	;FILL ENTIRE SCREEN WITH SPACES AND RIGHT COLOURING AND RIGHT SYMBOLS
	xor		bx, bx
	xor		si, si
	fill:
		mov		al,	byte ptr ds:[buffor+si]
		mov		byte ptr es:[bx], al
		mov		byte ptr es:[bx+1], 0000111b
		add		bx, 2
		inc		si
		cmp		bx, 4000
	jne		fill
ret


		
ready_stopka:		
	xor		si, si
	mov		bx, 3856
		
	disp_name:
		mov		al, byte ptr ds:[filename+si]
		mov		byte ptr es:[bx], al
		inc		si
		add		bx, 2
		cmp		byte ptr ds:[filename+si], 0
	jne		disp_name
	
	
	mov		byte ptr es:[3840],'('
	mov		byte ptr es:[3842],'0'
	mov		byte ptr es:[3844],'0'
	mov		byte ptr es:[3846],','
	mov		byte ptr es:[3848],'0'
	mov		byte ptr es:[3850],'0'
	mov		byte ptr es:[3852],')'
ret	
	
	

	
editor:
	call	calculate_cursor
		
	mov		bx, ds:[cursor_pos]
	mov		byte ptr es:[bx+1], 1111111b

	main_editor_loop:
		call	get_position
		
		push	bx
		mov		ah, 0
		int		16h
		pop		bx
		
		;CHECK WHICH KEY WAS INPUT ON THE KEYBOARD
		exit:
		cmp		al, 24
		je		end_editor
		
		save:
		cmp		al, 19
		jne		k_del
		call	write_to_file
		jmp		main_editor_loop
		
		k_del:
		cmp		ah, 83
		jne		k_up
		call	delete
		
		
		k_up:
		cmp		ah, 72
		jne		k_left
		cmp		bx, 158
		jle		main_editor_loop
		mov		ax, -160
		call	move_cursor
		
		k_left:
		cmp		ah, 75
		jne		k_right
		cmp		bx, 0
		je		main_editor_loop
		mov		ax, -2
		call	move_cursor
		
		k_right:
		cmp		ah, 77
		jne		k_down
		cmp		bx, 3838
		je		main_editor_loop
		mov		ax, 2
		call	move_cursor
		
		k_down:
		cmp		ah, 80
		jne		display
		cmp		bx, 3680
		jge		main_editor_loop
		mov		ax, 160
		call	move_cursor
		
		
		display:
		cmp		al, 32
		jb		main_editor_loop		
		call	display_char
ret	

;EDITOR FUNCTIONS
display_char:	
	mov		byte ptr es:[bx], al
	mov		byte ptr es:[bx+1], 0000111b
	
	add		bx, 2
	cmp		bx, 3840
	jne		next
	
	sub		bx, 2
	
	next:
	mov		byte ptr es:[bx+1], 1111111b
	
	jmp		main_editor_loop
ret

delete:
	mov 	byte ptr es:[bx+1],0000111b
	
	cmp		bx, 0
	je		del
	
	sub		bx, 2
	
	del:
	mov		byte ptr es:[bx], ' '
	mov 	byte ptr es:[bx+1],1111111b
	
	jmp		main_editor_loop
ret	

move_cursor:
	mov		byte ptr es:[bx+1], 0000111b
	add		bx, ax
	mov		byte ptr es:[bx+1], 1111111b
	
	jmp		main_editor_loop
ret


get_position:	
	mov		ax, bx
	mov		dl, 160
	div		dl
	
	mov		ch, ah
	xor		ah, ah
	
	mov		dl,10
	div		dl
	
	add		al,30h
	add		ah,30h
	
	mov		byte ptr es:[3842],al
	mov		byte ptr es:[3844],ah
	
	
	xor		ax, ax
	mov		al, ch
	
	mov		dl, 2
	div		dl
	
	mov		dl, 10
	div		dl

	add		al, 30h
	add		ah, 30h

	mov		byte ptr es:[3848],al
	mov		byte ptr es:[3850],ah
ret

calculate_cursor:
	mov		bx, es:[3842]
	sub		bx, 30h
	mov		ax, bx
	
	mov		dl, 10
	mul		dl
	
	mov		bx, es:[3844]
	sub		bx, 30h
	
	add		ax, bx
	
	mov		dl, 160
	mul		dl
	
	mov		cx, ax
	
	mov		bx, es:[3848]
	sub		bx, 30h
	mov		ax, bx
	
	mov		dl, 10
	mul		dl
	
	mov		bx, es:[3850]
	sub		bx, 30h
	
	add		ax, bx
	
	mov		dl, 2
	mul		dl
	
	add		ax,cx
	
	mov		ds:[cursor_pos],ax
ret	
;************************************MAIN PROGRAM********************************

start:
	;MOVE SEGMENT ADRESSES TO THEIR SEGMENT REGISTER
	mov		ax, seg stack1
	mov		ss, ax
	mov		sp, offset top

	mov		ax, seg data1
	mov		ds, ax
	
	
	call	get_cmdline
	
	
	;CMDLINE SYNTAX CHECKING
	mov		al, byte ptr ds:[cmdline]
	
	cmp		al, '-'
	je		options
	
	cmp		al, 30h
	jb		syntax_error
	
	

no_options:
	mov		al, 1
	mov		bx, 82h
	call	get_filename
	
	mov		al, 0
	call	open_file
	jb		new_file  ;NO EXISTING FILE - WE WILL BE CREATING A NEW ONE
	
	mov		byte ptr ds:[not_saved_once], 0
	
	
	mov		ds:[file_handle], ax	;EDIT EXISTING FILE
	call	to_buffor
	
	mov		al, 1
	call	open_file
	mov		ds:[file_handle], ax
	call	ready_editor
	
	jmp		start_editing
	
new_file:
	call	create_file
	mov		al, 1
	call	open_file
	mov		ds:[file_handle], ax
	call 	ready_editor
	call	ready_stopka
	
start_editing:	
	call 	editor
	end_editor:
	
	
	cmp		byte ptr ds:[not_saved_once], 1
	jne		close
	
	call	ready_editor
	call	ready_stopka
	
	call	write_to_file
	
	close:
	call	close_file
	call 	clear_screen
	jmp  	terminate
	
	
options:
	;INPUT SYNTAX CHECKING
	mov		al, byte ptr ds:[cmdline+1]
	
	cmp		al, ' '
	je		syntax_error
	
	;NEED HELP?
	cmp		al, 'h'
	je		display_help
	
	;MORE SYNTAX CHECKING
	mov		al, byte ptr ds:[cmdline+2]
	
	cmp		al, ' '
	jne		syntax_error
	
	mov		al, byte ptr ds:[cmdline+3]
	
	cmp		al, 30h
	jb		syntax_error
	
	
	
;	  SYNTAX IS OKAY

	mov		al, 4
	mov		bx, 85h
	call	get_filename
	
	mov		al, 0
	call	open_file
	jb		no_file_error
	
	mov		ds:[file_handle], ax
	call	to_buffor
	call	close_file
	
	
	;WHICH OPTION?
	mov		al, byte ptr ds:[cmdline+1]
	
	cmp		al, 'd'
	je		display_stopka
	
	cmp		al, 'r'
	je		read_only
	
	;IF NOT -D OR -R THEN SYNTAX ERROR
	jmp		syntax_error

	

;		EXECUTE THE OPTIONS

display_stopka:
	mov		bx, 1920
	mov		cx, 79
	call	print_buffor_from_pos
	
	
read_only:
	call	ready_editor
	call	read_only_stopka

	key_wait:	
		mov		ah, 0
		int		16h
	
	cmp		al, 24
	jne		key_wait	
	
	call	clear_screen
	jmp		terminate	
	

	
	
;     FLAGS TO DISPLAY VARIOUS MESSAGES

	
syntax_error:
	mov		dx, offset ds:[syntax_error_msg]
	call	print_string
	jmp		terminate
	
no_file_error:
	mov		dx, offset ds:[no_file_msg]
	call	print_string
	jmp		terminate
	
display_help:
	mov		dx, offset ds:[help_msg]
	call	print_string
	jmp		terminate
	
	
;     TERMINATE THE PROGRAM
terminate:
	mov		ah, 4Ch
	int		21h
code1	ends


stack1	segment stack
	dw		200 dup(?)
top	dw		?
stack1	ends

end		start
