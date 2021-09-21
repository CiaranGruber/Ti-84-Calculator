;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Durcrux Boss Routines                                         ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; initialisation
;------------------------------------------------
iniDurcrux:
        ld      hl,INI_DURCRUX_HEALTH
        ld      (dHealth),hl
        ld      hl,INI_DURCRUX_YX
        ld      (dy),hl
        ld      a,DURCRUX_DAMAGE
        ld      b,DURCRUX_BULLET_DAMAGE
        ld      ix,doDurcrux
        ld      de,drawDurcrux
        ld      hl,finishedDurcrux
        ret

;------------------------------------------------
; implementation
;------------------------------------------------
doDurcrux:
        call    moveDurcruxBullets
        ld      a,(dCnt)
        inc     a
        cp      192
        jr      c,durcruxCheck
        ; about to phase in, so choose a random x,y
        ld      b,COLS*8-16-16
        call    random
        add     a,8
        ld      (dx),a
        ld      b,24
        call    random
        add     a,8
        ld      (dy),a
        xor     a
durcruxCheck:
        ld      (dCnt),a
        cp      64
        jr      z,durcruxShoot
        cp      128
        ret     nz
durcruxPhaseOut:
        ld      a,COLS*8
        ld      (dx),a
        ret
durcruxShoot:
        ; throw 3 objects in a cone towards the player, they move a small distance and then sit
        call    getDemonAngle
        ld      e,a
        ld      d,3
        mlt     de
        ld      hl,durcruxBullets
        add     hl,de
        ld      b,3
makeDurcruxBullets:
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
        add     a,5
        ld      (hl),a
        inc     hl
        ld      (hl),248
        inc     de
        ex      de,hl
        pop     bc
        djnz    makeDurcruxBullets
        ret

moveDurcruxBullets:
        ld      ix,demonTable
        ld      b,MAX_DEMON_OBJECTS
moveDurcruxBulletsLoop:
        push    bc
        ld      a,(ix+D_DIR)
        or      a
        jr      z,moveDurcruxBulletsNext
        dec     (ix+D_SPECIAL)
        jr      z,moveDurcruxBulletsDespawn
        ld      a,(ix+D_SPECIAL)
        cp      232
        jr      c,moveDurcruxBulletsNext
        ld      b,1
        cp      242
        jr      c,moveDurcruxBulletsFrame
        ld      b,0
moveDurcruxBulletsFrame:
        call    moveDemonObject
        jr      moveDurcruxBulletsNext
moveDurcruxBulletsDespawn:
        ld      (ix+D_DIR),0
moveDurcruxBulletsNext:
        ld      de,DEMON_ENTRY_SIZE
        add     ix,de
        pop     bc
        djnz    moveDurcruxBulletsLoop
        ret

;------------------------------------------------
; graphics
;------------------------------------------------
drawDurcrux:
        ld      hl,sprBoss1
        ld      a,(dCnt)
        cp      128
        ret     nc                              ; no need to draw boss when invisible
        cp      32
        jr      c,drawDurcruxPhasing
        cp      96
        jr      nc,drawDurcruxPhasing
        cp      56
        jp      c,drawBoss
        cp      72
        jp      nc,drawBoss
        ld      hl,sprBoss2
        jp      drawBoss
drawDurcruxPhasing:
        ld      a,(frame)
        bit     1,a
        ret     nz
        jp      drawBoss

;------------------------------------------------
; finished
;------------------------------------------------
finishedDurcrux:
        ld      a,215
        ld      bc,64*256+8
        ld      de,DURCRUX_GOLD
        ld      ix,durcruxChangeList
        ret

;------------------------------------------------
; dCnt settings
;------------------------------------------------
; 0-31          Phasing in
; 32-95         Standing and shooting (shoots on 64)
; 96-127        Phasing out
; 128-191       Invisible (boss is off screen during this so player can't attack it)

.end
