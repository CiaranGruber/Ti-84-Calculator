.nolist
#include "includes\ti84pce.inc"
#include "includes\defines.inc"
#include "includes\macros.inc"
.list

.org Usermem-2
.db tExtTok,tAsm84CeCmp
PROGRAM_HEADER:
  jp PROGRAM_START
 .db 1									; Signifies a Cesium program
 .db 16,16								; Width, Height of sprite
 .db 255,255,255,163,255,255,163,255,255,163,255,255,163,255,255,255
 .db 255,107,107,162,107,107,162,107,107,162,107,107,162,107,107,255
 .db 255,107,255,129,255,255,129,255,255,129,255,255,129,255,107,255
 .db 255,107,255,097,181,255,097,181,255,097,181,255,097,181,107,255
 .db 255,107,255,255,255,255,255,255,255,255,255,255,255,255,107,255
 .db 255,107,255,182,182,182,182,182,182,182,182,255,255,255,107,255
 .db 255,107,255,255,255,255,255,255,255,255,255,255,255,255,107,255
 .db 255,107,255,182,182,182,182,182,182,182,182,182,182,255,107,255
 .db 255,107,255,255,255,255,255,255,255,255,255,255,255,255,107,255
 .db 255,107,255,182,182,182,182,182,182,182,255,255,255,255,107,255
 .db 255,107,255,255,255,255,255,255,255,255,255,255,255,255,107,255
 .db 255,107,255,182,182,182,182,182,182,182,182,182,255,255,107,255
 .db 255,107,255,255,255,255,255,255,255,255,255,255,255,255,107,255
 .db 255,107,255,182,182,182,182,182,255,255,255,255,255,255,107,255
 .db 255,107,255,255,255,255,255,255,255,255,255,255,255,255,107,255
 .db 255,107,107,107,107,107,107,107,107,107,107,107,107,107,107,255
 .db "Text Editor ",VersionMajor+'0','.',VersionMinor+'0',0
PROGRAM_START:

PGRM_BEGIN:
 call Initialize
 jp Redraw	; Draw the stuff and the files
 
;------------------------------------------------------------------
; FullExit
; Fixes up everything and exits
;------------------------------------------------------------------
FullExit:
 call ClearScreens
 ld a,lcdBpp16
 ld (mpLcdCtrl),a
 call _DrawStatusBar
 call _HomeUp
 set graphDraw,(iy+graphFlags)
 res onInterrupt,(iy+onFlags)
 ret
 
#include "routines\initialization.asm"
#include "routines\keyboard.asm"
#include "routines\mainscrn.asm"
#include "routines\editing.asm"
#include "routines\appvar.asm"
#include "routines\other.asm"
#include "routines\text.asm"		; External includes
#include "routines\LCD.asm"

CODE_END:
DATA_START:
#include "data\ImageData.asm"
#include "data\TextData.asm"
DATA_END:

PGRM_END:
.echo "Code Base Size:\t",CODE_END-PGRM_BEGIN," bytes"
.echo "Data Size:\t",DATA_END-DATA_START," bytes"
.echo "Total Size:\t",PGRM_END-PGRM_BEGIN," bytes"