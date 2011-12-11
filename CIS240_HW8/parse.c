/** 
 * This class parses a given instruction and returns values accordingly.
 * CIS240, Fall 2011
 * Catherine Hu
 **/

#include <stdio.h>
#include <stdlib.h>
#include "parse.h"


/**
 * function to set NZP bits
 */

int setNZP(short x){
  if (x > 0)
    return 0x1;
  else if (x == 0)
    return 0x2;
  else // x < 0
    return 0x4;
}

/**
 * function for parsing a single instruction
 * returns next pc
 **/
unsigned short parseInstruction(unsigned short pc, unsigned short* mem, signed short* reg, unsigned short instruction){
  
  unsigned short programC = pc;
  unsigned short psr = (unsigned short)reg[8];

  /**
   * These are errors with accessing data, or OS code without the privilege bit
   */
  if (psr != 0x8000){
    if (programC > 0x1FFF){
      printf("IllegalMemAccessException accessing address %X with privilege false\n", programC);
      reg[10] = 1;
      return 0;
    }
  }
  else{
    if ((0x1FFF < programC) && (0x8000 > programC)){
      printf("IllegalMemAccessException accessing address %X with privilege true\n", programC);
      reg[10] = 1;
      return 0;
    }
    else if (programC > 0x9FFF){
      printf("IllegalMemAccessException accessing address %X with privilege true\n", programC);
      reg[10] = 1;
      return 0;
    }
  }

  unsigned short instr = instruction;
  unsigned short op = INSN_OP(instr);
  unsigned short subop, sub, rd, rs, rt, nzp;
  signed short imm11, imm9, imm7, imm6, imm5;
  unsigned short uimm8, uimm7, uimm4;

  switch(op)
  {
    case 0: //0000 - BRANCH INSTRUCTION
      //      printf("Branch instruction\n");
      subop = INSN_12_10(instr);
      imm9 = SEXT_9(INSN_9IMM(instr));
      nzp = reg[9];
      switch(subop)
	{
	case 0: // NOP
	  //  printf("NOP\n");
	  programC++;
	  break;

	case 4: // BRn
	  // printf("BRn\n");
	  if (nzp == 0x4)
	    programC = programC + 1 + imm9;
	  else
	    programC++;
	  break;

	case 6: // BRnz
	  // printf("BRnz\n");
	  if (nzp == 0x4 || nzp == 0x2)
	    programC = programC + 1 +imm9;
	  else
	    programC++;
	  break;

	case 5: // BRnp
	  //printf("BRnp\n");
	  if (nzp == 0x4 || nzp == 0x1){
	    programC = programC + 1 + imm9;
	    //printf("programC: %X", programC);
	  }
	  else
	    programC++;
	  break;

	case 2: // BRz
	  //printf("BRz\n");
	  if (nzp == 0x2)
	    programC = programC + 1 + imm9;
	  else
	    programC++;
	  break;

	case 3: // BRzp
	  //printf("BRzp\n");
	  if (nzp == 0x2 || nzp == 0x1)
	    programC = programC + 1 + imm9;
	  else
	    programC++;
	  break;

	case 1: // BRp
	  //printf("BRp\n");
	  if (nzp == 0x1)
	    programC = programC + 1 + imm9;
	  else
	    programC++;
	  break;

	case 7: // BRnzp
	  // printf("BRnzp\n");
	  programC = programC + 1 + imm9;
	  break;
	}
      break;

    case 1: //0001 - ARITHMETIC INSTRUCTION
      //printf("Arithmetic instruction\n");
      
      // check 6th bit
      sub = INSN_6(instr);
      switch (sub)
	{
	case 0: // no immediate
	  subop = INSN_6_4(instr);
	  rd = INSN_12_10(instr);
	  rs = INSN_9_7(instr);
	  rt = INSN_3_1(instr);
	  switch (subop)
	    {
	    case 0: // ADD Rd, Rs, Rt
	      //      printf("ADD\n");
	      reg[rd] = reg[rs] + reg[rt];
	      reg[9] = setNZP(reg[rd]);
	      break;
	    case 1: // MUL Rd, Rs, Rt
	      //printf("MUL\n");
	      reg[rd] = reg[rs] * reg[rt];
	      reg[9] = setNZP(reg[rd]);
	      break;
	    case 2: // SUB Rd, Rs, Rt
	      //printf("SUB\n");
	      reg[rd] = reg[rs] - reg[rt];
	      reg[9] = setNZP(reg[rd]);
	      break;
	    case 3: // DIV Rd, Rs, Rt
	      //printf("DIV\n");
	      if ((unsigned short)reg[rt] == 0)
		reg[rd] = 0;
	      else
		reg[rd] = (unsigned short)reg[rs] / (unsigned short)reg[rt];
	      reg[9] = setNZP(reg[rd]);
	      break;
	    }
	  break;

	case 1: // ADD Rd, Rs, IMM5
	  //printf("ADDI\n");
	  imm5 = SEXT_5(INSN_5IMM(instr));
	  rd = INSN_12_10(instr);
	  rs = INSN_9_7(instr);
	  reg[rd] = reg[rs] + imm5;
	  reg[9] = setNZP(reg[rd]);
	  break;
	}
      programC++;
      break;

    case 2: //0010 - COMPARE INSTRUCTION
      //printf("Compare instruction\n");
      
      //check 8-9th bits
      subop = INSN_9_8(instr);
      switch(subop)
	{
	case 0: // CMP Rs, Rt
	  // printf("CMP\n");
	  rs = INSN_12_10(instr);
	  rt = INSN_3_1(instr);
	  reg[9] = setNZP(reg[rs] - reg[rt]);
	  break;

	case 1: // CMPU Rs, Rt
	  //printf("CMPU\n");
	  rs = INSN_12_10(instr);
	  rt = INSN_3_1(instr);
	  reg[9] = setNZP((unsigned short)reg[rs] - (unsigned short)reg[rt]);
	  break;

	case 2: // CMPI Rs, IMM7
	  //printf("CMPI\n");
	  imm7 = SEXT_7(INSN_7IMM(instr));
	  rs = INSN_12_10(instr);
	  reg[9] = setNZP(reg[rs] - imm7);
	  break;

	case 3: // CMPIU Rs, UIMM7
	  //printf("CMPIU\n");
	  uimm7 = INSN_7IMM(instr);
	  rs = INSN_12_10(instr);
	  reg[9] = setNZP((unsigned short)reg[rs] - uimm7);
	  break;
	}
      programC++;
      break;

    case 4: //0100 - JSR/JSRR
      // printf("JSR/JSRR instruction\n");
      
      //check 12th bit
      subop = INSN_12(instr);
      switch(subop)
	{
	case 1: // JSR IMM11
	  //  printf("JSR\n");
	  reg[7] = programC + 1;
	  imm11 = INSN_11IMM(instr);
	  programC = ((programC & 0x8000) | (imm11 << 4));
	  break;
	
	case 0: // JSRR Rs
	  //printf("JSRR\n");
	  reg[7] = programC + 1;
	  programC = INSN_9_7(instr);
	  break;
	}
      break;

    case 5: //0101 - LOGICAL OP INSTRUCTION
      //printf("Logical op instruction\n");

      //check 6th bit
      sub = INSN_6(instr);
      switch(sub)
	{
	case 0:
	  //check 4-6th bits
	  subop = INSN_6_4(instr);
	  switch (subop)
	    { 
	    case 0: // AND Rd, Rs, Rt
	      //      printf("AND\n");
	      rd = INSN_12_10(instr);
	      //printf("rd: %X", rd);
	      rs = INSN_9_7(instr);
	      rt = INSN_3_1(instr);
	      reg[rd] = (reg[rs] & reg[rt]);
	      reg[9] = setNZP(reg[rd]);
	      break;
	    
	    case 1: // NOT R1, R2
	      //printf("NOT\n");
	      rd = INSN_12_10(instr);
	      //printf("rd: %X", rd);
	      rs = INSN_9_7(instr);
    	      reg[rd] = ~(reg[rs]);
	      break;
	    
	    case 2: // OR R1, R2, R3
	      //printf("OR\n");
	      rd = INSN_12_10(instr);
	      //printf("rd: %X", rd);
	      rs = INSN_9_7(instr);
    	      rt = INSN_3_1(instr);
	      reg[rd] = (reg[rs] | reg[rt]);
	      reg[9] = setNZP(reg[rd]);
	      break;
	    
	    case 3: // XOR R1, R2, R3
	      //printf("XOR\n");
	      rd = INSN_12_10(instr);
	      //printf("rd: %X", rd);
	      rs = INSN_9_7(instr);
    	      rt = INSN_3_1(instr);
	      //printf("rt: %X", rt);
	      reg[rd] = ((reg[rs]) ^ (reg[rt]));
	      reg[9] = setNZP(reg[rd]);
	      break;
	    }
	  break;

	case 1: // AND Rd, Rs, IMM5
	  //printf("ANDI\n");
	  rd = INSN_12_10(instr);
	  rs = INSN_9_7(instr);
	  imm5 = SEXT_5(INSN_5IMM(instr));
	  reg[rd] = (reg[rs] & imm5);
	  reg[9] = setNZP(reg[rd]);
	  break;
	}
      programC++;
      break;

    case 6: //0110 - LOAD INSTRUCTION
      //printf("LDR instruction\n");
      rd = INSN_12_10(instr);
      rs = INSN_9_7(instr);
      imm6 = SEXT_6(INSN_6IMM(instr));
      unsigned short addrLDR = (unsigned short)reg[rs] + imm6;

      if ((unsigned short)reg[8] == 0x8000){ // if the privilege bit is true
	if (addrLDR < 0x2000){
	  printf("IllegalMemAccessException accessing address %X with privilege true\n", addrLDR);
	  reg[10] = 1;
	  return 0;
	}
	else if ((addrLDR > 0x7FFF) && (addrLDR < 0xA000)){
	  printf("IllegalMemAccessException accessing address %X with privilege true\n", addrLDR);
	  reg[10] = 1;
	  return 0;
	}
      }

      else{ // if the privilege bit is false
	if ((addrLDR < 0x2000) || (addrLDR > 0x7FFF)){
	  printf("IllegalMemAccessException accessing address %X with privilege false\n", addrLDR);
	  reg[10] = 1;
	  return 0;
	}
      }

      reg[rd] = mem[(unsigned short)reg[rs] + imm6];
      programC++;
      break;

    case 7: //0111 - STORE INSTRUCTION
      //printf("STR instruction\n");
      rd = INSN_12_10(instr);
      rs = INSN_9_7(instr);
      imm6 = SEXT_6(INSN_6IMM(instr));
      unsigned short addrSTR = (unsigned short)reg[rs] + imm6;
      //printf("psr = %X", reg[8]);
      
      if ((unsigned short)reg[8] == 0x8000){ // if the privilege bit is true
	if (addrSTR < 0x2000){
	  printf("IllegalMemAccessException accessing address %X with privilege true\n", addrSTR);
	  reg[10] = 1;
	  return 0;
	}
	else if ((addrSTR > 0x7FFF) && (addrSTR < 0xA000)){
	  printf("IllegalMemAccessException accessing address %X with privilege true\n", addrSTR);
	  reg[10] = 1;
	  return 0;
	}
      }

      else{ // if the privilege bit is false
	if ((addrSTR < 0x2000) || (addrSTR > 0x7FFF)){
	  printf("IllegalMemAccessException accessing address %X with privilege false\n", addrSTR);
	  reg[10] = 1;
	  return 0;
	}
      }

      if (programC < 0x2000){
	if (addrSTR > 0x7FFF){
	  printf("IllegalMemAccessException accessing address %X\n", addrSTR);
	  reg[10] = 1;
	  return 0;
	}
      }

      mem[(unsigned short)reg[rs] + imm6] = reg[rd];
      programC++;
      break;

    case 8: //1000 - RTI
      //printf("RTI\n");
      programC = reg[7];
      reg[8] = 0x0;
      break;

    case 9: //1001 - CONST
      //printf("CONST\n");
      rd = INSN_12_10(instr);
      imm9 = SEXT_9(INSN_9IMM(instr));
      reg[rd] = imm9;
      reg[9] = setNZP(reg[rd]);
      programC++;
      break;

    case 10: //1010 - SHIFT AND MOD
      //printf("Shift and mod instructions\n");
      // grab 5-6th bits
      subop = INSN_6_5(instr);
      switch(subop)
	{
	case 0: // SLL Rd, Rs, UIMM4
	  rd = INSN_12_10(instr);
	  rs = INSN_9_7(instr);
	  uimm4 = INSN_4IMM(instr);
	  reg[rd] = reg[rs] << uimm4;
	  reg[9] = setNZP(reg[rd]);
	  break;

	case 1: // SRA Rs, Rs, UIMM4
	  rd = INSN_12_10(instr);
	  rs = INSN_9_7(instr);
	  uimm4 = INSN_4IMM(instr);
	  reg[rd] = reg[rs] >> uimm4;
	  reg[9] = setNZP(reg[rd]);
	  break;

	case 2: // SRL Rd, Rs, UIMM4
	  rd = INSN_12_10(instr);
	  rs = INSN_9_7(instr);
	  uimm4 = INSN_4IMM(instr);
	  reg[rd] = (unsigned short)(reg[rs]) >> uimm4;
	  break;

	case 3: // MOD Rd, Rs, Rt
	  rd = INSN_12_10(instr);
	  rs = INSN_9_7(instr);
	  rt = INSN_3_1(instr);
	  if ((unsigned short)reg[rt] == 0)
	    reg[rd] = 0;
	  else
	    reg[rd] = (unsigned short)(reg[rs]) %  (unsigned short)(reg[rt]);
	  reg[9] = setNZP(reg[rd]);
	  break;
	}
      break;

    case 12: //1100 - JMP/JMPR
      //printf("JMP/JMPR instructions\n");
      // grab 12th bit
      subop = INSN_12(instr);
      switch(subop)
	{
	case 0: // JMPR Rs
	  rs = INSN_9_7(instr);
	  programC = reg[rs];
	  break;
	
	case 1: // JMP IMM11
	  imm11 = SEXT_11(INSN_11IMM(instr));
	  programC = programC + 1 + imm11;
	  break;
	}
      break;

    case 13: //1101 - HICONST
      //printf("HICONST instruction\n");
      rd = INSN_12_10(instr);
      uimm8 = INSN_8IMM(instr);
      reg[rd] = ((reg[rd] & 0xFF) | (uimm8 << 8));
      reg[9] = setNZP(reg[rd]);
      programC++;
      break;

    case 15: //1111 - TRAP
      //printf("TRAP instruction\n");
      reg[7] = programC+1;
      uimm8 = INSN_8IMM(instr);
      programC = (0x8000|uimm8);
      reg[8] = 0x8000;
      break;

    default:
      printf("Invalid opcode");
  }

  return programC;
}
