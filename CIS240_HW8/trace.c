/** 
 * First .c file for PennSim homework assignment.
 * CIS240, Fall 2011, Catherine Hu
*/

#include <stdio.h>
#include <stdlib.h>
#include <netinet/in.h>
#include "parse.h"
//#include "ppm.h"

unsigned short lastPC;

void memoryInit(unsigned short* buffer, unsigned short* memory, int buffSize){

  int pc = 0;
  int selectSize = 0;
  int lineNum;
  int fileIndex;
  int i = 0;

  while (i < buffSize) {
    
    int value = buffer[i];

    // if the value indicates code
    if (value == 0xCADE){
      i++;
      pc = buffer[i];
      i++;
      selectSize = buffer[i];
      for (int c = 0; c < selectSize; c++){
	i++;
	memory[pc++] = buffer[i];
      }
    }

    // if the value indicates data
    else if (value == 0xDADA){
      i++;
      pc = buffer[i];
      i++;
      selectSize = buffer[i];
      for (int c = 0; c < selectSize; c++){
	i++;
	memory[pc++] = buffer[i];
      }
    }

    // if the value indicates symbol
    else if (value == 0xC3B7){
      i++;
      pc = buffer[i];
      i++;
      selectSize = buffer[i];
      selectSize = (selectSize+1)/2;
      for (int c = 0; c < selectSize; c++){
	i++;
      }
    }

    // if the value indicates file name
    else if (value == 0xF17E){
      i++;
      selectSize = buffer[i];
      selectSize=(selectSize+1)/2;
      pc++;
      for (int c = 0; c < selectSize; c++){
	i++;
      }
    }

    // if the value indicates linenumber
    else if (value == 0x715E){
      i++;
      pc = buffer[i];
      i++;
      lineNum = buffer[i];
      i++;
      fileIndex = buffer[i];
    }
    i++;
  }
}

/**
 * After the memory array has been initialized, run executeParse to parse
 * through the instructions.
 **/
void executeParse(unsigned short* mem, signed short* reg, unsigned short nextPC, FILE* file){
  unsigned short pc = nextPC; // initialize PC

  while (pc != lastPC){
    if (reg[10] == 0){
      //      printf("current pc: %d\n", pc);
      //printf("R0: %X, R1: %X, R2: %X, R3: %X, R4: %X, R5: %X, R6: %X, R7: %X\n", reg[0], reg[1], reg[2], reg[3], reg[4], reg[5], reg[6], reg[7]);
      fwrite(&pc, 2, 1, file);
      fwrite(&mem[pc], 2, 1, file);
      pc = parseInstruction(pc, mem, reg, mem[pc]);
    }
    else
      break;
  }

  // parse last instruction
  if (reg[10] == 0){
    //printf("current pc: %d\n", pc);
    fwrite(&pc, 2, 1, file);
    fwrite(&mem[pc], 2, 1, file);
    parseInstruction(pc, mem, reg, mem[pc]);
  }
}


/**
 * The main method.
 */
int main(int argc, const char* argv[]){
  int numArgs;
  unsigned short* buffer;
  long fileSize;
  unsigned short* memory; // xFFFF in decimal is 655350
  signed short* other; // for registers R0 - R7, PSR, NZP, halt check
  FILE *objectFile;
  FILE *outputFile;

  if (argc < 4){
    fprintf(stderr, "Not enough arguments. Please try again.\n");
    exit(6);
  }
  
  // malloc spaces for memory, registers, etc
  memory = (unsigned short*)malloc(0xFFFF*sizeof(unsigned short));
  if (memory == NULL) {printf("malloc failed"); exit(3);}
  other = (signed short*)malloc(11*sizeof(signed short));
  if (other == NULL) {printf("malloc failed"); exit(4);}
  
  for(int i = 0; i < 0xFFFF; i++)
    memory[i] = 0;
  for(int i = 0; i < 11; i++)
    other[i] = 0;

  other[8] = 0x2; // set PSR to 0x2
  other[9] = 0x2; // set NZP to 0x2, or Z
  lastPC = (unsigned short)atoi(argv[2]);
  //printf("lastPC: %X\n", lastPC);

  // cycle through object files, initialize them into memory
  for (numArgs = 3; numArgs < argc; numArgs++){
    //    printf("Entered loop again\n");
    objectFile = fopen(argv[numArgs],"rb");
    if (objectFile == NULL) {printf("File error"); exit(1);}
    
    // get file size
    fseek(objectFile, 0, SEEK_END);
    fileSize = ftell(objectFile);
    rewind(objectFile);

    // adjust file size
    fileSize = (fileSize/2)+1;

    // allocate memory for buffer, memory and registers
    buffer = (unsigned short*) malloc (sizeof(unsigned short)*fileSize);
    if (buffer == NULL) {printf("malloc failed"); exit(2);}

    // read from the file into the buffer, 2 bytes at a time, fileSize number of times
    fread(buffer,2,fileSize,objectFile);

    // fix endianness
    for (int k = 0; k < fileSize; k++){
      buffer[k] = htons(buffer[k]);
    }

    // initialize/fill simulated memory    
    memoryInit(buffer,memory,fileSize);
    free(buffer);
  }

  outputFile = fopen(argv[1],"wb");
  if (outputFile == NULL) {printf("Output file error"); exit(5);}
  executeParse(memory, other, 0, outputFile);
  
  /**  // print the memory array: FOR DEBUGGING
  for (int x = 0; x < 0xFFFF; x++){
    if (memory[x] != 0){
      printf("Index %X: %X\n", x, memory[x]);
    }
  }
  */

  //    ppm_write("image.ppm", &memory[0xC000], "b");
    
  // close the file
  fclose(objectFile);
  fclose(outputFile);
  free(memory);
  free(other);
  return 0;
}
