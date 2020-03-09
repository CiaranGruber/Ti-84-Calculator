;############## CMonster by Patrick Davidson - editor startup for CE

#include        ti84pce.inc

#define bcall(x) call x
#define TI84CE
#define WORDLEN 3
_DivHLBy10      =_DivHLBy10_s   

#include        data.asm

        .org    $D07000  
        
        ld      a,20
        ld      (delay_amount),a
        
#include editor.asm
#include sharedce.asm
#include select.asm
#include text.asm
#include chars.i
#include search.asm
        .block  (256-($ & 255))
brick_palettes:
#include palette.i
packed_brick_images:
#include        bricks.i