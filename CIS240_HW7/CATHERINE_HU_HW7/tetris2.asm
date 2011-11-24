NUMCELLS	.UCONST #240
NCOLS 		.UCONST #16
NROWS 		.UCONST #15
	
		.DATA
shapes 		.FILL #1632
		.FILL #1632
		.FILL #1632
		.FILL #1632
		.FILL #61440
		.FILL #17476
		.FILL #61440
		.FILL #17476
		.FILL #36352
		.FILL #25664
		.FILL #3616
		.FILL #17600
		.FILL #11776
		.FILL #17504
		.FILL #3712
		.FILL #50240
		.FILL #50688
		.FILL #19584
		.FILL #50688
		.FILL #19584
		.FILL #27648
		.FILL #35904
		.FILL #27648
		.FILL #35904
		.FILL #19968
		.FILL #17984
		.FILL #3648
		.FILL #19520
		.DATA
colors 		.FILL #31744
		.FILL #51
		.FILL #13056
		.FILL #32752
		.FILL #62976
		.FILL #1904
		.FILL #65535
;;;;;;;;;;;;;;;;;;;;;;;;;;;;clear_tetris_array;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; old version: 37 lines of instruction
;;; new version: 10 lines of instruction
		.CODE
		.FALIGN
clear_tetris_array
	LEA R1, cells
	CONST R2, #0
p	CONST R3, #0
	LC R4, NUMCELLS
LOOP
	STR R2, R1, #0
	ADD R1, R1, #1
	ADD R3, R3, #1
	CMP R3, R4
	BRn LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;draw_cells;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
draw_cells
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-2	;; allocate stack space for local variables
	;; function body
	CONST R7, #0
	STR R7, R5, #-2
L11_tetris
	CONST R7, #0
	STR R7, R5, #-1
L15_tetris
	LDR R7, R5, #-1
	LDR R3, R5, #-2
	SLL R2, R3, #4
	LEA R1, cells
	ADD R2, R2, R1
	ADD R2, R7, R2
	LDR R2, R2, #0
	ADD R6, R6, #-1
	STR R2, R6, #0
	SLL R3, R3, #3
	ADD R3, R3, #4
	ADD R6, R6, #-1
	STR R3, R6, #0
	SLL R7, R7, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_draw_8x8
	ADD R6, R6, #3	;; free space for arguments
L16_tetris
	LDR R7, R5, #-1
	ADD R7, R7, #1
	STR R7, R5, #-1
	LDR R7, R5, #-1
	CONST R3, #16
	CMP R7, R3
	BRn L15_tetris
L12_tetris
	LDR R7, R5, #-2
	ADD R7, R7, #1
	STR R7, R5, #-2
	LDR R7, R5, #-2
	CONST R3, #15
	CMP R7, R3
	BRn L11_tetris
L10_tetris
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;redraw;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
redraw
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	;; function body
	JSR lc4_reset_vmem
	ADD R6, R6, #0	;; free space for arguments
	JSR draw_cells
	ADD R6, R6, #0	;; free space for arguments
	JSR lc4_blt_vmem
	ADD R6, R6, #0	;; free space for arguments
L19_tetris
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;test_for_collision;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; old code: 75 lines of instruction
;;; new code: 58 lines of instruction
		.CODE
		.FALIGN
test_for_collision
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-4	;; allocate stack space for local variables
	;; function body
	;; shape = R5 + 3
	;; row = R5 + 4
	;; col = R5 + 5
	CONST R7, #0
	HICONST R7, #128	; set mask into R7
	STR R7, R5, #-2		; store mask into R5 - 2
	LDR R7, R5, #4		; set R7 to row
	STR R7, R5, #-3		; store row into R5 - 3
	LDR R7, R5, #5		; set R7 to col
	STR R7, R5, #-4		; store col into R5 - 4
	LDR R2, R5, #-2		; load mask into R2
	LDR R3, R5, #3		; load shape into R3
	CONST R0, #0		; counter for rows
	
ROW_LOOP
	CONST R1, #0		; counter for cols

COL_LOOP

SHAPE_AND_MASK
	AND R4, R2, R3		; AND R2 and R3, put result in R4
	CMPI R4, #0		; compare R4 to 0
	BRnz MASK_SHIFT		; if negative or zero, skip next code and go to mask shift

CHECK_COLUMNS
	STR R2, R5, #-2		; store mask value to free up R2
	LDR R4, R5, #-4		; load col into R4 (c)
	ADD R4, R4, R1		; c = col + col_counter
	LC R2, NCOLS		; set R2 to NCOLS (16)
	CMP R4, R2		; compare c to NCOLS
	BRzp COLLIDE		; if >= NCOLS, collides! ruh roh

	CONST R2, #0		; set R2 to 0
	CMP R4, R2		; compare c to 0
	BRn COLLIDE		; if < 0, collides!

CHECK_ROWS
	LDR R7, R5, #-3		; load row into R7 (r)
	ADD R7, R7, R0		; r = row + row_counter
	LC R2, NROWS		; set R2 to NROWS
	CMP R7, R2		; compare r to NROWS
	BRzp COLLIDE		; if >= NROWS, collides!

CHECK_CELLS
	LC R2, NCOLS		; set R2 to NCOLS
	MUL R7, R7, R2		; r = r * 16 (NCOLS)
	ADD R7, R7, R4		; R7 = r * 16 + R4 (col) --> should be proper offset
	LEA R2, cells		; set R2 to address of cells
	ADD R2, R2, R7		; add offset to address
	LDR R2, R2, #0		; load value at R2 into R2
	CMPI R2, #0		; compare R2 value to 0
	BRnp COLLIDE		; if not equal to zero, COLLIDE!!!!!!!!
	
	LDR R2, R5, #-2		; reload mask value into R2
	
MASK_SHIFT
	SRL R2, R2, #1		; shift mask right >> 1
	
	ADD R1, R1, #1		; increment cols
	CMPI R1, #4		; compare to 4
	BRn COL_LOOP		; loop if negative
END_COL_LOOP
	ADD R0, R0, #1		; increment row counter
	CMPI R0, #4		; compare to 4
	BRn ROW_LOOP		; loop if negative
END_ROW_LOOP
	CONST R7, #0
	JMP L20_tetris
COLLIDE
	CONST R7, #1
L20_tetris
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;draw_shape;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
draw_shape
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-4	;; allocate stack space for local variables
	;; function body
	CONST R7, #0
	HICONST R7, #128
	STR R7, R5, #-1
	LDR R7, R5, #6
	STR R7, R5, #-4
	LDR R7, R5, #4
	STR R7, R5, #-3
	JMP L42_tetris
L39_tetris
	LDR R7, R5, #5
	STR R7, R5, #-2
	JMP L46_tetris
L43_tetris
	LDR R7, R5, #3
	LDR R3, R5, #-1
	AND R7, R7, R3
	CONST R3, #0
	CMP R7, R3
	BRz L47_tetris
	LDR R7, R5, #-2
	LDR R3, R5, #-3
	SLL R3, R3, #4
	LEA R2, cells
	ADD R3, R3, R2
	ADD R7, R7, R3
	LDR R3, R5, #-4
	STR R3, R7, #0
L47_tetris
	LDR R7, R5, #-1
	SRL R7, R7, #1
	STR R7, R5, #-1
L44_tetris
	LDR R7, R5, #-2
	ADD R7, R7, #1
	STR R7, R5, #-2
L46_tetris
	LDR R7, R5, #-2
	LDR R3, R5, #5
	ADD R3, R3, #4
	CMP R7, R3
	BRn L43_tetris
L40_tetris
	LDR R7, R5, #-3
	ADD R7, R7, #1
	STR R7, R5, #-3
L42_tetris
	LDR R7, R5, #-3
	LDR R3, R5, #4
	ADD R3, R3, #4
	CMP R7, R3
	BRn L39_tetris
L38_tetris
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;remove_filled_rows;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
remove_filled_rows
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-4	;; allocate stack space for local variables
	;; function body
	CONST R7, #14
	STR R7, R5, #-4
L50_tetris
	CONST R7, #0
	STR R7, R5, #-3
L54_tetris
	LDR R7, R5, #-3
	LDR R3, R5, #-4
	SLL R3, R3, #4
	LEA R2, cells
	ADD R3, R3, R2
	ADD R7, R7, R3
	LDR R7, R7, #0
	CONST R3, #0
	CMP R7, R3
	BRnp L58_tetris
	JMP L56_tetris
L58_tetris
	LDR R7, R5, #-3
	CONST R3, #15
	CMP R7, R3
	BRnp L60_tetris
	LEA R7, numTotalRows
	LDR R3, R7, #0
	ADD R3, R3, #1
	STR R3, R7, #0
	LDR R7, R5, #-4
	ADD R7, R7, #-1
	STR R7, R5, #-2
	JMP L63_tetris
L62_tetris
	CONST R7, #0
	STR R7, R5, #-1
L65_tetris
	LDR R7, R5, #-1
	LDR R3, R5, #-2
	SLL R3, R3, #4
	LEA R2, cells
	CONST R1, #0
	CONST R0, #16
	ADD R0, R2, R0
	ADD R0, R3, R0
	ADD R0, R7, R0
	LDR R0, R0, #0
	CMP R0, R1
	BRnp L69_tetris
	ADD R3, R3, R2
	ADD R7, R7, R3
	LDR R7, R7, #0
	CMP R7, R1
	BRnp L69_tetris
	JMP L66_tetris
L69_tetris
	LDR R7, R5, #-1
	LDR R3, R5, #-2
	SLL R3, R3, #4
	LEA R2, cells
	CONST R1, #16
	ADD R1, R2, R1
	ADD R1, R3, R1
	ADD R1, R7, R1
	ADD R3, R3, R2
	ADD R7, R7, R3
	LDR R7, R7, #0
	STR R7, R1, #0
L66_tetris
	LDR R7, R5, #-1
	ADD R7, R7, #1
	STR R7, R5, #-1
	LDR R7, R5, #-1
	CONST R3, #16
	CMP R7, R3
	BRn L65_tetris
	LDR R7, R5, #-2
	ADD R7, R7, #-1
	STR R7, R5, #-2
L63_tetris
	LDR R7, R5, #-2
	CONST R3, #0
	CMP R7, R3
	BRzp L62_tetris
	LDR R7, R5, #-4
	ADD R7, R7, #1
	STR R7, R5, #-4
L60_tetris
L55_tetris
	LDR R7, R5, #-3
	ADD R7, R7, #1
	STR R7, R5, #-3
	LDR R7, R5, #-3
	CONST R3, #16
	CMP R7, R3
	BRn L54_tetris
L56_tetris
L51_tetris
	LDR R7, R5, #-4
	ADD R7, R7, #-1
	STR R7, R5, #-4
	LDR R7, R5, #-4
	CONST R3, #0
	CMP R7, R3
	BRzp L50_tetris
L49_tetris
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;print_num;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
print_num
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-6	;; allocate stack space for local variables
	;; function body
	LDR R7, R5, #3
	CONST R3, #0
	CMP R7, R3
	BRnp L72_tetris
	LEA R7, L74_tetris
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	JMP L73_tetris
L72_tetris
	CONST R7, #6
	ADD R6, R6, #-1
	STR R7, R6, #0
	ADD R7, R5, #-6
	ADD R6, R6, #-1
	STR R7, R6, #0
	LDR R7, R5, #3
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_utoa
	ADD R6, R6, #3	;; free space for arguments
	ADD R7, R5, #-6
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	LEA R7, L75_tetris
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
L73_tetris
L71_tetris
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;main;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
main
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-14	;; allocate stack space for local variables
	;; function body
	CONST R7, #0
	STR R7, R5, #-5
	JSR clear_tetris_array
	ADD R6, R6, #0	;; free space for arguments
	JSR redraw
	ADD R6, R6, #0	;; free space for arguments
	LEA R7, L77_tetris
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	LEA R7, L78_tetris
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	LEA R7, L79_tetris
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	LEA R7, L80_tetris
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	LEA R7, L81_tetris
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	LEA R7, L82_tetris
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	CONST R7, #-1
	STR R7, R5, #-2
	JMP L84_tetris
L83_tetris
	JSR lc4_get_event
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #0	;; free space for arguments
	STR R7, R5, #-1
	LDR R7, R5, #-5
	CONST R3, #0
	CMP R7, R3
	BRnp L86_tetris
	LDR R7, R5, #-1
	CONST R3, #32
	CMP R7, R3
	BRnp L86_tetris
	LEA R7, numTotalRows
	CONST R3, #0
	STR R3, R7, #0
	JSR clear_tetris_array
	ADD R6, R6, #0	;; free space for arguments
	CONST R7, #-1
	STR R7, R5, #-2
	CONST R7, #1
	STR R7, R5, #-5
	LEA R7, L88_tetris
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
L86_tetris
	LDR R7, R5, #-5
	CONST R3, #0
	CMP R7, R3
	BRz L89_tetris
	LDR R7, R5, #-2
	CONST R3, #0
	CMP R7, R3
	BRzp L91_tetris
	CONST R7, #1
	STR R7, R5, #-11
	CONST R7, #0
	STR R7, R5, #-2
	CONST R7, #8
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_rand_power2
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	STR R7, R5, #-12
	CONST R3, #4
	ADD R6, R6, #-1
	STR R3, R6, #0
	JSR lc4_rand_power2
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	STR R7, R5, #-13
	CONST R3, #2
	ADD R6, R6, #-1
	STR R3, R6, #0
	JSR lc4_rand_power2
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	LDR R3, R5, #-12
	LDR R2, R5, #-13
	ADD R3, R3, R2
	ADD R7, R3, R7
	STR R7, R5, #-3
	CONST R7, #4
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_rand_power2
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	STR R7, R5, #-14
	CONST R3, #2
	ADD R6, R6, #-1
	STR R3, R6, #0
	JSR lc4_rand_power2
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	LDR R3, R5, #-14
	ADD R7, R3, R7
	STR R7, R5, #-6
	CONST R7, #4
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_rand_power2
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	STR R7, R5, #-4
	LDR R7, R5, #-3
	ADD R6, R6, #-1
	STR R7, R6, #0
	LDR R7, R5, #-2
	ADD R6, R6, #-1
	STR R7, R6, #0
	LDR R7, R5, #-4
	LDR R3, R5, #-6
	SLL R3, R3, #2
	LEA R2, shapes
	ADD R3, R3, R2
	ADD R7, R7, R3
	LDR R7, R7, #0
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR test_for_collision
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #3	;; free space for arguments
	STR R7, R5, #-7
	LDR R7, R5, #-7
	CONST R3, #0
	CMP R7, R3
	BRz L93_tetris
	CONST R7, #0
	STR R7, R5, #-5
	LEA R7, L95_tetris
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	LEA R7, L96_tetris
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	LEA R7, numTotalRows
	LDR R7, R7, #0
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR print_num
	ADD R6, R6, #1	;; free space for arguments
L93_tetris
L91_tetris
	LDR R7, R5, #-2
	STR R7, R5, #-10
	LDR R7, R5, #-3
	STR R7, R5, #-8
	LDR R7, R5, #-4
	STR R7, R5, #-9
	LDR R7, R5, #-1
	CONST R3, #106
	CMP R7, R3
	BRnp L97_tetris
	LDR R7, R5, #-3
	ADD R7, R7, #-1
	STR R7, R5, #-8
L97_tetris
	LDR R7, R5, #-1
	CONST R3, #107
	CMP R7, R3
	BRnp L99_tetris
	LDR R7, R5, #-3
	ADD R7, R7, #1
	STR R7, R5, #-8
L99_tetris
	LDR R7, R5, #-1
	CONST R3, #97
	CMP R7, R3
	BRnp L101_tetris
	LDR R7, R5, #-4
	ADD R7, R7, #-1
	AND R7, R7, #3
	STR R7, R5, #-9
L101_tetris
	LDR R7, R5, #-1
	CONST R3, #115
	CMP R7, R3
	BRnp L103_tetris
	LDR R7, R5, #-4
	ADD R7, R7, #1
	AND R7, R7, #3
	STR R7, R5, #-9
L103_tetris
	LDR R7, R5, #-1
	CONST R3, #0
	CMP R7, R3
	BRnp L105_tetris
	LDR R7, R5, #-11
	CONST R3, #0
	CMP R7, R3
	BRnp L107_tetris
	LDR R7, R5, #-2
	ADD R7, R7, #1
	STR R7, R5, #-10
L107_tetris
	CONST R7, #0
	STR R7, R5, #-11
L105_tetris
	CONST R7, #0
	ADD R6, R6, #-1
	STR R7, R6, #0
	LDR R7, R5, #-3
	ADD R6, R6, #-1
	STR R7, R6, #0
	LDR R7, R5, #-2
	ADD R6, R6, #-1
	STR R7, R6, #0
	LDR R7, R5, #-4
	LDR R3, R5, #-6
	SLL R3, R3, #2
	LEA R2, shapes
	ADD R3, R3, R2
	ADD R7, R7, R3
	LDR R7, R7, #0
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR draw_shape
	ADD R6, R6, #4	;; free space for arguments
	LDR R7, R5, #-8
	ADD R6, R6, #-1
	STR R7, R6, #0
	LDR R7, R5, #-10
	ADD R6, R6, #-1
	STR R7, R6, #0
	LDR R7, R5, #-9
	LDR R3, R5, #-6
	SLL R3, R3, #2
	LEA R2, shapes
	ADD R3, R3, R2
	ADD R7, R7, R3
	LDR R7, R7, #0
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR test_for_collision
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #3	;; free space for arguments
	STR R7, R5, #-7
	LDR R7, R5, #-7
	CONST R3, #0
	CMP R7, R3
	BRnp L109_tetris
	LDR R7, R5, #-9
	STR R7, R5, #-4
	LDR R7, R5, #-10
	STR R7, R5, #-2
	LDR R7, R5, #-8
	STR R7, R5, #-3
L109_tetris
	LDR R7, R5, #-6
	LEA R3, colors
	ADD R3, R7, R3
	LDR R3, R3, #0
	ADD R6, R6, #-1
	STR R3, R6, #0
	LDR R3, R5, #-3
	ADD R6, R6, #-1
	STR R3, R6, #0
	LDR R3, R5, #-2
	ADD R6, R6, #-1
	STR R3, R6, #0
	LDR R3, R5, #-4
	SLL R7, R7, #2
	LEA R2, shapes
	ADD R7, R7, R2
	ADD R7, R3, R7
	LDR R7, R7, #0
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR draw_shape
	ADD R6, R6, #4	;; free space for arguments
	LDR R7, R5, #-7
	CONST R3, #1
	CMP R7, R3
	BRnp L111_tetris
	LDR R7, R5, #-1
	CONST R3, #0
	CMP R7, R3
	BRnp L111_tetris
	JSR remove_filled_rows
	ADD R6, R6, #0	;; free space for arguments
	CONST R7, #-1
	STR R7, R5, #-2
L111_tetris
L89_tetris
	JSR redraw
	ADD R6, R6, #0	;; free space for arguments
L84_tetris
	JMP L83_tetris
	CONST R7, #0
L76_tetris
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

		.DATA
numTotalRows 		.BLKW 1
		.DATA
cells 		.BLKW 240
		.DATA
L96_tetris 		.STRINGZ "Your score is:\n"
		.DATA
L95_tetris 		.STRINGZ "Game Over\n"
		.DATA
L88_tetris 		.STRINGZ "Game On!\n"
		.DATA
L82_tetris 		.STRINGZ "Press space bar to start\n"
		.DATA
L81_tetris 		.STRINGZ "Press a to rotate counter-clockwise\n"
		.DATA
L80_tetris 		.STRINGZ "Press s to rotate clockwise\n"
		.DATA
L79_tetris 		.STRINGZ "Press k to go right\n"
		.DATA
L78_tetris 		.STRINGZ "Press j to go left\n"
		.DATA
L77_tetris 		.STRINGZ "!!! Welcome to Tetris !!!\n"
		.DATA
L75_tetris 		.STRINGZ "\n"
		.DATA
L74_tetris 		.STRINGZ "0\n"
