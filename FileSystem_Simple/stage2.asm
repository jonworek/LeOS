org 	0x0

bits 	16

main:

	cli
	push 	cs
	pop		ds
	
	call	PrintWelcome

	cli                         	; clear all interrupts
	hlt                         	; halt the system


;*************************************************;
;	Print Welcome Message	
;*************************************************;

msg		db		"Preparing to load operating system...", 13, 10, 0

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
