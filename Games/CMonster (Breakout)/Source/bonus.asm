;############## CMonster by Patrick Davidson - bonus brick

Check_Drop_Bonus:
        call    get_rand
        ld      hl,hard_flag
        bit     0,(hl)
        jr      nz,hard_mode
        and     127
hard_mode:
        cp      5
        ret     nc              ; exit if outside range (don't drop anything)
        
        ld      hl,bonus_type   ; exit if bonus existing
        bit     3,(hl)
        ret     nz
        
        add     a,8
        ld      (hl),a
        inc     hl
        ld      a,d
        add     a,a
        add     a,a
        add     a,a
        ld      (hl),a
        inc     hl
        ld      a,e
        add     a,a
        add     a,a
        add     a,a
        ld      (hl),a  
        ret
        
Show_Bonus:
        ld      a,(bonus_type)
        or      a
        ret     z               ; exit if type is 0
        
        ld      hl,bonus_y
        inc     (hl)
        ld      a,(hl)
        cp      217
        jr      c,bonus_still_on_screen
        
        dec     hl
        ld      a,(expanded_flag)
        add     a,31
        ld      b,a             ; B = bonus collection area width
        ld      a,(hl)          ; A = bonus X
        ld      hl,p_x
        sub     (hl)            ; A = bonus X - paddle X
        add     a,7
        cp      b
        jr      c,collect_bonus
        
        ld      a,(bonus_y)
        cp      232
        jr      nz,bonus_still_on_screen
        
remove_bonus_brick:
        ld      hl,bonus_type
        ld      a,(hl)
        or      a
        ret     z
        ld      (hl),0
        inc     hl
        ld      b,(hl)
        inc     hl
        ld      l,(hl)
        dec     l
        ld      de,img_fake_bonus
        ld      a,8
        jp      Erase_Sprite_Check_Clip_Below
        
bonus_still_on_screen:  
        ld      de,(bonus_x)
        ld      a,e
        rra
        rra
        rra
        and     31
        ld      b,a
        ld      a,d
        dec     a
        rra
        rra
        rra
        and     31        
        ld      c,a
        call    Draw_Brick
        
        ld      bc,(bonus_type-1)
        ld      hl,bonus_images-(66*8)
        ld      de,66
loop_find_image:
        add     hl,de
        djnz    loop_find_image
        
        ex      de,hl    

        ld      hl,(bonus_x)
        ld      b,l
        ld      l,h
        ld      a,8
        jp      Draw_Sprite_Check_Clip_Below_16        

collect_bonus:        
        ld      hl,remove_bonus_brick
        push    hl
        ld      a,(bonus_type)
        sub     9
        jr      z,collect_multi_ball
        dec     a
        jr      z,collect_bonus_points
        dec     a
        jr      z,collect_extra_life
        dec     a
        jr      z,collect_expand
        
collect_brickthrough:
        ld      hl,balls
        ld      b,ball_count
        ld      de,ball_size
collect_brickthrough_loop:
        ld      a,(hl)
        or      a
        jr      z,collect_brickthrough_skip
        ld      (hl),3
collect_brickthrough_skip:
        add     hl,de
        djnz    collect_brickthrough_loop
        ret
        
collect_expand:
        ld      hl,expanded_flag
        ld      a,(hl)
        or      a
        ret     nz
        ld      (hl),8
        
        ld      a,(p_x)
        cp      108
        ret     c
        sub     8        
        ld      (p_x),a
        ret

collect_bonus_points:
        ld      de,score_bonus+6
        ld      hl,score+6
        jp      Add_6_Digits_BCD
        
collect_extra_life:
#ifndef TI84CE
        call    Full_Window
#endif
        ld      hl,lives
        ld      a,(hl)
        cp      99
        jr      z,collect_bonus_points
        inc     (hl)
        ld      a,(hl)
        ld      de,livesm+1
        call    Decode_A_DE
        ld      a,(livesm)
        ld      bc,15*4*256+232 
        call    Draw_Char
        ld      a,(livesm+1)
        ld      bc,16*4*256+232 
        jp      Draw_Char
        
collect_multi_ball:
        ld      hl,balls
        ld      a,(hl)
        or      a
        jr      nz,found_source
        ld      hl,balls+ball_size
        ld      a,(hl)
        or      a
        jr      nz,found_source
        ld      hl,balls+(ball_size*2)
        
found_source:
        ld      de,balls
        call    Duplicate_Ball
        ld      de,balls+ball_size
        call    Duplicate_Ball
        ld      de,balls+(ball_size*2)
        
Duplicate_Ball:
        ld      a,(de)
        or      a
        ret     nz                      ; don't duplicate over existing ball
        
        push    hl
        ld      bc,ball_size            ; copy the ball
        ldir
        call    get_rand               
        ex      de,hl
        dec     hl
        dec     hl        
        dec     hl
        and     %11000011               ; up/down, left/right, low bits angle
        xor     (hl)
        ld      (hl),a
        pop     hl
        ret

get_rand:
        ld      hl,rand_inc     ; generate random bonus type
        ld      a,(hl)
        inc     hl
        add     a,(hl)
        ld      (hl),a
        ret
        