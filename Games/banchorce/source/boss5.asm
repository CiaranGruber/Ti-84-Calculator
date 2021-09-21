;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Anazar Demon Routines                                         ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; Initialisation
;------------------------------------------------
iniAnazar:
        xor     a
        ld      (frame),a                       ; this boss requires frame counter initialisation
        ld      hl,INI_ANAZAR_HEALTH
        ld      (dHealth),hl
        ld      hl,INI_ANAZAR_YX
        ld      (dy),hl
        ld      a,ANAZAR_DAMAGE
        ld      b,ANAZAR_BULLET_DAMAGE
        ld      ix,doAnazar
        ld      de,drawAnazar
        ld      hl,finishedAnazar
        ret

;------------------------------------------------
; Implementation
;------------------------------------------------
doAnazar:
        ld      b,MAX_DEMON_OBJECTS
        ld      ix,demonTable
moveAnazarBullets:
        push    bc
        ld      a,(ix+D_DIR)
        or      a
        jr      z,endMoveAnazarBullets
        ld      b,2
        call    moveDemonObject
        ld      a,(ix+D_SPECIAL)
        or      a
        jr      z,endMoveAnazarBullets
        ld      a,(ix+D_X)
        cp      ANAZAR_LEFT+1
        jp      c,anazarBulletLeft
        cp      ANAZAR_RIGHT
        jp      nc,anazarBulletRight
        ld      a,(ix+D_Y)
        cp      ANAZAR_TOP+1
        jp      c,anazarBulletTop
        cp      ANAZAR_BOTTOM
        jp      nc,anazarBulletBottom
endMoveAnazarBullets:
        pop     bc
        ld      de,DEMON_ENTRY_SIZE
        add     ix,de
        djnz    moveAnazarBullets
anazarShoot:
        call    getEmptyDemonEntry
        ld      a,(frame)
        and     %01111111
        jr      nz,moveAnazar                   ; Only make new bullet every 128th frame
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
        ld      (hl),3
moveAnazar:
        ld      ix,dFlags
        ; first do horizontal movement, which works off the boss counter
        ld      a,(dCnt)
        or      a
        sbc     hl,hl
        ld      l,a
        ld      de,anazarHorizTable
        add     hl,de
        inc     a
        cp      ANAZAR_HORIZ_MAX
        jr      nz,anazarSaveCount
        ld      a,(ix)
        xor     %00000001
        ld      (ix),a
        xor     a
anazarSaveCount:
        ld      (dCnt),a
        bit     0,(ix)
        ld      a,(hl)
        ld      hl,dx
        jr      nz,moveAnazarHoriz
        neg
moveAnazarHoriz:
        add     a,(hl)
        ld      (hl),a
        ; do vertical movement, which works off the frame counter
        ld      a,(frame)
        and     %00011111
        jr      nz,afterAnazarToggle
        ld      c,a
        ld      a,(ix)
        xor     %00000010
        ld      (ix),a
        ld      a,c
afterAnazarToggle:
        or      a
        sbc     hl,hl
        ld      l,a
        ld      de,anazarVertTable
        add     hl,de
        bit     1,(ix)
        ld      a,(hl)
        ld      hl,dy
        jr      nz,moveAnazarVert
        neg
moveAnazarVert:
        add     a,(hl)
        ld      (hl),a
        ret

anazarBulletLeft:
        ld      hl,aBounceLeft
        jr      anazarBulletHitWall
anazarBulletRight:
        ld      hl,aBounceRight
        jr      anazarBulletHitWall
anazarBulletTop:
        ld      hl,aBounceTop
        jr      anazarBulletHitWall
anazarBulletBottom:
        ld      hl,aBounceBottom
anazarBulletHitWall:
        ld      de,0
        ld      e,(ix+D_DIR)
        dec     e
        add     hl,de
        ld      a,(hl)
        inc     a
        ld      (ix+D_DIR),a
        dec     (ix+D_SPECIAL)
        jp      endMoveAnazarBullets

;------------------------------------------------
; Graphics
;------------------------------------------------
drawAnazar:
        ld      a,(frame)
        ld      hl,sprBoss1
        bit     5,a
        jp      z,drawAnazar2
        ld      hl,sprBoss2
        bit     6,a
        jp      z,drawBoss
        ld      hl,sprBoss4
        jp      drawBoss
drawAnazar2:
        bit     6,a
        jp      z,drawBoss
        ld      hl,sprBoss3
        jp      drawBoss

;------------------------------------------------
; Finished
;------------------------------------------------
finishedAnazar:
        ld      a,145
        ld      bc,72*256+8
        ld      de,ANAZAR_GOLD
        ld      ix,anazarChangeList
        ret

.end
