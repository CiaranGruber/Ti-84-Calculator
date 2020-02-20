#ifndef DEFINES_TEXTEDIT
#define DEFINES_TEXTEDIT
#define maxLines 15
VersionMajor	equ 01h
VersionMinor	equ 02h
.ADDINSTR LD  HL,(HL) 6F66237E 4 NOP 1
;------------------
safeMem		equ 0D031F6h		; SafeRAM - This is where the file will be stored
cursorMem	equ 0E30800h		; SafeRAM
curSearchFile	equ cursorMem
numFiles	equ curSearchFile+3
selFile 	equ numFiles+1
scrollOffset	equ selFile+1
fullNumFiles	equ scrollOffset+1
absScrollPos	equ fullNumFiles+1
prevSel	 	equ absScrollPos+1
textPtr 	equ prevSel+1
currLine	equ textPtr+3
currPtr	 	equ currLine+3
prevPtr		equ currPtr+3
savePtr		equ prevPtr+3
originalsize	equ savePtr+3
sizePtr		equ originalsize+3
TblPtr		equ sizePtr+3
tmpX		equ TblPtr+3
tmpY		equ tmpx+3
alphaStatus	equ tmpY+1
lineLengths	equ alphaStatus+1
cursorX		equ lineLengths+16
cursorYReal	equ cursorX+1
cursorXReal	equ cursorYReal+1
cursorOffset	equ cursorXReal+3
fileName	equ cursorOffset+3
tmpStr		equ fileName
saveLocations	equ tmpStr+30
fileLocations	equ saveLocations+200
linePtrs	equ plotSScreen
;------------------
vBuf1 = vRAM
vBuf2 = vBuf1+(lcdWidth*lcdHeight)
;------------------
newlineByte	equ 0Dh
;------------------
txtFlgs		equ 21h
more		equ 00h
deleting	equ 01h
onFirstLine	equ 02h
deleteFileFlg	equ 03h
smallInput	equ 04h
pressed2ND	equ 05h
saved		equ 06h
;------------------
#endif