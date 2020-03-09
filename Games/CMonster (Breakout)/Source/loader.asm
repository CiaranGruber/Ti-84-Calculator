;############## CMonster by Patrick Davidson - TI-84 Plus C Silver Edition specific

#include        ti84pcse.inc
#define WORDLEN 2
#define TI84CSE_LOADER

#include        data.asm   
load_address    =plotSScreen+768

;############## Flash app header

        .org    $4000
        .db     $80,$0f,0,0,0,0         ; master field
        .db     $80,$48,"CMonster"
        .db     $80,$90                 ; disable splash screen  
        .db     $80,$81,1               ; 1 page add
        .db     $80,$12,$01,$0f         ; 10F signing key (for 84+CSE)
        .db     $03,$20,$09,$00         ; empty date stamp
        .db     $02,$00                 ; empty date signature
        .db     $80,$70                 ; final field of flash header
        
        jp      main_loader_code
        
        jp      Search_Levels
        jp      Read_Ext_Level
        jp      Draw_String
        jp      Draw_Char
        jp      Draw_Strings
        
;############## Write HL to display register A

Write_Display_Control:
        out     ($10),a
        out     ($10),a
        ld      c,$11
        out     (c),h
        out     (c),l
        ret        

Write_Display_Control_C11:
        out     ($10),a
        out     ($10),a
        out     (c),h
        out     (c),l
        ret
        
        jp      GET_KEY
        jp      Select_External_Levels
        jp      Clear_Screen
        jp      Full_Window
        jp      timer_wait
        jp      timer_init
        jp      Decode_A_DE
        jp      Decode_A_DE_3
        
                .block  (256-($ & 255))
brick_palettes:
#include        palette.i
#include        chars.i
packed_brick_images:
#include        bricks.i
        
#include        shared.asm
#include        search.asm
#include        text.asm
#include        select.asm

main_loader_code:      
        ld      a,1
        out     ($20),a         ; maximum CPU speed
        ld      a,$45
        out     ($30),a         ; set timer frequency to 2048Hz  
        
        call    Read_Files      ; read from variables if possible
        
        ld      hl,0
        add     hl,sp
        ld      sp,$8100        ; new stack at $8100
        push    hl              ; save old stack
        
        ld      a,7             ; set our first data page at $C000
        out     (5),a

        ld      hl,saved_flag   ; copy game variables to ingame pages
        ld      de,saved_flag+$4000
        ld      bc,data_end-saved_flag
        ldir        
        ld      hl,high_scores
        ld      de,high_scores+$4000
        ld      bc,TABLE_SIZE
        ldir
        
        ld      a,6             ; set our data page at $C000
        out     (5),a
        ld      a,$87           ; set our data page at $8000
        out     (7),a
        
        ld      hl,compressed_data
        ld      de,load_address
        call    Decompress           
        call    load_address    ; run main game code
        
        ld      a,1             ; set standard $8000 page at $C000
        out     (5),a
        
        ld      hl,saved_flag
        ld      de,saved_flag+$4000
        ld      bc,data_end-saved_flag
        ldir        
        ld      hl,high_scores
        ld      de,high_scores+$4000
        ld      bc,TABLE_SIZE
        ldir    
        
        xor     a               ; restore usual RAM at $C000
        out     (5),a   
        ld      a,$81           ; restore usual RAM at $8000
        out     (7),a  

        pop     hl              ; restore stack pointer
        ld      sp,hl
        
        ld      a,(saved_flag)
        dec     a
        jr      nz,no_level_editor

        call    level_editor
        call    Full_Window
        jr      exit_app
no_level_editor:      
        call    Write_Files     ; write to variables if needed
exit_app:        
        bcall(_DrawStatusBar)
        bcall(_maybe_ClrScrn)
        bjump(_JForceCmdNoChar)
        
#include        editor.asm
#include        "..\ti86\lite86\lite86.asm"
#include        save.asm

Add_6_Digits_BCD:
        ld      b,6
loop_add_nocarry:
        xor     a
loop_add:
        dec     hl
        dec     de
        ld      a,(de)
        adc     a,(hl)
        sub     '0'             ; '0' was added twice because both ASCII
        cp      '0'+10
        jr      c,loop_add_nocarry_end
        sub     10
        ccf
        ld      (hl),a
        djnz    loop_add        
        ret     
loop_add_nocarry_end:
        ld      (hl),a
        djnz    loop_add_nocarry
        ret
        
Set_Sprite_Boundary:
        ld      h,0
        ld      a,$50           ; set minimum Y
        call    Write_Display_Control
        ld      a,$20           ; set current Y
        call    Write_Display_Control_C11
        
        ld      l,b             ; set minimum X
        ld      h,0
        add     hl,hl
        ld      a,$52
        call    Write_Display_Control_C11
        ld      a,$21           ; set current X
        call    Write_Display_Control_C11
        ld      a,(de)
        inc     de
        ld      c,a
        ld      b,0
        add     hl,bc
        ld      a,$53           ; set maximum X
        call    Write_Display_Control
        ld      a,$22
        out     ($10),a
        out     ($10),a
        ret     
        
;############## Main game data
        
compressed_data:
#import compressed.bin
        
#if     ($ > $8000)        
        .echo   "Overflow of available flash space on page 0 by ",eval($ - $8000)
        .error  "!!!!!!!!!!!!!!!!!!!! DISASTER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#endif
#if     ($ > $7FA0)        
        .echo   "Overflow after adding certificate by ",eval($ - $7FA0)
#else
        .echo   "Bytes left over in flash: ",eval($7FA0 - $)
#endif