
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ				DOSIDLE1                                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ      Created:   11-Jul-100		                                 ÛÛ
;ÛÛ      Passes:    9          Analysis	Options on: none                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

target		EQU   'M6'                      ; Target assembler: MASM-6.0

include  srmacros.inc

.586p

PSP_envirn_seg	equ	2Ch

;------------------------------------------------------------  seg_a   ----

seg_a		segment	byte public use16 'code'
		assume cs:seg_a  , ds:seg_a , ss:stack_seg_b

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

mem_lallocate	proc near			               
	push	bx
	mov	bx,cx
	mov	ah,48h
	int	21h			; DOS Services  ah=function 48h
					;  allocate memory, bx=bytes/16
	pop	bx
	retn
mem_lallocate	endp

mem_lrelease	proc	near
	push	ax
	push	es
	mov	es,ax
	mov	ah,49h
	int	21h			; DOS Services  ah=function 49h
					;  release memory block, es=seg
	pop	es
	pop	ax
	retn
mem_lrelease	endp

mem_lresize	proc	near			                        
	push	ax
	push	bx
	push	es
	mov	es,ax
	mov	bx,cx
	mov	ah,4Ah
	int	21h			; DOS Services  ah=function 4Ah
					;  change memory allocation
					;   bx=bytes/16, es=mem segment
	pop	es
	pop	bx
	pop	ax
	retn
mem_lresize	endp

mem_lallocate_all	proc	near			                        
	push	bx
	mov	bx,0FFFFh
	mov	ah,48h
	int	21h			; DOS Services  ah=function 48h
					;  allocate memory, bx=bytes/16
	mov	ax,bx
	mov	cx,bx
	pop	bx
	retn
mem_lallocate_all	endp

intr_vec_struc	struc 
	number  db  0                                                              	
 	old_isr dd  0                                                              	             
 	new_isr dd  0                                                              	            
intr_vec_struc	ends                                                                               	

intr_suspend_struc	struc
	byte1	db 0
	bytes25	dd 0	
intr_suspend_struc	ends

par_item	struc
	switch		db 11 dup (0)
	proc_offset	dw	0		
par_item	ends

INTR_14H_BIOS		= 14h * 4
INTR_16H_BIOS		= 16h * 4
INTR_21H_BIOS		= 21h * 4
INTR_2DH_BIOS		= 2dh * 4

tsr_kernel_id	dw	0                                       
tsr_psp_seg	dw	0                                       
tsr_env_seg	dw	0                                       
new_int_2dh	dd	isr_2dh                                 
old_int_2dh	dd	0                                    	
intr_vectors	intr_vec_struc 30 dup (<>)
vectors_hooked	dw	0                                    	
suspend_vectors	intr_suspend_struc 30 dup (<>)
vectors_suspend	dw	0                                      	

TSR_ID			= 0FEADh
ACTION_TEST		= 0
ACTION_UNINSTALL       	= 1
ACTION_SUSPEND         	= 2
ACTION_REACTIVATE	= 3

isr_2dh	proc	far
	cmp	dx, tsr_kernel_id	;		db	 2Eh, 3Bh, 16h, 31h, 00h, 74h 
	jz	loc_1                   ;		db	 05h                          
loc_2:
	jmp	dword ptr cs:old_int_2dh
loc_1:			                        
	cmp	bx,ACTION_TEST
	jne	short loc_3		; Jump if not equal
	mov	ax,TSR_ID
	sti				; Enable interrupts
	iret				; Interrupt return
loc_3:
	cmp	bx,ACTION_UNINSTALL
	jne	short loc_10		; Jump if not equal
	cli				; Disable interrupts
	push	cx
	push	si
	push	di
	push	ds
	push	es
	mov	ax,cs
	mov	ds,ax
	xor	ax,ax			; Zero register
	mov	es,ax
	mov	eax,new_int_2dh
	cmp	es:INTR_2DH_BIOS,eax
	jne	short loc_8		; Jump if not equal
	mov	si,offset intr_vectors
	mov	cx,vectors_hooked
	test	cx,cx
	jz	short loc_7		; Jump if zero

locloop_4:
	movzx	di, [(intr_vec_struc ptr [si]).number]	; Mov w/zero extend
	shl	di,2			; Shift w/zeros fill
	mov	eax,[(intr_vec_struc ptr [si]).old_isr]
	cmp	es:[di],eax
	je	short loc_5		; Jump if equal
	mov	eax,[(intr_vec_struc ptr [si]).new_isr]
	cmp	es:[di],eax
	jne	short loc_8		; Jump if not equal
loc_5:
	add	si,size intr_vec_struc
	loop	locloop_4		; Loop if cx > 0

	mov	si,offset intr_vectors
	mov	cx,vectors_hooked

locloop_6:
	mov	eax,[(intr_vec_struc ptr [si]).old_isr]
	movzx	di,[(intr_vec_struc ptr [si]).number]	; Mov w/zero extend
	shl	di,2			; Shift w/zeros fill
	mov	es:[di],eax
	add	si,size intr_vec_struc
	loop	locloop_6		; Loop if cx > 0

loc_7:
	mov	eax,dword ptr old_int_2dh
	mov	es:INTR_2DH_BIOS,eax
	mov	ax,tsr_psp_seg
	call	mem_lrelease
	mov	ax,1
	jmp	short loc_9
loc_8:
	xor	ax,ax			; Zero register
loc_9:
	pop	es
	pop	ds
	pop	di
	pop	si
	pop	cx
	sti				; Enable interrupts
	iret				; Interrupt return
loc_10:
	cmp	bx,ACTION_SUSPEND
	jne	short loc_15		; Jump if not equal
	cli				; Disable interrupts
	push	ebx
	push	cx
	push	si
	push	di
	push	ds
	push	es
	mov	ax,cs
	mov	ds,ax
	cmp	vectors_suspend,0
	jne	short loc_13		; Jump if not equal
	mov	si,offset intr_vectors
	mov	di,offset suspend_vectors
	mov	cx,vectors_hooked
	mov	vectors_suspend,cx
	test	cx,cx
	jz	short loc_12		; Jump if zero

locloop_11:
	mov	ebx,[(intr_vec_struc ptr [si]).new_isr]
	ror	ebx,10h			; Rotate
	mov	es,bx
	rol	ebx,10h			; Rotate
	mov	al,es:[bx]
	mov	[(intr_suspend_struc ptr [di]).byte1],al
	mov	eax,es:[bx+1]
	mov	[di+1],eax
	mov	eax,[si+1]
	mov	byte ptr es:[bx],0EAh
	mov	es:[bx+1],eax
	add	si, size intr_vec_struc
	add	di,size intr_suspend_struc
	loop	locloop_11		; Loop if cx > 0

loc_12:
	mov	ax,1
	jmp	short loc_14
loc_13:
	xor	ax,ax			; Zero register
loc_14:
	pop	es
	pop	ds
	pop	di
	pop	si
	pop	cx
	pop	ebx
	sti				; Enable interrupts
	iret				; Interrupt return
loc_15:
	cmp	bx,ACTION_REACTIVATE
	jne	loc_2			; Jump if not equal
	cli				; Disable interrupts
	push	ebx
	push	cx
	push	si
	push	di
	push	ds
	push	es
	mov	ax,cs
	mov	ds,ax
	cmp	vectors_suspend,0
	je	short loc_18		; Jump if equal
	mov	si,offset intr_vectors
	mov	di,offset suspend_vectors
	mov	cx,vectors_hooked
	mov	vectors_suspend,0
	test	cx,cx
	jz	short loc_17		; Jump if zero

locloop_16:
	mov	ebx,[(intr_vec_struc ptr [si]).new_isr]
	ror	ebx,10h			; Rotate
	mov	es,bx
	rol	ebx,10h			; Rotate
	mov	al,[(intr_suspend_struc ptr [di]).byte1]
	mov	es:[bx],al
	mov	eax,[(intr_suspend_struc ptr [di]).bytes25]
	mov	es:[bx+1],eax
	add	si,size intr_vec_struc
	add	di,size intr_suspend_struc
	loop	locloop_16		; Loop if cx > 0

loc_17:
	mov	ax,1
	jmp	short loc_19
loc_18:
	xor	ax,ax			; Zero register
loc_19:
	pop	es
	pop	ds
	pop	di
	pop	si
	pop	cx
	pop	ebx
	sti				; Enable interrupts
	iret				; Interrupt return
isr_2dh	endp

hex_table2	db	'0123456789ABCDEF'	; Data table (indexed access)

VIDEO_SEG	= 0B800h
video_offset	dw	0
video_attribute	db	0Eh

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

video_writestring	proc	near
	push	ax
	push	si
	push	es
	mov	ax,VIDEO_SEG
	mov	es,ax
loc_20:
	mov	al,[si]
	test	al,al
	jz	short loc_21		; Jump if zero
	call	video_writech
	inc	si
	jmp	short loc_20
loc_21:
	pop	es
	pop	si
	pop	ax
	retn
video_writestring	endp

video_set_nl	proc	near			                        
	push	ax
	call	video_writestring
	call	video_get_pos
	inc	al
	call	video_set_pos
	pop	ax
	retn
video_set_nl	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

video_writech	proc	near
	push	ax
	push	di
	mov	di,VIDEO_SEG
	mov	es,di
	mov	di,video_offset
	mov	ah,video_attribute
	mov	es:[di],ax
	add	video_offset,2
	pop	di
	pop	ax
	retn
video_writech	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

video_writedec	proc	near
	push	eax
	push	ebx
	push	cx
	push	edx
	push	es
	mov	bx,VIDEO_SEG
	mov	es,bx
	mov	ebx,0Ah
	xor	cx,cx			; Zero register
loc_22:
	xor	edx,edx			; Zero register
	div	ebx			; ax,dx rem=dx:ax/reg
	push	dx
	inc	cl
	test	eax,eax
	jnz	loc_22			; Jump if not zero

locloop_23:
	pop	bx
	mov	al,byte ptr hex_table2[bx]	; ('0123456789ABCDEF')
	call	video_writech
	loop	locloop_23		; Loop if cx > 0

	pop	es
	pop	edx
	pop	cx
	pop	ebx
	pop	eax
	retn
video_writedec	endp

video_writehex	proc	near			                        
	push	ax
	push	ebx
	push	cx
	push	si
	push	es
	mov	bx,VIDEO_SEG
	mov	es,bx
	mov	ebx,eax
	mov	cx,8

locloop_24:
	rol	ebx,4			; Rotate
	mov	si,bx
	and	si,0Fh
	test	si,si
	loopz	locloop_24		; Loop if zf=1, cx>0

	jcxz	short loc_26		; Jump if cx=0
	ror	ebx,4			; Rotate
	inc	cx

locloop_25:
	rol	ebx,4			; Rotate
	mov	si,bx
	and	si,0Fh
	mov	al,byte ptr hex_table2[si]	; ('0123456789ABCDEF')
	call	video_writech
	loop	locloop_25		; Loop if cx > 0

	jmp	short loc_27
loc_26:
	mov	al,30h			; '0'
	call	video_writech
loc_27:
	mov	al,68h			; 'h'
	call	video_writech
	pop	es
	pop	si
	pop	cx
	pop	ebx
	pop	ax
	retn
video_writehex	endp

video_attribute_special	proc	near			                        	
	push	ax
	push	cx
	push	es
	call	video_get_attribute
	push	ax
	mov	ax,VIDEO_SEG
	mov	es,ax
	mov	cx,7D0h
	mov	al,0Fh
	call	video_set_attribute
	mov	al,20h			; ' '

locloop_28:
	call	video_writech
	loop	locloop_28		; Loop if cx > 0

	pop	ax
	call	video_set_attribute
	pop	es
	pop	cx
	pop	ax
	retn
video_attribute_special	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

video_get_attribute	proc	near
	mov	al,video_attribute
	retn
video_get_attribute	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

video_set_attribute	proc	near
	mov	video_attribute,al
	retn
video_set_attribute	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

video_get_pos	proc	near
	push	dx
	mov	ax,video_offset
	mov	dx,0A0h
	div	dx			; ax,dx rem=dx:ax/reg
	shr	dx,1			; Shift w/zeros fill
	mov	ah,dl
	pop	dx
	retn
video_get_pos	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

video_set_pos		proc	near
	push	ax
	push	dx
	mov	dh,ah
	mov	dl,0A0h
		mul	dl			; ax = reg * al
	shr	dx,7			; Shift w/zeros fill
	and	dl,0FEh
	add	ax,dx
	mov	video_offset,ax
	pop	dx
	pop	ax
	retn
video_set_pos		endp

IDLE_MODE_1	=	1      	;enable TESTOMODE
IDLE_MODE_2	=	2     	;disable FORCEMODE
idle_mode	db	0

		db	 87h,0DBh
old_intr_21h		dd	0
new_intr_21h_1		dd	isr_21h_1
new_intr_21h_2		dd	isr_21h_2
intr_21h_delay		dd	00000h					
intr_21h_halts		dd	00000h                             	
intr_21h_calls		dd	00000h                                	
intr_21h_halts_msg	db	' int 21h HLTs executed.', 0
intr_21h_calls_msg	db	' int 21h calls.', 0

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

isr_21h_halt_1	proc	near
	test	cs:idle_mode,IDLE_MODE_2
	jnz	short loc_ret_29	; Jump if not zero
	inc	cs:intr_21h_delay
	cmp	cs:intr_21h_delay,0Ah
	jb	short loc_ret_29	; Jump if below
	sti				; Enable interrupts
	hlt				; Halt processor
	inc	cs:intr_21h_halts

loc_ret_29:
	retn
isr_21h_halt_1	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

isr_21h_halt_2		proc	near
	push	ax
	sti				; Enable interrupts
loc_30:
	mov	ah,0Bh
	pushf				; Push flags
	call	dword ptr cs:old_intr_21h
	test	ax,ax
	jnz	short loc_31		; Jump if not zero
	hlt				; Halt processor
	inc	cs:intr_21h_halts
	jmp	short loc_30
loc_31:
	pop	ax
	retn
isr_21h_halt_2		endp

			                        
	xchg	bx,bx
	xchg	bx,bx
	xchg	bx,bx
	nop

isr_21h_1	proc	far
	cmp	ah,2Ch			; ','
	ja	short loc_34		; Jump if above
	jnz	short loc_32		; Jump if not zero
	call	isr_21h_halt_1
	jmp	short loc_35
loc_32:
	cmp	ah,8
	je	short loc_33		; Jump if equal
	cmp	ah,7
	je	short loc_33		; Jump if equal
	cmp	ah,1
	jne	short loc_34		; Jump if not equal
loc_33:
	call	isr_21h_halt_2
	jmp	short loc_35
loc_34:
	mov	dword ptr cs:intr_21h_delay,0
	mov	dword ptr cs:intr_16h_delay,0
loc_35:
	jmp	dword ptr cs:old_intr_21h
isr_21h_1	endp			                        

	xchg	bx,bx
	xchg	bx,bx
	xchg	bx,bx
	nop

isr_21h_2	proc	far	
	push	eax
	push	si
	push	ds
	mov	ax,cs
	mov	ds,ax
	mov	al,1
	mov	ah,37h			; '7'
	call	video_set_pos
	mov	al,0Ch
	call	video_set_attribute
	mov	eax,intr_21h_calls
	inc	intr_21h_calls
	call	video_writedec
	mov	al,0Eh
	call	video_set_attribute
	mov	si,offset intr_21h_calls_msg	; (' int 21h calls.')
	call	video_writestring
	mov	eax,dword ptr [esp+4]
	cmp	ah,2Ch			; ','
	ja	short loc_38		; Jump if above
	jnz	short loc_36		; Jump if not zero
	mov	ax,1
	call	video_set_pos
	mov	al,0Ch
	call	video_set_attribute
	mov	eax,intr_21h_halts
	call	video_writedec
	mov	al,0Eh
	call	video_set_attribute
	mov	si,offset intr_21h_halts_msg	; (' int 21h HLTs executed.')
	call	video_writestring
	call	isr_21h_halt_1
	jmp	short loc_39
loc_36:
	cmp	ah,8
	je	short loc_37		; Jump if equal
	cmp	ah,7
	je	short loc_37		; Jump if equal
	cmp	ah,1
	jne	short loc_38		; Jump if not equal
loc_37:
	mov	ax,1
	call	video_set_pos
	mov	al,0Ch
	call	video_set_attribute
	mov	eax,intr_21h_halts
	call	video_writedec
	mov	al,0Eh
	call	video_set_attribute
	mov	si,offset intr_21h_halts_msg	; (' int 21h HLTs executed.')
	call	video_writestring
	call	isr_21h_halt_2
	jmp	short loc_39
loc_38:
	mov	dword ptr intr_21h_delay,0
	mov	dword ptr intr_16h_delay,0
loc_39:
	pop	ds
	pop	si
	pop	eax
	jmp	dword ptr cs:old_intr_21h
isr_21h_2	endp

		db	 87h,0DBh
old_intr_16h		dd	0
new_intr_16h_1		dd	isr_16h_1
new_intr_16h_2		dd	isr_16h_2
intr_16h_delay		dd	00000h                                       
intr_16h_halts		dd	00000h                                       
intr_16h_calls		dd	00000h                                       
intr_16h_halts_msg	db	' int 16h HLTs executed.', 0
intr_16h_calls_msg	db	' int 16h calls.', 0

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

isr_16h_halt_1		proc	near
	test	cs:idle_mode,IDLE_MODE_2
	jnz	short loc_ret_40	; Jump if not zero
	inc	cs:intr_16h_delay
	cmp	cs:intr_16h_delay,0Ah
	jb	short loc_ret_40	; Jump if below
	sti				; Enable interrupts
	hlt				; Halt processor
	inc	cs:intr_16h_halts

loc_ret_40:
	retn
isr_16h_halt_1		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

isr_16h_halt_2		proc	near
	push	ax
	push	cx
	inc	ah
	mov	ch,ah
	sti				; Enable interrupts
loc_41:
	pushf				; Push flags
	call	dword ptr cs:old_intr_16h
	jnz	short loc_42		; Jump if not zero
	hlt				; Halt processor
	inc	cs:intr_16h_halts
	mov	ah,ch
	jmp	short loc_41
loc_42:
	pop	cx
	pop	ax
	retn
isr_16h_halt_2		endp

			                        
	xchg	bx,bx
	xchg	bx,bx
	xchg	bx,bx
	xchg	bx,bx
	xchg	bx,bx
	nop

isr_16h_1	proc	far
	cmp	ah,12h
	ja	short loc_46		; Jump if above
	jz	short loc_43		; Jump if zero
	cmp	ah,11h
	je	short loc_43		; Jump if equal
	cmp	ah,2
	je	short loc_43		; Jump if equal
	cmp	ah,1
	jne	short loc_44		; Jump if not equal
loc_43:
	call	isr_16h_halt_1
	jmp	short loc_47
loc_44:
	cmp	ah,10h
	je	short loc_45		; Jump if equal
	test	ah,ah
	jnz	short loc_46		; Jump if not zero
loc_45:
	call	isr_16h_halt_2
	jmp	short loc_47
loc_46:
	mov	cs:intr_16h_delay,0
	mov	cs:intr_21h_delay,0
loc_47:
	jmp	dword ptr cs:old_intr_16h
isr_16h_1	endp
			                        
	xchg	bx,bx
	xchg	bx,bx
	xchg	bx,bx
	xchg	bx,bx
	xchg	bx,bx
	xchg	bx,bx
	xchg	bx,bx

isr_16h_2	proc	far
	push	eax
	push	si
	push	ds
	mov	ax,cs
	mov	ds,ax
	mov	ah,37h			; '7'
	xor	al,al			; Zero register
	call	video_set_pos
	mov	al,0Ch
	call	video_set_attribute
	mov	eax,intr_16h_calls
	inc	intr_16h_calls
	call	video_writedec
	mov	al,0Eh
	call	video_set_attribute
	mov	si,offset intr_16h_calls_msg	; (' int 16h calls.')
	call	video_writestring
	mov	eax,dword ptr [esp+4]
	cmp	ah,12h
	ja	short loc_51		; Jump if above
	jz	short loc_48		; Jump if zero
	cmp	ah,11h
	je	short loc_48		; Jump if equal
	cmp	ah,2
	je	short loc_48		; Jump if equal
	cmp	ah,1
	jne	short loc_49		; Jump if not equal
loc_48:
	xor	ax,ax			; Zero register
	call	video_set_pos
	mov	al,0Ch
	call	video_set_attribute
	mov	eax,intr_16h_halts
	call	video_writedec
	mov	al,0Eh
	call	video_set_attribute
	mov	si,offset intr_16h_halts_msg	; (' int 16h HLTs executed.')
	call	video_writestring
	call	isr_16h_halt_1
	jmp	short loc_52
loc_49:
	cmp	ah,10h
	je	short loc_50		; Jump if equal
	test	ah,ah
	jnz	short loc_51		; Jump if not zero
loc_50:
	xor	ax,ax			; Zero register
	call	video_set_pos
	mov	al,0Ch
	call	video_set_attribute
	mov	eax,intr_16h_halts
	call	video_writedec
	mov	al,0Eh
	call	video_set_attribute
	mov	si,offset intr_16h_halts_msg	; (' int 16h HLTs executed.')
	call	video_writestring
	mov	eax,dword ptr [esp+4]
	call	isr_16h_halt_2
	jmp	short loc_52
loc_51:
	mov	intr_16h_delay,0
	mov	intr_21h_delay,0
loc_52:
	pop	ds
	pop	si
	pop	eax
	jmp	dword ptr cs:old_intr_16h
isr_16h_2	endp

		db	90h
old_intr_14h	dd	0
new_intr_14h_1	dd	isr_14h_1
new_intr_14h_2	dd	isr_14h_2
		db	0, 0
		db	0, 0                                                 	
intr_14h_calls		dd	00000h                                          
intr_14h_halts		dd	00000h                                          
intr_14h_halts_msg	db	' int 14h HALTs executed.', 0
intr_14h_calls_msg	db	' int 14h calls.', 0

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

isr_14h_halt_1		proc	near
	push	ax
	sti				; Enable interrupts
loc_53:
	mov	ah,3
	pushf				; Push flags
	call	dword ptr cs:old_intr_14h
	test	ah,1
	jnz	short loc_54		; Jump if not zero
	hlt				; Halt processor
	inc	cs:intr_14h_calls
	jmp	short loc_53
loc_54:
	pop	ax
	retn
isr_14h_halt_1		endp

	nop

isr_14h_1	proc	far
	cmp	ah,2
	jne	short loc_55		; Jump if not equal
	call	isr_14h_halt_1
loc_55:
	jmp	dword ptr cs:old_intr_14h
isr_14h_1	endp

	xchg	bx,bx
	nop

isr_14h_2	proc	far
	push	eax
	push	si
	push	ds
	mov	ax,cs
	mov	ds,ax
	mov	al,2
	mov	ah,37h			; '7'
	call	video_set_pos
	mov	al,0Ch
	call	video_set_attribute
	mov	eax,intr_14h_halts
	inc	intr_14h_halts
	call	video_writedec
	mov	al,0Eh
	call	video_set_attribute
	mov	si,offset intr_14h_calls_msg	; (' int 14h calls.')
	call	video_writestring
	mov	eax,dword ptr [esp+4]
	cmp	ah,2
	jne	short loc_56		; Jump if not equal
	mov	ax,2
	call	video_set_pos
	mov	al,0Ch
	call	video_set_attribute
	mov	eax,intr_14h_calls
	call	video_writedec
	mov	al,0Eh
	call	video_set_attribute
	mov	si,offset intr_14h_halts_msg	; (' int 14h HALTs executed.')
	call	video_writestring
	call	isr_14h_halt_1
loc_56:
	pop	ds
	pop	si
	pop	eax
	jmp	dword ptr cs:old_intr_14h
isr_14h_2	endp

		db	90h
old_irq_01h		dd	00000h  		
new_irq_01h_1		dd	isr_01h_1		
new_irq_01h_2		dd	isr_01h_2		
irq_01h_calls		dd	0
irq_01h_calls_msg	db	' IRQ 01h calls.', 0

isr_01h_1	proc	far
	mov	dword ptr intr_16h_delay,0
	mov	dword ptr intr_21h_delay,0             	
	jmp	dword ptr cs:old_irq_01h
isr_01h_1	endp

	xchg	bx,bx
	xchg	bx,bx
	xchg	bx,bx
	nop

isr_01h_2	proc	far
	pushf
	call 	dword ptr cs:old_irq_01h
	push	eax
	push	si
	push	ds
	mov	ax,cs
	mov	ds,ax	
	mov	al,3
	mov	ah,37
	call	video_set_pos
	mov	al,0Ch
	call	video_set_attribute
	mov	eax, irq_01h_calls
	inc	irq_01h_calls
	call	video_writedec
	mov	al,0Eh
	call	video_set_attribute
	mov	si,offset irq_01h_calls_msg
	call	video_writestring
	mov	dword ptr intr_16h_delay,0
	mov	dword ptr intr_21h_delay,0
	pop	ds
	pop	si
	pop	eax
	iret
isr_01h_2	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

tsr_instcheck		proc	near
	push	bx
	xor	bx,bx			; Zero register
	int	2Dh			; ??INT Non-standard interrupt
	cmp	ax,TSR_ID
	sete	al			; Set byte if equal
	mov	ah,0
	pop	bx
	retn
tsr_instcheck		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

tsr_uninstall		proc	near
	push	bx
	mov	bx,ACTION_UNINSTALL
	int	2Dh			; ??INT Non-standard interrupt
	pop	bx
	retn
tsr_uninstall		endp

tsr_suspend	proc	near                       
	push	bx
	mov	bx,ACTION_SUSPEND
	int	2Dh			; ??INT Non-standard interrupt
	pop	bx
	retn
tsr_suspend	endp

tsr_reactivate	proc	near                        	
	push	bx
	mov	bx,ACTION_REACTIVATE
	int	2Dh			; ??INT Non-standard interrupt
	pop	bx
	retn
tsr_reactivate 	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

tsr_hookint		proc	near
	pushf				; Push flags
	pushad				; Save all regs
	push	es
	cli				; Disable interrupts
	xor	esi,esi			; Zero register
	mov	es,si
	mov	ecx, size intr_vec_struc                 			
	mov	si,vectors_hooked
	inc	vectors_hooked
	imul	esi,ecx			; reg = reg * reg
	add	si,offset intr_vectors	        
	mov	[(intr_vec_struc ptr [si]).number],bl                  		
	mov	[(intr_vec_struc ptr [si]).new_isr],eax                		
	xor	bh,bh			; Zero register
	shl	bx,2			; Shift w/zeros fill
	xchg	es:[bx],eax
	mov	[(intr_vec_struc ptr [si]).old_isr],eax  
	sti				; Enable interrupts
	pop	es
	popad				; Restore all regs
	popf				; Pop flags
	retn
tsr_hookint		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ


tsr_install		proc	near
	cli				; Disable interrupts
	mov	tsr_kernel_id,dx
	mov	tsr_psp_seg,bx
	mov	tsr_env_seg,ax
	xor	ax,ax			; Zero register
	mov	es,ax
	mov	eax,es:INTR_2DH_BIOS
	mov	dword ptr old_int_2dh,eax
	mov	eax,new_int_2dh
	mov	es:INTR_2DH_BIOS,eax
	mov	ax,tsr_env_seg
	call	mem_lrelease
	mov	ax,cx
	shr	ax,4			; Shift w/zeros fill
	add	ax,20h
	mov	dx,ax
	mov	ax,3100h
	int	21h			; DOS Services  ah=function 31h
					;  terminate & stay resident
					;   al=return code,dx=paragraphs
	ret
tsr_install		endp


KERNEL_NAME   equ "CPUidle for DOS"     ; Name of the kernel.
KERNEL_FILE   equ "DOSidle"             ; Name of the .exe (compiled) kernel.
KERNEL_ID     equ 0DEEDh                ; ID number of this program.

SYS_RAW         = 01h                   ;
SYS_VCPI        = 02h                   ; Flags for PM hosts driving the
SYS_DPMI        = 04h                   ; system.


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

tolower		proc	near
	cmp	al,41h			; 'A'
	jb	short loc_ret_57	; Jump if below
	cmp	al,5Ah			; 'Z'
	ja	short loc_ret_57	; Jump if above
	add	al,20h			; ' '

loc_ret_57:
	retn
tolower		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

toupper		proc	near
	cmp	al,61h			; 'a'
	jb	short loc_ret_58	; Jump if below
	cmp	al,7Ah			; 'z'
	ja	short loc_ret_58	; Jump if above
	sub	al,20h			; ' '

loc_ret_58:
	retn
toupper		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

islower		proc	near
	cmp	al,61h			; 'a'
	jb	short loc_59		; Jump if below
	cmp	al,7Ah			; 'z'
	ja	short loc_59		; Jump if above
	cmp	al,al
	jmp	short loc_ret_60
loc_59:
	cmp	al,61h			; 'a'

loc_ret_60:
	retn
islower		endp

isupper		proc	near			                        
	cmp	al,41h			; 'A'
	jb	short loc_61		; Jump if below
	cmp	al,5Ah			; 'Z'
	ja	short loc_61		; Jump if above
	cmp	al,al
	jmp	short loc_ret_62
loc_61:
	cmp	al,41h			; 'A'

loc_ret_62:
	retn
isupper		endp

tolower_test	proc	near			                        
	push	ax
	call	tolower
	call	islower
	pop	ax
	retn
tolower_test	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

isdigit		proc	near
	push	ax
	cmp	al,30h			; '0'
	jb	short loc_63		; Jump if below
	cmp	al,39h			; '9'
	ja	short loc_63		; Jump if above
	cmp	al,al
	jmp	short loc_64
loc_63:
	cmp	al,31h			; '1'
loc_64:
	pop	ax
	retn
isdigit		endp

ishex		proc	near                       
	push	ax
	call	isdigit
	jz	short loc_65		; Jump if zero
	call	toupper
	cmp	al,41h			; 'A'
	jb	short loc_66		; Jump if below
	cmp	al,46h			; 'F'
	ja	short loc_66		; Jump if above
loc_65:
	cmp	al,al
	jmp	short loc_67
loc_66:
	cmp	al,31h			; '1'
loc_67:
	pop	ax
	retn
ishex		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

iswhitespace	proc	near
	cmp	al,20h			; ' '
	je	short loc_ret_68	; Jump if equal
	cmp	al,9
	je	short loc_ret_68	; Jump if equal

loc_ret_68:
	retn
iswhitespace	endp

issign		proc	near                        
	cmp	al,2Eh			; '.'
	je	short loc_ret_69	; Jump if equal
	cmp	al,21h			; '!'
	je	short loc_ret_69	; Jump if equal
	cmp	al,3Fh			; '?'
	je	short loc_ret_69	; Jump if equal
	cmp	al,2Ch			; ','
	je	short loc_ret_69	; Jump if equal
	cmp	al,3Bh			; ';'
	je	short loc_ret_69	; Jump if equal
	cmp	al,3Ah			; ':'
	je	short loc_ret_69	; Jump if equal

loc_ret_69:
	retn
issign		endp

strchr		proc	near
	push	ax
	push	si
loc_70:
	mov	ah,[si]
	inc	si
	cmp	al,ah
	je	short loc_71		; Jump if equal
	test	ah,ah
	jnz	loc_70			; Jump if not zero
	inc	ah
loc_71:
	pop	si
	pop	ax
	retn
strchr		endp

strtolower	proc	near		                        	
	push	ax
	push	cx
	push	si
	mov	cx,0FFh

locloop_72:
	mov	al,[si]
	call	tolower
	mov	[si],al
	inc	si
	test	al,al
	loopnz	locloop_72		; Loop if zf=0, cx>0

	pop	si
	pop	cx
	pop	ax
	retn
strtolower	endp

strtoupper	proc	near			                        
	push	ax
	push	cx
	push	si
	mov	cx,0FFh

locloop_73:
	mov	al,[si]
	call	toupper
	mov	[si],al
	inc	si
	test	al,al
	loopnz	locloop_73		; Loop if zf=0, cx>0

	pop	si
	pop	cx
	pop	ax
	retn
strtoupper	endp

strlen		proc	near
	push	ax
	push	si
	mov	cx, 0FFh

locloop_74:
	mov	al,[si]
	inc	si
	test	al,al
	loopnz	locloop_74		; Loop if zf=0, cx>0

	neg	cx
	add	cx,0FFh
	pop	si
	pop	ax
	retn
strlen		endp

strspace	proc	near			                        
	push	ax
	push	cx
	mov	cx,0FFh
	dec	si

locloop_75:
	inc	si
	mov	al,[si]
	call	iswhitespace
	loopz	locloop_75		; Loop if zf=1, cx>0

	pop	cx
	pop	ax
	retn
strspace 	endp

strstr		proc	near				                        
	push	ax
	push	cx
	push	si
	push	di
	mov	cx,0FFh

locloop_76:
	mov	al,[si]
	cmp	al,es:[di]
	jne	short loc_77		; Jump if not equal
	test	al,al
	jz	short loc_77		; Jump if zero
	inc	si
	inc	di
	loop	locloop_76		; Loop if cx > 0

loc_77:
	pop	di
	pop	si
	pop	cx
	pop	ax
	retn
strstr		endp

strcpy		proc	near			                        
	push	ax
	push	cx
	push	si
	push	di
	mov	cx,0FFh

locloop_78:
	mov	al,[si]
	mov	es:[di],al
	inc	si
	inc	di
	test	al,al
	loopnz	locloop_78		; Loop if zf=0, cx>0

	pop	di
	pop	si
	pop	cx
	pop	ax
	retn
strcpy		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

local_switch		proc	near
	jmp	short loc_79
w1	dw	0
w2	dw	0
loc_79:
	push	dx
	push	si
	push	di
	mov	word ptr w1,0
	mov	word ptr w2,0
	mov	dh,al
	xor	ah,ah			; Zero register
	xor	bl,bl			; Zero register
	mov	dl,1
	movzx	cx,byte ptr es:[di]	; Mov w/zero extend
	jcxz	short loc_88		; Jump if cx=0

locloop_80:
	inc	di
	mov	al,es:[di]
	call	iswhitespace
	jz	short loc_81		; Jump if zero
	cmp	al,'-'			; '-'
	je	short loc_83		; Jump if equal
	jmp	short loc_82
loc_81:
	cmp	dl,2
	je	short loc_87		; Jump if equal
	mov	dl,1
	jmp	short loc_86
loc_82:
	inc	ah
	cmp	dl,1
	mov	dl,3
	jz	short loc_84		; Jump if zero
	jmp	short loc_86
loc_83:
	cmp	dl,2
	je	short loc_87		; Jump if equal
	mov	dl,2
loc_84:
	cmp	dh,bl
	jne	short loc_85		; Jump if not equal
	mov	w1,si
	mov	byte ptr w2,ah
loc_85:
	inc	bl
	mov	ah,1
	mov	si,di
loc_86:
	loop	locloop_80		; Loop if cx > 0

	cmp	dl,2
	je	short loc_87		; Jump if equal
	cmp	word ptr w2,0
	jne	short loc_88		; Jump if not equal
	mov	w1,si
	mov	byte ptr w2,ah
	jmp	short loc_88
loc_87:
	stc				; Set carry flag
	jmp	short loc_89
loc_88:
	mov	ah,bl
	mov	bx,w1
	mov	cx,w2
	mov	al,dh
	clc				; Clear carry flag
loc_89:
	pop	di
	pop	si
	pop	dx
	retn
local_switch		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

get_switch	proc	near
	push	ax
	push	bx
	mov	al,1
	call	local_switch
	mov	cl,ah
	mov	ch,0
	pop	bx
	pop	ax
	retn
get_switch	endp

get_switch_2	proc	near			                        
	push	ax
	push	cx
	call	local_switch
	pop	cx
	pop	ax
	retn
get_switch_2	endp

get_switch_3	proc	near				                        
	push	ax
	push	bx
	call	local_switch
	pop	bx
	pop	ax
	retn
get_switch_3	endp

get_switch_4	proc	near				                        
	push	ax
	push	bx
	push	cx
	push	si
	call	local_switch
	jc	short loc_91		; Jump if carry Set

locloop_90:
	mov	al,es:[bx]
	mov	[si],al
	inc	bx
	inc	si
	loop	locloop_90		; Loop if cx > 0

	clc				; Clear carry flag
loc_91:
	pop	si
	pop	cx
	pop	bx
	pop	ax
	retn
get_switch_4	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

compare_switch		proc	near
	push	ax
	push	bx
	push	cx
	push	si
	call	local_switch
	jc	short loc_94		; Jump if carry Set

locloop_92:
	mov	al,[si]
	call	tolower
	mov	ah,al
	mov	al,es:[bx]
	call	tolower
	cmp	al,ah
	jne	short loc_93		; Jump if not equal
	inc	si
	inc	bx
	loop	locloop_92		; Loop if cx > 0

	cmp	byte ptr [si],0
loc_93:
	clc				; Clear carry flag
loc_94:
	pop	si
	pop	cx
	pop	bx
	pop	ax
	retn
compare_switch		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

parse_cmdln		proc	near
	pusha				; Save all regs
	call	get_switch
	jc	short loc_99		; Jump if carry Set
	jcxz	short loc_98		; Jump if cx=0
	mov	al,1
	mov	bp,si

locloop_95:
	mov	bx,bp
	xor	dx,dx			; Zero register
loc_96:
	lea	si,[(par_item ptr [bx]).switch]			; Load effective addr
	call	compare_switch
	jc	short loc_99		; Jump if carry Set
	jnz	short loc_97		; Jump if not zero
	inc	dx
	call	word ptr [(par_item ptr [bx]).proc_offset]	;*
loc_97:
	add	bx,size par_item
	cmp	byte ptr [bx],0
	jne	loc_96			; Jump if not equal
	test	dx,dx
	jz	short loc_99		; Jump if zero
	inc	al
	loop	locloop_95		; Loop if cx > 0

loc_98:
	clc				; Clear carry flag
	jmp	short loc_100
loc_99:
	stc				; Set carry flag
loc_100:
	popa				; Restore all regs
	retn
parse_cmdln		endp

open_file	proc	near			                        
	push	ax
	mov	dx,si
	mov	ah,3Dh
	int	21h			; DOS Services  ah=function 3Dh
					;  open file, al=mode,name@ds:dx
	mov	dx,ax
	pop	ax
	retn
open_file	endp			                        

close_file	proc	near
	push	ax
	push	bx
	mov	bx,dx
	mov	ah,3Eh
	int	21h			; DOS Services  ah=function 3Eh
					;  close file, bx=file handle
	pop	bx
	pop	ax
	retn
close_file	endp

duplicate_handle 	proc	near	                        
	push	ax
	push	bx
	push	cx
	mov	cx,dx
	mov	bx,ax
	mov	ah,46h
	int	21h			; DOS Services  ah=function 46h
					;  force handle cx same as bx
	pop	cx
	pop	bx
	pop	ax
	retn
duplicate_handle	endp

set_handle_count	proc	near		                        
	push	ax
	push	bx
	mov	bx,ax
	mov	ah,67h
	int	21h			; DOS Services  ah=function 67h
					;  set maximum handles bx
	pop	bx
	pop	ax
	retn
set_handle_count	endp

read_file	proc	near			                        
	push	ax
	push	bx
	push	dx
	mov	bx,dx
	mov	dx,si
	mov	ah,3Fh
	int	21h			; DOS Services  ah=function 3Fh
					;  read file, bx=file handle
					;   cx=bytes to ds:dx buffer
	mov	cx,ax
	pop	dx
	pop	bx
	pop	ax
	retn
read_file	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

write_file	proc	near
	push	ax
	push	bx
	push	dx
	mov	bx,dx
	mov	dx,si
	mov	ah,40h
	int	21h			; DOS Services  ah=function 40h
					;  write file  bx=file handle
					;   cx=bytes from ds:dx buffer
	pop	dx
	pop	bx
	pop	ax
	retn
write_file	endp

local_readstr	proc	near			                        
	push	ax
	push	cx
	push	si
	mov	cx,0FFh

locloop_101:
	call	local_readch
	mov	[si],al
	inc	si
	cmp	al,0
	loopnz	locloop_101		; Loop if zf=0, cx>0

	pop	si
	pop	cx
	pop	ax
	retn
local_readstr	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

local_writestr		proc	near
	push	ax
	push	cx
	push	si
	mov	cx,0FFh

locloop_102:
	mov	al,[si]
	cmp	al,0
	je	short loc_103		; Jump if equal
	call	local_writech
	inc	si
	loop	locloop_102		; Loop if cx > 0

loc_103:
	pop	si
	pop	cx
	pop	ax
	retn
local_writestr	endp

local_readln	proc	near			                        
	push	ax
	push	cx
	push	si      	
	mov	cx,0FFh

locloop_104:
	call	local_readch
	cmp	al,0Dh
	je	short loc_105		; Jump if equal
	mov	[si],al
	inc	si
	loop	locloop_104		; Loop if cx > 0

loc_105:
	mov	byte ptr [si],0
	pop	si
	pop	cx
	pop	ax
	retn
local_readln	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

local_writeln		proc	near
	push	ax
	call	local_writestr
	mov	al,0Dh
	call	local_writech
	mov	al,0Ah
	call	local_writech
	pop	ax
	retn
local_writeln		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

local_readch	proc	near
	push	bx
	push	cx
	push	dx
	push	ds
	mov	bx,dx
	mov	cx,1
	sub	sp,2
	mov	ax,ss
	mov	ds,ax
	mov	dx,sp
	mov	ah,3Fh
	int	21h			; DOS Services  ah=function 3Fh
					;  read file, bx=file handle
					;   cx=bytes to ds:dx buffer
	pop	ax
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	retn
local_readch	endp

                                	
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

local_writech		proc	near
	push	bx
	push	cx
	push	dx
	push	ds
	push	ax
	mov	bx,dx
	mov	cx,1
	mov	ax,ss
	mov	ds,ax
	mov	dx,sp
	mov	ah,40h
	int	21h			; DOS Services  ah=function 40h
					;  write file  bx=file handle
					;   cx=bytes from ds:dx buffer
	pop	ax
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	retn
local_writech		endp

hex_table	db	'0123456789ABCDEF'	; Data table (indexed access)
		db	0C3h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

local_writedec		proc	near
	push	eax
	push	ebx
	push	cx
	push	edx
	push	si
	mov	ebx,0Ah
	mov	si,dx
	xor	cx,cx			; Zero register

loc_106:
	xor	edx,edx			; Zero register
	div	ebx			; ax,dx rem=dx:ax/reg
	push	dx
	inc	cl
	test	eax,eax
	jnz	loc_106			; Jump if not zero
	mov	dx,si

locloop_107:
	pop	bx
	mov	al,byte ptr cs:hex_table[bx]	; ('0123456789ABCDEF')
	call	local_writech
	loop	locloop_107		; Loop if cx > 0

	pop	si
	pop	edx
	pop	cx
	pop	ebx
	pop	eax
	retn
local_writedec		endp

		db	0C3h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

local_writehex		proc	near
	push	ax
	push	ebx
	push	cx
	push	si
	mov	ebx,eax
	mov	cx,8
	mov	al,30h			; '0'
	call	local_writech
	mov	al,78h			; 'x'
	call	local_writech

locloop_108:
	rol	ebx,4			; Rotate
	mov	si,bx
	and	si,0Fh
	mov	al,byte ptr cs:hex_table[si]	; ('0123456789ABCDEF')
	call	local_writech
	loop	locloop_108		; Loop if cx > 0

	pop	si
	pop	cx
	pop	ebx
	pop	ax
	retn
local_writehex		endp

test_writefile	proc	near
	push	dx
	mov	dx,1
	call	write_file
	pop	dx
	retn
test_writefile	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

com_writef		proc	near
	push	dx
	mov	dx,1
	call	local_writestr
	pop	dx
	retn
com_writef		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

com_writeln		proc	near
	push	dx
	mov	dx,1
	call	local_writeln
	pop	dx
	retn
com_writeln		endp

com_writech	proc	near		                        
	push	dx
	mov	dx,1
	call	local_writech
	pop	dx
	retn
com_writech	endp			                        		

com_writedec    proc	near
	push	dx
	mov	dx,1
	call	local_writedec
	pop	dx
	retn
com_writedec  	endp

com_writehex	proc	near		                        
	push	dx
	mov	dx,1
	call	local_writehex
	pop	dx
	retn
com_writehex  	endp

init_video	proc	near			                        
	push	ax
	call	get_video_state
	call	set_video_state
	pop	ax
	retn
init_video	endp
		                                                                              
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß                   
;                              SUBROUTINE                                                     
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

get_video_state	proc	near
	push	bx
	mov	ah,0Fh
	int	10h			; Video display   ah=functn 0Fh
					;  get state, al=mode, bh=page
					;   ah=columns on screen
	pop	bx
	retn
get_video_state	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

set_video_state	proc	near
	xor	ah,ah			; Zero register
	int	10h			; Video display   ah=functn 00h
					;  set display mode in al
	retn
set_video_state	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

video_get_page		proc	near
	push	bx
	mov	ah,0Fh
	int	10h			; Video display   ah=functn 0Fh
					;  get state, al=mode, bh=page
					;   ah=columns on screen
	mov	al,bh
	pop	bx
	retn
video_get_page		endp

video_set_page		proc	near			                        
	mov	ah,5
	int	10h			; Video display   ah=functn 05h
					;  set display page al
	retn
video_set_page	endp

test_video_get_set_page	proc 	near			                        
	push	bx
	push	cx
	push	dx
	call	video_get_page
	mov	bh,al
	mov	ah,5
	int	10h			; Video display   ah=functn 05h
					;  set display page al
	mov	al,dh
	mov	ah,dl
	pop	dx
	pop	cx
	pop	bx
	retn
test_video_get_set_page	endp			                        

video_set_cursor_pos	proc	near
	mov	dh,al
	mov	dl,ah
	call	video_get_page
	mov	bh,al
	mov	ah,2
	int	10h			; Video display   ah=functn 02h
					;  set cursor location in dx
	retn
video_set_cursor_pos	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

test_cpu		proc	near
	pushf				; Push flags
	push	bx
	push	cx
	push	ax
	pushf				; Push flags
	pop	ax
	mov	cx,ax
	and	ax,0FFFh
	push	ax
	popf				; Pop flags
	pushf				; Push flags
	pop	ax
	and	ax,0F000h
	cmp	ax,0F000h
	mov	al,0
	jz	short loc_109		; Jump if zero
	or	cx,0F000h
	push	cx
	popf				; Pop flags
	pushf				; Push flags
	pop	ax
	and	ax,0F000h
	mov	al,2
	jz	short loc_109		; Jump if zero
	mov	bx,sp
	and	sp,0FFFCh
	pushfd				; Push flags
	pop	eax
	mov	ecx,eax
	xor	eax,40000h
	push	eax
	popfd				; Pop flags
	pushfd				; Push flags
	pop	eax
	mov	sp,bx
	xor	eax,ecx
	mov	al,3
	jz	short loc_109		; Jump if zero
	and	sp,0FFFCh
	push	ecx
	popfd				; Pop flags
	mov	sp,bx
	mov	eax,ecx
	xor	eax,200000h
	push	eax
	popfd				; Pop flags
	pushfd				; Push flags
	pop	eax
	xor	eax,ecx
	mov	al,4
	jz	short loc_109		; Jump if zero
	mov	eax,1
	cpuid				; get ID into ebx
	and	ax,0F00h
	shr	ax,8			; Shift w/zeros fill
loc_109:
	mov	bl,al
	pop	ax
	mov	al,bl
	pop	cx
	pop	bx
	popf				; Pop flags
	retn
test_cpu		endp

test_fpu	proc	near
	jmp	short loc_fpu 
	w3	dw	0       
loc_fpu:
	push	bx 
	push	ax
	fninit				; Initialize math uP
	mov	ds:[w3],5A5Ah
	fnstsw	ds:[w3]	; Store status word
	mov	bl,0
	cmp	ds:[w3],0
	jne	short loc_110	; Jump if not equal
	fnstcw	ds:[w3]	; Store control word
	mov	ax, ds:[w3]
	and	ax,103Fh
	cmp	ax,3Fh
	mov	bl,0
	jnz	short loc_110	; Jump if not zero
	call	test_cpu
	mov	bl,al
	cmp	al,3
	jne	short loc_110	; Jump if not equal
	fld1				; Push +1.0 to stack
	fldz				; Push +0.0 to stack
	fdivp	st(1),st		; st(#)=st(#)/st, pop
	fld	st			; Push onto stack
	fchs				; Change sign in st
	fcompp				; Compare st & pop 2
	wait
	fnstsw	ds:[w3]	; Store status word
	mov	ax, ds:[w3]
	mov	bl,2
	sahf				; Store ah into flags
	jz	short loc_110	; Jump if zero
	mov	bl,3
loc_110:
	pop	ax
	mov	al,bl
	pop	bx
	retn
test_fpu	endp

test_himem	proc	near			                        
	push	ax
	mov	ax,4300h
	int	2Fh			; HIMEM.SYS installed state, al
	cmp	al,80h
	pop	ax
	retn
test_himem	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

EMS_BIOS	= 019Ch ;67h * 4	;INTR 67H LIM EMS

test_vcpi		proc	near
	push	ax
	push	bx
	push	es
	xor	ax,ax			; Zero register
	mov	es,ax
	cmp	dword ptr es:EMS_BIOS,0
	sete	ah			; Set byte if equal
	jz	short loc_111		; Jump if zero
	mov	ax,0DE00h
	int	67h			; EMS Memory        ah=func DEh
					;  VCPI active  ah=1, bx=version
loc_111:
	test	ah,ah
	pop	es
	pop	bx
	pop	ax
	retn
test_vcpi		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

test_dpmi		proc	near
	pusha				; Save all regs
	push	es
	mov	ax,1687h
	int	2Fh			; ??INT Non-standard interrupt
	test	ax,ax
	jnz	short loc_112		; Jump if not zero
	cmp	bl,1
loc_112:
	pop	es
	popa				; Restore all regs
	retn
test_dpmi		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

test_v86		proc	near
	push	ax
	smsw	ax			; Store machine stat
	and	al,1
	cmp	al,1
	pop	ax
	retn
test_v86		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

irq_getpic	proc	near
	mov	bx,7008h
	retn
irq_getpic	endp

sub_a		proc	near			                        
	push	ax
	push	bx
	pushf				; Push flags
	cli				; Disable interrupts
	in	al,0A1h			; port 0A1h, 8259-2 int IMR
	mov	ah,al
	jmp	short $+2		; delay for I/O
	jmp	short $+2		; delay for I/O
	in	al,21h			; port 21h, 8259-1 int IMR
	push	ax
	mov	al,11h
	out	20h,al			; port 20h, 8259-1 int command
	jmp	short $+2		; delay for I/O
	jmp	short $+2		; delay for I/O
	out	0A0h,al			; port 0A0h, 8259-2 int command
					;  al = 11h, initialize, 4 byte
	jmp	short $+2		; delay for I/O
	jmp	short $+2		; delay for I/O
	mov	al,bl
	out	21h,al			; port 21h, 8259-1 int comands
	jmp	short $+2		; delay for I/O
	jmp	short $+2		; delay for I/O
	mov	al,bh
	out	0A1h,al			; port 0A1h, 8259-2 int comands
	jmp	short $+2		; delay for I/O
	jmp	short $+2		; delay for I/O
	mov	al,4
	out	21h,al			; port 21h, 8259-1 int comands
					;  al = 4, inhibit IRQ2
	jmp	short $+2		; delay for I/O
	jmp	short $+2		; delay for I/O
	mov	al,2
	out	0A1h,al			; port 0A1h, 8259-2 int comands
					;  al = 2, inhibit IRQ9
	jmp	short $+2		; delay for I/O
	jmp	short $+2		; delay for I/O
	mov	al,1
	out	21h,al			; port 21h, 8259-1 int comands
					;  al = 1, inhibit IRQ0 timer
	jmp	short $+2		; delay for I/O
	jmp	short $+2		; delay for I/O
	out	0A1h,al			; port 0A1h, 8259-2 int comands
					;  al = 1, inhibit IRQ8 RTC
	jmp	short $+2		; delay for I/O
	jmp	short $+2		; delay for I/O
	pop	ax
	out	21h,al			; port 21h, 8259-1 int comands
	jmp	short $+2		; delay for I/O
	jmp	short $+2		; delay for I/O
	mov	al,ah
	out	0A1h,al			; port 0A1h, 8259-2 int comands
	popf				; Pop flags
	clc				; Clear carry flag
	pop	bx
	pop	ax
	retn
sub_a		endp

sub_b		proc	near			                        
	push	ax
	push	cx
	mov	cl,al
	in	al,0A1h			; port 0A1h, 8259-2 int IMR
	mov	ah,al
	in	al,21h			; port 21h, 8259-1 int IMR
	shr	ax,cl			; Shift w/zeros fill
	and	al,1
	mov	bl,1
	sub	bl,al
	pop	cx
	pop	ax
	retn
sub_b		endp

sub_c		proc	near			                        
	push	ax
	push	bx
	push	cx
	mov	cl,1
	xchg	bl,cl
	sub	bl,cl
	mov	cl,al
	in	al,0A1h			; port 0A1h, 8259-2 int IMR
	mov	ah,al
	in	al,21h			; port 21h, 8259-1 int IMR
	shr	ax,cl			; Shift w/zeros fill
	and	ax,0FFFEh
	and	bx,1
	or	ax,bx
	shl	ax,cl			; Shift w/zeros fill
	out	21h,al			; port 21h, 8259-1 int comands
					;  al = 1, inhibit IRQ0 timer
	mov	al,ah
	out	0A1h,al			; port 0A1h, 8259-2 int comands
	pop	cx
	pop	bx
	pop	ax
	retn
sub_c		endp

sub_d		proc	near
	push	cx
	push	di
loc_113:
	mov	cx,8
	mov	ax,di

locloop_114:
	cmp	dword ptr es:[di],0
	lea	di,[di+4]		; Load effective addr
	loopz	locloop_114		; Loop if zf=1, cx>0

	jz	short loc_115		; Jump if zero
	mov	di,ax
	add	di,20h
	cmp	di,3E0h
	jbe	loc_113			; Jump if below or =
	stc				; Set carry flag
	jmp	short loc_116
loc_115:
	shr	ax,2			; Shift w/zeros fill
	clc				; Clear carry flag
loc_116:
	pop	di
	pop	cx
	retn
sub_d		endp

copy64bytes	proc	near
	pushf				; Push flags
	pusha				; Save all regs
	push	es
	cli				; Disable interrupts
	xor	cx,cx			; Zero register
	mov	es,cx
	movzx	si,ah			; Mov w/zero extend
	movzx	di,al			; Mov w/zero extend
	shl	si,2			; Shift w/zeros fill
	shl	di,2			; Shift w/zeros fill
	mov	cx,8

locloop_117:
	mov	eax,es:[si]
	mov	es:[di],eax
	add	si,4
	add	di,4
	loop	locloop_117		; Loop if cx > 0

	pop	es
	popa				; Restore all regs
	popf				; Pop flags
	retn
copy64bytes	endp

zero64bytes	proc	near
	pushf				; Push flags
	push	cx
	push	di
	push	es
	cli				; Disable interrupts
	xor	cx,cx			; Zero register
	mov	es,cx
	movzx	di,al			; Mov w/zero extend
	shl	di,2			; Shift w/zeros fill
	mov	cx,8

locloop_118:
	mov	dword ptr es:[di],0
	add	di,4
	loop	locloop_118		; Loop if cx > 0

	pop	es
	pop	di
	pop	cx
	popf				; Pop flags
	retn
zero64bytes	endp

	xchg	bx,bx
	nop	

v86_callback	dd	0

win386_v86_callback_init	proc	near
	pushad				; Save all regs
	push	ds es
	mov	ax,1605h
	xor	bx,bx			; Zero register
	mov	es,bx
	xor	si,si			; Zero register
	mov	ds,si
	xor	dx,dx			; Zero register
	xor	cx,cx			; Zero register
	mov	di,30Bh
	int	2Fh			; Windows init broadcast
	test	cx,cx
	jnz	short loc_119a		; Jump if not zero
	mov	word ptr cs:v86_callback,si
	mov	word ptr cs:v86_callback+2,ds
	cmp	dword ptr cs:v86_callback,0
	je	short loc_119a		; Jump if equal
	cli				; Disable interrupts
	xor	ax,ax			; Zero register
	call	dword ptr cs:v86_callback
	jc	short loc_119a		; Jump if carry Set
	clc				; Clear carry flag
	jmp	short loc_119b
loc_119a:
	mov	ax,1606h
	xor	dx,dx			; Zero register
	int	2Fh			; Windows exit broadcast
	stc				; Set carry flag
loc_119b:
	pop	es ds
	popad				; Restore all regs
	retn
win386_v86_callback_init	endp

win386_v86_callback_exit	proc	near
	pushad				; Save all regs
	push	ds es
	cmp	dword ptr cs:v86_callback,0
	je	short loc_119e		; Jump if equal
	cli				; Disable interrupts
	mov	ax,1
	call	dword ptr cs:v86_callback
	mov	ax,1606h
	xor	dx,dx			; Zero register
	int	2Fh			; Windows exit broadcast
loc_119e:
	pop	es ds
	popad				; Restore all regs
	retn
win386_v86_callback_exit	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vcpi_getpic	proc	near
	push	bx
	mov	ax,0DE00h
	int	67h			; EMS Memory        ah=func DEh
					;  VCPI active  ah=1, bx=version
	call	clear_if_zero
	mov	ax,bx
	pop	bx
	retn
vcpi_getpic	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vcpi_get_intr		proc	near
	push	ax
	push	cx
	mov	ax,0DE0Ah
	int	67h			; EMS Memory        ah=func DEh
					;  VCPI get int vector maps
	mov	bh,cl
	call	clear_if_zero
	pop	cx
	pop	ax
	retn
vcpi_get_intr		endp

vcpi_set_intr	proc	near                        
	pushf				; Push flags
	push	ax
	push	cx
	cli				; Disable interrupts
	xor	cx,cx			; Zero register
	xchg	bh,cl
	mov	ax,0DE0Bh
	int	67h			; EMS Memory        ah=func DEh
					;  VCPI set int vector maps
	call	clear_if_zero
	pop	cx
	pop	ax
	popf				; Pop flags
	retn
vcpi_set_intr	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

clear_if_zero	proc	near
	test	ah,ah
	clc				; Clear carry flag
	jz	short loc_ret_120	; Jump if zero
	stc				; Set carry flag

loc_ret_120:
	retn
clear_if_zero	endp

psp_seg		dw	0			; segment storage
env_seg		dw	0
sys_type		db	1
par_table	par_item <"/H", par_help>                         		
		par_item <"/?", par_help>                         
		par_item <"/U", par_uninst>                       
       		par_item <"/TM", par_testmode>                          
      		par_item <"/NF", par_forcemode>                        
	       	par_item <0>            		; Marks end of par_table. ar_table.

msg_proginfo	db	'CPUIdle for DOS V1.32 [Beta]', 0Dh, 0Ah
		db	'Copyright (C) by Marton Balog, 1998.', 0Dh, 0Ah, 0
msg_progsyntax	db	'Syntax:    DOSIDLE [Options]', 0Dh, 0Ah, 0Dh, 0Ah
		db	'Options:   /U      Uninstall CPUIdle for DOS.', 0Dh, 0Ah
		db	'           /TM     Enable Test Mode (disabled by default).', 0Dh, 0Ah
		db	'           /NF     Disable Force Mode (enabled by default).', 0Dh, 0Ah
		db	'           /H, /?  Display this help message.', 0Dh, 0Ah, 0
msg_progexample	db	'Example:   DOSIDLE     Install CPUIdle for DOS.', 0Dh, 0Ah
		db	'           DOSIDLE /U  Uninstall CPUIdle for DOS.', 0Dh, 0Ah, 0
msg_inst	db	'CPUIdle for DOS installed successfully.', 00h
msg_uninst	db	'CPUIdle for DOS uninstalled successfully.', 0
warn_VCPI	db	'WARNING: VCPI host detected.', 0
warn_DPMI	db	'WARNING: DPMI host detected.', 0

err_str      	db	'FATAL ', 9
err_resize   	db	'[#10]: Failed to resize program memory.', 0
err_notinst    	db	'[#20]: CPUIdle for DOS is not installed.', 0
err_inst   	db	'[#21]: CPUIdle for DOS is already installed.', 0
err_uninst 	db	'[#22]: Failed to uninstall CPUIdle for DOS.', 0Dh, 0Ah
err_tsr  	db	'Another TSR program has been installed over it.', 0
err_cpu      	db	'[#30]: A 386 CPU or better is required.', 0
err_display 	db	'[#31]: 80 Column color display is required for Test Mode.', 0
err_cmdln    	db	'[#40]: Invalid command-line switch.', 0
err_v86      	db	'[#50]: CPU in V86 mode and no VCPI or DPMI host present.', 0
loc_121:
	push	si
	mov	si,offset err_str
	call	com_writef
	pop	si
	sti				; Enable interrupts
	call	com_writeln
	mov	ax,4C00h
	int	21h			; DOS Services  ah=function 4Ch
					;  terminate with al=return code
	retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

init		proc	near
	cli				; Disable interrupts
	mov	ax,cs
	mov	ds,ax
	mov	psp_seg,es
	mov	ax,es:PSP_envirn_seg
	mov	env_seg,ax
	mov	si,offset msg_proginfo	; ('CPUIdle for DOS V1.32 [B')
	call	com_writeln
	call	test_cpu
	mov	si,offset err_cpu
	cmp	al,3
	jb	loc_121			; Jump if below
	xor	ax,ax			; Zero register
	mov	gs,ax
	sti				; Enable interrupts
	retn
init		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ


par_help	proc	near
	mov	si,offset msg_progsyntax; ('Syntax:    DOSIDLE [Opti')
	call	com_writeln
	mov	si,offset msg_progexample ; ('Example:   DOSIDLE     I')
	call	com_writeln
	mov	ax,4C00h
	int	21h			; DOS Services  ah=function 4Ch
	retn				;  terminate with al=return code
par_help	endp

par_uninst	proc	near			                        
	mov	dx,KERNEL_ID
	call	tsr_instcheck
	mov	si,offset err_notinst
	test	ax,ax
	jz	loc_121			; Jump if zero
	mov	dx,KERNEL_ID
	call	tsr_uninstall
	mov	si,offset err_uninst
	test	ax,ax
	jz	loc_121			; Jump if zero
	mov	si,offset msg_uninst	; ('CPUIdle for DOS uninstal')
	call	com_writeln
	mov	ax,4C00h
	int	21h			; DOS Services  ah=function 4Ch
par_uninst	endp					;  terminate with al=return code

par_testmode	proc	near                       
	xor	ax,ax			; Zero register
	int	11h			; Put equipment bits in ax
	and	al,30h			; '0'
	cmp	al,20h			; ' '
	mov	si,offset err_display      
	jnz	loc_121			; Jump if not zero
	or	idle_mode,IDLE_MODE_1
	retn
par_testmode	endp
	
par_forcemode	proc	near	                        
	or	idle_mode,IDLE_MODE_2
	retn
par_forcemode	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

read_cmdln	proc	near
	mov	di,80h			;PSP:80h => commandline
	mov	es,psp_seg
	mov	si,offset par_table
	call	parse_cmdln
	mov	si,offset err_cmdln
	jc	loc_121			; Jump if carry Set
	retn
read_cmdln	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

check_system		proc	near
	call	test_vcpi
	jnz	short loc_122		; Jump if not zero
	mov	si,offset warn_VCPI	; ('WARNING: VCPI host detec')
	call	com_writeln
	mov	sys_type,SYS_VCPI
	jmp	short loc_ret_124
loc_122:
	call	test_dpmi
	jnz	short loc_123		; Jump if not zero
	mov	si,offset warn_DPMI	; ('WARNING: DPMI host detec')
	call	com_writeln
	mov	sys_type,SYS_DPMI
	jmp	short loc_ret_124
loc_123:
	call	test_v86
	mov	si,offset err_v86
	jz	loc_121			; Jump if zero

loc_ret_124:
	retn
check_system		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

hook_ints		proc	near
	mov	eax,gs:INTR_14H_BIOS
	mov	old_intr_14h,eax
	mov	eax,gs:INTR_16H_BIOS
	mov	old_intr_16h,eax
	mov	eax,gs:INTR_21H_BIOS
	mov	old_intr_21h,eax
	test	idle_mode,IDLE_MODE_1
	jnz	short loc_125		; Jump if not zero
	mov	eax,new_intr_14h_1
	mov	bl,14h                                          	
	call	tsr_hookint                                            	
	mov	eax,new_intr_16h_1                                     	
	mov	bl,16h
	call	tsr_hookint
	mov	eax,new_intr_21h_1
	mov	bl,21h			; '!'
	call	tsr_hookint
	jmp	short loc_ret_126
loc_125:
	mov	eax,new_intr_14h_2
	mov	bl,14h
	call	tsr_hookint
	mov	eax,new_intr_16h_2
	mov	bl,16h
	call	tsr_hookint
	mov	eax,new_intr_21h_2
	mov	bl,21h			; '!'
	call	tsr_hookint

loc_ret_126:
	retn
hook_ints	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

hook_irqs	proc	near
	cli				; Disable interrupts
	cmp	sys_type,SYS_VCPI
	jne	short loc_127		; Jump if not equal
	call	vcpi_get_intr
	jmp	short loc_129
loc_127:
	cmp	sys_type,SYS_DPMI
	jne	short loc_128		; Jump if not equal
	call	irq_getpic
	jmp	short loc_129
loc_128:
	call	irq_getpic
loc_129:
	movzx	ebx,bl			; Mov w/zero extend
	inc	ebx
	mov	eax,dword ptr gs:[ebx*4]
	mov	old_irq_01h,eax
	test	idle_mode,IDLE_MODE_1
	jnz	short loc_130		; Jump if not zero
	mov	eax,new_irq_01h_1
	call	tsr_hookint
	jmp	short loc_131
loc_130:
	mov	eax,new_irq_01h_2
	call	tsr_hookint
loc_131:
	sti				; Enable interrupts
	retn
hook_irqs	endp


;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;
;                       Program	Entry Point
;
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ


main	proc	far
	call	init
	call	read_cmdln
	mov	dx,KERNEL_ID
	call	tsr_instcheck
	mov	si,offset err_inst
	cmp	ax,1
	jz	loc_121			; Jump if zero
	call	check_system
	call	hook_ints
	call	hook_irqs
	mov	si,offset msg_inst	; ('CPUIdle for DOS installe')
	call	com_writeln
	mov	cx,8B8h
	mov	dx,KERNEL_ID
	mov	bx,psp_seg
	mov	ax,env_seg
	call	tsr_install			; Sub does not return here
	db	15 dup (0)

main	endp

seg_a	ends



;------------------------------------------------------  stack_seg_b   ----

stack_seg_b	segment	word stack 'STACK' use16

		db	800 dup (0)

stack_seg_b	ends



		end	main
