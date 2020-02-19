;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Animation Routines                                            ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; clearAnimTable - Clear animTable
;
; Input:    None
; Output:   None
;------------------------------------------------
clearAnimTable:
        ld      hl,animTable
        ld      b,ANIM_ENTRY_SIZE*MAX_ANIMS
        jp      _ld_hl_bz

;------------------------------------------------
; drawAnims - Draw animations
;
; Input:    None
; Output:   None
;------------------------------------------------
drawAnims:
        ld      ix,animTable
        ld      b,MAX_ANIMS
drawAnimsLoop:
        push    bc
        push    ix
        ld      a,(ix+A_CNT)
        or      a
        jr      z,endDrawAnimsLoop
        dec     a
        ld      e,a
        ld      d,24
        mlt     de
        ld      hl,sprExplosion
        add     hl,de
        ld      b,(ix+A_X)
        ld      c,(ix+A_Y)
        call    graySpriteClip
endDrawAnimsLoop:
        pop     ix
        pop     bc
        ld      de,ANIM_ENTRY_SIZE
        add     ix,de
        djnz    drawAnimsLoop
        ret

;------------------------------------------------
; newAnim - Create a new explosion animation
;
; Input:    B = X Coord
;           C = Y Coord
; Output:   None
;------------------------------------------------
newAnim:
        push    bc
        ld      b,MAX_ANIMS
        ld      hl,animTable
        ld      de,ANIM_ENTRY_SIZE
findEmptyAnimEntry:
        ld      a,(hl)
        or      a
        jr      z,foundEmptyAnimEntry
        add     hl,de
        djnz    findEmptyAnimEntry
        pop     bc
        ret
foundEmptyAnimEntry:
        ld      (hl),1
        inc     hl
        pop     bc
        ld      (hl),b
        inc     hl
        ld      (hl),c
        ret

;------------------------------------------------
; updateAnims - Update explosion animations
;
; Input:    None
; Output:   None
;------------------------------------------------
updateAnims:
        ld      a,(frame)
        bit     0,a
        ret     nz
        ld      hl,animTable
        ld      de,ANIM_ENTRY_SIZE
        ld      b,MAX_ANIMS
updateAnimsLoop:
        ld      a,(hl)
        or      a
        jr      z,endUpdateAnimsLoop
        inc     (hl)
        ld      a,(hl)
        cp      ANIM_MAX+1
        jr      nz,endUpdateAnimsLoop
        ld      (hl),0
endUpdateAnimsLoop:
        add     hl,de
        djnz    updateAnimsLoop
        ret

.end
