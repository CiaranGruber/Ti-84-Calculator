//--------------------------------------
// Program Name: Set
// Author: BasicTH
// License: 
// Description: Set v1.0
//--------------------------------------

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
#include <fileioc.h>
#include <debug.h>

#include "gfx/logo_gfx.h"

void addCard(uint8_t newCard, uint8_t nope);
void selectCard();
void dissect(uint8_t disCard, uint8_t index);
uint8_t getNecCard(uint8_t a, uint8_t b);
void calcPos();
void drawMenu();
void drawHowTo(uint8_t page);
void drawMode();
void drawGame();
void drawBack();
void drawCard(uint16_t x, uint8_t y, uint8_t number, bool showKey);
void drawShape(uint16_t x, uint8_t y, uint8_t shape, uint8_t color, uint8_t fill);
void drawGameOver();
void updateTime();
void drawTime(bool buffer);
void printTime(uint16_t t);
void altDelay(uint16_t ms);
void writeAppVar();
void loadAppVar();

uint8_t cards[15];
uint8_t cardSelect[2] = {15, 15};
uint8_t cardProp[3][4];
uint16_t setsFound;
uint8_t mode, setsPos, select, correct;
uint8_t c, i, j, k;
const char *menuStr[] = {"  PLAY", "HOW TO", "  QUIT", "CAREFREE", "RUSH", "MARATHON"};
const char *keyStr[] = {"[math]", "[apps]", "[prgm]", "[vars]", "[clear]", "[x^-1]", "[sin]", "[cos]", "[tan]", "[^]", "[x^2]", "[,]", "[(]", "[)]", "[/]"};
uint16_t time;
bool quit;

typedef struct appVar {
	uint8_t setScore[9];
	uint16_t timeScore[9];
} appVar_t;
appVar_t SETSCR;
ti_var_t slot;


void main(void){
	loadAppVar();
	srand(rtc_Time());
	
	gfx_SetTextTransparentColor(1);
	gfx_SetTextBGColor(0x01);
	gfx_Begin(gfx_8bpp);
MENU:
    timer_Control = TIMER1_DISABLE;
	timer_1_ReloadValue = timer_1_Counter = 32768;
	
	for(c = 0; c < 15; c++) cards[c] = 81;
	addCard(0, 81); addCard(1, 81); cards[2] = getNecCard(cards[0], cards[1]);
	
	drawMenu();
	
	while(kb_AnyKey()) kb_Scan();
	while(true){
		kb_Scan();
		
		if(kb_Data[1] & kb_Del) goto EXIT;
		
		if((kb_Data[6] & kb_Enter) | (kb_Data[1] & kb_2nd)){
			correct = 1+(int)(select == 2); drawMenu(); correct = 0;
			delay(450);
			if(select == 0) goto MODE;
			if(select == 1) goto HOWTO;
			if(select == 2) goto EXIT;
		}

		switch(kb_Data[7]){
			case kb_Left:
				select = (select+2)%3;
				drawMenu(); while(kb_Data[7] & kb_Left) kb_Scan();
				break;
			case kb_Right:
				select = (select+1)%3;
				drawMenu(); while(kb_Data[7] & kb_Right) kb_Scan();
				break;
		}
	}

HOWTO:
	correct = 0;
	select = 0;
	
	drawHowTo(0);
	
	while(kb_AnyKey()) kb_Scan();
	while(true){
		kb_Scan();
		
		if(kb_Data[1] & kb_Del){select = 1; goto MENU;}
		
		if((kb_Data[6] & kb_Enter) | (kb_Data[1] & kb_2nd)){
			if(select < 2){select = select+1;}else{select = 1; goto MENU;}
			drawHowTo(select); while((kb_Data[6] & kb_Enter) | (kb_Data[1] & kb_2nd)) kb_Scan();
		}
		
		switch(kb_Data[7]){
			case kb_Left:
				if(select > 0) select = select-1;
				drawHowTo(select); while(kb_Data[7] & kb_Left) kb_Scan();
				break;
			case kb_Right:
				if(select < 2) select = select+1;
				drawHowTo(select); while(kb_Data[7] & kb_Right) kb_Scan();
				break;
		}
	}
	
MODE:
	select = mode;
	quit = false;
	correct = 0;
	for(c = 0; c < 15; c++) cards[c] = 81;
	addCard(0, 81); addCard(1, 81); cards[2] = getNecCard(cards[0], cards[1]);
	
	drawMode();
	
	while(kb_AnyKey()) kb_Scan();
	while(true){
		kb_Scan();
		
		if(kb_Data[1] & kb_Del){select = 0; goto MENU;}
		
		if((kb_Data[6] & kb_Enter) | (kb_Data[1] & kb_2nd)){
			if(select == 0) mode = 0;
			if(select == 1) mode = 1;
			if(select == 2) mode = 2;
			correct = 1; drawMode(); correct = 0;
			delay(350);
			goto GAME;
		}
		
		switch(kb_Data[7]){
			case kb_Up:
				select = (select+2)%3;
				drawMode(); while(kb_Data[7] & kb_Up) kb_Scan();
				break;
			case kb_Down:
				select = (select+1)%3;
				drawMode(); while(kb_Data[7] & kb_Down) kb_Scan();
				break;
		}
	}
	
GAME:
	setsFound = 0;
	select = 7;
	
	do{
		for(c = 0; c < 15; c++) cards[c] = 81;
		for(c = 0; c < 15; c++) addCard(c, 81);
		calcPos();
	}while(setsPos == 0);
	
	timer_Control = TIMER1_ENABLE | TIMER1_32K | TIMER1_0INT | TIMER1_DOWN;
	if(mode > 0){time = (mode == 1) ? 120 : 0;}
	drawGame();
	if(mode > 0){
		for(i = 0; i < 4; i++){
			gfx_SetColor(0x9B); gfx_FillRectangle_NoClip(0, 115, 320, 11);
			gfx_SetColor(0x51); gfx_FillRectangle_NoClip(0, 109, 320, 6); gfx_FillRectangle_NoClip(0, 126, 320, 6);
			gfx_SetColor(0x28); gfx_FillRectangle_NoClip(0, 111, 320, 2); gfx_FillRectangle_NoClip(0, 128, 320, 2);
			gfx_SetTextFGColor(0xFF);
			if(i < 3){
				gfx_SetTextXY(157, 117); gfx_PrintUInt(3-i,1);
			}else{
				gfx_SetTextXY(152, 117); gfx_PrintString("GO");
			}
			
			gfx_BlitLines(gfx_buffer, 109, 23);
			delay(1000);
		}
		drawGame();
		time = (mode == 1) ? 121 : 65535;
	}
	
	while(kb_AnyKey()) kb_Scan();
	while(true){
        updateTime(); if(quit) goto MODE;
		kb_Scan();
		
		if(kb_Data[1] & kb_Del){select = 0; cardSelect[0] = 15; cardSelect[1] = 15; goto MODE;}
		
		if((kb_Data[6] & kb_Enter) | (kb_Data[1] & kb_2nd)){
			selectCard(select); if(quit) goto MODE;
			drawGame(); while((kb_Data[6] & kb_Enter) | (kb_Data[1] & kb_2nd)){kb_Scan(); updateTime(); if(quit) goto MODE;}
		}
		
		switch(kb_Data[7]){
			case kb_Left:
				select = (select+4)%5 + select-(select%5);
				drawGame(); while(kb_Data[7] & kb_Left){kb_Scan(); updateTime(); if(quit) goto MODE;}
				break;
			case kb_Right:
				select = (select+1)%5 + select-(select%5);
				drawGame(); while(kb_Data[7] & kb_Right){kb_Scan(); updateTime(); if(quit) goto MODE;}
				break;
			case kb_Up:
				select = (select+10)%15;
				drawGame(); while(kb_Data[7] & kb_Up){kb_Scan(); updateTime(); if(quit) goto MODE;}
				break;
			case kb_Down:
				select = (select+5)%15;
				drawGame(); while(kb_Data[7] & kb_Down){kb_Scan(); updateTime(); if(quit) goto MODE;}
				break;
		}
		
		for(c = 0; c < 15; c++){
			if(kb_Data[2+c%5] == (uint8_t) (8*pow(2, 3-c/5))){
				select = c; selectCard(c); if(quit) goto MODE;
				drawGame();
				while(kb_Data[2+c%5] & (uint8_t) (8*pow(2, 3-c/5))){kb_Scan(); updateTime(); if(quit) goto MODE;}
			}
		}
	}
	
EXIT:
	writeAppVar();
	gfx_End();
    timer_Control = TIMER1_DISABLE;
}

void addCard(uint8_t newCard, uint8_t nope){
	bool retry;
	do{
		retry = false;
		cards[newCard] = randInt(0,80);
		for(i = 0; i < 15; i++){
			if(newCard == i){continue;}
			if(cards[i] == cards[newCard] || nope == cards[newCard]){retry = true;}
		}
	}while(retry);
}

void selectCard(){
	if(cardSelect[0] == select){cardSelect[0] = cardSelect[1]; cardSelect[1] = 15; return;}
	if(cardSelect[1] == select){cardSelect[1] = 15; return;}
	if(cardSelect[0] == 15){cardSelect[0] = select; return;}
	if(cardSelect[1] == 15){cardSelect[1] = select; return;}
	if(cards[select] == getNecCard(cards[cardSelect[0]], cards[cardSelect[1]])){correct = 1; setsFound++;}else{correct = 2;}
	drawGame();
	altDelay(50+150*correct);
	correct = 0;
	if(cards[select] == getNecCard(cards[cardSelect[0]], cards[cardSelect[1]])){
		do{
			addCard(cardSelect[0], cards[cardSelect[0]]);
			addCard(cardSelect[1], cards[cardSelect[1]]);
			addCard(select, cards[select]);
			calcPos();
		}while(setsPos == 0);
		
		if(mode == 2 && setsFound == 15){
			timer_Control = TIMER1_DISABLE;
			cardSelect[0] = 15; cardSelect[1] = 15;
			drawGame();
			drawGameOver();
			for(i = 0; i < 9; i++){
				if(time < SETSCR.timeScore[i] || SETSCR.timeScore[i] == 0){
					for(j = 8; j > i; j--) SETSCR.timeScore[j] = SETSCR.timeScore[j-1];
					SETSCR.timeScore[i] = time;
					quit = true;
				}
				if(quit) break;
			}
			quit = true;
			writeAppVar();
			delay(2000);
			return;
		}
	}
	cardSelect[0] = 15; cardSelect[1] = 15;
}

void dissect(uint8_t disCard, uint8_t index){
	cardProp[index][3] = disCard%3;
	cardProp[index][2] = ((disCard-cardProp[index][3])/3)%3;
	cardProp[index][1] = ((disCard-cardProp[index][3]-3*cardProp[index][2])/9)%3;
	cardProp[index][0] = ((disCard-cardProp[index][3]-3*cardProp[index][2]-9*cardProp[index][1])/27)%3;
}

uint8_t getNecCard(uint8_t a, uint8_t b){
	dissect(a, 0); dissect(b, 1);
	for(k = 0; k < 4; k++) cardProp[2][k] = (6-cardProp[0][k]-cardProp[1][k])%3;
	return cardProp[2][0]*27+cardProp[2][1]*9+cardProp[2][2]*3+cardProp[2][3];
}

void calcPos(){
	setsPos = 0;
	for(i = 0; i < 13; i++){
		for(j = i+1; j < 14; j++){
			int n = getNecCard(cards[i], cards[j]);
			for(k = j+1; k < 15; k++){
				if(n == cards[k]) setsPos++;
			}
		}
	}
}

void drawMenu(){
	gfx_SetDrawBuffer();
	
	drawBack();
    gfx_Sprite(logo, 63, 40);
	gfx_SetTextFGColor(0x51);
	for(i = 0; i < 3; i++){
		drawCard(94+50*i, 156, i, false);
		gfx_SetTextXY(89+50*i, 147); gfx_PrintString(menuStr[i]);
	}
	
	gfx_SwapDraw();
}

void drawHowTo(uint8_t page){
	gfx_SetDrawBuffer();
	
	drawBack();
	switch(page){
		case 0:
			gfx_SetTextFGColor(0xFF);
			gfx_SetTextXY(249, 2); gfx_PrintString("Examples >");
			gfx_SetTextFGColor(0x28);
			gfx_SetTextXY(140, 20); gfx_PrintString("RULES");
			gfx_SetTextFGColor(0x51);
			gfx_SetTextXY(10, 34); gfx_PrintString("The objective of the game is to identify a");
			gfx_SetTextXY(10, 44); gfx_PrintString("valid Set of 3 cards from 15 cards. Each");
			gfx_SetTextXY(10, 54); gfx_PrintString("card has symbols on it, with 4 properties:");
			gfx_SetTextXY(16, 68); gfx_PrintString("- Amount:");
			gfx_SetTextXY(16, 78); gfx_PrintString("- Shape:");
			gfx_SetTextXY(16, 88); gfx_PrintString("- Color:");
			gfx_SetTextXY(16, 98); gfx_PrintString("- Shading:");
			gfx_SetTextXY(10, 112); gfx_PrintString("A Set is valid if every property either is");
			gfx_SetTextXY(10, 122); gfx_PrintString("the same or differs on every of the 3");
			gfx_SetTextXY(10, 132); gfx_PrintString("selected cards. If one property does not");
			gfx_SetTextXY(10, 142); gfx_PrintString("meet this requirement, the Set is invalid.");
			gfx_SetTextXY(10, 152); gfx_PrintString("This means, if you can say:");
			gfx_SetTextXY(10, 180); gfx_PrintString("the Set is invalid.");
			gfx_SetTextFGColor(0x9B);
			gfx_SetTextXY(96, 68); gfx_PrintString("One, Two or Three");
			gfx_SetTextXY(96, 78); gfx_PrintString("Square, Circle or Triangle");
			gfx_SetTextXY(96, 88); gfx_PrintString("Red, Green or Blue");
			gfx_SetTextXY(96, 98); gfx_PrintString("Full, Half or Empty");
			gfx_SetTextXY(16, 166); gfx_PrintString("\"Two have this and the other has that\"");
			break;
		case 1:
			gfx_SetTextFGColor(0xFF);
			gfx_SetTextXY(2, 2); gfx_PrintString("< Rules");
			gfx_SetTextXY(250, 2); gfx_PrintString("Controls >");
			gfx_SetTextFGColor(0x28);
			gfx_SetTextXY(128, 20); gfx_PrintString("EXAMPLES");
			gfx_SetTextFGColor(0x51);
			gfx_SetTextXY(10, 34); gfx_PrintString("The following example Sets serve as a");
			gfx_SetTextXY(10, 44); gfx_PrintString("demonstration of what is valid and invalid:");
			gfx_SetTextFGColor(0x06);
			gfx_SetTextXY(58, 72); gfx_PrintString("VALID");
			gfx_SetTextFGColor(0xE0);
			gfx_SetTextXY(214, 72); gfx_PrintString("INVALID");
			addCard(3, 81); addCard(4, cards[3]); cards[5] = getNecCard(cards[3], cards[4]);
			addCard(6, 81); addCard(7, cards[6]); cards[8] = getNecCard(cards[6], cards[7]);
			addCard(9, 81); addCard(10, cards[9]); addCard(11, getNecCard(cards[9], cards[10]));
			addCard(12, 81); addCard(13, cards[12]); addCard(14, getNecCard(cards[12], cards[13]));
			for(i = 0; i < 6; i++) drawCard(20+42*(i%3), 84+60*(i/3), i+3, false);
			for(i = 0; i < 6; i++) drawCard(184+42*(i%3), 84+60*(i/3), i+9, false);
			gfx_SetColor(0x9B); gfx_Line_NoClip(159, 66, 159, 198);
			break;
		case 2:
			gfx_SetTextFGColor(0xFF);
			gfx_SetTextXY(2, 2); gfx_PrintString("< Examples");
			gfx_SetTextFGColor(0x28);
			gfx_SetTextXY(128, 20); gfx_PrintString("CONTROLS");
			gfx_SetTextFGColor(0x51);
			gfx_SetTextXY(112, 34); gfx_PrintString("Select / Deselect");
			gfx_SetTextXY(112, 44); gfx_PrintString("Move Cursor");
			gfx_SetTextXY(112, 54); gfx_PrintString("Quit");
			gfx_SetTextXY(10, 68); gfx_PrintString("Cards can also be selected by pressing");
			gfx_SetTextXY(10, 78); gfx_PrintString("their corresponding keys:");
			gfx_SetTextFGColor(0x9B);
			gfx_SetTextXY(10, 34); gfx_PrintString("[2nd], [enter]");
			gfx_SetTextXY(10, 44); gfx_PrintString("[Arrow Keys]");
			gfx_SetTextXY(10, 54); gfx_PrintString("[del]");
			for(i = 0; i < 15; i++){gfx_SetTextXY(37+50*(i%5), 96+14*(i/5)); gfx_PrintString(keyStr[i]);}
			break;
	}
	
	gfx_SwapDraw();
}

void drawMode(){
	gfx_SetDrawBuffer();
	
	drawBack();
	gfx_SetTextFGColor(0x51);
	for(i = 0; i < 3; i++){
		drawCard(44, 36+60*i, i, false);
		gfx_SetTextXY(44, 27+60*i); gfx_PrintString(menuStr[i+3]);
	}
	if(select == 0){
		gfx_SetTextXY(172,138); gfx_PrintString("No limits, play the");
		gfx_SetTextXY(172,148); gfx_PrintString("game without stress");
		gfx_SetTextXY(172,158); gfx_PrintString("or practice without");
		gfx_SetTextXY(172,168); gfx_PrintString("worries.");
	}
	if(select == 1){
		gfx_SetTextXY(172,138); gfx_PrintString("Time limit, try to");
		gfx_SetTextXY(172,148); gfx_PrintString("find as many valid");
		gfx_SetTextXY(172,158); gfx_PrintString("Sets within 2");
		gfx_SetTextXY(172,168); gfx_PrintString("minutes.");
	}
	if(select == 2){
		gfx_SetTextXY(172,138); gfx_PrintString("Set limit, try to");
		gfx_SetTextXY(172,148); gfx_PrintString("find 15 valid Sets");
		gfx_SetTextXY(172,158); gfx_PrintString("as fast as possible.");
	}
	
	gfx_SetColor(0xDD);
	gfx_Rectangle_NoClip(170, 35, 120, 81);
	gfx_SetTextXY(172, 27); gfx_PrintString("Hi-Scores");
	for(i = 0; i < 9; i++){
		if(i%2 == 0) gfx_FillRectangle_NoClip(170, 35+9*i, 120, 9);
		gfx_SetTextXY(172, 36+9*i); gfx_PrintUInt(i+1, 1); gfx_PrintString(":");
		gfx_SetTextXY(192, 36+9*i);
		if(select == 0 && i == 4){gfx_PrintString("          N/A");}
		if(select == 1){
			gfx_PrintUInt(SETSCR.setScore[i], (int) log10(SETSCR.setScore[i])+1);
		}
		if(select == 2){
			if(SETSCR.timeScore[i] > 0){printTime(SETSCR.timeScore[i]);}else{gfx_PrintString("--:--");}
		}
	}
	
	gfx_SetTextFGColor(0x9B);
	gfx_SetTextXY(172,126); gfx_PrintString(menuStr[select+3]);
	
	gfx_SwapDraw();
}

void drawGame(){
	gfx_SetDrawBuffer();
	
	drawBack();
	gfx_SetTextFGColor(0xFF);
	gfx_SetTextXY(2, 2); gfx_PrintString("Sets Found: "); gfx_PrintUInt(setsFound, (int) log10(setsFound)+1); if(mode == 2) gfx_PrintString("/15");
	gfx_SetTextXY(205, 2); gfx_PrintString("Sets Possible: "); gfx_PrintUInt(setsPos, 2);
	for(i = 0; i < 15; i++) drawCard(44+50*(i%5), 36+60*(i/5), i, true);
	drawTime(false);
	
	gfx_SwapDraw();
}

void drawBack(){
	gfx_FillScreen(0xFF);
	gfx_SetColor(0x9B); gfx_FillRectangle_NoClip(0, 0, 320, 11); gfx_FillRectangle_NoClip(0, 229, 320, 11);
	gfx_SetColor(0x51); gfx_FillRectangle_NoClip(0, 11, 320, 6); gfx_FillRectangle_NoClip(0, 223, 320, 6);
	gfx_SetColor(0x28); gfx_FillRectangle_NoClip(0, 13, 320, 2); gfx_FillRectangle_NoClip(0, 225, 320, 2);
	gfx_SetTextFGColor(0xDD); gfx_SetTextScale(1, 1);
	gfx_SetTextXY(2, 231); gfx_PrintString("(C) 2019 BasicTH");
	gfx_SetTextXY(245, 231); gfx_PrintString("Version 1.0");
}

void drawCard(uint16_t x, uint8_t y, uint8_t number, bool showKey){
	if(cardSelect[0] == number || cardSelect[1] == number){gfx_SetColor(0xEF);}else{gfx_SetColor(0xFF);}
	if(correct != 0 && (cardSelect[0] == number || cardSelect[1] == number || select == number)){
		if(correct == 1){gfx_SetColor(0xAF);} if(correct == 2){gfx_SetColor(0xEE);}
	}
	gfx_FillRectangle_NoClip(x+1, y+1, 30, 46);
	if(select == number){gfx_SetColor(0xA0);}else{gfx_SetColor(0x00);}
	gfx_Rectangle_NoClip(x, y, 32, 48);
	if(select == number){gfx_SetColor(0xE0);}else{gfx_SetColor(0xB5);}
	gfx_Rectangle_NoClip(x+1, y+1, 30, 46);
	
	if(cardSelect[0] == number || cardSelect[1] == number){gfx_SetColor(0xBF);}else{gfx_SetColor(0xFF);}
	dissect(cards[number], 0);
	switch(cardProp[0][0]){
		case 0:
			drawShape(x+16, y+24, cardProp[0][1], cardProp[0][2], cardProp[0][3]);
			break;
		case 1:
			drawShape(x+16, y+17, cardProp[0][1], cardProp[0][2], cardProp[0][3]);
			drawShape(x+16, y+31, cardProp[0][1], cardProp[0][2], cardProp[0][3]);
			break;
		case 2:
			drawShape(x+11, y+10, cardProp[0][1], cardProp[0][2], cardProp[0][3]);
			drawShape(x+21, y+24, cardProp[0][1], cardProp[0][2], cardProp[0][3]);
			drawShape(x+11, y+38, cardProp[0][1], cardProp[0][2], cardProp[0][3]);
			break;
	}
	
	if(showKey){
		gfx_SetTextFGColor(0xB5);
		gfx_SetTextXY(x, y+49); gfx_PrintString(keyStr[number]);
	}
}

void drawShape(uint16_t x, uint8_t y, uint8_t shape, uint8_t color, uint8_t fill){
	uint8_t fc = 0, bc = 0;
	switch(color){
		case 0:
			fc = 0xF4; bc = 0xE0;
			break;
		case 1:
			fc = 0xB7; bc = 0x06;
			break;
		case 2:
			fc = 0x5D; bc = 0x18;
			break;
	}
	switch(fill){
		case 0:
			gfx_SetColor(bc);
			break;
		case 1:
			gfx_SetColor(fc);
			break;
		case 2:
			if(cardSelect[0] == i || cardSelect[1] == i){gfx_SetColor(0xEF);}else{gfx_SetColor(0xFF);}
			if(correct != 0 && (cardSelect[0] == i || cardSelect[1] == i || select == i)){
				if(correct == 1){gfx_SetColor(0xAF);} if(correct == 2){gfx_SetColor(0xEE);}
			}
			break;
	}
	switch(shape){
		case 0:
			gfx_FillRectangle_NoClip(x-6, y-6, 12, 12);
			gfx_SetColor(bc); gfx_Rectangle_NoClip(x-6, y-6, 12, 12);
			break;
		case 1:
			gfx_FillCircle_NoClip(x, y, 6);
			gfx_SetColor(bc); gfx_Circle(x, y, 6);
			break;
		case 2:
			gfx_FillTriangle_NoClip(x-6, y+6, x, y-6, x+6, y+6);
			gfx_SetColor(bc);
			gfx_Line_NoClip(x-6, y+6, x, y-5);
			gfx_Line_NoClip(x+6, y+6, x, y-6);
			gfx_Line_NoClip(x-6, y+6, x+6, y+6);
			break;
	}
}

void updateTime(){	
	if(timer_IntStatus & TIMER1_RELOADED){
		if(mode == 1){time--;}
		if(mode == 2){time++;}
		timer_IntAcknowledge = TIMER1_RELOADED;
	}
	
	if(mode == 1 && time == 0){
		timer_Control = TIMER1_DISABLE;
		drawGame();
		drawGameOver();
		cardSelect[0] = 15; cardSelect[1] = 15;
		for(i = 0; i < 9; i++){
			if(setsFound > SETSCR.setScore[i]){
				for(j = 8; j > i; j--) SETSCR.setScore[j] = SETSCR.setScore[j-1];
				SETSCR.setScore[i] = setsFound;
				quit = true;
			}
			if(quit) break;
		}
		quit = true;
		writeAppVar();
		delay(2000);
		return;
	}
	
	drawTime(true);
}

void drawGameOver(){
	gfx_SetColor(0x9B); gfx_FillRectangle_NoClip(0, 110, 320, 20);
	gfx_SetColor(0x51); gfx_FillRectangle_NoClip(0, 104, 320, 6); gfx_FillRectangle_NoClip(0, 130, 320, 6);
	gfx_SetColor(0x28); gfx_FillRectangle_NoClip(0, 106, 320, 2); gfx_FillRectangle_NoClip(0, 132, 320, 2);
	gfx_SetTextFGColor(0xFF);
	gfx_SetTextXY(127, 112); gfx_PrintString("GAME OVER");
	if(mode == 1){
		gfx_SetTextXY(129, 121); gfx_PrintString("Score: "); gfx_PrintUInt(setsFound, 2);
	}
	if(mode == 2){
		gfx_SetTextXY(126, 121); gfx_PrintString("Time: "); printTime(time);
	}
	
	gfx_BlitLines(gfx_buffer, 104, 32);
}

void drawTime(bool buffer){
	if(mode == 0) return;
	gfx_SetColor(0xFF);
	gfx_FillRectangle(0, 22, 320, 7);
	gfx_SetTextFGColor(0x9B);
	gfx_SetTextXY(143, 22); printTime(time);
	if(buffer) gfx_BlitLines(gfx_buffer, 22, 7);
}

void printTime(uint16_t t){
	gfx_PrintUInt(t/60, 2); gfx_PrintString(":"); gfx_PrintUInt(t%60, 2);
}

void altDelay(uint16_t ms){
	if(mode == 0){delay(ms); return;}
	for(i = 0; i < ms/3; i++){
		updateTime(); if(quit) return;
		delay(2);
	}
}

void writeAppVar(void) {
    ti_CloseAll();
    if(slot = ti_Open("SETSCR", "w")){
		ti_Write(&SETSCR, sizeof(SETSCR), 1, slot);
	}
	ti_SetArchiveStatus(true, slot);
    ti_CloseAll();
}

void loadAppVar(){
    ti_CloseAll();
    if(slot = ti_Open("SETSCR", "r")){
		ti_Read(&SETSCR, sizeof(SETSCR), 1, slot);
	}
	ti_CloseAll();
}