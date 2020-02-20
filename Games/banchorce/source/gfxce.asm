;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Graphics routines                                             ;
;                                                               ;
;---------------------------------------------------------------;

grayWin                 = vram+(56*320)+32

;------------------------------------------------
; loadPalette - load the palette
;   input:  none
;   output: none
;------------------------------------------------
loadPalette:
        ld      hl,palGray
        ld      bc,PAL_GRAY_SIZE
        ld      de,mpLcdPalette
        ldir
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
; clearVram - clear vram
;   input:  none
;   output: none
;------------------------------------------------
clearVram:
        ld      hl,vram
        ld      (hl),4
        ld      de,vram+1
        ld      bc,320*240
        ldir
        ret

;------------------------------------------------
; ShowGray - emulate TI-86 grayscale to 84+CE lcd
;   input:  none
;   output: none
;------------------------------------------------
ShowGray:
        di
        push    iy
        ld      ix,GrayMem1
        ld      iy,GrayMem2
        ld      hl,grayWin
        ld      c,64
sgRow:
        ld      b,16
sgCol:
        push    bc
        ld      bc,8*256+128                    ; B = 8, C = %10000000
sgByte:
        ld      d,0
        ld      a,(ix)
        and     c
        jr      z,sgSkip1
        ld      d,%00000010
sgSkip1:
        ld      a,(iy)
        and     c
        jr      z,sgSkip2
        inc     d
sgSkip2:
        ld      (hl),d
        inc     hl
        ld      (hl),d
        inc     hl
        srl     c
        djnz    sgByte
        inc     ix
        inc     iy
        pop     bc
        djnz    sgCol
        ld      de,64+320
        add     hl,de
        dec     c
        jr      nz,sgRow
        pop     iy
; interlace vertically
        ld      b,64
        ld      hl,grayWin
        ld      de,grayWin+320
sgInterlace:
        push    bc
        ld      bc,256
        ldir
        push    de
        ld      de,64+320
        add     hl,de
        ex      (sp),hl
        add     hl,de
        pop     de
        ex      de,hl
        pop     bc
        djnz    sgInterlace
        ret

;------------------------------------------------
; putString - write a string to buffer1 (or alter __psLoc to another buffer)
;   input:  HL => string
;           D = penrow
;           E = pencol
;   output: HL => next string
;           D = penrow (unchanged)
;           E = pencol (for next string)
;------------------------------------------------
putString:
        ld      a,(hl)
        inc     hl
        or      a
        ret     z
        push    hl
        ld      l,a
        ld      h,7
        mlt     hl
        ld      bc,font83ce
        add     hl,bc                           ; HL => character data
        ld      a,(hl)                          ; A = character width
        inc     hl                              ; HL => character sprite
        ld      c,e                             ; C = pencol for this character
        add     a,e
        ld      e,a                             ; E = updated pencol for next character
        push    de
        push    hl
        ld      l,d
        ld      h,16
        mlt     hl
        ld      a,c
        srl a \ srl a \ srl a                   ; A = pencol/8
        ld      de,0
        ld      e,a
        add     hl,de
__psLoc                 = $+1
        ld      de,buffer1
        add     hl,de                           ; HL => byte on buffer1 to start at
        ex      (sp),hl                         ; HL => character sprite
        pop     ix                              ; IX => buffer1 pointer
        ld      a,c
        and     %00000111
        ld      b,6                             ; B = 6 rows to put
psRow:
        ld      d,(hl)                          ; D = unshifted character row
        ld      e,0
        push    af
        or      a
        jr      z,psAfterShift
psShift:
        srl     d
        rr      e
        dec     a
        jr      nz,psShift
psAfterShift:
        ld      a,d
        or      (ix)
        ld      (ix),a
        ld      a,e
        or      (ix+1)
        ld      (ix+1),a
        inc     hl                              ; HL => next byte of char sprite
        ld      de,16
        add     ix,de                           ; IX => next row on buffer1
        pop     af
        djnz    psRow

        pop     de
        pop     hl
        jr      putString

.end
