;############## CMonster by Patrick Davidson - TI-84 Plus CE specific

#include        ti84pce.inc
#define TI84CE
#define WORDLEN 3
#define bcall(x) call x
_DivHLBy10      =_DivHLBy10_s   
_maybe_ClrScrn  =_ClrScrnFull

#include        data.asm   

        .org    $D07000   
        
        call    Read_Files   
        call    main
        jp      Write_Files        
    
;############## Subroutines

#include hiscore.asm
#include gfxce.asm
#include save.asm
#include text.asm
#include levels.asm
#include bonus.asm
#include ball.asm
#include title.asm
#include extlevel.asm
#include search.asm
#include select.asm
#include sharedce.asm

packed_brick_images:
#include bricks.i
#include chars.i
levelData:
#include map256.i
scroll_table:
#include        scroll_table.i
        .block  (256-($ & 255))
brick_palettes:
#include palette.i
#include cmonster.asm

#if     ($ > $d10000)        
        .echo   "CE Main code overflow of available memory by ",eval($ - $d10000)
        .error  "!!!!!!!!!!!!!!!!!!!! DISASTER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#else
        .echo   "Bytes left over for CE main code: ",eval($d10000 - $)
#endif

.end