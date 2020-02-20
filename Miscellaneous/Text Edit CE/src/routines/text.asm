DrawLine:
	ld	a,(hl)
	cp	a,newlineByte
	ret	z
	or	a,a
	ret	z
	call	drawChar
	inc	hl
	jr	DrawLine

DrawLine20:
	ld	b,20
_:	push	bc
	ld	a,(hl)
	cp	a,newlineByte
	jr	z,+_
	or	a,a
	jr	z,+_
	call	drawChar
	inc	hl
	pop	bc
	djnz	-_
	ret
_:	pop	bc
	ret
 
DrawString:
	ld	a,(hl)
	inc	hl
	or	a,a
	ret	z
	cp	a,newlineByte
	ret	z
	call	drawChar
	jr	DrawString

DrawChar:
posX =$+1
	ld	bc,0
	push	hl
	push	af
	push	de
	push	bc
posY =$+1
	ld	l,0
	ld	h,lcdWidth/2
	mlt	hl
	add	hl,hl
	ld	de,vBuf2
	add	hl,de
	add	hl,bc			; Add X
	push	hl
	sbc	hl,hl
	ld	l,a
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ex	de,hl
	ld	hl,char000
	add	hl,de			; hl -> Correct Character
	pop	de			; de -> correct place to draw
	ld	a,8
_iloop:	ld	c,(hl)
	ld	b,8
	ex	de,hl
	push	de
ForeColor =$+1
BackColor =$+2
	ld	de,$4AFF00
_i2loop:
	ld	(hl),d
	rlc	c
	jr	nc,+_
	ld	(hl),e
_:	inc	hl
	djnz	_i2loop
	ld	(hl),d
NextL:	ld	bc,320-8
	add	hl,bc
	pop	de
	ex	de,hl
	inc	hl
	dec	a
	jr	nz,_iloop
	pop	bc
	pop	de
	pop	af			; character
	cp	a,128
	jr	c,+_
	xor	a,a
_:	ld	hl,CharSpacing
	call	_AddHLAndA
	ld	a,(hl)			; A holds the amount to increment per character
AddToPosistion:
	or	a,a
	sbc	hl,hl
	ld	l,a
	add	hl,bc
	push	hl
	pop	bc
	inc	bc
	ld	(posX),bc
	pop	hl
	ret

;Gets width of character into A
getPixelWidth:
	cp	128
	jr	c,+_
	xor	a,a
_:	ld	hl,CharSpacing
	call	_AddHLAndA
	ld	a,(hl)			; A holds the amount to increment per character
	inc	a
	ret
 
DrawCursor:
	ld	a,(cIndex)
	push	af
	ld	a,$4A
	ld	(cIndex),a
_:	ld	a,(cursorYReal)
	call	compute8bpp
	push	hl
	ld	hl,(cursorXReal)
	ex	de,hl
	pop	hl
	add	hl,de
	ld	bc,9
	call	drawVLine8
	pop	af
	ld	(cIndex),a
	ret

EraseCursor:
	ld	a,(cIndex)
	push	af
	ld	a,255
	ld	(cIndex),a
	jr -_
 
;Gets width of string into DE
getPixelWidthStr:
	ld	de,0
	ld	b,a
_:
	push	hl
	ld	a,(hl)
	push	de
	call	getPixelWidth	; Now add a to de
	or	a,a
	sbc	hl,hl
	ld	l,a
	pop	de
	add	hl,de
	push	hl
	pop	de
	pop	hl
	inc	hl
	djnz	-_
	ret
