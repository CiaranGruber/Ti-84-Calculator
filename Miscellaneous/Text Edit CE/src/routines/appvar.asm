;-------------------------------------
; fdetect
; detects appvars, prot progs, and
; progs given a 0-terminated string
; pointed to by ix.
;-------------------------------------
; INPUTS:
; hl->place to start searching
; ix->string to find
;
; OUTPUTS:
; hl->place stopped searching
; de->program data
; bc=program size
; OP1 contains the name and type byte
; z flag set if found
;-------------------------------------
fdetect:
	ld	de,(ptemp)
	call	_cphlde
	ld	a,(hl)
	ld	(typeByte_SMC),a
	jr	nz,fcontinue
	inc	a
	ret
fcontinue:
	push	hl
	cp	a,appVarObj
	jr	z,fgoodtype
	cp	a,protProgObj
	jr	z,fgoodtype
	cp	a,progObj
	jr	nz,fskip
fgoodtype:
	dec	hl
	dec	hl
	dec	hl
	ld	e,(hl)
	dec	hl
	ld	d,(hl)
	dec	hl
	ld	a,(hl)
	call	_SetDEUToA
	push	de
	pop	hl
	cp	a,$d0
	jr	nc,finRAM
	push	ix
	push	de
	push	hl
	pop	ix
	ld	a,10
	add	a,(ix+9)
	ld	de,0
	ld	e,a
	add	hl,de
	ex	(sp),hl
	add	hl,de
	pop	de
	ex	de,hl
	pop	ix
finRAM:
	inc	de
	inc	de
	ld	bc,0
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl		; hl -> data
	push	bc		; bc = size
	push	ix
	pop	bc
fchkstr:
	ld	a,(bc)
	or	a,a
	jr	z,ffound
	cp	(hl)
	inc	bc
	inc	de
	inc	hl
	jr	z,fchkstr
	pop	bc
fskip:
	pop	hl
	call	fbypassname
	jr	fdetect
ffound:
	push	bc
	pop	hl
	push	ix
	pop	bc
	or	a,a
	sbc	hl,bc
	push	hl
	pop	bc
	pop	hl		; size
	or	a,a
	sbc	hl,bc
	push	hl
	pop	bc
	pop	hl		; current search location
	push	bc
	call	fbypassname
	pop	bc
	xor	a,a
	ret
fbypassname:
	push	de
	ld	bc,-6
	add	hl,bc
	ld	de,OP1
	push	de
	ld	b,(hl)		; Name to OP1
	inc	b
fbypassnameloop:
	ld	a,(hl)
	ld	(de),a
	inc	de
	dec	hl
	djnz	fbypassnameloop
	xor	a,a
	ld	(de),a
typeByte_SMC:	=$+1
	ld	a,15h
	pop	de
	ld	(de),a
	pop	de
	ret
 
LoadFile:
	or	a,a
	sbc	hl,hl
	push	hl
	pop	de
	ld	a,(selFile)
	ld	l,a
	ld	e,a
	add	hl,hl
	add	hl,de
	ld	de,fileLocations
	add	hl,de

	push	hl
	pop	ix

	ld	hl,(ix)
 
	push	de
	push	bc
	ld	ix,progSearchHeader
	call	fdetect
	push	bc
	pop	hl
	ld	bc,-20
	add	hl,bc
	push	hl
	pop	bc
	ex	de,hl
	ld	de,fileName
	push	bc
	ld	bc,20
	ldir
	pop	bc
	xor	a,a
	ld	(de),a
	ld	de,safeMem
	push	de
	ldir
	ex	de,hl
	ld	(hl),0
	drawFilledRect(20,0,320,20)
	changeFGColor(0FFh)
	changeBGColor(04Ah)
	print(fileName,20,5)
	changeFGColor(04Ah)
	changeBGColor(0FFh)
	call	makefileunarchived
	ex	de,hl
	ld	de,20
	add	hl,de			; bypass name
	ld	(savePtr),hl		; this is the location you will want to ldir to
	ld	bc,0
	ld	a,(hl)
	or	a,a			; check and see if the file size is 0.
	jr	z,+_
	xor	a,a
	call	StrLngth
_:	call	_SetBCUTo0
	ld	(originalsize),bc
	push	bc
	pop	hl
	call	_ChkFindSym
	ld	(sizePtr),de		; for changing the size of the appvar
	pop	hl			; okay... So need to bypass the name
	pop	bc
	pop	de
	ret
 
getFileLoc:
	or	a,a
	sbc	hl,hl
	push	hl
	pop	de
	ld	a,(selFile)
	ld	l,a
	ld	e,a
	add	hl,hl
	add	hl,de
	ld	de,fileLocations
	add	hl,de
	
	push	hl
	pop	ix
 
	ld	hl,(ix)
	ld	ix,progSearchHeader
	call	fdetect
	ret
 
makeFileUnarchived:
	call getFileLoc
	call _ChkFindSym
	call _ChkInRam
	jr z,InRam
	call _Arc_Unarc
InRam:	jp getFileLoc
 
makeFileArchived:
	call	getFileLoc
	call	_ChkFindSym
	call	_ChkInRam
	ret	nz
	jp	_Arc_Unarc
 
SaveFile:
	ld	hl,(savePtr)		; pointer to insert
	ld	de,(originalsize)	; original size -> DE
	call	_ChkDEIs0		; check if size == 0
	jr	z,+_
	call	_DelMem			; erase all the old stuff
_:	ld	bc,0
	ld	hl,safeMem
	ld	a,(hl)			; check and see if the file is empty
	or	a,a
	jr	z,+_
	xor	a,a
	call	StrLngth		; get the length of the file
	push	bc			; save file length (for copying)
	push	bc
	pop	hl
	ld	de,(savePtr)
	call	_InsertMem		; insert memory for the new stuff
	pop	bc
_:	push	bc
	ld	de,(originalsize)	; bc = newSize to add/subtract, de=oldSize 0-5=-5 5-0=5 therefore, need to do newSize-OldSize and take absolute value
	push	bc
	pop	hl			; hl = newSize, de=oldSize
	or	a,a
	sbc	hl,de
	push	hl			; hl = size to change by
	ld	hl,(sizePtr)
	call	_LoadDEInd_s		; de = size of file
	pop	hl
	add	hl,de
	ld	de,(sizePtr)
	ld	a,l
	ld	(de),a
	ld	a,h
	inc	de
	ld	(de),a
	pop	bc			; wait... If this is 0, it's going to crash.
	call	_ChkBCIs0
	jr	z,+_
	ld	de,(savePtr)
	ld	hl,safeMem
	ldir				; copy it in
_:	set	saved,(iy+txtFlgs)
Jump_SMC: =$+1
	jp	ReturnHere