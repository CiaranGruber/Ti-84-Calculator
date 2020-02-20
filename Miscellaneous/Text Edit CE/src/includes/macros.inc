#define popCall() pop hl

#macro drawSpr255(sprite, posX, posY)
	ld	hl,sprite
	ld	bc,(posY)+(256*(posX))
	call	_Sprite8bpp
#endmacro

#macro drawFilledRect(LposX, TposY, RposX, BposY)
	ld	bc,RposX-LposX
	ld	de,(lcdWidth*TposY)+LposX
	ld	a,BposY-TposY
	call	FillRectangle_Computed
#endmacro

#macro drawHLine(posX, posY, length)
	ld	hl,320*posY+vBuf2+posX
	ld	bc,length
	ld	a,(cIndex)
	call	_MemSet
#endmacro

#macro drawVLine(posX, posY, length)
	ld	hl,320*posY+vBuf2+posX
	ld	bc,length
	call	drawVLine8
#endmacro

#macro print(string, pos1, pos2)
	ld	hl,string
	ld	bc,pos1
	ld	(posX),bc
	ld	a,pos2
	ld	(posY),a
	call	DrawString
#endmacro

#macro changeFGColor(index)
#if index=0
	xor	a,a
#else
	ld a,index
#endif
	ld (ForeColor),a
#endmacro

#macro changeBGColor(index)
#if index=0
	xor	a,a
#else
	ld a,index
#endif
	ld (BackColor),a
#endmacro