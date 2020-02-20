getTable:
	ld	a,(alphaStatus)
	bit	pressed2ND,(iy+txtFlgs)
	jr	z,noShift
	or	a,a
	jr	nz,lowercaseinput
	
	ld	hl,CharTable2nd
	ld	b,0
	ld	d,$18
	jr	gotit
	
lowercaseinput:
	ld	hl,CharTableSmall
	ld	b,'A'
	ld	d,$18
	jr	gotit

noShift:
	ld	hl,CharTableNormal
	ld	b,'A'
	ld	d,0
	or	a,a
	jr	nz,gotit
	
	ld	hl,CharTableNum
	ld	b,0
	ld	d,b
	
gotit:
	ld	(TblPtr),hl
	push	de
	push	bc
	ld	a,6
	ld	(posY),a
	changeFGColor(0FFh)
	changeBGColor(04Ah)
	pop	af
	ld	de,320-12
	ld	(posX),de
	call	drawChar
	pop	af
	ld	de,320-12-12
	ld	(posX),de
	call	drawChar
	changeFGColor(04Ah)
	changeBGColor(0FFh)
	ret

alphaPressed:
	ld	a,(alphaStatus)
	dec	a
	jr	z,+_
	ld	a,1
_:	ld	(alphaStatus),a
	call	getTable
	call	FullBufCpy
	jp	LoopAndGet