;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Dezemon Demon Routines                                        ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; Initialisation
;------------------------------------------------
iniDezemon:
        ld      hl,INI_DEZEMON_HEALTH
        ld      (dHealth),hl
        ld      hl,INI_HEATH_YX
        ld      (dy),hl
        ld      a,DEZEMON_DAMAGE
        ld      b,0
        ld      ix,doDezemon
        ld      de,drawDezemon
        ld      hl,finishedDezemon
        ret

;------------------------------------------------
; Implementation
;------------------------------------------------
doDezemon:
        ld      hl,frame
        bit     0,(hl)
        ret     nz
        ld      a,(dCnt)
        inc     a
        and     %01111111
        ld      (dCnt),a
        cp      33
        ret     c
        cp      116
        ret     nc
        cp      63
        jr      c,checkDezemonRoll
        cp      86
        jr      c,dezemonRoll
checkDezemonRoll:
        ld      hl,frame
        bit     1,(hl)
        ret     nz
dezemonRoll:
        call    getDemonAngle
        ld      e,a
        ld      d,2
        mlt     de
        ld      hl,dir16Offsets
        add     hl,de
        ld      a,(dy)
        add     a,(hl)
        ld      (dy),a
        inc     hl
        ld      a,(dx)
        add     a,(hl)
        ld      (dx),a
        jp      checkBossOnScreen

;------------------------------------------------
; Graphics
;------------------------------------------------
drawDezemon:
        ld      a,(dCnt)
        ld      hl,sprBoss1
        cp      20
        jp      c,drawBoss
        ld      hl,sprBoss2
        cp      119
        jp      nc,drawBoss
        cp      29
        jp      c,drawBoss
        ld      hl,sprBoss3
        cp      33
        jp      c,drawBoss
        cp      116
        jp      nc,drawBoss
        ld      b,%00000100
        cp      63
        jr      c,drawDezemonFrameCheck
        cp      86
        jr      nc,drawDezemonFrameCheck
        srl     b
drawDezemonFrameCheck:
        ld      a,(frame)
        and     b
        jp      z,drawBoss
        ld      hl,sprBoss4
        jp      drawBoss

;------------------------------------------------
; Finished
;------------------------------------------------
finishedDezemon:
        ld      a,60
        ld      bc,104*256+72
        ld      de,DEZEMON_GOLD
        ld      ix,dezemonChangeList
        ret

;------------------------------------------------
; dCnt settings
;------------------------------------------------
; 0-19          Standing
; 20-28         Closing
; 29-32         Ready to roll
; 33-62         Rolling slow
; 63-85         Rolling fast
; 86-115        Rolling slow
; 116-119       Ready to open
; 119-127       Opening

.end
