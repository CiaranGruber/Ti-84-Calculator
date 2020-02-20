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
        ld      bc,doDezemon
        ld      de,drawDezemon
        ld      hl,finishedDezemon
        ld      ix,0
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
        and     %00111111
        ld      (dCnt),a
        cp      33
        ret     c
        cp      52
        ret     nc
        cp      40
        jr      c,checkDezemonRoll
        cp      45
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
        ld      hl,bulletOffsets
        add     hl,de
        ld      a,(dy)
        add     a,(hl)
        ld      (dy),a
        inc     hl
        ld      a,(dx)
        add     a,(hl)
        ld      (dx),a
        jp      checkDemonOnScreen

;------------------------------------------------
; Graphics
;------------------------------------------------
drawDezemon:
        ld      a,(dCnt)
        ld      hl,sprDezemon1
        cp      20
        jp      c,drawDemon
        ld      hl,sprDezemon2
        cp      56
        jp      nc,drawDemon
        cp      29
        jp      c,drawDemon
        ld      hl,sprDezemon3
        jp      drawDemon

;------------------------------------------------
; Finished
;------------------------------------------------
finishedDezemon:
        ld      bc,104*256+32
        ld      de,DEZEMON_GOLD
        ld      ix,dezemonChangeList
        ld      a,64
        ret

;------------------------------------------------
; dCnt settings
;------------------------------------------------
; 0-19          Standing
; 20-28         Closing
; 29-32         Ready to roll
; 33-39         Rolling slow
; 40-44         Rolling fast
; 45-51         Rolling slow
; 52-55         Ready to open
; 56-63         Opening

.end
