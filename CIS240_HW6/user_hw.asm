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

global_array
	.FILL #0		;store x
	.FILL #0		;store y
	.FILL #0		;store color
	.FILL #0		;store newx
	.FILL #0		;store newy

name_array
	.STRINGZ "Catherine Hu"

;;;  user code
	.CODE
	.ADDR x0000

	LC R0, INIT_X		; set X = 60
	LC R1, INIT_Y		; set Y = 0
	LC R2, RED		; set R2 (color) = red
	
LOOP
	ADD R6, R0, #0		; initialize newX = X
	LEA R3, global_array
	STR R0, R3, #0
	STR R1, R3, #1
	STR R2, R3, #2
	STR R6, R3, #3
	STR R7, R3, #4
	TRAP 0x09		; call GET_EVENT
	LEA R3, global_array
	LDR R0, R3, #0
	LDR R1, R3, #1
	LDR R2, R3, #2
	LDR R6, R3, #3
	LDR R7, R3, #4
	
IF_A
	LC R3, KEY_A
	CMP R5, R3		; compare R5 (output of GET_EVENT) with a
	BRnp IF_R
	
	LEA R3, global_array
	STR R0, R3, #0
	STR R1, R3, #1
	STR R2, R3, #2
	STR R6, R3, #3
	STR R7, R3, #4
	LEA R0, name_array
	TRAP 0x08		; call PUTS
	LEA R3, global_array
	LDR R0, R3, #0
	LDR R1, R3, #1
	LDR R2, R3, #2
	LDR R6, R3, #3
	LDR R7, R3, #4
	
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

	LC R6, INIT_X		; newX to 60
	LC R7, INIT_Y		; newY to 0
	JMP Y_NOT_OVER
	
IF_J
	LC R3, KEY_J
	CMP R5, R3		; compare R5 with j
	BRnp IF_K

	ADD R6, R6, #-1		; newX = X--

IF_K
	LC R3, KEY_K
	CMP R5, R3		; compare R5 with k
	BRnp INCR_Y

	ADD R6, R6, #1		; newX = X++

INCR_Y
	ADD R7, R1, #1		; newY (R7) = Y + 1

CHECK_X_UNDER
	CMPI R6, #0		; compare newX to 0
	BRzp CHECK_X_OVER
	CONST R6, #0		; set newX to 0
	BRnzp CHECK_Y
	
CHECK_X_OVER
	LC R3, MAX_X		; compare newX to MAX_X
	CMP R6, R3		
	BRnz CHECK_Y
	LC R6, MAX_X		; set newX to MAX_X
	
CHECK_Y
	LC R3, MAX_Y
	CMP R7, R3 		; compare Y to MAX_Y
	BRnz Y_NOT_OVER
	LC R7, MAX_Y		; set newY to MAX_Y if over
	
Y_NOT_OVER
	
	LEA R3, global_array
	STR R0, R3, #0
	STR R1, R3, #1
	STR R2, R3, #2
	STR R6, R3, #3
	STR R7, R3, #4
	LC R2, BLACK
	TRAP 0x0A		;;call DRAW_BLOCK to "erase" old block
	LEA R3, global_array
	LDR R0, R3, #0
	LDR R1, R3, #1
	LDR R2, R3, #2
	LDR R6, R3, #3
	LDR R7, R3, #4

	;; Update X and Y to newX and newY
	LDR R0, R3, #3
	LDR R1, R3, #4

	;; Draw new block
	LEA R3, global_array
	STR R0, R3, #0
	STR R1, R3, #1
	STR R2, R3, #2
	TRAP 0x0A
	LEA R3, global_array
	LDR R0, R3, #0
	LDR R1, R3, #1
	LDR R2, R3, #2
	CONST R7, #0
	JMP LOOP

END_PROGRAM