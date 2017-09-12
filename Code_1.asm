assume cs:code, ds:data


data segment

;-----------pr7seg data--------------
new_line	db 13,10,'$'
horizontal	db " ##### ",13,10,'$'
both		db "#     #",13,10,'$'
left		db "#      ",13,10,'$'
right		db "      #",13,10,'$'
al_save		db ?
;----------/pr7seg data--------------

data ends


code segment
start:	
	mov ax, seg top1	;INITIALIZE STACK
	mov ss, ax
	mov sp, offset top1

	mov ax, seg data
	mov ds, ax

	mov al, 5fh
	call pr7seg

	mov ah, 4ch	;END THE PROGRAM
	int 21h

;*************************************USER DEFINED SUBPROGRAMS**********************************

pr7seg:

	a	equ 01000000b		;SEGMENT NAMES AND THEIR CORESPONDING AL BITS
	b	equ 00100000b
	ce	equ 00010000b
	d	equ 00001000b
	e	equ 00000100b
	f	equ 00000010b
	g	equ 00000001b

;-------------------------pr7seg main---------------------------------

	mov al_save, al  		;SAVE AL VALUE IN A VARIABLE

	call print_new_line  		;PRINT A NEW LINE

	and al, a			;CHECK SEG.A 
	cmp al, a
	jne A_SEG_OFF			;IF OFF, GO TO A_SEG_OFF

	call print_horizontal		;ELSE PRINT SEG.A
	jmp F_AND_B_SEGS		;AND GO TO F_AND_B_SEGS

A_SEG_OFF:
	call print_new_line		;PRINT EMPTY SEG.A




F_AND_B_SEGS:
	mov al, al_save 		;GET BACK AL VALUE

	and al, f			;CHECK SEG.F
	cmp al, f
	je BOTH_F_AND_B			;IF ON, GO TO BOTH_F_AND_B
					;ELSE:
	mov al, al_save				;GET BACK AL VALUE

	and al, b				;CHECK SEG.B
	cmp al, b
	jne NONE1				;IF OFF, GO TO NONE1
	
	call print_right			;ELSE PRINT ONLY SEG.B
	jmp G_SEG				;AND GO TO G_SEG

BOTH_F_AND_B:
	mov al, al_save			;GET BACK AL VALUE

	and al, b			;CHECK SEG.B
	cmp al, b
	jne F_SEG			;IF OFF, GO TO F_SEG

	call print_both			;ELSE PRINT SEG.F AND SEG.B
	jmp G_SEG			;AND GO TO G_SEG

F_SEG:
	call print_left			;PRINT SEG.F
	jmp G_SEG			;AND GO TO G_SEG

NONE1:
	call print_none			;PRINT 3 EMPTY LINE




G_SEG:
	mov al, al_save			;GET BACK AL VALUE

	and al, g			;CHECK SEG.G
	cmp al, g			
	jne G_SEG_OFF			;IF OFF, GO TO G_SEG_OFF

	call print_horizontal		;ELSE PRINT SEG.G
	jmp E_AND_C_SEGS		;AND GO TO E_AND_C_SEGS

G_SEG_OFF:
	call print_new_line		;PRINT EMPTY SEG.G




E_AND_C_SEGS:
	mov al, al_save 		;GET BACK AL VALUE

	and al, e			;CHECK SEG.E
	cmp al, e
	je BOTH_E_AND_C			;IF ON, GO TO BOTH_E_AND_C
					;ELSE:
	mov al, al_save				;GET BACK AL VALUE

	and al, ce				;CHECK SEG.C
	cmp al, ce
	jne NONE2				;IF OFF, GO TO NONE2
	
	call print_right			;ELSE PRINT SEG.c
	jmp D_SEG				;AND GO TO D_SEG

BOTH_E_AND_C:
	mov al, al_save			;GET BACK AL VALUE

	and al, ce			;CHECK SEG.C
	cmp al, ce
	jne E_SEG			;IF OFF, GO TO E_SEG

	call print_both			;ELSE PRINT SEG.E AND SEG.C
	jmp D_SEG			;AND GO TO D_SEG

E_SEG:
	call print_left			;PRINT SEG.E
	jmp D_SEG			;AND GO TO D_SEG

NONE2:
	call print_none			;PRINT 3 EMPTY LINES




D_SEG:
	mov al, al_save

	and al, d			;CHECK SEG.D
	cmp al, d			
	jne D_SEG_OFF			;IF OFF, GO D_SEG_OFF

	call print_horizontal		;ELSE PRINT SEG.D
	jmp TERMINATE			;AND GO TO TERMINATE

D_SEG_OFF:
	call print_new_line		;PRINT EMPTY SEG.D




TERMINATE:
ret

;-----------------------/pr7seg main--------------------------------


print_new_line:
	mov dx, offset new_line
	call print_string
ret


print_horizontal:
	mov dx, offset horizontal	
	call print_string
ret


print_left:
	mov cx, 3
	mov dx, offset left

	l1:
	call print_string
	loop l1
ret


print_right:
	mov cx, 3
	mov dx, offset right

	l2:
	call print_string
	loop l2
ret


print_both:
	mov cx, 3
	mov dx, offset both

	l3:
	call print_string
	loop l3
ret


print_none:
	mov cx, 3
	mov dx, offset new_line

	l4:
	call print_string
	loop l4
ret
	

print_string:
	push ax
	push bx
	push cx
	push dx

	mov ah, 9h
	int 21h

	pop dx
	pop cx
	pop bx
	pop ax
ret


;*****************USER DEFINED SUBPROGRAMS************************
code ends



stack1	segment stack

	dw 200 dup(?)
top1	dw ?

stack1	ends



end start
