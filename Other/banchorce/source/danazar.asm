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
        ld      hl,INI_ANAZAR_HEALTH
        ld      (dHealth),hl
        ld      hl,INI_ANAZAR_YX
        ld      (dy),hl
        ld      a,ANAZAR_DAMAGE
        ld      bc,doAnazar
        ld      de,drawAnazar
        ld      hl,finishedAnazar
        ld      ix,sprAnazarBullet
        ret

;------------------------------------------------
; Implementation
;------------------------------------------------
doAnazar:
        ld      a,(frame)
        and     %00000011
        jr      nz,anazarShoot                  ; Only move bullets every 4th frame
        ld      b,MAX_DEMON_OBJECTS
        ld      ix,demonTable
moveAnazarBullets:
        push    bc
        ld      a,(ix+D_DIR)
        or      a
        jr      z,endMoveAnazarBullets
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
        ld      hl,(dCnt)
        ld      h,2
        mlt     hl
        ld      de,anazarOffsets
        add     hl,de
        ld      a,(dFlags)
        ld      b,a
        ld      de,(dy)
        ld      a,(hl)
        bit     1,b
        jr      z,$+4
        neg
        add     a,d
        ld      d,a
        inc     hl
        ld      a,(hl)
        bit     0,b
        jr      z,$+4
        neg
        add     a,e
        ld      e,a
        ld      (dy),de
        ld      hl,dCnt
        inc     (hl)
        ld      a,(hl)
        cp      ANAZAR_MAX
        ret     nz
        ld      (hl),0
        ld      hl,dFlags
        inc     (hl)
        ld      a,(hl)
        cp      4
        ret     c
        ld      (hl),0
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
        ld      hl,sprAnazar1
        bit     5,a
        jp      z,drawDemon
        ld      hl,sprAnazar2
        jp      drawDemon

;------------------------------------------------
; Finished
;------------------------------------------------
finishedAnazar:
        ld      bc,48*256+24
        ld      de,ANAZAR_GOLD
        ld      ix,anazarChangeList
        ld      a,211
        ret

.end
