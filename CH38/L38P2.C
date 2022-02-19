/* Draws all pixels in the list of horizontal lines passed in, in
   mode 13h, the VGA's 320x200 256-color mode. Uses a slow pixel-by-
   pixel approach, which does have the virtue of being easily ported
   to any environment. */

#include <dos.h>
#include "polygon.h"

#define SCREEN_WIDTH    320
#define SCREEN_SEGMENT  0xA000L

static void DrawPixel(int, int, int);

#define SCREEN_MEMADDR_32BIT  (SCREEN_SEGMENT << 4)
#define SCREEN_MEMADDR_16BIT  (SCREEN_SEGMENT << 16)

// When using 16-BIT compiler FAR required in raw pointer types
typedef unsigned char  byte;
typedef unsigned short word;

#ifdef __386__
   byte *VGA=(byte *) (SCREEN_MEMADDR_32BIT); 
#else
   byte far *VGA=(byte far *) (SCREEN_MEMADDR_16BIT); 
#endif


void DrawHorizontalLineList(struct HLineList * HLineListPtr,
      int Color)
{
  struct HLine *HLinePtr;
  int Y, X;

  /* Point to the XStart/XEnd descriptor for the first (top)
     horizontal line */
  HLinePtr = HLineListPtr->HLinePtr;
  /* Draw each horizontal line in turn, starting with the top one and
     advancing one line each time */
  for (Y = HLineListPtr->YStart; Y < (HLineListPtr->YStart +
        HLineListPtr->Length); Y++, HLinePtr++) {
     /* Draw each pixel in the current horizontal line in turn,
        starting with the leftmost one */
     for (X = HLinePtr->XStart; X <= HLinePtr->XEnd; X++)
        DrawPixel(X, Y, Color);
  }
}

/* Draws the pixel at (X, Y) in color Color in VGA mode 13h */
static void DrawPixel(int X, int Y, int Color) {
   byte far *ScreenPtr;

#ifdef __TURBOC__
   ScreenPtr = MK_FP(SCREEN_SEGMENT, Y * SCREEN_WIDTH + X);
#else    /* MSC 5.0 */
 #ifdef __WATCOMC__
   ScreenPtr = VGA + Y * SCREEN_WIDTH + X ;
 #else
   FP_SEG(ScreenPtr) = SCREEN_SEGMENT;
   FP_OFF(ScreenPtr) = Y * SCREEN_WIDTH + X;
 #endif
#endif
   *ScreenPtr = (unsigned char)Color;
}
