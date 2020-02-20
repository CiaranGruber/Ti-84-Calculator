; this is used for both renamming and naming files
getFileName:
	drawFilledRect(0,225,320,240)
	changeFGColor(0FFh)
	changeBGColor(04Ah)
	print(DoneStr, 3, 230)
	print(ExitStr, 284, 230)
	changeFGColor(04Ah)
	changeBGColor(0FFh)
	call	getFileLoc
	ex	de,hl
	ld	de,filename
	push	de
	ld	bc,20
	ldir
	ld	a,$0D
	ld	(de),a
	call	drawName
	ld	hl,(posX)
	dec	hl
	ld	(cursorXReal),hl
	pop	hl
	call	DrawLine			; this is the file name

	ld	a,213
	ld	(cursorYReal),a		;	the	cursor	is	now	located	at	the	end	of	the	string
	call	DrawCursor
	call	getTable			;	draws	an	'A'	hopefully
	xor	a,a
	sbc	hl,hl
	ld	(cursorOffset),hl
	ld	(cursorX),a
	set	smallInput,(iy+txtFlgs)
	call	FullBufCpy
getnameLoop:
	call	_GetCSC
	ld	hl,getnameLoop
	push	hl
	cp	a,sk2nd
	jp	z,Press2ND
	pop	hl
	cp	a,skAlpha
	jp	z,alphaPressed
	cp	a,skLeft
	jp	z,left
	cp	a,skRight
	jp	z,right
	cp	a,skDel
	jp	z,deleteChar
	cp	a,skEnter
	jr	z,gotomain
	cp	a,skYEqu
	jr	z,gotomain
	cp	a,sk2nd
	jr	z,gotomain
	cp	a,skClear
	jr	z,gotomain2
	cp	a,skGraph
	jr	z,gotomain2
	sub	a,skAdd
	jp	c,getnameLoop
	cp	a,skMath-skAdd+1
	jp	nc,getnameLoop
	jp	InsertCharacter
ReturnToSmallEdit:
	call	drawName
	ld	hl,filename
	call	DrawLine
	call	DrawCursor
	call	FullBufCpy
	jr	getnameLoop
 
drawName:
	ld	hl,filename
	ld	a,$0D
	call	StrLngth
	ld	a,c	
	ld	(linelengths),a
	call	drawLowerBar
	print(RenameStr+2,2,214)
	ld	a,':'
	call	drawChar
	ld	a,' '
	jp	drawChar
  
gotomain:
	call	makeFileUnarchived
	ld	hl,filename
	ld	bc,20
	ldir
	call	makeFileArchived
gotomain2:
	call	ClearScreenPartial
	res	smallInput,(iy+txtFlgs)
	jp	DrawFilesLoop
	
GetNextFileName:
	ld	hl,FileNames100
	ld	bc,3
	ld	a,'0'
	call	_MemSet
_:
	ld	hl,FileNames
	call	_Mov9ToOP1
	call	_ChkFindSym
	jr	c,makeItThisOne
	call	Increment1
	jr	-_

makeItThisOne:
	ld	hl,22+4
	call	_CreateAppVar
	inc	de
	inc	de
	ld	hl,progSearchHeader
	ld	bc,5
	ldir
	ld	hl,FileNames+1
	ld	bc,7
	ldir
	ld	a,$0D
	ld	bc,20-7
	ex	de,hl
	call	_MemSet
	inc	hl
	ld	(hl),0				; signifies the end of a file, I guess
	call	ClearScreenPartial
	jp	DrawFilesLoop

Press2ND:
	bit	pressed2ND,(iy+txtFlgs)
	jr	z,+_
	res	pressed2ND,(iy+txtFlgs)
	jr	++_
_:	set	pressed2ND,(iy+txtFlgs)
_:	call	getTable
	jp	FullBufCpy
 
Increment100:
	ld	hl,FileNames100
	inc	(hl)
	ld	a,'0'
	ld	(FileNames10),a
	ld	(FileNames1),a
	ret
Increment10:
	ld	a,(FileNames10)
	cp	'9'
	jr	z,Increment100
	inc	a
	ld	(FileNames10),a
	ld	a,'0'
	ld	(FileNames1),a
	ret
Increment1:
	ld	a,(FileNames1)
	cp	'9'
	jr	z,Increment10
	inc	a
	ld	(FileNames1),a
	ret

deleteFile:
	res	deleteFileFlg,(iy+txtFlgs)
	call	drawLowerBar
	print(DeleteStr,2,214)
	ld	a,'?'
	call	drawChar
	ld	a,' '
	call	drawChar
	call	getFileLoc
	ld	a,016h
	ld	(BackColor),a
	ld	hl,NoStr
	call	DrawLine
	ld	a,04Ah
	ld	(ForeColor),a
	ld	a,0FFh
	ld	(BackColor),a
	ld	hl,(posX)
	inc	hl
	inc	hl
	ld	(posX),hl
	ld	hl,YesStr
	call	DrawLine
	ld	bc,61
	ld	a,214
	ld	(tmpX),bc
	ld	(tmpY),a
	call	FullBufCpy
_:	call	_GetCSC
	cp	a,skLeft
	call	z,changeDeleteFlag
	cp	a,skRight
	call	z,changeDeleteFlag
	cp	a,skEnter
	jr	nz,-_
	bit	deleteFileFlg,(iy+txtFlgs)
	jr	z,+_
	call	_ChkFindSym
	call	_DelVarArc
_:	ld	a,(absScrollPos)
	ld	b,a
	ld	a,(fullNumFiles)
	cp	a,b
	jr	nz,+_
	ld	a,(selFile)
	or	a,a
	jr	z,+_
	dec	a
	ld	(selFile),a
_:	call	ClearScreenPartial
	jp	DrawFilesLoop
 
changeDeleteFlag:
	bit	deleteFileFlg,(iy+txtFlgs)
	jr	z,+_
	ld	a,016h
	ld	(BackColor),a
	res	deleteFileFlg,(iy+txtFlgs)
	jr	++_
_:	ld 	a,0FFh
	ld 	(BackColor),a
	set	deleteFileFlg,(iy+txtFlgs)
_:	ld	bc,(tmpX)
	ld 	a,(tmpY)
	ld	(posY),a
	ld	(posX),bc
	ld	hl,NoStr
	call	DrawLine
	ld	a,(BackColor)
	ld	e,016h
	cp	a,e
	jr	z,+_
	ld	a,e
	jr	++_
_:	ld	a,0FFh
_:	ld	(BackColor),a
	ld	hl,(posX)
	inc	hl
	inc	hl
	ld	(posX),hl
	ld	hl,YesStr
	call	DrawLine
	ld	a,04Ah
	ld	(ForeColor),a
	ld	a,0FFh
	ld	(BackColor),a
	jp	FullBufCpy