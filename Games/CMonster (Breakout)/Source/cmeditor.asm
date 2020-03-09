;############## CMonster by Patrick Davidson - editor startup for CE

#include        ti84pce.inc

#define bcall(x) call x
#define TI84CE
#define WORDLEN 3
_DivHLBy10      =_DivHLBy10_s   

#include        data.asm

        .org    userMem-2
        .db     tExtTok,tAsm84CeCmp    
        
        ld      a,20
        ld      (delay_amount),a
        
        call    _RunIndicOff
        call    level_editor
        
        call    _DrawStatusBar
        set     0,(iy+graphFlags)
        call    _ClrScrnFull        
        jp      _Clrtxtshd  
        
#include sharedce.asm
#include editor.asm
#include select.asm
#include text.asm
#include chars.i
#include search.asm
        .block  (256-($ & 255))
brick_palettes:
#include palette.i
packed_brick_images:
#include        bricks.i