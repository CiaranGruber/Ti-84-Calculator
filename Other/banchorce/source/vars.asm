;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Variables and Other Equates                                   ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; TI-86 -> TI-84+CE porting defines
;------------------------------------------------
GK_F1           = 53
GK_F2           = 52
GK_F3           = 51
GK_F4           = 50
GK_F5           = 49
GK_EXIT         = 55
GK_MORE         = 56

;------------------------------------------------
; Op equates
;------------------------------------------------
OP_OR_A                 = $B7
OP_SCF                  = $37

;------------------------------------------------
; Tile equates
;------------------------------------------------
BLACK                                   = 175
BLOCKWALL                               = 211
CHESTCLOSED                             = 165
CHESTOPEN                               = 166
DGRAY                                   = 2
DOOROPENDOWN                            = 40
DOOROPENUP                              = 39
DOORCLOSEDUP                            = 224
LAVA1                                   = 167
LAVA2                                   = 168
LGRAY                                   = 1
PERSON1LEFT                             = 234
PERSON1RIGHT                            = 235
PERSON2LEFT                             = 236
PERSON2RIGHT                            = 237
PERSON3LEFT                             = 238
PERSON3RIGHT                            = 239
SAPPHIRA1UP                             = 240
SAPPHIRA1DOWN                           = 241
SAPPHIRA2UP                             = 242
SAPPHIRA2DOWN                           = 243
SAPPHIRA3UP                             = 244
SAPPHIRA3DOWN                           = 245
ROCK1                                   = 89
ROCK2                                   = 90
ROCK3                                   = 91
STONE1                                  = 86
STONE2                                  = 87
STONE3                                  = 88
SWAMP1                                  = 84
SWAMP2                                  = 85
WATER1                                  = 82
WATER2                                  = 83
WATERFALL1                              = 169
WATERFALL2                              = 170
WATERFALL3                              = 171
WATERFALL4                              = 172
WATERFALLSPLASH1                        = 173
WATERFALLSPLASH2                        = 174
WELL1                                   = 163
WELL2                                   = 164
WATERPT1                                = 120
WATERPT2                                = 121
WATERPTL1                               = 122
WATERPTL2                               = 123
WATERPTR1                               = 124
WATERPTR2                               = 125
TILEFLOOR                               = 47
BRICKPORTAL1                            = 62
BRICKPORTAL2                            = 63
HELLPORTAL1                             = 64
HELLPORTAL2                             = 65
BRICKFLOOR                              = 51
BRICKFLOORWDOWN                         = 54
BRICKWALL                               = 213
STAIRSDOWNLEFT                          = 66
STAIRSDOWNRIGHT                         = 67
BRIDGEV                                 = 60
WHITE                                   = 0

;------------------------------------------------
; Defines to what player can walk over
;------------------------------------------------
NEED_AQUA                               = WATER1
NEED_WINGED                             = STONE1
CANT_WALK_OVER                          = WATERFALL1

;------------------------------------------------
; Misc defines
;------------------------------------------------
ONE_HEART                               = 32
NUMWARPS_OFFSET                         = 132
AREA_WAIT                               = 300000
BULLET_DAMAGE                           = ONE_HEART/4
ENEMY_WALL                              = WATER1
GOLD_MAX                                = 50000
TXT_DEAD                                = 26
MAX_CHANGES                             = 70

;------------------------------------------------
; Defines for sword strengths
;------------------------------------------------
SWORD_B_STR                             = 3
SWORD_S_STR                             = 6
SWORD_L_STR                             = 18

;------------------------------------------------
; Initialisation defines
;------------------------------------------------
INI_ATTACK                              = 10
INI_HEART_LEVEL                         = ONE_HEART
INI_HURT                                = 16
INI_YX_POS                              = 24*256+16
MAP_REX_HOUSE                           = 32
INI_YX_POS_REX_HOUSE                    = 96*256+16

;------------------------------------------------
; Demon defines
;------------------------------------------------
INI_HEATH_YX                            = 56*256+8
INI_HEATH_HEALTH                        = 350
HEATH_DAMAGE                            = ONE_HEART/2
HEATH_GOLD                              = 2000

INI_DEZEMON_YX                          = 56*256+8
INI_DEZEMON_HEALTH                      = 500
DEZEMON_DAMAGE                          = ONE_HEART
DEZEMON_GOLD                            = 5000

INI_WENDEG_YX                           = 56*256+9
INI_WENDEG_HEALTH                       = 750
WENDEG_DAMAGE                           = (ONE_HEART*3)/2
WENDEG_GOLD                             = 10000

INI_BELKATH_YX                          = 56*256+10
INI_BELKATH_HEALTH                      = 1000
BELKATH_DAMAGE                          = ONE_HEART*2
BELKATH_GOLD                            = 15000

INI_ANAZAR_YX                           = 24*256+20
INI_ANAZAR_HEALTH                       = 1500
ANAZAR_DAMAGE                           = (ONE_HEART*5)/2
ANAZAR_GOLD                             = 20000

INI_BANCHOR_YX                          = 56*256+8
INI_BANCHOR_HEALTH                      = 4000
BANCHOR_DAMAGE                          = ONE_HEART*3
BANCHOR_GOLD                            = 30000

;------------------------------------------------
; Item cost defines
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
COST_HEART_CONTAINER                    = 2000
COST_WELL                               = 150

;------------------------------------------------
; Enemy definitions
;------------------------------------------------
MAX_ENEMIES                             = 4
ENEMY_ENTRY_SIZE                        = 10
E_DIR                                   = 0
E_X                                     = 1
E_Y                                     = 2
E_HEALTH                                = 3
E_AI1CNT                                = 4
E_AI1OFF                                = 5
E_AI2CNT                                = 6
E_AI2OFF                                = 7
E_SPEED                                 = 8
E_HURT                                  = 9
enemyTable                              = freemem+65536-(ENEMY_ENTRY_SIZE*MAX_ENEMIES)

;------------------------------------------------
; Enemy bullet definitions
;------------------------------------------------
MAX_BULLETS                             = 2
BULLET_ENTRY_SIZE                       = 3
B_DIR                                   = 0
B_X                                     = 1
B_Y                                     = 2
bulletTable                             = enemyTable-(BULLET_ENTRY_SIZE*MAX_BULLETS)

;------------------------------------------------
; Animation definitions
;------------------------------------------------
MAX_ANIMS                               = 4
ANIM_ENTRY_SIZE                         = 3
A_CNT                                   = 0
A_X                                     = 1
A_Y                                     = 2
animTable                               = bulletTable-(ANIM_ENTRY_SIZE*MAX_ANIMS)

;------------------------------------------------
; Demon object definitions
;------------------------------------------------
MAX_DEMON_OBJECTS                       = 6
DEMON_ENTRY_SIZE                        = 4
D_DIR                                   = 0
D_X                                     = 1
D_Y                                     = 2
D_SPECIAL                               = 3
demonTable                              = animTable-(DEMON_ENTRY_SIZE*MAX_DEMON_OBJECTS)

;------------------------------------------------
; Map declarations
;------------------------------------------------
MAPS_OFFSET                             = 301
MAP_SIZE                                = 160
map                                     = datamem       ; 128   8 x 16 tiles
mapInfo                                 = map+128
upEdge                                  = mapInfo+0     ; 1
downEdge                                = mapInfo+1     ; 1
leftEdge                                = mapInfo+2     ; 1
rightEdge                               = mapInfo+3     ; 1
numWarps                                = mapInfo+4     ; 1
warps                                   = mapInfo+5     ; 16    4 warps x 4 bytes each
numPeople                               = mapInfo+21    ; 1
people                                  = mapInfo+22    ; 8     4 people x 2 bytes each
enemyType                               = mapInfo+30    ; 1
area                                    = mapInfo+31    ; 1

;------------------------------------------------
; In-game variables
;------------------------------------------------
vars                                    = map+MAP_SIZE
choice                                  = vars+000      ; 1     Main menu choice
y                                       = vars+001      ; 1     Player Y coord
x                                       = vars+002      ; 1     Player X coord
;; spare byte if HL writes to y,x
frame                                   = vars+004      ; 1     Frame counter
walkCnt                                 = vars+005      ; 1     Walk counter
attacking                               = vars+006      ; 1     Player attack flag
playerOffset                            = vars+007      ; 1     Player offset in map
string                                  = vars+008      ; 6     String buffer mem
hurt                                    = vars+014      ; 1     Player hurt flag
areaNum                                 = vars+015      ; 1     Area number
randData                                = vars+016      ; 3     Random data used in "random" routines
ai1                                     = vars+019      ; 1     AI script 1 for enemies
ai2                                     = vars+020      ; 1     AI script 2 for enemies
aiCnt                                   = vars+021      ; 1     Counter for AI scripts
aiOff                                   = vars+022      ; 1     Flag for AI scripts
collide1                                = vars+023      ; 4     Collision detection object
collide2                                = vars+027      ; 4     Collision detection object
attackStrength                          = vars+031      ; 1     Player's attack strength
heartLevel                              = vars+032      ; 1     Intermediate heart level the player doesn't see
dy                                      = vars+033      ; 1     Demon Y position
dx                                      = vars+034      ; 1     Demon X position
;; spare byte if HL writes to dy,dx
demonWarp                               = vars+036      ; 3     Data for where to warp to when demon finished
dHealth                                 = vars+039      ; 3     Demon health
demon                                   = vars+042      ; 1     Demon number player is fighting
dCnt                                    = vars+043      ; 1     Demon counter
dFlags                                  = vars+044      ; 1     Demon flags
dHurt                                   = vars+045      ; 1     Demon hurt this frame flag
aiCntOther                              = vars+046      ; 1     Copy of other AI counter

.end
