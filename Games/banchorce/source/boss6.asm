;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Margoth Boss Routines                                         ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; initialisation
;------------------------------------------------
iniMargoth:
        ld      hl,INI_MARGOTH_HEALTH
        ld      (dHealth),hl
        ld      hl,INI_MARGOTH_YX
        ld      (dy),hl
        ld      a,MARGOTH_DAMAGE
        ld      b,MARGOTH_BULLET_DAMAGE
        ld      ix,doMargoth
        ld      de,drawMargoth
        ld      hl,finishedMargoth
        ret

;------------------------------------------------
; implementation
;------------------------------------------------
doMargoth:
        call    moveMargothObjects
        call    doDezemon                       ; move same pattern as Dezemon
        ld      a,(dCnt)
        cp      12
        jr      z,margothShoot
        cp      28
        ret     nz
margothShoot:
        ld      hl,frame
        bit     0,(hl)
        ret     nz
        call    getEmptyDemonEntry
        ret     c
        ld      (hl),1                          ; direction is moot right now, will be recalculated each time it moves, just needs to be non zero
        inc     hl
        ld      a,(dx)
        add     a,5
        ld      (hl),a
        inc     hl
        ld      a,(dy)
        add     a,5
        ld      (hl),a
        inc     hl
        ld      (hl),250                        ; object will move 250*2 times then despawn
        ret

moveMargothObjects:
        ld      b,MAX_DEMON_OBJECTS
        ld      ix,demonTable
moveMargothObjectsLoop:
        ld      a,(ix+D_DIR)
        or      a
        call    nz,moveMargothObject
        ld      a,(frame)
        bit     0,a
        jr      z,endMoveMargothObjectsLoop
        dec     (ix+D_SPECIAL)
        jr      nz,endMoveMargothObjectsLoop
        ld      (ix+D_DIR),0
endMoveMargothObjectsLoop:
        ld      de,DEMON_ENTRY_SIZE
        add     ix,de
        djnz    moveMargothObjectsLoop
        ret

moveMargothObject:
        push    bc
        call    getAngle                        ; recalculate angle every time it moves, so that it's constantly following the player
        inc     a
        ld      (ix+D_DIR),a
        ld      b,2
        call    moveDemonObject
        pop     bc
        ret

;------------------------------------------------
; graphics
;------------------------------------------------
drawMargoth:
        ld      hl,sprBoss1
        ld      a,(dCnt)
        cp      33
        jr      c,drawMargothStanding
        cp      116
        jr      nc,drawMargothStanding
        ld      b,%00001000
        cp      63
        jr      c,drawMargothWalking
        cp      86
        jr      nc,drawMargothWalking
        srl     b
drawMargothWalking:
        and     b
        jp      z,drawBoss
        ld      hl,sprBoss2
        jp      drawBoss
drawMargothStanding:
        srl     a
        srl     a
        cp      1
        jr      z,drawMargothHeadUp
        cp      5
        jr      z,drawMargothHeadUp
        cp      2
        jr      z,drawMargothHeadDown
        cp      6
        jr      z,drawMargothHeadDown
        jp      drawBoss
drawMargothHeadUp:
        ld      hl,sprBoss3
        jp      drawBoss
drawMargothHeadDown:
        ld      hl,sprBoss4
        jp      drawBoss

;------------------------------------------------
; finished
;------------------------------------------------
finishedMargoth:
        ld      a,173
        ld      bc,96*256+8
        ld      de,MARGOTH_GOLD
        ld      ix,margothChangeList
        ret

;------------------------------------------------
; dCnt settings
;------------------------------------------------
; 0-33          Standing, can shoot here
;               Shoots on 12 and 28
;               Head up on 4-7, 20-23
;               Head down on 8-11, 24-27
; 33-62         Walking slow
; 63-85         Walking fast
; 86-115        Walking slow
; 116-127       Stopped

.end
