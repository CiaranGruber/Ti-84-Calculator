//--------------------------------------
// Program Name: TAXI
// Author: commandblockguy
// License:
// Description:
//--------------------------------------

/* Keep these headers */
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <tice.h>

/* Standard headers - it's recommended to leave them included */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Other available headers */
// stdarg.h, setjmp.h, assert.h, ctype.h, float.h, iso646.h, limits.h, errno.h, debug.h, intce.h
#include <graphx.h>
#include <keypadc.h>
#include <fileioc.h>

#include "gfx/sprite_gfx.h"

/* Put your function prototypes here */
enum directions {NORTH, EAST, SOUTH, WEST};
typedef enum directions direction_t;

void waitForKey();
void infobar();
void update();
void render();
void turn(direction_t dir);
void renderTraffic(bool update);
bool getTraffic();
bool atTarget();
void newTarget();

/* Put all your globals here. */
#define INFOBAR_HEIGHT 16
#define BORDER 4
#define ROADS_X 7
#define ROADS_Y 7
#define ROAD_LENGTH 24
#define ROAD_WIDTH 6
#define TAXI_LENGTH 8
#define TAXI_WIDTH 8
#define MAX_TURN_TOLERANCE 4 //how many pixels after an intersection you can still turn
#define MIN_TURN_TOLERANCE 20 //first pixel you can turn at an intersection
#define TRAFFIC_SLOWDOWN 6 //Number of times speed is reduced when in traffic

typedef struct {
    bool horiz [7] [8];
    bool vert [8] [7];
} trafficmap_t;

typedef struct {
    uint16_t score;
    uint8_t xPos; //screen coordinates
    uint8_t yPos; //screen coordinates
    uint8_t intersection_x; //taxi is approaching this
    uint8_t intersection_y; //taxi is approaching this
    uint8_t prev_x; //taxi is leaving this
    uint8_t prev_y; //taxi is leaving this
    uint8_t progress; //how far along the road the taxi is
    direction_t rotation;
    uint16_t play_time;
    bool crashed;
    trafficmap_t traffic;
    bool hasPass;
    uint8_t tip;
    bool targetAxis;
    uint8_t targetX;
    uint8_t targetY;
} game_t;
game_t game;

gfx_UninitedSprite(behind_sprite, 8, 8);

void main(void) {
    /* Fill in the body of the main function here */
    uint8_t xPos;
    uint8_t yPos;

    prgm_CleanUp();
    srand(rtc_Time());
    gfx_Begin(gfx_8bpp);
    gfx_SetPalette(sprite_gfx_pal, sizeof sprite_gfx_pal, 0);

    behind_sprite->width = 8;
    behind_sprite->height = 8;

    /* Background color */
    gfx_FillScreen(74);
    
    newTarget();

    gfx_Blit(gfx_screen);
    gfx_SetDrawBuffer();

    game.intersection_x = 3;
    game.intersection_y = 3;
    game.progress = 0;
    game.rotation = EAST;
    game.score = 0;

    infobar();

    while (kb_ScanGroup(kb_group_6) != kb_Clear && !game.crashed) {
        update();
    }
    if(game.crashed) {
        gfx_FillScreen(0xA0);
        gfx_SetTextFGColor(0);
        gfx_SetTextXY(120,100);
        gfx_PrintString("You Crashed!");
        gfx_SetTextXY(120,130);
        gfx_PrintString("Score: ");
        gfx_PrintUInt(game.score, 3);
        gfx_BlitBuffer();
        delay(250);
        waitForKey();
    }

    gfx_End();
    prgm_CleanUp();
}

/* Put other functions here */
void waitForKey() {
    while (os_GetCSC());
    while (!os_GetCSC());
}
void infobar() {
    /* White infobar */
    gfx_SetColor(255);
    gfx_FillRectangle(0, 0, LCD_WIDTH, INFOBAR_HEIGHT);
    /* Populate infobar */
    gfx_SetTextFGColor(2);
    gfx_PrintStringXY("Taxi Sim", 4, 4);
    gfx_SetTextXY(128,4);
    gfx_PrintString("Score: ");
    gfx_PrintUInt(game.score, 3);
    if(game.tip > 0) {
        gfx_PrintString(" Tip: ");
        gfx_PrintUInt(game.tip / 10, 2);
    }
}
void update() {
    kb_key_t arrows;
    typedef struct {
        bool right;
        bool left;
        bool up;
        bool down;
    } key_t;
    key_t keys;
    //update traffic
    if(game.play_time % 480 == 0) {
        renderTraffic(true);
    }
    //do keyboard stuff
    kb_Scan();
    arrows = kb_Data[7];
    keys.right = arrows & kb_Right;
    keys.left  = arrows & kb_Left;
    keys.down  = arrows & kb_Down;
    keys.up    = arrows & kb_Up;
    if (keys.right) {
        turn(EAST);
    } else if (keys.left) {
        turn(WEST);
    } else if (keys.up) {
        turn(NORTH);
    } else if (keys.down) {
        turn(SOUTH);
    }
    //process taxi movement
    if(!getTraffic() || game.play_time % TRAFFIC_SLOWDOWN == 0) { 
        game.progress++;
    }
    if(game.progress > (ROAD_LENGTH + ROAD_WIDTH)) {
        game.progress = 0;
        game.prev_x = game.intersection_x;
        game.prev_y = game.intersection_y;
        switch(game.rotation) {
            case NORTH:
            game.intersection_y--;
            break;
            case SOUTH:
            game.intersection_y++;
            break;
            case EAST:
            game.intersection_x++;
            break;
            case WEST:
            game.intersection_x--;
            break;
        }
    }
    if(game.intersection_x < 0 || game.intersection_y < 0 || game.intersection_x > ROADS_X || game.intersection_y > ROADS_Y) {
        game.crashed = true;
    }
    if(atTarget()) {
        if(game.hasPass) {
            game.score += game.tip / 10;
            game.tip = 0;
            gfx_SetColor(0x74);
            gfx_FillRectangle(280, 64, 10, 20);
        } else {
            game.tip = randInt(450, 750);
            gfx_TransparentSprite(passenger, 280, 64);
        }
        game.hasPass = !game.hasPass;
        newTarget();
    }
    //render taxi
    render();
    game.play_time++;
    if(game.tip > 0 && game.play_time % 10 == 0) {
        game.tip--;
    }
}

void render() {
    int8_t offset_x = 0;
    int8_t offset_y = 0;
    gfx_TempSprite(taxi, 8, 8);
    switch(game.rotation) {
        case NORTH:
        offset_y = -1;
        taxi = taxi_rear;
        break;
        case SOUTH:
        offset_y = 1;
        taxi = taxi_front;
        break;
        case EAST:
        offset_x = 1;
        taxi = taxi_right;
        break;
        case WEST:
        offset_x = -1;
        gfx_FlipSpriteY(taxi_right, taxi);
        break;
    }
    offset_x *= game.progress - (ROAD_LENGTH + ROAD_WIDTH);
    offset_y *= game.progress - (ROAD_LENGTH + ROAD_WIDTH);
    game.xPos = offset_x + (ROAD_LENGTH + ROAD_WIDTH) * game.intersection_x + BORDER - 1;
    game.yPos = offset_y + (ROAD_LENGTH + ROAD_WIDTH) * game.intersection_y + INFOBAR_HEIGHT;
    gfx_GetSprite(behind_sprite, game.xPos, game.yPos);
    gfx_TransparentSprite(taxi, game.xPos, game.yPos);
    //update infobar
    infobar();
    gfx_BlitBuffer();
    gfx_Sprite(behind_sprite, game.xPos, game.yPos);
}

void turn(direction_t dir) {
    if((dir % 2) == (game.rotation % 2)) {//In or opposite to direction of travel
        return;
    }
    if(game.progress < MAX_TURN_TOLERANCE) {
        //Turn from the intersection we just left
        game.rotation = dir;
        game.progress = 0;
        game.intersection_x = game.prev_x;
        game.intersection_y = game.prev_y;
        switch(game.rotation) {
            case NORTH:
            game.intersection_y--;
            break;
            case SOUTH:
            game.intersection_y++;
            break;
            case EAST:
            game.intersection_x++;
            break;
            case WEST:
            game.intersection_x--;
            break;
        }
    } else if(game.progress > MIN_TURN_TOLERANCE) {
        //Turn from the intersection we are approaching
        game.rotation = dir;
        game.progress = 0;
        switch(game.rotation) {
            case NORTH:
            game.intersection_y--;
            break;
            case SOUTH:
            game.intersection_y++;
            break;
            case EAST:
            game.intersection_x++;
            break;
            case WEST:
            game.intersection_x--;
            break;
        }
    } else {
        //Crash!
        game.crashed = true;
    }
}

void renderTraffic(bool update) {
    uint8_t xPos;
    uint8_t yPos;
    gfx_TempSprite(road, 6, 24);
    gfx_TempSprite(horiz_road, 24, 6);
    gfx_FillScreen(74);
    for( xPos = 0; xPos < (ROADS_X + 1); xPos++ ) {
        for( yPos = 0; yPos < ROADS_Y; yPos++ ) {
            if(update) {
                game.traffic.vert[xPos][yPos] = randInt(0,3) == 3;
            }
            if(game.traffic.vert[xPos][yPos]) {
                road = street_red;
            } else {
                road = street;
            }
            gfx_Sprite(road, (ROAD_LENGTH + ROAD_WIDTH) * xPos + BORDER, (ROAD_LENGTH + ROAD_WIDTH) * yPos + INFOBAR_HEIGHT + BORDER + ROAD_WIDTH);
        }
    }
    
    for( xPos = 0; xPos < ROADS_X; xPos++ ) {
        for( yPos = 0; yPos < (ROADS_Y + 1); yPos++ ) {
            if(update) {
                game.traffic.horiz[xPos][yPos] = randInt(0,3) == 3;
            }
            if(game.traffic.horiz[xPos][yPos]) {
                gfx_RotateSpriteC(street_red, horiz_road);
            } else {
                gfx_RotateSpriteC(street, horiz_road);
            }
            gfx_Sprite(horiz_road, (ROAD_LENGTH + ROAD_WIDTH) * xPos + ROAD_WIDTH + BORDER, (ROAD_LENGTH + ROAD_WIDTH) * yPos + INFOBAR_HEIGHT + BORDER);
        }
    }
    if(game.targetAxis) {
        gfx_TransparentSprite(x, (ROAD_LENGTH + ROAD_WIDTH) * game.targetX + BORDER - 1, (ROAD_LENGTH + ROAD_WIDTH) * game.targetY + INFOBAR_HEIGHT + BORDER + ROAD_WIDTH + 8);
    } else {
        gfx_TransparentSprite(x, (ROAD_LENGTH + ROAD_WIDTH) * game.targetX + ROAD_WIDTH + BORDER + 8, (ROAD_LENGTH + ROAD_WIDTH) * game.targetY + INFOBAR_HEIGHT + BORDER - 1);
    }
    if(game.hasPass) {
        gfx_TransparentSprite(passenger, 280, 64);
    }
}

bool getTraffic() {
    switch(game.rotation) {
        case NORTH:
        return game.traffic.vert[game.intersection_x][game.intersection_y];
        break;
        case SOUTH:
        return game.traffic.vert[game.intersection_x][game.intersection_y - 1];
        break;
        case WEST:
        return game.traffic.horiz[game.intersection_x][game.intersection_y];
        break;
        case EAST:
        return game.traffic.horiz[game.intersection_x - 1][game.intersection_y];
        break;
    }
    return false;
}

bool atTarget() {
    switch(game.rotation) {
        case NORTH:
        return game.intersection_x == game.targetX && game.intersection_y == game.targetY && game.targetAxis;
        break;
        case SOUTH:
        return game.intersection_x == game.targetX && game.intersection_y - 1 == game.targetY && game.targetAxis;
        break;
        case WEST:
        return game.intersection_x == game.targetX && game.intersection_y == game.targetY && !game.targetAxis;
        break;
        case EAST:
        return game.intersection_x - 1 == game.targetX && game.intersection_y == game.targetY && !game.targetAxis;
        break;
        default:
        return false;
    }
}

void newTarget() {
    game.targetAxis = randInt(0,1);
    if(game.targetAxis) {
        game.targetX = randInt(0,7);
        game.targetY = randInt(0,6);
    } else {
        game.targetX = randInt(0,6);
        game.targetY = randInt(0,7);
    }
    renderTraffic(false);
}