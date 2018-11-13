PAGE  59,132
;                           ÜÚÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¿Ü                            ;
;                        ÄÍÍ¹³ CPUidle for DOS ³ÌÍÍÄ                         ;
;                           ßÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙß                            ;


;[KERNEL CHARACTERISTICS]
; Kernel name:          CPUidle for DOS.
; Programming stage:    Working version, Under development.
; Kernel version:       V2.10 [Build 0077], Marton Balog, May 07, 1998 - [See: http://img.prohardver.hu/ad/prohardver/plusabit_1/english.htm]
;                       V2.50 [Build 0101], I. Tsenov, May, 2015 [See: http://www.vogons.org/viewtopic.php?f=24&t=43384]
;                       V2.51 [Build 0102], M. Kennedy (MJK), July, 2015 [See above vogons thread].
;			V3.00 [build 0200], W. Galazka

;[NOTES]
; Ralphs intlist -> more idle possibilities.



;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»;
;º ²²²²²²²²²²²²²²²²²²²²²²² RESIDENT PART OF PROGRAM ²²²²²²²²²²²²²²²²²²²²²²² º;
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
;°°°°°°°°°°±±±±±±±±±± GLOBAL CODE & DATA FOR ALL HANDLERS ±±±±±±±±±±°°°°°°°°°;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
.586p
ideal                                   ; Yep, this prog is TASM 4.0 coded!

SEGMENT	CODE_R	PARA PUBLIC  USE16 'CODE'
ENDS 
SEGMENT	CODE16	PARA PUBLIC  USE16 'CODE'
ENDS
SEGMENT	DATA16	DWORD PUBLIC  USE16 'DATA'
ENDS

SEGMENT	CODE_R
	ASSUME CS: CODE_R, DS:NOTHING

struc 	intr_vec_struc                                                             	
	number  db  ?                                                              	
 	old_isr dd  ?                                                              	             
 	new_isr dd  ?                                                              	            
ends                                                                               	

struc	intr_suspend_struc
	byte1	db 0
	bytes25	dd 0	
ends

INT2DH_BIOS	= 2dh * 4
VECTOR_NUM	= 30
tsr_kernel_id	dw	?					;data_11	stores KERNEL_ID
tsr_psp_seg	dw	?					;data_12     	stores psp_seg
tsr_env_seg	dw	?					;data_13   	stores env seg 
new_int_2dh	dd	isr_2dh					;data_14
old_int_2dh     dd 	?					;data_15
intr_vectors	intr_vec_struc VECTOR_NUM dup (<>)		;data_16
vectors_hooked	dw	0					;data_17
suspend_vectors	intr_suspend_struc VECTOR_NUM dup (<>)		;data_18
vectors_suspend	dw	0					;data_19	

TSR_ID			= 0FEADh
ACTION_TEST		= 0
ACTION_UNINSTALL       	= 1
ACTION_SUSPEND         	= 2
ACTION_REACTIVATE	= 3
	
PROC	isr_2dh
	cmp	dx, [cs:tsr_kernel_id]
	jz	short loc_1
loc_2:
	jmp	[dword cs:old_int_2dh]
loc_1:			                        
	cmp	bx, ACTION_TEST
	jne	short loc_3		
	mov	ax, TSR_ID
	sti				
	iret					; Interrupt return
loc_3:
	ASSUME 	DS: CODE_R
	cmp	bx, ACTION_UNINSTALL
	jne	short loc_10		
	cli				
	push	cx si di ds es
	mov	ax,cs
	mov	ds,ax
	xor	ax,ax			
	mov	es,ax
	mov	eax, [new_int_2dh]
	cmp	[es:INT2DH_BIOS],eax
	jne	short loc_8		
	mov	si,offset intr_vectors
	mov	cx, [vectors_hooked]
	test	cx,cx
	jz	short loc_7		

locloop_4:
	movzx	di, [(intr_vec_struc si).number]	; Mov w/zero extend
	shl	di,2					; Shift w/zeros fill
	mov	eax,[(intr_vec_struc si).old_isr]
	cmp	[es:di],eax
	je	short loc_5		
	mov	eax,[(intr_vec_struc si).new_isr]
	cmp	[es:di],eax
	jne	short loc_8		
loc_5:
	add	si,size intr_vec_struc
	loop	locloop_4		; Loop if cx > 0

	mov	si,offset intr_vectors
	mov	cx,[vectors_hooked]

locloop_6:
	mov	eax,[(intr_vec_struc si).old_isr]
	movzx	di,[(intr_vec_struc si).number]	; Mov w/zero extend
	shl	di,2			; Shift w/zeros fill
	mov	[es:di],eax
	add	si,size intr_vec_struc
	loop	locloop_6		; Loop if cx > 0

loc_7:
	mov	eax, [old_int_2dh]
	mov	[es:INT2DH_BIOS],eax
	mov	ax, [tsr_psp_seg]		;xxx perhaps error, should be mov bx, [tsr_bx]
	mov	es,ax
	mov	ah,49h
	int	21h			; DOS Services  ah=function 49h
					;  release memory block, es=seg
	mov	ax,1
	jmp	short loc_9
loc_8:
	xor	ax,ax			
loc_9:
	pop	es ds di si cx
	sti				
	iret				; Interrupt return

loc_10:
	cmp	bx, ACTION_SUSPEND
	jne	short loc_15		
	cli				
	push	ebx cx si di ds es
	mov	ax,cs
	mov	ds,ax
	cmp	[vectors_suspend],0
	jne	short loc_13		
	mov	si,offset intr_vectors
	mov	di,offset suspend_vectors
	mov	cx,[vectors_hooked]
	mov	[vectors_suspend],cx
	test	cx,cx
	jz	short loc_12		

locloop_11:
	mov	ebx,[(intr_vec_struc si).new_isr]
	ror	ebx,10h			; Rotate
	mov	es,bx			;save isr seg
	rol	ebx,10h			; Rotate
	mov	al,[es:bx]         	;copy first byte of new isr
	mov	[(intr_suspend_struc di).byte1],al
	mov	eax,[es:bx+1] 		;copy bytes 2-5 of new isr
	mov	[(intr_suspend_struc di).bytes25],eax
	mov	eax,[(intr_vec_struc si).old_isr]
	mov	[byte ptr es:bx],0EAh  	;patch isr with JMP FAR
	mov	[es:bx+1],eax       	;patch isr with jmp far old_intr_XX
	add	si,size intr_vec_struc
	add	di,size intr_suspend_struc
	loop	locloop_11		; Loop if cx > 0

loc_12:
	mov	ax,1
	jmp	short loc_14
loc_13:
	xor	ax,ax			
loc_14:
	pop	es ds di si cx ebx
	sti				
	iret				; Interrupt return

loc_15:
	cmp	bx, ACTION_REACTIVATE
	jne	loc_2			
	cli				
	push	ebx cx si di ds es
	mov	ax,cs
	mov	ds,ax
	cmp	[vectors_suspend],0
	je	short loc_18		
	mov	si,offset intr_vectors
	mov	di,offset suspend_vectors
	mov	cx,[vectors_hooked]
	mov	[vectors_suspend],0
	test	cx,cx
	jz	short loc_17		

locloop_16:
	mov	ebx,[(intr_vec_struc si).new_isr]
	ror	ebx,10h			; Rotate
	mov	es,bx
	rol	ebx,10h			; Rotate
	mov	al,[(intr_suspend_struc di).byte1]
	mov	[es:bx],al		;restore first byte of isr
	mov	eax,[(intr_suspend_struc di).bytes25]
	mov	[es:bx+1],eax         	;restore bytes 2-5 of isr
	add	si,size intr_vec_struc
	add	di,size intr_suspend_struc
	loop	locloop_16		; Loop if cx > 0

loc_17:
	mov	ax,1
	jmp	short loc_19
loc_18:
	xor	ax,ax			
loc_19:
	pop	es ds di si cx ebx
	sti				
	iret				; Interrupt return
ENDP

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ;

Struc 	qk_item
        prog    db 12 dup (0), 0        ; Name of the child process.
        hooknum db 0                    ; Number of FN hooks.
        execnum dw 0                    ; "PID number" of child.
Ends  	

Struc  	qk_hook
        fnaddr  dw 0                    ; Address of FN to hook.
        newaddr dw 0                    ; New address of the FN.
        oldaddr dw 0                    ; Old address of the FN.
Ends 	

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ;


MODE_OPTIMIZE   = 01h                   ; Set if CPU optimization selected.
MODE_HLT        = 02h                   ; Set if normal HLT method selected.
MODE_APM        = 04h                   ; Set if APM cooling method selected.
MODE_NOFORCE    = 08h                   ; Set if any FORCE MODE is disabled.
MODE_WFORCE     = 10h                   ; Set if WEAK FORCE strategy selected.
MODE_SFORCE     = 20h                   ; Set if STRONG FORCE strategy selected.
MODE_MOUSE      = 80h					; Set if there is a mouse driver

IRQ_00          = 01h                   ;
IRQ_01          = 02h                   ;
IRQ_02          = 04h                   ;
IRQ_03          = 08h                   ;
IRQ_04          = 10h                   ;
IRQ_05          = 20h                   ; Flag set if that specific IRQ was
IRQ_06          = 40h                   ; invoked. Should later be cleared by
IRQ_07          = 80h                   ; kernel...

INT_XXH_FORCE   = 300                   ; # of calls to FN before forced HLT. 


;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ;

Align 4
int_xxh_fcount  dd 0                    ;  # int xxh FN(x) called repeatedly.

quirk_table     qk_item <"NC.EXE", 1, 0>
                 qk_hook <int_21h_fntable + 2ch * 2, int_xxh_forcehlt, int_xxh_zerocount>
                qk_item <"SCANDISK.EXE", 1, 0>
                 qk_hook <int_21h_fntable + 0bh * 2, int_xxh_zerocount, int_xxh_forcehlt>
                QK_ITEMS = 2

exec_calls      dw 200                  ; Count of DOS FN 4bh calls.
child_name      db 13 dup (0)           ; Name of the child to be executed.
irq_flags       db 0                    ; IRQ flags for kernel.
tsr_mode_flags  dw 0

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ;
	ASSUME 	DS: CODE_R
Proc    strcmp_res                        ; NOTE: Copied from _string.h!!
        push ax cx si di

        mov cx,0FFh                     ; CX = maximum string length.
@@cmp:  mov al,[ds:si]                  ; Read char from string #1.
        cmp al,[es:di]                  ; Char (#1) == char (#2)?
        jne short @@done                ; Nope, strings can't be equal.

        test al,al                      ; Done (char (#1) = char (#2) = 0)?
        jz short @@done                 ; Yes, string are equal.

        inc si                          ;
        inc di                          ;
        loop @@cmp                      ; Continue.

@@done: pop di si cx ax
        ret
Endp

;----------------------------------------------------------------------------;

Proc    int_xxh_forcehlt
        inc [int_xxh_fcount]                    ; Increase force counter.
        cmp [int_xxh_fcount],INT_XXH_FORCE      ; Over the minimum?
        jb short @@done                         ; Nah, don't HLT yet.

        mov [irq_flags],0               ; Clear IRQ flags.
        sti                             ; Enable IRQs for following HLT.

        test [tsr_mode_flags],MODE_APM      ; APM usage requested?
        jnz short @@apm                 ; Yes.

        ;-  -  -  -  -  -  -  -  -  -  -;
@@std:  test [tsr_mode_flags],MODE_SFORCE   ; Running under STRONG FORCE mode?
        jnz short @@stds                ; Yes.

@@stdw: hlt                             ; Enter power saving mode.
        ret                             ; Fast exit.

@@stds: and [irq_flags],not IRQ_00      ; Clear IRQ0 occurred flag.
	hlt                             ; Enter power saving mode.

        cmp [irq_flags],IRQ_00          ; Was it IRQ0 (timer) ONLY?!
        je @@stds                       ; Yes, go back HLTing.
        ret                             ; Fast exit.
        ;-  -  -  -  -  -  -  -  -  -  -;

        ;-  -  -  -  -  -  -  -  -  -  -;
@@apm:  test [tsr_mode_flags],MODE_SFORCE   ; Running under STRONG FORCE mode?
        jnz short @@apms                ; Yes.

@@apmw:
        push ax                         ; Safety only - AX already saved in the
                                        ; int 14h, 16h, 21h and 2Fh handlers.
        mov ax,5305h                    ;
        pushf                           ;
        call [dword old_int_15h]        ; Call APM FN to put the CPU idle.
        
        pop ax 
        ret

@@apms:
        push ax                         ; Save AX (see comments above)
@@apm2: and [irq_flags],not IRQ_00      ; Clear IRQ0 occurred flag.
        mov ax,5305h                    ;
        pushf                           ;
        call [dword old_int_15h]        ; Call APM FN to put the CPU idle.

        cmp [irq_flags],IRQ_00          ; Was it IRQ0 (timer) ONLY?!
        je @@apm2                       ; Yes, go back HLTing.
        
        pop ax
@@done: ret
Endp

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

Proc    int_xxh_zerocount               ; Zero ALL FORCE counters.
        mov [int_xxh_fcount],0          ; Zero int xxh force counter.
        ret
Endp

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

Proc    int_xxh_skip                    ; Skip ALL FORCE counter updates.
        ret
Endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
;°°°°°°°°°°°°°°°±±±±±±±±±±±±±± INT 21H HANDLER ±±±±±±±±±±±±±±°°°°°°°°°°°°°°°°;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

INT_21H_TOPFN   = 4ch                   ; Highest FN that is handled.


;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ;

Align 4

old_int_21h     dd ?

int_21h_fntable dw offset int_xxh_zerocount    ; FN 00h: Terminate.
                dw offset int_21h_normalhlt    ; FN 01h: Keyboard input.
                dw offset int_xxh_zerocount    ; FN 02h: Display char.
                dw offset int_xxh_skip         ; FN 03h: Auxiliary input.
                dw offset int_xxh_zerocount    ; FN 04h: Auxiliary output.
                dw offset int_xxh_zerocount    ; FN 05h: Printer output.
                dw offset int_21h_fn06h        ; FN 06h: Console I/O.
                dw offset int_21h_normalhlt    ; FN 07h: No echo unfiltered input.
                dw offset int_21h_normalhlt    ; FN 08h: No echo input.
                dw offset int_xxh_zerocount    ; FN 09h: Display string.
                dw offset int_xxh_skip         ; FN 0ah: Buffered input.
                dw offset int_xxh_forcehlt     ; FN 0bh: "Keypressed?"
                dw offset int_xxh_skip         ; FN 0ch: Clear buffer and input.
                dw 24h dup (int_xxh_zerocount)  ; FNs 0dh - 30h.
                dw offset int_21h_fn31h        ; FN 31h: Terminate and Stay Resident.
                dw 19h dup (int_xxh_zerocount)  ; FNs 32h - 4ah.
                dw offset int_21h_fn4bh        ; FN 4bh: Execute child process.
                dw offset int_21h_fn4ch        ; FN 4ch: Terminate child process.

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ;

Proc    int_21h_fn06h                   ; DOS FN: Console I/O.
        cmp dl,0ffh                     ; "Keypressed?" function requested?
        jne short @@done                ; No.

        jmp [int_21h_fntable + 0bh * 2] ; Force HLT (as FN 0bh does it).
@@done: ret
Endp

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

Proc    int_21h_fn31h                   ; DOS FN: Terminate and Stay Resident.
        jmp short int_21h_fn4ch               ; Same as standard exit...
Endp

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

Proc    int_21h_fn4bh                   ; DOS FN: Execute child process.
        pusha
        push es                         ;
        mov bp,sp                       ; BP = ptr to entry DS on stack.

        inc [exec_calls]                ; Increase count of exec calls.

        test al,al                      ; Load and execute child?
        jnz short @@done                ; No, no work for us.

        mov ax,[ss:bp + 2 + 16 + 2]     ; Get DS from stack.
        mov es,ax                       ; 
        mov di,dx                       ; ES:DI = caller's DS:DX = child name.

        ;-  -  -  -  -  -  -  -  -  -  -;
        lea si,[child_name]             ; DS:SI = target buffer for child name.
        xor bx,bx                       ; BX = index of char at [DS:SI].

@@read: mov al,[es:di]                  ; Get char of child name in int 21h.
        mov [ds:si + bx],al             ; Save it to our buffer.

       	cmp al,':'                      ; Was it a DRIVE specifier?
        je short @@kill                 ; Yes.

        cmp al,'\'                      ; Was it a PATH separator?
        jne short @@next                ; No.

@@kill: mov bx,-1                       ; Restart saving to buffer...

@@next: inc di                          ;
        inc bx                          ; Advance index pointers.
        test al,al                      ; At end of ASCIIZ filename?
        jnz @@read                      ; No.
        ;-  -  -  -  -  -  -  -  -  -  -;

        ;-  -  -  -  -  -  -  -  -  -  -;
        lea bx,[quirk_table]            ; BX = ptr to table of quirky programs.
        mov cx,QK_ITEMS                 ; CX = number of entries in table.
        lea di,[child_name]             ;
        mov ax,ds                       ;
        mov es,ax                       ; ES:DI = ptr to ASCIIZ name of child.

@@find: lea si,[(qk_item bx).prog]      ; SI = ptr to quirky child name.
        call strcmp_res                 ; Is this child being executed?
        je short @@set                  ; Yes, handle it.

        mov al,[(qk_item bx).hooknum]   ; AL = number of FN hooks.
        mov ah,size qk_hook             ; AH = size of one FN hook.
        mul ah                          ; AX = value to increment BX with.

        add bx,ax                       ;
        add bx,size qk_item             ;
        loop @@find                     ; Continue.
        jmp short @@done                ; Child is NOT a quirky program, done.
        ;-  -  -  -  -  -  -  -  -  -  -;

        ;-  -  -  -  -  -  -  -  -  -  -;
@@set:  mov ax,[exec_calls]             ;
        mov [(qk_item bx).execnum],ax   ; Save "PID" of this quirky program.

        xor ch,ch                       ;
        mov cl,[(qk_item bx).hooknum]   ; CX = number of hooks to install.
        add bx,size qk_item             ; BX = ptr to first hook data.

        test cl,cl                      ; No hooks needed?
        jz short @@done                 ; Yes, crazy but quit...

@@hook: mov si,[(qk_hook bx).fnaddr]    ; SI = address of FN to hook.
        mov ax,[ds:si]                  ; Get old FN handler.
        mov [(qk_hook bx).oldaddr],ax   ; Save it.

        mov ax,[(qk_hook bx).newaddr]   ; Get new address for FN handler.
        mov [ds:si],ax                  ; Hook FN.

        add bx,size qk_hook             ;
        loop @@hook                     ; Continue.
        ;-  -  -  -  -  -  -  -  -  -  -;

@@done: pop es
        popa
        ret
Endp

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

Proc    int_21h_fn4ch                   ; DOS FN: Terminate child process.
        pusha
        lea bx,[quirk_table]            ; BX = ptr to table of quirky programs.
        mov cx,QK_ITEMS                 ; CX = number of entries in table.

        ;-  -  -  -  -  -  -  -  -  -  -;
@@find: mov ax,[(qk_item bx).execnum]   ; Get "PID" of saved program.
        cmp ax,[exec_calls]             ; Is it this program?
        je short @@set                  ; Yes, handle it.

        mov al,[(qk_item bx).hooknum]   ; AL = number of FN hooks.
        mov ah,size qk_hook             ; AH = size of one FN hook.
        mul ah                          ; AX = value to increment BX with.

        add bx,ax                       ;
        add bx,size qk_item             ;
        loop @@find                     ; Continue.
        jmp short @@done                ; Finish, program wasn't found.
        ;-  -  -  -  -  -  -  -  -  -  -;

        ;-  -  -  -  -  -  -  -  -  -  -;
@@set:  xor ch,ch                       ;
        mov cl,[(qk_item bx).hooknum]   ; CX = number of hooks to deinstall.
        add bx,size qk_item             ; BX = ptr to first hook data.

        test cl,cl                      ; No hooks needed?
        jz short @@done                 ; Yes, crazy but quit...

@@unhk: mov si,[(qk_hook bx).fnaddr]    ; SI = address of FN to unhook.
        mov ax,[(qk_hook bx).oldaddr]   ; Get old FN handler.
        mov [ds:si],ax                  ; Restore original handler.

        add bx,size qk_hook             ;
        loop @@unhk                     ; Continue.
        ;-  -  -  -  -  -  -  -  -  -  -;

@@done: dec [exec_calls]
        popa
        ret
Endp


;----------------------------------------------------------------------------;


Proc    int_21h_normalhlt
        sti                             ; Enable IRQs for following HLT.
        mov ah,0bh                      ; Int 21h FN: "Keypressed?".

        test [tsr_mode_flags],MODE_APM      ; APM usage requested?
        jnz short @@apml                ; Yes.

@@stdl: hlt                             ; Enter power saving mode.
        pushf                           ;
        call [dword old_int_21h]        ; Simulate int 21h without reentrancy.

        cmp al,0ffh                     ; Keystroke ready?
        jne @@stdl                      ; No, continue HLTing.
        jmp short @@done                ; Finish.

@@apml: mov ax,5305h                    ;
        pushf                           ;
        call [dword old_int_15h]        ; Call APM FN to put the CPU idle.

        mov ah,0bh                      ; Int 21h FN: "Keypressed?"
        pushf                           ;
        call [dword old_int_21h]        ; Simulate int 21h without reentrancy.

        cmp al,0ffh                     ; Keystroke ready?
        jne @@apml                      ; No, continue HLTing.
@@done: ret
Endp


;----------------------------------------------------------------------------;

Align 4

Proc    int_21h_handler                 ; DOS functions handler.
        push ax bx ds
        mov bx,cs                       ;
        mov ds,bx                       ; CODE = DATA.

        cmp ah,INT_21H_TOPFN            ; FN irrelevant for our handler?
        ja short @@old                  ; Yes, zero force counter and chain.

        xor bh,bh                       ;
        mov bl,ah                       ;
        add bx,bx                       ; BX = index to int_21h_fntable.
        add bx,offset int_21h_fntable   ; BX = offset of handler.

        call [word bx]                  ; Call the appropriate FN handler.
        jmp short @@oldn                ; Chain without zeroing force count.

@@old:  mov [int_xxh_fcount],0          ; Zero int xxh force counter.

@@oldn: pop ds bx ax
        jmp [dword cs:old_int_21h]      ; Chain to old interrupt handler.
Endp



;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
;°°°°°°°°°°°°°°°±±±±±±±±±±±±±± INT 16H HANDLER ±±±±±±±±±±±±±±°°°°°°°°°°°°°°°°;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

INT_16H_TOPFN   = 12h                   ; Highest FN that is handled.


;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ;


Align 4

old_int_16h     dd ?

int_16h_fntable dw offset int_16h_normalhlt    ; FN 00h: Keyboard input.
                dw offset int_xxh_forcehlt     ; FN 01h: "Keypressed?".
                dw offset int_xxh_forcehlt     ; FN 02h: "SHIFT Keypressed?".
                dw 0dh dup (int_xxh_zerocount)  ; FNs 03h - 09h.
                dw offset int_16h_normalhlt    ; FN 10h: Keyboard input (101-keys).
                dw offset int_xxh_forcehlt     ; FN 11h: "Keypressed?" (101-keys).
                dw offset int_xxh_forcehlt     ; FN 12h: "SHIFT Keypressed?" (101).


;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ;

Proc    int_16h_normalhlt
        push bx                         ; Safety only - BX already saved in the main Int-16 handler

        inc ah                          ; Int 16h FN: Is keystroke ready?
        mov bh,ah                       ; Save AH (FN number).
        sti                             ; Enable IRQs for following HLT.

        test [tsr_mode_flags],MODE_APM      ; APM usage requested?
        jnz short @@apml                ; Yes.

@@stdl: pushf                           ;
        call [dword old_int_16h]        ; Simulate int 16h without reentrancy.
        jnz short @@done                ; If ZF == 0 then key is ready.

        hlt                             ; Enter power saving mode.

        mov ah,bh                       ; Restore saved AH (FN number).
        jmp @@stdl

@@apml: pushf                           ;
        call [dword old_int_16h]        ; Simulate int 16h without reentrancy.
        jnz short @@done                ; If ZF == 0 then key is ready.

        mov ax,5305h                    ;
        pushf                           ;
        call [dword old_int_15h]        ; Call APM FN to put the CPU idle.

        mov ah,bh                       ; Restore saved AH (FN number).
        jmp @@apml                      ; No, continue HLTing.
@@done:
        pop bx
        ret
Endp


;----------------------------------------------------------------------------;

Align 4

Proc    int_16h_handler                 ; BIOS keyboard functions handler.
        push ax bx ds
        mov bx,cs                       ;
        mov ds,bx                       ; CODE = DATA.

        cmp ah,INT_16H_TOPFN            ; FN irrelevant for our handler?
        ja short @@old                  ; Yes, zero force counter and chain.

        xor bh,bh                       ;
        mov bl,ah                       ;
        add bx,bx                       ; BX = index to int_16h_fntable.
        add bx,offset int_16h_fntable   ; BX = offset of handler.

        call [word bx]                  ; Call the appropriate FN handler.
        jmp short @@oldn                ; Chain without zeroing force count.

@@old:  mov [int_xxh_fcount],0          ; Zero int xxh force counter.

@@oldn: pop ds bx ax
        jmp [dword cs:old_int_16h]      ; Chain to old interrupt handler.
Endp



;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
;°°°°°°°°°°°°°°°±±±±±±±±±±±±±± INT 2FH HANDLER ±±±±±±±±±±±±±±°°°°°°°°°°°°°°°°;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

INT_2FH_TOPFN   = 0ffffh                ; Highest FN that is handled.


;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ;

Align 4

old_int_2fh     dd	?

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ;

Align 4

Proc    int_2fh_handler
        push ax dx ds                   ; (AX might be clobbered in int_xxh_forcehlt)
        mov dx,cs                       ;
        mov ds,dx                       ; CODE = DATA.
        
        cmp ax,1680h                    ; DPMI release time slice?
        je short @@dpmi                 ; Yes.

        cmp ax,1607                     ; Windows VMPoll Idle callout?
        jne short @@old                 ; No, exit.

@@vmpl: cmp bx,0018h                    ; Is it the VMPoll VxD ID number?
        jne short @@old                 ; No, exit.

        test cx,cx                      ; Is it the VMPoll driver?
        jnz short @@old                 ; No, exit.

@@dpmi: call int_xxh_forcehlt           ; Enter power saving mode.
        jmp short @@oldn                ; Chain without zeroing force count.

@@old:  mov [int_xxh_fcount],0          ; Zero int xxh force counter.

@@oldn: pop ds dx ax
        jmp [dword cs:old_int_2fh]      ; Chain to old interrupt handler.	
Endp

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ;

Align 4

old_int_33h         dd ?
user_mouse_handler  dd ? 
user_mouse_mask     dw 0

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ;

Align 4

Proc    int_33h_handler
        sti                                ; (let 'em run!)

        mov [cs:int_xxh_fcount],0          ; Zero int xxh force counter.
        
        cmp ax,000Ch
        je short @@set_handler
        cmp ax,0014h
        je short @@xchg_handler
        cmp ax,0018h
        je short @@set_alt_handler

        jmp [dword cs:old_int_33h]      ; Chain to old interrupt handler.

@@set_handler:
        push es dx cx
        call install_mouse_handler
        pop  cx dx es
        iret

@@xchg_handler:
        call install_mouse_handler
        iret
		
@@set_alt_handler:
        mov ax,0FFFFh		; Return error
        iret
Endp

Proc	mouse_handler
	ASSUME DS:NOTHING
        mov [cs:int_xxh_fcount],0          ; Zero int xxh force counter.

        and ax,[cs:user_mouse_mask]
        jz short @@done

        ;call debug_char

        jmp [dword cs:user_mouse_handler]
@@done:		
        retf
Endp

;----------------------------------------------------------------------------;
; Installs a new mouse handler and returns the current one
; ES:DX - the new mouse handler to install (can be 0:0)
; CX - the new mouse event mask (can be 0)
;
; NB: re saving/clobbering CX, DX, ES. This proc used in two cases:
;   - Service int 33H fn 0Ch (set new mouse handler). CX, DX and ES are already
;     saved before this proc is called, and restored later.
;   - Service int 33h fn 14h (to set a new mouse handler and to return the old one).
;     These regs must NOT be saved and restored, as int 33h fn 14h returns the old
;     mouse handler in ES:DX and the old event mask in CX.

Proc	install_mouse_handler
	ASSUME DS:CODE_R
        push ds     ; (Do NOT save/restore CX, DX, ES - see note above)
        push eax
        mov ax,cs	; Set the DS to point to our segment
        mov ds,ax

        ; Save the new mouse handler

        mov ax,es
        rol eax,16
        mov ax,dx		; EAX now contains the new handler
        test eax,eax		; Is the new handler null?
        jnz short @@valid_handler
  	mov ax,cs
        rol eax,16		; YES, replace with dummy_mouse_handler and zero the mask
	mov ax,offset dummy_mouse_handler
        xor cx,cx

@@valid_handler:
        xchg [user_mouse_handler],eax
        xchg [user_mouse_mask],cx
        mov dx,ax	; Save the previous handler in ES:DX
        ror eax,16
        mov es,ax

        push es
        push dx
        push cx

        ; Install our real mouse handler

        mov dx,cs
        mov es,dx
        mov dx,offset mouse_handler
        mov cx,7Fh						; Catch all mouse events
        mov ax,000Ch
        pushf
        call [dword old_int_33h]      ; "INT-Call" to old interrupt handler.

        pop cx
        pop dx
        pop es

        pop eax
        pop ds
        ret
Endp

Proc	dummy_mouse_handler
        retf
Endp

;----------------------------------------------------------------------------;
; Debugging - show "changing" char at top-left of screen

; proc	debug_char
        ; push es
        ; push ax
        ; mov ax,0B800h
        ; mov es,ax
        ; inc [byte ptr es:0]
        ; pop ax
        ; pop es
        ; ret
; endp


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
;°°°°°°°°°°°°°°°±±±±±±±±±±±±±± INT 14H HANDLER ±±±±±±±±±±±±±±°°°°°°°°°°°°°°°°;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

INT_14H_TOPFN   = 03h                   ; Highest FN that is handled.


;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ;

Align 4

old_int_14h   	dd ?

int_14h_fntable dw offset int_xxh_zerocount    ; FN 00h: Init COM port.
                dw offset int_xxh_zerocount    ; FN 01h: Send char to COM port.
                dw offset int_14h_normalhlt    ; FN 02h: Read char from COM port.
                dw offset int_xxh_forcehlt     ; FN 03h: "Char ready?"


;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ;


Proc    int_14h_normalhlt
	sti                             ; Enable IRQs for following HLT.

        test [tsr_mode_flags],MODE_APM      ; APM usage requested?
        jnz short @@apml                ; Yes.

@@stdl: hlt                             ; Enter power saving mode.
        mov ah,03h                      ; Int 14h FN: Get serial port status.
        pushf                           ;
        call [dword old_int_14h]        ; Simulate int 14h without reentrancy.

        test ah,1                       ; Is data ready?
        jz @@stdl                       ; No, continue loop.
        jmp short @@done                ; Finish.

@@apml: mov ax,5305h                    ;
        pushf                           ;
        call [dword old_int_15h]        ; Call APM FN to put the CPU idle.

        mov ah,03h                      ; Int 14h FN: Get serial port status.
        pushf                           ;
        call [dword old_int_14h]        ; Simulate int 14h without reentrancy.

        test ah,1                       ; Is data ready?
        jz @@apml                       ; No, continue loop.
@@done: ret
Endp


;----------------------------------------------------------------------------;

Align 4

Proc    int_14h_handler                 ; BIOS serial I/O handler.
        push ax bx ds
        mov bx,cs                       ;
        mov ds,bx                       ; CODE = DATA.

        cmp ah,INT_14H_TOPFN            ; FN irrelevant for our handler?
        ja short @@old                  ; Yes, zero force counter and chain.

        xor bh,bh                       ;
        mov bl,ah                       ;
        add bx,bx                       ; BX = index to int_14h_fntable.
        add bx,offset int_14h_fntable   ; BX = offset of handler.

        call [word bx]                  ; Call the appropriate FN handler.
        jmp short @@oldn                ; Chain without zeroing force count.

@@old:  mov [int_xxh_fcount],0          ; Zero int xxh force counter.

@@oldn: pop ds bx ax
        jmp [dword cs:old_int_14h]      ; Chain to old interrupt handler.
Endp




;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
;°°°°°°°°°°°°°°°±±±±±±±±±±±±±± INT 1xH HANDLER ±±±±±±±±±±±±±±°°°°°°°°°°°°°°°°;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

Align 4

old_int_10h     dd ?              ;
old_int_15h     dd ?             ; Original vector values.

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ;

	ASSUME 	DS: NOTHING

Align 4

Proc    int_10h_handler                 ; BIOS video functions handler.
        mov [cs:int_xxh_fcount],0       ; Zero int xxh force counter.
        jmp [dword cs:old_int_10h]      ; Chain to old interrupt handler.
Endp


;----------------------------------------------------------------------------;

Align 4

Proc    int_15h_handler                 ; BIOS AT Services handler.
        cmp ax,5305h                    ; APM function: CPU idle called?
        je short @@old                  ; No.

        mov [cs:int_xxh_fcount],0       ; Zero int xxh force counter.

@@old:  jmp [dword cs:old_int_15h]      ; Chain to old interrupt handler.
Endp



;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
;°°°°°°°°°°°°°°°°±±±±±±±±±±±±±±± IRQ HANDLERS ±±±±±±±±±±±±±±±°°°°°°°°°°°°°°°°;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

Align 4

old_masterirqs  dd 8 dup (?)     ; Original handlers of the hooked IRQs.
new_masterirqs  dd irq_00_handler
		dd irq_01_handler
                dd irq_02_handler
		dd irq_03_handler
                dd irq_04_handler
		dd irq_05_handler
                dd irq_06_handler
		dd irq_07_handler

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ;

Align 4

Proc    irq_00_handler                  ; Handler for IRQ 0 (timer).
        or [cs:irq_flags],IRQ_00        ; Mark that IRQ 0 occurred.

        jmp [dword cs:old_masterirqs]   ; Chain to old interrupt handler.
Endp


;----------------------------------------------------------------------------;
Align 4

Proc    irq_01_handler                  ; Handler for IRQ 1 (keyboard).
        or [cs:irq_flags],IRQ_01        ; Mark that IRQ 1 occurred.

        mov [cs:int_xxh_fcount],0          ; Zero int xxh force counter.
        jmp [dword cs:old_masterirqs + 4]  ; Chain to old interrupt handler.
Endp


;----------------------------------------------------------------------------;
Align 4

Proc    irq_02_handler                  ; Handler for IRQ 2 (slave PIC).
        or [cs:irq_flags],IRQ_02        ; Mark that IRQ 2 occurred.

        mov [cs:int_xxh_fcount],0          ; Zero int xxh force counter.
        jmp [dword cs:old_masterirqs + 8]  ; Chain to old interrupt handler.
Endp


;----------------------------------------------------------------------------;
Align 4

Proc    irq_03_handler                  ; Handler for IRQ 3 (COM2).
        or [cs:irq_flags],IRQ_03        ; Mark that IRQ 3 occurred.

        mov [cs:int_xxh_fcount],0          ; Zero int xxh force counter.
        jmp [dword cs:old_masterirqs + 12] ; Chain to old interrupt handler.
Endp


;----------------------------------------------------------------------------;
Align 4

Proc    irq_04_handler                  ; Handler for IRQ 4 (COM1).
        or [cs:irq_flags],IRQ_04        ; Mark that IRQ 4 occurred.

        mov [cs:int_xxh_fcount],0          ; Zero int xxh force counter.
        jmp [dword cs:old_masterirqs + 16] ; Chain to old interrupt handler.
Endp


;----------------------------------------------------------------------------;
Align 4

Proc    irq_05_handler                  ; Handler for IRQ 5.
        or [cs:irq_flags],IRQ_05        ; Mark that IRQ 5 occurred.

        mov [cs:int_xxh_fcount],0          ; Zero int xxh force counter.
        jmp [dword cs:old_masterirqs + 20] ; Chain to old interrupt handler.
Endp


;----------------------------------------------------------------------------;
Align 4

Proc    irq_06_handler                  ; Handler for IRQ 6.
        or [cs:irq_flags],IRQ_06        ; Mark that IRQ 6 occurred.

        mov [cs:int_xxh_fcount],0          ; Zero int xxh force counter.
        jmp [dword cs:old_masterirqs + 24] ; Chain to old interrupt handler.
Endp


;----------------------------------------------------------------------------;
Align 4

Proc    irq_07_handler                  ; Handler for IRQ 7.
        or [cs:irq_flags],IRQ_07        ; Mark that IRQ 7 occurred.

        mov [cs:int_xxh_fcount],0          ; Zero int xxh force counter.
        jmp [dword cs:old_masterirqs + 28] ; Chain to old interrupt handler.
Endp

RESIDENT_END:

ENDS

SEGMENT	DATA16

KERNEL_NAME   equ "CPUidle for DOS"     ; Name of the kernel.
KERNEL_FILE   equ "DOSidle"             ; Name of the .exe (compiled) kernel.
KERNEL_ID     equ 0deedh                ; ID number of this program.

SYS_RAW         = 01h                   ;
SYS_VCPI        = 02h                   ; Flags for PM hosts driving the
SYS_DPMI        = 04h                   ; system.
OFF		= 00h
ON		= 01h
CR		= 13
LF		= 10
NL		equ <CR,LF>

psp_seg         dw 0
env_seg         dw 0
                     
dos_version     dw 0                    ; MS-DOS version.
apm_version     dw 0                    ; Advanced Power Management version.
apm_state       db OFF                  ; State of APM (enabled, disabled).
                    
sys_type        db SYS_RAW              ; Type of system (Raw, VCPI, DPMI).

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;
struc	par_item
	switch		db 11 dup (0)
	proc_offset	dw	0		
ends

par_table	par_item <"-H", par_help>                         		
	       	par_item <"-?", par_help>                         
	       	par_item <"-U", par_uninst>                       
	       	par_item <"-ON", par_on>                          
	      	par_item <"-OFF", par_off>                        
	      	par_item <"-CPU", par_cpu>                        
	      	par_item <"-HLT", par_hlt>                        
	      	par_item <"-APM", par_apm>                        
	      	par_item <"-FM0", par_noforce>                    
	      	par_item <"-FM1", par_weakforce>                  
	      	par_item <"-FM2", par_strongforce>                
	       	par_item <0>            		; Marks end of par_table. ar_table.

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

msg_intro       db KERNEL_NAME, " V3.00  [Build 0200]", NL
                db "Copyright (C) by Marton Balog, 1998.", NL
		db "		Updates 2015 by I. Tsenov & M. Kennedy", NL
		db "		Updates 2018 by Wojciech Galazka",NL,0
msg_help        db "Syntax:    ", KERNEL_FILE, " [Options]", NL
                db "--------", NL,0
msg_options_1   db "Standard   -On     Activate ", KERNEL_FILE, ".", NL
                db "Options:   -Off    Suspend ", KERNEL_FILE, ".", NL
                db "--------   -U      Uninstall ", KERNEL_FILE, ".", NL
                db "           -H, -?  Display this help message.", NL,0
msg_options_2   db "Advanced   -Cpu    Optimize processor for performance.", NL
                db "Options:   -Hlt    Select cooling method: HLT idle cycles (default).", NL
                db "--------   -Apm    Select cooling method: APM V1.00+ cycles.", 0
msg_options_3   db "           -Fm2    Select cooling strategy: Strong Forcing (default).", NL
                db "           -Fm1    Select cooling strategy: Weak Forcing.", NL
                db "           -Fm0    Select cooling strategy: No Forcing.", NL,0
msg_examples_1  db "Example:   ", KERNEL_FILE, "             Install and activate ", KERNEL_FILE, ".", NL
                db "--------   ", KERNEL_FILE, " -Off        Suspend ", KERNEL_FILE, " temporarily.", 0
msg_examples_2  db "           ", KERNEL_FILE, " -Fm2 -Apm   Enable Strong Forcing and use APM for cooling.",NL
                db "           ", KERNEL_FILE, " -Fm1 -Cpu   Enable Weak Forcing and optimize CPU.", NL,0

msg_inst        db NL, KERNEL_FILE, " installed successfully.",0
msg_uninst      db KERNEL_FILE, " uninstalled successfully.",0
msg_activate    db KERNEL_FILE, " is now activated.",0
msg_suspend     db KERNEL_FILE, " is now suspended.",0

msg_nl          db NL, 0
msg_na          db "N/A",0

msg_detect      db "DETECTING...", 0
msg_cpudet      db "[Processor]: ", 0
msg_apmdet      db "[Power/Man]: ", 0
msg_osdet       db "[Op/System]: ", 0
msg_pmdet       db "[32-b mode]: ", 0
msg_mouse       db "[Mouse drv]: ", 0

msg_apm         db "APM V",0
msg_apm_on      db " [Enabled].",0
msg_apm_off     db " [Disabled].",0
msg_msdos       db "MS-DOS V",0
msg_msdos_std   db " [Standard].",0
msg_msdos_win   db " [Windows 95/98].",0
msg_raw         db "16-bit MS-DOS interface.",0
msg_vcpi        db "32-bit VCPI interface.",0
msg_dpmi        db "32-bit DPMI interface.",0
msg_yes         db "Yes", 0
msg_no          db "No", 0

msg_optimize    db NL, "OPTIMIZING...", 0
msg_optnomod    db "No modifications made",0 

err_str         db "FATAL ",0
err_notinst     db "[#20]: ", KERNEL_FILE, " is not installed.",0
err_inst        db "[#21]: ", KERNEL_FILE, " is already installed.",0
err_uninst      db "[#22]: Cannot uninstall ", KERNEL_FILE ,".",0
err_activate    db "[#23]: ", KERNEL_FILE, " is already activated.",0
err_suspend     db "[#24]: ", KERNEL_FILE, " is already suspended.",0
err_cpu         db "[#30]: A 386 CPU or better is required.",0
err_dos_vers    db "[#32]: MS-DOS 5.00 or later is required.",0
err_cmdln       db "[#40]: Invalid command-line switch.",0
err_v86         db "[#50]: CPU in V86 mode and no VCPI or DPMI host present.",0

mode_flags  		dw 	MODE_SFORCE          ; Config flags for program startup.
hex_table		db	'0123456789ABCDEF'

v86_callback		dd	0
fpu_check		dw	0

cpu_name		db	49 dup (0)			
cpuid_str		db    	13 dup (0)			
cpu_stepping		db	0                      		
cpu_family		db	0				
cpu_model		db	0				
cpu_type        	db	0				
cpu_features   		dd	0				

highest_basic_cpuid	dd 	0		
highest_ext_cpuid	dd      0		
cpu_failed_str		db	'CPU detection failed.',0
                	
cpu_386_str		db	'Standard 80386', 0
cpu_386fpu_str		db	'Standard 80386 with 80387', 0
cpu_486sx_str		db	'Standard 80486SX', 0
cpu_486dx_str		db	'Standard 80486DX', 0

cyrix_0			db	00h
cyrix_1			db 	00h		;1b37
cyrix_2			db	00h         	;1bc8
cpu_cyrix_01_str	db	'CyrixInstead', 0
cpu_cyrix_02_str	db	'Unknown Cyrix', 0
cpu_cyrix_03_str	db	'Cyrix 486SLC', 0
cpu_cyrix_04_str	db	'Cyrix 486DLC', 0
cpu_cyrix_05_str	db	'Cyrix 486SLC2', 0
cpu_cyrix_06_str	db	'Cyrix 486DLC2', 0
cpu_cyrix_07_str	db	'Cyrix 486SRx', 0
cpu_cyrix_08_str	db	'Cyrix 486DRx', 0
cpu_cyrix_09_str	db	'Cyrix 486SRx2', 0
cpu_cyrix_10_str	db	'Cyrix 486DRx2', 0
cpu_cyrix_11_str	db	'Cyrix 486SRu', 0
cpu_cyrix_12_str	db	'Cyrix 486DRu', 0
cpu_cyrix_13_str	db	'Cyrix 486SRu2', 0
cpu_cyrix_14_str	db	'Cyrix 486DRu2', 0
cpu_cyrix_15_str	db	'Cyrix 486S', 0
cpu_cyrix_16_str	db	'Cyrix 486S2', 0
cpu_cyrix_17_str	db	'Cyrix 486Se', 0
cpu_cyrix_18_str	db	'Cyrix 486S2e', 0
cpu_cyrix_19_str	db	'Cyrix 486DX', 0
cpu_cyrix_20_str	db	'Cyrix 486DX2', 0
cpu_cyrix_21_str	db	'Cyrix 486SLC/DLC', 0
cpu_cyrix_22_str	db	'Cyrix 486Sa', 0
cpu_cyrix_23_str	db	'Cyrix 486DX4', 0
cpu_cyrix_24_str	db	'Cyrix 5x86', 0
cpu_cyrix_25_str	db	'Cyrix 6x86', 0
cpu_cyrix_26_str	db	'Cyrix 6x86L', 0
cpu_cyrix_27_str	db	'Cyrix 6x86MX', 0
cpu_cyrix_28_str	db	'Cyrix MediaGX', 0
cpu_cyrix_29_str	db	'Cyrix GXm', 0

intel_0			db	00h				
cpu_intel_01_str	db	'GenuineIntel', 0
cpu_intel_02_str	db	'Unknown Intel', 0
cpu_intel_03_str	db	'Intel 486DX at 25/33 Mhz', 0
cpu_intel_04_str	db	'Intel 486DX at 50 Mhz', 0
cpu_intel_05_str	db	'Intel 486SX', 0
cpu_intel_06_str	db	'Intel 486DX2', 0
cpu_intel_07_str	db	'Intel 486SL', 0
cpu_intel_08_str	db	'Intel 486SX2', 0
cpu_intel_09_str	db	'Intel 486DX2-WB', 0
cpu_intel_10_str	db	'Intel 486DX4', 0
cpu_intel_11_str	db	'Intel 486DX4-WB', 0
cpu_intel_12_str	db	'Intel Pentium A-Step', 0
cpu_intel_13_str	db	'Intel Pentium', 0
cpu_intel_14_str	db	'Intel Pentium OverDrive', 0
cpu_intel_15_str	db	'Intel Pentium-MMX', 0
cpu_intel_16_str	db	'Intel Pentium Pro A-Step', 0
cpu_intel_17_str	db	'Intel Pentium Pro', 0
cpu_intel_18_str	db	'Intel Pentium II', 0

cpu_amd_01_str		db	'AuthenticAMD', 0		
cpu_amd_02_str		db	'Unknown AMD', 0
cpu_amd_03_str		db	'AMD 486DX2', 0
cpu_amd_04_str		db	'AMD 486DX2-WB', 0
cpu_amd_05_str		db	'AMD 486DX4', 0
cpu_amd_06_str		db	'AMD 486DX4-WB', 0
cpu_amd_07_str		db	'AMD 5x86', 0
cpu_amd_08_str		db	'AMD 5x86-WB', 0
cpu_amd_09_str		db	'AMD K5-SS/A', 0
cpu_amd_10_str		db	'AMD K5', 0
cpu_amd_11_str		db	'AMD K6-MMX', 0
cpu_amd_12_str		db	'AMD K6-3D', 0
cpu_amd_13_str		db	'AMD K6-Plus', 0
                	
idt_0			db	? 
cpu_idt_01_str		db	'CentaurHauls', 0		
cpu_idt_02_str		db	'Unknown IDT', 0
cpu_idt_03_str		db	'IDT WinChip C6', 0
cpu_idt_04_str		db	'IDT WinChip C6-Plus', 0

cpu_nexgen_01_str	db	'NexGenDriven', 0
cpu_nexgen_02_str	db	'Unknown NexGen', 0
cpu_nexgen_03_str	db	'NexGen Nx586', 0
cpu_nexgen_04_str	db	'NexGen Nx586 with Nx587', 0
cpu_nexgen_05_str	db	'NexGen Nx686', 0

cpu_umc_01_str		db	'UMC UMC UMC ', 0
cpu_umc_02_str		db	'Unknown UMC', 0
cpu_umc_03_str		db	'UMC U5D', 0
cpu_umc_04_str		db	'UMC U5S', 0

ENDS

SEGMENT	CODE16
	ASSUME CS:CODE16, DS:DATA16, SS:STACK16, FS:CODE_R

PROC	mem_lrelease
	push	ax es
	mov	es,ax
	mov	ah,49h
	int	21h			; DOS Services  ah=function 49h
					;  release memory block, es=seg
	pop	es ax
	retn
ENDP

PROC	TSR_INSTCHECK
	push	bx
	xor	bx,bx			
	int	2Dh			; ??INT Non-standard interrupt
	cmp	ax, TSR_ID
	sete	al			; Set byte if equal
	mov	ah,0
	pop	bx
	retn
ENDP

PROC	TSR_UNINSTALL
	push	bx
	mov	bx, ACTION_UNINSTALL
	int	2Dh			; ??INT Non-standard interrupt
	pop	bx
	retn
ENDP

PROC	TSR_SUSPEND
	push	bx
	mov	bx, ACTION_SUSPEND
	int	2Dh			; ??INT Non-standard interrupt
	pop	bx
	retn
ENDP

PROC	TSR_REACTIVATE
	push	bx
	mov	bx, ACTION_REACTIVATE
	int	2Dh			; ??INT Non-standard interrupt
	pop	bx
	retn
ENDP

	ASSUME 	DS: CODE_R

PROC	TSR_HOOKINT
	pushf				
	pushad				
	push	ds es
	ASSUME	DS:CODE_R
	cli				
	mov	si,fs
	mov	ds,si
	xor	esi,esi			                                                 
	mov	es,si                                                   	
	mov	ecx, size intr_vec_struc                 			
	mov	si, [vectors_hooked]		        		
	inc	[vectors_hooked]         
	imul	esi,ecx			           	  			
	add	si,offset intr_vectors	        
	mov	[(intr_vec_struc si).number],bl                  		
	mov	[(intr_vec_struc si).new_isr],eax                		
	xor	bh,bh			           	
	shl	bx,2			           	
	xchg	[es:bx],eax                        
	mov	[(intr_vec_struc si).old_isr],eax  
	sti				
	pop	es ds
	popad				
	popf				
	retn
ENDP

PROC	tsr_install
	;       mov cx,OFFSET RESIDENT_END             ;
	;	mov di,[mode_flags]		;
	;	mov dx,KERNEL_ID                ;
	;	mov bx,[psp_seg]                ;
	;	mov ax,[env_seg]                ;
	;	call tsr_install                ; Make kernel TSR.
	cli					
	push	ds
	ASSUME	DS:CODE_R
	mov	si,fs
	mov	ds,si
	mov	[tsr_mode_flags],di
	mov	[tsr_kernel_id],dx
	mov	[tsr_psp_seg],bx
	mov	[tsr_env_seg],ax
	xor	ax,ax				
	mov	es,ax                   	
	mov	eax,[es:int2dh_bios]		;get original isr 2dh
	mov	[old_int_2dh],eax		;store away
	mov	eax,[new_int_2dh]			;new isr 2dh
	mov	[es:int2dh_bios],eax		;set in ivt
	mov	ax,[tsr_env_seg]
	call	mem_lrelease
	pop	ds
	mov	dx,cx
	mov	ax,3100h
	int	21h				; DOS Services  ah=function 31h
	ret
ENDP

	ASSUME	DS: DATA16
macro	exit	exit_code
	mov	al, exit_code
	mov	ah, 4ch
	int	21h
endm

Proc    error_exit                      ; Exits with error message.
	push si
	lea si,[err_str]                ;
	call con_writef                 ; Print "[FATAL]: "
	pop si

	sti
	call con_writeln                ; Print error message.
	exit 0                          ; Off we go...
	ret
Endp

Proc    init
	mov ax,DATA16                       ;
	mov ds,ax                       ; Set data segment.
	mov ax,CODE_R
	mov fs,ax
	xor ax,ax			;
	mov gs,ax               	; GS = segment of IVT.

	mov [psp_seg],es                ; Save PSP segment.
	mov ax,[es:2ch]                 ;
	mov [env_seg],ax                ; Save environment segment.

	lea si,[msg_intro]              ;
	call con_writeln                ; Display program name, copyright...

	call test_cpu                   ; Get CPU family number.
	lea si,[err_cpu]                ;
	cmp al,3                        ; Less than a 386 (286-)?
	jb error_exit                   ; Yep, error.

        mov ax,3000h                    ;
	int 21h                         ; Get DOS version.
        mov [dos_version],ax            ; Save it.

	lea si,[err_dos_vers]           ; Prepare for error.
	cmp al,5                        ; Is DOS new enough (5.00+)?
        jb error_exit                   ; No (4.99-) fail.

	ret
Endp

Proc    par_help
	lea si,[msg_help]               ;
	call con_writeln                ; Display help message.

        lea si,[msg_options_1]          ;
        call con_writeln                ; Display options help part 1.

        lea si,[msg_options_2]          ;
        call con_writeln                ; Display options help part 2.

        lea si,[msg_options_3]          ;
        call con_writeln                ; Display options help part 3.

        lea si,[msg_examples_1]         ;
        call con_writeln                ; Display examples help part 1.

        lea si,[msg_examples_2]         ;
        call con_writeln                ; Display examples help part 2.
	exit 0
Endp

Proc    par_uninst
	mov dx,KERNEL_ID                ;
	call tsr_instcheck              ; Is kernel installed already?

	lea si,[err_notinst]            ;
	test ax,ax                      ; AX == 0 if not installed.
	je error_exit                   ; Nope, can't uninstall, error.

	mov dx,KERNEL_ID                ;
        call tsr_uninstall              ; Try to uninstall kernel.

        lea si,[err_uninst]             ; Prepare for error.
        test ax,ax                      ; Uninstallation failed?
        jz error_exit                   ; Yes, fail.

        lea si,[msg_uninst]             ;
	call con_writeln                ; Print success message.
	exit 0                          ; Quit.
Endp

Proc    par_on
	mov dx,KERNEL_ID                ;
	call tsr_instcheck              ; Is kernel installed already?

	test ax,ax                      ; AX == 0 if not installed.
        jnz short @@on                  ; It's installed, try to activate.

        ret                             ; Do normal install if it's 1st time.

@@on:   mov dx,KERNEL_ID                ;
        call tsr_reactivate             ; Try to reactivate int handlers.

        lea si,[err_activate]           ;
        test ax,ax                      ; Reactivation of ints failed?
        jz error_exit                   ; Yes, fail.

        lea si,[msg_activate]           ;
        call con_writeln                ; Print success message.
        exit 0                          ; Quit.
Endp

Proc    par_off
	mov dx,KERNEL_ID                ;
	call tsr_instcheck              ; Is kernel installed already?

	lea si,[err_notinst]            ;
	test ax,ax                      ; AX == 0 if not installed.
        jz error_exit                   ; Nope, can't suspend, error.

        mov dx,KERNEL_ID                ;
        call tsr_suspend                ; Try to suspend interrupt handlers.

        lea si,[err_suspend]            ;
        test ax,ax                      ; Suspension of ints failed?
        jz error_exit                   ; Yes, fail.
        
        lea si,[msg_suspend]            ;
        call con_writeln                ; Print success message.
        exit 0                          ; Quit.
Endp

Proc    par_cpu
        or [mode_flags],MODE_OPTIMIZE   ; Request CPU optimization.
        ret
Endp

Proc    par_apm
        or [mode_flags],MODE_APM        ;
        and [mode_flags],not MODE_HLT   ; Set APM MODE in config flags.
        ret
Endp

Proc    par_hlt
        or [mode_flags],MODE_HLT        ; 
        and [mode_flags],not MODE_APM   ; Set HLT MODE in config flags.
        ret
Endp

Proc    par_noforce
        or [mode_flags],MODE_NOFORCE    ; Set NO FORCE in config flags.

        and [mode_flags],not MODE_WFORCE
        and [mode_flags],not MODE_SFORCE
        ret
Endp

Proc    par_weakforce
        or [mode_flags],MODE_WFORCE     ; Set WEAK FORCE in config flags.

        and [mode_flags],not MODE_SFORCE
        and [mode_flags],not MODE_NOFORCE
        ret
Endp

Proc    par_strongforce
        or [mode_flags],MODE_SFORCE     ; Set STRONG FORCE in config flags.

        and [mode_flags],not MODE_WFORCE
        and [mode_flags],not MODE_NOFORCE
        ret
Endp

Proc    read_cmdln
	mov di,80h                      ;
	mov es,[psp_seg]                ; ES:DI = ptr to command-line.
	lea si,[par_table]              ; DS:SI = ptr to parameter_table.

	call parse_cmdln                ; Process the command line.
	lea si,[err_cmdln]              ;
	jc error_exit                   ; Quit if invalid command-line switch.
	ret
Endp

Proc    init_modes
        test [mode_flags],MODE_NOFORCE  ; FORCE MODE disabled?
        jz short @@sfor                 ; No.

        mov [byte fs:int_xxh_forcehlt],0c3h  ; Disable FORCE HLT/APM procedure overwriting it with RET. 

@@sfor: test [mode_flags],MODE_SFORCE   ; STRONG FORCE MODE enabled?
        jz short @@apm                  ; No.

        cmp [sys_type],SYS_DPMI         ; Running under DPMI (possibly Win95)?
        jne short @@apm                 ; No

        cmp [byte dos_version],7        ; Windows MS-DOS 7.00+ (Win95)?
        jb short @@apm                  ; No.

        or [mode_flags],MODE_WFORCE     ; Set WEAK FORCE in config flags.
        and [mode_flags],not MODE_SFORCE
        and [mode_flags],not MODE_NOFORCE

@@apm:  test [mode_flags],MODE_APM      ; APM usage requested?
        jz short @@cpu                  ; No.

        and [mode_flags],not MODE_APM   ; Assume APM is disabled/disengaged.

        cmp [apm_state],OFF             ; APM disabled/disengaged?
        je short @@cpu                  ; Yes, no APM.

        mov ax,5304h                    ;
        xor bx,bx                       ;
        int 15h                         ; Disconnect Real-mode APM interface.
        jc short @@cpu                  ; Call failed, no APM.

        mov ax,5301h                    ;
        xor bx,bx                       ;
        int 15h                         ; Connect Real-mode APM interface.
        jc short @@cpu                  ; Call failed, no APM.

        mov ax,530eh                    ;
        xor bx,bx                       ;
        mov cx,[apm_version]            ;
        xchg cl,ch                      ; Connect appropriate version of APM
        int 15h                         ; BIOS (needed for V1.00+).
        jc short @@cpu                  ; Call failed, no APM.

        mov ax,5305h                    ;
        int 15h                         ; Call APM FN to put the CPU idle.
        jc short @@cpu                  ; Call failed, no APM.
        
        or [mode_flags],MODE_APM        ; It's safe to use APM...

@@cpu:  test [mode_flags],MODE_OPTIMIZE ; CPU optimization requested?
        jz short @@done                 ; No.

        lea si,[msg_optimize]           ;
        call con_writeln                ; Print optimization message.

        lea si,[msg_cpudet]             ;
        call con_writef                 ; Print message for CPU detection.

        call cpu_optimize               ; Optimize CPU.
        lea si,[msg_optnomod]           ; Assume optimization failed.
        jc short @@prnt                 ; Go..

        call cpu_getname                ;
        lea si,[cpu_name]               ; Get full name of CPU.

@@prnt: call con_writef                 ; Print results of optimization.

        mov al,'.'                      ;
        call con_writech                ; Period.

        mov al,CR                       ;
        call con_writech                ;
        mov al,LF                       ;
        call con_writech                ; New line.

@@done: ret
Endp

Proc    check_system
	call test_vcpi                  ; Running under VCPI server?
	jne short @@dpmi                ; No.

        mov [sys_type],SYS_VCPI         ; Mark that running under VCPI.
        jmp short @@done

@@dpmi: call test_dpmi                  ; Running under DPMI host?
	jne short @@v86                 ; No.

        mov [sys_type],SYS_DPMI         ; Mark that running under DPMI.
        jmp short @@done

@@v86:  call test_v86                   ; Running in V86 mode without PM host?
	lea si,[err_v86]                ; Yes, can't execute HLT instruction,
	je error_exit                   ; fail program.
@@done: ret
Endp

Proc    hook_ints
	push ds
	mov ax,fs
	mov ds,ax			; DS = CODE_R
        ;-  -  -  -  -  -  -  -  -  -  -;
	ASSUME	DS:CODE_R
        mov eax,[gs:(10h * 4)]          ;
        mov [old_int_10h],eax     ; Get and save original int 10h.

        mov eax,[gs:(15h * 4)]          ;
        mov [old_int_15h],eax     ; Get and save original int 15h.

        mov eax,[gs:(14h * 4)]          ;
        mov [old_int_14h],eax     ; Get and save original int 14h.

        mov eax,[gs:(16h * 4)]          ;
	mov [old_int_16h],eax     ; Get and save original int 16h.

	mov eax,[gs:(21h * 4)]          ;
	mov [old_int_21h],eax     ; Get and save original int 21h.

        mov eax,[gs:(2fh * 4)]          ;
        mov [old_int_2fh],eax     ; Get and save original int 2fh.
		
        mov eax,[gs:(33h * 4)]          ;
        mov [old_int_33h],eax     ; Get and save original int 33h.
        ;-  -  -  -  -  -  -  -  -  -  -;

        ;-  -  -  -  -  -  -  -  -  -  -;
        mov ax,fs                       ;
        shl eax,16                      ; High WORD of EAX = CODE_R.

        mov bl,10h                      ; BL = int number of video handler.
        mov ax,offset int_10h_handler   ; EAX = new handler for int 10h.
        call tsr_hookint                ; Hook int 10h.

        mov bl,15h                      ; BL = int number of AT services.
        mov ax,offset int_15h_handler   ; EAX = new handler for int 15h.
        call tsr_hookint                ; Hook int 15h.

        mov bl,14h                      ; BL = int number of BIOS COM handler.
        mov ax,offset int_14h_handler   ; EAX = new handler for int 14h.
        call tsr_hookint                ; Hook int 14h.

        mov bl,16h                      ; BL = int number of keyboard handler.
        mov ax,offset int_16h_handler   ; EAX = new handler for int 16h.
        call tsr_hookint                ; Hook int 16h.

        mov bl,21h                      ; BL = int number of DOS FNs handler.
        mov ax,offset int_21h_handler   ; EAX = new handler for int 21h.
        call tsr_hookint                ; Hook int 21h.

        mov bl,2fh                      ; BL = int # of DOS Multiplex handler.
        mov ax,offset int_2fh_handler   ; EAX = new handler for int 2fh.
        call tsr_hookint                ; Hook int 2fh.
	ASSUME	DS:DATA16
	pop ds
		
        test [mode_flags],MODE_MOUSE    ; Register mouse handler?
        jz short @@done

        ;-  -  -  -  -  -  -  -  -  -  -;
	ASSUME	DS:CODE_R
        mov ax,fs
	mov ds,ax                       ; DS = CODE_R
        mov es,ax
        mov dx,offset mouse_handler
        mov cx,7Fh			; Try to catch all mouse events
        mov ax,0014h
        int 33h

        mov ax,fs                 	;
        shl eax,16                      ; High WORD of EAX = CODE_R		
        mov bl,33h                      ; BL = int # of Mouse handler.
        mov ax,offset int_33h_handler   ; EAX = new handler for int 33h.
        call tsr_hookint                ; Hook int 33h.		

	ASSUME	DS:DATA16
	pop ds
        ;-  -  -  -  -  -  -  -  -  -  -;
@@done:		
        ret
Endp

Proc    hook_irqs
        ;-  -  -  -  -  -  -  -  -  -  -;
@@vcpi: cmp [sys_type],SYS_VCPI         ; Running under VCPI?
        jne short @@dpmi                ; No.

        call vcpi_getpic                ; Get VCPI IRQ mappings.
        jmp short @@hook

@@dpmi: cmp [sys_type],SYS_DPMI         ; Running under DPMI?
        jne short @@raw                 ; No.

        call irq_getpic                 ; Assume RM IRQ settings (should work).
        jmp short @@hook

@@raw:  call irq_getpic                 ; Get IRQ mappings.
        ;-  -  -  -  -  -  -  -  -  -  -;

        ;-  -  -  -  -  -  -  -  -  -  -;
@@hook: movzx ebx,bl                    ; EBX = base int # for master PIC.
        mov cx,8                        ; CX = number of IRQ in master PIC.
        xor di,di                       ; DI = index to irq arrays.

	push ds
        mov ax,fs
        mov ds,ax
@@mstr: 
	mov eax,[gs:(ebx * 4)]               ;
        mov [old_masterirqs + di],eax  ; Get and save old IRQ handler.
        mov eax,[new_masterirqs + di]  	; Get new handler of IRQ.
	
        call tsr_hookint                ; Hook IRQ.
        inc bl                          ; BL = next interrupt # for IRQ.
        add di,4                        ; DI = next IRQ number.
        loop @@mstr
        ;-  -  -  -  -  -  -  -  -  -  -;
	pop ds
@@done: ret
Endp

Proc    detect_cpu
        lea si,[msg_cpudet]             ;
        call con_writef                 ; Print message for CPU detection.

        call cpu_getname                ; Get full name of CPU.
        lea si,[cpu_name]               ;
        call con_writef                 ; Print it.

        mov al,'.'                      ;
        call con_writech                ; Period.

        lea si,[msg_nl]                 ;
        call con_writef                 ; New Line.
        ret
Endp

Proc    detect_os
        lea si,[msg_osdet]              ;
        call con_writef                 ; Print message for OS detection.

        lea si,[msg_msdos]              ;
        call con_writef                 ; Print "MS-DOS V"

        movzx eax,[byte dos_version]    ;
        call con_writedec               ; Print major version number.

        mov al,'.'                      ;
        call con_writech                ; Put a decimal point for version.

        movzx eax,[byte dos_version+1]  ;
        call con_writedec               ; Print minor version number.

        lea si,[msg_msdos_std]          ; Assume MS-DOS V6.22-
        cmp [byte dos_version],7        ; Is it V7.00+ (for Win95/98)?
        jb short @@osok                 ; No.

        lea si,[msg_msdos_win]          ; It's V7.00+ (for Win95/98).

@@osok: call con_writeln                ; Print DOS type.
        ret
Endp

Proc    detect_apm
        lea si,[msg_apmdet]             ;
        call con_writef                 ; Print message for APM detection.

        stc                             ;
        mov ax,5300h                    ;
        mov bx,0                        ;
        int 15h                         ; APM V1.00+: installation check.
        jnc short @@cont                ; Yes, it's installed, continue.
        
        lea si,[msg_na]                 ;
        jmp short @@done                ; Finish.

@@cont: xchg al,ah                      ; AL = major version, AH = minor.
        mov [apm_version],ax            ; Save APM version.

        lea si,[msg_apm]                ;
        call con_writef                 ; Print "APM V"

        movzx eax,[byte apm_version]    ;
        call con_writedec               ; Print major version number.

        mov al,'.'                      ;
        call con_writech                ; Put a decimal point for version.

        movzx eax,[byte apm_version+1]  ;
        call con_writedec               ; Print minor version number.

        test cx,18h                     ; Is the APM disabled/disengaged?
        jnz short @@off                 ; Yes.

@@on:   mov [apm_state],ON              ; Mark that APM is unusable.
        lea si,[msg_apm_on]             ; It's enabled.
        jmp short @@done                ; Finish up.

@@off:  mov [apm_state],OFF             ; Mark that APM is unusable.
        lea si,[msg_apm_off]            ; It's disabled.

@@done: call con_writeln                ; Print APM state.
        ret
Endp

Proc    detect_pm
        lea si,[msg_pmdet]              ;
        call con_writef                 ; Print message for PM detection.

        lea si,[msg_raw]                ; Assume raw DOS.
        test [sys_type],SYS_RAW         ; Running under raw DOS?
        jnz short @@pmok                ; Yes, done.

        lea si,[msg_vcpi]               ; Assume VCPI.
        test [sys_type],SYS_VCPI        ; Running under VCPI?
        jnz short @@pmok                ; Yes, done.

        lea si,[msg_dpmi]               ; Now it's DPMI for sure.
@@pmok: call con_writeln                ; Print PM system.
        ret
Endp

Proc    detect_mouse
        push es

        lea si,[msg_mouse]              ;
        call con_writef                 ; Print message for mouse detection.

        xor ax,ax
        mov es,ax
        mov ebx, [es:(33h * 4)]
        test ebx, ebx
        jz short @@no_mouse

        ror ebx,	16
        mov es,bx
        rol ebx,16
        mov al,[byte ptr es:bx]
        cmp al, 0CFh			; Check for IRET in the current 33h handler
        jz short @@no_mouse

        xor ax, ax
        int 33h
        cmp ax,0FFFFh
        jne short @@no_mouse

        lea si,[msg_yes]
        or [mode_flags],MODE_MOUSE
        jmp short @@done
		
@@no_mouse:
        lea si,[msg_no]

@@done: 
        call con_writeln
        pop es
        ret
Endp

Proc    info_detect
        lea si,[msg_detect]             ;
        call con_writeln                ; Print detection message.

        call detect_cpu                 ; Print CPU detection results.
        call detect_apm                 ; Print APM detection results.
        call detect_os                  ; Print OS detection results.
        call detect_pm                  ; Print PM host detection results.
        call detect_mouse				; Print mouse detection results.
        ret
Endp

Proc    install_kernel
	lea si,[msg_inst]               ;
	call con_writeln                ; Print success message.
	mov di,[mode_flags]		;
        mov cx,offset RESIDENT_END
	add cx, 0fh                     ;
	shr cx, 4                       ; resident part in paragraphs
	mov bx,[psp_seg]                ; add PSP
	mov ax,cs                       ;    ,,
	sub ax,bx                       ;    ,,
	add cx,ax			;    ,,
	mov dx,KERNEL_ID                ;    
	mov bx,[psp_seg]                ;
	mov ax,[env_seg]                ;
	call tsr_install                ; Make kernel TSR.
Endp

Proc    main
	call init                       ; Do general startup work.
	call read_cmdln                 ; Read cmd-ln params (maybe uninstall).

	mov dx,KERNEL_ID                ;
	call tsr_instcheck              ; Is kernel installed already?

	lea si,[err_inst]               ;
	cmp ax,1                        ; AX == 1 if installed.
	je error_exit                   ; Yes, quit now (don't install twice).

        call check_system               ; Check for VCPI, DPMI, etc.
        call info_detect                ; Detect CPU, system, APM, etc.
        call init_modes                 ; Init FORCE, Test and other modes.
        
        call hook_ints                  ; Hook needed interrupts.
        call hook_irqs                  ; Hook needed IRQs.

        call cpu_powersave              ; Enable power saving features.
        call install_kernel             ; Make kernel TSR.
Endp

PROC	strcmp
;sub_31		proc	near
	push	ax cx si di
	mov	cx,0FFh

locloop_104:
	mov	al,[si]
	cmp	al,[es:di]
	jne	short loc_105		
	test	al,al
	jz	short loc_105		
	inc	si
	inc	di
	loop	locloop_104		

loc_105:
	pop	di si cx ax
	retn
ENDP

PROC	strcpy
;sub_32		proc	near
	push	ax cx si di
	mov	cx,0FFh

locloop_106:
	mov	al,[si]
	mov	[es:di],al
	inc	si
	inc	di
	test	al,al
	loopnz	locloop_106		

	pop	di si cx ax
	retn
ENDP

PROC	LOCAL_WRITESTR
	push	ax cx si
	mov	cx,0FFh

locloop_107:
	mov	al,[si]
	cmp	al,0
	je	short loc_108		
	call	LOCAL_WRITECH
	inc	si
	loop	locloop_107		

loc_108:
	pop	si cx ax
	retn
ENDP

PROC	LOCAL_WRITELN
	push	ax
	call	LOCAL_WRITESTR
	mov	al,CR
	call	LOCAL_WRITECH
	mov	al,LF
	call	LOCAL_WRITECH
	pop	ax
	retn
ENDP

PROC	LOCAL_WRITECH         		
	push	bx cx dx ds ax
	mov	bx,dx
	mov	cx,1
	mov	ax,ss
	mov	ds,ax
	mov	dx,sp
	mov	ah,40h
	int	21h			; DOS Services  ah=function 40h
					;  write file  bx=file handle
					;   cx=bytes from ds:dx buffer
	pop	ax ds dx cx bx
	retn
ENDP

PROC	LOCAL_WRITEDEC
	push	eax ebx cx edx si
	mov	ebx, 10
	mov	si,dx
	xor	cx,cx			
loc_109:
	xor	edx,edx			
	div	ebx			; ax,dx rem=dx:ax/reg
	push	dx
	inc	cl
	test	eax,eax
	jnz	loc_109			
	mov	dx,si

locloop_110:
	pop	bx
	mov	al,[hex_table+bx]
	call	LOCAL_WRITECH
	loop	locloop_110		

	pop	si edx cx ebx eax
	retn
ENDP

PROC	CON_WRITEF
	push	dx
	mov	dx,1
	call	LOCAL_WRITESTR
	pop	dx
	retn
ENDP

PROC	CON_WRITELN
	push	dx
	mov	dx,1
	call	LOCAL_WRITELN
	pop	dx
	retn
ENDP

PROC	CON_WRITECH
	push	dx
	mov	dx,1
	call	LOCAL_WRITECH
	pop	dx
	retn
ENDP

PROC	CON_WRITEDEC
	push	dx
	mov	dx,1
	call	LOCAL_WRITEDEC
	pop	dx
	retn
ENDP

PROC	TOLOWER
	cmp	al,41h			; 'A'
	jb	short loc_ret_111	
	cmp	al,5Ah			; 'Z'
	ja	short loc_ret_111	
	add	al,20h			; ' '

loc_ret_111:
	retn
ENDP

PROC	isspace
	cmp	al,20h			; ' '
	je	short loc_ret_112	
	cmp	al,9
	je	short loc_ret_112	

loc_ret_112:
		retn
ENDP

PROC	LOCAL_SWITCH
	jmp	short loc_113
	w1	dw	0
	w2	dw 	0
loc_113:
	push	dx si di
	mov	[word ptr w1],0
	mov	[word ptr w2],0
	mov	dh,al
	xor	ah,ah			
	xor	bl,bl			
	mov	dl,1
	movzx	cx,[byte ptr es:di]	
	jcxz	short loc_122		

locloop_114:
	inc	di
	mov	al,[es:di]
	call	isspace
	jz	short loc_115		
	cmp	al,'-'			
	je	short loc_117		
	jmp	short loc_116
loc_115:
	cmp	dl,2
	je	short loc_121		
	mov	dl,1
	jmp	short loc_120
loc_116:
	inc	ah
	cmp	dl,1
	mov	dl,3
	jz	short loc_118		
	jmp	short loc_120
loc_117:
	cmp	dl,2
	je	short loc_121		
	mov	dl,2
loc_118:
	cmp	dh,bl
	jne	short loc_119		
	mov	[word ptr w1],si
	mov	[byte ptr w2],ah
loc_119:
	inc	bl
	mov	ah,1
	mov	si,di
loc_120:
	loop	locloop_114		

	cmp	dl,2
	je	short loc_121		
	cmp	[word ptr w2],0
	jne	short loc_122		
	mov	[word ptr w1],si
	mov	[byte ptr w2],ah
	jmp	short loc_122
loc_121:
	stc				
	jmp	short loc_123
loc_122:
	mov	ah,bl
	mov	bx,[word ptr w1]
	mov	cx,[word ptr w2]
	mov	al,dh
	clc				
loc_123:
	pop	di si dx
	retn
ENDP

PROC	GET_SWITCH
	push	ax bx
	mov	al,1
	call	LOCAL_SWITCH
	mov	cl,ah
	mov	ch,0
	pop	bx ax
	retn
ENDP

PROC	COMPARE_SWITCH
	push	ax bx cx si
	call	LOCAL_SWITCH
	jc	short loc_126		

locloop_124:
	mov	al,[si]
	call	TOLOWER
	mov	ah,al
	mov	al,[es:bx]
	call	TOLOWER
	cmp	al,ah
	jne	short loc_125		
	inc	si
	inc	bx
	loop	locloop_124		

	cmp	[byte ptr si],0
loc_125:
	clc				
loc_126:
	pop	si cx bx ax
	retn
ENDP

PROC	PARSE_CMDLN
	pusha				
	call	GET_SWITCH
	jc	short loc_131		
	jcxz	short loc_130		
	mov	al,1
	mov	bp,si

locloop_127:
	mov	bx,bp
	xor	dx,dx			
loc_128:
	lea	si,[(par_item bx).switch]	
	call	COMPARE_SWITCH
	jc	short loc_131		
	jnz	short loc_129		
	inc	dx
	call	[word ptr (par_item bx).proc_offset]	
loc_129:
	add	bx, size par_item
	cmp	[byte ptr bx],0
	jne	loc_128			
	test	dx,dx
	jz	short loc_131		
	inc	al
	loop	locloop_127		

loc_130:
	clc				
	jmp	short loc_132
loc_131:
	stc				
loc_132:
	popa				
	retn
ENDP

PROC	TEST_CPU
;	cpu types
;	0	8086	
;	2       286 
;	3       386
;	4       486 
;	cpuid   pentium or better
	pushf				
	push	bx cx ax 
	pushf				
	pop	ax
	mov	cx,ax
	and	ax,0FFFh
	push	ax
	popf				
	pushf				
	pop	ax
	and	ax,0F000h
	cmp	ax,0F000h                                                               
	mov	al,0															
	jz	short loc_133		                                  
	or	cx,0F000h                                                               
	push	cx                                                                      
	popf				
	pushf				
	pop	ax
	and	ax,0F000h
	mov	al,2			
	jz	short loc_133		
	mov	bx,sp
	and	sp,0FFFCh
	pushfd				
	pop	eax
	mov	ecx,eax
	xor	eax,40000h
	push	eax
	popfd				
	pushfd				
	pop	eax
	mov	sp,bx
	xor	eax,ecx
	mov	al,3
	jz	short loc_133		
	and	sp,0FFFCh
	push	ecx
	popfd				
	mov	sp,bx
	mov	eax,ecx
	xor	eax,200000h
	push	eax
	popfd				
	pushfd				
	pop	eax
	xor	eax,ecx
	mov	al,4
	jz	short loc_133		
	mov	eax,1
	cpuid				
	and	ax,0F00h
	shr	ax,8			
loc_133:
	mov	bl,al
	pop	ax
	mov	al,bl
	pop	cx bx
	popf				
	retn
ENDP

PROC	TEST_FPU
	push	bx ax
	fninit				; Initialize math uP
	mov	[fpu_check],5A5Ah
	fnstsw	[fpu_check]			; Store status word
	mov	bl,0
	cmp	[fpu_check],0
	jne	short loc_135		
	fnstcw	[fpu_check]			; Store control word
	mov	ax,[fpu_check]
	and	ax,103Fh
	cmp	ax,3Fh
	mov	bl,0
	jnz	short loc_135		
	call	test_cpu
	mov	bl,al
	cmp	al,3
	jne	short loc_135		
	fld1				; Push +1.0 to stack
	fldz				; Push +0.0 to stack
	fdivp	st(1),st		; st(#)=st(#)/st, pop
	fld	st			; Push onto stack
	fchs				; Change sign in st
	fcompp				; Compare st & pop 2
	fstsw	[fpu_check]			; Store status word
	mov	ax,[fpu_check]
	mov	bl,2
	sahf				; Store ah into flags
	jz	short loc_135		
	mov	bl,3
loc_135:
	pop	ax
	mov	al,bl
	pop	bx
	retn
ENDP

EMS_BIOS	= 019Ch ;67h * 4	;INTR 67H LIM EMS

PROC	TEST_VCPI
	push	ax bx es
	xor	ax,ax			
	mov	es,ax
	cmp	[dword ptr es:EMS_BIOS],0
	sete	ah			
	jz	short loc_136		
	mov	ax,0DE00h
	int	67h			; EMS Memory        ah=func DEh
					;  VCPI active  ah=1, bx=version
loc_136:
	test	ah,ah
	pop	es bx ax
	retn
ENDP

PROC	TEST_DPMI
	pusha				
	push	es
	mov	ax,1687h
	int	2Fh			
	test	ax,ax
	jnz	short loc_137		
	cmp	bl,1
loc_137:
	pop	es
	popa				
	retn
ENDP

PROC	TEST_V86
	push	ax
	smsw	ax			; Store machine stat
	and	al,1
	cmp	al,1
	pop	ax
	retn
ENDP

PROC	IRQ_GETPIC
	mov	bx,7008h
	retn
ENDP

PROC	WIN386_V86_CALLBACK_INIT
	pushad				
	push	ds es
	mov	ax,1605h
	xor	bx,bx			
	mov	es,bx
	xor	si,si			
	mov	ds,si
	xor	dx,dx			
	xor	cx,cx			
	mov	di,30Bh
	int	2Fh			; Windows init broadcast
	test	cx,cx
	jnz	short loc_138		
	mov	[ word ptr v86_callback],si
	mov	[ word ptr v86_callback+2],ds
	cmp	[dword ptr v86_callback],0
	je	short loc_138		
	cli				
	xor	ax,ax			
	call	[dword ptr v86_callback]
	jc	short loc_138		
	clc				
	jmp	short loc_139
loc_138:
	mov	ax,1606h
	xor	dx,dx			
	int	2Fh			; Windows exit broadcast
	stc				
loc_139:
	pop	es ds
	popad				
	retn
ENDP

PROC	WIN386_V86_CALLBACK_EXIT
	pushad				
	push	ds es
	cmp	[dword ptr v86_callback],0
	je	short loc_140		
	cli				
	mov	ax,1
	call	[dword ptr v86_callback]
	mov	ax,1606h
	xor	dx,dx			
	int	2Fh			; Windows exit broadcast
loc_140:
	pop	es ds
	popad				
	retn
ENDP

PROC	VCPI_GETPIC
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
ENDP

PROC	clear_if_zero
	test	ah,ah
	clc				
	jz	short loc_ret_141	
	stc				

loc_ret_141:
	retn
ENDP

PROC	is_486sx					
;sub_57		proc	near
	push	eax ebx ecx
	mov	bx,sp
	and	sp,0FFFCh
	pushfd				
	pop	eax
	mov	ecx,eax
	xor	eax,40000h
	push	eax
	popfd				
	pushfd				
	pop	eax
	mov	sp,bx
	cmp	eax,ecx
	je	short loc_142		
	and	sp,0FFFCh
	push	ecx
	popfd				
	mov	sp,bx
	xor	al,al			
	jmp	short loc_143
loc_142:
	xor	al,al			
	inc	al
loc_143:
	pop	ecx ebx eax 
	retn
ENDP

PROC	is_cpuid_available
;sub_58		proc	near
	push	eax
	push	ebx
	pushfd				
	pop	eax
	mov	ebx,eax
	xor	eax,200000h
	push	eax
	popfd				
	pushfd				
	pop	eax
	cmp	eax,ebx
	je	short loc_144		
	xor	al,al			
	jmp	short loc_145
loc_144:
	xor	al,al			
	inc	al
loc_145:
	pop	ebx
	pop	eax
	retn
ENDP

PROC	get_basic_cpuid
;sub_59		proc	near
	push	ebx ecx edx
	xor	eax,eax			
	cpuid				
	mov	[highest_basic_cpuid],eax
	mov	[dword cpuid_str],ebx
	mov	[dword cpuid_str+4],edx
	mov	[dword cpuid_str+8],ecx
	pop	edx ecx ebx
	retn
ENDP

PROC	get_basic_cpu_info
;sub_60		proc	near
	pushad				
	mov	eax,1
	cpuid				
	mov	ebx,eax
	and	al,0Fh
	mov	[cpu_stepping],al 	
	mov	al,bl
	shr	al,4			
	mov	[cpu_model],al 	
	mov	ah,bh
	and	ah,0Fh   	
	mov	[cpu_family],ah     
	mov	ah,bh
	shr	ah,4			                                       
	mov	[cpu_type],ah 	                                               
	mov	eax,ebx
	shr	eax,16
	and	al, 0fh
	shl	al,4
	add 	[cpu_model],al		;add extended model
	mov	eax,ebx
	shr	eax,20
	add	[cpu_family],al		;add extended family
	mov	[cpu_features],edx   	
	popad				
	retn
ENDP

PROC  	get_extended_cpuid
;sub_61		proc	near
	push	ebx ecx edx
	mov	eax,80000000h
	cpuid				
	mov	[highest_ext_cpuid],eax
	pop	edx ecx ebx
	retn
ENDP

PROC 	get_cpu_brandstring
;sub_62		proc	near
	pushad				
	mov	eax,80000002h
	cpuid				
	mov	[dword cpu_name +0  ],eax
	mov	[dword cpu_name +4  ],ebx
	mov	[dword cpu_name +8  ],ecx
	mov	[dword cpu_name +0ch],edx
	mov	eax,80000003h
	cpuid				
	mov	[dword cpu_name +10h],eax
	mov	[dword cpu_name +14h],ebx
	mov	[dword cpu_name +18h],ecx
	mov	[dword cpu_name +1ch],edx
	mov	eax,80000004h
	cpuid				
	mov	[dword cpu_name +20h],eax
	mov	[dword cpu_name +24h],ebx
	mov	[dword cpu_name +28h],ecx
	mov	[dword cpu_name +2ch],edx
	mov	[dword cpu_name +30h],0
	popad				
	retn
ENDP

PROC	get_cpus
;sub_63		proc	near
	push	eax
	push	ecx
	call	test_cpu                      
	cmp	al,3                                              
	jb	short loc_145a	                                  
	call	is_cpuid_available	
	jz	short loc_145a	                        
	call	get_cpu_intel_1		
	jz	short loc_145a	                        
	call	get_cpu_amd_3		
	jz	short loc_145a	                        
	call	initial_cpu_check	
	jz	short loc_145a	                        
	call	get_cpu_Centaur_1	
	jz	short loc_145a	                        
	call	get_cpu_nexgen_1	
	jz	short loc_145a	                        
	call	get_cpu_intel_6		
	jz	short loc_145a	
	xor	al,al
	jmp	short loc_145b	
loc_145a:
	xor	al,al
	inc	al
loc_145b:
	pop	ecx
	pop	eax
	retn
ENDP

PROC	get_cpu_early_model
;sub_64		proc	near
	pushad				
	call	is_486sx
	jz	short loc_146		                     	
	mov	si,offset cpu_386_str	                   	
	call	test_fpu                                                   	
	cmp	al,0                                                       	
	je	short loc_147		
	mov	si,offset cpu_386fpu_str
	jmp	short loc_147
loc_146:
	mov	si,offset cpu_486sx_str
	call	test_fpu
	cmp	al,0
	je	short loc_147		
	mov	si,offset cpu_486dx_str
	jmp	short loc_147
loc_147:
	mov	di,offset cpu_name
	call	strcpy
	popad				
	retn
ENDP
            
PROC	cyrix_io_port_1
;sub_65		proc	near
	push	ax
	pushf				
	cli				
	out	22h,al			; port 22h, C&T NEAT,Index Reg
	in	al,23h			; port 23h, C&T NEAT, Data Reg
	mov	bl,al
	sti				
	popf				
	pop	ax
	retn
ENDP

PROC    cyrix_io_port_2
;sub_66		proc	near
	push	ax
	pushf				
	cli				
	out	22h,al			; port 22h, C&T NEAT,Index Reg
	mov	al,bl
	out	23h,al			; port 23h, C&T NEAT, Data Reg
	sti				
	popf				
	pop	ax
	retn
ENDP

PROC	get_cyrix_1
;sub_67		proc	near
	push	ax bx dx
	mov	dl,bl
	call	cyrix_io_port_1
	mov	dh,bl
	and	bl,dl
	cmp	bl,dl
	je	short loc_148		
	mov	bl,dh
	or	bl,dl
	call	cyrix_io_port_2
	push	ax
	mov	al,0C0h
	call	cyrix_io_port_1
	pop	ax
	call	cyrix_io_port_1
	cmp	bl,dh
	je	short loc_149		
loc_148:
	clc				
	jmp	short loc_150
loc_149:
	stc				
loc_150:
	pop	dx bx ax 
	retn
ENDP

PROC	get_cyrix_2
;sub_68		proc	near
	push	ax bx dx 
	mov	dl,bl
	call	cyrix_io_port_1
	mov	dh,bl
	and	bl,dl
	jz	short loc_151		
	mov	bl,dh
	not	dl
	and	bl,dl
	call	cyrix_io_port_2
	push	ax
	mov	al,0C0h
	call	cyrix_io_port_1
	pop	ax
	call	cyrix_io_port_1
	not	dl
	and	bl,dl
	jnz	short loc_152		
loc_151:
	clc				
	jmp	short loc_153
loc_152:
	stc				
loc_153:
	pop	dx bx ax 
	retn
ENDP

PROC	get_cyrix_3
;sub_69		proc	near
	push	ax bx dx
	mov	al,0C2h
	call	cyrix_io_port_1
	mov	dh,bl
	mov	al,0C2h
	xor	bl,4
	call	cyrix_io_port_2
	mov	al,0C0h
	call	cyrix_io_port_1
	mov	al,0C2h
	call	cyrix_io_port_1
	mov	dl,bl
	mov	al,0C2h
	mov	bl,dh
	call	cyrix_io_port_2
	cmp	dl,dh
	je	short loc_154		
	xor	al,al			
	jmp	short loc_155
loc_154:
	xor	al,al			
	inc	al
loc_155:
	pop	dx bx ax
	retn
ENDP

PROC	get_cyrix_4
;sub_70		proc	near
	push	ax bx dx
	mov	al,0C3h
	call	cyrix_io_port_1
	mov	dh,bl
	mov	al,0C3h
	xor	bl,80h
	call	cyrix_io_port_2
	mov	al,0C0h
	call	cyrix_io_port_1
	mov	al,0C3h
	call	cyrix_io_port_1
	mov	dl,bl
	mov	al,0C3h
	mov	bl,dh
	call	cyrix_io_port_2
	cmp	dl,dh
	je	short loc_156		
	xor	al,al			
	jmp	short loc_157
loc_156:
	xor	al,al			
	inc	al
loc_157:
	pop	dx bx ax
	retn
ENDP

PROC	get_cpu_cyrix
;sub_71		proc	near
	push	ax bx dx
	xor	dx,dx			
	call	get_cyrix_3
	sete	dl			
	call	get_cyrix_4
	sete	dh			
	cmp	dh,1
	jne	short loc_158		
	mov	al,0FEh
	call	cyrix_io_port_1
	mov	[cyrix_1],bl
	mov	al,0FFh
	call	cyrix_io_port_1
	mov	[cyrix_2],bl
	jmp	short loc_160
loc_158:
	cmp	dl,1
	jne	short loc_159		
	mov	[cyrix_1],0FEh
	jmp	short loc_160
loc_159:
	mov	[cyrix_1],0FDh
	mov	[cyrix_2],1
loc_160:
	pop	dx bx ax
	retn
ENDP

PROC	get_cpu_cyrix_1
;sub_73		proc	near
	pusha				
	call	get_basic_cpu_info
	mov	al,[cpu_family]
	mov	bl,[cpu_model]
	cmp	al,4
	je	short loc_161		
	cmp	al,5
	je	short loc_163		
	cmp	al,6
	je	short loc_162		
	jmp	short loc_164
loc_161:
	mov	[cyrix_0],6	
	mov	si,offset cpu_cyrix_28_str
	cmp	bl,4
	je	short loc_165		
	mov	[cyrix_0],2	
	mov	si,offset cpu_cyrix_24_str
	cmp	bl,9
	je	short loc_165		
	jnz	short loc_164		
loc_162:
	mov	[cyrix_0],5	
	mov	si,offset cpu_cyrix_27_str
	cmp	bl,0
	je	short loc_165		
	jnz	short loc_164		
loc_163:
	mov	[cyrix_0],7	
	mov	si,offset cpu_cyrix_29_str
	cmp	bl,4
	je	short loc_165		
	cmp	bl,2
	jne	short loc_164		
	mov	[cyrix_0],3	
	mov	si,offset cpu_cyrix_25_str
	cmp	[dword ptr cpu_features],1
	je	short loc_165		
	mov	[cyrix_0],4	
	mov	si,offset cpu_cyrix_26_str
	cmp	[dword ptr cpu_features],105h
	je	short loc_165		
loc_164:
	mov	[cyrix_0],0FFh	
	mov	si,offset cpu_cyrix_02_str
	mov	di,offset cpu_name
	call	strcpy
	stc				
	jmp	short loc_166
loc_165:
	mov	di,offset cpu_name
	call	strcpy
	clc				
loc_166:
	popa				
	retn
ENDP

PROC	get_cpu_cyrix_2
;sub_74		proc	near
	pusha				
	call	get_cpu_cyrix
	mov	al,[cyrix_1]
	mov	[byte cyrix_0],1	
	mov	si,offset cpu_cyrix_03_str
	cmp	al,0
	je	loc_169			
	mov	si,offset cpu_cyrix_04_str
	cmp	al,1
	je	loc_169			
	mov	si,offset cpu_cyrix_05_str
	cmp	al,2
	je	loc_169			
	mov	si,offset cpu_cyrix_06_str
	cmp	al,3
	je	loc_169			
	mov	si,offset cpu_cyrix_07_str
	cmp	al,4
	je	loc_169			
	mov	si,offset cpu_cyrix_08_str
	cmp	al,5
	je	loc_169			
	mov	si,offset cpu_cyrix_09_str
	cmp	al,6
	je	loc_169			
	mov	si,offset cpu_cyrix_10_str
	cmp	al,7
	je	loc_169			
	mov	si,offset cpu_cyrix_11_str
	cmp	al,8
	je	loc_169			
	mov	si,offset cpu_cyrix_12_str
	cmp	al,9
	je	loc_169			
	mov	si,offset cpu_cyrix_13_str
	cmp	al,0Ah
	je	loc_169			
	mov	si,offset cpu_cyrix_14_str
	cmp	al,0Bh
	je	loc_169			
	mov	si,offset cpu_cyrix_15_str
	cmp	al,10h
	je	loc_169			
	mov	si,offset cpu_cyrix_16_str
	cmp	al,11h
	je	loc_169			
	mov	si,offset cpu_cyrix_17_str
	cmp	al,12h
	je	loc_169			
	mov	si,offset cpu_cyrix_18_str
	cmp	al,13h
	je	loc_169			
	mov	si,offset cpu_cyrix_19_str
	cmp	al,1Ah
	je	loc_169			
	mov	si,offset cpu_cyrix_20_str
	cmp	al,1Bh
	je	loc_169			
	mov	si,offset cpu_cyrix_21_str
	cmp	al,0FDh
	je	loc_169			
	mov	si,offset cpu_cyrix_22_str
	cmp	al,0FEh
	je	short loc_169		
	mov	si,offset cpu_cyrix_23_str
	cmp	al,1Fh
	je	short loc_169		
	mov	[byte cyrix_0],2	
	mov	si,offset cpu_cyrix_24_str
	mov	dl,al
	sub	dl,28h			
	cmp	dl,7
	jbe	short loc_169		 
	mov	dl,al
	sub	dl,30h			
	cmp	dl,7
	jbe	short loc_167		 
	mov	[byte cyrix_0],5	
	mov	si,offset cpu_cyrix_27_str
	mov	dl,al
	sub	dl,50h			
	cmp	dl,0Fh
	jbe	short loc_169		 
	mov	dl,al
	sub	dl,40h			
	cmp	dl,7
	jbe	short loc_168		 
	mov	[byte cyrix_0],0FFh	
	mov	si,offset cpu_cyrix_02_str
	jmp	short loc_169
loc_167:
	mov	[byte cyrix_0],3	
	mov	si,offset cpu_cyrix_25_str
	cmp	[byte cyrix_2],21h	
	jbe	short loc_169		 
	mov	[byte cyrix_0],4	
	mov	si,offset cpu_cyrix_26_str
	jmp	short loc_169
loc_168:
	mov	[byte cyrix_0],6	
	mov	si,offset cpu_cyrix_28_str
	mov	al,[cyrix_2]
	and	al,0F0h
	cmp	al,30h			
	jne	short loc_169		
	mov	[byte cyrix_0],7	
	mov	si, offset cpu_cyrix_29_str	
	jmp	short loc_169
loc_169:
	mov	di,offset cpu_name
	call	strcpy
	popa				
	retn
ENDP

PROC	initial_cpu_check
;sub_75		proc	near
	pusha				
	call	is_cpuid_available
	jnz	short loc_170		
	call	get_basic_cpuid
	mov	si,offset cpuid_str
	mov	di,offset cpu_cyrix_01_str
	call	strcmp
	jz	short loc_171		
	jnz	short loc_172		
loc_170:
	call	is_486sx
	jnz	short loc_172		
	xor	ax,ax			
	sahf				; Store ah into flags
	mov	ax,5
	mov	bx,2
	div	bl			; al, ah rem = ax/reg
	lahf				; Load ah from flags
	cmp	ah,2
	jne	short loc_172		
loc_171:
	xor	al,al			
	jmp	short loc_173
loc_172:
	xor	al,al			
	inc	al
loc_173:
	popa				
	retn
ENDP

PROC	test_cpu_cyrix
;sub_76		proc	near
	push	eax
	call	is_cpuid_available
	jnz	short loc_175		
	call	get_extended_cpuid
	cmp	eax,80000004h
	jb	short loc_174		
	call	get_cpu_cyrix_1
	call	get_cpu_brandstring
	jmp	short loc_176
loc_174:
	call	get_basic_cpuid
	cmp	eax,1
	jc	short loc_175		
	call	get_cpu_cyrix_1
	jnc	short loc_176		
loc_175:
	call	get_cpu_cyrix_2
loc_176:
	pop	eax
	retn
ENDP

PROC	test_cpu_cyrix_2
;sub_77		proc	near
	pusha				
	call	test_cpu_cyrix
	cmp	[byte cyrix_0],0FFh	
	je	short loc_181		
	cmp	[byte cyrix_0],2	
	jb	short loc_181		
	mov	al,0C3h
	mov	bl,10h
	call	get_cyrix_1
	jc	short loc_181		
	cmp	[byte cyrix_0],2	
	je	short loc_177		
	cmp	[byte cyrix_0],3	
	je	short loc_178		
	cmp	[byte cyrix_0],4	
	je	short loc_178		
	cmp	[byte cyrix_0],5	
	je	short loc_179		
	jmp	short loc_181
loc_177:
	mov	al,0E8h
	mov	bl,80h
	call	get_cyrix_1
	jmp	short loc_180
loc_178:
	mov	al,0C1h
	mov	bl,10h
	call	get_cyrix_1
	mov	al,0E8h
	mov	bl,80h
	call	get_cyrix_1
	mov	al,0E9h
	mov	bl,1
	call	get_cyrix_1
	jmp	short loc_180
loc_179:
	mov	al,0C1h
	mov	bl,10h
	call	get_cyrix_1
	mov	al,0E8h
	mov	bl,80h
	call	get_cyrix_1
	mov	al,0E9h
	mov	bl,1
	call	get_cyrix_1
	jmp	short loc_180
loc_180:
	clc				
	jmp	short loc_182
loc_181:
	stc				
loc_182:
	mov	al,0C3h
	mov	bl,10h
	call	get_cyrix_2
	popa				
	retn
ENDP	

PROC	test_cpu_cyrix_3
;sub_78		proc	near
	pusha				
	call	test_cpu_cyrix
	cmp	[byte cyrix_0],0FFh	
	je	short loc_184		
	cmp	[byte cyrix_0],2	
	jb	short loc_184		
	jz	short loc_183		
	cmp	[byte cyrix_0],3	
	je	short loc_183		
	cmp	[byte cyrix_0],4	
	je	short loc_183		
	cmp	[byte cyrix_0],5	
	je	short loc_183		
	jmp	short loc_184
loc_183:
	mov	al,0C2h
	mov	bl,8
	call	get_cyrix_1
	jc	short loc_184		
	clc				
	jmp	short loc_185
loc_184:
	stc				
loc_185:
	popa				
	retn
ENDP

PROC	get_cpu_intel_1
;sub_79		proc	near
	pusha				
	call	is_cpuid_available
	jnz	short loc_187		
	call	get_cpu_intel_2
	jz	short loc_186		
	call	get_basic_cpuid
	mov	si,offset cpuid_str
	mov	di,offset cpu_intel_01_str
	call	strcmp
	jnz	short loc_187		
loc_186:
	xor	al,al			
	jmp	short loc_188
loc_187:
	xor	al,al			
	inc	al
loc_188:
	popa				
	retn
ENDP

PROC	get_cpu_intel_2
;sub_80		proc	near
	push	eax
	call	get_basic_cpuid
	cmp	eax,5FFh
	ja	short loc_189		
	cmp	eax,500h
	jb	short loc_189		
	xor	al,al			
	jmp	short loc_190
loc_189:
	xor	al,al			
	inc	al
loc_190:
	pop	eax
	retn
ENDP

PROC	get_basic_cpu_info_3
;sub_81		proc	near
	push	eax bx
	call	get_basic_cpuid
	mov	bx,ax
	and	al,0Fh
	mov	[cpu_stepping],al
	mov	al,bl
	shr	al,4			
	mov	[cpu_model],al
	mov	ah,bh
	and	ah,0Fh
	mov	[cpu_family],ah
	mov	ah,bh
	shr	ah,4			
	mov	[cpu_type],ah
	mov	[cpu_features],1BFh
	pop	bx eax
	retn
ENDP

PROC	get_cpu_intel_4
;sub_83		proc	near
	pusha				
	call	get_cpu_intel_2
	jz	loc_194			
	call	get_basic_cpu_info
	mov	al,[cpu_family]
	mov	bl,[cpu_model]
	cmp	al,4
	je	short loc_191		
	cmp	al,5
	je	short loc_192		
	cmp	al,6
	je	loc_193			
	jmp	loc_195
loc_191:
	mov	[intel_0],1
	mov	si,offset cpu_intel_03_str
	cmp	bl,0
	je	loc_196			
	mov	si,offset cpu_intel_04_str
	cmp	bl,1
	je	loc_196			
	mov	si,offset cpu_intel_05_str
	cmp	bl,2
	je	loc_196			
	mov	si,offset cpu_intel_06_str
	cmp	bl,3
	je	loc_196			
	mov	si,offset cpu_intel_07_str
	cmp	bl,4
	je	loc_196			
	mov	si,offset cpu_intel_08_str
	cmp	bl,5
	je	loc_196			
	mov	si,offset cpu_intel_09_str
	cmp	bl,7
	je	loc_196			
	mov	si,offset cpu_intel_10_str
	cmp	bl,8
	je	loc_196			
	mov	si,offset cpu_intel_11_str
	cmp	bl,9
	je	loc_196			
	jnz	short loc_195		
loc_192:
	mov	[intel_0],2
	mov	si,offset cpu_intel_12_str
	cmp	bl,0
	je	short loc_196		
	mov	si,offset cpu_intel_13_str
	cmp	bl,1
	je	short loc_196		
	mov	[intel_0],3
	mov	si,offset cpu_intel_14_str
	cmp	bl,3
	je	short loc_196		
	mov	[intel_0],4
	mov	si,offset cpu_intel_13_str
	cmp	bl,2
	je	short loc_196		
	cmp	bl,7
	je	short loc_196		
	mov	[intel_0],5
	mov	si,offset cpu_intel_15_str
	cmp	bl,4
	je	short loc_196		
	cmp	bl,8
	je	short loc_196		
	jnz	short loc_195		
loc_193:
	mov	[intel_0],6
	mov	si,offset cpu_intel_16_str
	cmp	bl,0
	je	short loc_196		
	mov	si,offset cpu_intel_17_str
	cmp	bl,1
	je	short loc_196		
	mov	si,offset cpu_intel_18_str
	cmp	bl,3
	je	short loc_196		
	cmp	bl,5
	je	short loc_196		
	jnz	short loc_195		
loc_194:
	mov	[intel_0],2
	mov	si,offset cpu_intel_12_str
	jmp	short loc_196
loc_195:
	mov	[intel_0],0
	mov	si,offset cpu_intel_02_str
	jmp	short loc_196
loc_196:
	mov	di,offset cpu_name
	call	strcpy
	popa				
	retn
ENDP

PROC	get_cpu_intel_3
;sub_84		proc	near
	call	get_cpu_intel_2
	jnz	short loc_197		
	call	get_basic_cpu_info_3
	jmp	short loc_ret_198
loc_197:
	call	get_basic_cpu_info
	jmp	short loc_ret_198

loc_ret_198:
	retn
ENDP

PROC	test_cpu_intel
;sub_86		proc	near
	pusha				
	call	get_cpu_intel_3
	test	[cpu_features],20h
	jz	short loc_202		
	call	get_cpu_intel_4
	cmp	[byte ptr ds:intel_0],4
	jb	short loc_202		
	jz	short loc_199		
	cmp	[byte ptr ds:intel_0],5
	je	short loc_200		
	jnz	short loc_202		
loc_199:
	mov	ecx,0Eh
	rdmsr				
	and	al,0BFh
	wrmsr				
	jmp	short loc_201
loc_200:
	mov	ecx,0Eh
	rdmsr				
	and	al,0BFh
	or	eax,200000h
	wrmsr				
	jmp	short loc_201
loc_201:
	clc				
	jmp	short loc_203
loc_202:
	stc				
loc_203:
	popa				
	retn
ENDP
	nop

PROC get_cpu_amd_3
;sub_87		proc	near
	pusha				
	call	is_cpuid_available
	jnz	short loc_204		
	call	get_basic_cpuid
	mov	si,offset cpuid_str
	mov	di,offset cpu_amd_01_str
	call	strcmp
	jnz	short loc_204		
	xor	al,al			
	jmp	short loc_205
loc_204:
	xor	al,al			
	inc	al
loc_205:
	popa				
	retn
ENDP

PROC	get_cpu_amd_4
;sub_89		proc	near
	pusha				
	call	get_basic_cpu_info
	mov	al,[cpu_family]	
	mov	bl,[cpu_model	 ]
	cmp	al,4
	je	short loc_206		
	cmp	al,5
	je	short loc_207		
	jmp	short loc_208
loc_206:
	mov	si,offset cpu_amd_03_str
	cmp	bl,3
	je	short loc_209		
	mov	si,offset cpu_amd_04_str
	cmp	bl,7
	je	short loc_209		
	mov	si,offset cpu_amd_05_str
	cmp	bl,8
	je	short loc_209		
	mov	si,offset cpu_amd_06_str
	cmp	bl,9
	je	short loc_209		
	mov	si,offset cpu_amd_07_str
	cmp	bl,0Eh
	je	short loc_209		
	mov	si,offset cpu_amd_08_str
	cmp	bl,0Fh
	je	short loc_209		
	jnz	short loc_208		
loc_207:
	mov	si,offset cpu_amd_09_str
	cmp	bl,0
	je	short loc_209		
	mov	si,offset cpu_amd_10_str
	cmp	bl,1
	je	short loc_209		
	cmp	bl,2
	je	short loc_209		
	cmp	bl,3
	je	short loc_209		
	mov	si,offset cpu_amd_11_str
	cmp	bl,6
	je	short loc_209		
	cmp	bl,7
	je	short loc_209		
	mov	si,offset cpu_amd_12_str
	cmp	bl,8
	je	short loc_209		
	mov	si,offset cpu_amd_13_str
	cmp	bl,9
	je	short loc_209		
	jnz	short loc_208		
loc_208:
	mov	si,offset cpu_amd_02_str
	jmp	short loc_209
loc_209:
	mov	di,offset cpu_name
	call	strcpy
	popa				
	retn
ENDP

PROC	get_cpu_amd_5
;sub_90		proc	near
	push	eax
	call	get_extended_cpuid
	cmp	eax,80000004h
	jb	short loc_210		
	call	get_cpu_brandstring
	jmp	short loc_211
loc_210:
	call	get_cpu_amd_4
	jmp	short loc_211
loc_211:
	pop	eax
	retn
ENDP

PROC	set_clc_1
;sub_91		proc	near
	clc				
	retn
ENDP

PROC	get_cpu_Centaur_1
;sub_92		proc	near
	pusha				
	call	is_cpuid_available
	jnz	short loc_213		
	call	get_basic_cpuid
	mov	si,offset cpuid_str
	mov	di,offset cpu_idt_01_str
	call	strcmp
	jz	short loc_212		
	mov	eax,0C0000000h
	cpuid				
	cmp	eax,0C0000000h
	jne	short loc_213		
loc_212:
	xor	al,al			
	jmp	short loc_214
loc_213:
	xor	al,al			
	inc	al
loc_214:
	popa				
	retn
ENDP

PROC	get_cpu_Centaur_2
;sub_94		proc	near
	pusha				
	call	get_basic_cpu_info
	mov	al,[cpu_family]	
	mov	bl,[cpu_model ]
	cmp	al,5
	je	short loc_215		
	cmp	al,6
	je	short loc_216		
	jmp	short loc_217
loc_215:
	mov	[idt_0],1
	mov	si,offset cpu_idt_03_str
	cmp	bl,4
	je	short loc_218		
	jnz	short loc_217		
loc_216:
	mov	[idt_0],2
	mov	si,offset cpu_idt_04_str
	jmp	short loc_218
loc_217:
	mov	[idt_0],0
	mov	si,offset cpu_idt_02_str
	jmp	short loc_218
loc_218:
	mov	di,offset cpu_name
	call	strcpy
	popa				
	retn
ENDP

PROC	set_clc_2
;sub_95		proc	near
	clc				
	retn
ENDP

PROC	test_cpu_Centaur
;sub_96		proc	near
	pusha				
	call	get_basic_cpu_info
	test	[cpu_features],20h
	jz	short loc_220		
	call	get_cpu_Centaur_2
	cmp	[idt_0],1
	je	short loc_219		
	jnz	short loc_220		
loc_219:
	mov	ecx,0Eh
	rdmsr				
	or	al,40h			
	wrmsr				
	jmp	short $+2		
	clc				
	jmp	short loc_221
loc_220:
	stc				
loc_221:
	popa				
	retn
ENDP

PROC	get_cpu_nexgen_1
;sub_97		proc	near
	pusha				
	call	is_cpuid_available
	jnz	short loc_222		
	call	get_basic_cpuid
	mov	si,offset cpuid_str
	mov	di,offset cpu_nexgen_01_str
	call	strcmp
	jz	short loc_223		
	jnz	short loc_224		
loc_222:
	call	is_486sx
	jz	short loc_224		
	mov	ax,5555h
	xor	dx,dx			
	mov	cx,2
	div	cx			; ax,dx rem=dx:ax/reg
	jnz	short loc_224		
loc_223:
	xor	al,al			
	jmp	short loc_225
loc_224:
	xor	al,al			
	inc	al
loc_225:
	popa				
	retn
ENDP

PROC	get_cpu_nexgen_2
;sub_98		proc	near
	pushad				
	call	is_cpuid_available
	jnz	short loc_226		
	call	get_basic_cpuid
	cmp	eax,1
	jc	short loc_226		
	call	get_basic_cpu_info
	cmp	[cpu_family],5
	je	short loc_226		
	cmp	[cpu_family],6
	je	short loc_227		
	mov	si,offset cpu_nexgen_02_str
	jmp	short loc_228
loc_226:
	mov	si,offset cpu_nexgen_03_str
	call	test_fpu
	cmp	ah,0
	je	short loc_228		
	mov	si,offset cpu_nexgen_04_str
	jmp	short loc_228
loc_227:
	mov	si,offset cpu_nexgen_05_str
	jmp	short loc_228
loc_228:
	mov	di,offset cpu_name
	call	strcpy
	popad				
	retn
ENDP

PROC	get_cpu_intel_6
;sub_99		proc	near
	pusha				
	call	is_cpuid_available
	jnz	short loc_230		
	call	get_basic_cpuid
	mov	si,offset cpuid_str
	mov	di,offset cpu_intel_01_str
	call	strcmp
	jz	short loc_229		
	jnz	short loc_230		
loc_229:
	xor	al,al			
	jmp	short loc_231
loc_230:
	xor	al,al			
	inc	al
loc_231:
	popa				
	retn
ENDP

PROC	get_cpu_umc
;sub_100		proc	near
	pusha				
	call	get_basic_cpu_info
	mov	al,[cpu_family]	
	mov	bl,[cpu_model]	
	cmp	al,4
	je	short loc_232		
	jmp	short loc_234
loc_232:
	cmp	bl,1
	jne	short loc_233		
	mov	si,offset cpu_umc_03_str
	jmp	short loc_235
loc_233:
	cmp	bl,2
	jne	short loc_234		
	mov	si,offset cpu_umc_04_str
	jmp	short loc_235
loc_234:
	mov	si,offset cpu_umc_02_str
	jmp	short loc_235
loc_235:
	mov	di,offset cpu_name
	call	strcpy
	popa				
	retn
ENDP

PROC	cpu_getname
;sub_101		proc	near
	push	ax es
	mov	ax,ds
	mov	es,ax
	call	get_cpu_intel_1
	jz	short loc_236		
	call	get_cpu_amd_3
	jz	short loc_237		
	call	initial_cpu_check
	jz	short loc_238		
	call	get_cpu_Centaur_1
	jz	short loc_239		
	call	get_cpu_nexgen_1
	jz	short loc_240		
	call	get_cpu_intel_6
	jz	short loc_241		
	call	get_cpus		
	jz	short loc_242		
	jmp	short loc_244
loc_236:
	call	get_cpu_intel_4
	jmp	short loc_243
loc_237:
	call	get_cpu_amd_5
	jmp	short loc_243
loc_238:
	call	test_cpu_cyrix
	jmp	short loc_243
loc_239:
	call	get_cpu_Centaur_2
	jmp	short loc_243
loc_240:
	call	get_cpu_nexgen_2	
	jmp	short loc_243
loc_241:
	call	get_cpu_umc             
	jmp	short loc_243
loc_242:
	call	get_cpu_early_model
	jmp	short loc_243
loc_243:
	clc				
	mov	si,offset cpu_name
	jmp	short loc_245
loc_244:
	stc				
	mov	si,offset cpu_failed_str
loc_245:
	pop	es ax
	retn
ENDP

PROC	cpu_optimize
;sub_102		proc	near
	push	ax es si			
	cli				
	xor	si, si
	mov	ax,ds
	mov	es,ax
	call	TEST_V86
	jnz	short loc_247		
	call	TEST_DPMI
	jz	short loc_252		
	call	WIN386_V86_CALLBACK_INIT
	jc	short loc_252		
	mov	si,1
loc_247:
	call	initial_cpu_check
	jz	short loc_248		
	call	get_cpu_amd_3
	jz	short loc_249		
	call	get_cpu_Centaur_1
	jz	short loc_250		
	jmp	short loc_252
loc_248:
	call	test_cpu_cyrix_2
	jc	short loc_252		
	jnc	short loc_251		
loc_249:
	call	set_clc_1
	jc	short loc_252		
	jnc	short loc_251		
loc_250:
	call	set_clc_2
	jc	short loc_252		
	jnc	short loc_251		
loc_251:
	clc				
	jmp	short loc_253
loc_252:
	stc				
loc_253:
	pushf				
	cmp	si,1
	jne	short loc_254		
	call	WIN386_V86_CALLBACK_EXIT
loc_254:
	popf				
	pop	si es ax
	retn
ENDP

PROC	cpu_powersave
;sub_103		proc	near
	push	ax es si
	cli				
	xor	si,si
	mov	ax,ds
	mov	es,ax
	call	TEST_V86
	jnz	short loc_256		
	call	TEST_DPMI
	jz	short loc_261		
	call	WIN386_V86_CALLBACK_INIT
	jc	short loc_261		
	mov	si,1		
loc_256:
	call	get_cpu_intel_1
	jz	short loc_257		
	call	initial_cpu_check
	jz	short loc_258		
	call	get_cpu_centaur_1
	jz	short loc_259		
	jmp	short loc_261
loc_257:
	call	test_cpu_intel
	jc	short loc_261		
	jnc	short loc_260		
loc_258:
	call	test_cpu_cyrix_3
	jc	short loc_261		
	jnc	short loc_260		
loc_259:
	call	test_cpu_Centaur
	jc	short loc_261		
	jnc	short loc_260		
loc_260:
	clc				
	jmp	short loc_262
loc_261:
	stc				
loc_262:
	pushf				
	cmp	si,1
	jne	short loc_263		
	call	WIN386_V86_CALLBACK_EXIT
loc_263:
	popf				
	pop	si es ax
	retn
ENDP

ENDS

SEGMENT	STACK16	PARA STACK 'STACK'
        db 2048 dup (?)                 ; Stack for initialization part.
ENDS

END	main
