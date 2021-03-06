LoopAndGet:
	res	deleting,(iy+txtFlgs)
	call	_GetCSC
	ld	hl,LoopAndGet
	push	hl
	cp	a,sk2nd
	jp	z,Press2ND
	pop	hl
	cp	a,skGraph
	jp	z,ExitFile
	cp	a,skYEqu
	jp	z,SaveFile
	cp	a,skDown
	jp	z,down
	cp	a,skUp
	jp	z,up
	cp	a,skLeft
	jp	z,left
	cp	a,skRight
	jp	z,right
	cp	a,skDel
	jp	z,deleteChar
	cp	a,skAlpha
	jp	z,alphaPressed
	cp	a,skEnter
	jp	z,insertEnter
	sub	a,skAdd
	jp	c,LoopAndGet
	cp	skMath-skAdd+1
	jp	nc,LoopAndGet
	jp	InsertCharacter
 
ExitFile:
	bit	saved,(iy+txtFlgs)
	jp	nz,AlreadySaved
	set	deleteFileFlg,(iy+txtFlgs)
	call	drawLowerBar
	print(SaveStr2,2,214)
	ld	a,'?'
	call	drawChar
	ld	a,' '
	call	drawChar
	ld	bc,(posX)
	ld	a,(posY)
	ld	(tmpX),bc
	ld	(tmpY),a
	call	getFileLoc		; Got the current file
	ld	a,0FFh
	ld	(BackColor),a
	ld	hl,NoStr
	call	DrawLine
	ld	a,016h
	ld	(BackColor),a
	ld	hl,(posX)
	inc	hl
	inc	hl
	ld	(posX),hl
	ld	hl,YesStr
	call	DrawLine
	call	FullBufCpy
_:
	call	_GetCSC
	cp	skLeft
	call	z,changeDeleteFlag
	cp	skRight
	call	z,changeDeleteFlag
	cp	skEnter
	jr	nz,-_
	bit	deleteFileFlg,(iy+txtFlgs)
	jr	z,AlreadySaved
	ld	hl,AlreadySaved
	ld	(Jump_SMC),hl
	res	saved,(iy+txtFlgs)
	jp	SaveFile
AlreadySaved:
	ld	hl,ReturnHere
	ld	(Jump_SMC),hl
	call	makeFileArchived
	jp	Redraw
	
insertEnter:
	call	GetOffset
	ex	de,hl
	ld	hl,1
	call	InsertMem
	call	GetOffset
	ld	(hl),newlineByte
	call	ClearScreenPartial
	res	saved,(iy+txtFlgs)
	call	RedrawText
	jp	right
	
deleteChar:
	ld	hl,(cursorOffset)
	call	_ChkHLIs0
	jp	z,ReturnHere
	res	saved,(iy+txtFlgs)
	set	deleting,(iy+txtFlgs)
	jp	left

ReturnHereToDelete:				; Play some crazy shenanigans -- Seems to work pretty well.
	res	deleting,(iy+txtFlgs)
	call	GetOffset
	ld	de,1
	call	DelMem
	bit	smallInput,(iy+txtFlgs)
	jr	z,+_
	jp	ReturnToSmallEdit
_:	call	ClearScreenPartial
	call	RedrawText
	jp	ReturnHere
 
InsertCharacter:
	ld	c,a
	bit	smallInput,(iy+txtFlgs)
	jr	z,+_
	ld	a,(linelengths)
	cp	a,20
	jp	z,ReturnToSmallEdit
_:	ld	a,c
	push	af
	call	GetOffset
	pop	af
	push	hl
	or	a,a
	sbc	hl,hl
	ld	l,a
	ld	de,(TblPtr)
	add	hl,de
	ld	a,(hl)
	pop	hl
	or	a,a
	jp	z,ReturnHere
	res	saved,(iy+txtFlgs)
	push	hl
	call	GetOffset
	ex	de,hl
	ld	hl,1
	call	InsertMem
	pop	hl
	ld	(hl),a
	bit	smallInput,(iy+txtFlgs)
	jp	z,++_
	ld	a,(linelengths)
	cp	a,20
	jr	z,+_
	inc	a
	ld	(linelengths),a
_:	jp	right
_:	call	ClearScreenPartial
	call	RedrawText
	jp	right
 
ReturnHere:
	bit	pressed2ND,(iy+txtFlgs)
	call	nz,getTable
	bit	deleting,(iy+txtFlgs)
	jp	nz,ReturnHereToDelete
	bit	smallInput,(iy+txtFlgs)
	jp	nz,ReturnToSmallEdit
	call	DrawCursor
	call	drawSaveSavedStr
	call	FullBufCpy
	jp	LoopAndGet
 
GetOffset:	
	ld	hl,(cursorOffset)
GetOffset_Short:
	ld	de,safeMem
	bit	smallInput,(iy+txtFlgs)
	jr	z,+_
	ld	de,filename
_:	add	hl,de
	ret

IncrementOffset:
	ld	hl,cursorOffset
	ld	de,(hl)
	inc	de
_:	ld	(hl),de
	ret
DecrementOffset:
	ld	hl,cursorOffset
	ld	de,(hl)
	dec	de
	jr	-_
 
; move the cursor right
right:
	call	EraseCursor			; clear the current cursor location
	call	GetCurrentLineLength		; get the length of the line
	ld	a,(cursorX)
	cp	a,c				; check and see if we've reached the end of the line
	jp	z,CheckIfNextLine
	inc	a
	ld	(cursorX),a			; increment x line posistion
	
	call	GetOffset
	ld	a,(hl)
_:	call	getPixelWidth			; get width of character
	ld	hl,(cursorXReal)
	call	_AddHLAndA
	ld	(cursorXReal),hl		; store new x value
	call	IncrementOffset
	jp	ReturnHere
 
CheckIfNextLine:
	bit	smallInput,(iy+txtFlgs)
	jp	nz,ReturnToSmallEdit
	call	CursorYRealToCol
	ld	a,c
	cp	a,14				; Check if at bottom
	push	af
	call	z,scrolldown
	pop	af
	jr	z,SkipThis
	call	CursorYRealToCol
	inc	c
	ld	hl,lineLengths
	add	hl,bc
	ld	a,(hl)
	or	a,a				; if 0, this means we can't go to it. -- Or it's a blank line with an enter. :P
	jp	nz,+_
	call	GetOffset
	ld	a,(hl)
	cp	a,newlineByte
	jp	nz,ReturnHere
_:	call	IncrementRow
SkipThis:
	ld	hl,1
	ld	(cursorXReal),hl
	xor	a,a
	ld	(cursorX),a
	call	GetOffset
	ld	a,(hl)
	cp	newlineByte
	jp	nz,+_
	call	IncrementOffset
	jp	ReturnHere
_:	call	getPixelWidth		; get width of character
	ld	hl,(cursorXReal)
	call	_AddHLAndA
	ld	(cursorXReal),hl		; store new x value
	ld	a,1
	ld	(cursorX),a
	call	IncrementOffset
	jp	ReturnHere
left:
	call	EraseCursor		; clear the current cursor location
	ld	a,(cursorX)
	or	a,a				; check and see if we've reached the end of the line
	jp	z,CheckIfPrevLine
	dec	a
	ld	(cursorX),a			; increment x line posistion
	call	GetOffset
	dec	hl
	ld	a,(hl)
	call	getPixelWidth			; get width of character
	ld	hl,(cursorXReal)
	ld	bc,0
	ld	c,a
	or	a,a
	sbc	hl,bc
	ld	(cursorXReal),hl		; store new x value
	call	DecrementOffset
	jp	ReturnHere
 
CheckIfPrevLine:
	ld	hl,(cursorOffset)
	call	_ChkHLIs0			; Return if on line 0
	jp	z,ReturnHere
	call	CursorYRealToCol
	ld	a,c
	or	a,a				; Check if at bottom
	push	af
	call	z,scrollup
	pop	af
	jr	z,+_
	call	DecrementRow
_:
	call	GetOffset
	dec	hl
	ld	a,(hl)
	cp	newlineByte
	jr	nz,+_
	call	DecrementOffset
_:
	call	GetCurrentLineLength		; get the length of the previous line
	ld	a,c
	ld	(cursorX),a			; store it into the cursor x posistion
	ld	hl,(cursorOffset)
	ld	de,0
	or	a,a
	jr	z,+_				; is the previous line's length 0?
	ld	e,a
	or	a,a
	sbc	hl,de
	call	GetOffset_Short	
	call	getPixelWidthStr		; now get the width of the line in pixels -> de
_:	inc	de
	ld	(cursorXReal),de
	jp	ReturnHere
 
; stores value into c
GetCurrentLineLength:
	bit	smallinput,(iy+txtFlgs)
	jr	nz,+_
	call	CursorYRealToCol		; Get the offset in the lines
	ld	hl,lineLengths
	add	hl,bc
	ld	c,(hl)		
	ret
_:
	ld	a,(lineLengths)
	ld	c,a
	ret
 
; stores the value into c
CursorYRealToCol:
	ld	a,(cursorYReal)
	ld	bc,0
_:	sub	a,13
	cp	a,27-13
	ret	z
	inc	c
	jr	-_
	ret
 
Redrawtext:
	ld	hl,lineLengths
	ld	bc,16
	xor	a,a
	res	more,(iy+txtFlgs)
	res	onFirstLine,(iy+txtFlgs)
	call	_MemSet				; set each line length to 0.
	ld	hl,linelengths
	ld	(LLOffset_SMC),hl		; um, okay.
 
	ld	a,28
	ld	bc,2
	ld	(posY),a
	ld	(posX),bc			; start posiiton
 
	ld	de,linePtrs
	ld	hl,(currLine)
	add	hl,hl
	add	hl,de
	ex	de,hl
	ld	hl,(textPtr)
	ex	de,hl
	ld	(hl),de
	ex	de,hl
DrawLoop:
	ld	a,(hl)
	cp	a,newlineByte
	jr	z,NextLineSkip
	or	a,a
	jr	z,CheckWhatToDo
	call	drawChar
	push	hl
LLOffset_SMC:	=$+1
	ld	hl,lineLengths
	inc	(hl)
	ld	de,(posX)
	ld	hl,310
	call	_cphlde
	pop	hl
	call	c,NextLine
Skipped:
	inc	hl
	jr	DrawLoop
	
NextLineSkip:
	call	NextLine
	jr	Skipped
 
NextLine:
	push	hl
	ld	hl,(LLOffset_SMC)
	inc	hl
	ld	(LLOffset_SMC),hl
	pop	hl
	bit	onFirstLine,(iy+txtFlgs)
	jr	nz,+_
	set	onFirstLine,(iy+txtFlgs)
	ld	(currPtr),hl  			; save next line
_:	ld	a,(posY)
	cp	a,200
	jr	nc,CheckWhatToDo2
	add	a,13
	ld	(posY),a			; move down a row
	ld	bc,2
	ld	(posX),bc
	ret

CheckWhatToDo2:
	set	more,(iy+txtFlgs)
	pop	hl
CheckWhatToDo:
	ret
 
down:						; okay; to move down, we need to check things: 1) Is there anything there if we move down 2) The new location to set us at
	call	EraseCursor
	call	CursorYRealToCol
	ld	a,c
	cp	a,14				; Check if at bottom
	push	af
	call	z,scrolldown			; That's right, scroll the screen
	pop	af				; Did we scroll?
	jr	nz,+_
	call	DecrementRow
_:	call	CursorYRealToCol
	inc	c
	ld	hl,lineLengths
	add	hl,bc
	ld	a,(hl)				; check if 0?
	or	a,a
	jp	nz,+_
	call	GetCurrentLineLength
	ld	a,(cursorX)
	ld	b,a
	ld	a,c
	sub	a,b
	call	GetOffset
	call	_AddHLAndA
	ld	a,(hl)
	cp	a,newlineByte
	jp	nz,ReturnHere			; jump if no available place
_:	call	CursorYRealToCol
	inc	c
	ld	hl,lineLengths
	add	hl,bc
	ld	c,(hl)
	ld	a,(cursorX)
	push	af
	cp	a,c				; if next line is shorter, store the end.
	jr	c,+_
	ld	a,c
	ld	(cursorX),a
_:	call	GetCurrentLineLength		; get length of line we are on
	pop	af				; a=cursorX
	ld	b,a
	ld	a,c
	sub	a,b				; tells us how much to increment the offset by
	ld	hl,(cursorOffset)
	call	_AddHLAndA			; now we are pointing to the start of the next line... Almost
	ld	(cursorOffset),hl
	call	GetOffset_Short
	ld	a,(hl)
	cp	a,newlineByte			; check and see if we need to add the newline character
	jr	nz,+_
	call	IncrementOffset
_:	call	GetOffset
	ld	a,(cursorX)
	ld	de,0
	or	a,a
	jr	z,+_
	call	getPixelWidthStr		; get the width of the next line
_:	inc	de
	ld	(cursorXReal),de
	call	IncrementRow
	ld	a,(cursorX)
	ld	hl,(cursorOffset)
	call	_AddHLAndA			; now we are pointing to the start of the next line... Almost
	ld	(cursorOffset),hl
	jp	ReturnHere
 
ChkCursorOnFirstLine: 
	ld	hl,(cursorOffset)
	ld	a,(cursorX)
	ld	bc,0
	ld	c,a
	or	a,a
	sbc	hl,bc
	call	_ChkHLIs0
	ret
 
; last one! let's see if we can move the cursor up :)
up:
	call	ChkCursorOnFirstLine
	jp	z,ReturnHere
	call	EraseCursor			; return if at the top line
	ld	a,(cursorX)			; this is how many are left, I guess
	ld	hl,(cursorOffset)
	ld	bc,0
	ld	c,a
	or	a,a
	sbc	hl,bc
	ld	(cursorOffset),hl		; Now we are pointing to the start of the line
	call	GetOffset_Short
	dec	hl
	ld	a,(hl)
	cp	newlineByte
	jr	nz,+_
	call	DecrementOffset
_:	call	CursorYRealToCol
	ld	a,c
	or	a,a				; Check if at bottom
	push	af
	call	z,scrollup
	pop	af
	jr	nz,+_
	call	IncrementRow
_:	call	CursorYRealToCol
	dec	c
	ld	hl,lineLengths
	add	hl,bc
	ld	c,(hl)				; c=num chars in prev line	;6
	ld	a,(cursorX)							;0
	cp	a,c				; prevline < current		;a<6
	jr	c,+_
	ld	a,c
_:	ld	(cursorX),a			; found new cursorX posistion
	ld	b,a				;0
	ld	a,c				;6
	sub	a,b				;6
	ld	hl,(cursorOffset)
	ld	bc,0
	ld	c,a
	or	a,a
	sbc	hl,bc
	ld	(cursorOffset),hl
	ld	a,(cursorX)			; offset
	ld	c,a
	or	a,a
	sbc	hl,bc
	call	GetOffset_Short
	ld	a,(cursorX)
	ld	de,0
	or	a,a
	jr	z,+_
	call	getPixelWidthStr
_:	inc	de
	ld	(cursorXReal),de
	call	DecrementRow
	jp	ReturnHere

DecrementRow:
	ld	a,(cursorYReal)
	sub	a,13
	jr	+_
IncrementRow:
	ld	a,(cursorYReal)
	add	a,13
_:	ld	(cursorYReal),a
	ret
	
scrolldown:
	bit	more,(iy+txtFlgs)
	jr	nz,+_
	pop	hl
	pop	af
	jp	ReturnHere
_:	ld	hl,(currLine)
	inc	hl
	ld	(currLine),hl
	ld	hl,(currPtr)
	inc	hl
	ld	(textPtr),hl
	jr	+_
scrollup:
	ld	de,linePtrs
	ld	hl,(currLine)
	dec	hl
	add	hl,hl
	add	hl,de
	ld	hl,(hl)
	ld	(textPtr),hl
	ld	hl,(currLine)
	dec	hl
	ld	(currLine),hl
_:	call	ClearScreenPartial
	jp	Redrawtext