;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Animation Routines                                            ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; clearAnimTable - Clear animTable
;   input:  none
;   output: none
;------------------------------------------------
clearAnimTable:
        ld      hl,animTable
        ld      b,ANIM_ENTRY_SIZE*MAX_ANIMS
        jp      _ld_hl_bz

;------------------------------------------------
; drawAnims - Draw animations
;   input:  none
;   output: none
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
        ld      d,64
        mlt     de
        ld      hl,sprExplosion
        add     hl,de
        ld      e,(ix+A_X)
        ld      d,(ix+A_Y)
        call    drawSprite
endDrawAnimsLoop:
        pop     ix
        pop     bc
        ld      de,ANIM_ENTRY_SIZE
        add     ix,de
        djnz    drawAnimsLoop
        ret

;------------------------------------------------
; newAnim - Create a new explosion animation
;   input:  B = X Coord
;           C = Y Coord
;   output: none
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
;   input:  none
;   output: none
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
        jr      c,endUpdateAnimsLoop
        ld      (hl),0
endUpdateAnimsLoop:
        add     hl,de
        djnz    updateAnimsLoop
        ret

.end
