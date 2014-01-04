; filename: boot.asm

org     0x7c00                      ; we are loaded by the bios at 0x7c00
bits    16                          ; we are still in 16 bit real mode

start:  
	mov		ah, 0					; reset floppy disk function
	
	int		0x13					; call BIOS interrupt 0x13
	
	jc		PrintFailure			; print failure if carry flag set. 
									; this would signify an error!!
.read:		
	call 	PrintWelcome
						
	mov		ax, 0x07e0				; setting up the memory address that we are going to read the sector to!
	mov		es, ax					; addressed as segment:offset (es:bx)
	xor		bx, bx

	mov		ah, 0x02				; function 2, read disk sector
	mov		al, 1					; read just one sector
	mov		ch, 0					; we are reading the second sector past us, still track 1
	mov		cl, 2					; sector to read... the second sector.  sectors start at 1 :)
	mov		dh, 0					; head number
	
	int		0x13					; args are setup, call BIOS interrupt
	
	jc		PrintFailure			; print failure if one was encountered. based on carry register
	
	jmp		0:0x7e00				; execute the sector that was just loaded into memory!
									; if we're lucky, this address will hold our second stage bootloader
									
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
									
;*************************************************;
;	Print Failure Message	
;*************************************************;

PrintFailure:
	xor		ax, ax
	mov		ds, ax
	mov		es, ax
	mov 	si, msg2

PrintFailureLoop:

	lodsb
	or		al, al
	jz		PrintFailureDone
	mov		ah, 0eh
	int		10h
	jmp		PrintFailureLoop
	
PrintFailureDone:
	cli
	hlt

;**************************************************
; 	DATA SEGMENT
;**************************************************
msg			db		"JonOS Bootloader", 0
msg2		db		"Disk failure", 0

;**************************************************
;	Write out the rest of the boot sector.
;	KEEP AT EOF!!!
;**************************************************

times 510 - ($-$$) db 0             ; we have to be 512 bytes.  clear the rest of the bytes with 0
                                    ; $ is address of current line.  $$ is address of start of program

dw 0xAA55                           ; append the boot signature
