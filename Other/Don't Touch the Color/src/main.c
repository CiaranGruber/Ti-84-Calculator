// Program Name:
// Author(s):
// Description:

/* Keep these headers */
#include <tice.h>

/* Standard headers - it's recommended to leave them included */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <debug.h>
/* Other available headers */
// including stdarg.h, setjmp.h, assert.h, ctype.h, float.h, iso646.h, limits.h, errno.h

/* Available libraries */
// including lib/ce/graphc.h, lib/ce/fileioc.h, and lib/ce/keypadc.h
#include <graphx.h>
#include <keypadc.h>
#include <fileioc.h>
/* Put your function prototypes here */
void setColors(int color1, int color2, int color3, int color4, int color5, int color6, int color7);
void draw(void);
void setColor(void);
void inGame(void);
/* Put all your globals here. */
ti_var_t file;
uint8_t Gcolor1, Gcolor2, Gcolor3, Gcolor4, Gcolor5, Gcolor6, Gcolor7, highscore, score;
bool userColor1;
/* Put all your code here */

void main() {
	uint8_t key = 0, keyPress = 0;
	bool quit = false;
	ti_CloseAll();
	file = ti_Open("clrhs", "r");
	if (file) { 
		ti_Read(&highscore, sizeof(highscore), 1, file);
	}   
	else {
		highscore = 0;
	}
	srand( rtc_Time() );
	gfx_Begin(gfx_8bpp);
	gfx_FillScreen(181);
	gfx_PrintStringXY("Don't Touch the Wrong Color!",60,1);
	gfx_PrintStringXY("Press any key to play",85,11);
	gfx_PrintStringXY("Highscore:",105,51);
	gfx_SetTextXY(180,51);
	gfx_PrintInt(highscore, 3);
	while(kb_ScanGroup(kb_group_6) != kb_Clear) {
		if (keyPress % 50 == 0) {
			if (kb_AnyKey()) {
				gfx_FillScreen(181);
				setColors(31,255,7,235,186,224,24);
				draw();
				inGame();
				if (quit == false) {
					gfx_FillScreen(181);
					gfx_PrintStringXY("Don't Touch the Wrong Color!",60,1);
					gfx_PrintStringXY("Press any key to play",85,11);
					gfx_PrintStringXY("Highscore:",105,51);
					gfx_SetTextXY(180,51);
					gfx_PrintInt(highscore, 3);
				}
			}
		}
		if (quit == true)
			break;
		keyPress++;
	}
	gfx_End();
	prgm_CleanUp();
}
void draw(void){
	uint8_t random = 0;
	if (score >= 12) {
		userColor1 = false;
		setColor();
		gfx_FillRectangle(0, 0, 16, 40);
		setColor();
		gfx_FillRectangle(0, 40, 16, 40);
		setColor();
		gfx_FillRectangle(0, 80, 16, 40);
		setColor();
		gfx_FillRectangle(0, 120, 16, 40);
		setColor();
		gfx_FillRectangle(0, 160, 16, 40);
		setColor();
		gfx_FillRectangle(0, 200, 16, 40);
		if (userColor1 == false) {
			gfx_SetColor(Gcolor5);
			random = randInt(1,6);
			if (random == 1)
				gfx_FillRectangle(0, 0, 16, 40);
			if (random == 2)
				gfx_FillRectangle(0, 40, 16, 40);
			if (random == 3)
				gfx_FillRectangle(0, 80, 16, 40);
			if (random == 4)
				gfx_FillRectangle(0, 120, 16, 40);
			if (random == 5)
				gfx_FillRectangle(0, 160, 16, 40);
			if (random == 6)
				gfx_FillRectangle(0, 200, 16, 40);
		}
		userColor1 = false;	
		setColor();
		gfx_FillRectangle(304, 0, 16, 40);
		setColor();
		gfx_FillRectangle(304, 40, 16, 40);
		setColor();
		gfx_FillRectangle(304, 80, 16, 40);
		setColor();
		gfx_FillRectangle(304, 120, 16, 40);
		setColor();
		gfx_FillRectangle(304, 160, 16, 40);
		setColor();
		gfx_FillRectangle(304, 200, 16, 40);
		if (userColor1 == false) {
			gfx_SetColor(Gcolor5);
			random = randInt(1,6);
			if (random == 1)
				gfx_FillRectangle(304, 0, 16, 40);
			if (random == 2)
				gfx_FillRectangle(304, 40, 16, 40);
			if (random == 3)
				gfx_FillRectangle(304, 80, 16, 40);
			if (random == 4)
				gfx_FillRectangle(304, 120, 16, 40);
			if (random == 5)
				gfx_FillRectangle(304, 160, 16, 40);
			if (random == 6)
				gfx_FillRectangle(304, 200, 16, 40);
		}
	}
	if (score < 12) {
		userColor1 = false;
		setColor();
		gfx_FillRectangle(0, 0, 16, 60);
		setColor();
		gfx_FillRectangle(0, 60, 16, 60);
		setColor();
		gfx_FillRectangle(0, 120, 16, 60);
		setColor();
		gfx_FillRectangle(0, 180, 16, 60);
		if (userColor1 == false) {
			gfx_SetColor(Gcolor5);
			random = randInt(1,4);
			if (random == 1)
				gfx_FillRectangle(0, 0, 16, 60);
			if (random == 2)
				gfx_FillRectangle(0, 60, 16, 60);
			if (random == 3)
				gfx_FillRectangle(0, 120, 16, 60);
			if (random == 4)
				gfx_FillRectangle(0, 180, 16, 60);
		}
		userColor1 = false;	
		setColor();
		gfx_FillRectangle(304, 0, 16, 60);
		setColor();
		gfx_FillRectangle(304, 60, 16, 60);
		setColor();
		gfx_FillRectangle(304, 120, 16, 60);
		setColor();
		gfx_FillRectangle(304, 180, 16, 60);
		if (userColor1 == false) {
			gfx_SetColor(Gcolor5);
			random = randInt(1,4);
			if (random == 1)
				gfx_FillRectangle(304, 0, 16, 60);
			if (random == 2)
				gfx_FillRectangle(304, 60, 16, 60);
			if (random == 3)
				gfx_FillRectangle(304, 120, 16, 60);
			if (random == 4)
				gfx_FillRectangle(304, 180, 16, 60);
		}
	}
}
void setColor(void) {
	uint8_t colorChoice = 0;
	bool userColor = false;
	colorChoice = randInt(1,7);
	if (colorChoice == 1) {
		gfx_SetColor(Gcolor1);
		userColor = false;
	}
	if (colorChoice == 2) {
		gfx_SetColor(Gcolor2);
		userColor = false;
	}
	if (colorChoice == 3) {
		gfx_SetColor(Gcolor3);
		userColor = false;
	}
	if (colorChoice == 4) {
		gfx_SetColor(Gcolor4);
	}
	if (colorChoice == 5) {
		gfx_SetColor(Gcolor5);
		userColor1 = true;
	}
	if (colorChoice == 6) {
		gfx_SetColor(Gcolor6);
		userColor1 = false;
	}
	if (colorChoice == 7) {
		gfx_SetColor(Gcolor7);
		userColor1 = false;
	}
}
void setColors(int color1, int color2, int color3, int color4, int color5, int color6, int color7) {
	Gcolor1 = color1;
	Gcolor2 = color2;
	Gcolor3 = color3;
	Gcolor4 = color4;
	Gcolor5 = color5;
	Gcolor6 = color6;
	Gcolor7 = color7;
}
void inGame() {
	int posX = 160, getPixelLeft = 0, getPixelRight = 0;
	uint8_t speed = 20, key = 0, keyPress = 0, colorChange = 0, random = 0, loop = 1;
	bool quit = false, up = false, left = true;
	float posY = 68.0, velocityY = 0.0, gravity = 0.2;
	score = 0;
	while (kb_Data[kb_group_6] != kb_Clear) {
		getPixelLeft = gfx_GetPixel(posX-16, posY);
		getPixelRight = gfx_GetPixel(posX+17, posY);
		velocityY += gravity;
		posY += velocityY;
		if(kb_AnyKey() && loop>13){
			velocityY = -3.7;
			loop=0;
		}
		loop = (loop>13?15:loop+1);
		if (left == true)
			posX = posX - 3;
		if (left == false)
			posX = posX + 3;
		gfx_SetColor(181);
		gfx_SetDrawBuffer();
		gfx_FillRectangle(16,0, 288, 240);
		gfx_SetColor(Gcolor5);
		gfx_FillCircle(posX, posY, 6);
		gfx_SetTextXY(150, 1);
		gfx_SetColor(181);
		gfx_PrintInt(score, 3);
		gfx_BlitRectangle(gfx_buffer,16,0, 288, 240);
		gfx_SetDrawScreen();
		if (left == true && getPixelLeft == Gcolor5) {
			draw();
			left = false;
			score++;
			colorChange++;
			if (speed >= 1)
				speed--;
			gfx_SetTextXY(150, 1);
			gfx_SetColor(181);
			gfx_FillRectangle(150, 1, 32, 10);
			gfx_PrintInt(score, 3);
		}
		if (left == false && getPixelRight == Gcolor5) {
			draw();
			left = true;
			score++;
			colorChange++;
			gfx_SetTextXY(150, 1);
			gfx_SetColor(181);
			gfx_FillRectangle(150, 1, 32, 10);
			gfx_PrintInt(score, 3);
		}
		if (colorChange == 6) {
			random = randInt(1,5);
			if (random == 1)
				Gcolor5 = Gcolor1;
			if (random == 2)
				Gcolor5 = Gcolor2;
			if (random == 3)
				Gcolor5 = Gcolor3;
			if (random == 4)
				Gcolor5 = Gcolor4;
			if (random == 5)
				Gcolor5 = Gcolor5;
			colorChange = 0;
			draw();
		}
		if (left == true && getPixelLeft != 181 && getPixelLeft != Gcolor5)
			break;
		if (left == false && getPixelRight != 181 && getPixelRight != Gcolor5)
			break;
		keyPress++;
	}
	quit = true;
	if (score >= highscore) {
		highscore = score; 
    /* Close all open file handles before we try any funny business */ 
		ti_CloseAll(); 

    /* Open a file for writting*/ 
		file = ti_Open("clrhs", "w"); 

    /* write some things to the file */ 
		if (file) 
			ti_Write(&highscore, sizeof(highscore), 1, file);  
	}
}
/* Other functions */
