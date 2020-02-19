;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Demon Data                                                    ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; X & Y offsets used when drawing 16x16 demon sprite
;------------------------------------------------
demonDrawTable:
.db     8,0
.db     -8,8
.db     8,0

;------------------------------------------------
; Change list entries to add after Heath defeated
;------------------------------------------------
heathChangeList:
.db     5
.db     20,BLOCKWALL,33
.db     21,DOOROPENDOWN,119
.db     4,DOOROPENUP,7
.db     16,12,77
.db     16,14,93

;------------------------------------------------
; Change list entries to add after Dezemon defeated
;------------------------------------------------
dezemonChangeList:
.db     6
.db     61,BRICKFLOORWDOWN,119
.db     61,BRICKFLOORWDOWN,120
.db     64,BRICKFLOOR,59
.db     38,STAIRSDOWNLEFT,82
.db     43,BRIDGEV,73
.db     64,BRICKWALL,26

;------------------------------------------------
; Change list entries to add after Wendeg defeated
;------------------------------------------------
wendegChangeList:
.db     4
.db     97,DOORCLOSEDUP,3
.db     97,TILEFLOOR,60
.db     85,24,72
.db     79,STAIRSDOWNRIGHT,92

;------------------------------------------------
; Change list entires to add after Belkath defeated
;------------------------------------------------
belkathChangeList:
.db     4
.db     139,BRICKWALL,77
.db     139,28,54
.db     119,16,87
.db     133,STAIRSDOWNRIGHT,46

;------------------------------------------------
; Change list entires to add after Anazar defeated
;------------------------------------------------
anazarChangeList:
.db     3
.db     211,2,82
.db     211,1,NUMWARPS_OFFSET
.db     188,STAIRSDOWNRIGHT,62

;------------------------------------------------
; Change list entires to add after Banchor defeated
;------------------------------------------------
banchorChangeList:
.db     1
.db     219,DOORCLOSEDUP,55

;------------------------------------------------
; Wendeg star movement data
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
belkathBullets:
.db     0,4,15
.db     1,5,6
.db     2,7,13
.db     3,10,13
.db     4,0,11
.db     5,1,14
.db     6,1,12
.db     7,2,9
.db     8,10,15
.db     9,7,14
.db     10,3,8
.db     11,4,12
.db     12,6,11
.db     13,2,3
.db     14,5,9
.db     15,0,8

;------------------------------------------------
; Anazar data
;------------------------------------------------
anazarOffsets:
.db     0,-1
.db     0,-1
.db     0,-1
.db     1,-1
.db     0,-1
.db     1,-1
.db     0,-1
.db     1,-1
.db     1,0
.db     1,-1
.db     1,-1
.db     1,0
.db     1,-1
.db     1,0
.db     1,0
.db     1,0
.db     1,-1
.db     1,0
.db     1,0
.db     1,0
.db     1,0
.db     1,0
.db     1,0
.db     1,0
.db     1,0
.db     1,1
.db     1,0
.db     1,0
.db     1,0
.db     1,1
.db     1,0
.db     1,1
.db     1,1
.db     1,0
.db     1,1
.db     0,1
.db     1,1
.db     0,1
.db     1,1
.db     0,1
.db     0,1
ANAZAR_MAX                              = ($-anazarOffsets)/2

aBounceTop:
.db     0,0,0,0,0,0,2,1
.db     0,5,4,3,13,0,14,15
ANAZAR_TOP                              = 8

aBounceBottom:
.db     8,7,6,11,10,9,0,0
.db     0,0,0,0,0,12,0,0
ANAZAR_BOTTOM                           = 64-5

aBounceLeft:
.db     0,0,0,2,1,0,0,0
.db     0,8,7,6,12,13,15,0
ANAZAR_LEFT                             = DSXMIN+8

aBounceRight:
.db     5,4,3,0,0,0,11,10
.db     9,0,0,0,12,13,0,14
ANAZAR_RIGHT                            = DSXMAX-8-5

.end
