;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Variables and Other Equates                                   ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; include files
;------------------------------------------------
#include "ti84pce.inc"
#include "get_key.inc"
#include "tiles.asm"

;------------------------------------------------
; misc definitions
;------------------------------------------------
#define HUFF84PCE                               ; notify huffextr.asm of TI-84+CE
#define MOVE9() call _Mov9ToOP1
#define LDHLIND() push de \ ld e,(hl) \ inc hl \ ld d,(hl) \ inc hl \ ld a,(hl) \ ex de,hl \ pop de \ call _setHLUtoA
#define HLTIMES8() add hl,hl \ add hl,hl \ add hl,hl
#define LDHLA() or a \ sbc hl,hl \ ld l,a
#define ABSA() bit 7,a \ jr z,$+4 \ neg
#define ADIV8() sra a \ sra a \ sra a
AREA_COUNT_MAX                          = 80
HUD_COUNT_MAX                           = 2
#define DRAW_AREA_NAME() ld a,AREA_COUNT_MAX \ ld (__drawAreaName),a
#define REDRAW_HUD() ld a,HUD_COUNT_MAX \ ld (__redrawHud),a
#define db .db
#define dw .dw
#define dl .dl

;------------------------------------------------
; some graphics definitions
;------------------------------------------------
vbuf1                                   = vram
vbuf2                                   = vram+(320*240)
pVram                                   = mpLcdBase

COLS                                    = 16
ROWS                                    = 12

WIN_X                                   = 32
WIN_Y                                   = 32
VBUF_WIN_OFFSET                         = (WIN_Y*320)+WIN_X

SPRITE_WIDTH                            = 8
SPRITE_HEIGHT                           = 8
SPRITE_SIZE                             = SPRITE_WIDTH*SPRITE_HEIGHT

SCROLL_DELAY                            = 640
FADE_DELAY                              = 2000

GFX_FILE_TITLE                          = 0
GFX_FILE_MAINGFX                        = 1
GFX_FILE_BOSS_WALLS                     = 2
GFX_FILE_BOSS_FLOORS                    = 3
GFX_FILE_BOSS_SPRITES                   = GFX_FILE_BOSS_FLOORS+8

;------------------------------------------------
; colour definitions
;------------------------------------------------
COLOUR_BLACK                            = 1
COLOUR_RED                              = 3
COLOUR_REDORANGE                        = 4
COLOUR_ORANGE                           = 5
COLOUR_YELLOW                           = 7
COLOUR_BLUE                             = 12
COLOUR_PURPLE                           = 15
COLOUR_REDGREY                          = 16
COLOUR_DARKRED                          = 19
COLOUR_GREEN                            = 24
COLOUR_GREENGREY                        = 32
COLOUR_BLUEGREY                         = 48
COLOUR_WHITE                            = 50

;------------------------------------------------
; TI-86 -> TI-84+CE porting definitions
;------------------------------------------------
GK_F1                                   = 53
GK_F2                                   = 52
GK_F3                                   = 51
GK_F4                                   = 50
GK_F5                                   = 49
GK_EXIT                                 = 55
GK_MORE                                 = 56

;------------------------------------------------
; op equates
;------------------------------------------------
OP_SCF                                  = $37
OP_INC_A                                = $3C
OP_DEC_A                                = $3D
OP_XOR_A                                = $AF
OP_OR_A                                 = $B7
OP_RET                                  = $C9
OP_CALLZ                                = $CC
OP_CALL                                 = $CD

;------------------------------------------------
; definitions for what player can walk over
;------------------------------------------------
NEED_AQUA                               = WATER
NEED_WINGED                             = STONE_SAND
CANT_WALK_OVER                          = WATERFALL_1

;------------------------------------------------
; misc game definitions
;------------------------------------------------
ONE_HEART                               = 32
QH1                                     = ONE_HEART/4
QH2                                     = QH1*2
QH3                                     = QH1*3
QH4                                     = QH1*4
QH5                                     = QH1*5
QH6                                     = QH1*6
QH7                                     = QH1*7
QH8                                     = QH1*8
QH12                                    = QH1*12
QH16                                    = QH1*16
NUMWARPS_OFFSET                         = 132
AREA_WAIT                               = 300000
BULLET_DAMAGE                           = ONE_HEART/4
ENEMY_WALL                              = WATER
GOLD_MAX                                = 99990
TXT_DEAD                                = 26
TXT_GAMEOVER                            = 66
MAX_CHANGES                             = 100
ORB_CHANCE                              = 8

;------------------------------------------------
; sword strengths
;------------------------------------------------
SWORD_B_STR                             = 3
SWORD_S_STR                             = 9
SWORD_L_STR                             = 18

;------------------------------------------------
; initialisation definitions
;------------------------------------------------
INI_ATTACK                              = 10
INI_HEARTS                              = 3
INI_HEART_LEVEL                         = ONE_HEART
INI_HURT                                = 24
INI_YX_POS                              = 24*256+16
MAP_REX_HOUSE                           = 31
INI_YX_POS_REX_HOUSE                    = 96*256+32
INI_ORB_COUNT                           = 1     ; value currently just needs to be non-zero, but could be programmed for use as a despawn timer

;------------------------------------------------
; boss definitions
;------------------------------------------------
INI_HEATH_YX                            = 56*256+8
INI_HEATH_HEALTH                        = 350
HEATH_DAMAGE                            = QH2
HEATH_GOLD                              = 2000

INI_DEZEMON_YX                          = 56*256+10
INI_DEZEMON_HEALTH                      = 500
DEZEMON_DAMAGE                          = QH2
DEZEMON_GOLD                            = 5000

INI_WENDEG_YX                           = 56*256+12
INI_WENDEG_HEALTH                       = 1000
WENDEG_DAMAGE                           = QH4
WENDEG_BULLET_DAMAGE                    = QH2
WENDEG_GOLD                             = 10000

INI_BELKATH_YX                          = 56*256+10
INI_BELKATH_HEALTH                      = 1200
BELKATH_DAMAGE                          = QH4
BELKATH_BULLET_DAMAGE                   = QH2
BELKATH_GOLD                            = 12000

INI_ANAZAR_YX                           = ((COLS*8)-8-16)*256+40
INI_ANAZAR_HEALTH                       = 1000
ANAZAR_DAMAGE                           = QH5
ANAZAR_BULLET_DAMAGE                    = QH2
ANAZAR_GOLD                             = 16000

INI_MARGOTH_YX                          = 44*256+8
INI_MARGOTH_HEALTH                      = 2000
MARGOTH_DAMAGE                          = QH6
MARGOTH_BULLET_DAMAGE                   = QH2
MARGOTH_GOLD                            = 20000

INI_DURCRUX_YX                          = 64*256+12
INI_DURCRUX_HEALTH                      = 3000
DURCRUX_DAMAGE                          = QH12
DURCRUX_BULLET_DAMAGE                   = QH4
DURCRUX_GOLD                            = 25000

INI_BANCHOR_YX                          = 56*256+8
INI_BANCHOR_HEALTH                      = 4000
BANCHOR_DAMAGE                          = QH16
BANCHOR_BULLET_DAMAGE                   = QH8
BANCHOR_GOLD                            = 50000

;------------------------------------------------
; item costs
;------------------------------------------------
COST_SUPERIOR_SWORD                     = 15000
COST_LEGENDARY_SWORD                    = 35000
COST_IRON_SHIELD                        = 22000
COST_LIGHT_ARMOR                        = 10000
COST_HEAVY_ARMOR                        = 30000
COST_AQUA_BOOTS                         = 20000
COST_WINGED_BOOTS                       = 40000
COST_RING_OF_MIGHT                      = 8000
COST_RING_OF_THUNDER                    = 25000
COST_HEART_CONTAINER_1                  = 2000
COST_HEART_CONTAINER_2                  = 4000
COST_HEART_CONTAINER_3                  = 8000
COST_WELL                               = 150
#define GOLDTXT_SUPERIOR_SWORD          "15000"
#define GOLDTXT_LEGENDARY_SWORD         "35000"
#define GOLDTXT_IRON_SHIELD             "22000"
#define GOLDTXT_LIGHT_ARMOR             "10000"
#define GOLDTXT_HEAVY_ARMOR             "30000"
#define GOLDTXT_AQUA_BOOTS              "20000"
#define GOLDTXT_WINGED_BOOTS            "40000"
#define GOLDTXT_RING_OF_MIGHT           "8000"
#define GOLDTXT_RING_OF_THUNDER         "25000"
#define GOLDTXT_HEART_CONTAINER_1       "2000"
#define GOLDTXT_HEART_CONTAINER_2       "4000"
#define GOLDTXT_HEART_CONTAINER_3       "8000"
#define GOLDTXT_WELL                    "150"

;------------------------------------------------
; enemy definitions
;------------------------------------------------
MAX_ENEMIES                             = 4
ENEMY_ENTRY_SIZE                        = 10
E_DIR                                   = 0
E_X                                     = 1
E_Y                                     = 2
E_HEALTH                                = 3
E_FRAME                                 = 4
E_PAUSECNT                              = 5
E_JUMPCNT                               = 6
E_SPEED                                 = 7
E_FLAGS                                 = 8
E_HURT                                  = 9

;------------------------------------------------
; Enemy bullet definitions
;------------------------------------------------
MAX_BULLETS                             = 2
BULLET_ENTRY_SIZE                       = 3
B_DIR                                   = 0
B_X                                     = 1
B_Y                                     = 2

;------------------------------------------------
; Animation definitions
;------------------------------------------------
MAX_ANIMS                               = 4
ANIM_ENTRY_SIZE                         = 3
A_CNT                                   = 0
A_X                                     = 1
A_Y                                     = 2

;------------------------------------------------
; Demon object definitions
;------------------------------------------------
MAX_DEMON_OBJECTS                       = 6
DEMON_ENTRY_SIZE                        = 4
D_DIR                                   = 0
D_X                                     = 1
D_Y                                     = 2
D_SPECIAL                               = 3

;------------------------------------------------
; health orb definitions
;------------------------------------------------
MAX_HEALTH_ORBS                         = 3
ORB_ENTRY_SIZE                          = 3
O_COUNT                                 = 0
O_X                                     = 1
O_Y                                     = 2


;------------------------------------------------
; start of memory layout
;------------------------------------------------
freemem                 = pixelshadow           ; 69090 bytes of available memory to use

huffTree                = freemem               ; 1024 bytes used by huffExtr
treeAddr                = huffTree+1024         ; 3 bytes used by huffExtr

font                    = treeAddr+3            ; 2744, space for 56 7x7 font characters

pVbuf                   = font+2744             ; 3
pVbufWin                = pVbuf+3               ; 3

;------------------------------------------------
; map definitions
;------------------------------------------------
MAPS_OFFSET             = 301
MAP_SIZE                = 224
TILE_DATA_SIZE          = ROWS*COLS
MAP_META_SIZE           = MAP_SIZE-TILE_DATA_SIZE
map                     = pVbufWin+3            ; 192   16 x 12 tiles
mapInfo                 = map+TILE_DATA_SIZE
upEdge                  = mapInfo+0             ; 1
downEdge                = mapInfo+1             ; 1
leftEdge                = mapInfo+2             ; 1
rightEdge               = mapInfo+3             ; 1
numWarps                = mapInfo+4             ; 1
warps                   = mapInfo+5             ; 16    4 warps x 4 bytes each
numPeople               = mapInfo+21            ; 1
people                  = mapInfo+22            ; 8     4 people x 2 bytes each
enemyType               = mapInfo+30            ; 1
area                    = mapInfo+31            ; 1

nextMap                 = map+MAP_SIZE          ; place to store tiles of next map when scrolling screen

;------------------------------------------------
; in-game variables
;------------------------------------------------
vars                    = nextMap+MAP_SIZE
choice                  = vars+000              ; 1     Main menu choice
y                       = vars+001              ; 1     Player Y coord
x                       = vars+002              ; 1     Player X coord
;; spare byte if HL writes to y,x               ; 1
frame                   = vars+004              ; 1     Frame counter
walkCnt                 = vars+005              ; 1     Walk counter
attacking               = vars+006              ; 1     Player attack flag
playerOffset            = vars+007              ; 1     Player offset in map
string                  = vars+008              ; 6     String buffer mem
hurt                    = vars+014              ; 1     Player hurt flag
areaNum                 = vars+015              ; 1     Area number
randData                = vars+016              ; 3     Random data used in "random" routines
dirFlags                = vars+019              ; 1     Direction flags used in enemyFollow AI routine
collide1                = vars+020              ; 4     Collision detection object
collide2                = vars+024              ; 4     Collision detection object
attackStrength          = vars+028              ; 1     Player's attack strength
heartLevel              = vars+029              ; 1     Partial heart level (shown as either a full heart or half heart)
dy                      = vars+030              ; 1     Demon Y position
dx                      = vars+031              ; 1     Demon X position
;; spare byte if HL writes to dy,dx             ; 1
demonWarp               = vars+033              ; 3     Data for where to warp to when demon finished
dHealth                 = vars+036              ; 3     Demon health
demon                   = vars+039              ; 1     Demon number player is fighting
dCnt                    = vars+040              ; 1     Demon counter
dFlags                  = vars+041              ; 1     Demon flags
dHurt                   = vars+042              ; 1     Demon hurt this frame flag
gameNum                 = vars+043              ; 1     game selection counter
tempSprite              = vars+044              ; 256   temporary sprite storage

enemyTable              = vars+320
bulletTable             = enemyTable+(ENEMY_ENTRY_SIZE*MAX_ENEMIES)
animTable               = bulletTable+(BULLET_ENTRY_SIZE*MAX_BULLETS)
demonTable              = animTable+(ANIM_ENTRY_SIZE*MAX_ANIMS)
orbTable                = demonTable+(DEMON_ENTRY_SIZE*MAX_DEMON_OBJECTS)

;------------------------------------------------
; game data that will be included in save files
;------------------------------------------------
gameData                = orbTable+(ORB_ENTRY_SIZE*MAX_HEALTH_ORBS)
difficulty              = gameData              ; 1
mapNo                   = difficulty+1          ; 1
playerDir               = mapNo+1               ; 1
enterMapCoords          = playerDir+1           ; 3
hearts                  = enterMapCoords+3      ; 1
maxHearts               = hearts+1              ; 1
gold                    = maxHearts+1           ; 3
items                   = gold+3                ; 12
crystals                = items+12              ; 7
chests                  = crystals+7            ; 300
changeList              = chests+300            ; 300

SAVE_GAME_SIZE          = 630
NUM_ITEMS               = 12+7

bluntSword              = items+0
superiorSword           = items+1
legendarySword          = items+2
woodenShield            = items+3
ironShield              = items+4
lightArmor              = items+5
heavyArmor              = items+6
aquaBoots               = items+7
wingedBoots             = items+8
ringOfMight             = items+9
ringOfThunder           = items+10
heartPiece              = items+11


;------------------------------------------------
; place for gfx assets to be decompressed to
;------------------------------------------------
gfxmem                  = gameData+SAVE_GAME_SIZE
tileset                 = gfxmem                ; 16384 (256 sprites)
sprPlayer               = tileset+16384         ; 1280 (20 sprites)
sprEnemies              = sprPlayer+1280        ; 4608 (69 enemy sprites, 2 spawning sprites, 1 bullet sprite)
sprAnims                = sprEnemies+4608       ; 384 (6 explosion animation sprites)
sprOrb                  = sprAnims+384          ; 64 (1 health orb sprite)
sprHud                  = sprOrb+64             ; 1088 (17 hud sprites)
sprBoss                 = sprHud+1088           ; 1088 (17 boss sprites)

.end
