//--------------------------------------
// Program Name: ApsirinCE
// Author: Unicorn	
// License:
// Description: A Port of Aspirin to the TI 84+ CE Calculator
//--------------------------------------

/* Headers! */
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <tice.h>

/* More Headers! */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <graphx.h>
#include <keypadc.h>
#include <fileioc.h>
#include <debug.h>

/* Fuction Prototypes */
void drawLines(uint8_t color);
void checkForStab(void);
void updateLines(void);
void addLines(uint8_t number);
void drawMenu(void);
void renderMenu(void);
void inGame(uint8_t numLines);
void readAppVar(void);
void writeAppVar(void);
void updateMenuLines(void);

/* Globals */
int playerX = 76, playerY = 41;
uint8_t numberOfLines, y;
bool quit, difficulty = 1, goUp;
const char appvar_name[] = "asprinHI";
ti_var_t file;

typedef struct my_line {
	int x;
	int y;
	bool direction;
	bool goingRight;
} my_line_t;
my_line_t lines[30];
typedef struct appVar1 {
	uint8_t easyHighscore;
	uint8_t mediumHighscore;
	uint8_t hardHighscore;
} appVar1_t;
appVar1_t appVar; 

/* Main Menu */
void main(void) {
	kb_key_t key = 0;
	kb_key_t key1 = 0;
	unsigned int delay = 0;
	srand(rtc_Time());
	ti_CloseAll();
	readAppVar();
	gfx_Begin(gfx_8bpp);
	gfx_SetDrawScreen	();
	drawMenu();
	renderMenu();
	gfx_SetDrawBuffer();
	drawMenu();
	renderMenu();
	while (kb_Data[kb_group_6] != kb_Clear) {
		kb_Scan();
		gfx_SetTextFGColor(gfx_black);
		if (key & kb_Right && difficulty != 3) {
			difficulty += 1;
			dbg_sprintf(dbgout, "difficulty: %d\n", difficulty);
		}
		if (key & kb_Left && difficulty != 1) {
			difficulty -= 1;
			dbg_sprintf(dbgout, "difficulty: %d\n", difficulty);

		}
		renderMenu();
		if (key1 & kb_2nd) {
			quit = false;
			inGame(difficulty);
			gfx_SetDrawScreen();
			drawMenu();
			renderMenu();
			gfx_SetDrawBuffer();
			drawMenu();
			renderMenu();
			numberOfLines = 0;
		}
		key = kb_Data[kb_group_7];
		key1 = kb_Data[kb_group_1];
		gfx_SwapDraw();
	}
	gfx_End();
}
void writeAppVar(void) {
	int stuff;
	ti_var_t file = ti_Open(appvar_name, "w");
	stuff = ti_Write(&appVar, sizeof(appVar), 1, file);
	ti_CloseAll();
}
void readAppVar(void) {
	int stuff;
	ti_var_t file = ti_Open(appvar_name, "r");
	stuff = ti_Read(&appVar, sizeof(appVar), 1, file);
	ti_CloseAll();
}
/* Draws the Menu */
void drawMenu(void) {
	gfx_FillScreen(gfx_white);
	gfx_SetTextFGColor(gfx_red);
	gfx_SetTextScale(3, 3);
	gfx_PrintStringXY("AspirinCE", 60, 5);
	gfx_SetTextScale(1, 1);
	gfx_SetTextFGColor(gfx_green);
	gfx_PrintStringXY("2nd to start", 110, 45);
	if (difficulty == 1)
		gfx_PrintStringXY("Difficulty:  Easy", 95, 65);
	if (difficulty == 2)
		gfx_PrintStringXY("Difficulty:  Medium", 95, 65);
	if (difficulty == 3)
		gfx_PrintStringXY("Difficulty:  Hard", 95, 65);
	gfx_SetTextFGColor(48);
	gfx_PrintStringXY("Highscores", 110, 150);
	gfx_PrintStringXY("Easy: ", 110, 165);
	gfx_PrintStringXY("Medium: ", 110, 175);
	gfx_PrintStringXY("Hard: ", 110, 185);
	gfx_SetTextXY(175, 165);
	gfx_PrintUInt(appVar.easyHighscore, 2);
	gfx_SetTextXY(175, 175);
	gfx_PrintUInt(appVar.mediumHighscore, 2);
	gfx_SetTextXY(175, 185);
	gfx_PrintUInt(appVar.hardHighscore, 2);
	updateMenuLines();
}

void renderMenu(void) {
	gfx_SetColor(gfx_white);
	gfx_FillRectangle(95, 65, 160, 10);
	gfx_SetTextFGColor(gfx_red);
	if (difficulty == 1)
		gfx_PrintStringXY("Difficulty:  Easy", 95, 65);
	if (difficulty == 2)
		gfx_PrintStringXY("Difficulty:  Medium", 95, 65);
	if (difficulty == 3)
		gfx_PrintStringXY("Difficulty:  Hard", 95, 65);
	updateMenuLines();
}

void updateMenuLines(void) {
	if (y <= 0) {
		goUp = false;
	}
	if (y >= 224) {
		goUp = true;
	}
	if (goUp == true) {
		y -= 4;
	}
	if (goUp == false) {
		y += 4;
	}
	gfx_FillRectangle(20, 0, 3, 240);
	gfx_FillRectangle(300, 0, 3, 240);
	gfx_SetColor(gfx_black);
	gfx_FillRectangle(20, y, 3, 20);
	gfx_SetPixel(20 + 1, y - 1);
	gfx_SetPixel(20 + 1, y + 20);
	gfx_FillRectangle(300, y, 3, 20);
	gfx_SetPixel(300 + 1, y - 1);
	gfx_SetPixel(300 + 1, y + 20);
}

/* The Game */
void inGame(uint8_t numLines) {
	kb_key_t key = 0;
	int pointX = randInt(70, 233);
	int pointY = randInt(35, 198);
	int i = 0;
	uint8_t score = 0;
	bool pointGrabbed = false;
	gfx_SetDrawScreen();
	gfx_FillScreen(136);
	gfx_SetDrawBuffer();
	gfx_FillScreen(136);
	for (i = 0; i < numLines; i++) {
		my_line_t *this_line = &lines[i];
		this_line->y = 30;
		this_line->goingRight = true;
	}

	while (kb_Data[kb_group_6] != kb_Clear && !quit) {
		int testx, testy;
		uint8_t ressq;
		//Erase Screen
		gfx_SetColor(gfx_white);
		gfx_FillRectangle(64, 29, 183, 185);
		//Aspirin Point movement and grabbing
		if (pointGrabbed == true) {
			pointX = randInt(70, 233);
			pointY = randInt(35, 198);
			addLines(numLines);
			pointGrabbed = false;
			score++;
		}
		if (pointGrabbed == false) {
			gfx_SetColor(gfx_red);
			gfx_Circle(pointX, pointY, 6);
			gfx_Circle(pointX, pointY, 5);
		}
		testx = playerX - pointX;
		testy = playerY - pointY;
		ressq = sqrt(testx * testx + testy * testy);
		if (ressq <= 10 && ressq >= 0) {
			pointGrabbed = true;
		}
		//Move Player and Draw
		gfx_SetColor(gfx_white);
		gfx_FillCircle(playerX, playerY, 4);
		if (key & kb_Up && playerY >= 36)
			playerY -= 3;
		if (key & kb_Down && playerY < 203)
			playerY += 3;
		if (key & kb_Left && playerX > 70)
			playerX -= 3;
		if (key & kb_Right && playerX < 236)
			playerX += 3;
		gfx_SetColor(gfx_blue);
		gfx_FillCircle(playerX, playerY, 4);
		gfx_SetColor(136);
		gfx_FillRectangle(158, 1, 30, 10);
		gfx_SetTextFGColor(0);
		gfx_SetTextXY(158, 1);
		gfx_PrintUInt(score, 3);
		updateLines();
		drawLines(gfx_black);
		checkForStab();
		gfx_SwapDraw();
		//Scan Keypad
		kb_Scan();
		key = kb_Data[kb_group_7];
	}
	if (score > appVar.easyHighscore && difficulty == 1) {
		//overwrite Easy high
		appVar.easyHighscore = score;

	}
	if (score > appVar.mediumHighscore && difficulty == 2) {
		//overwrite Medium high
		appVar.mediumHighscore = score;

	}
	if (score > appVar.hardHighscore && difficulty == 3) {
		//overwrite Hard high
		appVar.hardHighscore = score;
	}
	ti_CloseAll();
	writeAppVar();
}

/* Draw the lines while in game. */ 
void drawLines(uint8_t color) {
	uint8_t i = 0;
	gfx_SetColor(color);
	for (i = 0; i < numberOfLines; i++) {
		my_line_t *this_line = &lines[i];
		if (this_line->direction == false) {
			gfx_FillRectangle(this_line->x, this_line->y, 20, 3);
			gfx_SetPixel(this_line->x - 1, this_line->y + 1);
			gfx_SetPixel(this_line->x + 20, this_line->y + 1);
		}
		if (this_line->direction == true) {
			gfx_FillRectangle(this_line->x, this_line->y, 3, 20);
			gfx_SetPixel(this_line->x + 1, this_line->y - 1);
			gfx_SetPixel(this_line->x + 1, this_line->y + 20);
		}
	}
}
/* Check for collision with lines. */
void checkForStab(void) {
	int i = 0;
	for (i = 0; i < 8; i++) {
		if (gfx_GetPixel(playerX - 4 + i, playerY - 3) == gfx_black)
			quit = true;
	}
	for (i = 0; i < 8; i++) {
		if (gfx_GetPixel(playerX + 3, playerY - 4 + i) == gfx_black)
			quit = true;
	}
	for (i = 0; i < 8; i++) {
		if (gfx_GetPixel(playerX + 4 - i, playerY + 3) == gfx_black)
			quit = true;
	}
	for (i = 0; i < 8; i++) {
		if (gfx_GetPixel(playerX - 3, playerY + 4 - i) == gfx_black)
			quit = true;
	}
}

/* Update the coordinates of the lines. */
void updateLines(void) {
	uint8_t i;
	for (i = 0; i < numberOfLines; i++) {
		my_line_t *this_line = &lines[i];
		if (this_line->x <= 66 && this_line->direction == false) {
			this_line->goingRight = true;
		}
		if (this_line->x >= 223 && this_line->direction == false) {
			this_line->goingRight = false;
		}
		if (this_line->y <= 34 && this_line->direction == true) {
			this_line->goingRight = true;
		}
		if (this_line->y >= 193 && this_line->direction == true) {
			this_line->goingRight = false;
		}
		if (this_line->direction == false && this_line->goingRight == true)
			this_line->x += 3;
		if (this_line->direction == true && this_line->goingRight == true)
			this_line->y += 3;
		if (this_line->direction == false && this_line->goingRight == false)
			this_line->x -= 3;
		if (this_line->direction == true && this_line->goingRight == false)
			this_line->y -= 3;
	}
}

/* Add more lines when a point is collected */
void addLines(uint8_t number) {
	uint8_t i;
	for (i = numberOfLines; i < numberOfLines + number; i++) {
		my_line_t *this_line = &lines[i];
		this_line->direction = randInt(0, 1);
		if (this_line->direction == 1) {
			if (randInt(1, 0) == 1) {
				this_line->y = 37;
			} else {
				this_line->y = 194;
			}
			this_line->x = randInt(66, 223);
		}
		if (this_line->direction == 0) {
			if (randInt(1, 0) == 1) {
				this_line->x = 66;
			} else {
				this_line->x = 223;
			}
			this_line->y = randInt(34, 194);
		}
		this_line->goingRight = true;
	}
	numberOfLines += number;
}


/* You lost */
