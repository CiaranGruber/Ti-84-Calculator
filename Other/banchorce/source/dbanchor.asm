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
        ld      bc,doBanchor
        ld      de,drawBanchor
        ld      hl,finishedBanchor
        ld      ix,sprBanchorBullet
        ret

;------------------------------------------------
; Implementation
;------------------------------------------------
doBanchor:
        call    moveDemonObjectsNormal
        call    doDezemon
        ld      a,(dCnt)
        cp      33
        ret     nc
        ld      a,(frame)
        and     %00000011
        ret     nz
        call    getEmptyDemonEntry
        ret     c
        ld      (hl),14
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
        ld      a,(dCnt)
        cp      33
        jr      c,drawBanchorStanding
        cp      52
        jr      nc,drawBanchorStanding
        ld      hl,frame
        bit     4,(hl)
        ld      hl,sprBanchor1
        jp      z,drawDemon
        ld      hl,sprBanchor2
        jp      drawDemon
drawBanchorStanding:
        ld      hl,sprBanchor3
        jp      drawDemon

;------------------------------------------------
; Finished
;------------------------------------------------
finishedBanchor:
        ld      a,57
        call    textMessage                     ; Show game complete text/credits, etc.
        ld      bc,56*256+32
        ld      de,BANCHOR_GOLD
        ld      ix,banchorChangeList
        ld      a,219
        ret

.end
