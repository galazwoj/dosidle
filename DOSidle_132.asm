
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				DOSIDLE1                                 €€
;€€					                                 €€
;€€      Created:   11-Jul-100		                                 €€
;€€      Passes:    9          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'M6'                      ; Target assembler: MASM-6.0

include  srmacros.inc

.486p

.387


; The following equates show data references outside the range of the program.

data_1e		equ	0B4h
data_2e		equ	19Ch
data_3e		equ	3E0h
PSP_envirn_seg	equ	2Ch
data_4e		equ	3Fh
data_5e		equ	12ABh			;*
data_78e	equ	0B800h

;------------------------------------------------------------  seg_a   ----

seg_a		segment	byte public use16
		assume cs:seg_a  , ds:seg_a , ss:stack_seg_b

		db	53h
data_6		db	8Bh
		db	0D9h,0B4h, 48h,0CDh, 21h, 5Bh
		db	0C3h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		push	ax
		push	es
		mov	es,ax
		mov	ah,49h
		int	21h			; DOS Services  ah=function 49h
						;  release memory block, es=seg
		pop	es
		pop	ax
		retn
sub_2		endp

			                        ;* No entry point to code
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
			                        ;* No entry point to code
		push	bx
		mov	bx,0FFFFh
		mov	ah,48h
		int	21h			; DOS Services  ah=function 48h
						;  allocate memory, bx=bytes/16
		mov	ax,bx
		mov	cx,bx
		pop	bx
		retn
data_8		dw	0
data_9		dw	0
data_10		dw	0
data_11		dd	94FF01E7h
data_12		db	0, 0, 0, 0
data_13		db	0
		db	16 dup (0)
data_14		dd	00000h
		db	0, 0, 0, 0
data_15		dd	00000h
		db	36 dup (0)
data_16		db	0
		db	0, 0, 0
data_17		dd	00000h
		db	197 dup (0)
data_18		dw	0
data_19		db	0
		db	149 dup (0)
data_20		dw	0
		db	 2Eh, 3Bh, 16h, 31h, 00h, 74h
		db	 05h
loc_2::
		jmp	dword ptr cs:data_12
			                        ;* No entry point to code
		cmp	bx,0
		jne	short loc_3		; Jump if not equal
		mov	ax,0FEADh
		sti				; Enable interrupts
		iret				; Interrupt return
loc_3::
		cmp	bx,1
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
		mov	eax,data_11
		cmp	es:data_1e,eax
		jne	short loc_8		; Jump if not equal
		mov	si,offset data_13
		mov	cx,data_18
		test	cx,cx
		jz	short loc_7		; Jump if zero

locloop_4::
		movzx	di,byte ptr [si]	; Mov w/zero extend
		shl	di,2			; Shift w/zeros fill
		mov	eax,[si+1]
		cmp	es:[di],eax
		je	short loc_5		; Jump if equal
		mov	eax,[si+5]
		cmp	es:[di],eax
		jne	short loc_8		; Jump if not equal
loc_5::
		add	si,9
		loop	locloop_4		; Loop if cx > 0

		mov	si,offset data_13
		mov	cx,data_18

locloop_6::
		mov	eax,[si+1]
		movzx	di,byte ptr [si]	; Mov w/zero extend
		shl	di,2			; Shift w/zeros fill
		mov	es:[di],eax
		add	si,9
		loop	locloop_6		; Loop if cx > 0

loc_7::
		mov	eax,dword ptr data_12
		mov	es:data_1e,eax
		mov	ax,data_9
		call	sub_2
		mov	ax,1
		jmp	short loc_9
loc_8::
		xor	ax,ax			; Zero register
loc_9::
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	cx
		sti				; Enable interrupts
		iret				; Interrupt return
loc_10::
		cmp	bx,2
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
		cmp	data_20,0
		jne	short loc_13		; Jump if not equal
		mov	si,offset data_13
		mov	di,offset data_19
		mov	cx,data_18
		mov	data_20,cx
		test	cx,cx
		jz	short loc_12		; Jump if zero

locloop_11::
		mov	ebx,[si+5]
		ror	ebx,10h			; Rotate
		mov	es,bx
		rol	ebx,10h			; Rotate
		mov	al,es:[bx]
		mov	[di],al
		mov	eax,es:[bx+1]
		mov	[di+1],eax
		mov	eax,[si+1]
		mov	byte ptr es:[bx],0EAh
		mov	es:[bx+1],eax
		add	si,9
		add	di,5
		loop	locloop_11		; Loop if cx > 0

loc_12::
		mov	ax,1
		jmp	short loc_14
loc_13::
		xor	ax,ax			; Zero register
loc_14::
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	cx
		pop	ebx
		sti				; Enable interrupts
		iret				; Interrupt return
loc_15::
		cmp	bx,3
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
		cmp	data_20,0
		je	short loc_18		; Jump if equal
		mov	si,offset data_13
		mov	di,offset data_19
		mov	cx,data_18
		mov	data_20,0
		test	cx,cx
		jz	short loc_17		; Jump if zero

locloop_16::
		mov	ebx,[si+5]
		ror	ebx,10h			; Rotate
		mov	es,bx
		rol	ebx,10h			; Rotate
		mov	al,[di]
		mov	es:[bx],al
		mov	eax,[di+1]
		mov	es:[bx+1],eax
		add	si,9
		add	di,5
		loop	locloop_16		; Loop if cx > 0

loc_17::
		mov	ax,1
		jmp	short loc_19
loc_18::
		xor	ax,ax			; Zero register
loc_19::
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	cx
		pop	ebx
		sti				; Enable interrupts
		iret				; Interrupt return
data_21		db	'0123456789ABCDEF'	; Data table (indexed access)
data_22		dw	0
data_23		db	0Eh

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
		push	ax
		push	si
		push	es
		mov	ax,0B800h
		mov	es,ax
loc_20::
		mov	al,[si]
		test	al,al
		jz	short loc_21		; Jump if zero
		call	sub_4
		inc	si
		jmp	short loc_20
loc_21::
		pop	es
		pop	si
		pop	ax
		retn
sub_3		endp

			                        ;* No entry point to code
		push	ax
		call	sub_3
		call	sub_8
		inc	al
		call	sub_9
		pop	ax
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4		proc	near
		push	ax
		push	di
		mov	di,data_78e
		mov	es,di
		mov	di,data_22
		mov	ah,data_23
		mov	es:[di],ax
		add	data_22,2
		pop	di
		pop	ax
		retn
sub_4		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_5		proc	near
		push	eax
		push	ebx
		push	cx
		push	edx
		push	es
		mov	bx,0B800h
		mov	es,bx
		mov	ebx,0Ah
		xor	cx,cx			; Zero register
loc_22::
		xor	edx,edx			; Zero register
		div	ebx			; ax,dx rem=dx:ax/reg
		push	dx
		inc	cl
		test	eax,eax
		jnz	loc_22			; Jump if not zero

locloop_23::
		pop	bx
		mov	al,byte ptr data_21[bx]	; ('0123456789ABCDEF')
		call	sub_4
		loop	locloop_23		; Loop if cx > 0

		pop	es
		pop	edx
		pop	cx
		pop	ebx
		pop	eax
		retn
sub_5		endp

			                        ;* No entry point to code
		push	ax
		push	ebx
		push	cx
		push	si
		push	es
		mov	bx,0B800h
		mov	es,bx
		mov	ebx,eax
		mov	cx,8

locloop_24::
		rol	ebx,4			; Rotate
		mov	si,bx
		and	si,0Fh
		test	si,si
		loopz	locloop_24		; Loop if zf=1, cx>0

		jcxz	short loc_26		; Jump if cx=0
		ror	ebx,4			; Rotate
		inc	cx

locloop_25::
		rol	ebx,4			; Rotate
		mov	si,bx
		and	si,0Fh
		mov	al,byte ptr data_21[si]	; ('0123456789ABCDEF')
		call	sub_4
		loop	locloop_25		; Loop if cx > 0

		jmp	short loc_27
loc_26::
		mov	al,30h			; '0'
		call	sub_4
loc_27::
		mov	al,68h			; 'h'
		call	sub_4
		pop	es
		pop	si
		pop	cx
		pop	ebx
		pop	ax
		retn
			                        ;* No entry point to code
		push	ax
		push	cx
		push	es
		call	sub_6
		push	ax
		mov	ax,0B800h
		mov	es,ax
		mov	cx,7D0h
		mov	al,0Fh
		call	sub_7
		mov	al,20h			; ' '

locloop_28::
		call	sub_4
		loop	locloop_28		; Loop if cx > 0

		pop	ax
		call	sub_7
		pop	es
		pop	cx
		pop	ax
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_6		proc	near
		mov	al,data_23
		retn
sub_6		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_7		proc	near
		mov	data_23,al
		retn
sub_7		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_8		proc	near
		push	dx
		mov	ax,data_22
		mov	dx,0A0h
		div	dx			; ax,dx rem=dx:ax/reg
		shr	dx,1			; Shift w/zeros fill
		mov	ah,dl
		pop	dx
		retn
sub_8		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_9		proc	near
		push	ax
		push	dx
		mov	dh,ah
		mov	dl,0A0h
		mul	dl			; ax = reg * al
		shr	dx,7			; Shift w/zeros fill
		and	dl,0FEh
		add	ax,dx
		mov	data_22,ax
		pop	dx
		pop	ax
		retn
sub_9		endp

data_24		db	0
		db	 87h,0DBh
data_25		dw	0, 0
data_26		dd	94FF04F0h
data_27		dd	94FF0530h
data_28		dd	00000h
data_30		dd	00000h
data_31		dd	00000h
data_32		db	' int 21h HLTs executed.', 0
data_33		db	' int 21h calls.', 0

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_10		proc	near
		test	cs:data_24,2
		jnz	short loc_ret_29	; Jump if not zero
		inc	cs:data_28
		cmp	cs:data_28,0Ah
		jb	short loc_ret_29	; Jump if below
		sti				; Enable interrupts
		hlt				; Halt processor
		inc	cs:data_30

loc_ret_29::
		retn
sub_10		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_11		proc	near
		push	ax
		sti				; Enable interrupts
loc_30::
		mov	ah,0Bh
		pushf				; Push flags
		call	dword ptr cs:data_25
		test	ax,ax
		jnz	short loc_31		; Jump if not zero
		hlt				; Halt processor
		inc	cs:data_30
		jmp	short loc_30
loc_31::
		pop	ax
		retn
sub_11		endp

			                        ;* No entry point to code
		xchg	bx,bx
		xchg	bx,bx
		xchg	bx,bx
		nop
		cmp	ah,2Ch			; ','
		ja	short loc_34		; Jump if above
		jnz	short loc_32		; Jump if not zero
		call	sub_10
		jmp	short loc_35
loc_32::
		cmp	ah,8
		je	short loc_33		; Jump if equal
		cmp	ah,7
		je	short loc_33		; Jump if equal
		cmp	ah,1
		jne	short loc_34		; Jump if not equal
loc_33::
		call	sub_11
		jmp	short loc_35
loc_34::
		mov	cs:data_28,0
		mov	cs:data_37,0
loc_35::
		jmp	dword ptr cs:data_25
			                        ;* No entry point to code
		xchg	bx,bx
		xchg	bx,bx
		xchg	bx,bx
		nop
		push	eax
		push	si
		push	ds
		mov	ax,cs
		mov	ds,ax
		mov	al,1
		mov	ah,37h			; '7'
		call	sub_9
		mov	al,0Ch
		call	sub_7
		mov	eax,data_31
		inc	data_31
		call	sub_5
		mov	al,0Eh
		call	sub_7
		mov	si,offset data_33	; (' int 21h calls.')
		call	sub_3
		mov	eax,dword ptr [esp+4]
		cmp	ah,2Ch			; ','
		ja	short loc_38		; Jump if above
		jnz	short loc_36		; Jump if not zero
		mov	ax,1
		call	sub_9
		mov	al,0Ch
		call	sub_7
		mov	eax,data_30
		call	sub_5
		mov	al,0Eh
		call	sub_7
		mov	si,offset data_32	; (' int 21h HLTs executed.')
		call	sub_3
		call	sub_10
		jmp	short loc_39
loc_36::
		cmp	ah,8
		je	short loc_37		; Jump if equal
		cmp	ah,7
		je	short loc_37		; Jump if equal
		cmp	ah,1
		jne	short loc_38		; Jump if not equal
loc_37::
		mov	ax,1
		call	sub_9
		mov	al,0Ch
		call	sub_7
		mov	eax,data_30
		call	sub_5
		mov	al,0Eh
		call	sub_7
		mov	si,offset data_32	; (' int 21h HLTs executed.')
		call	sub_3
		call	sub_11
		jmp	short loc_39
loc_38::
		mov	data_28,0
		mov	data_37,0
loc_39::
		pop	ds
		pop	si
		pop	eax
		jmp	dword ptr cs:data_25
		db	 87h,0DBh
data_34		dw	0, 0
data_35		dd	94FF0660h
data_36		dd	94FF06B0h
data_37		dd	00000h
data_39		dd	00000h
data_40		dd	00000h
data_41		db	' int 16h HLTs executed.', 0
data_42		db	' int 16h calls.', 0

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_12		proc	near
		test	cs:data_24,2
		jnz	short loc_ret_40	; Jump if not zero
		inc	cs:data_37
		cmp	cs:data_37,0Ah
		jb	short loc_ret_40	; Jump if below
		sti				; Enable interrupts
		hlt				; Halt processor
		inc	cs:data_39

loc_ret_40::
		retn
sub_12		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_13		proc	near
		push	ax
		push	cx
		inc	ah
		mov	ch,ah
		sti				; Enable interrupts
loc_41::
		pushf				; Push flags
		call	dword ptr cs:data_34
		jnz	short loc_42		; Jump if not zero
		hlt				; Halt processor
		inc	cs:data_39
		mov	ah,ch
		jmp	short loc_41
loc_42::
		pop	cx
		pop	ax
		retn
sub_13		endp

			                        ;* No entry point to code
		xchg	bx,bx
		xchg	bx,bx
		xchg	bx,bx
		xchg	bx,bx
		xchg	bx,bx
		nop
		cmp	ah,12h
		ja	short loc_46		; Jump if above
		jz	short loc_43		; Jump if zero
		cmp	ah,11h
		je	short loc_43		; Jump if equal
		cmp	ah,2
		je	short loc_43		; Jump if equal
		cmp	ah,1
		jne	short loc_44		; Jump if not equal
loc_43::
		call	sub_12
		jmp	short loc_47
loc_44::
		cmp	ah,10h
		je	short loc_45		; Jump if equal
		test	ah,ah
		jnz	short loc_46		; Jump if not zero
loc_45::
		call	sub_13
		jmp	short loc_47
loc_46::
		mov	cs:data_37,0
		mov	cs:data_28,0
loc_47::
		jmp	dword ptr cs:data_34
			                        ;* No entry point to code
		xchg	bx,bx
		xchg	bx,bx
		xchg	bx,bx
		xchg	bx,bx
		xchg	bx,bx
		xchg	bx,bx
		xchg	bx,bx
		push	eax
		push	si
		push	ds
		mov	ax,cs
		mov	ds,ax
		mov	ah,37h			; '7'
		xor	al,al			; Zero register
		call	sub_9
		mov	al,0Ch
		call	sub_7
		mov	eax,data_40
		inc	data_40
		call	sub_5
		mov	al,0Eh
		call	sub_7
		mov	si,offset data_42	; (' int 16h calls.')
		call	sub_3
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
loc_48::
		xor	ax,ax			; Zero register
		call	sub_9
		mov	al,0Ch
		call	sub_7
		mov	eax,data_39
		call	sub_5
		mov	al,0Eh
		call	sub_7
		mov	si,offset data_41	; (' int 16h HLTs executed.')
		call	sub_3
		call	sub_12
		jmp	short loc_52
loc_49::
		cmp	ah,10h
		je	short loc_50		; Jump if equal
		test	ah,ah
		jnz	short loc_51		; Jump if not zero
loc_50::
		xor	ax,ax			; Zero register
		call	sub_9
		mov	al,0Ch
		call	sub_7
		mov	eax,data_39
		call	sub_5
		mov	al,0Eh
		call	sub_7
		mov	si,offset data_41	; (' int 16h HLTs executed.')
		call	sub_3
		mov	eax,dword ptr [esp+4]
		call	sub_13
		jmp	short loc_52
loc_51::
		mov	data_37,0
		mov	data_28,0
loc_52::
		pop	ds
		pop	si
		pop	eax
		jmp	dword ptr cs:data_34
		db	90h
data_43		dw	0, 0
data_44		dd	94FF07C0h
data_45		dd	94FF07D0h
		db	0, 0
		db	0, 0
data_47		dd	00000h
data_48		dd	00000h
data_49		db	' int 14h HALTs executed.', 0
data_50		db	' int 14h calls.', 0

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_14		proc	near
		push	ax
		sti				; Enable interrupts
loc_53::
		mov	ah,3
		pushf				; Push flags
		call	dword ptr cs:data_43
		test	ah,1
		jnz	short loc_54		; Jump if not zero
		hlt				; Halt processor
		inc	cs:data_47
		jmp	short loc_53
loc_54::
		pop	ax
		retn
sub_14		endp

			                        ;* No entry point to code
		nop
		cmp	ah,2
		jne	short loc_55		; Jump if not equal
		call	sub_14
loc_55::
		jmp	dword ptr cs:data_43
			                        ;* No entry point to code
		xchg	bx,bx
		nop
		push	eax
		push	si
		push	ds
		mov	ax,cs
		mov	ds,ax
		mov	al,2
		mov	ah,37h			; '7'
		call	sub_9
		mov	al,0Ch
		call	sub_7
		mov	eax,data_48
		inc	data_48
		call	sub_5
		mov	al,0Eh
		call	sub_7
		mov	si,offset data_50	; (' int 14h calls.')
		call	sub_3
		mov	eax,dword ptr [esp+4]
		cmp	ah,2
		jne	short loc_56		; Jump if not equal
		mov	ax,2
		call	sub_9
		mov	al,0Ch
		call	sub_7
		mov	eax,data_47
		call	sub_5
		mov	al,0Eh
		call	sub_7
		mov	si,offset data_49	; (' int 14h HALTs executed.')
		call	sub_3
		call	sub_14
loc_56::
		pop	ds
		pop	si
		pop	eax
		jmp	dword ptr cs:data_43
		db	90h
data_51		dd	00000h
data_52		dd	94FF0850h
data_53		dd	94FF0870h
		db	0, 0, 0, 0
		db	' IRQ 01h calls.'
		db	 00h, 66h, 2Eh,0C7h, 06h,0E4h
		db	 05h, 00h, 00h, 00h, 00h, 66h
		db	 2Eh,0C7h, 06h, 7Ch, 04h, 00h
		db	 00h, 00h, 00h, 2Eh,0FFh, 2Eh
		db	 30h, 08h, 87h,0DBh, 87h,0DBh
		db	 87h,0DBh, 90h, 9Ch, 2Eh,0FFh
		db	 1Eh, 30h, 08h, 66h, 50h, 56h
		db	 1Eh, 8Ch,0C8h, 8Eh,0D8h,0B0h
		db	 03h,0B4h, 37h,0E8h,0D2h,0FBh
		db	0B0h, 0Ch,0E8h,0BAh,0FBh, 66h
		db	0A1h, 3Ch, 08h, 66h,0FFh, 06h
		db	 3Ch, 08h,0E8h, 07h,0FBh,0B0h
		db	 0Eh,0E8h,0A9h,0FBh,0BEh, 40h
		db	 08h,0E8h,0BCh,0FAh, 66h,0C7h
		db	 06h,0E4h, 05h, 00h, 00h, 00h
		db	 00h, 66h,0C7h, 06h, 7Ch, 04h
		db	 00h, 00h, 00h, 00h, 1Fh, 5Eh
		db	 66h, 58h,0CFh

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_15		proc	near
		push	bx
		xor	bx,bx			; Zero register
		int	2Dh			; ??INT Non-standard interrupt
		cmp	ax,0FEADh
		sete	al			; Set byte if equal
		mov	ah,0
		pop	bx
		retn
sub_15		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_16		proc	near
		push	bx
		mov	bx,1
		int	2Dh			; ??INT Non-standard interrupt
		pop	bx
		retn
sub_16		endp

			                        ;* No entry point to code
		push	bx
		mov	bx,2
		int	2Dh			; ??INT Non-standard interrupt
		pop	bx
		retn
			                        ;* No entry point to code
		push	bx
		mov	bx,3
		int	2Dh			; ??INT Non-standard interrupt
		pop	bx
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_17		proc	near
		pushf				; Push flags
		pushad				; Save all regs
		push	es
		cli				; Disable interrupts
		xor	esi,esi			; Zero register
		mov	es,si
		mov	ecx,9
		mov	si,data_18
		inc	data_18
		imul	esi,ecx			; reg = reg * reg
;*		add	si,data_4e
		db	 81h,0C6h, 3Fh, 00h	;  Fixup - byte match
		mov	[si],bl
		mov	[si+5],eax
		xor	bh,bh			; Zero register
		shl	bx,2			; Shift w/zeros fill
		xchg	es:[bx],eax
		mov	[si+1],eax
		sti				; Enable interrupts
		pop	es
		popad				; Restore all regs
		popf				; Pop flags
		retn
sub_17		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

;      Note: Subroutine does not return	to instruction after call

sub_18		proc	near
		cli				; Disable interrupts
		mov	data_8,dx
		mov	data_9,bx
		mov	data_10,ax
		xor	ax,ax			; Zero register
		mov	es,ax
		mov	eax,es:data_1e
		mov	dword ptr data_12,eax
		mov	eax,data_11
		mov	es:data_1e,eax
		mov	ax,data_10
		call	sub_2
		mov	ax,cx
		shr	ax,4			; Shift w/zeros fill
;*		add	ax,20h
		db	 05h, 20h, 00h		;  Fixup - byte match
		mov	dx,ax
		mov	ax,3100h
		int	21h			; DOS Services  ah=function 31h
						;  terminate & stay resident
						;   al=return code,dx=paragraphs
sub_18		endp

		db	0C3h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_19		proc	near
		cmp	al,41h			; 'A'
		jb	short loc_ret_57	; Jump if below
		cmp	al,5Ah			; 'Z'
		ja	short loc_ret_57	; Jump if above
		add	al,20h			; ' '

loc_ret_57::
		retn
sub_19		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_20		proc	near
		cmp	al,61h			; 'a'
		jb	short loc_ret_58	; Jump if below
		cmp	al,7Ah			; 'z'
		ja	short loc_ret_58	; Jump if above
		sub	al,20h			; ' '

loc_ret_58::
		retn
sub_20		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_21		proc	near
		cmp	al,61h			; 'a'
		jb	short loc_59		; Jump if below
		cmp	al,7Ah			; 'z'
		ja	short loc_59		; Jump if above
		cmp	al,al
		jmp	short loc_ret_60
loc_59::
		cmp	al,61h			; 'a'

loc_ret_60::
		retn
sub_21		endp

			                        ;* No entry point to code
		cmp	al,41h			; 'A'
		jb	short loc_61		; Jump if below
		cmp	al,5Ah			; 'Z'
		ja	short loc_61		; Jump if above
		cmp	al,al
		jmp	short loc_ret_62
loc_61::
		cmp	al,41h			; 'A'

loc_ret_62::
		retn
			                        ;* No entry point to code
		push	ax
		call	sub_19
		call	sub_21
		pop	ax
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_22		proc	near
		push	ax
		cmp	al,30h			; '0'
		jb	short loc_63		; Jump if below
		cmp	al,39h			; '9'
		ja	short loc_63		; Jump if above
		cmp	al,al
		jmp	short loc_64
loc_63::
		cmp	al,31h			; '1'
loc_64::
		pop	ax
		retn
sub_22		endp

			                        ;* No entry point to code
		push	ax
		call	sub_22
		jz	short loc_65		; Jump if zero
		call	sub_20
		cmp	al,41h			; 'A'
		jb	short loc_66		; Jump if below
		cmp	al,46h			; 'F'
		ja	short loc_66		; Jump if above
loc_65::
		cmp	al,al
		jmp	short loc_67
loc_66::
		cmp	al,31h			; '1'
loc_67::
		pop	ax
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_23		proc	near
		cmp	al,20h			; ' '
		je	short loc_ret_68	; Jump if equal
		cmp	al,9
		je	short loc_ret_68	; Jump if equal

loc_ret_68::
		retn
sub_23		endp

			                        ;* No entry point to code
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

loc_ret_69::
		retn
		db	 50h, 56h
loc_70::
		mov	ah,[si]
		inc	si
		cmp	al,ah
		je	short loc_71		; Jump if equal
		test	ah,ah
		jnz	loc_70			; Jump if not zero
		inc	ah
loc_71::
		pop	si
		pop	ax
		retn
			                        ;* No entry point to code
		push	ax
		push	cx
		push	si
		mov	cx,0FFh

locloop_72::
		mov	al,[si]
		call	sub_19
		mov	[si],al
		inc	si
		test	al,al
		loopnz	locloop_72		; Loop if zf=0, cx>0

		pop	si
		pop	cx
		pop	ax
		retn
			                        ;* No entry point to code
		push	ax
		push	cx
		push	si
		mov	cx,0FFh

locloop_73::
		mov	al,[si]
		call	sub_20
		mov	[si],al
		inc	si
		test	al,al
		loopnz	locloop_73		; Loop if zf=0, cx>0

		pop	si
		pop	cx
		pop	ax
		retn
		db	 50h, 56h,0B9h,0FFh, 00h

locloop_74::
		mov	al,[si]
		inc	si
		test	al,al
		loopnz	locloop_74		; Loop if zf=0, cx>0

		neg	cx
		add	cx,0FFh
		pop	si
		pop	ax
		retn
			                        ;* No entry point to code
		push	ax
		push	cx
		mov	cx,0FFh
		dec	si

locloop_75::
		inc	si
		mov	al,[si]
		call	sub_23
		loopz	locloop_75		; Loop if zf=1, cx>0

		pop	cx
		pop	ax
		retn
			                        ;* No entry point to code
		push	ax
		push	cx
		push	si
		push	di
		mov	cx,0FFh

locloop_76::
		mov	al,[si]
		cmp	al,es:[di]
		jne	short loc_77		; Jump if not equal
		test	al,al
		jz	short loc_77		; Jump if zero
		inc	si
		inc	di
		loop	locloop_76		; Loop if cx > 0

loc_77::
		pop	di
		pop	si
		pop	cx
		pop	ax
		retn
			                        ;* No entry point to code
		push	ax
		push	cx
		push	si
		push	di
		mov	cx,0FFh

locloop_78::
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

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_24		proc	near
		jmp	short loc_79
data_54		dw	0
data_55		dw	0
loc_79::
		push	dx
		push	si
		push	di
		mov	data_54,0
		mov	data_55,0
		mov	dh,al
		xor	ah,ah			; Zero register
		xor	bl,bl			; Zero register
		mov	dl,1
		movzx	cx,byte ptr es:[di]	; Mov w/zero extend
		jcxz	short loc_88		; Jump if cx=0

locloop_80::
		inc	di
		mov	al,es:[di]
		call	sub_23
		jz	short loc_81		; Jump if zero
		cmp	al,2Dh			; '-'
		je	short loc_83		; Jump if equal
		jmp	short loc_82
loc_81::
		cmp	dl,2
		je	short loc_87		; Jump if equal
		mov	dl,1
		jmp	short loc_86
loc_82::
		inc	ah
		cmp	dl,1
		mov	dl,3
		jz	short loc_84		; Jump if zero
		jmp	short loc_86
loc_83::
		cmp	dl,2
		je	short loc_87		; Jump if equal
		mov	dl,2
loc_84::
		cmp	dh,bl
		jne	short loc_85		; Jump if not equal
		mov	data_54,si
		mov	byte ptr data_55,ah
loc_85::
		inc	bl
		mov	ah,1
		mov	si,di
loc_86::
		loop	locloop_80		; Loop if cx > 0

		cmp	dl,2
		je	short loc_87		; Jump if equal
		cmp	data_55,0
		jne	short loc_88		; Jump if not equal
		mov	data_54,si
		mov	byte ptr data_55,ah
		jmp	short loc_88
loc_87::
		stc				; Set carry flag
		jmp	short loc_89
loc_88::
		mov	ah,bl
		mov	bx,data_54
		mov	cx,data_55
		mov	al,dh
		clc				; Clear carry flag
loc_89::
		pop	di
		pop	si
		pop	dx
		retn
sub_24		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_25		proc	near
		push	ax
		push	bx
		mov	al,1
		call	sub_24
		mov	cl,ah
		mov	ch,0
		pop	bx
		pop	ax
		retn
sub_25		endp

			                        ;* No entry point to code
		push	ax
		push	cx
		call	sub_24
		pop	cx
		pop	ax
		retn
			                        ;* No entry point to code
		push	ax
		push	bx
		call	sub_24
		pop	bx
		pop	ax
		retn
			                        ;* No entry point to code
		push	ax
		push	bx
		push	cx
		push	si
		call	sub_24
		jc	short loc_91		; Jump if carry Set

locloop_90::
		mov	al,es:[bx]
		mov	[si],al
		inc	bx
		inc	si
		loop	locloop_90		; Loop if cx > 0

		clc				; Clear carry flag
loc_91::
		pop	si
		pop	cx
		pop	bx
		pop	ax
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_26		proc	near
		push	ax
		push	bx
		push	cx
		push	si
		call	sub_24
		jc	short loc_94		; Jump if carry Set

locloop_92::
		mov	al,[si]
		call	sub_19
		mov	ah,al
		mov	al,es:[bx]
		call	sub_19
		cmp	al,ah
		jne	short loc_93		; Jump if not equal
		inc	si
		inc	bx
		loop	locloop_92		; Loop if cx > 0

		cmp	byte ptr [si],0
loc_93::
		clc				; Clear carry flag
loc_94::
		pop	si
		pop	cx
		pop	bx
		pop	ax
		retn
sub_26		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_27		proc	near
		pusha				; Save all regs
		call	sub_25
		jc	short loc_99		; Jump if carry Set
		jcxz	short loc_98		; Jump if cx=0
		mov	al,1
		mov	bp,si

locloop_95::
		mov	bx,bp
		xor	dx,dx			; Zero register
loc_96::
		lea	si,[bx]			; Load effective addr
		call	sub_26
		jc	short loc_99		; Jump if carry Set
		jnz	short loc_97		; Jump if not zero
		inc	dx
		call	word ptr [bx+0Bh]	;*Sub does not return1hentry
loc_97::
		add	bx,0Dh
		cmp	byte ptr [bx],0
		jne	loc_96			; Jump if not equal
		test	dx,dx
		jz	short loc_99		; Jump if zero
		inc	al
		loop	locloop_95		; Loop if cx > 0

loc_98::
		clc				; Clear carry flag
		jmp	short loc_100
loc_99::
		stc				; Set carry flag
loc_100::
		popa				; Restore all regs
		retn
sub_27		endp

			                        ;* No entry point to code
		push	ax
		mov	dx,si
		mov	ah,3Dh
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		mov	dx,ax
		pop	ax
		retn
			                        ;* No entry point to code
		push	ax
		push	bx
		mov	bx,dx
		mov	ah,3Eh
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		pop	bx
		pop	ax
		retn
			                        ;* No entry point to code
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
			                        ;* No entry point to code
		push	ax
		push	bx
		mov	bx,ax
		mov	ah,67h
		int	21h			; DOS Services  ah=function 67h
						;  set maximum handles bx
		pop	bx
		pop	ax
		retn
			                        ;* No entry point to code
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

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_28		proc	near
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
sub_28		endp

			                        ;* No entry point to code
		push	ax
		push	cx
		push	si
		mov	cx,0FFh

locloop_101::
		call	sub_31
		mov	[si],al
		inc	si
		cmp	al,0
		loopnz	locloop_101		; Loop if zf=0, cx>0

		pop	si
		pop	cx
		pop	ax
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_29		proc	near
		push	ax
		push	cx
		push	si
		mov	cx,0FFh

locloop_102::
		mov	al,[si]
		cmp	al,0
		je	short loc_103		; Jump if equal
		call	sub_32
		inc	si
		loop	locloop_102		; Loop if cx > 0

loc_103::
		pop	si
		pop	cx
		pop	ax
		retn
sub_29		endp

			                        ;* No entry point to code
		push	ax
		push	cx
		push	si
		mov	cx,0FFh

locloop_104::
		call	sub_31
		cmp	al,0Dh
		je	short loc_105		; Jump if equal
		mov	[si],al
		inc	si
		loop	locloop_104		; Loop if cx > 0

loc_105::
		mov	byte ptr [si],0
		pop	si
		pop	cx
		pop	ax
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_30		proc	near
		push	ax
		call	sub_29
		mov	al,0Dh
		call	sub_32
		mov	al,0Ah
		call	sub_32
		pop	ax
		retn
sub_30		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_31		proc	near
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
sub_31		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_32		proc	near
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
sub_32		endp

data_56		db	'0123456789ABCDEF'	; Data table (indexed access)
		db	0C3h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_33		proc	near
		push	eax
		push	ebx
		push	cx
		push	edx
		push	si
		mov	ebx,0Ah
		mov	si,dx
		xor	cx,cx			; Zero register
loc_106::
		xor	edx,edx			; Zero register
		div	ebx			; ax,dx rem=dx:ax/reg
		push	dx
		inc	cl
		test	eax,eax
		jnz	loc_106			; Jump if not zero
		mov	dx,si

locloop_107::
		pop	bx
		mov	al,byte ptr cs:data_56[bx]	; ('0123456789ABCDEF')
		call	sub_32
		loop	locloop_107		; Loop if cx > 0

		pop	si
		pop	edx
		pop	cx
		pop	ebx
		pop	eax
		retn
sub_33		endp

		db	0C3h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_34		proc	near
		push	ax
		push	ebx
		push	cx
		push	si
		mov	ebx,eax
		mov	cx,8
		mov	al,30h			; '0'
		call	sub_32
		mov	al,78h			; 'x'
		call	sub_32

locloop_108::
		rol	ebx,4			; Rotate
		mov	si,bx
		and	si,0Fh
		mov	al,byte ptr cs:data_56[si]	; ('0123456789ABCDEF')
		call	sub_32
		loop	locloop_108		; Loop if cx > 0

		pop	si
		pop	cx
		pop	ebx
		pop	ax
		retn
sub_34		endp

			                        ;* No entry point to code
		push	dx
		mov	dx,offset data_6
		call	sub_28
		pop	dx
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_35		proc	near
		push	dx
		mov	dx,1
		call	sub_29
		pop	dx
		retn
sub_35		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_36		proc	near
		push	dx
		mov	dx,1
		call	sub_30
		pop	dx
		retn
sub_36		endp

			                        ;* No entry point to code
		push	dx
		mov	dx,1
		call	sub_32
		pop	dx
		retn
			                        ;* No entry point to code
		push	dx
		mov	dx,1
		call	sub_33
		pop	dx
		retn
			                        ;* No entry point to code
		push	dx
		mov	dx,1
		call	sub_34
		pop	dx
		retn
			                        ;* No entry point to code
		push	ax
		call	sub_37
		call	sub_38
		pop	ax
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_37		proc	near
		push	bx
		mov	ah,0Fh
		int	10h			; Video display   ah=functn 0Fh
						;  get state, al=mode, bh=page
						;   ah=columns on screen
		pop	bx
		retn
sub_37		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_38		proc	near
		xor	ah,ah			; Zero register
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		retn
sub_38		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_39		proc	near
		push	bx
		mov	ah,0Fh
		int	10h			; Video display   ah=functn 0Fh
						;  get state, al=mode, bh=page
						;   ah=columns on screen
		mov	al,bh
		pop	bx
		retn
sub_39		endp

			                        ;* No entry point to code
		mov	ah,5
		int	10h			; Video display   ah=functn 05h
						;  set display page al
		retn
			                        ;* No entry point to code
		push	bx
		push	cx
		push	dx
		call	sub_39
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
			                        ;* No entry point to code
		mov	dh,al
		mov	dl,ah
		call	sub_39
		mov	bh,al
		mov	ah,2
		int	10h			; Video display   ah=functn 02h
						;  set cursor location in dx
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_40		proc	near
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
loc_109::
		mov	bl,al
		pop	ax
		mov	al,bl
		pop	cx
		pop	bx
		popf				; Pop flags
		retn
sub_40		endp

		db	0EBh, 02h
data_57		dw	0
		db	 53h, 50h,0DBh,0E3h,0C7h, 06h
		db	0D9h, 0Dh, 5Ah, 5Ah,0DDh, 3Eh
		db	0D9h, 0Dh,0B3h, 00h, 83h, 3Eh
		db	0D9h, 0Dh, 00h, 75h, 35h,0D9h
		db	 3Eh,0D9h, 0Dh,0A1h,0D9h, 0Dh
		db	 25h, 3Fh, 10h, 3Dh, 3Fh, 00h
		db	0B3h, 00h, 75h, 24h,0E8h, 4Eh
		db	0FFh, 8Ah,0D8h, 3Ch, 03h, 75h
		db	 1Bh,0D9h,0E8h,0D9h,0EEh,0DEh
		db	0F9h,0D9h,0C0h,0D9h,0E0h,0DEh
		db	0D9h, 9Bh,0DDh, 3Eh,0D9h, 0Dh
		db	0A1h,0D9h, 0Dh,0B3h, 02h, 9Eh
		db	 74h, 02h,0B3h, 03h
loc_110::
		pop	ax
		mov	al,bl
		pop	bx
		retn
			                        ;* No entry point to code
		push	ax
		mov	ax,4300h
		int	2Fh			; HIMEM.SYS installed state, al
		cmp	al,80h
		pop	ax
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_41		proc	near
		push	ax
		push	bx
		push	es
		xor	ax,ax			; Zero register
		mov	es,ax
		cmp	dword ptr es:data_2e,0
		sete	ah			; Set byte if equal
		jz	short loc_111		; Jump if zero
		mov	ax,0DE00h
		int	67h			; EMS Memory        ah=func DEh
						;  VCPI active  ah=1, bx=version
loc_111::
		test	ah,ah
		pop	es
		pop	bx
		pop	ax
		retn
sub_41		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_42		proc	near
		pusha				; Save all regs
		push	es
		mov	ax,1687h
		int	2Fh			; ??INT Non-standard interrupt
		test	ax,ax
		jnz	short loc_112		; Jump if not zero
		cmp	bl,1
loc_112::
		pop	es
		popa				; Restore all regs
		retn
sub_42		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_43		proc	near
		push	ax
		smsw	ax			; Store machine stat
		and	al,1
		cmp	al,1
		pop	ax
		retn
sub_43		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_44		proc	near
		mov	bx,7008h
		retn
sub_44		endp

			                        ;* No entry point to code
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
			                        ;* No entry point to code
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
			                        ;* No entry point to code
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
;*		and	ax,0FFFEh
		db	 25h,0FEh,0FFh		;  Fixup - byte match
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
		db	 51h, 57h
loc_113::
		mov	cx,8
		mov	ax,di

locloop_114::
		cmp	dword ptr es:[di],0
		lea	di,[di+4]		; Load effective addr
		loopz	locloop_114		; Loop if zf=1, cx>0

		jz	short loc_115		; Jump if zero
		mov	di,ax
		add	di,20h
		cmp	di,data_3e
		jbe	loc_113			; Jump if below or =
		stc				; Set carry flag
		jmp	short loc_116
loc_115::
		shr	ax,2			; Shift w/zeros fill
		clc				; Clear carry flag
loc_116::
		pop	di
		pop	cx
		retn
			                        ;* No entry point to code
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

locloop_117::
		mov	eax,es:[si]
		mov	es:[di],eax
		add	si,4
		add	di,4
		loop	locloop_117		; Loop if cx > 0

		pop	es
		popa				; Restore all regs
		popf				; Pop flags
		retn
			                        ;* No entry point to code
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

locloop_118::
		mov	dword ptr es:[di],0
		add	di,4
		loop	locloop_118		; Loop if cx > 0

		pop	es
		pop	di
		pop	cx
		popf				; Pop flags
		retn
		db	 87h,0DBh, 90h
data_58		dw	0, 0
		db	 66h, 60h, 1Eh, 06h,0B8h, 05h
		db	 16h, 33h,0DBh, 8Eh,0C3h, 33h
		db	0F6h, 8Eh,0DEh, 33h,0D2h, 33h
		db	0C9h,0BFh, 0Bh, 03h,0CDh, 2Fh
		db	 85h,0C9h, 75h, 20h, 2Eh, 89h
		db	 36h, 84h, 0Fh, 2Eh, 8Ch, 1Eh
		db	 86h, 0Fh, 66h, 2Eh, 83h, 3Eh
		db	 84h, 0Fh, 00h, 74h, 0Dh,0FAh
		db	 33h,0C0h, 2Eh,0FFh, 1Eh, 84h
		db	 0Fh, 72h, 03h,0F8h,0EBh, 08h
		db	0B8h, 06h, 16h, 33h,0D2h,0CDh
		db	 2Fh,0F9h, 07h, 1Fh, 66h, 61h
		db	0C3h, 66h, 60h, 1Eh, 06h, 66h
		db	 2Eh, 83h, 3Eh, 84h, 0Fh, 00h
		db	 74h, 10h,0FAh,0B8h, 01h, 00h
		db	 2Eh,0FFh, 1Eh, 84h, 0Fh,0B8h
		db	 06h, 16h, 33h,0D2h,0CDh
		db	2Fh
loc_119::
		pop	es
		pop	ds
		popad				; Restore all regs
		retn
		db	53h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_45		proc	near
		mov	ax,0DE00h
		int	67h			; EMS Memory        ah=func DEh
						;  VCPI active  ah=1, bx=version
		call	sub_47
		mov	ax,bx
		pop	bx
		retn
sub_45		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_46		proc	near
		push	ax
		push	cx
		mov	ax,0DE0Ah
		int	67h			; EMS Memory        ah=func DEh
						;  VCPI get int vector maps
		mov	bh,cl
		call	sub_47
		pop	cx
		pop	ax
		retn
sub_46		endp

			                        ;* No entry point to code
		pushf				; Push flags
		push	ax
		push	cx
		cli				; Disable interrupts
		xor	cx,cx			; Zero register
		xchg	bh,cl
		mov	ax,0DE0Bh
		int	67h			; EMS Memory        ah=func DEh
						;  VCPI set int vector maps
		call	sub_47
		pop	cx
		pop	ax
		popf				; Pop flags
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_47		proc	near
		test	ah,ah
		clc				; Clear carry flag
		jz	short loc_ret_120	; Jump if zero
		stc				; Set carry flag

loc_ret_120::
		retn
sub_47		endp

data_59		dw	0			; segment storage
data_60		dw	0
data_61		db	1
		db	 2Fh, 48h
		db	9 dup (0)
data_63		dw	offset sub_49
		db	 2Fh, 3Fh
		db	9 dup (0)
		db	 84h, 14h, 2Fh, 55h
		db	9 dup (0)
		db	 96h, 14h, 2Fh, 54h, 4Dh
		db	8 dup (0)
		db	0BBh, 14h, 2Fh, 4Eh, 46h
		db	8 dup (0)
		db	0CEh, 14h, 00h
		db	12 dup (0)
data_69		db	'CPUIdle for DOS V1.32 [Beta]', 0Dh
		db	0Ah, 'Copyright (C) by Marton Bal'
		db	'og, 1998.', 0Dh, 0Ah, 0
data_70		db	'Syntax:    DOSIDLE [Options]', 0Dh
		db	0Ah, 0Dh, 0Ah
		db	'Options:   /U      Uninstall CPU'
		db	'Idle for DOS.', 0Dh, 0Ah, '     '
		db	'      /TM     Enable Test Mode ('
		db	'disabled by default).', 0Dh, 0Ah
		db	'           /NF     Disable Force'
		db	' Mode (enabled by default).', 0Dh
		db	0Ah, '           /H, /?  Display '
		db	'this help message.', 0Dh, 0Ah
		db	0
data_71		db	'Example:   DOSIDLE     Install C'
		db	'PUIdle for DOS.', 0Dh, 0Ah, '   '
		db	'        DOSIDLE /U  Uninstall CP'
		db	'UIdle for DOS.', 0Dh, 0Ah
		db	0
data_72		db	'CPUIdle for DOS installed succes'
		db	 73h, 66h, 75h, 6Ch, 6Ch, 79h
		db	 2Eh, 00h
data_73		db	'CPUIdle for DOS uninstalled succ'
		db	'essfully.'
		db	0
data_74		db	'WARNING: VCPI host detected.', 0
data_75		db	'WARNING: DPMI host detected.', 0
		db	 46h, 41h, 54h, 41h, 4Ch, 20h
		db	 00h
		db	'[#10]: Failed to resize program '
		db	'memory.'
		db	0
		db	'[#20]: CPUIdle for DOS is not in'
		db	'stalled.'
		db	0
		db	'[#21]: CPUIdle for DOS is alread'
		db	'y installed.'
		db	0
		db	'[#22]: Failed to uninstall CPUId'
		db	'le for DOS.', 0Dh, 0Ah, 'Another'
		db	' TSR program has been installed '
		db	'over it.'
		db	0
		db	'[#30]: A 386 CPU or better is re'
		db	'quired.'
		db	0
		db	'[#31]: 80 Column color display i'
		db	's required for Test Mode.'
		db	0
		db	'[#40]: Invalid command-line swit'
		db	'ch.'
		db	0
		db	'[#50]: CPU in V86 mode and no VC'
		db	'PI or DPMI host present.'
		db	0
loc_121::
		push	si
		mov	si,data_5e
		call	sub_35
		pop	si
		sti				; Enable interrupts
		call	sub_36
		mov	ax,4C00h
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
		db	0C3h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_48		proc	near
		cli				; Disable interrupts
		mov	ax,cs
		mov	ds,ax
		mov	data_59,es
		mov	ax,es:PSP_envirn_seg
		mov	data_60,ax
		mov	si,offset data_69	; ('CPUIdle for DOS V1.32 [B')
		call	sub_36
		call	sub_40
		mov	si,138Dh
		cmp	al,3
		jb	loc_121			; Jump if below
		xor	ax,ax			; Zero register
		mov	gs,ax
		sti				; Enable interrupts
		retn
sub_48		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

;      Note: Subroutine does not return	to instruction after call

sub_49		proc	near
		mov	si,offset data_70	; ('Syntax:    DOSIDLE [Opti')
		call	sub_36
		mov	si,offset data_71	; ('Example:   DOSIDLE     I')
		call	sub_36
		mov	ax,4C00h
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
sub_49		endp

			                        ;* No entry point to code
		retn
			                        ;* No entry point to code
		mov	dx,0DEEDh
		call	sub_15
		mov	si,12DAh
		test	ax,ax
		jz	loc_121			; Jump if zero
		mov	dx,0DEEDh
		call	sub_16
		mov	si,1330h
		test	ax,ax
		jz	loc_121			; Jump if zero
		mov	si,offset data_73	; ('CPUIdle for DOS uninstal')
		call	sub_36
		mov	ax,4C00h
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
			                        ;* No entry point to code
		xor	ax,ax			; Zero register
		int	11h			; Put equipment bits in ax
		and	al,30h			; '0'
		cmp	al,20h			; ' '
		mov	si,13B5h
		jnz	loc_121			; Jump if not zero
		or	data_24,1
		retn
			                        ;* No entry point to code
		or	data_24,2
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_50		proc	near
		mov	di,offset data_16
		mov	es,data_59
		mov	si,102Fh
		call	sub_27
		mov	si,13EFh
		jc	loc_121			; Jump if carry Set
		retn
sub_50		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_51		proc	near
		call	sub_41
		jnz	short loc_122		; Jump if not zero
		mov	si,offset data_74	; ('WARNING: VCPI host detec')
		call	sub_36
		mov	data_61,2
		jmp	short loc_ret_124
loc_122::
		call	sub_42
		jnz	short loc_123		; Jump if not zero
		mov	si,offset data_75	; ('WARNING: DPMI host detec')
		call	sub_36
		mov	data_61,4
		jmp	short loc_ret_124
loc_123::
		call	sub_43
		mov	si,1413h
		jz	loc_121			; Jump if zero

loc_ret_124::
		retn
sub_51		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_52		proc	near
		mov	eax,gs:data_14
		mov	dword ptr data_43,eax
		mov	eax,gs:data_15
		mov	dword ptr data_34,eax
		mov	eax,gs:data_17
		mov	dword ptr data_25,eax
		test	data_24,1
		jnz	short loc_125		; Jump if not zero
		mov	eax,data_44
		mov	bl,14h
		call	sub_17
		mov	eax,data_35
		mov	bl,16h
		call	sub_17
		mov	eax,data_26
		mov	bl,21h			; '!'
		call	sub_17
		jmp	short loc_ret_126
loc_125::
		mov	eax,data_45
		mov	bl,14h
		call	sub_17
		mov	eax,data_36
		mov	bl,16h
		call	sub_17
		mov	eax,data_27
		mov	bl,21h			; '!'
		call	sub_17

loc_ret_126::
		retn
sub_52		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_53		proc	near
		cli				; Disable interrupts
		cmp	data_61,2
		jne	short loc_127		; Jump if not equal
		call	sub_46
		jmp	short loc_129
loc_127::
		cmp	data_61,4
		jne	short loc_128		; Jump if not equal
		call	sub_44
		jmp	short loc_129
loc_128::
		call	sub_44
loc_129::
		movzx	ebx,bl			; Mov w/zero extend
		inc	ebx
		mov	eax,dword ptr gs:[ebx*4]
		mov	data_51,eax
		test	data_24,1
		jnz	short loc_130		; Jump if not zero
		mov	eax,data_52
		call	sub_17
		jmp	short loc_131
loc_130::
		mov	eax,data_53
		call	sub_17
loc_131::
		sti				; Enable interrupts
		retn
sub_53		endp


;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;                       Program	Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€


dosidle1	proc	far

start::
		call	sub_48
		call	sub_50
		mov	dx,0DEEDh
		call	sub_15
		mov	si,1303h
;*		cmp	ax,1
		db	 3Dh, 01h, 00h		;  Fixup - byte match
		jz	loc_121			; Jump if zero
		call	sub_51
		call	sub_52
		call	sub_53
		mov	si,offset data_72	; ('CPUIdle for DOS installe')
		call	sub_36
		mov	cx,8B8h
		mov	dx,0DEEDh
		mov	bx,data_59
		mov	ax,data_60
		call	sub_18			; Sub does not return here
		db	15 dup (0)

dosidle1	endp

seg_a		ends



;------------------------------------------------------  stack_seg_b   ----

stack_seg_b	segment	word stack 'STACK' use16

		db	800 dup (0)

stack_seg_b	ends



		end	start
