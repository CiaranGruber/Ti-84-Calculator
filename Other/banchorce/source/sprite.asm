;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Grayscale Sprite Routines                                     ;
;                                                               ;
;---------------------------------------------------------------;

GrayDraw1       = GrayMem1                      ; [1024] dark grayscale plane
GrayDraw2       = GrayMem2                      ; [1024] light grayscale plane

;------------------------------------------------
; GraySpriteClip - Put masked grayscale sprite, with clipping
;
; Author:   David Phillips <david@acz.org>
; Input:    HL => 8x8 masked grayscale sprite
;           B = XCoord
;           C = YCoord
; Output:   None
;------------------------------------------------
GraySpriteClip:
        ex      de,hl                           ; save pointer in de
        ld      hl,GraySpriteE                  ; need to call graysprite
        ld      (__ClipSpriteE),hl              ; modify call address

ClipSprite:
        ld      a,b                             ; get x coord
        cp      249                             ; hanging off left edge?
        jr      nc,ClipSpriteL                  ; then clip left edge
        cp      128                             ; completely off right edge?
        ret     nc                              ; then don't draw it
        jr      ClipSpriteR                     ; clip right edge
ClipSpriteL:
        res     7,b                             ; draw on right edge
        dec     c                               ; move up a row (left clipping)
        bit     7,c                             ; are we on the top edge?
        jr      z,ClipSpriteA                   ; if not, skip top fix
        ld      hl,__RenderSpriteCV             ; point to rows to draw
        inc     (hl)                            ; increase it (decreased later)
        dec     de                              ; decrease sprite pointer
        ld      hl,-16                          ; need to draw up a row
        ld      (__ClipSpriteX),hl              ; modify top row fix value
ClipSpriteA:
        ld      hl,$0318                        ; change instruction to <jr 3>
        ld      (__RenderSpriteCL),hl           ; modify to skip drawing left byte
        jr      ClipSpriteH                     ; done clipping horizontal
ClipSpriteR:
        cp      120                             ; hanging off right edge?
        jr      c,ClipSpriteH                   ; if not, don't clip
        ld      hl,$0318                        ; change instruction to <jr 3>
        ld      (__RenderSpriteCR),hl           ; modify to skip drawing right byte
ClipSpriteH:
        ld      a,c                             ; get y coord
        cp      249                             ; hanging off top?
        jr      nc,ClipSpriteT                  ; then clip the top
;        cp      63                              ; completely off the bottom?
        cp      64
        jr      nc,ClipSpriteF                  ; then don't draw, but fix everything
        jr      ClipSpriteB                     ; clip the bottom
ClipSpriteT:
        xor     a                               ; clear for subtract
        ;ld      h,a                             ; clear high byte
        sbc     hl,hl
        sub     c                               ; calc bytes above screen
        ld      c,h                             ; set y coord to 0
        ld      l,a                             ; set low byte to bytes above screen
        add     hl,de                           ; advance sprite pointer
        ex      de,hl                           ; swap back into de
        jr      ClipSpriteV                     ; finish vertical clipping
ClipSpriteB:
;        sub     56                              ; calc bytes below screen
        sub     57
        jr      c,ClipSpriteD                   ; don't clip if not below screen
        inc     a                               ; increase bytes below screen
ClipSpriteV:
        neg                                     ; negate so it can be subtracted
__ClipSpriteZ =$+1
        ld      hl,__RenderSpriteCV             ; point to rows to draw
        add     a,(hl)                          ; add (subtract) from current value
        ld      (hl),a                          ; save new value
ClipSpriteD:
        push    de                              ; push sprite pointer
        pop     ix                              ; pop sprite pointer in ix
        call    FindAddress                     ; calc address and offset of sprite
__ClipSpriteX =$+1
        ld      de,0                            ; load address fix for top row
        add     hl,de                           ; add the fix value
__ClipSpriteE =$+1
        call    $ffff                           ; call the correct sprite routine
ClipSpriteF:
        ld      a,8                             ; normally 8 rows are drawn
        ld      (__RenderSpriteCV),a            ; set rows to draw back
        ld      hl,$a678                        ; normal opcode is <ld a,b \ and (hl)>
        ld      (__RenderSpriteCL),hl           ; set instructions back
        inc     l                               ; change <ld a,b> to <ld a,c>
        ld      (__RenderSpriteCR),hl           ; set instructions back
        ld      hl,0                            ; normally top row fix is 0
        ld      (__ClipSpriteX),hl              ; set row fix back
        ret                                     ; return from clipping

;================================================
; GraySprite - Put a masked grayscale sprite, no clipping
;
; Author:   David Phillips <david@acz.org>
;           Modified by James Vernon to allow whiting out of sprites
; Input:    HL => 8x8 masked grayscale sprite
;           B = XCoord
;           C = YCoord
; Output:   None
;================================================
GraySprite:
        push    hl                              ; push sprite pointer
        pop     ix                              ; pop in ix
        call    FindAddress                     ; calc address and offset
GraySpriteE:
        push    hl                              ; save address offset
        push    ix                              ; save sprite pointer
__ChooseGraySprite1 = $+1
        ld      de,GrayDraw1                    ; draw to first gray buffer
        add     hl,de                           ; add offset to buffer start
        ld      a,16                            ; grayscale sprites are 16 bytes
        ld      (__RenderSpriteM),a             ; adjust sprite load instruction
        call    RenderSprite                    ; draw the sprite
        ld      a,8                             ; second sprite is 8 bytes from mask
        ld      (__RenderSpriteM),a             ; adjust sprite load instruction back
        pop     ix                              ; restore sprite pointer
        pop     hl                              ; restore address offset
__ChooseGraySprite2 = $+1
        ld      de,GrayDraw2                    ; now draw to second gray buffer
        add     hl,de                           ; add offset to second buffer start
        ld      de,$0008                        ; sprites are 8 bytes
        add     ix,de                           ; advance sprite pointer

RenderSprite:
__RenderSpriteCV =$+1
        ld      b,8                             ; set row counter to 8 bytes
RenderSpriteL:
        push    bc                              ; save row counter and sprite offset
        ld      a,(ix+8)                        ; load mask for this row
__RenderSpriteM =$-1
        cpl                                     ; invert the mask
        ld      b,a                             ; save inverted mask
__GraySpriteWhite       = $
        nop
        ld      d,(ix)                          ; load sprite byte for this row
        jr      nc,GraySpriteNotWhite
        ld      d,0
GraySpriteNotWhite:
        inc     ix                              ; advance sprite pointer
        ld      a,c                             ; set shift counter to sprite offset
        ld      c,$ff                           ; set all bits of right mask byte
        ld      e,0                             ; clear right byte of sprite
        or      a                               ; is the sprite aligned?
        jr      z,RenderSpriteD                 ; then skip shifting it
RenderSpriteS:
        srl     d                               ; shift left sprite byte
        rr      e                               ; into the right sprite byte
        scf                                     ; set carry
        rr      b                               ; shift left mask byte
        rr      c                               ; into the right mask byte
        dec     a                               ; decrease shift counter
        jr      nz,RenderSpriteS                ; loop until counter is 0
RenderSpriteD:
__RenderSpriteCL = $
        ld      a,b                             ; load the left sprite byte
        and     (hl)                            ; and it with the screen
        nop
        or      d                               ; or it with the mask
        ld      (hl),a                          ; set screen memory to left byte
        inc     hl                              ; increase screen pointer
__RenderSpriteCR = $
        ld      a,c                             ; load the right sprite byte
        and     (hl)                            ; and it with the screen
        nop
        or      e                               ; or it with the mask
        ld      (hl),a                          ; set screen memory to left byte
        ld      de,15                           ; next row is 15 bytes ahead
        add     hl,de                           ; move screen pointer to next row
        pop     bc                              ; restore loop counter and shift mask
        djnz    RenderSpriteL                   ; loop for all bytes in sprite
        ret                                     ; done drawing the sprite

;================================================
; FindAddress - Get offset for x & y coords
;
; Author:   David Phillips <david@acz.org>
; Input:    B = XCoord
;           C = YCoord
; Output:   HL = Offset of byte
;           C = Bit offset
;================================================
FindAddress:
        ld      l,c                             ; get the y coord
        ld      h,16
        mlt     hl
        ld      a,b                             ; now get the x coord
        and     %11111000                       ; clear lower 3 bits
        rra                                     ; divide by 2
        rra                                     ; this time by 4
        rra                                     ; and finally by 8
        or      l                               ; combine with low byte
        ld      l,a                             ; save it
        ld      a,b                             ; get x coord again
        and     %00000111                       ; clear all but last 3 bits
        ld      c,a                             ; save sprite offset in c
        ret                                     ; return to caller

.end
