; filename: boot.asm

org     0x7c00                      ; we are loaded by the bios at 0x7c00
bits    16                          ; we are still in 16 bit real mode

start:  
	jmp loader						; jump over OEM block, it's just data, not code

%include "opb.inc"					; include OEM parameter block from external file


;*************************************************;
;	Bootloader Entry Point
;*************************************************;

loader:

	call	PrintWelcome

	cli                         	; clear all interrupts
	hlt                         	; halt the system


;*************************************************;
;	Print Welcome Message	
;*************************************************;

msg		db		"JonOS Bootloader", 0

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

;**************************************************
;	Write out the rest of the boot sector.
;	KEEP AT EOF!!!
;**************************************************

times 510 - ($-$$) db 0             ; we have to be 512 bytes.  clear the rest of the bytes with 0
                                    ; $ is address of current line.  $$ is address of start of program

dw 0xAA55                           ; append the boot signature


