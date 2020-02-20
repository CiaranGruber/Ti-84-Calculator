InsertMem:
	push	de
	push	hl
	ld	hl,plotSScreen-1
	bit	smallInput,(iy+txtFlgs)
	jr	z,+_
	ld	hl,tmpStr+30
_:	ld	(change),hl
	or	a,a
	sbc	hl,de
	jr	z, +_
	push 	hl
	pop	bc
	add	hl,de
	dec	hl
	pop	de
	push	de
	add	hl,de
	ex	de,hl
change: = $+1
	ld	hl,plotSScreen-1
	dec	hl
	lddr
_:	pop	bc
	pop	de
	ret
 
DelMem:
	push	de
	push	hl
	add	hl,de
	ex	de,hl
	ld	hl,plotSScreen-1
	bit	smallInput,(iy+txtFlgs)
	jr	z,+_
	ld	hl,tmpStr+30
_:	or	a,a
	sbc	hl, de
	push	hl
	pop	bc
	pop	hl
	push	hl
	ex	de,hl
	jr	z, +_
	ldir
_:	pop	de
	pop	bc
	ret

;clears cursorX,cursorYReal,cursorXReal,cursorOffset,fileName,tmpStr
ResetForNew:
	ld	bc,38
	ld	hl,cursorX
	jp	_MemClear
 
drawLowerBar:
	ld	a,0FFh
	ld	hl,vBuf2+(lcdWidth*211)
	ld	bc,lcdWidth*14
	call	_MemSet
	ld	a,04Ah
	ld	(cIndex),a
	drawHLine(0,209,lcdWidth)
	drawHLine(0,210,lcdWidth)
	ret
 
StrLngth:
	push	hl
	ld	bc,0
	push	bc
	cpir
	pop	hl
	or	a,a
	sbc	hl, bc
	dec	hl
	push	hl
	pop	bc
	pop	hl
	ret
 
drawSaveSavedStr:
	changeFGColor(0FFh)
	changeBGColor(04Ah)
	bit	saved,(iy+txtFlgs)
	jr	z,NotSaved
	print(SavedStr, 3, 230)
	jr	+_
NotSaved:
	print(SaveStr, 3, 230)
_:	changeFGColor(04Ah)
	changeBGColor(0FFh)
	ret