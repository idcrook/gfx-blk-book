
/*
 * Sample program to illustrate EGA/VGA line drawing routines.
 *
 * Compiled with Borland C++
 *
 * By Michael Abrash
 */

#include <stdio.h>
#include <dos.h>     /* contains geninterrupt */

#define GRAPHICS_MODE   0x10
#define TEXT_MODE       0x03
#define BIOS_VIDEO_INT  0x10
#define X_MAX           640      /* working screen width */
#define Y_MAX           348      /* working screen height */

#ifdef USE_ASM_EVGALINE
extern void __cdecl EVGALine();
#else
extern void EVGALine();
#endif


#ifdef __WATCOMC__
static inline void just_int86(unsigned char c,union REGS *r1,union REGS *r2) {
# ifdef __386__
    int386(c,r1,r2);
# else
    int86(c,r1,r2);
# endif
}
#endif

/*
 * Subroutine to draw a rectangle full of vectors, of the specified
 * length and color, around the specified rectangle center.
 */
void VectorsUp(XCenter, YCenter, XLength, YLength, Color)
int XCenter, YCenter;   /* center of rectangle to fill */
int XLength, YLength;   /* distance from center to edge
                           of rectangle */
int Color;              /* color to draw lines in */
{
   int WorkingX, WorkingY;

   /* Lines from center to top of rectangle */
   WorkingX = XCenter - XLength;
   WorkingY = YCenter - YLength;
   for ( ; WorkingX < ( XCenter + XLength ); WorkingX++ )
      EVGALine(XCenter, YCenter, WorkingX, WorkingY, Color);

   /* Lines from center to right of rectangle */
   WorkingX = XCenter + XLength - 1;
   WorkingY = YCenter - YLength;
   for ( ; WorkingY < ( YCenter + YLength ); WorkingY++ )
      EVGALine(XCenter, YCenter, WorkingX, WorkingY, Color);

   /* Lines from center to bottom of rectangle */
   WorkingX = XCenter + XLength - 1;
   WorkingY = YCenter + YLength - 1;
   for ( ; WorkingX >= ( XCenter - XLength ); WorkingX-- )
      EVGALine(XCenter, YCenter, WorkingX, WorkingY, Color);

   /* Lines from center to left of rectangle */
   WorkingX = XCenter - XLength;
   WorkingY = YCenter + YLength - 1;
   for ( ; WorkingY >= ( YCenter - YLength ); WorkingY-- )
      EVGALine(XCenter, YCenter, WorkingX, WorkingY, Color );
}


/* Mode 13h mode-set function. */
void enter_display_mode()
{
   union REGS regset;

   //regset.x.ax = 0x0013;
   regset.w.ax = GRAPHICS_MODE;

   just_int86(0x10, &regset, &regset);

   //_settextposition(1, 1); // rol, col
}

void exit_display_mode()
{
   union REGS regset;

#ifdef __WATCOMC__
    regset.w.ax = TEXT_MODE;
#else
    regset.x.ax = TEXT_MODE;
#endif
   just_int86(0x10, &regset, &regset);
}   


/*
 * Sample program to draw four rectangles full of lines.
 */
void main()
{
   char temp;

   /* Set graphics mode */
#ifdef __WATCOMC__
   enter_display_mode();
#else
   _AX = GRAPHICS_MODE;
   geninterrupt(BIOS_VIDEO_INT);
#endif

   /* Draw each of four rectangles full of vectors */
   VectorsUp(X_MAX / 4, Y_MAX / 4, X_MAX / 4,
      Y_MAX / 4, 1);
   VectorsUp(X_MAX * 3 / 4, Y_MAX / 4, X_MAX / 4,
      Y_MAX / 4, 2);
   VectorsUp(X_MAX / 4, Y_MAX * 3 / 4, X_MAX / 4,
      Y_MAX / 4, 3);
   VectorsUp(X_MAX * 3 / 4, Y_MAX * 3 / 4, X_MAX / 4,
      Y_MAX / 4, 4);

   /* Wait for the enter key to be pressed */
   scanf("%c", &temp);

   /* Return back to text mode */
#ifdef __WATCOMC__
   exit_display_mode();
#else
   _AX = TEXT_MODE;
   geninterrupt(BIOS_VIDEO_INT);   
#endif   
}
