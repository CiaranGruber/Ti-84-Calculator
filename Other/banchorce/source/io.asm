;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Input/Output Routines                                         ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; waitKey - Wait for a key press
;
; Input:    None
; Output:   A = Key code (_getcsc style)
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
;
; Input:    None
; Output:   A = Key code (_getcsc style)
;------------------------------------------------
waitKeyA:
        call    waitKey
        cp      5
        jr      c,waitKeyA
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
        ld      b,4
        ld      iy,mpLcdPalette
        ld      ix,palGray
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
        ld      bc,4000
        call    waitBC
        pop     bc
        ;ei
        ;halt \ halt \ halt \ halt
        dec     c
        jr      nz,flOuter
        pop     iy
        ret

;------------------------------------------------
; setShowHL - Set coords and show HL in _vputs font
;
; Input:    HL = Number to show
;           DE = Coords to load to (_pencol)
;           B = Number of characters to show
; Output:   None
;------------------------------------------------
showHL:
        push    de
        ld      de,string+5
        xor     a
        ld      (de),a
convertHLToAscii:
        dec     de
        call    _divhlby10_s
        add     a,'0'
        ld      (de),a
        djnz    convertHLToAscii
        ex      de,hl
        pop     de
        jp      putString

;------------------------------------------------
; waitBC - Wait a bit
;
; Input:    BC = How many times to loop
; Output:   None
;------------------------------------------------
waitBC:
        push bc \ pop bc
        dec     bc
        call    _setAToBCU
        or      b
        or      c
        jr      nz,waitBC
        ret

;------------------------------------------------
; fillSide - Fill a side of the screen
;
; Input:    HL => Start of video memory to fill
; Output:   None
;------------------------------------------------
fillSide:
        ld      b,128
        ld      de,15
fillSideLoop:
        ld      (hl),$FF
        inc     hl
        ld      (hl),$FF
        add     hl,de
        djnz    fillSideLoop
        ret

.end
