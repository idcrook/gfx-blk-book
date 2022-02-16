 
/* C++ Game of Life implementation for any mode for which mode set
   and draw pixel functions can be provided.
   Tested with Borland C++ in the small model. */
#include <stdlib.h>
#include <stdio.h>
#include <iostream.h>
#include <conio.h>
#include <time.h>
#include <dos.h>
#include <bios.h>
#include <mem.h>

#define random(x) (rand() % (x))

#define ON_COLOR  15       // on-cell pixel color
#define OFF_COLOR 0        // off-cell pixel color
#define MSG_LINE  12       // row for text messages
#define GENERATION_LINE 13 // row for generation # display
#define LIMIT_18_HZ  1     // set 1 for maximum frame rate = 18Hz
#define WRAP_EDGES   1     // set to 0 to disable wrapping around
                           // at cell map edges
 
/* cellmap class definition, constructor, copy_cells(), set_cell(),
   clear_cell(), cell_state(), count_neighbors(), and
   next_generation() for fast, hard-wired neighbor count approach.
   Otherwise, the same as Listing 17.1 */

class cellmap {
private:
   unsigned char *cells;
   unsigned int width;
   unsigned int width_in_bytes;
   unsigned int height;
   unsigned int length_in_bytes;
public:
   cellmap(unsigned int h, unsigned int v);
   ~cellmap(void);
   void copy_cells(cellmap &sourcemap);
   void set_cell(unsigned int x, unsigned int y);
   void clear_cell(unsigned int x, unsigned int y);
   int cell_state(int x, int y);
   int count_neighbors(int x, int y);
   void next_generation(cellmap& dest_map);
};

extern void enter_display_mode(void);
extern void exit_display_mode(void);
extern void draw_pixel(unsigned int X, unsigned int Y,
   unsigned int Color);
extern void show_text(int x, int y, char *text);

/* Controls the size of the cell map. Must be within the capabilities
   of the display mode, and must be limited to leave room for text
   display at right. */
unsigned int cellmap_width = 96;
unsigned int cellmap_height = 96;
/* Width & height in pixels of each cell as displayed on screen. */
unsigned int magnifier = 2;

int main()
{
   unsigned int init_length, x, y, seed;
   unsigned long generation = 0;
   char gen_text[80];
   long bios_time, start_bios_time;

   cellmap current_map(cellmap_height, cellmap_width);
   cellmap next_map(cellmap_height, cellmap_width);

   // Get the seed; seed randomly if 0 entered
   cout << "Seed (0 for random seed): ";
   cin >> seed;
   if (seed == 0) seed = (unsigned) time(NULL);

   // Randomly initialize the initial cell map
   cout << "Initializing..." << endl;
   srand(seed);
   init_length = (cellmap_height * cellmap_width) / 2;
   do {
     x = random(cellmap_width);
     y = random(cellmap_height);

      next_map.set_cell(x, y);
   } while (--init_length);
   current_map.copy_cells(next_map); // put init map in current_map

   enter_display_mode();

   // Keep recalculating and redisplaying generations until a key
   // is pressed
   show_text(0, MSG_LINE, "Generation: ");
   start_bios_time = _bios_timeofday(_TIME_GETCLOCK, &bios_time);
   do {
      generation++;
      sprintf(gen_text, "%10lu", generation);
      show_text(1, GENERATION_LINE, gen_text);
      // Recalculate and draw the next generation
      current_map.next_generation(next_map);
      // Make current_map current again
      current_map.copy_cells(next_map);
#if LIMIT_18_HZ
      // Limit to a maximum of 18.2 frames per second,for visibility
      do {
         _bios_timeofday(_TIME_GETCLOCK, &bios_time);
      } while (start_bios_time == bios_time);
      start_bios_time = bios_time;
#endif
   } while (!kbhit());
   getch();    // clear keypress
   exit_display_mode();
   cout << "Total generations: " << generation << "\nSeed: " <<
         seed << "\n";
}

/* cellmap constructor. Pads around cell storage area with 1 extra
   byte, used for handling edge wrapping. */
cellmap::cellmap(unsigned int h, unsigned int w)
{
   width = w;
   width_in_bytes = ((w + 7) / 8) + 2; // pad each side with
                                      // 1 extra byte
   height = h;
   length_in_bytes = width_in_bytes * (h + 2);     // pad top/bottom
                                                   // with 1 extra byte
   cells = new unsigned char[length_in_bytes];     // cell storage
   memset(cells, 0, length_in_bytes);              // clear all cells, to start
}

/* cellmap destructor. */
cellmap::~cellmap(void)
{
   delete[] cells;
}

/* Copies one cellmap's cells to another cellmap. If wrapping is
   enabled, copies edge (wrap) bytes into opposite padding bytes in
   source first, so that the padding bytes off each edge have the
   same values as would be found by wrapping around to the opposite
   edge. Both cellmaps are assumed to be the same size. */
void cellmap::copy_cells(cellmap &sourcemap)
{
   unsigned char *cell_ptr;
   int i;

#if WRAP_EDGES
// Copy left and right edges into padding bytes on right and left
   cell_ptr = sourcemap.cells + width_in_bytes;
   for (i=0; i<height; i++) {
      *cell_ptr = *(cell_ptr + width_in_bytes - 2);
      *(cell_ptr + width_in_bytes - 1) = *(cell_ptr + 1);
      cell_ptr += width_in_bytes;
   }
// Copy top and bottom edges into padding bytes on bottom and top
   memcpy(sourcemap.cells, sourcemap.cells + length_in_bytes -
         (width_in_bytes * 2), width_in_bytes);
   memcpy(sourcemap.cells + length_in_bytes - width_in_bytes,
         sourcemap.cells + width_in_bytes, width_in_bytes);
#endif
   // Copy all cells to the destination
   memcpy(cells, sourcemap.cells, length_in_bytes);
}

/* Turns cell on. x and y are offset by 1 byte down and to the right, to compensate for the
padding bytes around the cellmap. */
void cellmap::set_cell(unsigned int x, unsigned int y)
{
   unsigned char *cell_ptr =
         cells + ((y + 1) * width_in_bytes) + ((x / 8) + 1);

   *(cell_ptr) |= 0x80 >> (x & 0x07);
}

/* Turns cell off. x and y are offset by 1 byte down and to the right,
to compensate for the padding bytes around the cell map. */
void cellmap::clear_cell(unsigned int x, unsigned int y)
{
   unsigned char *cell_ptr =
         cells + ((y + 1) * width_in_bytes) + ((x / 8) + 1);

   *(cell_ptr) &= ~(0x80 >> (x & 0x07));
}

/* Returns cell state (1=on or 0=off). x and y are offset by 1 byte
   down and to the right, to
compensate for the padding bytes around
   the cell map. */
int cellmap::cell_state(int x, int y)
{
   unsigned char *cell_ptr =
         cells + ((y + 1) * width_in_bytes) + ((x / 8) + 1);

   return (*cell_ptr & (0x80 >> (x & 0x07))) ? 1 : 0;
}

/* Counts the number of neighboring on-cells for specified cell. */
int cellmap::count_neighbors(int x, int y)
{
   unsigned char *cell_ptr, mask;
   unsigned int neighbor_count;

   // Point to upper left neighbor
   cell_ptr = cells + ((y * width_in_bytes) + ((x + 7) / 8));
   mask = 0x80 >> ((x - 1) & 0x07);
   // Count upper left neighbor
   neighbor_count = (*cell_ptr & mask) ? 1 : 0;
   // Count left neighbor
   if ((*(cell_ptr + width_in_bytes) & mask)) neighbor_count++;
   // Count lower left neighbor
   if ((*(cell_ptr + (width_in_bytes * 2)) & mask)) neighbor_count++;

   // Point to upper neighbor
   if ((mask >>= 1) == 0) {
      mask = 0x80;
      cell_ptr++;
   }
   // Count upper neighbor
   if ((*cell_ptr & mask)) neighbor_count++;
   // Count lower neighbor
   if ((*(cell_ptr + (width_in_bytes * 2)) & mask))  neighbor_count++;

   // Point to upper right neighbor
   if ((mask >>= 1) == 0) {
      mask = 0x80;
      cell_ptr++;
   }
   // Count upper right neighbor
   if ((*cell_ptr & mask)) neighbor_count++;
   // Count right neighbor
   if ((*(cell_ptr + width_in_bytes) & mask)) neighbor_count++;
   // Count lower right neighbor
   if ((*(cell_ptr + (width_in_bytes * 2)) & mask))  neighbor_count++;

   return neighbor_count;
}

// /* Calculates the next generation of current_map and stores it in
//    next_map. */
// void cellmap::next_generation(cellmap& next_map)
// {
//    unsigned int x, y, neighbor_count;

//    for (y=0; y<height; y++) {
//       for (x=0; x<width; x++) {
//          neighbor_count = count_neighbors(x, y);
//          if (cell_state(x, y) == 1) {
//             if ((neighbor_count != 2) && (neighbor_count != 3)) {
//                next_map.clear_cell(x, y);    // turn it off
//                draw_pixel(x, y, OFF_COLOR);
//             }
//          } else {
//             if (neighbor_count == 3) {
//                next_map.set_cell(x, y);      // turn it on
//                draw_pixel(x, y, ON_COLOR);
//             }
//          }
//       }
//    }
// }

 
/* next_generation(), implemented using fast, all-in-one hard-wired
   neighbor count/update/draw function. Otherwise, the same as
   Listing 17.3. */

/* Calculates the next generation of current_map and stores it in
   next_map. */
void cellmap::next_generation(cellmap& next_map)
{
   unsigned int x, y, neighbor_count;
   unsigned int width_in_bytesX2 = width_in_bytes << 1;
   unsigned char *cell_ptr, *current_cell_ptr, mask, current_mask;
   unsigned char *base_cell_ptr, *row_cell_ptr, base_mask;
   unsigned char *dest_cell_ptr = next_map.cells;

   // Process all cells in the current cellmap
   row_cell_ptr = cells;      // point to upper left neighbor of
                              // first cell in cell map
   for (y=0; y<height; y++) { // repeat for each row of cells
      // Cell pointer and cell bit mask for first cell in row
      base_cell_ptr = row_cell_ptr; // to access upper left neighbor
      base_mask = 0x01;             // of first cell in row
      for (x=0; x<width; x++) {     // repeat for each cell in row
         // First, count neighbors
         // Point to upper left neighbor of current cell
         cell_ptr = base_cell_ptr;  // pointer and bit mask for
         mask = base_mask;          // upper left neighbor
         // Count upper left neighbor
         neighbor_count = (*cell_ptr & mask) ? 1 : 0;
         // Count left neighbor
         if ((*(cell_ptr + width_in_bytes) & mask)) neighbor_count++;
         // Count lower left neighbor
         if ((*(cell_ptr + width_in_bytesX2) & mask))
neighbor_count++;
         // Point to upper neighbor
         if ((mask >>= 1) == 0) {
            mask = 0x80;
            cell_ptr++;
         }
         // Remember where to find the current cell
         current_cell_ptr = cell_ptr + width_in_bytes;
         current_mask = mask;
         // Count upper neighbor
         if ((*cell_ptr & mask)) neighbor_count++;
         // Count lower neighbor
         if ((*(cell_ptr + width_in_bytesX2) & mask))
               neighbor_count++;
         // Point to upper right neighbor
         if ((mask >>= 1) == 0) {
            mask = 0x80;
            cell_ptr++;
         }
         // Count upper right neighbor
         if ((*cell_ptr & mask)) neighbor_count++;
         // Count right neighbor
         if ((*(cell_ptr + width_in_bytes) & mask))  neighbor_count++;
         // Count lower right neighbor
         if ((*(cell_ptr + width_in_bytesX2) & mask))
               neighbor_count++;
         if (*current_cell_ptr & current_mask) {
            if ((neighbor_count != 2) && (neighbor_count != 3)) {
               *(dest_cell_ptr + (current_cell_ptr - cells)) &=
                     ~current_mask;    // turn off cell
               draw_pixel(x, y, OFF_COLOR);
            }
         } else {
            if (neighbor_count == 3) {
               *(dest_cell_ptr + (current_cell_ptr - cells)) |=
                     current_mask;     // turn on cell
               draw_pixel(x, y, ON_COLOR);
            }
         }
         // Advance to the next cell on row
         if ((base_mask >>= 1) == 0) {
            base_mask = 0x80;
            base_cell_ptr++;  // advance to the next cell byte
         }
      }
      row_cell_ptr += width_in_bytes;  // point to start of next row
   }
}