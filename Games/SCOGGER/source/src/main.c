/*
 *--------------------------------------
 * Program Name: SCOGGER CE
 *       Porter: Rodger "Iambian" Weisman
 *      License: BSD (See LICENSE file)
 *  Description: Hop across all the lilipads
 *--------------------------------------
*/

#define VERSION_INFO "v0.1"

#define TRANSPARENT_COLOR 0xF8

#define GM_TITLE 1
#define GM_STAGESELECT 2
#define GM_GAMEMODE 3
#define GM_STAGECOMPLETE 4

/* Standard headers (recommended) */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* External library headers */
#include <debug.h>
#include <intce.h>
#include <keypadc.h>
#include <graphx.h>
#include <decompress.h>
#include <fileioc.h>

#include "gfx/sprites_gfx.h"
#include "font.h"
#include "base_set.h"
#include "extend_set.h"


const char *blankstr = "";
const char *title1 = "Classic Mode";
const char *title2 = "Scogger+";
const char *stagesel = "Stage Select";
const char *diffstr[] = {"Baby","Easy","Normal","Hard","Extra"};


const char *scorefilename = "SCOGGDAT";

/* Put your function prototypes here */

void drawboard();
void drawboardfast();
void drawscorekeepers();
void drawstillfrog();
void drawmovingfrog(int x,int y);
void drawfrog(gfx_sprite_t** spr,int x,int y);
void dispversion();
//---
void putaway();
void waitanykey();
void keywait();
void drawdebug();
void centerxtext(char* strobj,int y);
void* decompress(void* cdata_in, int out_size);
//---
void loadstage(uint8_t levelnum);
bool checkfrogmove(uint8_t dir);


/* Put all your globals here */
struct {
	uint8_t classic_curlevel;
	uint8_t classic_maxlevel;
	uint8_t extended_curlevel;
	uint8_t extended_maxlevel;
} levelstats;

uint8_t gamemode;
uint8_t menuoption;
uint8_t maintimer;
uint8_t curlevel;
uint8_t maxlevel;
uint8_t* levelpack;
uint8_t levels_in_pack;

uint8_t leveldata[8*6];
uint8_t frogx;
uint8_t frogy;
uint8_t direction;
uint8_t difficulty;
uint8_t splashlen;
uint8_t newstagerefresh;

gfx_sprite_t* title;
gfx_sprite_t* allclear;
gfx_sprite_t* bor_do;
gfx_sprite_t* bor_le;
gfx_sprite_t* bor_ri;
gfx_sprite_t* bor_up;
gfx_sprite_t* completed;
gfx_sprite_t* cursor;
gfx_sprite_t* fmo_do;
gfx_sprite_t* fmo_le;
gfx_sprite_t* fmo_ri;
gfx_sprite_t* fmo_up;
gfx_sprite_t* fst_do;
gfx_sprite_t* fst_le;
gfx_sprite_t* fst_ri;
gfx_sprite_t* fst_up;
gfx_sprite_t* lily_1;
gfx_sprite_t* lily_2;
gfx_sprite_t* rock;
gfx_sprite_t* splash;
gfx_sprite_t* water;

ti_var_t slot;

//-----------------------------------Enemy fish size limit--^

void main(void) {
    int x,y,dx,dy,i,j,temp,subtimer;
	uint8_t a,b,c;
	kb_key_t k;
	char* tmp_str;
	void* ptr1;
	void* ptr2;
	int8_t frogmoveinterval[8] = {0,-8,0,8,-8,0,8,0};
	
	/* Initialize system */
	malloc(0);  //for linking purposes
	gfx_Begin(gfx_8bpp);
	gfx_SetDrawBuffer();
	gfx_SetTransparentColor(TRANSPARENT_COLOR);
	gfx_SetClipRegion(0,0,320,240);
	gfx_SetFontData(&font_data - (32*8));
	gfx_SetFontSpacing(&font_spacing - 32);
	gfx_SetTextScale(2,2);
	/* Initialize variables */
	
	title  = decompress(title_compressed,title_size);
	allclear = decompress(allclear_compressed,allclear_size);
	bor_do = decompress(bor_do_compressed,bor_do_size);
	bor_le = decompress(bor_le_compressed,bor_le_size);
	bor_ri = decompress(bor_ri_compressed,bor_ri_size);
	bor_up = decompress(bor_up_compressed,bor_up_size);
	completed = decompress(completed_compressed,completed_size);
	cursor = decompress(cursor_compressed,cursor_size);
	fmo_do = decompress(fmo_do_compressed,fmo_do_size);
	fmo_le = decompress(fmo_le_compressed,fmo_le_size);
	fmo_ri = decompress(fmo_ri_compressed,fmo_ri_size);
	fmo_up = decompress(fmo_up_compressed,fmo_up_size);
	fst_do = decompress(fst_do_compressed,fst_do_size);
	fst_le = decompress(fst_le_compressed,fst_le_size);
	fst_ri = decompress(fst_ri_compressed,fst_ri_size);
	fst_up = decompress(fst_up_compressed,fst_up_size);
	lily_1 = decompress(lily_1_compressed,lily_1_size);
	lily_2 = decompress(lily_2_compressed,lily_2_size);
	rock = decompress(rock_compressed,rock_size);
	splash = decompress(splash_compressed,splash_size);
	water = decompress(water_compressed,water_size);
	
	memset(&levelstats,0,4);
	
	ti_CloseAll();
	slot = ti_Open(scorefilename,"r");
	if (slot) ti_Read(&levelstats,sizeof leveldata, 1, slot);
	ti_CloseAll();
	
	/* Initiate main game loop */
	gamemode = GM_TITLE;
	menuoption = 0;
	while (1) {
		kb_Scan();
		switch (gamemode) {
			case GM_TITLE:
				k = kb_Data[1];
				if (k&kb_2nd) {
					if (!menuoption) {
						curlevel = levelstats.classic_curlevel;
						maxlevel = levelstats.classic_maxlevel;
						levelpack = leveldata_base_set;
						levels_in_pack = base_set_numlevels;
					} else {
						curlevel = levelstats.extended_curlevel;
						maxlevel = levelstats.extended_maxlevel;
						levelpack = leveldata_extend_set;
						levels_in_pack = extend_set_numlevels;
					}
					gamemode = GM_STAGESELECT;
					keywait();
					break;
				}
				if (k&kb_Mode) putaway();
				k = kb_Data[7];
				if ((k&kb_Down)&&!menuoption) menuoption=1;
				if ((k&kb_Up)&&menuoption) menuoption=0;
				
				gfx_FillScreen(0xFF);  //full screen white
				
				gfx_ScaledSprite_NoClip(title,1*2,8*2,2,2);
				gfx_SetTextXY(54*2,89*2);  //line height 12*2
				gfx_PrintString(title1);
				gfx_SetTextXY(54*2,101*2);  //line height 12*2
				gfx_PrintString(title2);
				// use on-the-fly scaled sprite to x2 size. For everything
				gfx_ScaledTransparentSprite_NoClip(cursor,43*2,(89*2)+(12*2*menuoption),2,2);
				dispversion();
				break;
			case GM_STAGESELECT:
				k = kb_Data[1];
				if (k&kb_Mode) {
					gamemode = GM_TITLE;
					keywait();
				}
				if (k&kb_2nd) {
					loadstage(curlevel);
					gamemode = GM_GAMEMODE;
					dbg_sprintf(dbgout,"dir,x,y %02X %02X %02X\n",direction,frogx,frogy);
					keywait();
				}
				k = kb_Data[7];
				if ((k&kb_Left)&&curlevel) {
					curlevel--;
					keywait();
				}
				if ((k&kb_Right)&&((curlevel<maxlevel)&&(curlevel<(levels_in_pack-1)))) {
					curlevel++;
					keywait();
				}
				gfx_FillScreen(0xFF);  //full screen white
				gfx_ScaledSprite_NoClip(title,1*2,8*2,2,2);
				gfx_SetTextXY(54*2,89*2);  //line height 12*2
				gfx_PrintString(stagesel);
				gfx_SetTextXY(67*2,101*2);  //line height 12*2
				gfx_PrintChar('<');
				gfx_SetTextFGColor((curlevel==maxlevel) ? 0xA0 : 0x05);
				gfx_PrintUInt(curlevel+1,3);
				gfx_SetTextFGColor(0);
				gfx_PrintChar('>');
				dispversion();
				break;
			case GM_GAMEMODE:
				k = kb_Data[1];
				if (k&kb_Mode) {
					gamemode = GM_STAGECOMPLETE;
					keywait();
				}
				if (k&kb_Del) {
					loadstage(curlevel);
				}
				
				a = false;
				switch (kb_Data[7]) {
					case kb_Up:
						if (direction==1) break;
						a = checkfrogmove(0);
						break;
					case kb_Down:
						if (direction==0) break;
						a = checkfrogmove(1);
						break;
					case kb_Left:
						if (direction==3) break;
						a = checkfrogmove(2);
						break;
					case kb_Right:
						if (direction==2) break;
						a = checkfrogmove(3);
						break;
					default:
						break;
				}
				if (a) {
					keywait();
					//moving frog
					x = 24-4+(24*frogx);
					y = 48-4+(24*frogy);
					dx = frogmoveinterval[2*direction];
					dy = frogmoveinterval[2*direction+1];
					a = leveldata[frogy*8+frogx];
					if (a == 1) leveldata[frogy*8+frogx] = 8;
					if (a == 6) leveldata[frogy*8+frogx] = 1;
					do {
						for (a=0;a<3;a++) {
							x += dx;
							y += dy;
							drawboardfast(1);
							drawmovingfrog(x,y);
							gfx_SwapDraw();
						}
						if (leveldata[frogy*8+frogx]==8) leveldata[frogy*8+frogx] = 0;
						switch (direction) {
							case 0:
								frogy--;
								break;
							case 1:
								frogy++;
								break;
							case 2:
								frogx--;
								break;
							case 3:
								frogx++;
								break;
							default:
								break;
						}
					} while (!leveldata[frogy*8+frogx]);
				}
				drawboard();
				drawstillfrog();
				gfx_SwapDraw();
				// check victory condition here
				for (b=a=y=0;y<6;y++) {
					for(x=0;x<8;a++,x++) {
						if (leveldata[a]==6) b++;
						if (leveldata[a]==1 && !(x==frogx && y==frogy)) b++;
					}
				}
				
				if (!b) {
					drawboard();
					drawstillfrog();
					x = 13*2;
					y = 48*2;
					if (levels_in_pack==maxlevel) {
						ptr1 = completed;
						gamemode = GM_STAGECOMPLETE;
					} else {
						curlevel++;
						if (curlevel>maxlevel) maxlevel++;
						if (maxlevel==levels_in_pack) {
							ptr1 = allclear;
							gamemode = GM_STAGECOMPLETE;
							curlevel--;
							x = 14*2;
							y = 36*2;
						} else {
							ptr1 = completed;
							loadstage(curlevel);
						}
					}
					gfx_ScaledTransparentSprite_NoClip(ptr1,x,y,2,2);
					gfx_SwapDraw();
					waitanykey();
					break;
				}
				
				break;
			case GM_STAGECOMPLETE:
				if (!menuoption) {
					levelstats.classic_curlevel = curlevel;
					levelstats.classic_maxlevel = maxlevel;
				} else {
					levelstats.extended_curlevel = curlevel;
					levelstats.extended_maxlevel = maxlevel;
				}
				gamemode = GM_STAGESELECT;
				keywait();
				break;
			default:
				putaway();
				break;
		}
		maintimer++;
	}
}

/*  NOTE: ALL THESE POSITIONS MAP TO A 160X120 RESOLUTION SCREEN
;border locations:
;bor_up: 0,7
;bor_le: 0,24
;lor_ri: 108,24
;bor_do: 0,96

;12x12 sprites
;(8+2) x (6+2) grid water overscan
;start location:(0,12)

leveldata: 0=water, 1=lily_1 6=lily_2 7=rock

*/
void drawboard() {
	uint16_t x;
	uint8_t y,i,t;
	gfx_FillScreen(0xFF);
	for(y=24;y<24+(8*24);y+=24) {
		for(x=0;x<24*10;x+=24) {
			gfx_ScaledSprite_NoClip(water,x,y,2,2);
		}
	}
	
	drawboardfast(0);
	
	gfx_ScaledTransparentSprite_NoClip(bor_up,0,14,2,2);
	gfx_ScaledTransparentSprite_NoClip(bor_le,0,48,2,2);
	gfx_ScaledTransparentSprite_NoClip(bor_ri,216,48,2,2);
	gfx_ScaledTransparentSprite_NoClip(bor_do,0,192,2,2);
	
	drawscorekeepers();
}

void drawboardfast(drawwater) {
	uint16_t x;
	uint8_t y,i;
	if (newstagerefresh<2) {
		newstagerefresh++;   //these are done to make sure the text doesn't
		drawscorekeepers();  //flicker if the user moves too soon on next stage
	}
	i=0;
	for (y=48;y<48+(6*24);y+=24) {
		for(x=24;x<24+(24*8);x+=24) {
			if (drawwater) gfx_ScaledSprite_NoClip(water,x,y,2,2);
			switch (leveldata[i]) {
				case 1:
					gfx_ScaledTransparentSprite_NoClip(lily_1,x,y,2,2);
					break;
				case 6:
					gfx_ScaledTransparentSprite_NoClip(lily_2,x,y,2,2);
					break;
				case 7:
					gfx_ScaledTransparentSprite_NoClip(rock,x,y,2,2);
					break;
				case 8:
					gfx_ScaledTransparentSprite_NoClip(splash,x,y,2,2);
					break;
				default:
					break;
			}
			i++;			
		}
	}
}

void drawscorekeepers() {
	gfx_PrintStringXY("Level",129*2,32*2);
	gfx_SetTextXY(140*2,42*2);
	gfx_PrintUInt(curlevel+1,3);
	gfx_PrintStringXY(diffstr[difficulty],129*2,64*2);
}


// 0=up, 1=down, 2=left, 3=right
void drawstillfrog() {
	gfx_sprite_t* fspr[4];
	fspr[0] = fst_up;
	fspr[1] = fst_do;
	fspr[2] = fst_le;
	fspr[3] = fst_ri;
	
	drawfrog(fspr,24+(24*frogx),48+(24*frogy));
}

void drawmovingfrog(int x,int y) {
	gfx_sprite_t* mspr[4];
	mspr[0] = fmo_up;
	mspr[1] = fmo_do;
	mspr[2] = fmo_le;
	mspr[3] = fmo_ri;
	drawfrog(mspr,x,y);
}

void drawfrog(gfx_sprite_t** spr,int x,int y) {
	gfx_ScaledTransparentSprite_NoClip(spr[direction],x,y,2,2);
}


void dispversion() {
	gfx_SetTextXY(290,230);
	gfx_SetTextScale(1,1);
	gfx_PrintString(VERSION_INFO);
	gfx_SetTextScale(2,2);
	gfx_SwapDraw();
}

//---------------------------------------------------------------------------

void putaway() {
//	int_Reset();
	gfx_End();
	slot = ti_Open(scorefilename,"w");
	ti_Write(&levelstats,sizeof levelstats, 1, slot);
	ti_CloseAll();
	exit(0);
}

void waitanykey() {
	keywait();            //wait until all keys are released
	while (!kb_AnyKey()); //wait until a key has been pressed.
	while (kb_AnyKey());  //make sure key is released before advancing
}	

void keywait() {
	while (kb_AnyKey());  //wait until all keys are released
}

void centerxtext(char* strobj,int y) {
	gfx_PrintStringXY(strobj,(LCD_WIDTH-gfx_GetStringWidth(strobj))/2,y);
}

void* decompress(void *cdata_in,int out_size) {
	void *ptr = malloc(out_size);
	dzx7_Turbo(cdata_in,ptr);
	return ptr;
}

//----------------------------------------------------------------------------------

//note: fmt: x,y,dir,diff, [8*6]
void loadstage(uint8_t levelnum) {
	uint8_t i;
	uint8_t* curptr = (uint8_t*) levelpack+levelnum*(8*6+4)+4;
	for(i=0;i<48;i++) leveldata[i] = curptr[i];
	frogx = curptr[-4];
	frogy = curptr[-3]-1;  //the minus 1 to convert from 8x8 to 8x6 fmt
	direction = curptr[-2];
	difficulty = curptr[-1];
	newstagerefresh = 0;
}


// 0=up, 1=down, 2=left, 3=right
//returns true if move is valid, else false. alters direction if valid move
bool checkfrogmove(uint8_t dir) {
	int8_t dirarr[] = {0,-1,0,1,-1,0,1,0};
	int curx,cury,dx,dy;
	curx = frogx;
	cury = frogy;
	dx = dirarr[2*dir];
	dy = dirarr[2*dir+1];
	while (1) {
		curx += dx;
		cury += dy;
		if (!(curx>-1 && cury>-1 && curx<8 && cury<6)) break;
		if (leveldata[8*cury+curx]) {
			direction = dir;
			return true;
		}
	}
	return false;
}
