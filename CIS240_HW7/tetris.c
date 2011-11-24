/*
 * Tetris.c : Camillo J. Taylor Nov. 4, 2011
 */

#include "lc4libc.h"

/*
 * #############  DATA STRUCTURES THAT STORE THE GAME STATE ######################
 */

// Number of rows and columns in the tetris array
#define NROWS     15
#define NCOLS     16

#define NSHAPES    7

// Array specifying the configuration of the game pieces - for every shape there are 4 entries
// correspoinding to the 4 possible orientations. Each configuration is captured by a 16 bit field
// where each bit corresponds to a cell. The MSB corresponds to the top left cell, the next bit to the
// cell next to that etc.

lc4uint shapes[NSHAPES][4] = { 
  { 0x0660U, 0x0660U, 0x0660U, 0x0660U},
  { 0xF000U, 0x4444U, 0xF000U, 0x4444U},
  { 0x8E00U, 0x6440U, 0x0E20U, 0x44C0U},
  { 0x2E00U, 0x4460U, 0x0E80U, 0xC440U},
  { 0xC600U, 0x4C80U, 0xC600U, 0x4C80U},
  { 0x6C00U, 0x8C40U, 0x6C00U, 0x8C40U},
  { 0x4E00U, 0x4640U, 0x0E40U, 0x4C40U}
 };

// Each shape has an associated color - these colors are defined in lc4libc.h
lc4uint colors[NSHAPES] = {RED, BLUE, GREEN, YELLOW, ORANGE, CYAN, WHITE};

// This 2D array contains the current state of the tetris array each entry indicates the color
// currently stored in the corresponding block. Zero entries indicate unoccupied blocks.
lc4uint cells[NROWS][NCOLS];
int numTotalRows;


/*
 * ###############################################################################
 */

// Clear the tetris array
void clear_tetris_array ()
{
  int i;
  int j;
  for (i = 0; i < NROWS; i++){
    for (j = 0; j < NCOLS; j++){
      cells[i][j] = 0;
    }
  }
}

/*
 * ################# CODE FOR DRAWING THE SCENE ##########################
 */

//
// Draw the cells on the screen using the lc4_draw_8x8 routine.
// Remember to skip the top 4 rows in the display since a 15x16 array of 8x8 pixel blocks
// will take 120x128 pixels while our display has 124 rows.
//
void draw_cells ()
{
  int i;
  int j;
  for (i = 0; i < NROWS; i++){
    for (j = 0; j < NCOLS; j++){
	lc4_draw_8x8(8*j, (8*i)+4, cells[i][j]);
    }
  }
}

void redraw ()
{
  // This function assumes that PennSim is being run in double buffered mode
  // In this mode we first clear the video memory buffer with lc4_reset_vmem,
  // then draw the scene, then call lc4_blt_vmem to swap the buffer to the screen
  // NOTE that you need to run PennSim with the following command:
  // java -jar PennSim.jar -d

  lc4_reset_vmem();

  draw_cells ();

  lc4_blt_vmem();
}

/*
 * ################# CODE FOR UPDATNG THE GAME STATE ##########################
 */

// Tests whether the pattern specified in the bitvector shape can be drawn without
// collision in the current array. If there is a collision return 1 else return 0.
// This function also tests whether any of the filled cells would be drawn outside
// the bounds of the array which would also be considered a collision.
int test_for_collision (lc4uint shape, int row, int col)
{
  lc4uint mask = 0x8000U; //This is an unsigned int whose msb is a 1
  int r;
  int c;

  // | -> bitwise or
  // & -> bitwise and
  // ^ -> bitwise xor

  // mask  1 0 0 0 >> 0 1 0 0
  // shape 0 1 0 1 -> 0 1 0 1
  // this deals with if it overlaps with any shape
  for (r = row; r < row+4; r++){
    for (c = col; c < col+4; c++){
      if ((shape & mask) > 0){
	if (c >= NCOLS || c < 0){
	  return 1;
	}
	if (r >= NROWS){
	  return 1;
	}
	if (cells[r][c] != 0){
	  return 1;
	}
      }
      mask = mask >> 1;
    }
  }

  return 0;
}

// draw the specified shape into the array - you can assume that you have already
// called test_for_collision so there shouldn't be any illegal memory accesses.
void draw_shape (lc4uint shape, int row, int col, lc4uint color)
{
  lc4uint mask = 0x8000U; //This is an unsigned int whose msb is a 1
  int r;
  int c;
  lc4uint shapeColor = color;

  // | -> bitwise or
  // & -> bitwise and
  // ^ -> bitwise xor

  // mask  1 0 0 0 >> 0 1 0 0
  // shape 0 1 0 1 -> 0 1 0 1
  for (r = row; r < row+4; r++){
    for (c = col; c < col+4; c++){
      if ((shape & mask) > 0){
	cells[r][c] = shapeColor;
      }
      mask = mask >> 1;
    }
  }
}

// Iterate through the tetris array from bottom to top removing any rows that
// are completely filled.
void remove_filled_rows ()
{

  /// go back and follow pseudocode.
  int r, r2, c, c2;

  for (r = NROWS - 1; r >= 0; r = r - 1){
    for (c = 0; c < NCOLS; c++){
      // if there is an empty column in this row, break out of the column loop
      // because the row is clearly not full
      if (cells[r][c] == 0){
	break;
      }

      // if we're at the last column and we haven't broken out of the loop yet,
      // set isFull to TRUE
      if (c == NCOLS - 1){
	// the row is full!
	numTotalRows++;
	r2 = r - 1; // set r2 to current row - 1
	while (r2 >= 0){
	  for (c2 = 0; c2 < NCOLS; c2++){
	    if (cells[r2+1][c2] == 0 && cells[r2][c2] == 0){
	      continue;
	    }
	    else{
	      cells[r2+1][c2] = cells[r2][c2];
	    }
	  }
	  r2 = r2 - 1;
	}
	r = r+1; //(don't increase r)
      }
    }
  }
}


/*
 * new code
 */

void print_num(lc4uint num)
{
  // Max value of num is 2**16-1=65535 which has 5 characters + 1 for null
  // Don't need space for minus sign, because number is unsigned
  char s[6];
  if (num == 0) {
    lc4_puts((lc4uint*)"0\n");
  } else {
    lc4_utoa(num, s, 6);
    lc4_puts((lc4uint*)s);
    lc4_puts((lc4uint*)"\n");
  }
}

/*
 * ############################### MAIN FUNCTION #############################
 */


int main ()
{
  lc4uint event, collision;
  int game_started = 0;   // game mode
  int row, col, shape_idx, orientation;
  int new_row, new_col, new_orientation;
  int isNewShape;

  clear_tetris_array ();
  redraw ();

  lc4_puts ((lc4uint*)"!!! Welcome to Tetris !!!\n");
  lc4_puts ((lc4uint*)"Press j to go left\n");
  lc4_puts ((lc4uint*)"Press k to go right\n");
  lc4_puts ((lc4uint*)"Press s to rotate clockwise\n");
  lc4_puts ((lc4uint*)"Press a to rotate counter-clockwise\n");
  // lc4_puts ((lc4uint*)"Press , to move down\n");
  lc4_puts ((lc4uint*)"Press space bar to start\n");

  row = -1;

  // MAIN LOOP
  while (1) {

    event = lc4_get_event();

    if (!game_started && event == 0x00020){ // event == spacebar
      numTotalRows = 0;
      clear_tetris_array();
      row = -1;
      game_started = TRUE;
      lc4_puts ((lc4uint*)"Game On!\n");
    }

    if (game_started){

      // if the row is less than 0
      if (row < 0){
	isNewShape = TRUE;
	row = 0;
	col = lc4_rand_power2(8) + lc4_rand_power2(4) + lc4_rand_power2(2); // (0-7) + (0-3) + (0-1) = min 0, max 11
	shape_idx = lc4_rand_power2(4) + lc4_rand_power2(2); // min 0, max 6
	orientation = lc4_rand_power2(4); // min 0, max 3

	collision = test_for_collision(shapes[shape_idx][orientation], row, col); // test for collision
	if (collision){
	  game_started = FALSE;
	  lc4_puts ((lc4uint*)"Game Over\n");
	  lc4_puts ((lc4uint*)"Your score is:\n");
	  print_num(numTotalRows);
	}
      }

      // if row > 0 jump here immediately
      
      // initialize new states to old states
      new_row = row;
      new_col = col;
      new_orientation = orientation;

      // handle keyboard presses
      if (event == 0x0006A){ // the letter j
	new_col = col - 1;
      }
      if (event == 0x0006B){ // the letter k
	new_col = col + 1;
      }
      if (event == 0x00061){ // the letter a
	new_orientation = (orientation - 1) & 0x3;
      }
      if (event == 0x00073){ // the letter s
	new_orientation = (orientation + 1) & 0x3;
      }

      // if event == timer, row + 1
      if (event == 0){
        if (!isNewShape){
	  new_row = row + 1;
	}
	isNewShape = FALSE;
      }

      // clear out current shape
      draw_shape (shapes[shape_idx][orientation], row, col, BLACK);
      
      // check if the new state is feasible
      collision = test_for_collision(shapes[shape_idx][new_orientation], new_row, new_col);

      // if there is no collision:
      if (collision == FALSE){
        orientation = new_orientation;
        row = new_row;
        col = new_col;
      }

      draw_shape(shapes[shape_idx][orientation], row, col, colors[shape_idx]);

      // if there was a collision and event == timer
      if (collision == TRUE && event == 0){
        remove_filled_rows();
        row = -1; //new piece will be generated on next iteration
      }
    }
    redraw();
  }

  return 0;
}

