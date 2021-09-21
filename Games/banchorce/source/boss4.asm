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
        ld      b,BELKATH_BULLET_DAMAGE
        ld      ix,doBelkath
        ld      de,drawBelkath
        ld      hl,finishedBelkath
        ret

;------------------------------------------------
; Implementation
;------------------------------------------------
doBelkath:
        call    moveBelkathBullets
        ld      hl,dCnt
        inc     (hl)
        ld      a,(hl)
        cp      112
        jr      nc,afterMoveBelkath
moveBelkath:
        ld      a,(dFlags)
        ld      hl,dx
        bit     0,a
        jr      nz,moveBelkathRight
moveBelkathLeft:
        dec     (hl)
        ld      a,(hl)
        cp      8
        jr      nz,afterMoveBelkath
changeBelkathDirection:
        ld      a,(dFlags)
        xor     1
        ld      (dFlags),a
        jr      afterMoveBelkath
moveBelkathRight:
        inc     (hl)
        ld      a,(hl)
        cp      (COLS*8)-16-8
        jr      z,changeBelkathDirection
afterMoveBelkath:
        ld      a,(dCnt)
        cp      118
        jr      z,belkathShoot
        cp      128
        ret     c
        ld      b,32
        call    random
        ld      (dCnt),a
        ret

belkathShoot:
        call    getEmptyDemonEntry
        ret     c
        push    hl
        call    getDemonAngle
        pop     hl
        inc     a
        ld      (hl),a
        inc     hl
        ld      a,(dx)
        add     a,5
        ld      (hl),a
        inc     hl
        ld      a,(dy)
        add     a,5
        ld      (hl),a
        inc     hl
        ld      (hl),1
        ret

moveBelkathBullets:
        ld      b,MAX_DEMON_OBJECTS
        ld      ix,demonTable
moveBelkathBulletLoop:
        push    bc
        ld      a,(ix+D_DIR)
        or      a
        jr      z,endMoveBelkathBulletLoop
        ld      a,(ix+D_SPECIAL)
        xor     1
        ld      b,a                             ; thrown bullets move fast, split/rebound bullets move normal
        call    moveDemonObject
        ld      a,(ix+D_SPECIAL)
        or      a
        jr      z,endMoveBelkathBulletLoop
        ld      a,(ix+D_X)
        cp      BELKATH_LEFT+1
        jp      c,belkathBulletLeft
        cp      BELKATH_RIGHT
        jp      nc,belkathBulletRight
        ld      a,(ix+D_Y)
        cp      BELKATH_TOP+1
        jp      c,belkathBulletTop
        cp      BELKATH_BOTTOM
        jp      nc,belkathBulletBottom
endMoveBelkathBulletLoop:
        pop     bc
        ld      de,DEMON_ENTRY_SIZE
        add     ix,de
        djnz    moveBelkathBulletLoop
        ret

belkathBulletLeft:
        ld      de,bBounceLeft
        jr      belkathBulletHitWall
belkathBulletRight:
        ld      de,bBounceRight
        jr      belkathBulletHitWall
belkathBulletTop:
        ld      de,bBounceTop
        jr      belkathBulletHitWall
belkathBulletBottom:
        ld      de,bBounceBottom
belkathBulletHitWall:
        ; despawn this bullet
        ld      (ix+D_DIR),0
        ; spawn 4 bullets in its place
        ld      b,4
belkathSplitLoop:
        push    bc
        push    de
        call    getEmptyDemonEntry
        pop     de
        jr      c,endBelkathSplitLoop
        ld      a,(de)
        inc     a
        ld      (hl),a
        inc     hl
        ld      a,(ix+D_X)
        ld      (hl),a
        inc     hl
        ld      a,(ix+D_Y)
        ld      (hl),a
        inc     hl
        ld      (hl),0
endBelkathSplitLoop:
        inc     de
        pop     bc
        djnz    belkathSplitLoop
        ret

;------------------------------------------------
; Graphics
;------------------------------------------------
drawBelkath:
        ld      hl,sprBoss2
        ld      a,(dCnt)
        cp      112
        jp      nc,drawBoss
        ld      a,(frame)
        bit     3,a
        jp      z,drawBoss
        ld      hl,sprBoss1
        jp      drawBoss

;------------------------------------------------
; Finished
;------------------------------------------------
finishedBelkath:
        ld      a,125
        ld      bc,96*256+8
        ld      de,BELKATH_GOLD
        ld      ix,belkathChangeList
        ret

;------------------------------------------------
; dCnt settings
;------------------------------------------------
; 0-111         Moving, but when dCnt resets it will get a random number between 0-31 to randomise the walking distance each time
; 112-127       Standing (shoots on 118)

.end
