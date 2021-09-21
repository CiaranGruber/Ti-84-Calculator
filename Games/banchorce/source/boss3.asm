;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Wendeg Demon Routines                                         ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; Initialisation
;------------------------------------------------
iniWendeg:
        ld      hl,INI_WENDEG_HEALTH
        ld      (dHealth),hl
        ld      hl,INI_WENDEG_YX
        ld      (dy),hl
        ld      a,WENDEG_DAMAGE
        ld      b,WENDEG_BULLET_DAMAGE
        ld      ix,doWendeg
        ld      de,drawWendeg
        ld      hl,finishedWendeg
        ret

;------------------------------------------------
; Implementation
;------------------------------------------------
doWendeg:
; Firstly, move stars
        ld      a,(frame)
        bit     0,a
        jr      nz,afterMoveStars
        ld      ix,demonTable
        ld      b,MAX_DEMON_OBJECTS
moveWendegStarsLoop:
        push    bc
        ld      a,(ix+D_DIR)
        or      a
        jr      z,endMoveWendegStarsLoop
        ld      hl,wendegStarPattern1
        ld      de,WENDEG_STAR_STEPS*2
        ld      a,(ix+D_DIR)
        dec     a
        jr      z,afterFindStarPattern
        ld      b,a
        add     hl,de
        djnz    $-1
afterFindStarPattern:
        ld      a,(ix+D_SPECIAL)
        cp      WENDEG_STAR_STEPS
        jr      nc,endOfStarPattern
moveStarsNow:
        add     a,a
        ld de,0 \ ld e,a
        add     hl,de
        ld      a,(hl)
        add     a,(ix+D_X)
        ld      (ix+D_X),a
        inc     hl
        ld      a,(hl)
        add     a,(ix+D_Y)
        cp      ROWS*8
        jr      nc,starOffScreen
        ld      (ix+D_Y),a
        inc     (ix+D_SPECIAL)
        jr      endMoveWendegStarsLoop
endOfStarPattern:
        ld      a,WENDEG_STAR_STEPS-1
        jr      moveStarsNow
starOffScreen:
        ld      (ix+D_DIR),0
endMoveWendegStarsLoop:
        pop     bc
        ld      de,DEMON_ENTRY_SIZE
        add     ix,de
        djnz    moveWendegStarsLoop
afterMoveStars:
; Next, move Wendeg
        ld      hl,frame
        bit     0,(hl)
        ret     z
        ld      a,(dCnt)
        bit     7,a
        jr      nz,updateWendegThrow
        or      a
        call    z,iniWendegThrow
        ld      a,(dFlags)
        ld      hl,dCnt
        dec     (hl)
        bit     0,a
        ld      hl,dX
        ld      a,(hl)
        jr      z,moveWendegRight
moveWendegLeft:
        cp      8
        jr      z,changeWendegDirection
        dec     (hl)
        ret
moveWendegRight:
        cp      (COLS*8)-16-8
        jr      z,changeWendegDirection
        inc     (hl)
        ret
changeWendegDirection:
        ld      a,(dFlags)
        xor     $01
        ld      (dFlags),a
        ret
updateWendegThrow:
        inc     a
        ld      (dCnt),a
        call    z,getWendegDirection
        ret
iniWendegThrow:
        ld      a,-8
        ld      (dCnt),a
        ld      a,(dY)
        ld      l,a
        ld      a,(dX)
        add     a,4
        ld      h,a
        ld      b,3
newWendegStarLoop:
        push    hl
        push    bc
        call    getEmptyDemonEntry
        pop     bc
        push    hl
        pop     ix
        pop     hl
        ld      (ix+D_DIR),b
        ld      (ix+D_X),h
        ld      (ix+D_Y),l
        ld      (ix+D_SPECIAL),0
        djnz    newWendegStarLoop
        ret
getWendegDirection:
        ld      b,2
        call    random                          ; 0 <= A <=1
        ld      (dFlags),a
        ld      b,16
        call    random
        add     a,24                            ; 24 <= A <= 41
        ld      (dCnt),a
        ret

;------------------------------------------------
; Graphics
;------------------------------------------------
drawWendeg:
        ld      a,(dCnt)
        bit     7,a
        ld      hl,sprBoss3
        jp      nz,drawBoss
        or a \ sbc hl,hl \ ld l,a
        ld      a,4
        call    _divhlbya_s
        ld      a,l
        ld      hl,sprBoss1
        bit     0,a
        jp      z,drawBoss
        ld      hl,sprBoss2
        jp      drawBoss

;------------------------------------------------
; Finished
;------------------------------------------------
finishedWendeg:
        ld      a,79
        ld      bc,96*256+8
        ld      de,WENDEG_GOLD
        ld      ix,wendegChangeList
        ret

.end
