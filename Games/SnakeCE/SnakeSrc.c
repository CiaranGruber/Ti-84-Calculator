/*
 *--------------------------------------
 * Program Name: SnakeCE v1.1
 * Author: LogicalJoe
 * Copyright: Copyright (C) 2017 LogicalJoe
 * License:
 * Description:
 *--------------------------------------
 */

/* Keep these headers */
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <tice.h>

/* Standard headers (recommended) */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <LJ.h>

#include <graphx.h>
#include <keypadc.h>
#include <fileioc.h>

/* Put your function prototypes here */
void menu( void );
void game( void );

/* Put all your globals here */
static const char *Snake_AppVar = "SnakeCE";

uint8_t ListD[3] = {0,7,224};
uint16_t ListA[5000], ListC[2], ListB[5000], ListE[2];
uint16_t D = 10, Q = 15, G = 1, Y, X, A, B, L, S = 0, K, M;
bool quit = false, die;
int highscore;
ti_var_t file;
typedef struct appVar1 {
    int highscore;
} appVar1_t;

void main(void) {
    /* Fill in the body of the main function here */
    
    ti_CloseAll();
    file = ti_Open(Snake_AppVar, "r");
    if (file) {
        ti_Read(&highscore, sizeof(highscore), 1, file);
    }
    else {
        highscore = 0;
    }
    
    gfx_Begin(gfx_8bpp);
    
    while (quit == false)
        menu();
    
    /* archive the save file */
    file = ti_Open(Snake_AppVar, "r");
    if (file)
        ti_SetArchiveStatus(true, file);
    ti_CloseAll();
    
    /* Close the graphics */
    gfx_End();
    
    
}

/* Put other functions here */
void menu(void) {
    gfx_SetTextTransparentColor(0);
    
    gfx_FillScreen(0);
    gfx_SetTextBGColor(0);
    gfx_SetTextFGColor(ListD[1]);
    gfx_PrintStringXY("Snake",1,1);
    gfx_SetTextFGColor(255);
    gfx_PrintStringXY("2nd Starts",1,9);
    
    gfx_SetTextXY(1,230);
    gfx_PrintString("High: ");
    gfx_PrintUInt(highscore,3);
    gfx_SetTextXY(1,220);
    gfx_PrintString("Score: ");
    gfx_PrintUInt(S,3);
    
    gfx_SetTextXY(1,2*9);
    gfx_PrintString("Size:  mode ");
    gfx_PrintUInt(D,2);
    gfx_PrintString(" del");
    
    gfx_SetTextXY(1,3*9);
    gfx_PrintString("Speed:  XT0n ");
    gfx_PrintUInt(Q,2);
    gfx_PrintString(" stat");
    
    gfx_SetTextXY(1,4*9);
    gfx_PrintString("Growth:  apps ");
    if (G == 100) {
        gfx_PrintString("Infinity");
    } else {
        gfx_PrintUInt(G,2);
    }
    gfx_PrintString(" prgm");
    
    gfx_SetTextXY(1,5*9);
    gfx_PrintString("Snake:  sin ");
    gfx_SetTextFGColor(ListD[1]);
    gfx_PrintUInt(ListD[1],3);
    gfx_SetTextFGColor(255);
    gfx_PrintString(" cos");
    
    gfx_SetTextXY(1,6*9);
    gfx_PrintString("Berries:  , ");
    gfx_SetTextFGColor(ListD[2]);
    gfx_PrintUInt(ListD[2],3);
    gfx_SetTextFGColor(255);
    gfx_PrintString(" (");
    
    while (!kb_AnyKey())
        kb_Scan();
    
    if (kb_Data[6] & kb_Clear)
        quit = true;
    
    /* size */
    if (kb_Data[1] & kb_Mode) {
        if (D != 1)
            D--;
    }
    
    if (kb_Data[1] & kb_Del) {
        if (D != 20)
            D++;
    }
    
    /* speed */
    if (kb_Data[3] & kb_GraphVar) {
        if (Q != 0)
            Q--;
    }
    if (kb_Data[4] & kb_Stat) {
        if (Q != 50)
            Q++;
    }
    
    /* growth */
    if (kb_Data[3] & kb_Apps) {
        if (G != 1)
            G--;
    }
    if (kb_Data[4] & kb_Prgm) {
        if (G != 100)
            G++;
    }
    
    /* colors */
    if (kb_Data[3] & kb_Sin) {
        if (ListD[1] != 0) {
            ListD[1]--;
        } else {
            ListD[1] = 255;
        }
    }
    
    if (kb_Data[4] & kb_Cos) {
        if (ListD[1] != 255) {
            ListD[1]++;
        } else {
            ListD[1] = 0;
        }
    }
    
    if (kb_Data[3] & kb_Comma) {
        if (ListD[2] != 0) {
            ListD[2]--;
        } else {
            ListD[2] = 255;
        }
    }
    if (kb_Data[4] & kb_LParen) {
        if (ListD[2] != 255) {
            ListD[2]++;
        } else {
            ListD[2] = 0;
        }
    }
    
    
    if (kb_Data[1] & kb_2nd)
        game();
    
}

void game(void) {
    
    gfx_SetTextTransparentColor(1);
    gfx_FillScreen(0);
    ListE[2] = (240/D);
    ListE[1] = (320/D);
    Y = ListE[2];
    X = ListE[1];
    for(A=1;A<6;A++) {
        ListA[6-A] = A;
        ListB[A] = ListE[2]/2;
    }
    
    gfx_SetTextBGColor(0);
    gfx_SetTextFGColor(255);
    gfx_SetColor(ListD[1]);
    for(A=1; A<6; A++) {
        gfx_FillRectangle(D*ListA[A],D*ListB[A],D,D);
    }
    ListC[1]=rand() % X;
    ListC[2]=rand() % Y;
    B=5;
    L=3;
    S=0;
    die=false;
    while (kb_AnyKey());
    while (die == false) {
        
        for (M=0;M<Q;M++)
            boot_WaitShort();
        gfx_SetColor(0);
        gfx_FillRectangle(D*ListA[B],D*ListB[B],D,D);
        gfx_SetColor(ListD[2]);
        gfx_FillRectangle(D*ListC[1],D*ListC[2],D,D);
        
        for(A=B-1; A>0; A--) {
            ListA[A+1] = ListA[A];
            ListB[A+1] = ListB[A];
        }
        kb_Scan();
        
        if (kb_Data[1] & kb_2nd) {
            while (kb_AnyKey());
            while (!(kb_Data[1] & kb_2nd ||  kb_Data[6] & kb_Clear))
                kb_Scan();
            if (kb_Data[1] & kb_2nd)
                while (kb_AnyKey());
        } // Pause button v1.1
        
        if (kb_Data[6] & kb_Clear) // if clear was pressed, quit
            die=true;
        
        
        if (kb_Data[7] & kb_Up && L != 1) {
            L=4;
        } else {
            if (kb_Data[7] & kb_Right && L != 2) {
                L=3;
            } else {
                if (kb_Data[7] & kb_Left && L != 3) {
                    L=2;
                } else {
                    if (kb_Data[7] & kb_Down && L != 4){
                        L=1;
                    }
                }
            }
        } //could have squeezed this into a mere 3 lines, bus this is easier to read, isn't it? v1.1
        
        if (L==1) {
            ListA[1] = ListA[2];
            ListB[1] = ListB[2]+1;
            if (ListB[2] == (ListE[2]-1))
                ListB[1] = 0;
        }
        if (L==2) {
            ListA[1] = ListA[2]-1;
            ListB[1] = ListB[2];
            if (ListA[2] == 0)
                ListA[1] = ListE[1]-1;
        }
        if (L==3) {
            ListA[1] = ListA[2]+1;
            ListB[1] = ListB[2];
            if (ListA[2] == (ListE[1]-1))
                ListA[1] = 0;
        }
        if (L==4) {
            ListA[1] = ListA[2];
            ListB[1] = ListB[2]-1;
            if (ListB[2] == 0)
                ListB[1] = ListE[2]-1;
        }
        
        gfx_SetColor(ListD[1]);
        gfx_FillRectangle(D*ListA[1],D*ListB[1],D,D);
        
        gfx_SetTextXY(1,1);
        gfx_PrintString("Score:");
        gfx_PrintUInt(S,3);
        gfx_SetTextXY(240,1);
        gfx_PrintString("High:");
        gfx_PrintUInt(highscore,3);
        
        if ((ListA[1] == ListC[1]) && (ListB[1] == ListC[2])) {
            
            if (G != 100) {
                for(A=1; A<(G+1);A++) {
                    B++;
                    ListA[B] = 500;
                    ListB[B] = 500;
                }
            }
            
            for(A=1;A<G+1;A++)
                S++;
            
            if (S > highscore) {
                highscore = S;
                ti_CloseAll();
                file = ti_Open(Snake_AppVar, "w");
                if (file)
                    ti_Write(&highscore, sizeof(highscore), 1, file);
            }
            
            ListC[1] = rand() % X;
            ListC[2] = rand() % Y;
        }
        
        for(A=2;A<(B+1);A++) {
            if ((ListA[1] == ListA[A]) && (ListB[1] == ListB[A]))
                die=true;
        }
        
        if (G==100 && S != 0) {
            B++;
            ListA[B] = 500;
            ListB[B] = 500;
        }
        
    }
    while (kb_AnyKey());
}

/*
 * ListA is for Snake X location
 * ListB is for Snake Y location
 * ListC is for Berry place
 * ListD is for Settings
 * ListE is for Screen size
 */
