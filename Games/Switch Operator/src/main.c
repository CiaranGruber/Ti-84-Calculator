//--------------------------------------
// Program Name:
// Author:
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
#include <graphx.h>
#include <keypadc.h>
#include <fileioc.h>
#include <debug.h>
#include "gfx/sprites.h"
#include "gfx/spritesUnCompressed.h"
/* Other available headers */
// stdarg.h, setjmp.h, assert.h, ctype.h, float.h, iso646.h, limits.h, errno.h, debug.h

/* Put your function prototypes here */
void drawMenu(int x, int y, int trackX);
void drawGame(int x, int y, int trackX);
void inGame();
void train1(uint8_t tracknumber, int trainX);
void train2(uint8_t tracknumber, int train2X);
void CampaignMode();
void crashCampaign();
void readAppVar();
void writeAppVar();
void dispPerks();
void drawUpgrades();
void setPerk(uint8_t perkName, const char *perkStringName, uint8_t y);
void payForPerk(uint8_t varToBuy, uint8_t varToEnable, uint8_t varPrice, uint8_t yCoord, uint8_t selectorY);
void doPayForPerk(uint8_t selectorY);
void makeMoney();
void updateScores();
void decompressSprites();
/* Put all your globals here. */
uint8_t track1, track2, trackNumber1, trackNumber2, score, speed;
int gamemode, trainX1, trainX2;
const char appvar_name[] = "switchhs";
bool quit, train2Start, endless, bulletmode, campaignText = true, crashRan, started;
ti_var_t file;
typedef struct appVar1 {
	int wallet;
    uint8_t highscore;
    uint8_t highscoreBul;
    //uint8_t wallet;
    uint8_t slowDown1;
    uint8_t slowDown2;
    uint8_t moreMoney1;
    uint8_t moreMoney2;
    uint8_t moreMoney3;
    uint8_t track1Switch;
    uint8_t track2Switch;
    uint8_t track3Switch;
    uint8_t track4Switch;
    uint8_t track1Auto;
    uint8_t track2Auto;
    uint8_t track3Auto;
    uint8_t track4Auto;
} appVar1_t;
appVar1_t appVar; 
gfx_image_t *Train;
gfx_image_t *TrainTracks;

void main(void) {
	uint8_t keyPress = 0, key = 0, key1 = 0;
	int trainX = 0 - 190;
	srand(rtc_Time());
	ti_CloseAll();
	readAppVar();
	decompressSprites();
	if (appVar.wallet == 0) {
		appVar.wallet = 10;
	}
	gfx_Begin(gfx_8bpp);
	gfx_SetPalette(sprites_pal, sizeof(sprites_pal), 0);
	drawMenu(0,0,0);
	while(kb_ScanGroup(kb_group_6) != kb_Clear) {
		if (keyPress % 4 == 0) {
			trainX = trainX + 7;
			gfx_TransparentSprite(TrainTracks, trainX-7, 130);
			gfx_TransparentSprite(Train, trainX, 132);
			if (trainX >= 320)
				trainX = 0 - 170;
			if (key & kb_2nd)
				inGame();
			if (key & kb_Mode) {
				started = true;
				drawUpgrades();
				drawMenu(0,0,0);
			}
		}
		if (keyPress % 25 == 0) {
			if (key1 & kb_Left) {
				gamemode--;
				gfx_FillRectangle(125, 48, 90, 8);
			}
			if (key1 & kb_Right) {
				gfx_FillRectangle(125, 48, 90, 8);
				gamemode++;
			}
			if (key & kb_Graph) {
				gfx_FillScreen(gfx_red);
				drawMenu(0,0,0);
				if (campaignText == true) {
					campaignText = false;
				}
				else {
					campaignText = true;
				}
			}
		}
		gfx_SetTextFGColor(gfx_red);
		if (gamemode == 2) {
			gfx_SetColor(5);
			gfx_FillRectangle(115, 180, 100, 40);
			gfx_FillRectangle(85, 210, 160, 15);
			gfx_PrintStringXY("<     Bullet    >", 125, 48);
		}
		if (gamemode == 1) {
			gfx_SetColor(5);
			gfx_FillRectangle(115, 180, 100, 40);
			gfx_FillRectangle(85, 210, 160, 15);
			gfx_PrintStringXY("<   Endless  >", 125, 48);
		}
		if (gamemode == 0) {
			gfx_SetColor(5);
			gfx_PrintStringXY("< Campaign >", 125, 48);
			gfx_SetTextFGColor(gfx_black);
			gfx_PrintStringXY("Balance:", 120, 185);
			gfx_SetTextXY(190, 185);
			gfx_PrintInt(appVar.wallet, 3);
			gfx_PrintStringXY("Story:", 120, 200);
			gfx_PrintStringXY("[Mode] to see Upgrades", 90, 213);
			if (campaignText == true) {
				gfx_SetTextFGColor(gfx_red);
				gfx_PrintStringXY("On", 195, 200);
			}
			if (campaignText == false) {
				gfx_SetTextFGColor(gfx_red);
				gfx_PrintStringXY("Off", 190, 200);
			}
			gfx_SetTextFGColor(gfx_red);

		}
		if (gamemode == 3)
			gamemode = 0;
		if (gamemode == -1)
			gamemode = 2;
		key = kb_ScanGroup(kb_group_1);
		key1 = kb_ScanGroup(kb_group_7);
		keyPress++;
	}
	writeAppVar();
	gfx_End();
	pgrm_CleanUp();
}
void drawUpgrades(void) {
	uint8_t keyPress = 0, y = 50, key = 0, key1 = 0, key2 = 0;
	bool reset = false, gameBeat = false;
	gfx_FillScreen(gfx_black);
	gfx_SetTextScale(2,2);
	gfx_SetTextFGColor(8);
	gfx_PrintStringXY("Upgrades", 40, 1);
	gfx_PrintStringXY("Balance: $", 40, 210);
	gfx_SetTextXY(180, 210);
	gfx_PrintInt(appVar.wallet, 3);
	gfx_SetTextScale(1,1);
	// 0 means unavailabe
	// 1 means able to buy
	// 2 means bought

	//Get rid of this eventaully
	if (appVar.slowDown1 == 0)
		appVar.slowDown1 = 1;
	dispPerks();
	gfx_SetColor(gfx_black);
	while (kb_ScanGroup(kb_group_6) != kb_Clear) {
		if (keyPress % 20 == 0) {
			if (key & kb_Down) {
				gfx_FillRectangle(2, y, 8, 8);
				y += 10;
			}
			if (key & kb_Up) {
				gfx_FillRectangle(2, y, 8, 8);
				y -= 10;
			}
			if (y == 40)
				y = 50;
			if (y == 180)
				y = 170;
			gfx_SetTextFGColor(gfx_red);
			gfx_PrintStringXY(">", 2, y);
			if (key1 & kb_2nd) {
				doPayForPerk(y);
				gfx_SetTextScale(2,2);
				gfx_SetTextFGColor(8);
				gfx_FillRectangle(180, 210, 50, 40);
				gfx_SetTextXY(180, 210);
				gfx_PrintInt(appVar.wallet, 3);
				gfx_SetTextScale(1,1);
			}
			if (key2 & kb_Alpha) {
				gfx_FillScreen(gfx_black);
				gfx_SetTextScale(1,1);
				gfx_SetTextFGColor(8);
				gfx_PrintStringXY("Are you SURE you want to reset?", 1, 1);
				gfx_PrintStringXY("[2nd] Yes - [Mode] No", 1, 10);
				reset = true;
				while (reset == true) {
					if (key1 & kb_Mode) {
						reset = false;
					}
					if (key1 & kb_2nd) {
						memset_fast(&appVar, 0, sizeof(appVar1_t));
						reset = false;
						appVar.slowDown1 = 1;
						appVar.wallet = 10;
					}
					key1 = kb_ScanGroup(kb_group_1);
				}
				gfx_FillScreen(gfx_black);
				gfx_SetTextScale(2,2);
				gfx_SetTextFGColor(8);
				gfx_PrintStringXY("Upgrades", 40, 1);
				gfx_PrintStringXY("Balance: $", 40, 210);
				gfx_SetTextXY(180, 210);
				gfx_PrintInt(appVar.wallet, 3);
				gfx_SetTextScale(1,1);
				dispPerks();

			}

			if (appVar.track4Auto == 2 && gameBeat == false) {
				gfx_SetTextFGColor(gfx_orange);
				gfx_FillScreen(gfx_black);
				gfx_SetTextScale(3,3);
				gfx_PrintStringXY("You've beat", 1,1);
				gfx_PrintStringXY("the game!", 1,40);
				gfx_SetTextScale(2,2);
				gfx_SetTextFGColor(gfx_green);
				gfx_PrintStringXY("You can restart", 1, 80);
				gfx_PrintStringXY("by pressing [Alpha]", 1, 100);
				gfx_PrintStringXY("on the Upgrades Screen", 1, 120);
				while (!kb_AnyKey())
				gameBeat = true;
				gfx_SetTextScale(1,1);
				gfx_FillScreen(gfx_black);
				gfx_SetTextScale(2,2);
				gfx_SetTextFGColor(8);
				gfx_PrintStringXY("Upgrades", 40, 1);
				gfx_PrintStringXY("Balance: $", 40, 210);
				gfx_SetTextXY(180, 210);
				gfx_PrintInt(appVar.wallet, 3);
				gfx_SetTextScale(1,1);
				dispPerks();
			}
		}
		keyPress++;
		key = kb_ScanGroup(kb_group_7);
		key1 = kb_ScanGroup(kb_group_1);
		key2 = kb_ScanGroup(kb_group_2);
		}
}
void doPayForPerk(uint8_t selectorY) {
	payForPerk(appVar.slowDown1, appVar.slowDown2, 15, 50, selectorY);
	payForPerk(appVar.slowDown2, appVar.moreMoney1, 20, 60, selectorY);
	payForPerk(appVar.moreMoney1, appVar.moreMoney2, 25, 70, selectorY);
	payForPerk(appVar.moreMoney2, appVar.moreMoney3, 35, 80, selectorY);
	payForPerk(appVar.moreMoney3, appVar.track1Switch, 40, 90, selectorY);
	payForPerk(appVar.track1Switch, appVar.track2Switch, 55, 100, selectorY);
	payForPerk(appVar.track2Switch, appVar.track3Switch, 60, 110, selectorY);
	payForPerk(appVar.track3Switch, appVar.track4Switch, 75, 120, selectorY);
	payForPerk(appVar.track4Switch, appVar.track1Auto, 80, 130, selectorY);
	payForPerk(appVar.track1Auto, appVar.track2Auto, 90, 140, selectorY);
	payForPerk(appVar.track2Auto, appVar.track3Auto, 100, 150, selectorY);
	payForPerk(appVar.track3Auto, appVar.track4Auto, 115, 160, selectorY);
	payForPerk(appVar.track4Auto, appVar.track4Auto, 125, 170, selectorY);
}

void payForPerk(uint8_t varToBuy, uint8_t varToEnable, uint8_t varPrice, uint8_t yCoord, uint8_t selectorY) {
	if (varToBuy == 1 && selectorY == yCoord) {
		appVar.wallet -= varPrice;
		if (appVar.wallet <= 0) {
			appVar.wallet += varPrice;
		} else {
			varToEnable = 1;
			varToBuy = 2;
		}
		if (selectorY == 50) {
			appVar.slowDown1 = varToBuy;
			appVar.slowDown2 = varToEnable;
		}
		if (selectorY == 60) {
			appVar.slowDown2 = varToBuy;
			appVar.moreMoney1 = varToEnable;
		}
		if (selectorY == 70) {
			appVar.moreMoney1 = varToBuy;
			appVar.moreMoney2 = varToEnable;
		}
		if (selectorY == 80) {
			appVar.moreMoney2 = varToBuy;
			appVar.moreMoney3 = varToEnable;
		}
		if (selectorY == 90) {
			appVar.moreMoney3 = varToBuy;
			appVar.track1Switch = varToEnable;
		}
		if (selectorY == 100) {
			appVar.track1Switch = varToBuy;
			appVar.track2Switch = varToEnable;
		}
		if (selectorY == 110){
			appVar.track2Switch = varToBuy;
			appVar.track3Switch = varToEnable;
		}
		if (selectorY == 120) {
			appVar.track3Switch = varToBuy;
			appVar.track4Switch = varToEnable;
		}
		if (selectorY == 130) {
			appVar.track4Switch = varToBuy;
			appVar.track1Auto = varToEnable;
		}
		if (selectorY == 140) {
			appVar.track1Auto = varToBuy;
			appVar.track2Auto = varToEnable;
		}
		if (selectorY == 150) {
			appVar.track2Auto = varToBuy;
			appVar.track3Auto = varToEnable;
		}
		if (selectorY == 160) {
			appVar.track3Auto = varToBuy;
			appVar.track4Auto = varToEnable;
		}
		if (selectorY == 170) {
			appVar.track4Auto = varToEnable;
			appVar.track4Auto = varToBuy;
		}
		dispPerks();
	}
} 
void dispPerks(void) {
	setPerk(appVar.slowDown1, "- Slower Trains 1 - $ 15", 50);
	setPerk(appVar.slowDown2, "- Slower Trains 2 - $ 20", 60);
	setPerk(appVar.moreMoney1, "- Better Paycheck 1 - $ 25", 70);
	setPerk(appVar.moreMoney2, "- Better Paycheck 2 - $ 35", 80);
	setPerk(appVar.moreMoney3, "- Better Paycheck 3 - $ 40", 90);
	setPerk(appVar.track1Switch, "- Upgrade Track 1 - $ 55", 100);
	setPerk(appVar.track2Switch, "- Upgrade Track 2 - $ 60", 110);
	setPerk(appVar.track3Switch, "- Upgrade Track 3 - $ 75", 120);
	setPerk(appVar.track4Switch, "- Upgrade Track 4 - $ 80", 130);
	setPerk(appVar.track1Auto, "- Automatic Switch 1 - $ 95", 140);
	setPerk(appVar.track2Auto, "- Automatic Switch 2 - $ 100", 150);
	setPerk(appVar.track3Auto, "- Automatic Switch 3 - $ 115", 160);
	setPerk(appVar.track4Auto, "- Automatic Switch 4 - $ 125", 170); 
}
void setPerk(uint8_t perkName, const char *perkStringName, uint8_t y) {
	gfx_SetTextXY(15, y);
	if (perkName == 0) {
		gfx_SetTextFGColor(148);
		gfx_PrintString(perkStringName);
	} else if (perkName == 1) {
		gfx_SetTextFGColor(8);
		gfx_PrintString(perkStringName);
	} else if (perkName == 2) {
		gfx_SetTextFGColor(5);
		gfx_PrintString(perkStringName);
	}
}
void drawMenu(int x, int y, int trackX) {
	while (1) {
		if (x >= 320) {
			x = 0;
			y = y+8;
		}
		gfx_Sprite(Grass, x, y);
		x = x+8;
		if (y ==240)
			break;
	}
	while (1) {
		gfx_Sprite(TrainTracks,  trackX, 130);
		if (trackX >= 320)
			break;
		trackX = trackX + 7;
	}
	gfx_SetColor(5);
	gfx_FillRectangle(105, 1, 120,107);
	gfx_FillRectangle(115, 180, 100, 40);
	gfx_FillRectangle(85, 210, 160, 15);
	gfx_SetTextFGColor(8);
	gfx_PrintStringXY("Switch Operator", 110, 5);
	gfx_PrintStringXY("Hit 2nd to Start", 109, 16);
	gfx_PrintStringXY("Clear to Exit", 120, 28);
	gfx_SetTextFGColor(gfx_red);
	gfx_FillRectangle(125, 48, 90, 8);
	if (gamemode == 0)
		gfx_PrintStringXY("< Campaign >", 125, 48);
	if (gamemode == 1)
		gfx_PrintStringXY("<   Endless  >", 125, 48);
	if (gamemode == 2)
		gfx_PrintStringXY("<     Bullet    >", 125, 48);
	gfx_SetTextFGColor(gfx_black);
	gfx_PrintStringXY("Highscores", 125, 68);
	gfx_PrintStringXY("-", 160, 78);
	gfx_PrintStringXY("Endless:", 120, 88);
	gfx_PrintStringXY("Bullet:", 120, 98);
	gfx_SetTextXY(185, 88);
	gfx_PrintUInt(appVar.highscore, 3);
	gfx_SetTextXY(185, 98);
	gfx_PrintUInt(appVar.highscoreBul, 3);
	gfx_SetTextFGColor(8);
}
void drawGame(int x, int y, int trackX) {
	while (1) {
		if (x >= 320) {
			x = 0;
			y = y+8;
		}
		gfx_Sprite(Grass, x, y);
		x = x+8;
		if (y ==240)
			break;
	}
	while (1) {
		gfx_Sprite(TrainTracks,  trackX, 10);
		if (trackX >= 320)
			break;
		trackX = trackX + 7;
	}
	trackX = 0;
	while (1) {
		gfx_Sprite(TrainTracks,  trackX, 70);
		if (trackX >= 320)
			break;
		trackX = trackX + 7;
	}	
	trackX = 0;
	while (1) {
		gfx_Sprite(TrainTracks,  trackX, 130);
		if (trackX >= 320)
			break;
		trackX = trackX + 7;
	}
	trackX = 0;
	while (1) {
		gfx_Sprite(TrainTracks,  trackX, 190);
		if (trackX >= 320)
			break;
		trackX = trackX + 7;
	}
	gfx_SetColor(gfx_black);
	gfx_Circle(310, 55, 6);
	gfx_Circle(310, 55, 7);
	gfx_SetColor(gfx_red);
	if (appVar.track1Auto == 2 && gamemode == 0)
		gfx_SetColor(gfx_green);
	gfx_FillCircle(310, 55, 5);
	
	gfx_SetColor(gfx_black);
	gfx_Circle(310, 115, 6);
	gfx_Circle(310, 115, 7);
	gfx_SetColor(gfx_red);
	if (appVar.track2Auto == 2 && gamemode == 0)
		gfx_SetColor(gfx_green);
	gfx_FillCircle(310, 115, 5);
	
	gfx_SetColor(gfx_black);
	gfx_Circle(310, 175, 6);
	gfx_Circle(310, 175, 7);
	gfx_SetColor(gfx_red);
	if (appVar.track3Auto == 2 && gamemode == 0)
		gfx_SetColor(gfx_green);
	gfx_FillCircle(310, 175, 5);
	
	gfx_SetColor(gfx_black);
	gfx_Circle(310, 231, 6);
	gfx_Circle(310, 231, 7);
	gfx_SetColor(gfx_red);
	if (appVar.track4Auto == 2 && gamemode == 0)
		gfx_SetColor(gfx_green);
	gfx_FillCircle(310, 231, 5);
}
void CampaignMode(void) {
	uint8_t i, y = 1;
	const char *string_array[] = { "Oh no!", "You've lost your job", "in the great techological layoffs of 2050!", "Luckily, your uncle can get you a job.", "It will be at the railroad,", "as a Switch Operator.", "You will make sure that all trains", "have the go-ahead when running", "Be sure not to let a train run a red light,", "beacuse they will crash,", "and you will have to pay insurance fines.", "The fines are 5 - 10 dollars."};
	gfx_SetTextTransparentColor(93);
	gfx_FillScreen(gfx_black);
	gfx_SetTextBGColor(0);
	gfx_SetTextFGColor(255);
	for(i = 0; i < 12; i++) { 
		gfx_PrintStringXY( string_array[i], 1, y );
		y += 10;
	}
	while (1) {
		if (kb_AnyKey())
			break;
	}
	gfx_SetTextFGColor(255);
	gfx_SetTextTransparentColor(255);
	gfx_SetTextBGColor(255);
}
void inGame(void) {
	uint8_t keyPress = 0, key = 0, key1 = 0, timer = 35,start3Timer = 0, start6Timer = 0, start9Timer = 0, startChsTimer = 0, ChsTimer = 0, ThreeTimer = 0, SixTimer = 0, NineTimer = 0;
	if (gamemode == 0 && campaignText == true)
		CampaignMode();
	if (gamemode == 1)
		endless = true;
	if (gamemode == 2) 
		bulletmode = true;
	if (appVar.track4Switch == 2 || appVar.track3Switch == 2 && gamemode == 0)
		timer = 45;
	drawGame(0,0,0);
	trainX1 = 0 - 190;
	trainX2 = 0 - 190;
	track1 = randInt(1,4);
	track2 = randInt(1,4);
	trackNumber1 = 5;
	trackNumber2 = 6;
	score = 0;
	if (appVar.slowDown1 == 2) {
		speed = 10;
	}
	if (appVar.slowDown2 == 2) {
		speed = 12;
	} else {
		speed = 8;
	}
	quit = false;
	train2Start = false;
	if (bulletmode == true) 
		speed = 2.5;
	gfx_SetColor(5);
	gfx_FillRectangle(157, 1, 28, 8);
	while (kb_ScanGroup(kb_group_6) != kb_Clear) {
		gfx_SetTextFGColor(0);
		gfx_SetTextXY(160, 1);
		if (gamemode != 0)
			gfx_PrintInt(score, 3);
		if (gamemode == 0)
			gfx_PrintInt(appVar.wallet, 3);
		if (keyPress % speed == 0) {
			if (key & kb_Chs) {
				gfx_SetColor(gfx_black);
				gfx_Circle(310, 231, 6);
				gfx_Circle(310, 231, 7);
				gfx_SetColor(gfx_green);
				gfx_FillCircle(310, 231, 5);
				startChsTimer = true;
			}
			if (key & kb_3) {
				gfx_SetColor(gfx_black);
				gfx_Circle(310, 175, 6);
				gfx_Circle(310, 175, 7);
				gfx_SetColor(gfx_green);
				gfx_FillCircle(310, 175, 5);
				start3Timer = true;
			}
			if (key & kb_6) {
				gfx_SetColor(gfx_black);
				gfx_Circle(310, 115, 6);
				gfx_Circle(310, 115, 7);
				gfx_SetColor(gfx_green);
				gfx_FillCircle(310, 115, 5);
				start6Timer = true;
			}
			if (key & kb_9) {
				gfx_SetColor(gfx_black);
				gfx_Circle(310, 55, 6);
				gfx_Circle(310, 55, 7);
				gfx_SetColor(gfx_green);
				gfx_FillCircle(310, 55, 5);
				start9Timer = true;
			}
			if (startChsTimer == true)
				ChsTimer++;
			if (start3Timer == true)
				ThreeTimer++;
			if (start6Timer == true) {
				SixTimer++;
			}
			if (start9Timer == true)
				NineTimer++;
			if (ChsTimer == timer) {
				gfx_SetColor(gfx_black);
				gfx_Circle(310, 231, 6);
				gfx_Circle(310, 231, 7);
				gfx_SetColor(gfx_red);
				if (appVar.track4Auto == 2 && gamemode == 0)
					gfx_SetColor(gfx_green);
				gfx_FillCircle(310, 231, 5);
				ChsTimer = 0;
				startChsTimer = false;
			}
			if (ThreeTimer == timer) {
				gfx_SetColor(gfx_black);
				gfx_Circle(310, 175, 6);
				gfx_Circle(310, 175, 7);
				gfx_SetColor(gfx_red);
				if (appVar.track3Auto == 2 && gamemode == 0)
					gfx_SetColor(gfx_green);
				gfx_FillCircle(310, 175, 5);
				ThreeTimer = 0;
				start3Timer = false;
			}
			if (SixTimer == timer) {
				gfx_SetColor(gfx_black);
				gfx_Circle(310, 115, 6);
				gfx_Circle(310, 115, 7);
				gfx_SetColor(gfx_red);
				if (appVar.track2Auto == 2 && gamemode == 0)
					gfx_SetColor(gfx_green);
				gfx_FillCircle(310, 115, 5);
				SixTimer = 0;
				start6Timer = false;
			}
			if (NineTimer == timer) {
				gfx_SetColor(gfx_black);
				gfx_Circle(310, 55, 6);
				gfx_Circle(310, 55, 7);
				gfx_SetColor(gfx_red);
				if (appVar.track1Auto == 2 && gamemode == 0)
					gfx_SetColor(gfx_green);
				gfx_FillCircle(310, 55, 5);
				NineTimer = 0;
				start9Timer = false;
			}
			train1(track1, trainX1);
			if (score >= 10 && randInt(1,17) == 7 && train2Start == false && endless == false && bulletmode == false) 
				train2Start = true;
			if (score >= 15 && randInt(1,17) == 7 && train2Start == false && endless == true) 
				train2Start = true;
			if (track1 == track2 && train2Start == true) {
				while (1) {
					track2 = randInt(1,4);
					if (track2 != track1)
						break;
				}
			}
			if (train2Start == true)
				train2(track2, trainX2);
			if (quit == true)
				break;
		}
		keyPress++;
		key = kb_ScanGroup(kb_group_5);
	}
	if (score > appVar.highscore && endless == true)
		appVar.highscore = score;
	if (score > appVar.highscoreBul && bulletmode == true)
		appVar.highscoreBul = score;
	if (gamemode == 0 && appVar.wallet == 0)
		appVar.wallet = 10;
	ti_CloseAll();
	writeAppVar();
	bulletmode = false;
	drawMenu(0,0,0);	
	
}
void train1(uint8_t tracknumber, int train1X) {
	if (tracknumber == 1) {
				train1X = train1X + 7;
				gfx_TransparentSprite(TrainTracks, train1X-7, 10);
				gfx_TransparentSprite(Train, train1X, 12);	
				if (train1X >= 335 && gfx_GetPixel(310, 55) == gfx_green) {
					train1X = 0 - 190;
					tracknumber = randInt(1,4);
					track1 = tracknumber;
					score++;
					makeMoney();
					if (endless == true)
						speed--;
					gfx_SetColor(5);
					gfx_FillRectangle(157, 1, 28, 8);
					gfx_SetTextXY(160, 1);
					updateScores();
				}
				if (train1X+189 >= 315 && gfx_GetPixel(310, 55) == gfx_red && gamemode != 0)
					quit = true;
				if (train1X+189 >= 315 && gfx_GetPixel(310, 55) == gfx_red && gamemode == 0)
					crashCampaign();
			}
			if (tracknumber == 2) {
				train1X = train1X + 7;
				gfx_TransparentSprite(TrainTracks, train1X-7, 70);
				gfx_TransparentSprite(Train, train1X, 72);	
				if (train1X >= 335 && gfx_GetPixel(310, 115) == gfx_green) {
					train1X = 0 - 190;
					tracknumber = randInt(1,4);
					track1 = tracknumber;
					score++;
					if (endless == true)
						speed--;
					makeMoney();
					gfx_SetColor(5);
					gfx_FillRectangle(157, 1, 28, 8);
					gfx_SetTextXY(160, 1);
					 updateScores();
				}
				if (train1X+189 >= 315 && gfx_GetPixel(310, 115) == gfx_red && gamemode != 0)
					quit = true;
				if (train1X+189 >= 315 && gfx_GetPixel(310, 115) == gfx_red && gamemode == 0)
					crashCampaign();
			}
			if (tracknumber == 3) {
				train1X = train1X + 7;
				gfx_TransparentSprite(TrainTracks, train1X-7, 130);
				gfx_TransparentSprite(Train, train1X, 132);	
				if (train1X >= 335 && gfx_GetPixel(310, 175) == gfx_green) {
					train1X = 0 - 190;
					tracknumber = randInt(1,4);
					track1 = tracknumber;
					score++;
					makeMoney();
					if (endless == true)
						speed--;
					gfx_SetColor(5);
					gfx_FillRectangle(157, 1, 28, 8);
					gfx_SetTextXY(160, 1);
					 updateScores();
				}
				if (train1X+189 >= 315 && gfx_GetPixel(310, 175) == gfx_red && gamemode != 0)
					quit = true;
				if (train1X+189 >= 315 && gfx_GetPixel(310, 175) == gfx_red && gamemode == 0)
					crashCampaign();
			}
			if (tracknumber == 4) {
				train1X = train1X + 7;
				gfx_TransparentSprite(TrainTracks, train1X-7, 190);
				gfx_TransparentSprite(Train, train1X, 192);	
				if (train1X >= 335 && gfx_GetPixel(310, 231) == gfx_green) {
					train1X = 0 - 190;
					tracknumber = randInt(1,4);
					track1 = tracknumber;
					score++;
					makeMoney();
					gfx_SetColor(5);
					gfx_FillRectangle(157, 1, 28, 8);
					gfx_SetTextXY(160, 1);
					 updateScores();
				}
				if (train1X+189 >= 315 && gfx_GetPixel(310, 231) == gfx_red && gamemode != 0)
					quit = true;
				if (train1X+189 >= 315 && gfx_GetPixel(310, 231) == gfx_red && gamemode == 0)
					crashCampaign();
			}
			if (crashRan == false)
				trainX1 = train1X;
			crashRan = false;
			tracknumber = trackNumber1;
}
void train2(uint8_t tracknumber, int train2X) {
	if (tracknumber == 1) {
				train2X = train2X + 7;
				gfx_TransparentSprite(TrainTracks, train2X-7, 10);
				gfx_TransparentSprite(Train, train2X, 12);	
				if (train2X >= 335 && gfx_GetPixel(310, 55) == gfx_green) {
					train2X = 0 - 190;
					tracknumber = randInt(1,4);
					track2 = tracknumber;
					train2Start = false;
					score++;
					makeMoney();
					if (endless == true)
						speed--;
					gfx_SetColor(5);
					gfx_FillRectangle(157, 1, 28, 8);
					gfx_SetTextXY(160, 1);
					 updateScores();
				}
				if (train2X+189 >= 315 && gfx_GetPixel(310, 55) == gfx_red && gamemode != 0)
					quit = true;
				if (train2X+189 >= 315 && gfx_GetPixel(310, 55) == gfx_red && gamemode == 0)
					crashCampaign();
			}
			if (tracknumber == 2) {
				train2X = train2X + 7;
				gfx_TransparentSprite(TrainTracks, train2X-7, 70);
				gfx_TransparentSprite(Train, train2X, 72);
				if (train2X >= 335 && gfx_GetPixel(310, 115) == gfx_green) {	
 					train2X = 0 - 190;
					tracknumber = randInt(1,4);
					track2 = tracknumber;
					train2Start = false;
					score++;
					if (endless == true)
						speed--;
					makeMoney();
					gfx_SetColor(5);
					gfx_FillRectangle(157, 1, 28, 8);
					gfx_SetTextXY(160, 1);
					 updateScores();
				}
				if (train2X+189 >= 315 && gfx_GetPixel(310, 115) == gfx_red && gamemode != 0)
					quit = true;
				if (train2X+189 >= 315 && gfx_GetPixel(310, 115) == gfx_red && gamemode == 0)
					crashCampaign();
				if (appVar.track2Auto == 2)
					crashCampaign();
			}
			if (tracknumber == 3) {
				train2X = train2X + 7;
				gfx_TransparentSprite(TrainTracks, train2X-7, 130);
				gfx_TransparentSprite(Train, train2X, 132);	
				if (train2X >= 335 && gfx_GetPixel(310, 175) == gfx_green) {
					train2X = 0 - 190;
					tracknumber = randInt(1,4);
					track2 = tracknumber;
					train2Start = false;
					score++;
					if (endless == true)
						speed--;
					makeMoney();
					gfx_SetColor(5);
					gfx_FillRectangle(157, 1, 28, 8);
					gfx_SetTextXY(160, 1);
					 updateScores();
				}
				if (train2X+189 >= 315 && gfx_GetPixel(310, 175) == gfx_red && gamemode != 0)
					quit = true;
				if (train2X+189 >= 315 && gfx_GetPixel(310, 175) == gfx_red && gamemode == 0)
					crashCampaign();
			}
			if (tracknumber == 4) {
				train2X = train2X + 7;
				gfx_TransparentSprite(TrainTracks, train2X-7, 190);
				gfx_TransparentSprite(Train, train2X, 192);	
				if (train2X >= 335 && gfx_GetPixel(310, 231) == gfx_green) {
					train2X = 0 - 190;
					tracknumber = randInt(1,4);
					track2 = tracknumber;
					train2Start = false;
					score++;
					makeMoney();
					gfx_SetColor(5);
					gfx_FillRectangle(157, 1, 28, 8);
					gfx_SetTextXY(160, 1);
					updateScores();
				}
				if (train2X+189 >= 315&& gfx_GetPixel(310, 231) == gfx_red && gamemode != 0)
					quit = true;
				if (train2X+189 >= 315 && gfx_GetPixel(310, 231) == gfx_red && gamemode == 0)
					crashCampaign();
			}
			if (crashRan == false)
				trainX2 = train2X;
			crashRan = false;
			tracknumber = trackNumber2;
}
void crashCampaign(void) {
	uint8_t payUp = randInt(5, 20);
	gfx_SwapDraw();
	drawGame(0,0,0);
	gfx_SetDrawBuffer();
	gfx_SetDrawScreen();
	gfx_FillScreen(gfx_black);
	gfx_SetTextFGColor(gfx_orange);
	gfx_SetTextScale(4, 4);
	gfx_PrintStringXY("Boom!", 1, 20);
	gfx_SetTextScale(2, 2);
	gfx_SetTextFGColor(gfx_blue);
	gfx_PrintStringXY("You crashed a train,",1, 50);
	gfx_PrintStringXY("And you have to pay $",1, 70);
	gfx_SetTextXY(285, 70);
	gfx_PrintInt(payUp, 2);
	appVar.wallet -= payUp;
	gfx_PrintStringXY("in insurance charges.",1, 90);
	gfx_PrintStringXY("Balance:    $", 1, 200);
	gfx_SetTextXY(170, 200);
	quit = true;
	if (appVar.wallet <= 0) {
		gfx_FillScreen(gfx_black);
		gfx_SetTextFGColor(gfx_red);
		gfx_PrintStringXY("You ran out of money!", 1, 1);
		gfx_PrintStringXY("You can either quit", 1, 40);
		gfx_PrintStringXY("or try again.", 1, 60);
		quit = true;
		memset_fast(&appVar, 0, sizeof(appVar1_t));
		appVar.slowDown1 = 1;
		appVar.wallet = 10;
	} 
	else {
		gfx_PrintInt(appVar.wallet, 3);	
	}
	while (!kb_AnyKey()) {
	}
	gfx_SwapDraw();
	gfx_FillScreen(gfx_black);
	gfx_SetDrawScreen();
	gfx_SetTextScale(1,1);
	trainX1 = 0 - 190;
	trainX2 = 0 - 190;
	score = 0;
	speed = 10;
	crashRan = true;
	track1 = randInt(1,4);
	track2 = randInt(1,4);		 
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
void makeMoney(void) {
	if (gamemode == 0 && appVar.moreMoney1 == 2)
		appVar.wallet += randInt(1,6);
		if (gamemode == 0 && appVar.moreMoney2 == 2)
			appVar.wallet += randInt(1,8);
		if (gamemode == 0 && appVar.moreMoney3 == 2) {
			appVar.wallet += randInt(1,10);
		} else {
			appVar.wallet += randInt(1,4);
		}
}
void updateScores(void) {
	if (gamemode != 0)
		gfx_PrintUInt(score, 3);
	if (gamemode == 0)
		gfx_PrintInt(appVar.wallet, 3);
}
void decompressSprites(void) {
	malloc(0);
	Train = gfx_AllocSprite(186, 28, malloc);
	TrainTracks = gfx_AllocSprite(7, 32, malloc);
	gfx_LZDecompressSprite(Train_data_compressed, Train);
	gfx_LZDecompressSprite(TrainTracks_data_compressed, TrainTracks);
}
/* Put other functions here */
