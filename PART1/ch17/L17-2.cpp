 
/* VGA mode 13h functions for Game of Life.
   Tested with Borland C++. */
#include <stdio.h>
#include <conio.h>
#include <graph.h>
#include <dos.h>

#define TEXT_X_OFFSET   27
#define SCREEN_WIDTH_IN_BYTES 320
#define DEBUG_LINE  10

/* Width & height in pixels of each cell. */
extern unsigned int magnifier;

#define SCREEN_SEGMENT  0xA000
#define SCREEN_IOADDR  0xA0000
#define SCREEN_MEMADDR_32BIT  0xA0000L
#define SCREEN_MEMADDR_16BIT  0xA0000000L

// We are using 16-BIT compiler (FAR required for these raw pointer types)
typedef unsigned char  far byte;
typedef unsigned short far word;
//byte *VGA=(byte *)0xA0000000L;        /* this points to video memory. */

/* Mode 13h draw pixel function. Pixels are of width & height
   specified by magnifier. */
void draw_pixel(unsigned int x, unsigned int y, unsigned int color)
{
   byte *VGA=(byte *)0xA0000000L; 
   ///static byte *VGA=(byte *)0xA0000000L;        /* this points to video memory. */

   unsigned short offset = (y*SCREEN_WIDTH_IN_BYTES+x)*magnifier;
   byte *scr_ptr = VGA;
   byte colr = color;
   scr_ptr += offset;
   if (magnifier == 2) {
      // VGA[(y*SCREEN_WIDTH_IN_BYTES+x)*2]=color;
      // VGA[(y*SCREEN_WIDTH_IN_BYTES+x)*2 + 1]=color; // x+1
      // VGA[(y*SCREEN_WIDTH_IN_BYTES+x)*2 + SCREEN_WIDTH_IN_BYTES]=color; // y+1
      // VGA[(y*SCREEN_WIDTH_IN_BYTES+x)*2 + 1 + SCREEN_WIDTH_IN_BYTES]=color; // x+1, y+1
      // VGA[offset]=color;
      // VGA[offset + 1]=color; // x+1
      // VGA[offset2]=color; // y+1
      // VGA[offset2 + 1]=color; // x+1, y+1      
      *scr_ptr = colr;
      scr_ptr[1] = colr;
      scr_ptr += SCREEN_WIDTH_IN_BYTES;
      *scr_ptr = colr;
      scr_ptr[1] = colr;
   } else {
      VGA[offset]=color;      
   } 
}


/* Mode 13h mode-set function. */
void enter_display_mode()
{
   union REGS regset;

   //regset.x.ax = 0x0013;
   regset.w.ax = 0x0013;

   int86(0x10, &regset, &regset);
}

/* Text mode mode-set function. */
void exit_display_mode()
{
   union REGS regset;

   //regset.x.ax = 0x0003;
   regset.w.ax = 0x0003;
   int86(0x10, &regset, &regset);
}

/* Text display function. Offsets text to non-graphics area of
   screen. */
void show_text(int x, int y, char *text)
{
   //gotoxy(TEXT_X_OFFSET + x, y);
   _settextposition(y, 1 + TEXT_X_OFFSET + x);
   //_settextposition(TEXT_X_OFFSET + x, y);
   puts(text);
   //_outtext(text);
}
