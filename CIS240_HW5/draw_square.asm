;; draw_square program
;;
;; draw a 60x60 square in video memory
;;
;; for (row = 30; row < 90; ++row){
;;	for (col = 34; col < 94; ++col){
;;		Pixel_address = xC000 + (row * 128) + col;
;; 		Store designated color at pixel address;
;;	}
;; }
;;

OS_VIDEO_MEM 		.UCONST xC000
OS_VIDEO_NUM_COLS	.UCONST #128
OS_VIDEO_NUM_ROWS	.UCONST #124

ROW_OFFSET 	.UCONST #30
COL_OFFSET 	.UCONST #34

RED	.UCONST x7C00
BLUE 	.UCONST x03E0
GREEN	.UCONST x001F
LIME	.UCONST x5329
ORANGE	.UCONST xFDE3
PURPLE 	.UCONST xCCDD

	.CODE			; This is a code segment
	.ADDR 0x0000 		; Start the code at address 0x0000

	LC R0, PURPLE		; load the color into R0
	CONST R3, #-1		; r = -1
	
LOOP
	ADD R3, R3, #1			; increment r
	
	;; Set up R1 to point to leftmost pixel of line
	LC R1, ROW_OFFSET	; initially set R1 to ROW_OFFSET
	ADD R1, R1, R3		; add the # row we are on
	SLL R1, R1, #7		; multiply row by 128 by shifting left #7
	LC R4, COL_OFFSET	; set R4 constant to COL_OFFSET
	ADD R1, R1, R4		; add column offset to R1
	LC R4, OS_VIDEO_MEM	; set R4 constant to OS_VIDEO_MEM
	ADD R1, R1, R4		; add video mem address to R1
	
	CMPI R3, #60		; compare row number to 60
	BRzp END
	
	CONST R2, #0		; c = 0
	JMP TEST
BODY
	STR R0, R1, #0		; write the color into the pixel address
	ADD R2, R2, #1		; increment c
	ADD R1, R1, #1		; increment address
TEST
	CMPI R2, #60		; compare column number to 60
	BRn BODY

	BRnzp LOOP		

END
	NOP