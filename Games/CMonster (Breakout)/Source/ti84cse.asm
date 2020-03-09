;############## CMonster by Patrick Davidson - TI-84 Plus CSE main program

#include        ti84pcse.inc
#define WORDLEN 2
#include        data.asm

#define rscount         $4024
Search_Levels                           rs(3)
Read_Ext_Level                          rs(3)
Draw_String                             rs(3)
Draw_Char                               rs(3)
Draw_Strings                            rs(3)
Write_Display_Control                   rs(11)
Write_Display_Control_C11               rs(9)
GET_KEY                                 rs(3)
Select_External_Levels                  rs(3)
Clear_Screen                            rs(3)
Full_Window                             rs(3)
timer_wait                              rs(3)
timer_init                              rs(3)
Decode_A_DE                             rs(3)
Decode_A_DE_3                           rs(3)

#define rscount         $4100
brick_palettes                          rs(128)
tileData                                rs(98*8)
packed_brick_images                     rs(17*4*8)

        .org    plotSScreen+768
        
        call    Display_Org
        call    main
        jp      Display_Normal
        
;############## Subroutines

#include hiscore.asm
#include gfx.asm
#include levels.asm
#include bonus.asm
#include ball.asm
#include title.asm
#include extlevel.asm
#include cmonster.asm

#if     ($ > $C000)        
        .echo   "CSE executable code overflow by ",eval($ - $C000)
        .error  "!!!!!!!!!!!!!!!!!!!! DISASTER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#else
        .echo   "Bytes left over for CSE executable code: ",eval($C000 - $)
#endif

levelData:
#include map256.i
scroll_table:
#include        scroll_table.i

#if     ($ > $FFFF)        
        .echo   "CSE RAM overflow of available memory by ",eval($ - $FFFF)
        .error  "!!!!!!!!!!!!!!!!!!!! DISASTER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#else
        .echo   "Bytes left over in CSE RAM: ",eval($FFFF - $)
#endif

.end