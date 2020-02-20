;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Belkath Demon Routines                                        ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; Initialisation
;------------------------------------------------
iniBelkath:
        ld      hl,INI_BELKATH_HEALTH
        ld      (dHealth),hl
        ld      hl,INI_BELKATH_YX
        ld      (dy),hl
        ld      a,BELKATH_DAMAGE
        ld      bc,doBelkath
        ld      de,drawBelkath
        ld      hl,finishedBelkath
        ld      ix,sprBelkathBullet
        ret

;------------------------------------------------
; Implementation
;------------------------------------------------
doBelkath:
        ld      hl,frame
        bit     0,(hl)
        ret     nz
        call    moveDemonObjectsNormal
moveBelkath:
        ld      a,(dFlags)
        ld      hl,dx
        bit     0,a
        jr      nz,moveBelkathRight
moveBelkathLeft:
        dec     (hl)
        ld      a,(hl)
        cp      DSXMIN+8
        jr      nz,afterMoveBelkath
changeBelkathDirection:
        ld      a,(dFlags)
        xor     1
        ld      (dFlags),a
        jr      afterMoveBelkath
moveBelkathRight:
        inc     (hl)
        ld      a,(hl)
        cp      DSXMAX-24
        jr      z,changeBelkathDirection
afterMoveBelkath:
        ld      a,(frame)
        and     %00111111
        ret     nz
; Throw 3 objects
        call    getDemonAngle
        ld      e,a
        ld      d,3
        mlt     de
        ld      hl,belkathBullets
        add     hl,de
        ld      b,3
makeBelkathBullets:
        push    bc
        push    hl
        call    getEmptyDemonEntry
        pop     de
        ld      a,(de)
        inc     a
        ld      (hl),a
        inc     hl
        ld      a,(dx)
        add     a,5
        ld      (hl),a
        inc     hl
        ld      a,(dy)
        add     a,6
        ld      (hl),a
        inc     de
        ex      de,hl
        pop     bc
        djnz    makeBelkathBullets
        ret

;------------------------------------------------
; Graphics
;------------------------------------------------
drawBelkath:
        ld      hl,sprBelkath1
        ld      a,(frame)
        bit     3,a
        jp      z,drawDemon
        ld      hl,sprBelkath2
        jp      drawDemon

;------------------------------------------------
; Finished
;------------------------------------------------
finishedBelkath:
        ld      bc,64*256+8
        ld      de,BELKATH_GOLD
        ld      ix,belkathChangeList
        ld      a,139
        ret

.end
