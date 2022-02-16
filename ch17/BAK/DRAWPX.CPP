 
/* VGA mode 13h functions for Game of Life.
   Tested with Borland C++. */
#include <stdio.h>
#include <conio.h>
#include <graph.h>
#include <dos.h>
#include <assert.h>

#define TEXT_X_OFFSET   26
#define SCREEN_WIDTH_IN_BYTES 320
#define DEBUG_LINE  10

/* Width & height in pixels of each cell. */
extern unsigned int magnifier;

#define SCREEN_WIDTH 320

/*
http://www.azillionmonkeys.com/qed/watfaq.shtml

 Familiar DOS/BIOS data areas such as 0A000:0000 and 0040:0000 have been
mapped in the most natural way:  16*segment+offset.  So VGA space is now
at _FLAT:0x0A0000 and the standard BIOS area is now at _FLAT:0x0400.  But
this mapping doesn't necessarily hold true for the rest of system memory.
This is actually a good thing since it allows for linearly mapped graphics
cards to have their address range placed at a convenient place, namely the
end of your conventional memory.  (Or in the case of Windows; usually a
special address range with certain OS specific characteristics.)

(It is important to note that the construct MK_FP(0xA000,0); doesn't have
the same meaning and will *NOT* correctly map the screen to a usable
pointer.  Use (char *)(0x0A0000) as just described.)

This sudden ease of implementation for everything is actually likely to
make the job of porting from 16 bit DOS quite involved for many
applications.  This porting procedure would mostly be an exercise in
*undoing* all the 16 bit nonsense that was being done previously.

For more information look under "Converting to WATCOM C/C++" in the 
Programmer's Guide.
 */

/*
http://firebell.org/guardiansoft/tutorials/mode13h/mode13h.html

  The way this is accomplished is by first creating a pointer to this VGA buffer as follows:

32-bit compiler:

unsigned char *VGA = (unsigned char *)0xA0000; // Pointer to VGA

16-bit compiler:

unsigned char far *VGA = (unsigned char far *)0xA0000000L; // Pointer to VGA
*/

// We are using 16-BIT compiler 
typedef unsigned char  far byte;
typedef unsigned short far word;

#define SCREEN_MEMADDR_32BIT  0xA0000L
#define SCREEN_MEMADDR_16BIT  0xA0000000L

byte *VGA=(byte *)0xA0000000L;        /* this points to video memory. */

/* Mode 13h draw pixel function. Pixels are of width & height
   specified by extern magnifier. */
void draw_pixel(unsigned int x, unsigned int y, unsigned int color)
{
   // unsigned short offset;
   // offset = ((y * SCREEN_WIDTH_IN_BYTES) + x) * magnifier;
   // assert (offset < 200 * SCREEN_WIDTH_IN_BYTES);   

   if (magnifier == 2) {
      VGA[(y*SCREEN_WIDTH_IN_BYTES+x)*2]=color;
      VGA[(y*SCREEN_WIDTH_IN_BYTES+x)*2 + 1]=color; // x+1
      VGA[(y*SCREEN_WIDTH_IN_BYTES+x)*2 + SCREEN_WIDTH_IN_BYTES]=color; // y+1
      VGA[(y*SCREEN_WIDTH_IN_BYTES+x)*2 + 1 + SCREEN_WIDTH_IN_BYTES]=color; // x+1, y+1
   } else {
      VGA[y*SCREEN_WIDTH_IN_BYTES+x]=color;      
   } 
}

/* plotting a pixel */
void draw_pixel_bios(unsigned int x, unsigned int y, unsigned int color)
{
    union REGS regset;

    regset.h.ah = 0x0C;   /* function 0Ch = pixel plot */
    regset.h.al = color;
    regset.w.cx = x;      /* x location, from 0..319  */
    regset.w.dx = y;      /* y location, from 0..199  */
    int86(0x10,&regset,&regset);
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

   regset.w.ax = 0x0003; /* text mode is mode 3 */
#ifdef __386__
   int386(0x10, &regset, &regset);
#else 
   int86(0x10, &regset, &regset);
#endif
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

/* Text display function. Offsets text to non-graphics area of
   screen. */
void show_debug_text(int x, int y, char *text)
{
    // _settextposition( short row, short col );
    _settextposition(y, x);
    puts(text);
    //_outtext(text);
}