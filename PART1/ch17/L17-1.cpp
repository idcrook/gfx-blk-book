 
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

/* cellmap constructor. */
cellmap::cellmap(unsigned int h, unsigned int w)
{
   width = w;
   width_in_bytes = (w + 7) / 8;
   height = h;
   length_in_bytes = width_in_bytes * h;
   cells = new unsigned char[length_in_bytes];  // cell storage
   memset(cells, 0, length_in_bytes);  // clear all cells, to start
}

/* cellmap destructor. */
cellmap::~cellmap(void)
{
   delete[] cells;
}

/* Copies one cellmap's cells to another cellmap. Both cellmaps are
   assumed to be the same size.  */
void cellmap::copy_cells(cellmap &sourcemap)
{
   memcpy(cells, sourcemap.cells, length_in_bytes);
}

/* Turns cell on. */
void cellmap::set_cell(unsigned int x, unsigned int y)
{
   unsigned char *cell_ptr =
         cells + (y * width_in_bytes) + (x / 8);

   *(cell_ptr) |= 0x80 >> (x & 0x07);
}

/* Turns cell off. */
void cellmap::clear_cell(unsigned int x, unsigned int y)
{
   unsigned char *cell_ptr =
         cells + (y * width_in_bytes) + (x / 8);

   *(cell_ptr) &= ~(0x80 >> (x & 0x07));
}

/* Returns cell state (1=on or 0=off), optionally wrapping at the
   borders around to the opposite edge. */
int cellmap::cell_state(int x, int y)
{
   unsigned char *cell_ptr;

#if WRAP_EDGES
   while (x < 0) x += width;     // wrap, if necessary
   while (x >= width) x -= width;
   while (y < 0) y += height;
   while (y >= height) y -= height;
#else
   if ((x < 0) || (x >= width) || (y < 0) || (y >= height))
      return 0;   // return 0 for off edges if no wrapping
#endif
   cell_ptr = cells + (y * width_in_bytes) + (x / 8);
   return (*cell_ptr & (0x80 >> (x & 0x07))) ? 1 : 0;
}

/* Calculates the next generation of a cellmap and stores it in
   next_map. */
void cellmap::next_generation(cellmap& next_map)
{
   unsigned int x, y, neighbor_count;

   for (y=0; y<height; y++) {
      for (x=0; x<width; x++) {
         // Figure out how many neighbors this cell has
         neighbor_count = cell_state(x-1, y-1) + cell_state(x, y-1) +
               cell_state(x+1, y-1) + cell_state(x-1, y) +
               cell_state(x+1, y) + cell_state(x-1, y+1) +
               cell_state(x, y+1) + cell_state(x+1, y+1);
         if (cell_state(x, y) == 1) {
            // The cell is on; does it stay on?
            if ((neighbor_count != 2) && (neighbor_count != 3)) {
               next_map.clear_cell(x, y);    // turn it off
               draw_pixel(x, y, OFF_COLOR);
            }
         } else {
            // The cell is off; does it turn on?
            if (neighbor_count == 3) {
               next_map.set_cell(x, y);      // turn it on
               draw_pixel(x, y, ON_COLOR);
            }
         }
      }
   }
}