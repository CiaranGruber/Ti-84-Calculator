;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Boss Data                                                     ;
;                                                               ;
;---------------------------------------------------------------;

DSXMIN                                  = 16
DSXMAX                                  = 128-16
B_INI_YX                                = ((COLS*8/2)-4)*256+(ROWS*8)-16

;------------------------------------------------
; X & Y offsets used when drawing 16x16 boss sprite
;------------------------------------------------
bossDrawTable:
.db     8,0
.db     -8,8
.db     8,0

;------------------------------------------------
; x & y offsets when creating boss death explosions
;------------------------------------------------
bossExplodeTable:
.db     -1,0
.db     10,8
.db     9,-1
.db     0,9

;------------------------------------------------
; Change list entries to add after Heath defeated
;------------------------------------------------
heathChangeList:
.db     5
.db     20,STONE_WALL_1,33
.db     21,DOOR_DOWN,183
.db     4,DOOR_UP,7
.db     16,GRASS,78
.db     16,GRASS,94

;------------------------------------------------
; Change list entries to add after Dezemon defeated
;------------------------------------------------
dezemonChangeList:
.db     5
.db     60,BRICK_FLOOR,91
.db     60,BRICK_FLOOR,107
.db     60,CLOSED_DOOR_UP,8
.db     39,STAIRS_DOWN_L,65
.db     42,WOOD_BRIDGE_V,89

;------------------------------------------------
; Change list entries to add after Wendeg defeated
;------------------------------------------------
wendegChangeList:
.db     4
.db     79,CLOSED_DOOR_UP,7
.db     79,ICE_FLOOR,45
.db     69,STAIRS_DOWN_R,92
.db     75,GRASS,72

;------------------------------------------------
; Change list entries to add after Belkath defeated
;------------------------------------------------
belkathChangeList:
.db     4
.db     120,CLOSED_DOOR_DOWN,151
.db     125,DIRT,75
.db     101,GRASS,151
.db     114,STAIRS_DOWN_R,46    

;------------------------------------------------
; Change list entries to add after Anazar defeated
;------------------------------------------------
anazarChangeList:
.db     3
.db     146,CLOSED_DOOR_UP,13
.db     145,STONE_FLOOR,74
.db     131,STAIRS_DOWN_R,46

;------------------------------------------------
; Change list entries to add after Margoth defeated
;------------------------------------------------
margothChangeList:
.db     3
.db     173,CLOSED_DOOR_UP,2
.db     173,BLUESTONE_FLOOR,58
.db     164,STAIRS_DOWN_R,174

;------------------------------------------------
; Change list entries to add after Drurcux defeated
;------------------------------------------------
durcruxChangeList:
.db     3
.db     215,CLOSED_DOOR_UP,29
.db     215,DARKSTONE_FLOOR,43
.db     189,STAIRS_DOWN_R,78

;------------------------------------------------
; Change list entries to add after Banchor defeated
;------------------------------------------------
banchorChangeList:
.db     1
.db     248,CLOSED_DOOR_UP,8

;------------------------------------------------
; Wendeg data
;------------------------------------------------
wendegStarPattern1:
.db     -2,-1
.db     -2,0
.db     -1,0
.db     -1,1
.db     -1,1
.db     -1,1
.db     -1,2
.db     -1,2
.db     -1,2
.db     -1,3

WENDEG_STAR_STEPS               = ($-wendegStarPattern1)/2

wendegStarPattern2:
.db     0,-1
.db     0,0
.db     0,0
.db     0,1
.db     0,1
.db     0,1
.db     0,2
.db     0,2
.db     0,2
.db     0,3

wendegStarPattern3:
.db     2,-1
.db     2,0
.db     1,0
.db     1,1
.db     1,1
.db     1,1
.db     1,2
.db     1,2
.db     1,2
.db     1,3

;------------------------------------------------
; Belkath data
;------------------------------------------------
bBounceTop:
.db     9,11,13,15
BELKATH_TOP             = 8

bBounceBottom:
.db     1,3,5,7
BELKATH_BOTTOM          = (ROWS*8)-5

bBounceLeft:
.db     1,3,13,15
BELKATH_LEFT            = 8

bBounceRight:
.db     5,7,9,11
BELKATH_RIGHT           = (COLS*8)-8-5

;------------------------------------------------
; Anazar data
;------------------------------------------------
anazarHorizTable:
.db     0,0,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,0,0
ANAZAR_HORIZ_MAX        = $-anazarHorizTable

anazarVertTable:
.db     0,0,0,0,0,1,1,1,1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1,1,1,1,0,0,0,0,0

aBounceTop:
.db     0,15,14,13,12,11,10,9,8,9,10,11,12,13,14,15
ANAZAR_TOP              = BELKATH_TOP

aBounceBottom:
.db     0,1,2,3,4,5,6,7,8,7,6,5,4,3,2,1
ANAZAR_BOTTOM           = BELKATH_BOTTOM

aBounceLeft:
.db     0,1,2,3,4,3,2,1,0,15,14,13,12,13,14,15
ANAZAR_LEFT             = BELKATH_LEFT

aBounceRight:
.db     8,7,6,5,4,5,6,7,8,9,10,11,12,11,10,9
ANAZAR_RIGHT            = BELKATH_RIGHT

;------------------------------------------------
; Durcrux data
;------------------------------------------------
durcruxBullets:
.db     0,2,14
.db     1,3,15
.db     2,4,0
.db     3,5,1
.db     4,6,2
.db     5,7,3
.db     6,8,4
.db     7,9,5
.db     8,10,6
.db     9,11,7
.db     10,12,8
.db     11,13,9
.db     12,14,10
.db     13,15,11
.db     14,0,12
.db     15,1,13

;------------------------------------------------
; Banchor data
;------------------------------------------------
banchorConeTable:
.db     2,5,8,10,13,16
BANCHOR_CONE_SIZE       = $-banchorConeTable

;------------------------------------------------
; boss room layout
;------------------------------------------------
bossRoom:
.db     $08,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$0A
.db     $05,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$07
.db     $04,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$06
.db     $05,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$07
.db     $04,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$06
.db     $05,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$07
.db     $04,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$06
.db     $05,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$07
.db     $04,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$06
.db     $05,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$07
.db     $04,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$06
.db     $05,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$02,$03,$07

;------------------------------------------------
; sprite definitions
;------------------------------------------------
sprBoss1                = sprBoss
sprBoss2                = sprBoss1+(64*4)
sprBoss3                = sprBoss2+(64*4)
sprBoss4                = sprBoss3+(64*4)
sprBossBullet           = sprBoss4+(64*4)

.end
