;;; USER Code
	.DATA
	.ADDR x4000
	
name_array
	.STRINGZ "Enter characters : "

;;;  Allocate space for some temporary variables
	.ADDR x4200
TEMPS 	.BLKW x200
	
	.CODE
	.ADDR x0000

;;; Loop to print out null terminated string
	LEA R4, name_array	; Initialize R4
	LEA R5, TEMPS
	STR R4, R5, #0		; Store pointer
	
PRINT_STRING_LOOP
	LEA R5, TEMPS
	LDR R4, R5, #0		; retrieve pointer
	LDR R0, R4, #0		; Get a character from the string
	
	BRz ECHO_LOOP		; check if character is null
	
	ADD R4, R4, #1		; increment pointer
	STR R4, R5, #0		; store pointer

	TRAP x01		; Call putc

	JMP PRINT_STRING_LOOP
	
ECHO_LOOP
;;;  Get a character from the keyboard
;;; Echo it to the display
	TRAP 0x00		; Call Getc
	
	CMPI R0, 0x00
	BRzp ECHO_LOOP		; Loop while KBSR[15] == 0
	
	CMPIU R1, 0x0A		; Check for newline
	BRz END_PROGRAM

	ADD R0, R1, #0		; Copy R1 to R0

	TRAP 0x01		; Call putc

	JMP ECHO_LOOP

END_PROGRAM
