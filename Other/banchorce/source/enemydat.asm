;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Enemy Data                                                    ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; Initial health for each enemy
;------------------------------------------------
enemyHealth:
.db     1,8,10,20,1,1,10,20,18,18
.db     20,24,18,36,27,45,60,56,70,50
.db     56,60,75,56,62,85,50,100,130,110
.db     100,140,160,180,200

;------------------------------------------------
; How much gold player gets when an enemy is killed (divided by 10)
;------------------------------------------------
enemyGold:
.db     1,5,2,4,2,2,10,4,3,4
.db     8,9,6,8,9,7,12,18,28,20
.db     16,18,22,25,22,32,28,30,32,32
.db     30,35,45,50,48

;------------------------------------------------
; Speed of each enemy
;------------------------------------------------
enemySpeed:
.db     1,1,1,1,0,1,1,1,1,1
.db     1,0,1,1,0,1,1,1,1,1
.db     0,1,1,1,0,1,1,1,0,1
.db     1,1,1,0,1

;------------------------------------------------
; Whether or not each enemy can fly over water/solid tiles
;------------------------------------------------
enemyFlying:
.db     0,1,0,0,1,0,1,0,1,1
.db     0,0,0,0,1,0,0,0,0,1
.db     1,1,1,1,0,0,0,0,0,0
.db     1,1,1,0,0

;------------------------------------------------
; How much each enemy hurts player on contact
;------------------------------------------------
enemyDamage:
.db     ONE_HEART/4,ONE_HEART/4,ONE_HEART/4,ONE_HEART/4,ONE_HEART/4
.db     ONE_HEART/2,ONE_HEART/4,ONE_HEART/4,ONE_HEART/4,ONE_HEART/4
.db     ONE_HEART/2,ONE_HEART/4,ONE_HEART/2,(ONE_HEART*3)/4,ONE_HEART/2
.db     ONE_HEART/2,ONE_HEART,ONE_HEART,(ONE_HEART*3)/2,(ONE_HEART*3)/2
.db     (ONE_HEART*3)/2,(ONE_HEART*3)/2,(ONE_HEART*3)/2,ONE_HEART*2,(ONE_HEART*3)/2
.db     ONE_HEART*2,ONE_HEART*2,ONE_HEART*2,ONE_HEART,ONE_HEART*2
.db     ONE_HEART*2,ONE_HEART*2,ONE_HEART*2,(ONE_HEART*3)/2,ONE_HEART*2

;------------------------------------------------
; AI Tags
;------------------------------------------------
AI_NONE                                 = 0
AI_FOLLOWPLAYER                         = 1
AI_FOLLOWPLAYERHITWALLS                 = 2
AI_CIRCULAR                             = 3
AI_SHOOT                                = 4
AI_JUMP                                 = 5
AI_RANDOMMOVEMENT                       = 6
AI_RANDOMMOVEMENTHITWALLS               = 7
AI_FROGMOVE                             = 8
AI_SHOOT4DIR                            = 9
AI_HORIZMOVE                            = 10
AI_WAIT                                 = 11

;------------------------------------------------
; AI Scripts used by each enemy
;------------------------------------------------
enemyAI:
.db     AI_RANDOMMOVEMENTHITWALLS,AI_NONE       ; Castle Stone Knight
.db     AI_JUMP,AI_SHOOT                        ; Light Octopus
.db     AI_FOLLOWPLAYERHITWALLS,AI_NONE         ; Dark Potato Bug
.db     AI_FOLLOWPLAYERHITWALLS,AI_WAIT         ; Light Jellyfish
.db     AI_CIRCULAR,AI_NONE                     ; Light Bat
.db     AI_FOLLOWPLAYERHITWALLS,AI_JUMP         ; Light Snake
.db     AI_CIRCULAR,AI_SHOOT                    ; Bee
.db     AI_FOLLOWPLAYERHITWALLS,AI_JUMP         ; Dark Snake
.db     AI_FROGMOVE,AI_NONE                     ; Light Frog
.db     AI_RANDOMMOVEMENT,AI_SHOOT              ; Light Spider
.db     AI_FOLLOWPLAYERHITWALLS,AI_SHOOT4DIR    ; Mummy
.db     AI_FOLLOWPLAYERHITWALLS,AI_NONE         ; Black Pigmy Skeleton
.db     AI_RANDOMMOVEMENTHITWALLS,AI_SHOOT4DIR  ; Light Troll
.db     AI_FOLLOWPLAYERHITWALLS,AI_JUMP         ; Black Snake
.db     AI_CIRCULAR,AI_NONE                     ; Dark Bat
.db     AI_RANDOMMOVEMENTHITWALLS,AI_SHOOT4DIR  ; Light Stone Knight
.db     AI_FOLLOWPLAYERHITWALLS,AI_NONE         ; White Potato Bug
.db     AI_FOLLOWPLAYERHITWALLS,AI_JUMP         ; White Snake
.db     AI_FOLLOWPLAYERHITWALLS,AI_WAIT         ; Dark Jellyfish
.db     AI_JUMP,AI_SHOOT                        ; Dark Octopus
.db     AI_CIRCULAR,AI_NONE                     ; White Bat
.db     AI_FROGMOVE,AI_NONE                     ; Dark Frog
.db     AI_FOLLOWPLAYER,AI_NONE                 ; Mudman
.db     AI_RANDOMMOVEMENT,AI_SHOOT              ; Dark Spider
.db     AI_FOLLOWPLAYERHITWALLS,AI_WAIT         ; Tree Monster
.db     AI_FOLLOWPLAYERHITWALLS,AI_WAIT         ; White Jellyfish
.db     AI_RANDOMMOVEMENTHITWALLS,AI_SHOOT4DIR  ; Dark Troll
.db     AI_RANDOMMOVEMENTHITWALLS,AI_SHOOT4DIR  ; Dark Stone Knight
.db     AI_FOLLOWPLAYERHITWALLS,AI_NONE         ; White Pigmy Skeleton
.db     AI_RANDOMMOVEMENTHITWALLS,AI_SHOOT4DIR  ; White Troll
.db     AI_FOLLOWPLAYER,AI_NONE                 ; Shadow Beast
.db     AI_HORIZMOVE,AI_NONE                    ; Death Lord
.db     AI_FOLLOWPLAYER,AI_SHOOT                ; Koranda
.db     AI_FOLLOWPLAYERHITWALLS,AI_JUMP         ; Midget Demon
.db     AI_RANDOMMOVEMENTHITWALLS,AI_SHOOT      ; Hell Knight

;------------------------------------------------
; What enemy's bullets can be blocked with the Wooden Shield
;------------------------------------------------
woodenBlock:
.db     2,7,20
NUM_WOODEN                              = $-woodenBlock

;------------------------------------------------
; Circle X & Y offsets
;------------------------------------------------
circleTable:
.db     0,-1
.db     0,-1
.db     1,-1
.db     0,-1
.db     1,-1
.db     1,-1
.db     1,0
.db     1,-1
.db     1,0
.db     1,0
.db     1,0
.db     1,0
.db     1,1
.db     1,0
.db     1,1
.db     1,1
.db     0,1
.db     1,1
.db     0,1
.db     0,1
.db     0,1
.db     0,1
.db     -1,1
.db     0,1
.db     -1,1
.db     -1,1
.db     -1,0
.db     -1,1
.db     -1,0
.db     -1,0
.db     -1,0
.db     -1,0
.db     -1,-1
.db     -1,0
.db     -1,-1
.db     -1,-1
.db     0,-1
.db     -1,-1
.db     0,-1
.db     0,-1
CIRCLE_MAX              = ($-circleTable)/2

;------------------------------------------------
; X & Y offsets for 16 directions of movement
;------------------------------------------------
bulletOffsets:
;------------------------------------------------
; Direction table
;------------------------------------------------
;         9     12    8
;    10         |         7
;               |
;  11           |            6
;               |
;               |
;  14 ----------+---------- 15
;               |
;               |
;  3            |            2
;               |
;     4         |         1
;         5    13    0
;------------------------------------------------
.db     2,1     ; 0
.db     2,2     ; 1
.db     1,2     ; 2
.db     1,-2    ; 3
.db     2,-2    ; 4
.db     2,-1    ; 5
.db     -1,2    ; 6
.db     -2,2    ; 7
.db     -2,1    ; 8
.db     -2,-1   ; 9
.db     -2,-2   ; 10
.db     -1,-2   ; 11
.db     -2,0    ; 12
.db     2,0     ; 13
.db     0,-2    ; 14
.db     0,2     ; 15

;------------------------------------------------
; Y Offsets for jumping
;------------------------------------------------
jumpTable:
.db     -3,-2,-2,-2,-1,-1,0,0                   ; Going up..
.db     0,1,1,2,2,2,3                           ;          .. coming down
JUMP_MAX                                = $-jumpTable

;------------------------------------------------
; Frog movement data
;------------------------------------------------
frogYTable:
.db     -2,-2,-1,-1,1,1,2,2,0,0,0,0
frogXTable:
.db     1,1,1,1,1,1,1,1,0,0,0,0
frogDirTable:
.db     2,2,2,2,2,2,2,2,1,1,1,1
FROG_CNT_MAX    = ($-frogYTable)/3

;------------------------------------------------
; Horizontal sway movement data
;------------------------------------------------
horizMoveTable1:
.db     -1,-1,0,1,1,1,1,0,-1,-1
HORIZ_MAX_1     = $-horizMoveTable1
horizMoveTable2:
.db     -2,-2,-1,0,1,2,2,2,2,1,0,-1,-2,-2
HORIZ_MAX_2     = $-horizMoveTable2

.end
