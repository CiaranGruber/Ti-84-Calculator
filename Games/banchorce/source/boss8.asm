;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Banchor Demon Routines                                        ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; Initialisation
;------------------------------------------------
iniBanchor:
        ld      hl,INI_BANCHOR_HEALTH
        ld      (dHealth),hl
        ld      hl,INI_BANCHOR_YX
        ld      (dy),hl
        ld      a,BANCHOR_DAMAGE
        ld      b,BANCHOR_BULLET_DAMAGE
        ld      ix,doBanchor
        ld      de,drawBanchor
        ld      hl,finishedBanchor
        ret

;------------------------------------------------
; Implementation
;------------------------------------------------
doBanchor:
        ld      c,0
        call    moveDemonObjectsNormal          ; move bullets
        call    doDezemon                       ; move same pattern as Dezemon
        ld      hl,frame
        bit     0,(hl)
        ret     nz
        ld      a,(dCnt)
        cp      33
        ld      ix,dFlags
        jr      c,banchorCheckShoot             ; see if he should shoot (only when not moving)
        ld      (ix),0
        ret
banchorCheckShoot:
        ld      a,(frame)
        and     %00000011
        ret     nz                              ; only try to shoot every 4th frame
        bit     0,(ix)                          ; has a shooting method already been picked?
        jr      nz,banchorShoot
        ld      b,2
        call    random                          ; pick a shooting method
        rlca
        or      %00000001
        ld      (ix),a
banchorShoot:
        bit     1,(ix)
        jr      nz,banchorShootDown
banchorShootCone:
        call    getNumBossObjects
        or      a
        ret     nz                              ; only shoot cone if no bullets active
        ld      b,BANCHOR_CONE_SIZE
        ld      ix,banchorConeTable
        ld      hl,demonTable
        ld      a,(dx)
        add     a,5
        ld      e,a
        ld      a,(dy)
        add     a,5
        ld      d,a
banchorConeLoop:
        ld      a,(ix)
        inc     ix
        ld      (hl),a
        inc     hl
        ld      (hl),e
        inc     hl
        ld      (hl),d
        inc     hl
        inc     hl
        djnz    banchorConeLoop
        ret
banchorShootDown:
        call    getEmptyDemonEntry
        ret     c
        ld      (hl),13
        inc     hl
        ld      a,(dx)
        add     a,5
        ld      (hl),a
        inc     hl
        ld      a,(dy)
        add     a,5
        ld      (hl),a
        ret

;------------------------------------------------
; Graphics
;------------------------------------------------
drawBanchor:
        ld      hl,sprBoss1
        ld      a,(dCnt)
        cp      33
        jr      c,drawBanchorStanding
        cp      116
        jr      nc,drawBanchorStanding
        ld      b,%00001000
        cp      63
        jr      c,drawBanchorWalking
        cp      86
        jr      nc,drawBanchorWalking
        srl     b
drawBanchorWalking:
        and     b
        jp      z,drawBoss
        ld      hl,sprBoss2
        jp      drawBoss
drawBanchorStanding:
        ld      ix,dFlags
        bit     0,(ix)                          ; is Banchor attacking?
        jp      z,drawBoss
        bit     1,(ix)
        ld      hl,sprBoss3
        jp      nz,drawBoss
        ld      hl,sprBoss4
        jp      drawBoss

;------------------------------------------------
; Finished
;------------------------------------------------
finishedBanchor:
        ld      a,57
        call    textMessage                     ; Show game complete text/credits, etc.
        ld      a,(difficulty)
        cp      3
        ld      a,77
        call    z,textMessage                   ; If Hell difficulty, show extra congratulations
        ld      a,221
        ld      bc,56*256+32
        ld      de,BANCHOR_GOLD
        ld      ix,banchorChangeList
        ret

;------------------------------------------------
; dCnt settings
;------------------------------------------------
; 0-33          Standing, can shoot here
; 33-62         Walking slow
; 63-85         Walking fast
; 86-115        Walking slow
; 116-127       Stopped

.end
