#include        ti84pce.inc

        .org    userMem-2
        .db     tExtTok,tAsm84CeCmp
        
        di        
        ld	a,$25
	ld	($E30018),a                     ; set to 16 color mode
        
        ld      hl,image_data                   ; copy image data
        ld      de,$D60000
        ld      bc,256*16
        ldir                                    
        
        ld      hl,main_code                    ; copy and run main code
        ld      de,$E30200
        ld      bc,512
        ldir
        call    $E30200
        
        ld	a,$2D                           ; back to 65536 color mode    
	ld	($E30018),a
        ei
        call    _DrawStatusBar
        set     0,(iy+graphFlags)
        call    _ClrScrnFull        
        jp      _Clrtxtshd 
        
main_code:
#import main.bin
        
image_data:
#include        image.i