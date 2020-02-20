#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <tice.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <graphx.h>
#include <keypadc.h>

#define BOUND 1
#define MAX_BALLS 4096

/* function prototypes */
void check_keys(void);

/* globals */
typedef struct ball {
    int x,y;
    uint8_t r,c;
    int8_t move_x, move_y;
} ball_t;

ball_t ball[MAX_BALLS];
bool keypress = false;
unsigned num_balls = 1;
uint8_t mode = gfx_white;
bool fill_circle = true;

/* Put all your code here */
void main(void) {
    unsigned i;
    int r,x,y;
    bool c;

    srand(rtc_Time());
    gfx_Begin();

    kb_EnableInt = KB_DATA_CHANGED;
    kb_SetMode(MODE_3_CONTINUOUS);

    gfx_SetDrawBuffer();
    gfx_SetTextTransparentColor(0x55);
    gfx_SetTextBGColor(0x55);

    for (;;) {
        check_keys();

        gfx_FillScreen(mode);

        for (i=0; i<num_balls; i++) {
            ball_t *b = &ball[i];
            gfx_SetColor(b->c);

            x = b->x + b->move_x;
            y = b->y + b->move_y;
            r = b->r;

            if (x + r >= LCD_WIDTH - BOUND) {
                x = gfx_lcdWidth - r - BOUND;
                b->move_x = -(b->move_x);
            }
            if (y + r >= LCD_HEIGHT - BOUND) {
                y = gfx_lcdHeight - r - BOUND;
                b->move_y = -(b->move_y);
            }
            if (x - r < BOUND) {
                x = r + BOUND;
                b->move_x = -(b->move_x);
            }
            if (y - r < BOUND) {
                y = r + BOUND;
                b->move_y = -(b->move_y);
            }
            if (fill_circle) {
                gfx_FillCircle_NoClip(b->x = x, b->y = y, r);
            } else {
                gfx_Circle_NoClip(b->x = x, b->y = y, r);
            }
        }

        gfx_SwapDraw();
    }

}

void check_keys(void) {
    if (kb_IntStatus & KB_DATA_CHANGED) {
        kb_key_t key6, key1;
        ball_t *b;

        if (keypress) {
            keypress = false;
            goto ret;
        }

        key1 = kb_Data[1];
        key6 = kb_Data[6];

        if (key6 & kb_Clear) {
            kb_Reset();
            gfx_End();
            exit(0);
        }

        if (key1 & kb_Del) {
            if (num_balls) {
                num_balls--;
            }
            keypress = true;
            goto ret;
        }

        if (key1 & kb_Mode) {
            num_balls = 0;
            keypress = true;
            goto ret;
        }

        if (key6 & kb_Enter) {
            mode ^= gfx_white;
            keypress = true;
            goto ret;
        }

        if(key6 & kb_Sub) {
            fill_circle ^= true;
            keypress = true;
            goto ret;
        }

        if (key6 & kb_Add) {
            keypress = true;
            goto ret;
        }

        if (num_balls == MAX_BALLS) {
            goto ret;
        }

        b = &ball[num_balls];

        b->x = randInt(20,300);
        b->y = randInt(20,220);
        b->r = randInt(3,9);
        b->c = randInt(1,254);
        b->move_x = randInt(-5,5);
        b->move_y = randInt(-5,5);
        num_balls++;
ret:
        kb_IntAcknowledge = KB_DATA_CHANGED;
    }
}


