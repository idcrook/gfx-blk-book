 
/* VGA mode 13h functions for Game of Life.
   Tested with Borland C++. */
#include <stdio.h>
#include <conio.h>
#include <graph.h>
#include <dos.h>

#define TEXT_X_OFFSET   26
#define SCREEN_WIDTH_IN_BYTES 320

/* Width & height in pixels of each cell. */
extern unsigned int magnifier;

#define SCREEN_MEMADDR_32BIT  0xA0000L
#define SCREEN_MEMADDR_16BIT  0xA0000000L

// When using 16-BIT compiler FAR required in raw pointer types
typedef unsigned char  byte;
typedef unsigned short word;

#ifdef __WATCOMC__
static inline void just_int86(unsigned char c,union REGS *r1,union REGS *r2) {
# ifdef __386__
    int386(c,r1,r2);
# else
    int86(c,r1,r2);
# endif
}
#endif

/* Mode 13h draw pixel function. Pixels are of width & height
   specified by magnifier. */
void draw_pixel(unsigned int x, unsigned int y, unsigned int color)
{
#ifdef __386__
   byte *VGA=(byte *) (SCREEN_MEMADDR_32BIT); 
#else
   byte *VGA=(byte far *) (SCREEN_MEMADDR_16BIT); 
#endif

   unsigned short offset = ((y*SCREEN_WIDTH_IN_BYTES+x)*magnifier);
   byte *scr_ptr = VGA + offset;

   scr_ptr[0] = color;
   if (magnifier == 2) { 
      scr_ptr[1] = color; // x+1  
      scr_ptr[SCREEN_WIDTH_IN_BYTES+0] = color;  // y+1
      scr_ptr[SCREEN_WIDTH_IN_BYTES+1] = color; // x+1, y+1
   }
}

/* Mode 13h mode-set function. */
void enter_display_mode()
{
   union REGS regset;

   //regset.x.ax = 0x0013;
   regset.w.ax = 0x0013;

   just_int86(0x10, &regset, &regset);

   //_settextposition(1, 1); // rol, col
}

/* Text mode mode-set function. */
void exit_display_mode()
{
   union REGS regset;

   //regset.x.ax = 0x0003;
   regset.w.ax = 0x0003;
   just_int86(0x10, &regset, &regset);
}   


/* Text display function. Offsets text to non-graphics area of
   screen. */
void show_text(int x, int y, char *text)
{
   //gotoxy(TEXT_X_OFFSET + x, y);
   //_settextposition(TEXT_X_OFFSET + x, y);
   _settextposition(y, TEXT_X_OFFSET + x);
   puts(text);
   //_outtext(text);
}
