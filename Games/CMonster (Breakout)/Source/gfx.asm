;############## CMonster by Patrick Davidson - graphics rendering routines

#define SPRITE(width,height) .db width-1,((width*height/2)*5)&255
        
        .block  (256-($ & 255))
        ;       %RRRRRGGG,%GGGBBBBB
color_table:
        .db     %00000000,%00000000     ; 0 = black
        .db     %11111000,%00000000     ; 1 = red
        .db     %11000110,%00011000     ; 2 = light gray
        .db     %11111111,%11111111     ; 3 = white
        .db     %11111100,%11111111     ; 4 = bright purple 
        
Clear_Below_Tiles:
        call    Full_Window
        ld      a,$50
        ld      hl,128
        call    Write_Display_Control
        ld      a,$20
        call    Write_Display_Control
        ld      l,0
        inc     a
        call    Write_Display_Control
        inc     a
        out     ($10),a
        out     ($10),a
        ld      bc,320*104*2/2
below_blank_loop:
        xor     a
        out     ($11),a
        out     ($11),a
        dec     bc
        ld      a,b
        or      c
        jp      nz,below_blank_loop
        ret
        
Display_Org:
        ld      a,3             ; adjust origin drawing mode
        ld      hl,$1038
        call    Write_Display_Control
        jp      Full_Window
        
Display_Normal:
        ld      a,3             ; normal drawing mode
        ld      hl,$10B8
        call    Write_Display_Control
        jp      Full_Window
        
;############## Draw a sprite
; A = sprite's height (only needed for clipped version)
; B = X coordinate divided by 2
; L = Y coordinate
; DE -> sprite (first byte is the width minus 1, second byte is (width * height / 2) * 5
        
Draw_Sprite_Check_Clip_Below_16:
        add     a,l                     ; A = bottom Y coordinate + 1
        sub     233
        jr      c,Draw_Sprite_16
        
        push    af
        call    Set_Sprite_Boundary
        pop     af
        
        inc     a                       ; A = number of lines to cut
        ld      b,a                     ; B = number of lines to cut
        
        dec     de
        ld      a,(de)
        inc     a                       ; A = number of pixels per line
        srl     a                       ; A = number of bytes per line
        ld      c,a
        add     a,a
        add     a,a
        add     a,c                     ; A = number of bytes per line * 5
        ld      c,a                     ; A = number of bytes per line * 5
        inc     de
        ld      a,(de)                  ; A = normal loop counter (bytes * 5)
        
loop_cut_line:                          
        sub     c
        djnz    loop_cut_line
        ld      c,$11
        jr      Ready_Draw_Sprite_16
        
Draw_Sprite_16:
        call    Set_Sprite_Boundary
        ld      a,(de)
Ready_Draw_Sprite_16:
        ld      b,a
        inc     de
        ld      hl,color_table
Loop_Draw_Sprite_16:
        ld      a,(de)          ; 134 clocks per loop, 67 clocks per pixel
        rra
        rra
        rra
        and     %11110
        ld      l,a
        outi
        outi
        ld      a,(de)
        rla
        and     %11110
        ld      l,a
        outi
        outi
        inc     de
        djnz    Loop_Draw_Sprite_16
        ret
        
Erase_Sprite_Check_Clip_Below:
        add     a,l                     ; A = bottom Y coordinate + 1
        cp      233
        jr      c,Erase_Sprite
                
        ld      a,232                   
        sub     l                       ; A = remaining lines to draw
        ret     c
        ret     z

        push    af
        ld      a,(de)                  ; A = width in pixels - 1
        inc     a
        ld      c,a                     ; C = width in pixels
        push    bc
        call    Set_Sprite_Boundary
        ex      de,hl
        inc     hl
        
        pop     de                      ; E = width in bytes
        pop     af                      ; A = remaining height in pixels
        ld      c,a
        xor     a
Erase_Clipped_Loop:
        ld      b,e
Erase_Clipped_Inner_Loop
        out     ($11),a
        out     ($11),a
        djnz    Erase_Clipped_Inner_Loop
        dec     c
        jr      nz,Erase_Clipped_Loop   
        ret
        
Erase_Sprite:
        call    Set_Sprite_Boundary
        ld      a,(de)
        ld      b,a
        xor     a
erase_loop:
        out     ($11),a
        out     ($11),a
        out     ($11),a
        out     ($11),a
        djnz    erase_loop
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
smc_odd_offset:
        nop
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
        
Set_Sprite_Offset:
        ld      (smc_odd_offset),a
        ret 