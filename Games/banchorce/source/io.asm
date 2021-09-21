;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Input/Output Routines                                         ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; keyScan - perform a keyscan
;   input:  none
;   output: none
;------------------------------------------------
keyScan:
        di
        ld      hl,DI_Mode
        ld      (hl),$02
        xor     a
ksWait:
        cp      (hl)
        jr      nz,ksWait
        ret

_ld_hl_bz:
        ld      (hl),0
        inc     hl
        djnz    _ld_hl_bz
        ret

;------------------------------------------------
; waitKey - Wait for a key press
;   input:  none
;   output: A = Key code (_getcsc style)
;------------------------------------------------
waitKey:
        ei
waitKeyLoop:
        halt
        call    _getcsc
        or      a
        jr      z,waitKeyLoop
        ret

;------------------------------------------------
; waitKeyA - Wait for a key press excluding arrow keys
;   input:  none
;   output: A = Key code (_getcsc style)
;------------------------------------------------
waitKeyA:
        call    waitKey
        cp      5
        jr      c,waitKeyA
        ret

;------------------------------------------------
; waitEnter - wait until Enter is pressed
;   input:  none
;   output: none
;------------------------------------------------
waitEnter:
        call    waitKey
        cp      GK_ENTER
        jr      nz,waitEnter
        ret

;------------------------------------------------
; drawStringColour - draw a string in a specified colour to vBuf
;   input:  HL => string
;           DE = x pos
;           C = y pos
;           A = colour
;   output: HL => data after string
;------------------------------------------------
drawStringColour:
        ld      (__dcColour),a
        ; fall through to drawString

;------------------------------------------------
; drawString - draw a string to vBuf
;   input:  HL => string
;           DE = x pos
;           C = y pos
;   output: HL => data after string
;           DE = x pos (preserved)
;           C = y pos (preserved)
;------------------------------------------------
drawString:
        push    de
dsContinue:
        ld      a,(hl)
        inc     hl
        or      a                                           ; null terminator?
        jr      z,dsDone
        cp      1                                           ; $01 = colour change
        jr      z,dsColour
        push    hl
        push    de
        push    bc
        call    drawChar
        pop     bc
        pop     de
        ld      hl,8
        add     hl,de
        ex      de,hl
        pop     hl
        jr      dsContinue
dsDone:
        pop     de
        ld      a,COLOUR_WHITE
        ld      (__dcColour),a
        ret
dsColour:
        ld      a,(hl)
        ld      (__dcColour),a
        inc     hl
        jr      dsContinue
        
;------------------------------------------------
; drawChar - draw a font character to vBuf
;   input:  A = ascii character
;           DE = x pos
;           C = y pos
;   output: none
;------------------------------------------------
drawChar:
        push    de
        push    bc
        sub     $20
        ld bc,0 \ ld c,a
        ld      hl,fontTable
        add     hl,bc
        ld      c,(hl)
        ld      b,49
        mlt     bc
        ld      ix,font
        add     ix,bc
        pop     hl
        ld      h,160
        mlt     hl
        add     hl,hl
        ld      de,(pVbuf)
        add     hl,de
        pop     de
        add     hl,de                           ; HL => vbuf location
        ld      c,7
dcRow:
        push    hl
        ld      b,7
dcCol:
        ld      a,(ix)
        or      a
        jr      z,dcSkip
__dcColour              = $+1
        ld      a,COLOUR_WHITE
dcWrite:
        ld      (hl),a
dcSkip:
        inc ix \ inc hl
        djnz    dcCol
        pop     hl
        ld      de,320
        add     hl,de
        dec     c
        jr      nz,dcRow
        ret

;------------------------------------------------
; calcStringWidth - calculate the string width in pixels
;   input:  HL => string
;   output: HL => string
;           BC = string width
;------------------------------------------------
calcStringWidth:
        push    hl
        ld      bc,0
cswLoop:
        ; count the number of characters in the string
        ld      a,(hl)
        or      a
        jr      z,cswDone
        inc     c
        inc     hl
        jr      cswLoop
cswDone:
        push    bc
        pop     hl
        HLTIMES8()
        push    hl
        pop     bc
        pop     hl
        ret

;------------------------------------------------
; fadeIn - fade the screen in
;   input:  none
;   output: none
;------------------------------------------------
fadeIn:
        ld      hl,fadeInSub
        jp      fadeLcd
fadeInSub:
        dec     c
        ret

;------------------------------------------------
; fadeOut - fade the screen out by slowing erasing the palette
;   input:  none
;   output: none
;------------------------------------------------
fadeOut:
        ld      hl,fadeOutSub
        jp      fadeLcd
fadeOutSub:
        ld      a,c
        sub     32
        neg
        ld      c,a
        ret

;------------------------------------------------
; fadeLcd - fade the screen out or in
;   input:  HL => routine to calculate RGB modifier
;   output: none
;------------------------------------------------
fadeLcd:
        ld      (__flSubCalc),hl
        push    iy
        ld      c,32
flOuter:
        ld      b,GAME_PALETTE_SIZE/2
        ld      iy,mpLcdPalette
        ld      ix,gamePalette
flInner:
        push    bc
__flSubCalc             = $+1
        call    $000000
        ld      hl,0
        ; red
        ld      a,(ix+1)
        rrca \ rrca
        and     %00011111
        sub     c
        jr      nc,flSkipR
        xor     a
flSkipR:
        rlca \ rlca
        ld      l,a
        ; green
        ld      e,(ix+1)
        ld      d,(ix)
        sla d \ rl e
        sla d \ rl e
        sla d \ rl e
        ld      a,e
        and     %00011111
        sub     c
        jr      nc,flSkipG
        xor     a
flSkipG:
        ld      d,0
        ld      e,a
        srl e \ rr d
        srl e \ rr d
        srl e \ rr d
        ld      a,l
        or      e
        ld      l,a
        ld      a,h
        or      d
        ld      h,a
        ; blue
        ld      a,(ix)
        and     %00011111
        sub     c
        jr      nc,flSkipB
        xor     a
flSkipB:
        or      h
        ld      h,a
        ld      (iy),h
        ld      (iy+1),l
        inc ix \ inc ix
        inc iy \ inc iy
        pop     bc
        djnz    flInner
        push    bc
        ld      bc,FADE_DELAY
        call    waitBC
        pop     bc
        dec     c
        jr      nz,flOuter
        pop     iy
        ret

;------------------------------------------------
; drawHL - Set coords and show HL
;   input:  HL = Number to show
;           DE = x pos
;           C = y pos
;           B = Number of characters to show
;   output: none
;------------------------------------------------
drawHL:
        push    de
        push    bc
        ld      de,string+5
        xor     a
        ld      (de),a
convertHLToAscii:
        dec     de
        ;call    _divhlby10_s
        ld      a,10
        call    _divHLbyA
        add     a,'0'
        ld      (de),a
        djnz    convertHLToAscii
        ex      de,hl
        pop     bc
        pop     de
        jp      drawString

;------------------------------------------------
; waitBC - Wait a bit
;   input:  BC = How many times to loop
;   output: none
;------------------------------------------------
waitBC:
        push bc \ pop bc
        dec     bc
        call    _setAToBCU
        or      b
        or      c
        jr      nz,waitBC
        ret

.end
