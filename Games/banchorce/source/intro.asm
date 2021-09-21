;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Introdcution routines                                         ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; doIntro - show the intro text
;   input:  none
;   output: none
;------------------------------------------------
doIntro:
        ; fade to black and clear both vbuf1 & vbuf2
        call    fadeOut
        call    vramClear
        ; we need vbuf1 to be the active screen and drawString to write to vbuf2 for the scrolling effect
        ld      hl,vbuf1
        ld      (mpLcdBase),hl
        ld      hl,vbuf2
        ld      (pVbuf),hl
        ; reload the palette after the fadeOut
        call    loadPalette
        ; initialise for looping
        ld      b,1
        ld      hl,strIntro

introOuterLoop:
        push    hl

introInnerLoop:
        call    introScroll
        jr      c,introDone
        djnz    introInnerLoop

        pop     hl
        ld      a,(hl)
        inc     a                               ; A = $FF?
        jr      z,introScrollOut
        ld      de,0
        ld      c,0
        call    drawString
        ld      b,10
        jr      introOuterLoop
introDone:
        pop     hl
        ret

introScrollOut:
        ld      b,240
introScrollOutLoop:
        call    introScroll
        ret     c
        djnz    introScrollOutLoop
        ret

introScroll:
        push    bc
        ld      hl,vbuf1+320
        ld      de,vbuf1
        ld      bc,320*250
        ldir
        call    keyScan
        ld      a,(kbdG1)
        ld      hl,kbdG2
        or      (hl)
        jr      nz,introFast
        ld      a,(kbdG6)
        bit     kbitClear,a
        jr      nz,introSkip
        ld      bc,16000
        call    waitBC
introFast:
        pop     bc
        or      a
        ret
introSkip:
        pop     bc
        scf
        ret

.end
