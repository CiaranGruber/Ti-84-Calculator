;-------------------------------------------------------------------------------
ClearScreens:
	call	ClearVBuf2
ClearVBuf1:
	ld	hl,vBuf1
	jr	+_
ClearVBuf2:
	ld	hl,vBuf2
_:	ld	a,255
	ld	bc,lcdWidth*lcdHeight
	jp	_MemSet

;-------------------------------------------------------------------------------
ClearScreenPartial:
	ld	a,255
	ld	hl,vBuf2+(lcdWidth*20)
	ld	bc,lcdWidth*lcdHeight-(lcdWidth*20)-(lcdWidth*16)
	jp	_MemSet

;-------------------------------------------------------------------------------
setup8bppMode:
	ld	a,lcdBpp8
	ld	(mpLcdCtrl),a
	ld	hl,$E30200    ; palette mem
	ld	b,0
_:	ld	d,b
	ld	a,b
	and	a,%11000000
	srl	d
	rra
	ld	e,a
	ld	a,%00011111
	and	a,b
	or	a,e
	ld	(hl),a
	inc	hl
	ld	(hl),d
	inc	hl
	inc	b
	jr	nz,-_
	ret

;-------------------------------------------------------------------------------
fullbufCpy:
	ld	bc,lcdWidth*lcdHeight
	ld	hl,vBuf2
	ld	de,vBuf1
	ldir
	ret

;-------------------------------------------------------------------------------
FillRectangle:
; bc = width
; hl = x coordinate
; e = y coordinate
; a = height
	ld	d,lcdWidth/2
	mlt	de
	add	hl,de
	add	hl,de
	ex	de,hl
FillRectangle_Computed:
	ld	ix,(SwapBufferLoc_SMC)			; de -> place to begin drawing
	ld	(_RectangleWidth_SMC),bc
_Rectangle_Loop_NoClip:
	add	ix,de
	lea	de,ix
_RectangleWidth_SMC =$+1
	ld	bc,0
	ld	hl,ForeColor
	ldi					; check if we only need to draw 1 pixel
	jp	po,_Rectangle_NoClip_Skip
	scf
	sbc	hl,hl
	add	hl,de
	ldir					; draw the current line
_Rectangle_NoClip_Skip:
	ld	de,lcdWidth			; move to next line
	dec	a
	jr	nz,_Rectangle_Loop_NoClip
	ret

;-------------------------------------------------------------------------------
bufCpy:
	ld	bc,(320*240)-(6*320)-90		; Shave off as much time that is reasonable when drawing.
	ld	hl,vBuf2
	ld	de,vBuf1
	ldir
	ret
 

_Sprite8bpp:
; hl -> sprite
; bc = xy
	push	hl
	or	a,a
	sbc	hl,hl
	ld	l,b
	add	hl,hl
	ld	de,vBuf2
	add	hl,de
	ld	b,lcdWidth/2
	mlt	bc
	add	hl,bc
	add	hl,bc				; hl -> start draw location
	ld	b,0
	ex	de,hl
	pop	hl
	ld	a,(hl)
	ld	(NoClipSprLineNext),a		; a = width
	inc	hl
	ld	a,(hl)				; a = height
	inc	hl
	ld	ix,0
NoClipSprLineNext =$+1
_:	ld	c,0
	add	ix,de
	lea	de,ix
	ldir
	ld	de,lcdWidth
	dec	a
	jr	nz,-_
	ret

compute8bpp:
	ld	de,320
	call	multDEA
SwapBufferLoc_SMC: =$+1
	ld	de,vBuf2
	add	hl,de
	ret
 
multDEA:
	ld	b,8
	or	a,a
	sbc	hl,hl
	add	hl,hl
	rlca
	jr	nc,$+3
	add	hl,de
	djnz	$-5
	ret
 
drawVLine8:
cIndex =$+1
	ld	a,0
	ld	(hl),a
	ld	de,lcdWidth
	add	hl,de
	dec	bc
	ld	a,b
	or	a,c
	jr	nz,drawVLine8
	ret
