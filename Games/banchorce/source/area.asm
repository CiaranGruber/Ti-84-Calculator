;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Area Name Routines                                            ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; drawAreaName - draw the area name
;   input:  A = __drawAreaName value (will always be NZ)
;   output: none
;------------------------------------------------
drawAreaName:
        ld      b,a
        ld      a,(areaNum)
        or      a
        jr      z,noAreaName
        ld      a,b
        call    clearHud

noAreaClear:
        ; update __drawAreaName
        dec     a
        ld      (__drawAreaName),a
        jr      nz,noHudRedraw
        REDRAW_HUD()                            ; redraw HUD after showing the area name

noHudRedraw:
        ld      hl,(areaNum)
        dec     l
        ld      h,3
        mlt     hl
        ld      de,areaNames
        add     hl,de
        ld      de,(hl)
        ex      de,hl
        call    calcStringWidth
        push    hl                              ; save string pointer
        ld      hl,9*8
        add     hl,bc
        ex      de,hl
        ld      hl,320
        or      a
        sbc     hl,de
        srl     h
        rr      l                               ; HL = x position to use for centred area name (including the "ENTERING ")
        ex      de,hl
        push    de
        ld      c,240-11
        ld      hl,strEntering
        ld      a,COLOUR_REDORANGE
        call    drawStringColour
        pop     de
        ld      hl,9*8
        add     hl,de
        ex      de,hl
        pop     hl
        ld      c,240-11
        ld      a,COLOUR_REDORANGE
        jp      drawStringColour

noAreaName:
        ld      (__drawAreaName),a              ; A is always 0 here
        REDRAW_HUD()
        ret

.end
