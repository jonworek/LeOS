; filename: boot.asm

org     0x7c00                      ; we are loaded by the bios at 0x7c00
bits    16                          ; we are still in 16 bit real mode

start:
	jmp 	loader					; need to jump over the OPB

%include "opb.inc"					; include OEM parameter block from external file
									; this describes the filesystem

;***************************************************
;	BOOTLOADER CODE
;***************************************************

loader:

	; adjust segment registers to reflect where we will be loaded
	
	cli								; disable interrupts
	
	mov		ax, 0x7c0				; setup registers to point to our segment
	mov		ds, ax
	mov		es, ax
	mov		fs, ax
	mov		gs, ax
	
	; create the stack
	
	mov		ax, 0x0000				; set the stack
	mov		ss, ax
	mov		sp, 0xffff
	
	sti								; restore interrupts
	
	; print the welcome message

	mov 	si, welcomeMsg
	call	PrintMessage

LOAD_ROOT_DIR:

; compute the size of the root directory in num sectors and store in CX
	
	xor		cx, cx
	xor		dx, dx
	mov		ax, 0x20					; size of directory entry -> 32 bytes
	mul		WORD [bpbRootEntries]		; total size of direcotry
	div		WORD [bpbBytesPerSector]	; sectors used by directory
	xchg	ax, cx						; put the result in the CX register
	
; compute location of root directory and store in AX

	mov		al, BYTE [bpbNumberOfFATs]			; the number of FATs
	mul		WORD [bpbSectorsPerFAT]				; number of sectors used by a FAT
	add		ax, WORD [bpbReservedSectors]		; adjust for reserved sectors (bootsector)
	mov		WORD [datasector], ax				; base of root directory
	add		WORD [datasector], cx
	
; read root directory into memory at (7c00:0200)

	mov		bx, 0x200					; copy root directory above bootsector
	call	ReadSectors
		
		
	; TODO: halt the computer, for now...					
	cli
	hlt
									
;*************************************************;
;	Prints a message to the screen
;	Parameters: si: start address of string to print	
;*************************************************;

PrintMessage:
	xor		ax, ax
	mov		ds, ax
	mov		es, ax

.printMessageLoop:

	lodsb
	or		al, al
	jz		.printMessageDone
	mov		ah, 0eh
	int		10h
	jmp		.printMessageLoop
	
.printMessageDone:
	ret
	
;**************************************************
;	Reads a series of sectors from disk into memory
;	Parameters:
;		CX: number of sectors to read
;		AX: starting sector
;		ES:BX: memory location to read into
;**************************************************

ReadSectors:
	.main:
		mov		di, 0x0005				; number of retries on error
		
	.sectorLoop:
		push	ax
		push	bx
		push	cx
		
		call	LBAtoCHS					; convert starting sector to CHS
		
		mov		ah, 0x02					; BIOS read sector
		mov		al, 0x01					; read one sector
		mov		ch, BYTE [absoluteTrack]	; track
		mov		cl, BYTE [absoluteSector]	; sector
		mov		dh, BYTE [absoluteHead]		; head
		mov		dl, BYTE [bsDriveNumber]	; drive number
		
		int		0x13						; call BIOS read disk function
		
		jnc		.success					; test for read error
		
		xor		ax, ax						; BIOS reset disk function
		int		0x13						; BIOS reset disk function
		
		dec		di							; decrement error counter
		pop		cx
		pop		bx
		pop		ax
		
		jnz		.sectorLoop					; try to read again
		
		int		0x18
		
	.success:
		mov		si, msgProgress
		call	PrintMessage
		
		pop		cx
		pop		bx
		pop		ax
		add		bx, WORD [bpbBytesPerSector]	; queue next buffer
		inc		ax								; queue next sector
		
		loop	.main							; read next sector
		
		ret
		
;**************************************************
;	Convert LBA to CHS
;	Parameters:
;		AX: LBA address to convert
;
;	Returns:
;		absoluteSector: (logical sector / sectors per track) + 1
;		absoluteHead: (logical sector / sectors per track) % number of heads
;		absoluteTrack: (logical sector / (sectors per track * number of heads))
;
;**************************************************

LBAtoCHS:
	
	xor		dx, dx
	div		WORD [bpbSectorsPerTrack]	
	inc		dl								; adjust for sector 0
	mov		BYTE [absoluteSector], dl
	
	xor		dx, dx
	div		WORD [bpbHeadsPerCylinder]
	mov		BYTE [absoluteHead], dl
	mov		BYTE [absoluteTrack], al
	
	ret
									
;**************************************************
;**************************************************
; 	DATA SEGMENT
;**************************************************
;**************************************************

welcomeMsg			db		"JonOS Bootloader", 0xd, 0xa, 0
msgProgress 		db 		".", 0x00

datasector			DW		0x0000
absoluteSector 		db 		0x00
absoluteHead   		db 		0x00
absoluteTrack  		db 		0x00

;**************************************************
;	Write out the rest of the boot sector.
;	KEEP AT EOF!!!
;**************************************************

times 510 - ($-$$) db 0             ; we have to be 512 bytes.  clear the rest of the bytes with 0
                                    ; $ is address of current line.  $$ is address of start of program

dw 0xAA55                           ; append the boot signature

times 0x167e00 db 0					; write out the rest to make a full 1.44MB floppy image
