//--------------------------------------
// Program Name: SolitiCE
// Author: BasicTH
// License: 
// Description: SolitiCE v2.0
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

#include "gfx/sprites.h"

void setupGame();
void selectCard(uint8_t x, uint8_t y, uint8_t h);
bool matchVal(uint8_t c, uint8_t s);
void updateStats();
void correctMove();
void drawMenu(uint8_t page);
void drawGame();
void drawBack();
void drawCard(uint16_t x, uint8_t y, uint8_t val, uint8_t type, bool hidden);
void gfx_Circtangle(uint16_t x, uint8_t y, uint16_t w, uint8_t h, bool filled);
void updateTime();
uint8_t max(int16_t a, int16_t b);
uint8_t min(int16_t c, int16_t d);
void writeAppVar();
void loadAppVar();

uint8_t i, j;
uint8_t cx, cy, sx, sy, hold;
bool autoFinish;
char *vals[13] = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"};
char *menuStr[9] = {"New Game", "Load Game", "Settings", "Controls", "Quit", "Gameplay", "Graphics", "Reset Cumulative Score", "Cancel"};
char *optNameStr[6] = {"Draw Card:", "Move Counter/Clock:", "Scoring System:", "Auto-Finish:", "Pictograms:", "Card Back:"};
char *optPosStr[8] = {"THREE", "ONE", "OFF", "ON", "NONE", "STANDARD", "VEGAS", "VEGAS CUMUL."};
char *ctrlStr[8] = {"[arrows]", "[2nd]", "[alpha]", "[clear]", "Move Cursor", "Select/Drop Stack", "Automove", "Quit Game"};
uint8_t menuOpt[6] = {5, 0, 3, 4, 2, 2};
uint8_t stackEx[7];
typedef struct AppVar{
	uint8_t options[6];
	uint8_t deckCard[7][19];
	uint8_t stackHid[7];
	uint8_t foundProg[4];
	uint8_t stockCard[24];
	uint8_t stockProg, stockSize, stockPass;
	uint16_t moves, time;
	int24_t score[3];
	bool gameEx;
} appVar_t;
appVar_t g;
ti_var_t slot;
gfx_sprite_t *sym[2][4];
gfx_sprite_t *back[6];
gfx_sprite_t *pic[4];
uint8_t kh;
typedef struct AnimCard{
	int16_t x, y;
	int8_t vx, vy;
	uint8_t type;
} animCard_t;
animCard_t animCard;

void main(){
	sym[0][0] = heart;
	sym[0][1] = diamond;
	sym[0][2] = spade;
	sym[0][3] = clover;
	sym[1][0] = heart_green;
	sym[1][1] = diamond_green;
	sym[1][2] = spade_green;
	sym[1][3] = clover_green;
	back[0] = back1;
	back[1] = back2;
	back[2] = back3;
	back[3] = back4;
	back[4] = back5;
	back[5] = back6;
	pic[0] = jack;
	pic[1] = queen;
	pic[2] = king;
	pic[3] = ace;
	
	loadAppVar();
	srand(rtc_Time());
	
	gfx_SetTransparentColor(0xF8);
	gfx_SetTextTransparentColor(0xF8);
	gfx_SetTextBGColor(0xF8);
    gfx_SetTextConfig(gfx_text_noclip);
	gfx_Begin(gfx_8bpp);
MENU:
    timer_Control = TIMER1_DISABLE;
	timer_1_ReloadValue = timer_1_Counter = 32768;
	
	hold = 0;
	cx = 0; cy = g.gameEx;
	drawMenu(cx);
	while(kb_AnyKey()) kb_Scan();
	while(true){
		if(!kb_AnyKey()) kh = 0;
		kb_Scan();
		
		if(kb_Data[6] & kb_Clear){
			if(cx == 0) goto EXIT;
			else{
				switch(cx){
					case 1: cy = 3; break;
					case 2: cy = 2; break;
					case 3: cy = 0; break;
					case 4: cy = 1; break;
					case 5: cy = 2; break;
				}
				cx = 2*(cx > 2);
				drawMenu(cx);
			}
			while(kb_Data[6] & kb_Clear) kb_Scan();
		}
		
		if(kb_Data[7]){
			switch(kb_Data[7]){
				case kb_Left:
					switch(cx){
						case 3:
							switch(cy){
								case 2: g.options[2] = (g.options[2]+3)%4; g.gameEx = false; drawMenu(cx); break;
								default: g.options[cy] = !g.options[cy]; drawMenu(cx); break;
							}
							break;
						case 4:
							switch(cy){
								case 1: g.options[5] = (g.options[5]+5)%6; drawMenu(cx); break;
								default: g.options[4+cy] = !g.options[4+cy]; drawMenu(cx); break;
							}
							break;
						break;
					}
					drawMenu(cx); while((kb_Data[7] & kb_Left) && kh < 150){kb_Scan(); kh++;}
					break;
				case kb_Right:
					switch(cx){
						case 3:
							switch(cy){
								case 2: g.options[2] = (g.options[2]+1)%4; g.gameEx = false; drawMenu(cx); break;
								default: g.options[cy] = !g.options[cy]; drawMenu(cx); break;
							}
							break;
						case 4:
							switch(cy){
								case 1: g.options[5] = (g.options[5]+1)%6; drawMenu(cx); break;
								default: g.options[4+cy] = !g.options[4+cy]; drawMenu(cx); break;
							}
							break;
						break;
					}
					drawMenu(cx); while((kb_Data[7] & kb_Right) && kh < 150){kb_Scan(); kh++;}
					break;
				case kb_Up:
					if(menuOpt[cx]) cy = (cy+menuOpt[cx]-1)%menuOpt[cx];
					drawMenu(cx); while((kb_Data[7] & kb_Up) && kh < 150){kb_Scan(); kh++;}
					break;
				case kb_Down:
					if(menuOpt[cx]) cy = (cy+1)%menuOpt[cx];
					drawMenu(cx); while((kb_Data[7] & kb_Down) && kh < 150){kb_Scan(); kh++;}
					break;
			}
			delay(50);
		}
		
		if((kb_Data[1] & kb_2nd) || (kb_Data[6] & kb_Enter)){
			switch(cx){
				case 0:
					switch(cy){
						case 0: goto NEWGAME; break;
						case 1: if(g.gameEx) goto GAME; break;
						case 2: cx = 2; cy = 0; drawMenu(cx); break;
						case 3: cx = 1; cy = 0; drawMenu(cx); break;
						case 4: goto EXIT; break;
						break;
					}
					break;
				case 2:
					switch(cy){
						case 0: cx = 3; cy = 0; drawMenu(cx); break;
						case 1: cx = 4; cy = 0; drawMenu(cx); break;
						case 2: cx = 5; cy = 1; drawMenu(cx); break;
					}
					break;
				case 3:
					switch(cy){
						case 2: g.options[2] = (g.options[2]+1)%4; g.gameEx = false; drawMenu(cx); break;
						default: g.options[cy] = !g.options[cy]; g.gameEx = false; drawMenu(cx); break;
					}
					break;
				case 4:
					switch(cy){
						case 1: g.options[5] = (g.options[5]+1)%6; drawMenu(cx); break;
						default: g.options[4+cy] = !g.options[4+cy]; drawMenu(cx); break;
					}
					break;
				case 5:
					switch(cy){
						case 0: cx = 2; cy = 2; g.score[1] = 0; g.gameEx = false; drawMenu(cx); break;
						case 1: cx = 2; cy = 2; drawMenu(cx); break;
					}
					break;
			}
			while((kb_Data[1] & kb_2nd) || (kb_Data[6] & kb_Enter)) kb_Scan();
		}
	}
	
NEWGAME:
	setupGame();
GAME:
	cx = 0; cy = 1;
	timer_Control = TIMER1_ENABLE | TIMER1_32K | TIMER1_0INT | TIMER1_DOWN;
	updateStats();
	drawGame();
	while(kb_AnyKey()) kb_Scan();
	while(true){
		updateTime();
		if(!kb_AnyKey()) kh = 0;
		kb_Scan();
		
		if(kb_Data[6] & kb_Clear) goto MENU;
		
		if(kb_Data[7]){
			switch(kb_Data[7]){
				case kb_Left:
					if(cx) cx--;
					if(cx == 2 && !cy) cx = 1;
					correctMove();
					drawGame(); while((kb_Data[7] & kb_Left) && kh < 150){kb_Scan(); updateTime(); kh++;}
					break;
				case kb_Right:
					if(cx < 6) cx++;
					if(cx == 2 && !cy) cx = 3;
					correctMove();
					drawGame(); while((kb_Data[7] & kb_Right) && kh < 150){kb_Scan(); updateTime(); kh++;}
					break;
				case kb_Up:
					if(cy) cy--;
					if(cy == g.stackHid[cx]) cy = 0;
					if(!cy && cx == 2) cx = 1;
					drawGame(); while((kb_Data[7] & kb_Up) && kh < 150){kb_Scan(); updateTime(); kh++;}
					break;
				case kb_Down:
					cy++;
					correctMove();
					drawGame(); while((kb_Data[7] & kb_Down) && kh < 150){kb_Scan(); updateTime(); kh++;}
					break;
			}
			delay(30);
		}
		
		if(kb_Data[2] & kb_Alpha){
			if(autoFinish){
				autoFinish = false;
				cx = 7;
				while(g.foundProg[0]+g.foundProg[1]+g.foundProg[2]+g.foundProg[3] < 52){
					cx = (cx+1)%7;
					cy = stackEx[cx];
					if(g.deckCard[cx][cy-1] == 13*(g.deckCard[cx][cy-1]/13)+g.foundProg[g.deckCard[cx][cy-1]/13] && cy){
						g.foundProg[g.deckCard[cx][cy-1]/13]++;
						g.deckCard[cx][cy-1] = 52;
						stackEx[cx]--;
						if(cy-1) cy--;
						g.moves++;
						if(g.options[2] == 1) g.score[0] += 10;
						if(g.options[2] > 1) g.score[g.options[2]-2] += 5;
						drawGame(); delay(20);
					}
				}
				goto WIN;
			}
			else if(hold) hold = 0;
			else if(cy && cy < stackEx[cx]) cy = stackEx[cx];
			else if(cy){
				if(g.deckCard[cx][cy-1] == 13*(g.deckCard[cx][cy-1]/13)+g.foundProg[g.deckCard[cx][cy-1]/13]){
					g.foundProg[g.deckCard[cx][cy-1]/13]++;
					g.deckCard[cx][cy-1] = 52;
					if(cy-1) cy--;
					g.moves++;
					if(g.options[2] == 1) g.score[0] += 10;
					if(g.options[2] > 1) g.score[g.options[2]-2] += 5;
					if(g.foundProg[0]+g.foundProg[1]+g.foundProg[2]+g.foundProg[3] == 52) goto WIN;
				}
			}else if(cx == 1){
				if(g.stockCard[g.stockProg-1] == 13*(g.stockCard[g.stockProg-1]/13)+g.foundProg[g.stockCard[g.stockProg-1]/13]){
					g.foundProg[g.stockCard[g.stockProg-1]/13]++;
					if(g.stockSize){
						for(i = g.stockProg; i < g.stockSize; i++) g.stockCard[i-1] = g.stockCard[i];
					}
					g.stockCard[g.stockSize-1] = 52;
					g.stockProg--; g.stockSize--;
					g.moves++;
					if(g.options[2] == 1) g.score[0] += 15;
					if(g.options[2] > 1) g.score[g.options[2]-2] += 5;
				}
			}
			updateStats();
			drawGame(); while(kb_Data[2] & kb_Alpha){updateTime(); kb_Scan();}
		}
		
		if((kb_Data[1] & kb_2nd) || (kb_Data[6] & kb_Enter)){
			if(!hold){
				if(!cx && !cy){
					if(g.stockSize){
						if(g.stockProg == g.stockSize){
							g.stockProg = 0;
							g.stockPass++;
							if(g.options[2] == 1){
								if(!g.options[0] && g.stockPass > 3) g.score[0] -= 20;
								if(g.options[0]) g.score[0] -= 100;
							}
						}else{
							if(g.stockSize-g.stockProg > 3-2*g.options[0]){
								g.stockProg += 3-2*g.options[0];
							}else g.stockProg = g.stockSize;
							g.moves++;
						}
					}
				}
				if(cx == 1 && !cy && g.stockProg) selectCard(cx, cy, 1);
				if(cx > 2 && !cy && g.foundProg[cx-3]) selectCard(cx, cy, 1);
				if(cy) selectCard(cx, cy, stackEx[cx]-cy+1);
			}else{
				if(cy){
					if(cx-sx || !sy){
						if(sy){
							if(matchVal(g.deckCard[cx][stackEx[cx]-1+(!stackEx[cx])], g.deckCard[sx][sy-1])){
								for(i = 0; i < hold; i++){
									g.deckCard[cx][stackEx[cx]+i] = g.deckCard[sx][sy+i-1];
									g.deckCard[sx][sy+i-1] = 52;
								}
								cy = stackEx[cx]+hold;
								g.moves++;
							}
						}else if(sx == 1){
							if(matchVal(g.deckCard[cx][stackEx[cx]-1+(!stackEx[cx])], g.stockCard[g.stockProg-1])){
								g.deckCard[cx][stackEx[cx]] = g.stockCard[g.stockProg-1];
								if(g.stockSize){
									for(i = g.stockProg; i < g.stockSize; i++) g.stockCard[i-1] = g.stockCard[i];
								}
								g.stockCard[g.stockSize-1] = 52;
								g.stockProg--; g.stockSize--;
								cy = stackEx[cx]+1;
								g.moves++;
								if(g.options[2] == 1) g.score[0] += 5;
							}
						}else if(sx > 2){
							if(matchVal(g.deckCard[cx][stackEx[cx]-1], 13*sx+g.foundProg[sx-3]-40)){
								g.deckCard[cx][stackEx[cx]] = 13*sx+g.foundProg[sx-3]-40;
								g.foundProg[sx-3]--;
								cy = stackEx[cx]+1;
								g.moves++;
								if(g.options[2] == 1) g.score[0] -= 15;
								if(g.options[2] > 1) g.score[g.options[2]-2] -= 5;
							}
						}
					}
				}else if(!cx){
					if(g.stockProg == g.stockSize) g.stockProg = 0;
					else{
						if(g.stockSize-g.stockProg > 3-2*g.options[0]) g.stockProg += 3-2*g.options[0];
						else g.stockProg = g.stockSize;
					}
				}else if(cx > 2 && hold == 1){
					if(sy){
						if(g.deckCard[sx][sy-1] == 13*cx+g.foundProg[cx-3]-39){
							g.foundProg[cx-3]++;
							g.deckCard[sx][sy-1] = 52;
							g.moves++;
							if(g.options[2] == 1) g.score[0] += 10;
							if(g.options[2] > 1) g.score[g.options[2]-2] += 5;
						}
					}else{
						if(g.stockCard[g.stockProg-1] == 13*cx+g.foundProg[cx-3]-39){
							g.foundProg[cx-3]++;
							if(g.stockSize){
								for(i = g.stockProg; i < g.stockSize; i++) g.stockCard[i-1] = g.stockCard[i];
							}
							g.stockCard[g.stockSize-1] = 52;
							g.stockProg--; g.stockSize--;
							g.moves++;
							if(g.options[2] == 1) g.score[0] += 15;
							if(g.options[2] > 1) g.score[g.options[2]-2] += 5;
						}
					}
				}
				hold = 0;
				updateStats();
			}
			drawGame(); while((kb_Data[1] & kb_2nd) || (kb_Data[6] & kb_Enter)){updateTime(); kb_Scan();}
		}
		
		if(g.options[2] > 1){
			if((!g.options[0] && g.stockPass == 3) || (g.options[0] && g.stockPass)){drawGame(); goto END;}
		}
	}
	
WIN:
	if(g.options[2] == 1 && g.time > 30) g.score[0] += 700000/g.time;
	drawGame();
	delay(300);
    gfx_SetTextConfig(gfx_text_clip);
	
	for(i = 0; i < 52; i++){
		delay(50);
		animCard.x = 145+40*(i%4);
		animCard.y = 10;
		animCard.vx = randInt(2, 5)*pow(-1, randInt(0, 1))-1;
		animCard.vy = randInt(-3, 6);
		animCard.type = 13*(i%4)+12-i/4;
		drawCard(animCard.x, animCard.y, animCard.type%52, 0, false);
		gfx_BlitRectangle(gfx_buffer, animCard.x, animCard.y, 30, 40-(animCard.y > 200)*(animCard.y-200));
		while(animCard.y+animCard.vy < 240){
			delay(20);
			animCard.x += animCard.vx;
			animCard.y += animCard.vy;
			if(animCard.y > 200 && animCard.type < 52){animCard.y = 200; animCard.vy = 2-animCard.vy;}
			if(animCard.x < 1){animCard.type += 52; animCard.x = 0; animCard.vx *= -1;}
			if(animCard.x > 289){animCard.type += 52; animCard.x = 290; animCard.vx *= -1;}
			animCard.vy++;
			drawCard(animCard.x, animCard.y, animCard.type%52, 0, false);
			gfx_BlitRectangle(gfx_buffer, animCard.x, animCard.y, 30, 40-(animCard.y > 200)*(animCard.y-200));
			if(os_GetCSC()) goto END;
		}
	}
END:
	g.gameEx = false;
	delay(100);
    gfx_SetTextConfig(gfx_text_noclip);
	
	gfx_SetColor(0x03); gfx_Circtangle(11, 157, 298, 56, true);
	gfx_SetColor(0x04); gfx_Circtangle(10, 156, 300, 58, false);
	gfx_SetTextFGColor(0x06);
	gfx_SetTextXY(127, 160); gfx_PrintString("GAME OVER");
	gfx_SetTextXY(28, 170); gfx_PrintString("Scoring System:");
	gfx_SetTextXY(38, 180); gfx_PrintString(optPosStr[4+g.options[2]]);
	if(g.options[2]){
		gfx_SetTextXY(28, 190); gfx_PrintString("Score:");
		gfx_SetTextXY(78, 190); if(g.options[2] > 1) gfx_PrintChar(36);
		gfx_PrintInt(g.score[g.options[2] == 3], 1+log10(g.score[g.options[2] == 3]));
		if(g.options[2] == 3){
			gfx_SetTextXY(28, 200); gfx_PrintString("Gain:");
			if(g.score[1]-g.score[2] > 0){gfx_SetTextFGColor(0x07);}else{gfx_SetTextFGColor(0xE0);}
			gfx_SetTextXY(78, 200); gfx_PrintChar(36); if(g.score[1]-g.score[2] > 0) gfx_PrintString("+");
			gfx_PrintInt(g.score[1]-g.score[2], 1+log10(g.score[1]-g.score[2]));
		}
	}
	gfx_SetTextFGColor(0x06);
	gfx_SetTextXY(178, 170); gfx_PrintString("DRAW "); gfx_PrintString(optPosStr[g.options[0]]);
	if(g.options[1]){
		gfx_SetTextXY(178, 180); gfx_PrintString("Moves:");
		gfx_SetTextXY(228, 180); gfx_PrintUInt(g.moves, 1+log10(g.moves));
		gfx_SetTextXY(178, 190); gfx_PrintString("Time:");
		gfx_SetTextXY(228, 190); gfx_PrintUInt(g.time/60, 2); gfx_PrintString(":"); gfx_PrintUInt(g.time%60, 2);
	}
	
	gfx_BlitRectangle(gfx_buffer, 10, 156, 300, 58);
	
	delay(500);
	while(kb_AnyKey()) kb_Scan();
	while(!os_GetCSC());
	goto MENU;
	
EXIT:
	writeAppVar();
	gfx_End();
}

void setupGame(){
	uint8_t card = 0;
	uint8_t x, y;
	uint8_t *pa = 0, *pb = 0, c;
	
	for(i = 0; i < 133; i++) g.deckCard[i/19][i%19] = 52;
	for(i = 0; i < 7; i++){
		g.stackHid[i] = i;
		for(j = 0; j < i+1; j++){
			g.deckCard[i][j] = card;
			card++;
		}
	}
	for(i = 0; i < 24; i++){
		g.stockCard[i] = card;
		card++;
	}
	
	for(i = 0; i < 52; i++){
		if(i < 28){
			x = 0;
			while(i+1 > (x+2)*(x+1)/2) x++;
			y = i-x*(x+1)/2;
			pa = &(g.deckCard[x][y]);
		}else{
			pa = &(g.stockCard[i-28]);
		}
		
		do{
			j = randInt(0, 51);
		}while(i == j);
		
		if(j < 28){
			x = 0;
			while(j+1 > (x+2)*(x+1)/2) x++;
			y = j-x*(x+1)/2;
			pb = &(g.deckCard[x][y]);
		}else{
			pb = &(g.stockCard[j-28]);
		}
		
		c = *pa;
		*pa = *pb;
		*pb = c;
	}
	
	for(i = 0; i < 4; i++) g.foundProg[i] = 0;
	g.stockSize = 24;
	g.stockProg = 0;
	g.stockPass = 0;
	g.moves = 0;
	g.time = 0;
	if(g.options[2] == 1) g.score[0] = 0;
	if(g.options[2] == 2) g.score[0] = -52;
	if(g.options[2] == 3){g.score[2] = g.score[1]; g.score[1] -= 52;}
	g.gameEx = true;
}

void selectCard(uint8_t x, uint8_t y, uint8_t h){
	sx = x; sy = y;
	hold = h;
}

bool matchVal(uint8_t c, uint8_t s){
	if(c == 52 && s%13 == 12) return true;
	if(c%13 == s%13+1 && ((s < 26 && c >= 26) || (s >= 26 && c < 26))) return true;
	return false;
}

void updateStats(){
	for(i = 0; i < 7; i++){
		for(j = 0; j < 19; j++){
			if(g.deckCard[i][j] == 52){
				stackEx[i] = j;
				break;
			}
		}
		if(g.stackHid[i] == stackEx[i] && stackEx[i]){
			g.stackHid[i]--;
			if(g.options[2] == 1) g.score[0] += 5;
		}
	}
	if(!g.stockSize && g.foundProg[0]+g.foundProg[1]+g.foundProg[2]+g.foundProg[3]-52 && !(g.stackHid[0]+g.stackHid[1]+g.stackHid[2]+g.stackHid[3]+g.stackHid[4]+g.stackHid[5]+g.stackHid[6])){
		autoFinish = true;
	}
}

void correctMove(){
	if(cy && cy <= g.stackHid[cx]) cy = g.stackHid[cx]+1;
	if(cy && cy > stackEx[cx]) cy = stackEx[cx]+(!stackEx[cx]);
}

void drawMenu(uint8_t page){
	gfx_SetDrawBuffer();
	
	drawBack();
	
	gfx_SetTextScale(3, 4);
	gfx_SetTextFGColor(0xE0);
	gfx_SetTextXY(139, 122); gfx_PrintString("Soliti");
	gfx_SetTextFGColor(0x00);
	gfx_SetTextXY(253, 122); gfx_PrintString("CE");
	gfx_SetTextXY(141, 120); gfx_PrintString("Soliti");
	gfx_SetTextFGColor(0xE0);
	gfx_SetTextXY(255, 120); gfx_PrintString("CE");
	
	gfx_SetTextScale(1, 1);
	gfx_SetColor(0x03); gfx_Circtangle(11, 157, 298, 56, true);
	gfx_SetColor(0x04); gfx_Circtangle(10, 156, 300, 58, false);
	gfx_SetColor(0x05); gfx_FillRectangle_NoClip(30, 160, 4, 50);
	if(menuOpt[cx]) gfx_SetColor(0xFF); gfx_FillRectangle_NoClip(30, 160+cy*10, 4, 10);
	if(g.options[2] == 3){
		gfx_SetTextFGColor(0x05);
		gfx_SetTextXY(11, 146); gfx_PrintString("Balance: "); gfx_PrintChar(36); gfx_PrintInt(g.score[1], 1+log10(g.score[1]));
	}
	switch(page){
		case 0:
			for(i = 0; i < 5; i++){
				if((!g.gameEx && i == 1) || i == 4){gfx_SetTextFGColor(0x05);}else{gfx_SetTextFGColor(0x06);}
				gfx_SetTextXY(38, 160+10*i); gfx_PrintString(menuStr[i]);
			}
			break;
		case 1:
			for(i = 0; i < 4; i++){
				gfx_SetTextFGColor(0x05);
				gfx_SetTextXY(38, 160+10*i); gfx_PrintString(ctrlStr[i]);
				gfx_SetTextFGColor(0x06);
				gfx_SetTextXY(118, 160+10*i); gfx_PrintString(ctrlStr[i+4]);
			}
			break;
		case 2:
			gfx_SetTextFGColor(0x06);
			for(i = 0; i < 3; i++){
				gfx_SetTextXY(38, 160+10*i); gfx_PrintString(menuStr[i+5]);
			}
			break;
		case 3:
			gfx_SetTextFGColor(0x06);
			for(i = 0; i < 4; i++){
				gfx_SetTextXY(38, 160+10*i); gfx_PrintString(optNameStr[i]);
			}
			gfx_SetTextXY(188, 160); gfx_PrintString(optPosStr[g.options[0]]);
			gfx_SetTextXY(188, 170); gfx_PrintString(optPosStr[2+g.options[1]]);
			gfx_SetTextXY(188, 180); gfx_PrintString(optPosStr[4+g.options[2]]);
			gfx_SetTextXY(188, 190); gfx_PrintString(optPosStr[2+g.options[3]]);
			gfx_SetTextFGColor(0x05);
			gfx_SetTextXY(48, 200); gfx_PrintString("(Changes Will Delete Current Game)");
			break;
		case 4:
			gfx_SetTextFGColor(0x06);
			for(i = 0; i < 2; i++){
				gfx_SetTextXY(38, 160+10*i); gfx_PrintString(optNameStr[4+i]);
			}
			gfx_SetTextXY(188, 160); gfx_PrintString(optPosStr[2+g.options[4]]);
			gfx_SetTextXY(188, 170); gfx_PrintString("Style "); gfx_PrintUInt(1+g.options[5], 1);
			drawCard(240, 161, 27, 0, false);
			drawCard(240, 169, 0, 0, false);
			drawCard(275, 161, 1, 0, true);
			drawCard(275, 169, 1, 0, true);
			break;
		case 5:
			gfx_SetTextFGColor(0x06);
			for(i = 0; i < 2; i++){
				gfx_SetTextXY(38, 160+10*i); gfx_PrintString(menuStr[7+i]);
			}
			break;
	}
	
	gfx_SwapDraw();
}

void drawGame(){
	gfx_SetDrawBuffer();
	
	drawBack();
	
	gfx_SetTextScale(1, 1);
	gfx_SetTextFGColor(0x06);
	if(g.options[1]){
		gfx_SetTextXY(4, 218); gfx_PrintString("Moves:");
		gfx_SetTextXY(54, 218); gfx_PrintUInt(g.moves, 1+log10(g.moves));
		gfx_SetTextXY(4, 208); gfx_PrintString("Time:");
		gfx_SetTextXY(54, 208); gfx_PrintUInt(g.time/60, 2); gfx_PrintString(":"); gfx_PrintUInt(g.time%60, 2);
		gfx_SetTextXY(26, 51); gfx_PrintString("Passes: "); gfx_PrintUInt(g.stockPass, 1+log10(g.stockPass));
	}
	if(g.options[2]){
		gfx_SetTextXY(4, 218-20*(g.options[1])); gfx_PrintString("Score:");
		gfx_SetTextXY(54, 218-20*(g.options[1])); if(g.options[2] > 1) gfx_PrintChar(36); gfx_PrintInt(g.score[g.options[2] == 3], 1+log10(g.score[g.options[2] == 3]));
	}
	if(autoFinish){
		gfx_SetTextXY(146, 51); gfx_PrintString("[alpha]: Auto-Finish");
	}
	
	if(g.stockProg < g.stockSize){
		drawCard(25, 9, 0, !cx && !cy, true);
		if(!cx && !cy){gfx_SetTextFGColor(0xBF);}else{gfx_SetTextFGColor(0xFF);}
		gfx_SetTextXY(32+(g.stockSize-g.stockProg > 9 && g.stockSize-g.stockProg < 20), 25); gfx_PrintUInt(g.stockSize-g.stockProg, 2);
	}
	
	if(g.stockProg > 0){
		for(i = 0; i < 3; i++){
			if(g.stockProg+i > 2){
				drawCard(29+12*i+12*min(3, g.stockProg), 9, g.stockCard[g.stockProg-3+i], max((cx == 1 && !cy && i == 2), 2*(sx == 1 && !sy && i == 2 && hold)), false);
			}
		}
	}
	
	for(i = 0; i < 4; i++){
		if(g.foundProg[i] > 0) drawCard(145+40*i, 9, 13*i+g.foundProg[i]-1, max((cx == i+3 && !cy), 2*((sx == i+3 && !sy) && hold)), false);
	}
	
	for(i = 0; i < 7; i++){
		for(j = 0; j < 19; j++){
			if(g.deckCard[i][j] < 52) drawCard(25+40*i, 60+8*j, g.deckCard[i][j], max((cx == i && cy && (j+2 > cy || hold)), 2*(sx == i && j+2 > sy && sy && hold)), (g.stackHid[i] > j));
		}
	}
	
	gfx_SetColor(0xE0);
	if(!cy){
		if(cx == 1){
			gfx_Circtangle(53+12*min(3, max(1, g.stockProg)), 9, 30, 40, false);
			gfx_Circtangle(52+12*min(3, max(1, g.stockProg)), 8, 32, 42, false);
		}else{
			gfx_Circtangle(25+40*cx, 9, 30, 40, false);
			gfx_Circtangle(24+40*cx, 8, 32, 42, false);
		}
	}else{
		gfx_Circtangle(25+40*cx, 52+8*cy, 30, 40, false);
		gfx_Circtangle(24+40*cx, 51+8*cy, 32, 42, false);
	}
	
	gfx_SwapDraw();
}

void drawBack(){
	gfx_FillScreen(0x02);
	
	gfx_SetColor(0x01);
	gfx_Rectangle_NoClip(0, 0, 320, 240);
	gfx_Rectangle_NoClip(1, 1, 318, 238);
	gfx_SetColor(0x04);
	gfx_SetTextScale(1, 1); gfx_SetTextFGColor(0x03);
	gfx_SetTextXY(4, 228); gfx_PrintString("By BasicTH");
	gfx_SetTextXY(239, 228); gfx_PrintString("Version: 2.0");
	
	gfx_Circtangle(25, 9, 30, 40, false); gfx_Circle(40, 29, 5);
	gfx_Circtangle(65, 9, 30, 40, false);
	for(i = 0; i < 4; i++){
		gfx_Circtangle(145+40*i, 9, 30, 40, false);
		gfx_TransparentSprite_NoClip(sym[1][i], 147+40*i, 11);
	}
	
	gfx_SetColor(0x05);
	for(i = 0; i < 7; i++) gfx_Circtangle(25+40*i, 60, 30, 40, false);
}

void drawCard(uint16_t x, uint8_t y, uint8_t val, uint8_t type, bool hidden){
	switch(type){
		case 0:
			gfx_SetColor(0xFF);
			break;
		case 1:
			gfx_SetColor(0xBF);
			break;
		case 2:
			gfx_SetColor(0xEF);
			break;
	}
	gfx_FillRectangle(x+1, y+1, 28, 38);
	gfx_SetColor(0x00); gfx_Circtangle(x, y, 30, 40, false);
	if(hidden){
		gfx_TransparentSprite(back[g.options[5]], x+4, y+4);
	}else{
		gfx_SetTextScale(1, 1);
		gfx_SetTextFGColor(224*(1-val/26));
		gfx_SetTextXY(x+2, y+2); gfx_PrintString(vals[val%13]);
		gfx_TransparentSprite(sym[0][val/13], x+20, y+2);
		gfx_TransparentSprite(sym[0][val/13], x+2, y+30);
		if(g.options[4] && (val+3)%13 < 4){
			switch((val+3)%13){
				case 0:
					gfx_TransparentSprite(pic[0], x+5, y+15);
					break;
				case 1:
					gfx_TransparentSprite(pic[1], x+7, y+15);
					break;
				case 2:
					gfx_TransparentSprite(pic[2], x+4, y+15);
					break;
				case 3:
					gfx_TransparentSprite(pic[3], x+8, y+13);
					break;
			}
		}
	}
}

void gfx_Circtangle(uint16_t x, uint8_t y, uint16_t w, uint8_t h, bool filled){
	gfx_Line(x, y+1, x, y+h-2); gfx_Line(x+w-1, y+1, x+w-1, y+h-2);
	gfx_Line(x+1, y, x+w-2, y); gfx_Line(x+1, y+h-1, x+w-2, y+h-1);
	if(filled) gfx_FillRectangle(x+1, y+1, w-2, h-2);
	else{
		gfx_SetPixel(x+1, y+1); gfx_SetPixel(x+w-2, y+1);
		gfx_SetPixel(x+1, y+h-2); gfx_SetPixel(x+w-2, y+h-2);
	}
}

void updateTime(){
	if(timer_IntStatus & TIMER1_RELOADED){
		g.time++;
		if(!(g.time%10) && g.options[2] == 1){
			g.score[0] -= 2;
		}
		drawGame();
		timer_IntAcknowledge = TIMER1_RELOADED;
	}
}

uint8_t max(int16_t a, int16_t b){return (a > b) ? a : b;}
uint8_t min(int16_t c, int16_t d){return (c < d) ? c : d;}

void writeAppVar(){
	ti_CloseAll();
	if(slot = ti_Open("SoliVar", "w")){
		ti_Write(&g, sizeof(g), 1, slot);
	}
	ti_SetArchiveStatus(false, slot);
	ti_CloseAll();
}

void loadAppVar(){
	ti_CloseAll();
	if(slot = ti_Open("SoliVar", "r")){
		ti_Read(&g, sizeof(g), 1, slot);
	}else{
		g.options[0] = 0;
		g.options[1] = 0;
		g.options[2] = 0;
		g.options[3] = 1;
		g.options[4] = 1;
		g.options[5] = 0;
		g.score[1] = 0;
		g.gameEx = false;
	}
	ti_CloseAll();
}