/*
 *--------------------------------------
 * Program Name: FlasLite
 * Author: LogicalJoe
 * License: None
 * Description: Turns your calc into a flashlight!
 *--------------------------------------
 */

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <tice.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <graphx.h>
#include <keypadc.h>

void main(void) {
    uint8_t i, level;
    
    /* Initialize the 8bpp graphics */
    gfx_Begin(gfx_8bpp);
    
    /* Store the brightness level */
    level = lcd_BacklightLevel;
    
    gfx_FillScreen(gfx_white);
    lcd_BacklightLevel = 0;
    
    while (kb_Data[2] != kb_Recip) {
        kb_Scan();
        
        if ((kb_Data[1] & kb_2nd) && (kb_Data[2] & kb_Alpha)) {
            gfx_FillScreen(31);
            lcd_BacklightLevel = 0;
        } else {
            /* Normal */
            if (kb_Data[1] & kb_2nd) {
                gfx_FillScreen(255);
                lcd_BacklightLevel = 0;
            } else {
                /* Night Shift */
                if (kb_Data[2] & kb_Alpha) {
                    gfx_FillScreen(224);
                    lcd_BacklightLevel = 0;
                } else {
                    /* Off */
                    if (kb_Data[2] & kb_Math) {
                        gfx_FillScreen(0);
                        lcd_BacklightLevel = 255;
                    }
                }
            }
        }
    }
    
    gfx_End();
    
    /* Restore the brightness level */
    lcd_BacklightLevel = level;
}
