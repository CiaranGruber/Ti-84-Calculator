;############## CMonster by Patrick Davidson - ball handling

Process_Balls:
        ld      hl,balls
        ld      b,ball_count
ball_loop:
        ld      a,(hl)
        or      a
        inc     hl
        jp      z,ball_loop_end
        push    bc            
        
;############## Erase the ball at its old coordinates

        push    hl
        ld      b,(hl)
        inc     hl
        ld      c,(hl)          ; C = high bits of Y coordinate 

        push    bc
        inc     hl
        inc     hl
        ld      a,(hl)          ; A = low bits of X
#ifdef  TI84CE
        rlca                    ; Get bit 0 of coordinate in 0 of A
        and     1
        add     a,a             ; double to byte offset in display memory
        ld      (smc_odd_offset+1),a
#else
        add     a,a             ; carry set if odd
        ld      a,0             ; NOP instruction
        jr      nc,no_erase_odd
        ld      a,$2c           ; INC L instruction
no_erase_odd:
        call    Set_Sprite_Offset
#endif     
        ld      de,img_fake_ball
        ld      l,c
        ld      a,5
        call    Erase_Sprite_Check_Clip_Below       

        pop     bc              ; BC = pixel XY
        push    bc
        
        ld      a,b
        rra
        rra
        rra
        and     %11111
        ld      b,a
        ld      a,c
        rra
        rra
        rra
        and     %11111
        ld      c,a             ; BC = brick coordinates        
        
        call    Draw_Brick_If_Nonzero
        pop     de              ; DE = pixel XY
        
        ld      a,d
        and     7               ; get X position within brick
        cp      5
        jr      c,not_multiple_column
        
        inc     b
        push    de
        call    Draw_Brick_If_Nonzero
        pop     de
        
        ld      a,e
        and     7               ; get Y position within brick
        cp      4
        jr      c,erase_brick_done
        inc     c
        call    Draw_Brick_If_Nonzero
        dec     b
        call    Draw_Brick_If_Nonzero
        jr      erase_brick_done
not_multiple_column:
        ld      a,e
        and     7               ; get Y position within brick
        cp      4
        jr      c,erase_brick_done
        inc     c
        call    Draw_Brick_If_Nonzero
erase_brick_done:
        
        pop     hl
        
;############## Ball outer loop (repeats ball movement 5 times)

        ld      b,5
ball_outer_loop:
        push    bc
        
;############## Y motion of ball

Move_Ball:
        push    hl              ; Push X coordinate pointer
        inc     hl
        push    hl              ; Push Y coordinate pointer
#ifdef  TI84CE
        ld      de,0
#endif
        ld      d,(hl)          ; A = Y coordinate (high bits)
        inc     hl
        ld      a,(hl)          ; A = direction
        inc     hl
        inc     hl
        ld      e,(hl)          ; DE = Y coordinate (8 bits fractional)
        
        bit     7,a             ; check Y direction flag
        ld      hl,ball_directions_y
#ifdef  TI84CE
        jp      nz,ball_up
#else
        jr      nz,ball_up
#endif
        
ball_down:
#ifdef  TI84CE
        ld      bc,0
#else
        ld      b,0
#endif
        and     31
        ld      c,a
        add     hl,bc
#ifdef  TI84CE
        ld      a,(hl)          ; A = new Y velocity
        ld      hl,0
        ld      l,a
#else
        ld      l,(hl)
        ld      h,0
#endif   
        add     hl,de           ; HL = new Y coordinate
        ex      de,hl           ; DE = new Y coordinate
        pop     hl              ; pop Y coordinate pointer
        ld      (hl),d          ; store high bits
        inc     hl
        inc     hl
        inc     hl
        ld      (hl),e          ; store low bits
        ld      a,d
        cp      232
        jr      c,not_fall_off_bottom
        pop     hl              ; pop X coordinate pointer      
        pop     bc              ; remove counter for the loop we're exiting
        dec     hl
        ld      (hl),0
        inc     hl
        jp      ball_loop_end_before_pop
not_fall_off_bottom:
        cp      219
        jr      c,ball_y_finished
        
        ld      a,(p_x)
        dec     hl
        dec     hl
        dec     hl
        dec     hl
        sub     (hl)
        neg                     ; A = ball X - paddle X 
        add     a,2             ; A = distance past left paddle edge + buffer
        
        ld      bc,(expanded_flag)
        bit     3,c             ; check for expanded paddle
        jr      z,not_expanded
        cp      32
        jr      nc,ball_y_finished
        ld      b,a
        add     a,a
        add     a,b
        srl     a
        srl     a               ; compute 3/4 of offset to normalize hit point
not_expanded:
        
        cp      24              ; paddle width plus buffer
        jr      nc,ball_y_finished
        inc     hl
        inc     hl
        cp      12
        jr      nc,bounced_right
        
bounced_left:      
        neg
        add     a,11
        or      %11000000     
        ld      (hl),a
        jr      update_counters_after_bounce
        
bounced_right:
        sub     12
        or      %10000000
        ld      (hl),a

update_counters_after_bounce:        
        xor     a
        ld      (bounce_count),a
        ld      (since_bounce),a
        
        ld      hl,plimit       ; decrement pause limit on bounce
        ld      a,(hl)
        or      a
        jr      z,plimit_already_zero
        dec     (hl)
plimit_already_zero:    

        pop     hl
        push    hl
        dec     hl              ; HL -> type
        ld      a,(hl)
        dec     a               ; decrement brickthrough if active
        jr      z,ball_y_finished
        ld      (hl),a
        jr      ball_y_finished
        
ball_up:
#ifdef  TI84CE
        ld      bc,0
#else
        ld      b,0
#endif
        and     31
        ld      c,a
        add     hl,bc
        ld      a,(hl)
        neg
#ifdef  TI84CE
        ld      hl,-1
#else
        ld      h,-1
#endif   
        ld      l,a
        add     hl,de           ; HL = new Y coordinate
        ex      de,hl           ; DE = new Y coordinate
        pop     hl
        ld      (hl),d          ; store high bits
        inc     hl
        inc     hl
        inc     hl
        ld      (hl),e          ; store low bits
        
        ld      a,d             ; check if bouncing off the top
        cp      245
        jr      c,ball_y_finished
        ld      (hl),0          ; low bits of coordinate to 0
        dec     hl
        dec     hl
        res     7,(hl)          ; set direction flag to down
        dec     hl
        ld      (hl),0          ; high bits of coordinate to 0            
        
ball_y_finished:

;############## X motion of ball

        pop     hl  
        push    hl              ; Push and pop X coordinate pointer
#ifdef  TI84CE
        ld      de,0
#endif
        ld      d,(hl)          ; A = X coordinate (high bits)
        inc     hl
        inc     hl
        ld      a,(hl)          ; A = direction
        inc     hl
        ld      e,(hl)          ; DE = X coordinate (8 bits fractional)
        
        bit     6,a             ; check Y direction flag
        ld      hl,ball_directions_x
        jr      nz,ball_left
        
ball_right:
#ifdef  TI84CE
        ld      bc,0
#else
        ld      b,0
#endif
        and     31
        ld      c,a
        add     hl,bc
#ifdef  TI84CE
        ld      a,(hl)          ; A = new X velocity
        ld      hl,0
        ld      l,a
#else
        ld      l,(hl)
        ld      h,0
#endif   
        add     hl,de           ; HL = new X coordinate
        ex      de,hl           ; DE = new X coordinate
        pop     hl
        push    hl
        ld      (hl),d          ; store high bits
        inc     hl
        inc     hl
        inc     hl
        ld      (hl),e          ; store low bits
        ld      a,d             ; check if bouncing off the right edge
        
        cp      157
        jr      c,ball_x_finished
        ld      (hl),127        ; low bits of coordinate to half
        dec     hl
        set     6,(hl)          ; set direction flag to left
        dec     hl
        dec     hl
        ld      (hl),157        ; high bits of coordinate to 157  
                
ball_left:
#ifdef  TI84CE
        ld      bc,0
#else
        ld      b,0
#endif
        and     31
        ld      c,a
        add     hl,bc
        ld      a,(hl)
        neg
#ifdef  TI84CE
        ld      hl,-1
#else
        ld      h,-1
#endif   
        ld      l,a
        add     hl,de           ; HL = new X coordinate
        ex      de,hl           ; DE = new X coordinate
        pop     hl
        push    hl
        ld      (hl),d          ; store high bits
        inc     hl
        inc     hl
        inc     hl
        ld      (hl),e          ; store low bits
        ld      a,d             ; check if bouncing off the left edge
        
        cp      245
        jr      c,ball_x_finished
        ld      (hl),0          ; low bits of coordinate to 0
        dec     hl
        res     6,(hl)          ; set direction flag to right
        dec     hl
        dec     hl
        ld      (hl),0          ; high bits of coordinate to 0  
        
ball_x_finished:
        pop     hl
        
;############## Collision check with bricks
         
        xor     a
        ld      (hit_corner),a
        ld      (already_count),a
             
        push    hl
        ld      a,(hl)          ; D = pixel X coordinate / 2
        rra
        rra
        rra
        and     31
        ld      d,a
        inc     hl
        ld      a,(hl)
        rra
        rra
        rra
        and     31
        ld      e,a                  
        call    Bounce_Brick_DE      
        jr      z,no_hit_topleft
        ld      hl,hit_corner
        set     0,(hl)
no_hit_topleft:
        pop     hl              ; HL -> X
               
        push    hl
        inc     d               
        ld      a,(hl)        
        and     7               ; get position within brick
        cp      6
        jr      c,topright_copy ; check if adding 2 goes to the next brick        
        call    Bounce_Brick_DE_Check_Already
        jr      z,no_hit_topright
        ld      hl,hit_corner
        set     1,(hl)
        jr      no_hit_topright
topright_copy:
        ld      hl,hit_corner
        bit     0,(hl)
        jr      z,no_hit_topright
        set     1,(hl)
no_hit_topright:
        pop     hl              ; HL -> X

        push    hl
        dec     d         
        inc     e
        inc     hl
        ld      a,(hl)        
        and     7               ; get position within brick
        cp      4
        jr      c,bottomleft_copy       
        call    Bounce_Brick_DE_Check_Already
        jr      z,no_hit_bottomleft
        ld      hl,hit_corner
        set     2,(hl)
        jr      no_hit_bottomleft
bottomleft_copy:
        ld      hl,hit_corner
        bit     0,(hl)
        jr      z,no_hit_bottomleft
        set     2,(hl)
no_hit_bottomleft:
        pop     hl              ; HL -> X        

        push    hl      
        inc     d
        ld      a,(hl)        
        and     7               ; get position within brick
        cp      6
        jr      c,bottomright_copy_from_bottomleft    
        inc     hl
        ld      a,(hl)        
        and     7               ; get position within brick
        cp      4
        jr      c,bottomright_copy_from_topright      
        call    Bounce_Brick_DE_Check_Already
        jr      z,no_hit_bottomright
        ld      hl,hit_corner
        set     3,(hl)
        jr      no_hit_bottomright
bottomright_copy_from_topright:
        ld      hl,hit_corner
        bit     1,(hl)
        jr      z,no_hit_bottomright
        set     3,(hl)
bottomright_copy_from_bottomleft:
        ld      hl,hit_corner
        bit     2,(hl)
        jr      z,no_hit_bottomright
        set     3,(hl)
no_hit_bottomright:
        pop     hl              ; HL -> X   
        
        push    hl
        ld      a,(hit_corner)
#ifdef  TI84CE
        ld      bc,0
#else
        ld      b,0
#endif
        ld      c,a
        ld      hl,bounce_actions
        add     hl,bc
        ld      d,(hl)          ; D = bit mask of bounce actions to take             
        pop     hl              ; HL -> X
        push    hl
        
        dec     hl
        ld      a,(hl)
        dec     a
        jr      nz,brickthrough_active
        
        inc     hl
        inc     hl
        inc     hl              ; HL -> direction
        ld      a,(hl)
        rl      d
        jr      nc,no_bounce_left
        set     6,a
no_bounce_left:
        rl      d
        jr      nc,no_bounce_right
        res     6,a
no_bounce_right:
        rl      d
        jr      nc,no_reverse_x
        xor     %01000000
no_reverse_x:
        rl      d
        jr      nc,no_bounce_up
        set     7,a
no_bounce_up:
        rl      d
        jr      nc,no_bounce_down
        res     7,a
no_bounce_down:
        rl      d
        jr      nc,no_reverse_y
        xor     %10000000
no_reverse_y:
        ld      (hl),a

        jr      bounce_done

brickthrough_active:
        xor     a
        ld      (bounce_count),a
bounce_done:
        pop     hl        
        
;############## End of ball outer loop
        pop     bc
        dec     b
        jp      nz,ball_outer_loop
        
;############## Draw the ball at its new coordinates

        push    hl
        ld      b,(hl)
        inc     hl
        ld      c,(hl)
        inc     hl
        inc     hl
        ld      a,(hl)          ; A = low bits of X
#ifdef  TI84CE
        rlca                    ; Get bit 0 of coordinate in 0 of A
        and     1
        add     a,a             ; double to byte offset in display memory
        ld      (smc_odd_offset+1),a
#else
        add     a,a             ; carry set if odd
        ld      a,0             ; NOP instruction
        jr      nc,no_draw_odd
        ld      a,$2c           ; INC L instruction
no_draw_odd:
        call    Set_Sprite_Offset
#endif        
        ld      de,img_fake_ball
        ld      l,c
        ld      de,img_ball
        ld      a,5
        call    Draw_Sprite_Check_Clip_Below_16
        pop     hl       
        
;############## End of the ball loop

ball_loop_end_before_pop:
        pop     bc
ball_loop_end:
        ld      de,ball_size-1
        add     hl,de
        dec     b
        jp      nz,ball_loop
        
        xor     a
#ifdef  TI84CE
        ld      (smc_odd_offset+1),a
#else
        call    Set_Sprite_Offset
#endif  
        ret

; Bounce actions table
; Indexed into table as follows
; Bit 0 - set if top left corner hit
; Bit 1 - set if top right corner hit
; Bit 2 - set if bottom left corner hit
; Bit 3 - set if bottom right corner hit
; Action byte defined as follows
; Bit 7 - set to force direction to left
; Bit 6 - set to force direction to right
; Bit 5 - set to reverse X direction
; Bit 4 - set to force direction to up
; Bit 3 - set to force direction to down
; Bit 2 - set to reverse direction
bounce_actions:
        .db     %00000000       ; Nothing hit, keep going
        .db     %01001000       ; A Hit on top left only, so go down right
        .db     %10001000       ; B Hit on top right only, so go down left
        .db     %00001000       ; C Hit on all of top, so go down only
        .db     %01010000       ; D Hit on bottom left only, so go up right
        .db     %01000000       ; E Hit on all of left, so go right only        
        .db     %00100100       ; F Hit on bottom left, top right, so reverse
        .db     %01001000       ; G Hit all but bottom right, so go down right
        .db     %10010000       ; H Hit on bottom right only, so go up left
        .db     %00100100       ; I Hit on bottom right and top left, so reverse
        .db     %10000000       ; J Hit on all of right, so go left only
        .db     %10001000       ; K Hit on all but bottom left, so go down left
        .db     %00010000       ; L Hit on all of bottom, so go up only
        .db     %01010000       ; M Hit on all but top right, so go up right
        .db     %10010000       ; N Hit on all but top left, so go up left
        .db     %00100100       ; O Hit on all, should be impossible, but reverse