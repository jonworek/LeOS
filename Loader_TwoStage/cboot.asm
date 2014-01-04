org 0x7e00

;**************************************************
;	Second stage bootloader code.  Woot!
;**************************************************

	call	PrintWelcome

	cli								; clear interrupts
	hlt								; halt the system
	

;*************************************************;
;	Print Welcome Message	
;*************************************************;

PrintWelcome:
	xor		ax, ax
	mov		ds, ax
	mov		es, ax
	mov 	si, msg

PrintWelcomeLoop:

	lodsb
	or		al, al
	jz		PrintWelcomeDone
	mov		ah, 0eh
	int		10h
	jmp		PrintWelcomeLoop
	
PrintWelcomeDone:
	ret
	
msg		db		"JonOS Bootloader - Stage 2", 0
