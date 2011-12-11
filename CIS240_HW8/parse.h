/*
 * Header file for parse.c
 */

#ifndef PARSE_H
#define PARSE_H


/**
 * Macros for grabbing bits 3 at a time
 **/
#define INSN_OP(I) ((I) >> 12) // grab the opcode (13-16)
#define INSN_12_10(I) (((I) >> 9) & 0x7) // grab bits 10-12
#define INSN_9_7(I) (((I) >> 6) & 0x7) // grab bits 7-9
#define INSN_6_4(I) (((I) >> 3) & 0x7) // grab bits 4-6
#define INSN_3_1(I) ((I) & 0x7) // grab bits 1-3

/**
 * Macros useful for grabbing single bits 
 **/
#define INSN_12(I) (((I) >> 11) & 0x1) // grab 12th bit
#define INSN_9(I) (((I) >> 8) & 0x1) // grab 9th bit
#define INSN_6(I) (((I) >> 5) & 0x1) // grab 6th bit

/** 
 * Macros for grabbing bits 2 at a time
 **/
#define INSN_9_8(I) (((I) >> 7) & 0x3) // grab 8-9th bits
#define INSN_6_5(I) (((I) >> 4) & 0x3) // grab 5-6th bits

/**
 * Macros for long immediates
 **/
#define INSN_4IMM(I) ((I) & 0xF) // IMM4 or UIMM
#define INSN_5IMM(I) ((I) & 0x1F) // IMM5 or UIMM
#define INSN_6IMM(I) ((I) & 0x3F) // IMM6 or UIMM
#define INSN_7IMM(I) ((I) & 0x7F) // IMM7 or UIMM
#define INSN_8IMM(I) ((I) & 0xFF) // IMM8 or UIMM
#define INSN_9IMM(I) ((I) & 0x1FF) // IMM9 or UIMM
#define INSN_11IMM(I) ((I) & 0x7FF) // IMM11 or UIMM

/**
 * Macro for sign extension
 **/
#define SEXT_5(Y) (((signed short)((Y) << 11)) >> 11)
#define SEXT_6(Y) (((signed short)((Y) << 10)) >> 10)
#define SEXT_7(Y) (((signed short)((Y) << 9)) >> 9)
#define SEXT_9(Y) (((signed short)((Y) << 7)) >> 7)
#define SEXT_11(Y) (((signed short)((Y) << 5)) >> 5)

int setNZP(short x);
unsigned short parseInstruction(unsigned short pc, unsigned short* mem, signed short* reg, unsigned short instruction);

#endif
