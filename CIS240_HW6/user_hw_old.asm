OS_VIDEO_MEM 		.UCONST xC000
OS_VIDEO_NUM_COLS	.UCONST #128
OS_VIDEO_NUM_ROWS	.UCONST #124
	
INIT_X	.UCONST #60
INIT_Y	.UCONST #0
MAX_X 	.UCONST #120
MAX_Y	.UCONST #116
	
KEY_A	.UCONST x61
KEY_R	.UCONST x72
KEY_G	.UCONST x67
KEY_B	.UCONST x62
KEY_Q	.UCONST x71
KEY_J	.UCONST x6A
KEY_K	.UCONST x6B

;;;  define some colors
RED   .UCONST x7C00	; 0 11111 00000 00000
GREEN .UCONST x03E0	; 0 00000 11111 00000
BLUE  .UCONST x001F	; 0 00000 00000 11111
WHITE .UCONST x7FFF	; 0 11111 11111 11111
BLACK .UCONST x0000

;;;  data
	.DATA
	.ADDR x4000
	
name_array
	.STRINGZ "Catherine Hu"

global_array
	.FILL #0		; use this slot for X
	.FILL #0		; use this slot for Y
	.FILL #0		; use this slot for color
	.FILL #0		; use these slot for anything else that comes up
	.FILL #0
	.FILL #0

;;;  user code
	.CODE
	.ADDR x0000

	LC R0, INIT_X		; set X = 60
	LC R1, INIT_Y		; set Y = 0
	LC R2, RED		; set R2 (color) = red
	
LOOP
	TRAP 0x09		; Call GET_EVENT

IF_A
	LC R3, KEY_A
	CMP R5, R3		; compare R5 (output of GET_EVENT) with a
	BRnp IF_R

	;;;initialize variables for PUTS
	LEA R0, name_array	; Initialize R4
	
	TRAP 0x08		; call PUTS

IF_R
	LC R3, KEY_R
	CMP R5, R3		; compare R5 with r
	BRnp IF_G
	
	LC R2, RED

IF_G
	LC R3, KEY_G
	CMP R5, R3		; compare R5 with g
	BRnp IF_B

	LC R2, GREEN

IF_B	LC R3, KEY_B
	CMP R5, R3		; compare R5 with b
	BRnp IF_Q

	LC R2, BLUE

IF_Q
	LC R3, KEY_Q
	CMP R5, R3		; compare R5 with q
	BRnp IF_J

	LC R0, INIT_X		; reset R0 (X) to 60
	LC R1, INIT_Y		; reset R1 (Y) to 0
	
IF_J
	LC R3, KEY_J
	CMP R5, R3		; compare R5 with j
	BRnp IF_K

	ADD R6, R0, #-1		; newX = X--
	
IF_K
	LC R3, KEY_K
	CMP R5, R3		; compare R5 with k
	BRnp CONTINUE

	ADD R6, R0, #1		; newX = X++

CONTINUE

	ADD R7, R1, #1		; newY = Y+1

	CMPI R6, #0		; compare newX to 0
	BRzp X_NOTUNDER
	CONST R6, #0		; newX = 0
	JMP X_NOTOVER
	
X_NOTUNDER
	LC R3, MAX_X
	CMP R6, R3		; compare newX to the maxX
	BRnz X_NOTOVER
	SUB R6, R6, R6
	LC R6, MAX_X		; newX = 120

X_NOTOVER
	LC R3, MAX_Y		; compare newY to maxY
	CMP R7, R3
	BRnz Y_NOTOVER
	SUB R7, R7, R7
	LC R7, MAX_Y		; newY = 116

Y_NOTOVER

	;; Erase old block
	LC R2, RED
	TRAP 0x0A		;;call DRAW_BLOCK to "erase" old block


	;; Update X and Y to newX and newY
	CONST R0, #0
	ADD R0, R0, R6
	CONST R1, #0
	ADD R1, R1, R7

	;; Draw new block
		;;LC R2, RED
		;;TRAP 0x0A

	JMP LOOP

END_PROGRAM