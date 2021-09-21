;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Graphics routines                                             ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; loadPalette - load the palette
;   input:  none
;   output: none
;------------------------------------------------
loadPalette:
        ld      hl,gamePalette
        ld      bc,GAME_PALETTE_SIZE
        ld      de,mpLcdPalette
        ldir
        ret

;------------------------------------------------
; loadStdGfx - load standard tileset & sprites
;   input:  none
;   output: CA = 1 if file missing
;------------------------------------------------
loadStdGfx:
        call    getGfxFile                      ; DE => start of file data
        ret     c                               ; if missing, ret
        ld      hl,gfxmem                       ; HL => where to decompress to
        ex      de,hl
        ld      ix,huffTree
        ld      b,GFX_FILE_MAINGFX
        call    huffExtr
        or      a                               ; clear carry
        ret

;------------------------------------------------
; vram8bpp - set up LCD for 8bpp
;   input:  none
;   output: none
;------------------------------------------------
vram8bpp:
        ld      a,$27
        ld      (mpLcdCtrl),a                   ; set 8bpp
        ret
        
;------------------------------------------------
; vram16bpp - return LCD to default 16bpp
;   input:  none
;   output: none
;------------------------------------------------
vram16bpp:
        ld      a,$2D
        ld      (mpLcdCtrl),a                   ; set 16bpp  5:6:5
        ret

;------------------------------------------------
; vramClear - clear entire vram
;   input:  none
;   output: none
;------------------------------------------------
vramClear:
        ld      hl,vram
        ld      de,vram+1
        ld      bc,320*240*2-1
        ld      (hl),COLOUR_BLACK
        ldir
        ret

;------------------------------------------------
; vbufClear - clear (pVbuf)
;   input:  none
;   output: none
;------------------------------------------------
vbufClear:
        ld      hl,(pVbuf)
        push    hl
        pop     de
        inc     de
        ld      bc,320*240-1
        ld      (hl),COLOUR_BLACK
        ldir
        ret

;------------------------------------------------
; vramFlip - flip vram between vbuf1/vbuf2
;   input:  none
;   output: none
;------------------------------------------------
vramFlip:
        ld      de,vbuf1
        ld      hl,(mpLcdBase)
        or      a
        sbc     hl,de
        add     hl,de
        jr      nz,vfSetBuffer
        ld      de,vbuf2
vfSetBuffer:
        ld      (pVbuf),hl
        ld      bc,VBUF_WIN_OFFSET
        add     hl,bc
        ld      (pVbufWin),hl
        ld      (mpLcdBase),de
        ld	    hl,mpLcdIcr
        set	    2,(hl)
        ld	    l,mpLcdRis&$FF
vfWait:
        bit     2,(hl)
        jr      z,vfWait
        ret

;------------------------------------------------
; vramCopy - copy vram to (pVbuf)
;   input:  none
;   output: none
;------------------------------------------------
vramCopy:
        ld      hl,(pVram)
        ld      de,(pVbuf)
        ld      bc,320*240
        ldir
        ret

;------------------------------------------------
; drawWindow - draw a window using fillRect to black out and drawRect to draw the border
;   input:  A = colour
;           E = x pos / 2
;           D = y pos
;           B = width / 2
;           C = height
;   output: none
;------------------------------------------------
drawWindow:
        push    af
        push    bc
        push    de
        ld      a,COLOUR_BLACK
        call    fillRect
        pop     de
        inc d \ inc d
        inc     e
        pop     bc
        dec b \ dec b \ dec b
        dec c \ dec c \ dec c \ dec c
        pop     af
        ; fall through to drawRect

;------------------------------------------------
; drawRect - draw a 2 pixel thick rectangle outline to vbuf
;   input:  A = colour
;           E = x pos / 2
;           D = y pos
;           B = width / 2
;           C = height
;   output: none
;------------------------------------------------
drawRect:
        ; top line
        push    af
        push    bc
        push    de
        call    drawHLine
        pop     de
        pop     bc
        pop     af
        ; bottom line
        push    af
        push    bc
        push    de
        ld      h,a
        ld      a,d
        add     a,c
        sub     2
        ld      d,a
        ld      a,h
        call    drawHLine
        pop     de
        pop     bc
        pop     af
        ; left line
        push    af
        push    bc
        push    de
        call    drawVLine
        pop     de
        pop     bc
        pop     af
        ; right line
        ld      h,a
        ld      a,e
        add     a,b
        ld      e,a
        ld      a,h
        ; fall through to drawVLine

;------------------------------------------------
; drawVLine - draw a 2 pixel thick vertical line to vbuf
;   input:  A = colour
;           E = x pos / 2
;           D = y pos
;           C = height
;   output: none
;------------------------------------------------
drawVLine:
        push    af
        call    getDrawPtr
        pop     af
        ld      de,319
        ld      b,c
dvlLoop:
        ld      (hl),a
        inc     hl
        ld      (hl),a
        add     hl,de
        djnz    dvlLoop
        ret

;------------------------------------------------
; drawHLine - draw a 2 pixel thick horizontal line to vbuf
;   input:  A = colour
;           E = x pos / 2
;           D = y pos
;           B = width / 2
;   output: none
;------------------------------------------------
drawHLine:
        push    af
        push    bc
        call    getDrawPtr
        push    hl
        pop     de                              ; DE = vbuf ptr for 1st line
        ld      bc,320
        add     hl,bc                           ; HL = vbuf ptr for 2nd line
        pop     bc
        pop     af
dhlLoop:
        ld (hl),a \ inc hl
        ld (hl),a \ inc hl
        ld (de),a \ inc de
        ld (de),a \ inc de
        djnz    dhlLoop
        ret

;------------------------------------------------
; fillRect - fill a rectangular section of vbuf
;   input:  A = colour
;           E = x pos / 2
;           D = y pos
;           B = width / 2
;           C = height
;   output: none
;------------------------------------------------
fillRect:
        push    af
        call    getDrawPtr
        pop     af
        ld      de,320
frRows:
        push    bc
        push    hl
frCols:
        ld      (hl),a
        inc     hl
        ld      (hl),a
        inc     hl
        djnz    frCols
        pop     hl
        add     hl,de
        pop     bc
        dec     c
        jr      nz,frRows
        ret

;------------------------------------------------
; getDrawPtr - get a vbuf pointer to start drawing lines, etc.
;   input:  E = x pos / 2
;           D = y pos
;   output: HL => location on vbuf
;------------------------------------------------
getDrawPtr:
        ld      h,160
        ld      l,d
        mlt     hl
        add     hl,hl
        ld      d,2
        mlt     de
        add     hl,de
        ld      de,(pVbuf)
        add     hl,de
        ret

;------------------------------------------------
; drawTile - draw an 8x8 8bpp sprite to vbuf scaled up x2 (no clipping, no transparency)
;   input:  HL => sprite
;           E = x pos / 2
;           D = y pos / 2
;   output: none
;------------------------------------------------
drawTile:
        push    iy
        push    hl
        ld      h,160
__dtY                   = $+1
        ld      a,WIN_Y/2
        add     a,d
        ld      l,a
        mlt     hl
        add     hl,hl
        add     hl,hl
__dtX                   = $+1
        ld      a,WIN_X/2
        add     a,e
        ld      e,a
        ld      d,2
        mlt     de
        add     hl,de
        ld      de,(pVbuf)
        add     hl,de
        push    hl
        pop     ix                              ; IX => vbuf pointer
        ld      de,320
        add     hl,de
        push    hl
        pop     iy
        pop     hl                              ; HL => sprite
        ld      de,640
        ld      b,8
dtRow:
        ld a,(hl) \ ld (ix+0),a \ ld (iy+0),a \ ld (ix+1),a \ ld (iy+1),a \ inc hl
        ld a,(hl) \ ld (ix+2),a \ ld (iy+2),a \ ld (ix+3),a \ ld (iy+3),a \ inc hl
        ld a,(hl) \ ld (ix+4),a \ ld (iy+4),a \ ld (ix+5),a \ ld (iy+5),a \ inc hl
        ld a,(hl) \ ld (ix+6),a \ ld (iy+6),a \ ld (ix+7),a \ ld (iy+7),a \ inc hl
        ld a,(hl) \ ld (ix+8),a \ ld (iy+8),a \ ld (ix+9),a \ ld (iy+9),a \ inc hl
        ld a,(hl) \ ld (ix+10),a \ ld (iy+10),a \ ld (ix+11),a \ ld (iy+11),a \ inc hl
        ld a,(hl) \ ld (ix+12),a \ ld (iy+12),a \ ld (ix+13),a \ ld (iy+13),a \ inc hl
        ld a,(hl) \ ld (ix+14),a \ ld (iy+14),a \ ld (ix+15),a \ ld (iy+15),a \ inc hl
        add     ix,de
        add     iy,de
        djnz    dtRow
        pop     iy
        ret

;------------------------------------------------
; drawSprite - draw an 8x8 8bpp sprite to vbuf game window scaled up x2 (with clipping & transparency)
;   input:  HL => sprite
;           E = x pos / 2
;           D = y pos / 2
;   output: none
;------------------------------------------------
drawSprite:
        ; y clipping
        ld      a,d
        bit     7,a
        jr      z,dsCheckBottom                 ; if y pos is between 0-127 then check bottom edge
        cp      -7
        ret     c                               ; if y pos < -7, sprite is off the top of the screen
        neg
        ld      c,a
        ld      b,SPRITE_WIDTH                  ; bytes of sprite data to skip per row clipped
        mlt     bc
        add     hl,bc                           ; updated sprite pointer
        ld      a,d
        add     a,8
        ld      d,0                             ; updated y pos to draw at
        jr      dsSetRows
dsCheckBottom:
        cp      (ROWS*8)-7
        ld      a,8
        jr      c,dsSetRows
        ld      a,d
        sub     ROWS*8
        ret     nc
        neg
dsSetRows:
        ld      (__dsRows),a
        ; x clipping
        ld      a,e
        cp      COLS*8
        jr      c,dsCheckRight
        cp      -7
        ret     c
        neg
        ld      bc,0
        ld      c,a
        add     hl,bc
        ld      a,e
        add     a,8
        ld      e,0
        jr      dsSetCols
dsCheckRight:
        cp      (COLS*8)-7
        ld      a,8
        jr      c,dsSetCols
        ld      a,e
        sub     COLS*8
        ret     nc
        neg
dsSetCols:
        ld      (__dsCols),a
        sub     8
        neg
        ld      (__dsNext),a
        ; prepare to draw
        ex      de,hl                           ; DE => sprite, H = y pos / 2, L = x pos / 2
        sla     h                               ; H = y pos
        sla     l                               ; L = x pos
        ld bc,0 \ ld c,l
        ld      l,160
        mlt     hl
        add     hl,hl
        add     hl,bc
        ld      bc,(pVbufWin)
        add     hl,bc                           ; HL => location on vbuf
        push    iy
        push    hl
        ex      de,hl                           ; HL => sprite
        pop     iy                              ; IY => vbuf
        push    ix
__dsRows                = $+2
        ld      ixh,8
dsRow:
__dsCols                = $+1
        ld      a,8
        push    hl
        lea     de,iy
        ld      hl,320
        add     hl,de
        ex      de,hl
        lea     bc,iy
        pop     hl
dsCol:
        ld      (__dsDec),a
        ld      a,(hl)
        or      a
        jr      z,dsSkip
        ld      (bc),a
        ld      (de),a
        inc     bc
        inc     de
        ld      (bc),a
        ld      (de),a
        dec     bc
        dec     de
dsSkip:
        inc     bc
        inc     bc
        inc     de
        inc     de
        inc     hl
__dsDec                 = $+1
        ld      a,8
        dec     a
        jr      nz,dsCol
        ld      bc,0                            ; ensure that BCU is 0
__dsNext                = $+1
        ld      c,8
        add     hl,bc
        ld      de,640
        add     iy,de
        dec     ixh
        jr      nz,dsRow
        pop     ix
        pop     iy
        ret

.end
