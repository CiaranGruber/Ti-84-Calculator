;############## CMonster by Patrick Davidson - graphics rendering routines

#define SPRITE(width,height) .db width/2,height
        
;############## Draw a sprite
; A = sprite's height (only needed for clipped version)
; B = X coordinate divided by 2
; L = Y coordinate
; DE -> sprite (first byte is the width / 2, second byte is height)
        
Draw_Sprite_Check_Clip_Below_16:
        add     a,l                     ; A = bottom Y coordinate + 1
        cp      233
        jr      c,Draw_Sprite_16        
        
        ld      a,232                   
        sub     l                       ; A = remaining lines to draw
        ret     c
        ret     z
        push    af
        
        call    Get_Screen_Start
        ld      a,(de)
        ld      (smc_sprite_column_count+1),a
        inc     de
        ld      a,(de)
        inc     de
        
        pop     af
        jr      draw_sprite_ready
        
Draw_Sprite_16:
        call    Get_Screen_Start

        ld      a,(de)
        ld      (smc_sprite_column_count+1),a
        inc     de
        ld      a,(de)
        inc     de
draw_sprite_ready:
        ld      b,a

next_sprite_row_draw:
        push    bc
        push    hl
smc_sprite_column_count:
        ld      b,5
next_sprite_column_draw:
        push    bc
        ld      bc,color_table
        ld      a,(de)
        rra
        rra
        rra
        and     %11110
        ld      c,a
        inc     bc
        ld      a,(bc)
        ld      (hl),a
        dec     bc
        inc     hl
        ld      a,(bc)
        ld      (hl),a
        inc     hl
        
        ld      a,(de)
        inc     de
        rla
        and     %11110
        ld      c,a
        inc     bc
        ld      a,(bc)
        ld      (hl),a
        dec     bc
        inc     hl
        ld      a,(bc)
        ld      (hl),a
        inc     hl      
        pop     bc
        djnz    next_sprite_column_draw
        pop     hl
        ld      bc,640
        add     hl,bc
        pop     bc
        djnz    next_sprite_row_draw

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
        
        call    Get_Screen_Start
        ld      a,(de)
        ld      (smc_erase_column_count+1),a
        inc     de
        ld      a,(de)
        
        pop     af
        jr      erase_sprite_ready
        
Erase_Sprite:
        call    Get_Screen_Start
        ld      a,(de)
        ld      (smc_erase_column_count+1),a
        inc     de
        ld      a,(de)
        inc     de
erase_sprite_ready:
        ld      b,a
        xor     a
        ld      de,640
next_sprite_row_erase:
        push    bc
        push    hl
smc_erase_column_count:
        ld      b,5
next_sprite_column_erase:
        ld      (hl),a
        inc     hl
        ld      (hl),a
        inc     hl
        ld      (hl),a
        inc     hl
        ld      (hl),a
        inc     hl
        djnz    next_sprite_column_erase
        pop     hl
        add     hl,de
        pop     bc
        djnz    next_sprite_row_erase

        ret

Get_Screen_Start:
        push    de
        ld      a,l
        ld      hl,0
        ld      l,a
        push    hl
        pop     de
        add     hl,hl
        add     hl,hl
        add     hl,de                   ; HL = 5 * Y
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl                   ; HL = 160 * Y
        ld      e,b
        add     hl,de                   ; HL = 160 * Y + X
        add     hl,hl
        add     hl,hl                   ; HL = 640 * Y + 4 * X
smc_odd_offset: 
        ld      de,$D40000
        add     hl,de
        pop     de
        ret