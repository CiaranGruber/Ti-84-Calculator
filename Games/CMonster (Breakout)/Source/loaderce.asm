;############## Calcuzap by Patrick Davidson - TI-84 Plus CE unpacker

; Memory map on TI-84 CE ($D031F6 through $D13FD7 is available)
;
; $D031F6 to $D06FFF for unpacker, stack at very end (start = pixelShadow)
; $D07000 to $D0FFFF for main game
; $D10000 to $D13FD7 for variables (not fully used)

#include        ti84pce.inc

load_address    =$D07000   

        .org    userMem-2
        .db     tExtTok,tAsm84CeCmp    
        
        call    _RunIndicOff
        
        ld      hl,unpacker_source
        ld      de,unpacker_start
        ld      bc,unpacker_end-unpacker_start
        ldir
        
        ld      a,$d0
        ld      mb,a                    ; Z80 mode will be on $D00000 page   
        di
        ld.sis  sp,$7000                ; set Z80 mode stack pointer
        jp.sis  unpacker_start-$D00000  ; run unpacker in Z80 mode
        
unpacker_done:
        call    load_address
        
        ei      
        call    _DrawStatusBar
        set     0,(iy+graphFlags)
        call    _ClrScrnFull        
        jp      _Clrtxtshd        

unpacker_source:
        .org    pixelShadow
        .ASSUME ADL=0
unpacker_start:       
        ld      hl,compressed_data-$D00000
        ld      de,load_address-$D00000
        call    Decompress-$D00000      
        jp.lil  unpacker_done           ; go back to ADL mode for the rest  

#include        "..\ti86\lite86\lite86.asm"
        
compressed_data:
#import compressedce.bin

unpacker_end:

#if     ($ > $d06f00)        
        .echo   "CE loader overflow of available memory by ",eval($ - $d06f00)
        .error  "!!!!!!!!!!!!!!!!!!!! DISASTER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#else
        .echo   "Bytes left over for CE loader: ",eval($d06f00 - $)
#endif