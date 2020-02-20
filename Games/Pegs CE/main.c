// Program Name: PEGS
// Author(s): OSIAS HERNANDEZ
// Description:

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

/* Shared libraries */
//#include <lib/ce/graphc.h>
#include <lib/ce/graphx.h>
#include <lib/ce/fileioc.h>
#include <lib/ce/keypadc.h>

/* Some LCD defines */
#define lcd_size 320*240*2
#define lcd_buf  (uint16_t*)0xD40000

void fillScreen(uint8_t color);
void drawBlock();
void drawGrid();
void drawSection();
void drawSelect();
void drawLevel();
void drawTitle();
void drawPause();
void drawBar();
void collision();
void level_editor();



void gfx_Rectangle(int x, int y, int width, int height);
void gfx_FillRectangle_NoClip(uint24_t x, uint8_t y, uint24_t width, uint8_t height);
void gfx_Line_NoClip(uint24_t x0, uint8_t y0, uint24_t x1, uint8_t y1);
void gfx_PrintStringXY(const char *string, uint24_t x, uint8_t y);
void gfx_FillTriangle_NoClip(int x0, int y0, int x1, int y1, int x2, int y2);
uint8_t gfx_SetTextFGColor(uint8_t color);
uint8_t gfx_SetTextBGColor(uint8_t color);


void matriscopy (void * destmat, void * srcmat){
	memcpy(destmat, srcmat, 8*12*sizeof(uint8_t));}	


/* Declare some strings and variables */
const char appvar_name[] = "Pegs";


/* version info */
#define VERSION      1

typedef struct settings_struct {
    uint8_t lmax;
} settings_t;

settings_t settings;


void load_save(void);
void save_save(void);
void archive_save(void);

uint8_t a,b,key,key1,key3,key4,key5,db,s1,s2,s3,ss,i,j,win;
uint8_t c,keyPress=0,level=1;
uint8_t rpos,cpos,levelflag,cursorflag;

uint8_t deltar,deltas,deltac,deltad;
uint8_t row1,row2,col1,col2,drow,dcol;
uint8_t tc;
uint8_t rmoves,mode=1,theme=1;
uint8_t gfx_SetTextTransparentColor(uint8_t color);
signed char buf[20];
signed char flagtext[70];

uint8_t cursor[2][15] = {
			{2,4,2,3,4,0,3,3,4,1,0,0,3,5,5},
			{4,0,8,5,5,0,6,0,5,11,1,0,0,10,0},
};

static const char *themename[]={"COLOR","ORIGINAL","DARK"};

uint8_t color[3][16] = {
	{0xFF,0xE3,0xE6,0xE3,0xFF,0xE0,0xFF,0x25,0xFF,0xE2,0xFF,0xD1,0xFF,0x1A,0x00,0x1A},
	{0xFF,0x00,0xB5,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,0x00,0xFF},
	{0xB5,0xE3,0xE6,0xE3,0xB5,0xE0,0xB5,0x25,0xB5,0xE2,0xB5,0xD1,0xB5,0x1A,0x00,0x1A},
	};

uint8_t moves[15] = {6,8,4,19,15,10,9,48,16,15,20,14,24,10,10};

uint8_t drb[8][12] = {
			{0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0},
			};
			
uint8_t drb16[8][12] = {
			{0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0},
			};		
			
uint8_t pegslogo[8][12] = {
			{9,9,9,9,9,9,9,9,9,9,9,9},
			{1,1,1,5,5,5,8,8,8,1,1,1},
			{1,9,1,5,9,9,8,9,9,1,9,9},
			{1,1,1,5,5,5,8,9,8,1,1,1},
			{1,9,9,5,9,9,8,9,8,9,9,1},
			{1,9,9,5,5,5,8,8,8,1,1,1},
			{9,9,9,9,9,9,9,9,9,9,9,9},
			{9,9,9,9,9,9,9,9,9,9,9,9},
			};


/* Put all your code here */
void main(void) {
	/* Seed the random numbers */
	srand(rtc_Time());

    load_save();
	if (settings.lmax==0){settings.lmax=1;}
	level=settings.lmax;

    gfx_Begin( gfx_8bpp );
	gfx_FillScreen(0x00);

	/* Set the text color where index 0 is transparent, and the forecolor is random */
    gfx_SetTextTransparentColor(0x00);	
    gfx_SetColor(0xFF);

	drawTitle();
	drawLevel();
	if (levelflag!=1){
	drawGrid();}
    drawBar();
	b=rpos;a=cpos;db=2;      
    drawBlock();

	    /* Loop until 2nd is pressed */
    keyPress=0;
    while((kb_ScanGroup(kb_group_1) != kb_Graph) && mode!=4) {

        if (rmoves==0){ //game completed
        level=level+1;

		
		
		
		if (mode==1){
		levelflag=0;
		
        if (level==16){win=1;}

		if (((level==settings.lmax+1)) && (settings.lmax<15)){settings.lmax=level;  }
            sprintf(flagtext,"Nice Pegging!!!");
       if (win==1){sprintf(flagtext,"You beat all levels!!!");level=15;}
        save_save();
        drawPause();
		keyPress=0;
        }
		
		if (mode==2){
	    levelflag=1;
		sprintf(flagtext,"Nice Pegging!!!");
		level=settings.lmax;		
		drawPause();
 		drawTitle();
 		drawLevel();
		drawGrid();
		drawBar();
				keyPress=0;
		}
		
		
		}
		
        if (keyPress>110){
        key = kb_ScanGroup(kb_group_7);
		key1 = kb_ScanGroup(kb_group_1);

		switch(key1) {
        case kb_Window:
		drawLevel();
		drawGrid();
		drawBar();
		keyPress=0;
        break;
        case kb_Yequ:
		if (mode=2){level=settings.lmax;}
		
        drawTitle();
		drawLevel();
		drawGrid();
		drawBar();
		keyPress=0;
        break;  
        default:
                break;
		}

        switch(key) {
            case kb_Down:
				if (rpos<7){
				deltar=1;deltas=0;deltac=0;deltad=0;keyPress=0;
                b=rpos;a=cpos;collision();}
                break;
			case kb_Right:
                if (cpos<11){
                deltar=0;deltas=0;deltac=1;deltad=0;keyPress=0;
				b=rpos;a=cpos;
				collision();
                }
                break;
            case kb_Up:
				if (rpos>0){
				deltar=0;deltas=1;deltac=0;deltad=0;keyPress=0;
				b=rpos;a=cpos;
				collision();}
                break;
            case kb_Left:
				if (cpos>0){
                deltar=0;deltas=0;deltac=0;deltad=1;keyPress=0;
				b=rpos;a=cpos;
				collision();}
                break;
            default:
                break;
        }

        }		
		keyPress++;
	}
	save_save();
     ti_CloseAll();
	/* Wait for a key to be pressed -- Don't use this in your actual programs! */
	gfx_FillScreen(0xFF);
	/* Close the graphics and return to the OS */
    gfx_End();
	pgrm_CleanUp();
}


/* Simple way to fill the screen with a given color */
void fillScreen(uint8_t color) {
    memset_fast(lcd_buf, color, lcd_size);
}

void drawGrid(){
	for (b=0;b<8;b++){
    for (a=0;a<12;a++){
	db= drb[b][a];
	drawBlock();
	}
	}
return;
}


void drawBlock(){
	if (db==0){
	gfx_SetColor(color[theme-1][0]);
	gfx_FillRectangle_NoClip(26*a,26*b,26,26);
	return;}

	if (db==1){
	gfx_SetColor(color[theme-1][1]);
	gfx_FillRectangle_NoClip(26*a,26*b,26,26);
	gfx_SetColor(color[theme-1][2]);
	gfx_FillRectangle_NoClip(26*a+1,26*b+1,24,24);
    gfx_SetColor(color[theme-1][3]);
	gfx_Line_NoClip(26*a,26*b,26*a+25,26*b+25);
	gfx_Line_NoClip(26*a,26*b+25,26*a+25,26*b);
	return;}

	if (db==2){
   	gfx_SetColor(color[theme-1][4]);
    gfx_FillRectangle_NoClip(26*a,26*b,26,26);
    gfx_SetColor(color[theme-1][5]);
	gfx_FillRectangle_NoClip(26*a+7,26*b+7,12,12);
	gfx_FillRectangle_NoClip(26*a+11,26*b,4,26);
	gfx_FillRectangle_NoClip(26*a,26*b+11,26,4);
	gfx_FillRectangle_NoClip(26*a,26*b+7,4,12);
	gfx_FillRectangle_NoClip(26*a+22,26*b+7,4,12);
	gfx_FillRectangle_NoClip(26*a+7,26*b,12,4);
	gfx_FillRectangle_NoClip(26*a+7,26*b+22,12,4);
    }

	if (db==3){
    gfx_SetColor(color[theme-1][6]);
    gfx_FillRectangle_NoClip(26*a,26*b,26,26);
    gfx_SetColor(color[theme-1][7]);
	gfx_FillRectangle_NoClip(26*a+9,26*b,8,26);
    gfx_FillRectangle_NoClip(26*a,26*b+9,26,8);
	return;}

	if (db==4){
	gfx_SetColor(color[theme-1][8]);
    gfx_FillRectangle_NoClip(26*a,26*b,26,26);
	gfx_SetColor(color[theme-1][9]);
	
	if (theme!=2){
    gfx_FillRectangle_NoClip(26*a,26*b+7,6,6);
    gfx_FillRectangle_NoClip(26*a,26*b+13,13,13);
    gfx_FillRectangle_NoClip(26*a+13, 26*b+20, 6, 6); 
	for (c=0;c<7;c++){
	gfx_Line_NoClip(26*a,26*b+c,26*a+25-c,26*b+25);}  
	}
	if (theme==2){
	gfx_Line_NoClip(26*a,26*b,26*a,26*b+25);
	gfx_Line_NoClip(26*a+1,26*b+1,26*a+1,26*b+24);
	gfx_Line_NoClip(26*a,26*b+25,26*a+25,26*b+25);
	gfx_Line_NoClip(26*a+1,26*b+24,26*a+24,26*b+24);
	gfx_Line_NoClip(26*a,26*b,26*a+25,26*b+25);
	gfx_Line_NoClip(26*a,26*b+1,26*a+24,26*b+25);	
	}
	return;}
    if (db==5){
	gfx_SetColor(color[theme-1][10]);
    gfx_FillRectangle_NoClip(26*a,26*b,26,26);	
    gfx_SetColor(color[theme-1][11]);
	if (theme!=2){
	gfx_FillRectangle_NoClip(26*a,26*b,26,26);
	}
	if (theme==2){
	gfx_Rectangle_NoClip(26*a,26*b,26,26);
	gfx_Rectangle_NoClip(26*a+1,26*b+1,24,24);		
	}
	
	
	return;}
	if (db==6){
    gfx_SetColor(color[theme-1][12]);
    gfx_FillRectangle_NoClip(26*a,26*b,26,26);
	gfx_SetColor(color[theme-1][13]);
	if (theme!=2){
	gfx_FillCircle(26*a+13, 26*b+13, 12);
	}
	if (theme==2){
	gfx_Circle(26*a+13, 26*b+13, 12);
	gfx_Circle(26*a+13, 26*b+13, 11);
	}

	return;
	}
	if (db==7){
    gfx_SetColor(color[theme-1][14]);
	gfx_FillRectangle_NoClip(26*a,26*b,26,26);
	return;}
	if (db==8){
    gfx_SetColor(color[theme-1][15]);
	gfx_FillRectangle_NoClip(26*a,26*b,26,26);
	return;}
}


void collision(){
row1=rpos+deltar-deltas;
row2=rpos+2*(deltar-deltas);
col1=cpos+deltac-deltad;
col2=cpos+2*(deltac-deltad);

drow=deltar-deltas;
dcol=deltac-deltad;
    
    if ((((col1<0) && (dcol!=0)) || ((col1>11) && (dcol!=0))) || (((row1<0) && (drow!=0)) || ((row1>7) && (drow!=0)))){
    sprintf(flagtext,"no colli");
    return;
}
    
s1=drb[rpos][cpos]; /*current position */
s2=drb[row1][col1]; /*future position */
s3=drb[row2][col2];

if (((col2<0) || (col2>11)) || ((row2<0) || (row2>7))){
s3=9;
}

if (s2==0){
	drb[rpos][cpos]=0;
	drb[row1][col1]=2;
    ss=drb[rpos][cpos];
	b=rpos;a=cpos;db=ss;
	drawBlock();
	ss=drb[row1][col1];
	b=row1;a=col1;db=ss;
	drawBlock();
	rpos=row1;
	cpos=col1;
    for (i=0;i<30;i++){j=i;}
return;
}

if (s2==7){
	b=rpos;a=cpos;db=0;
	drawBlock();
	sprintf(flagtext,"You fell in a hole and died.");
	drawPause();
return;
}


if (((s2>2) && (s2<7)) && ((s3>2) && (s3<7)) && (s2!=s3))
{
	sprintf(flagtext,"They don't match.");
	drawPause();
}


if ((((s2>2) && (s2<7)) && (s3==0)))
{
	drb[rpos][cpos]=0;
	drb[row2][col2]=drb[row1][col1];
	drb[row1][col1]=2;
    drawSection();
	rpos=row1;
	cpos=col1;
	return;
}


if (((s2==5) && (s3==5)) || ((s2==6) && (s3==6)))
{
	drb[rpos][cpos]=0;
	drb[row1][col1]=2;
	drb[row2][col2]=0;
    drawSection();
	rpos=row1;
	cpos=col1;
	rmoves=rmoves-2;
	return;}

if ((((s2>2) && (s2<7)) && (s3==7)))
{
	drb[rpos][cpos]=0;
	drb[row1][col1]=2;
    if (s2!=5){drb[row2][col2]=7;}
    else {drb[row2][col2]=0;}
    drawSection();
	rpos=row1;
	cpos=col1;
	rmoves=rmoves-1;
	return;}


if (s2==1){return;}

if (((s2==4) && (s3==4))){
	drb[rpos][cpos]=0;
	drb[row1][col1]=2;
	drb[row2][col2]=1;
    drawSection();
	rpos=row1;
	cpos=col1;
	rmoves=rmoves-2;
	return;
}

if (((s2==3) && (s3==3))){
	drb[rpos][cpos]=0;
	drb[row1][col1]=0;
	drb[row2][col2]=3;
    drawSection();
    drawSelect();
	rpos=row1;
	cpos=col1;
	rmoves=rmoves-1;
	return;
	}
}


void drawSelect(){
	gfx_SetColor(0x00);
    gfx_FillRectangle_NoClip(0,220,320,20);
	gfx_SetTextFGColor(0xFF);
	sprintf(flagtext,"Select: 'UP' or 'DOWN'                        Choose: ENTER");
	gfx_PrintStringXY(flagtext,0,220);
ss=4;
b=row2;a=col2;db=ss;keyPress=0;
drawBlock();
drb[row2][col2]=ss;

keyPress=0;
	
	    /* Loop until ENTER is pressed */
    while(kb_ScanGroup(kb_group_6) != kb_Enter) {
        		        if (keyPress>120){
        key = kb_ScanGroup(kb_group_7);

        switch(key) {
            case kb_Down:
				if (ss>2){ss=ss+1;
				if (ss==7){ss=3;}
				b=row2;a=col2;db=ss;keyPress=0;
				drawBlock();
				drb[row2][col2]=ss;
				}
                break;
            case kb_Up:
				if (ss<7){ss=ss-1;
				if (ss==2){ss=6;}
				b=row2;a=col2;db=ss;keyPress=0;
				drawBlock();
				drb[row2][col2]=ss;
                }
                break;
            default:
                break;
        }
    }
        	keyPress++;
	}
    gfx_SetColor(0x00);
    gfx_FillRectangle_NoClip(0,220,320,20);
    b=row1;a=col1;db=2;
    drawBlock();
	drawBar();
}

void drawSection(){
	
	ss=drb[rpos][cpos];
	b=rpos;a=cpos;db=ss;
	drawBlock();
	ss=drb[row1][col1];
	b=row1;a=col1;db=ss;
	drawBlock();
	ss=drb[row2][col2];
	b=row2;a=col2;db=ss;
	drawBlock();
}

void drawLevel(){
	
	uint8_t drb1[8][12] = {
			{1,1,1,1,1,1,1,1,1,1,1,1},
			{1,0,0,0,0,0,0,0,0,0,0,1},
			{1,0,0,0,2,0,0,6,0,0,0,1},
			{1,0,0,0,0,3,3,4,0,0,0,1},
			{1,0,0,0,5,7,0,6,0,0,0,1},
			{1,0,0,0,0,0,0,0,0,0,0,1},
			{1,0,0,0,0,0,0,0,0,0,0,1},
			{1,1,1,1,1,1,1,1,1,1,1,1},
			};
uint8_t drb2[8][12] = {
			{1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,0,0,0,4,4,0,0,0,1},
			{1,1,1,0,0,0,1,0,0,0,0,1},
			{1,1,1,0,0,0,1,1,0,0,0,1},
			{2,0,0,0,4,4,6,6,0,0,0,1},
			{1,1,1,0,0,0,1,1,0,0,0,1},
			{1,1,1,0,0,0,1,0,0,0,0,1},
			{1,1,1,0,0,0,4,4,0,0,0,1},
			};
uint8_t drb3[8][12] = {
			{1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1},
			{1,0,0,0,0,0,4,0,2,0,0,0},
			{1,0,1,1,0,1,1,0,1,1,4,1},
			{1,0,0,4,0,0,0,0,0,0,0,1},
			{1,1,1,1,1,1,1,1,1,1,4,1},
			{1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1},
			};
uint8_t drb4[8][12] = {
			{1,1,1,1,1,1,1,1,1,1,1,1},
			{7,0,5,0,4,0,4,0,0,0,0,1},
			{7,0,3,0,6,0,4,0,0,0,0,1},
			{7,0,6,0,5,2,4,0,0,0,0,1},
			{7,0,4,0,5,0,4,0,3,0,0,1},
			{7,0,5,0,6,0,4,0,0,0,0,1},
			{7,0,6,0,5,0,4,0,0,0,0,1},
			{7,1,1,1,1,1,1,1,1,1,1,1},
			};
uint8_t drb5[8][12] = {
			{0,7,7,0,5,7,0,0,7,0,0,0},
			{0,7,7,0,5,5,0,0,7,0,0,4},
			{0,7,7,0,7,7,7,0,1,4,4,4},
			{0,7,7,0,7,5,7,0,1,4,0,4},
			{0,7,7,0,7,2,7,6,7,0,0,0},
			{0,7,7,0,7,7,7,0,7,0,0,0},
			{0,7,7,0,5,0,0,0,7,0,0,0},
			{0,7,7,0,0,6,0,0,7,6,6,0},
			};
uint8_t drb6[8][12] = {
			{2,0,0,0,0,0,0,0,0,0,0,0},
			{4,0,0,0,0,0,0,0,0,0,3,0},
			{4,0,0,4,0,0,0,4,4,0,0,0},
			{0,1,1,4,1,1,1,1,1,1,1,0},
			{0,0,0,0,0,0,0,0,0,0,0,0},
			{0,1,1,1,1,0,1,1,0,1,1,1},
			{0,3,0,0,0,0,0,0,6,5,7,0},
			{0,0,0,1,1,1,1,0,0,1,1,1},
			};
uint8_t drb7[8][12] = {
			{1,1,1,1,0,0,1,1,1,1,1,1},
			{1,1,1,7,0,0,5,7,0,1,1,1},
			{1,1,1,1,0,1,6,1,0,1,1,1},
			{1,1,1,4,3,3,2,5,4,7,0,1},
			{1,1,1,1,0,1,4,1,0,0,0,1},
			{1,1,1,1,0,0,6,0,0,1,0,1},
			{1,1,1,1,1,1,1,0,1,1,0,1},
			{1,1,1,1,1,1,1,0,0,0,0,1},
			};
uint8_t drb8[8][12] = {
			{1,1,1,1,1,1,1,1,1,1,1,1},
			{0,0,3,3,3,3,3,5,3,3,0,0},
			{0,0,3,3,3,4,3,3,6,3,0,0},
			{2,0,3,3,3,4,3,3,5,3,0,0},
			{0,0,3,3,5,6,3,3,3,3,0,0},
			{0,0,3,3,6,4,3,3,3,3,0,0},
			{0,0,3,3,4,5,3,3,3,3,0,0},
			{1,1,1,1,1,1,1,1,1,1,1,1},
			};
uint8_t drb9[8][12] = {
			{0,0,0,0,1,1,0,0,0,0,0,0},
			{0,3,0,0,1,1,0,0,0,0,0,0},
			{0,0,0,0,4,5,5,3,0,1,1,0},
			{0,1,0,0,4,1,0,0,0,1,1,1},
			{0,0,0,4,4,2,1,0,0,0,0,4},
			{0,0,0,0,4,1,0,0,1,1,1,1},
			{0,3,1,0,4,6,6,0,0,0,3,0},
			{0,0,0,0,5,1,0,0,0,0,0,0},
			};
uint8_t drb10[8][12] = {
			{1,1,1,1,4,1,1,1,0,0,0,0},
			{1,1,1,1,0,1,1,1,0,0,0,2},
			{0,0,5,0,7,7,7,0,0,0,3,0},
			{0,3,3,0,7,7,7,0,5,3,5,0},
			{0,3,3,0,7,7,7,0,5,3,5,0},
			{0,0,0,0,7,7,7,0,3,0,0,0},
			{1,1,1,1,1,0,1,1,0,0,0,0},
			{1,1,1,1,1,4,1,1,0,0,0,0},
			};
uint8_t drb11[8][12] = {
			{1,2,1,0,1,1,7,0,0,1,1,0},
			{1,0,0,0,6,5,7,7,0,4,4,0},
			{1,4,1,4,0,1,7,0,0,4,4,0},
			{1,0,0,4,0,1,0,0,0,3,3,0},
			{1,4,1,0,0,1,0,1,0,3,3,0},
			{0,0,0,0,0,1,0,1,1,0,1,0},
			{0,3,5,3,0,1,0,1,0,0,0,0},
			{0,0,0,0,4,4,4,1,1,1,1,1},
			};
uint8_t drb12[8][12] = {
			{2,0,0,0,0,0,1,1,1,1,1,1},
			{1,4,1,4,1,4,1,1,0,0,0,1},
			{0,0,0,0,0,0,1,0,0,1,0,1},
			{1,4,1,4,1,4,1,0,0,0,0,1},
			{0,0,0,0,0,0,1,1,6,6,7,1},
			{1,4,1,4,1,4,1,1,0,4,4,1},
			{0,0,0,0,0,0,0,0,0,0,4,1},
			{1,0,1,1,1,1,1,1,0,0,1,1},
			};			
			
uint8_t drb13[8][12] = {
			{1,1,1,1,1,1,1,1,1,1,1,1},
			{0,0,5,0,4,0,6,0,5,0,0,7},
			{0,0,4,0,6,0,4,0,5,0,0,7},
			{2,0,3,0,5,0,6,0,5,0,0,7},
			{0,0,6,0,5,0,4,0,5,0,0,7},
			{0,0,5,0,4,0,6,0,5,0,0,7},
			{0,0,3,0,3,0,4,0,5,0,0,7},
			{1,1,1,1,1,1,1,1,1,1,1,1},
			};			

uint8_t drb14[8][12] = {
			{1,1,1,1,1,0,0,1,0,0,1,1},
			{1,1,0,4,0,0,5,0,0,4,0,1},
			{1,7,0,0,6,1,0,1,1,0,0,1},
			{1,1,1,0,0,3,6,3,0,0,1,1},
			{1,1,0,0,1,1,0,1,6,0,0,7},
			{1,1,0,4,0,0,5,0,0,0,2,1},
			{1,1,0,0,1,0,0,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1},
			};

uint8_t drb15[8][12] = {
			{0,0,0,7,0,7,0,7,0,7,0,1},
			{0,0,0,7,0,7,0,7,0,7,0,1},
			{0,3,5,7,0,7,0,7,0,7,0,4},
			{0,5,0,7,0,7,5,7,0,7,0,1},
			{0,3,0,7,0,7,0,7,0,7,0,1},
			{2,0,0,7,5,7,0,7,0,7,0,1},
			{0,0,5,7,0,7,0,7,5,7,0,1},
			{0,0,5,7,0,7,0,7,0,7,0,1},
			};		
	
	
	rpos=cursor[0][level-1];
    cpos=cursor[1][level-1];
	rmoves=moves[level-1];
    
	if (level==1){matriscopy(drb,drb1);
	return;}
	if (level==2){matriscopy(drb,drb2);
	return;}
	if (level==3){matriscopy(drb,drb3);
	return;}
	if (level==4){matriscopy(drb,drb4);
	return;}
	if (level==5){matriscopy(drb,drb5);
	return;}
	if (level==6){matriscopy(drb,drb6);
	return;}
	if (level==7){matriscopy(drb,drb7);
	return;}
	if (level==8){matriscopy(drb,drb8);
	return;}
	if (level==9){matriscopy(drb,drb9);
	return;}
	if (level==10){matriscopy(drb,drb10);
	return;}
	if (level==11){matriscopy(drb,drb11);
	return;}
	if (level==12){matriscopy(drb,drb12);
	return;}
	if (level==13){matriscopy(drb,drb13);
	return;}
	if (level==14){matriscopy(drb,drb14);
	return;}
	if (level==15){matriscopy(drb,drb15);
	return;}
	if (level==17){matriscopy(drb,drb16);

		rmoves=0;
	for (b=0;b<8;b++){
    for (a=0;a<12;a++){
	c = drb[b][a];
	if (c==2){
	rpos=b;cpos=a;
	}	
    if ((c==3) || (c==4)  || (c==5) || (c==6)){
    rmoves=rmoves+1;}
	}
	}
	drawGrid();
    return;
	}
	
	
	}

void drawTitle(){
	mode=1;
    	gfx_SetColor(0x00);
    gfx_FillRectangle_NoClip(0,0,320,240);
    for (b=0;b<8;b++){
    for (a=0;a<12;a++){ 
	drb[b][a]= pegslogo[b][a];}}
    drawGrid();
	gfx_SetTextBGColor(0x00);
	gfx_SetTextFGColor(0xE5);
    gfx_PrintStringXY(" Press [2nd]",220,230);	
	gfx_SetTextFGColor(0xFF);
	gfx_PrintStringXY("EDITOR",20,200);
	gfx_PrintStringXY("THEME :",20,215);
	gfx_SetTextFGColor(0xE6);
	gfx_PrintStringXY(themename[theme-1],75,215);
	gfx_SetTextFGColor(0xFF);
	gfx_PrintStringXY("EXIT",20,230);

	sprintf(flagtext,"LEVEL");
	gfx_PrintStringXY(flagtext,20,185);
	gfx_SetTextFGColor(0xE6);
	gfx_PrintStringXY(">",0,185);
    sprintf(flagtext,"%d",level);
    if (level>1){sprintf(flagtext,"< %d",level);}
    else {sprintf(flagtext,"%d",level);}
    if (level!=settings.lmax){strcat(flagtext," >");}
	gfx_PrintStringXY(flagtext,70,185);
	keyPress=0;
    while(kb_ScanGroup(kb_group_1) != kb_2nd) {
        if (keyPress>120){
        key = kb_ScanGroup(kb_group_7);

        switch(key) {
            case kb_Right:
                	keyPress=0;
					if (mode==1){
				if (level>0 && level<settings.lmax){level=level+1;}
    gfx_SetColor(0x00);
	gfx_FillRectangle_NoClip(70,185,65,10);
	gfx_SetTextFGColor(0xE6);
    if (level>1){sprintf(flagtext,"< %d",level);}
    else {sprintf(flagtext,"%d",level);}
    if (level!=settings.lmax){strcat(flagtext," >");}
	gfx_PrintStringXY(flagtext,70,185);
					}
					
					if (mode==3){
						if (theme>0){theme=theme+1;
						if (theme==4){theme=1;}						
						}
				    gfx_SetColor(0x00);
					gfx_FillRectangle_NoClip(75,215,65,10);
					gfx_SetTextFGColor(0xE6);
					gfx_PrintStringXY(themename[theme-1],75,215);
					}
				break;
            case kb_Left:
                	keyPress=0;
					if (mode==1){
				if (level<settings.lmax+1 && level>1){level=level-1;
                }
    gfx_SetColor(0x00);
	gfx_FillRectangle_NoClip(70,185,65,10);
    gfx_SetTextFGColor(0xE6);
    if (level>1){sprintf(flagtext,"< %d",level);}
    else {sprintf(flagtext,"%d",level);}
    if (level!=settings.lmax){strcat(flagtext," >");}
	gfx_PrintStringXY(flagtext,70,185);
					}
					if (mode==3){
			    if (theme<4){theme=theme-1;
				if (theme==0){theme=3;}				
					}
						gfx_SetColor(0x00);
					gfx_FillRectangle_NoClip(75,215,65,10);
					gfx_SetTextFGColor(0xE6);
					gfx_PrintStringXY(themename[theme-1],75,215);
					}
                break;
			
            case kb_Down:
			    if (mode>0){mode=mode+1;
				if (mode==5){mode=1;}
				gfx_SetColor(0x00);
	            gfx_FillRectangle_NoClip(0,185,10,65);
				gfx_SetColor(0xE6);  
	            gfx_PrintStringXY(">",0,170+15*mode);
				keyPress=0;}
				break;
            case kb_Up:
			    if (mode<5){mode=mode-1;
				if (mode==0){mode=4;}
				gfx_SetColor(0x00);
	            gfx_FillRectangle_NoClip(0,185,10,65);
				gfx_SetColor(0xE6);
	            gfx_PrintStringXY(">",0,170+15*mode);
				keyPress=0;}
				break;
				default:
                break;
        }
    }
		
        	keyPress++;
	}
          if (mode==2){
			  keyPress=0;
			 level_editor();
          }
		     if (mode==3){
			  keyPress=0;
			  mode=1;
             }
		  
		  
		  if (mode==4){levelflag=1;}
		  
	gfx_SetColor(0x00);
    gfx_FillRectangle_NoClip(0,0,320,240);
	gfx_SetColor(0xFF);
	gfx_SetTextTransparentColor(0x00);
}

void drawPause(){
	gfx_SetTextTransparentColor(0x00);
    gfx_SetColor(0x00);
    gfx_FillRectangle_NoClip(0,220,320,20);
    gfx_SetTextFGColor(0xFF);
	gfx_PrintStringXY(flagtext,0,220);

while(kb_ScanGroup(kb_group_6) != kb_Enter) {};

gfx_SetColor(0x00);
gfx_FillRectangle_NoClip(0,220,320,20);

if (levelflag==0){
drawLevel();
drawGrid();
drawBar();}
}

void drawBar(){
gfx_SetTextTransparentColor(0x00);
    gfx_SetColor(0x00);
    gfx_FillRectangle_NoClip(0,220,320,20);
    gfx_SetColor(0xFF);	
	    for (a=0;a<3;a++){
		    gfx_Line_NoClip(5,220+5*a,20,220+5*a);
		}
		gfx_Line_NoClip(75,225,80,220);
		gfx_Line_NoClip(75,225,80,230);
        gfx_Line_NoClip(295,220,305,230);
		gfx_Line_NoClip(295,230,305,220);
}



void load_save(void) {
    ti_var_t save;
    ti_CloseAll();
    save = ti_Open(appvar_name, "r+");

    if(save) {
        if (ti_GetC(save) == VERSION) {
            if (ti_Read(&settings, sizeof(settings_t), 1, save) != 1) {
                return;
        } else {
            return;
        }
    }
	}
    ti_CloseAll();
}


void save_save(void) {
    ti_var_t save;
    ti_CloseAll();
    save = ti_Open(appvar_name, "w");
    if(save) {
        ti_PutC(VERSION, save);
        if (ti_Write(&settings, sizeof(settings_t), 1, save) != 1) {
            goto err;
        }
    }
    ti_CloseAll();

    return;
    
err:
    ti_Delete(appvar_name);
}


void level_editor(){
keyPress=0,rmoves=0;cursorflag=0,levelflag=0;
    for (b=0;b<8;b++){
    for (a=0;a<12;a++){
	drb[b][a]=0;}}
	level=17;
	
drawGrid();
gfx_SetColor(0x00);
gfx_FillRectangle_NoClip(0,210,320,30);
gfx_SetColor(0xE6);
gfx_PrintStringXY("0 - EMPTY   1 - BLOCK   2 - YOU   3 - CROSS",0,210);
gfx_PrintStringXY("4 - TRIANGLE   5 - SQUARE   6 - CIRCLE   7 - HOLE",0,220);
gfx_SetColor(0xFF);
gfx_PrintStringXY("Press [ENTER]",225,230);

rpos=0;cpos=0;
b=rpos;a=cpos;db=0;
gfx_SetColor(0x1D);
gfx_FillRectangle_NoClip(26*a,26*b,26,26);

	keyPress=0;
	levelflag=0;
	while(levelflag != 1 || cursorflag != 1){
	
	    while((kb_ScanGroup(kb_group_6) != kb_Enter)) {
	        if (keyPress>110){
        key = kb_ScanGroup(kb_group_7);
		key3 = kb_ScanGroup(kb_group_3);
		key4 = kb_ScanGroup(kb_group_4);
		key5 = kb_ScanGroup(kb_group_5);
		switch(key3){
             case kb_0:
              b=rpos;a=cpos;
			  if (drb[b][a]==2){cursorflag=0;}
			  if ((drb[b][a]>2) && (drb[b][a]<7)){
		      rmoves=rmoves-1;
			  if (rmoves==0){levelflag=0;}
			  }			  
			  db=0;keyPress=0; 
			  drb[b][a]=db; 
              drawBlock();
              break;
              case kb_1:
              b=rpos;a=cpos;db=1;keyPress=0;
			  drb[b][a]=db;
              drawBlock();
              break;
			  case kb_4:
              b=rpos;a=cpos;db=4;keyPress=0,levelflag=1;
			  if (drb[b][a]!=4){
			  rmoves=rmoves+1;}
			  drb[b][a]=db;
              drawBlock();
              break;
			  case kb_7:
              b=rpos;a=cpos;db=7;keyPress=0; 
			  drb[b][a]=db;
              drawBlock();
              break;
              default: break;
         }
		switch(key4){
             case kb_2:
			 if (cursorflag==0){
              b=rpos;a=cpos;db=2;keyPress=0;
			  cursorflag=1;
			  drb[b][a]=db;
		      drawBlock();}
                 break;
                 case kb_5:
              b=rpos;a=cpos;db=5;keyPress=0,levelflag=1;
			  if (drb[b][a]!=5){
			  rmoves=rmoves+1;}			  
			  drb[b][a]=db;
              drawBlock();
                 break;
             default: break;
         }
        switch(key5){
             case kb_3:
              b=rpos;a=cpos;db=3;keyPress=0,levelflag=1;
			  if (drb[b][a]!=3){
			  rmoves=rmoves+1;}
			  drb[b][a]=db;
              drawBlock();
                 break;
                 case kb_6:
              b=rpos;a=cpos;db=6;keyPress=0,levelflag=1;
			  if (drb[b][a]!=6){
			  rmoves=rmoves+1;}
			  drb[b][a]=db;
              drawBlock();
                 break;
             default: break;
         }
		switch(key) {
            case kb_Down:
				if (rpos<7){
				keyPress=0;
				db = drb[b][a];
				drawBlock();
                rpos=rpos+1;
                b=rpos;a=cpos;
			    gfx_SetColor(0x1D);
	            gfx_FillRectangle_NoClip(26*a,26*b,26,26);
				}
                break;
            case kb_Up:
				if (rpos>0){
				keyPress=0;
				db = drb[b][a];
				drawBlock();
				rpos=rpos-1;
                b=rpos;a=cpos;
			    gfx_SetColor(0x1D);
	            gfx_FillRectangle_NoClip(26*a,26*b,26,26);
				}
                break;
			case kb_Right:
				if (cpos<11){
				keyPress=0;
			    db = drb[b][a];
				drawBlock();
                cpos=cpos+1;
                b=rpos;a=cpos;
			    gfx_SetColor(0x1D);
	            gfx_FillRectangle_NoClip(26*a,26*b,26,26);
				}
                break;
			case kb_Left:
				if (cpos>0){
				keyPress=0;
				db = drb[b][a];
				drawBlock();
                cpos=cpos-1;
                b=rpos;a=cpos;
			    gfx_SetColor(0x1D);
	            gfx_FillRectangle_NoClip(26*a,26*b,26,26);
				}
                break;
            default:
                break;
			}
		}
            keyPress++;
}    
	}
	matriscopy(drb16,drb);
	matriscopy(drb,drb16);	
	drawLevel();
        }
		
	