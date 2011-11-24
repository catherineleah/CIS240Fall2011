;;;
;;; Code to test out keyboard echoing : CJT
;;;

;;; Define addresses of I/O registers
	OS_KBSR_ADDR .UCONST xFE00
	OS_KBDR_ADDR .UCONST xFE02
	OS_ADSR_ADDR .UCONST xFE04
	OS_ADDR_ADDR .UCONST xFE06

	.OS
	.CODE
	.ADDR x8200

EGETC
	LC R0, OS_KBSR_ADDR	; Loop while KBSR[15] == 0
	LDR R0, R0, #0
	BRzp EGETC
	LC R0, OS_KBDR_ADDR
	LDR R0, R0, #0 		; Read the Keyboard character
EGETC_E
	LC R1, OS_ADSR_ADDR	; Loop while ADSR[15] == 0 ie output not ready
	LDR R1, R1, #0
	BRzp EGETC_E
	LC R1, OS_ADDR_ADDR
	STR R0, R1, #0

	JMP EGETC		; Jump back and start again