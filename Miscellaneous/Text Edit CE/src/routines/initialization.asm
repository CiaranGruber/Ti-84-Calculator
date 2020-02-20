; Gets everything up and running
Initialize:
	call	_RunIndicOff
	xor	a,a
	sbc	hl,hl
	ld	(currLine),hl
	ld	(selFile),a
	ld	(prevSel),a
	ld	(scrollOffset),a ; Reset Stuff
	cpl
	ld	bc,256*2
	ld	hl,mpLcdPalette
	call	_MemSet
	jp	setup8bppMode
 
Redraw:
	call	ClearVBuf2
	changeFGColor(04Ah)
	drawFilledRect(0,0,320,20)
	drawSpr255(_icon,2,3)
	changeFGColor(0FFh)
	changeBGColor(04Ah)
	print(PgrmName, 20, 5)
	call	getTable
DrawFilesLoop:
	call	ResetForNew
	changeFGColor(04Ah)
	changeBGColor(0FFh)
	xor	a,a
	ld	(numFiles),a
	ld	(fullNumFiles),a
	ld	a,20-5
	ld	(posY),a
	ld	hl,fileLocations
	ld	(saveLocations),hl
	ld	hl,(progPtr)
	ld	a,(scrollOffset)
	or	a,a
	jr	z,NoScrollOffset
	ld	b,a
ScrollToFindStartFile:
	push	bc
	ld	ix,progSearchHeader
	call	fdetect
	pop	bc
	jp	nz,NoScrollOffset
	ld	a,(fullNumFiles)
	inc	a
	ld	(fullNumFiles),a
	djnz	ScrollToFindStartFile
NoScrollOffset:
ScanFindNextFile:
	ld	de,(saveLocations)
	ex	de,hl
	ld	(hl),de
	ex	de,hl
	inc	de
	inc	de
	inc	de
	ld	(saveLocations),de
 
	ld	ix,progSearchHeader
	call	fdetect
	ld	(curSearchFile),hl
	jr	nz,FoundAllFiles 	; No more files

	push	hl
	ld	hl,numFiles
	inc	(hl)
	ld	hl,fullNumFiles
	inc	(hl)
	ld	a,(numFiles)
	pop	hl
	cp	a,maxLines
	jr	nz,notHitMax
	jr	FoundAllFiles

notHitMax:
	ld	a,(posY)
	add	a,13
	ld	(posY),a
	ld	bc,14
	ld	(posX),bc
	ex	de,hl
	call	DrawLine20

	ld	hl,(curSearchFile)
	jr	ScanFindNextFile
 
FoundAllFiles:
	ld	hl,(curSearchFile)
CountAllFiles:
	ld	ix,progSearchHeader
	call	fdetect
	jr	nz,countedAllFiles

	ld	a,(fullNumFiles)
	inc	a
	ld	(fullNumFiles),a
	jr	CountAllFiles

NoFiles:	
	changeFGColor(04Ah)
	changeBGColor(0FFh)
	print(NoFilesStr,6,33-5)
	call	FullBufCpy

_:	call	_GetCSC
	cp	a,skYEqu
	jp	z,GetNextFileName
	cp	a,skClear
	jp	z,FullExit
	cp	a,skGraph
	jp	z,FullExit
	jr	-_
	
countedAllFiles:
	drawFilledRect(0,225,320,240)
	changeFGColor(0FFh)
	changeBGColor(04Ah)
	print(NewStr,3,230)
	print(ExitStr,284,230)
	
	ld	a,(numFiles)
	or	a,a
	jp	z,NoFiles
	
	changeFGColor(0FFh)
	changeBGColor(04Ah)
	print(RenameStr,58,230)
	print(DeleteStr,133,230)
	changeBGColor(0FFh)
	changeFGColor(04Ah)
	
	ld	a,(selFile)
	ld	b,a
	ld	a,(scrollOffset)
	add	a,b
	inc	a
	ld	(absScrollPos),a

	ld	a,(prevSel)
	ld	hl,ExtraSpace
	ld	b,2	
DrawBulletLoop:
	push	bc
	or	a,a
	jr	z,First
	ld	b,a
	xor	a,a
_:	add	a,13
	djnz	-_
First:
	add	a,33-5	;	Offset
	ld	bc,3
	ld	(posX),bc
	ld	(posY),a
	ld	a,(hl)
	call	drawChar
	ld	a,(selFile)
	ld	hl,Arrow
	pop	bc
	djnz	DrawBulletLoop
	call	fullbufcpy

noKeyPressedGUI:
	call	_getCSC
	or	a,a
	jr	z,noKeyPressedGUI
	cp	a,skYEqu
	jp	z,GetNextFileName
	cp	a,skWindow
	jp	z,getFileName
	cp	a,skZoom
	jp	z,deleteFile
	cp	a,skDel
	jp	z,deleteFile
	cp	a,skClear
	jp	z,FullExit
	cp	a,skGraph
	jp	z,FullExit
	cp	a,skEnter
	jp	z,loadAndDrawFile
	cp	a,sk2nd
	jp	z,loadAndDrawFile
	cp	a,skUp
	jr	nz,notGUIUp
	ld	a,(selFile)
	or	a,a
	jr	nz,notOffTop

	ld	a,(scrollOffset)
	or	a,a
	jr	z,noKeyPressedGUI
	ld	(prevSel),a
	dec	a
	ld	(scrollOffset),a
	call	ClearScreenPartial
	jp	DrawFilesLoop

notOffTop:
	ld	(prevSel),a
	dec	a
	ld	(selFile),a
	jp	DrawFilesLoop
notGUIUp:
	dec	a				; Down
	jr	nz,noKeyPressedGUI
	
	ld	a,(numFiles)
	ld	b,a
	ld	a,(selFile)
	ld	(prevSel),a
	inc	a
	cp	maxLines-1
	jr	nz,notOffBottomScreen

	ld	a,(absScrollPos)
	ld	b,a
	ld	a,(fullNumFiles)
	cp	a,b
	jp	z,noKeyPressedGUI
	ld	a,(scrollOffset)
	inc	a
	ld	(scrollOffset),a
	call	ClearScreenPartial
	jp	DrawFilesLoop

notOffBottomScreen:
	cp	a,b
	jp	z,noKeyPressedGUI
	ld	(selFile),a
	jp	DrawFilesLoop
	
loadAndDrawFile:
	ld	hl,safeMem
	ld	bc,plotsscreen-safeMem-1
	call	_MemClear
	set	saved,(iy+txtFlgs)
	drawFilledRect(0,225,320,240)
	changeFGColor(0FFh)
	changeBGColor(04Ah)
	print(SavedStr,3,230)
	print(ExitStr,284,230)
	changeBGColor(0FFh)
	changeFGColor(04Ah)
	res	smallInput,(iy+txtFlgs)
	call	ClearScreenPartial
	call	LoadFile
	ld	(textPtr),hl
	ld	a,27
	ld	bc,1
	ld	(cursorYReal),a
	ld	(cursorXReal),bc
	call	Redrawtext
	ld	a,1
	ld	(alphaStatus),a
	res	pressed2ND,(iy+txtFlgs)
	call	getTable
	jp	ReturnHere