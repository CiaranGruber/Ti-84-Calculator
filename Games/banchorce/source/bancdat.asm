;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Data File                                                     ;
;                                                               ;
;---------------------------------------------------------------;

palGray:
.dw 20145
.dw 13771
.dw 7430
.dw 1089
.dw 8192
PAL_GRAY_SIZE           = $-palGray

font83ce:
#include "font83ce.asm"

#include "mapspr.asm"

titlePic:
#import "title.huf"

titlePic2:
#import "title2.huf"

DSXMIN                                  = 16
DSXMAX                                  = 128-16
D_INI_YX                                = ((DSXMAX-DSXMIN)/2+DSXMIN-4)*256+64-8

;------------------------------------------------
; Map animation table
;------------------------------------------------
animationTable:
; Normal water
.db     WATER1,WATER2, WATER2,WATER1
; Swamp water
.db     SWAMP1,SWAMP2, SWAMP2,SWAMP1
; Lava
.db     LAVA1,LAVA2, LAVA2,LAVA1
; Waterfall
.db     WATERFALL1,WATERFALL2, WATERFALL2,WATERFALL3, WATERFALL3,WATERFALL4, WATERFALL4,WATERFALL1
; Waterfall Splash
.db     WATERFALLSPLASH1,WATERFALLSPLASH2, WATERFALLSPLASH2,WATERFALLSPLASH1
; Water behind Pine Trees (Top)
.db     WATERPT1,WATERPT2, WATERPT2,WATERPT1
; Water behind Pine Trees (Top-left)
.db     WATERPTL1,WATERPTL2, WATERPTL2, WATERPTL1
; Water behind Pine Trees (Top-right)
.db     WATERPTR1,WATERPTR2, WATERPTR2, WATERPTR1
; Person 1
.db     PERSON1LEFT,PERSON1RIGHT, PERSON1RIGHT, PERSON1LEFT
; Person 2
.db     PERSON2LEFT,PERSON2RIGHT, PERSON2RIGHT, PERSON2LEFT
; Person 3
.db     PERSON3LEFT,PERSON3RIGHT, PERSON3RIGHT, PERSON3LEFT
; Sapphira 1
.db     SAPPHIRA1UP,SAPPHIRA1DOWN, SAPPHIRA1DOWN, SAPPHIRA1UP
; Sapphira 2
.db     SAPPHIRA2UP,SAPPHIRA2DOWN, SAPPHIRA2DOWN, SAPPHIRA2UP
; Sapphira 3
.db     SAPPHIRA3UP,SAPPHIRA3DOWN, SAPPHIRA3DOWN, SAPPHIRA3UP
; Well
.db     WELL1,WELL2, WELL2,WELL1
; Brick Portal
.db     BRICKPORTAL1,BRICKPORTAL2, BRICKPORTAL2,BRICKPORTAL1
; Hell Portal
.db     HELLPORTAL1,HELLPORTAL2, HELLPORTAL2, HELLPORTAL1
animationTableSize                      = ($-animationTable)/2

#include "animspr.asm"                          ; Animation Sprites
#include "areatxt.asm"                          ; Area Names
#include "demondat.asm"                         ; Demon Data
#include "demonspr.asm"                         ; Demon Sprites
#include "enemydat.asm"                         ; Enemy Data
#include "enemyspr.asm"                         ; Enemy Sprites
#include "invendat.asm"                         ; Inventory Screen Data
#include "invenspr.asm"                         ; Inventory Screen Sprites
#include "playrspr.asm"                         ; Player Sprites
#include "talkdat.asm"                          ; Talking Data
#include "talktxt.asm"                          ; Talking Text

stoneRockTiles:
.db     STONE1,STONE2,STONE3,ROCK1,ROCK2,ROCK3

replaceStoneRockTiles:
.db     DGRAY,LGRAY,WHITE,DGRAY,LGRAY,WHITE

swordCoords:
.db     3,-7
.db     2,14
.db     -7,2
.db     14,2

reviveMapTable:
.db 0,0,0,0,0,0,0,0,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,29,29,29,29,29,29,29,29,29,29,29,29,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
.db 48,48,48,48,48,48,48,48,48,48,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116
.db 116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,158,184,184,184,184,184,184,184,184,184,184,184
.db 184,184,184,184,184,184,184,184,184,184,184,184,184,184,184,184,184,184,184,184,184,184,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216,216

reviveRefTable:
.db 0,12,29,48,77,116,158,184,216
reviveCoordsTable:
.dl 24*256+16,88*256+24,8*256+40,80*256+40,96*256+40,24*256+40,104*256+16,24*256+24,40*256+32

.end
