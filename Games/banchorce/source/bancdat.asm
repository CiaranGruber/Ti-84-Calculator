;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Data                                                          ;
;                                                               ;
;---------------------------------------------------------------;

gamePalette:
#import "bancpal.bin"
GAME_PALETTE_SIZE       = $-gamePalette

strTitle:
.db     "BY JAMES VERNON",0
.db     "PRESS ANY KEY TO START",0
.db     "V",VERSION,0

strSelectGame:
.db     "-- SELECT GAME --",0

strSelectDiff:
.db     "SELECT DIFFICULTY:",0
.db     "  1. EASY",0
.db     "  2. NORMAL",0
.db     "  3. HARD",0
.db     "  4. HELL",0

strEmpty:
.db     "EMPTY",0

strEasy:
.db     "  EASY",0
strNormal:
.db     "NORMAL",0
strHard:
.db     "  HARD",0
strHell:
.db     "  HELL",0

strDelete:
.db     "  DELETE SELECTED GAME?",0
.db     254,255

strPaused:
.db     "PAUSED",0

strYes:
.db     "YES",0
strNo:
.db     "NO",0

#include "animdat.asm"                          ; Animation data
#include "areatxt.asm"                          ; Area Names
#include "bossdat.asm"                          ; Boss data
#include "enemydat.asm"                         ; Enemy Data
#include "huddat.asm"                           ; Hud data
#include "introtxt.asm"                         ; Introduction Text
#include "talktxt.asm"                          ; Talking Text

stoneRockTiles:
.db     STONE_SAND,STONE_GRASS,STONE_DIRT,CRUSHED_STONE_SAND,CRUSHED_STONE_GRASS,CRUSHED_STONE_DIRT
.db     ROCK_SAND,ROCK_GRASS,ROCK_DIRT,CRUSHED_ROCK_SAND,CRUSHED_ROCK_GRASS,CRUSHED_ROCK_DIRT

replaceStoneRockTiles:
.db     DIRT,GRASS,SAND,CRUSHED_ROCK_DIRT,CRUSHED_ROCK_GRASS,CRUSHED_ROCK_SAND
.db     DIRT,GRASS,SAND,CRUSHED_STONE_DIRT,CRUSHED_STONE_GRASS,CRUSHED_STONE_SAND

swordCoords:
.db     3,-7
.db     2,14
.db     -7,2
.db     14,2

reviveMapTable:
.db     0,0,0,0,0,0,0,0,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,28,28,28,28,28,28,28
.db     28,28,28,28,28,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
.db     67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,99,99,99,99,99
.db     99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,141
.db     141,141,141,141,141,141,141,141,141,141,141,141,141,141,141,141,141,141,141,141,141,141,141,141,141,141,159,159,159,159,159,159
.db     159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,185,185,185,185,185,185,185,185,185,185
.db     185,185,185,185,185,185,185,185,185,185,185,185,185,185,185,185,185,185,185,185,185,185,185,185,185,185,219,219,219,219,219,219
.db     219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219

reviveBossTable:
.db     12,47,67,99,141,159,185,219

reviveRefTable:
.db     0,12,28,47,67,99,141,159,185,219

reviveCoordsTable:
.dl     24*256+24,88*256+24,8*256+40,80*256+40,96*256+40,24*256+56,104*256+24,48*256+24,24*256+24,104*256+72

;------------------------------------------------
; sprite definitions & tables
;------------------------------------------------
sprPlayer1              = sprPlayer
sprPlayer2              = sprPlayer+(4*SPRITE_SIZE)
sprAttacking            = sprPlayer+(8*SPRITE_SIZE)
sprPlayerHurt           = sprPlayer+(16*SPRITE_SIZE)

sprKnightGrey           = sprEnemies
sprKnightBlue           = sprKnightGrey+256
sprKnightRed            = sprKnightBlue+256
sprKnightWhite          = sprKnightRed+256
sprOctopusPink          = sprKnightWhite+256
sprOctopusBlue          = sprOctopusPink+64
sprPotatoBugGreen       = sprOctopusBlue+64
sprPotatoBugWhite       = sprPotatoBugGreen+64
sprJellyfishRed         = sprPotatoBugWhite+64
sprJellyfishBlue        = sprJellyfishRed+128
sprJellyfishWhite       = sprJellyfishBlue+128
sprBatBlue              = sprJellyfishWhite+128
sprBatRed               = sprBatBlue+64
sprBatWhite             = sprBatRed+64
sprSnakeRed             = sprBatWhite+64
sprSnakeBlue            = sprSnakeRed+128
sprSnakeGreen           = sprSnakeBlue+128
sprSnakeWhite           = sprSnakeGreen+128
sprBeeRed               = sprSnakeWhite+128
sprFrogGreen            = sprBeeRed+64
sprFrogRed              = sprFrogGreen+256
sprSpiderBlue           = sprFrogRed+256
sprSpiderRed            = sprSpiderBlue+64
sprMummyWhite           = sprSpiderRed+64
sprPigmySkeletonWhite   = sprMummyWhite+128
sprPigmySkeletonBlack   = sprPigmySkeletonWhite+128
sprPigmySkeletonRed     = sprPigmySkeletonBlack+128
sprTrollPink            = sprPigmySkeletonRed+128
sprTrollBlue            = sprTrollPink+128
sprTrollWhite           = sprTrollBlue+128
sprMudmanRed            = sprTrollWhite+128
sprTreeMonsterGreen     = sprMudmanRed+128
sprShadowBeastBlack     = sprTreeMonsterGreen+64
sprDeathLordWhite       = sprShadowBeastBlack+128
sprKorandaRed           = sprDeathLordWhite+64
sprSpawn                = sprKorandaRed+64
sprBullet               = sprSpawn+128

enemySpriteTable:
; Grey Knight
.dl     sprKnightGrey,sprKnightGrey+64,sprKnightGrey+128,sprKnightGrey+192
; Pink Octopus
.dl     sprOctopusPink,sprOctopusPink,sprOctopusPink,sprOctopusPink
; Green Potato Bug
.dl     sprPotatoBugGreen,sprPotatoBugGreen,sprPotatoBugGreen,sprPotatoBugGreen
; Red Jellyfish
.dl     sprJellyfishRed,sprJellyfishRed+64,sprJellyfishRed,sprJellyfishRed+64
; Blue Bat
.dl     sprBatBlue,sprBatBlue,sprBatBlue,sprBatBlue
; Red Snake
.dl     sprSnakeRed,sprSnakeRed+64,sprSnakeRed,sprSnakeRed+64
; Bee
.dl     sprBeeRed,sprBeeRed,sprBeeRed,sprBeeRed
; Blue Snake
.dl     sprSnakeBlue,sprSnakeBlue+64,sprSnakeBlue,sprSnakeBlue+64
; Green Frog
.dl     sprFrogGreen,sprFrogGreen+64,sprFrogGreen+128,sprFrogGreen+192
; Blue Spider
.dl     sprSpiderBlue,sprSpiderBlue,sprSpiderBlue,sprSpiderBlue
; White Mummy
.dl     sprMummyWhite,sprMummyWhite+64,sprMummyWhite,sprMummyWhite+64
; White Pigmy Skeleton
.dl     sprPigmySkeletonWhite,sprPigmySkeletonWhite+64,sprPigmySkeletonWhite,sprPigmySkeletonWhite+64
; Pink Troll
.dl     sprTrollPink,sprTrollPink+64,sprTrollPink,sprTrollPink+64
; Green Snake
.dl     sprSnakeGreen,sprSnakeGreen+64,sprSnakeGreen,sprSnakeGreen+64
; Red Bat
.dl     sprBatRed,sprBatRed,sprBatRed,sprBatRed
; Blue Stone Knight
.dl     sprKnightBlue,sprKnightBlue+64,sprKnightBlue+128,sprKnightBlue+192
; White Potato Bug
.dl     sprPotatoBugWhite,sprPotatoBugWhite,sprPotatoBugWhite,sprPotatoBugWhite
; White Snake
.dl     sprSnakeWhite,sprSnakeWhite+64,sprSnakeWhite,sprSnakeWhite+64
; Blue Jellyfish
.dl     sprJellyfishBlue,sprJellyfishBlue+64,sprJellyfishBlue,sprJellyfishBlue+64
; Blue Octopus
.dl     sprOctopusBlue,sprOctopusBlue,sprOctopusBlue,sprOctopusBlue
; White Bat
.dl     sprBatWhite,sprBatWhite,sprBatWhite,sprBatWhite
; Red Frog
.dl     sprFrogRed,sprFrogRed+64,sprFrogRed+128,sprFrogRed+192
; Red Mudman
.dl     sprMudmanRed,sprMudmanRed+64,sprMudmanRed,sprMudmanRed+64
; Red Spider
.dl     sprSpiderRed,sprSpiderRed,sprSpiderRed,sprSpiderRed
; Green Tree Monster
.dl     sprTreeMonsterGreen,sprTreeMonsterGreen,sprTreeMonsterGreen,sprTreeMonsterGreen
; White Jellyfish
.dl     sprJellyfishWhite,sprJellyfishWhite+64,sprJellyfishWhite,sprJellyfishWhite+64
; Blue Troll
.dl     sprTrollBlue,sprTrollBlue+64,sprTrollBlue,sprTrollBlue+64
; Red Stone Knight
.dl     sprKnightRed,sprKnightRed+64,sprKnightRed+128,sprKnightRed+192
; Black Pigmy Skeleton
.dl     sprPigmySkeletonBlack,sprPigmySkeletonBlack+64,sprPigmySkeletonBlack,sprPigmySkeletonBlack+64
; White Troll
.dl     sprTrollWhite,sprTrollWhite+64,sprTrollWhite,sprTrollWhite+64
; Black Shadow Beast
.dl     sprShadowBeastBlack,sprShadowBeastBlack+64,sprShadowBeastBlack,sprShadowBeastBlack+64
; White Death Lord
.dl     sprDeathLordWhite,sprDeathLordWhite,sprDeathLordWhite,sprDeathLordWhite
; Red Koranda
.dl     sprKorandaRed,sprKorandaRed,sprKorandaRed,sprKorandaRed
; Red Pigmy Demon
.dl     sprPigmySkeletonRed,sprPigmySkeletonRed+64,sprPigmySkeletonRed,sprPigmySkeletonRed+64
; White Stone Knight
.dl     sprKnightWhite,sprKnightWhite+64,sprKnightWhite+128,sprKnightWhite+192

sprExplosion            = sprAnims
ANIM_MAX                = 6

sprFullHeart            = sprHud
sprHalfHeart            = sprFullHeart+64
sprEmptyHeart           = sprHalfHeart+64
sprGold                 = sprEmptyHeart+64
sprBluntSword           = sprGold+64
sprSuperiorSword        = sprBluntSword+64
sprLegendarySword       = sprSuperiorSword+64
sprWoodenShield         = sprLegendarySword+64
sprIronShield           = sprWoodenShield+64
sprLightArmor           = sprIronShield+64
sprHeavyArmor           = sprLightArmor+64
sprAquaBoots            = sprHeavyArmor+64
sprWingedBoots          = sprAquaBoots+64
sprRingOfMight          = sprWingedBoots+64
sprRingOfThunder        = sprRingOfMight+64
sprHeartPiece           = sprRingOfThunder+64
sprCrystal              = sprHeartPiece+64

.end
