;############## CMonster by Patrick Davidson - level loading and rendering

Load_Level:
        dec     a
#ifdef  TI84CE
        ld      de,0
#else
	ld	d,0
#endif
	ld	e,a
#ifdef  TI84CE
        push    de
        pop     hl
#else
        ld      h,d
        ld      l,e
#endif
        add     hl,hl
        add     hl,hl
        add     hl,de           ; HL = 5 * level number
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl           ; HL = 320 * level number
        
        ld      de,levelData
        ld      a,(map_name)
        or      a
        jp      nz,Read_Ext_Level
        
        add     hl,de           ; HL -> map        
        ld      de,map
        ld      bc,320
        ldir
        ret
        
Draw_Map:
        ld      c,15
Draw_Map_Partial:
	ld      b,19
loop_draw_board:
	push	bc
	call	Draw_Brick
	pop	bc
	dec     b
        jp      p,loop_draw_board
        dec     c
        jp      p,Draw_Map_Partial
        ret
        
;############## Find brick value
; Input C = brick Y coordinate (0-15)
; Input B = brick X coordinate (0-19)
; Output A = brick value

Find_Brick_BC:
        ld      a,c 
        cp      16
        jr      nc,below_brick_area

        ld      hl,map
#ifdef  TI84CE
        ld      de,0
#else
        ld      d,0
#endif         

        add     a,a
        add     a,a               
        add     a,c             ; A = 5 * Y
        add     a,a             ; A = 10 * Y          
        ld      e,a
        add     hl,de
        add     hl,de           ; HL -> map + 20 * Y (start of row)
        ld      e,b
        add     hl,de           ; HL -> relevant brick in map
        ld      a,(hl)
        ret
	
below_brick_area:
        xor     a
        ret
        
;############## Detect if brick is present and update for bounce
; Input E = brick Y coordinate (0-15)
; Input D = brick X coordinate (0-19)
; Output zero flag set if no bounce, clear if we should bounce
; Preserves DE, destroys all other registers

Bounce_Brick_DE_Check_Already:
        ld      hl,already_hit
        ld      a,(already_count)
        or      a
        jr      z,Bounce_Brick_DE
        inc     a
        ld      b,a
already_check_loop:
        ld      a,(hl)
        cp      d
        inc     hl
        ld      a,(hl)
        inc     hl
        jr      nz,already_check_no_match
        cp      e
        jr      nz,already_check_no_match
        inc     a
        ret
already_check_no_match:
        djnz    already_check_loop
        
Bounce_Brick_DE:
        ld      a,e
        cp      16
        jr      nc,below_brick_area
        
        ld      hl,map
#ifdef  TI84CE
        ld      bc,0
#else
        ld      b,0
#endif  
        add     a,a
        add     a,a                    
        add     a,e             ; A = 5 * Y
        add     a,a             ; A = 10 * Y          

        ld      c,a
        add     hl,bc
        add     hl,bc           ; HL -> map + 20 * Y (start of row)
        ld      c,d
        add     hl,bc           ; HL -> relevant brick in map
        ld      a,(hl)
        and     15
        
#ifdef  TI84CE
        add     a,a
        add     a,a
#else
        ld      b,a
        add     a,a
        add     a,b
#endif
        ld      (brick_hit_dispatch+1),a

brick_hit_dispatch:
        jr      brick_hit_dispatch
        
        ret                             ; 0 = no brick, return with Z set
        .fill   WORDLEN
        jp      hit_normal_brick        ;1
        jp      hit_double_brick        ;2
        jp      solid_brick             ;3
        jp      hit_triple_brick        ;4
        jp      solid_brick             ;5
        jp      solid_brick             ;6
        jp      tall_upper              ;7
        jp      tall_lower              ;8
        jp      wide_top                ;9
        jp      wide_top                ;10
        jp      wide_bottom             ;11
        jp      wide_bottom             ;12
        jp      tall_middle             ;13
        jp      wide_top                ;14
                                        ;15
wide_bottom:    
        push    de
        push    hl
        call    wide_scan
        pop     hl
        pop     de
        
        push    de
        ld      bc,-20
        add     hl,bc
        dec     e
        call    wide_scan
        pop     de
        ret
        
wide_top:    
        push    de
        push    hl
        call    wide_scan
        pop     hl
        pop     de
        
        push    de
        ld      bc,20
        add     hl,bc
        inc     e
        call    wide_scan
        pop     de
        ret
        
wide_scan:
        ld      a,e
        add     a,a
        ret     c                               ; negative Y coord invalid
        cp      32
        ret     nc                              ; Y above 16 invalid
        ld      a,(hl)
        and     %1111
        cp      9
        jr      z,wide_scan_right_continue      ; at left edge
        cp      12
        jr      z,wide_scan_right_continue      ; at left edge
        cp      10
        jr      z,wide_scan_left_continue       ; at right edge            
        cp      11
        jr      z,wide_scan_left_continue       ; at right edge
        cp      14
        jr      z,wide_middle
        cp      15
        ret     nz
wide_middle:
        push    de
        push    hl
        call    wide_scan_right_continue        ; clear this col and to right
        pop     hl
        pop     de
        dec     d                               ; move one col left to clear
        dec     hl
        
wide_scan_left:
        bit     7,d
        ret     nz                              ; negative X coord invalid
        ld      a,(hl)
        and     %1111
        cp      14
        jr      z,wide_scan_left_continue
        cp      15
        jr      z,wide_scan_left_continue
        cp      9
        jr      z,wide_scan_left_final
        cp      12
        ret     nz
wide_scan_left_final:
        ld      a,(hl)
        and     %11110000
        inc     a
        ld      (hl),a
        push    hl
        push    de
        call    Draw_Brick_ADE_Set_Already
        pop     de
        pop     hl
        ret        
wide_scan_left_continue:
        call    wide_scan_left_final
        dec     hl
        dec     d
        jr      wide_scan_left

wide_scan_right:
        ld      a,d
        cp      20
        ret     nc                              ; X > 20 invalid
        ld      a,(hl)
        and     %1111
        cp      14
        jr      z,wide_scan_right_continue
        cp      15
        jr      z,wide_scan_right_continue
        cp      10
        jr      z,wide_scan_right_final
        cp      11
        ret     nz
wide_scan_right_final:
        ld      a,(hl)
        and     %11110000
        inc     a
        ld      (hl),a
        push    hl
        push    de
        call    Draw_Brick_ADE_Set_Already
        pop     de
        pop     hl
        ret        
wide_scan_right_continue:
        call    wide_scan_right_final
        inc     hl
        inc     d
        jr      wide_scan_right        

tall_middle:
        push    hl
        push    de
        inc     e
        ld      bc,20
        add     hl,bc
        call    tall_scan_down          ; first scan down from next row
        pop     de
        pop     hl                      ; fall through up from current row
                                        
tall_lower:
        push    de     
        call    tall_scan_up_continue
        pop     de
        ret
        
tall_scan_up:
        ld      a,(hl)
        and     %1111
        cp      7                       ; test if we found top brick     
        jr      z,tall_scan_up_final
        cp      13
        ret     nz                      ; exit if unexpected brick found
tall_scan_up_continue:
        call    tall_scan_up_final
        ld      bc,-20
        add     hl,bc
        dec     e
        bit     7,e                     ; check for going above the top
        jr      z,tall_scan_up
        ret           
tall_scan_up_final:
        ld      a,(hl)
        and     %11110000
        inc     a
        ld      (hl),a
        push    hl
        push    de
        call    Draw_Brick_ADE_Set_Already
        pop     de
        pop     hl
        ret                                 
                
tall_upper:
        push    de
        call    tall_scan_down_continue
        pop     de
        ret
              
tall_scan_down:
        ld      a,e
        cp      16
        ret     nc                      ; check for going below the bottom
        ld      a,(hl)
        and     %1111
        cp      8                       ; test if we found bottom brick     
        jr      z,tall_scan_down_final
        cp      13
        jr      z,tall_scan_down_continue
        ret                             ; reached if invalid map
tall_scan_down_final:
        ld      a,(hl)
        and     %11110000
        inc     a
        ld      (hl),a
        push    hl
        push    de
        call    Draw_Brick_ADE_Set_Already
        pop     de
        pop     hl
        ret        
tall_scan_down_continue:
        call    tall_scan_down_final
        ld      bc,20
        add     hl,bc
        inc     e
        jr      tall_scan_down
        
hit_triple_brick:
        dec     (hl)
hit_double_brick:
        dec     (hl)            ; change to single
        ld      a,(hl)
        push    de
        call    Draw_Brick_ADE
        pop     de
        ret
        
hit_normal_brick:
        xor     a
        ld      (hl),a
        push    de
        call    Draw_Brick_ADE
        jr      collect_points
        
solid_brick:
        ld      hl,since_bounce
        inc     (hl)
        ret
        
collect_points:
        ld      hl,(brick_count)
        dec     hl
        ld      (brick_count),hl
        ld      hl,bounce_count
        ld      a,(hl)
        cp      10
        jr      z,max_bounce
        inc     a
        ld      (hl),a
max_bounce:
        ld      b,a
add_score_loop:
        push    bc
        call    add_score
        pop     bc
        djnz    add_score_loop
        pop     de
        call    Check_Drop_Bonus
        xor     a               ; make sure zero flag is clear (NZ)
        inc     a
        ret

add_score:
        ld      a,(hard_flag)
        or      a
        call    nz,do_add_score
do_add_score:
        ld      hl,score+6      ; and increment the score
        ld      de,score_increment+5
        ld      a,(score_inc)
        ld      (de),a
        inc     de

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
        
score_increment:
        .db     "000001"

brick_results:
        .db     0,1,3,2,5,6
        
;############## Draw brick using images below
;
; B = X coordinate (0-19)
; C = Y coordinate (0-29)

Draw_Brick_If_Nonzero:
        push    bc
        push    hl        
        push    bc
        call    Find_Brick_BC
        pop     de
        or      a
        call    nz,Draw_Brick_ADE
        pop     hl
        pop     bc
        ret

Draw_Brick_ADE_Set_Already:
        push    af
        ld      hl,already_count
        #ifdef  TI84CE
        ld      bc,0
#else
        ld      b,0
#endif
        ld      c,(hl)
        inc     (hl)
        inc     hl
        add     hl,bc
        add     hl,bc
        ld      (hl),d
        inc     hl
        ld      (hl),e
        pop     af
        jr      Draw_Brick_ADE
        
Draw_Brick: 
        push    bc
        call    Find_Brick_BC
        pop     de

Draw_Brick_ADE:        
        push    af
        ld      hl,packed_brick_images
        add     a,a
        add     a,a
        add     a,a
        add     a,a
#ifdef  TI84CE
        ld      bc,0
#else
        ld      b,0
#endif
        ld      c,a
        add     hl,bc
        add     hl,bc           ; HL -> brick image
        pop     af
        
        rra
        and     %1111000        ; A = palette image offset
        
#ifdef  TI84CE
        inc     a               ; second color byte copied first on 84+CE
        ld      (smc_offset_1+1),a
        ld      (smc_offset_2+1),a
        ld      (smc_offset_3+1),a
        ld      (smc_offset_4+1),a
        push    hl
        ld      a,e
        add     a,a
        add     a,a
        add     a,a             ; A = pixel Y coordinate of top of brick

        ld      hl,0
        ld      l,a
        push    hl
        pop     bc
        add     hl,hl
        add     hl,hl           ; HL = 4 * Y
        add     hl,bc           ; HL = 5 * Y
        add     hl,hl
        add     hl,hl           ; HL = 20 * Y
        ld      c,d             
        add     hl,bc           ; HL = 20 * Y + brick X
        add     hl,hl
        add     hl,hl
        add     hl,hl           ; HL = 160 * Y + X
        add     hl,hl
        add     hl,hl           ; HL = 640 * Y + 4 * X
        ld      de,$D40000
        add     hl,de           ; HL -> start pixel
        ex      de,hl           ; DE -> start pixel
        pop     bc              ; BC -> image data        
        
        ld      a,8
draw_brick_outer:
        push    af
        ld      a,4
        ld      hl,brick_palettes+1
draw_brick_inner:
        push    af
        
        ld      a,(bc)
        rlca
        rlca
        rlca
        and     %110
smc_offset_1:
        or      %11
        ld      l,a
        ld      a,(hl)
        ld      (de),a
        dec     hl
        inc     de
        ld      a,(hl)
        ld      (de),a
        inc     de

        ld      a,(bc)
        rra
        rra
        rra
        and     %110
smc_offset_2:
        or      %11
        ld      l,a
        ld      a,(hl)
        ld      (de),a
        dec     hl
        inc     de
        ld      a,(hl)
        ld      (de),a
        inc     de
        
        ld      a,(bc)
        rra
        and     %110
smc_offset_3:
        or      %11
        ld      l,a
        ld      a,(hl)
        ld      (de),a
        dec     hl
        inc     de
        ld      a,(hl)
        ld      (de),a
        inc     de
        
        ld      a,(bc)
        add     a,a
        and     %110
smc_offset_4:
        or      %11
        ld      l,a
        ld      a,(hl)
        ld      (de),a
        dec     hl
        inc     de
        ld      a,(hl)
        ld      (de),a
        inc     de
        inc     bc
        
        pop     af
        dec     a
        jr      nz,draw_brick_inner
        ld      hl,640-32
        add     hl,de
        push    hl
        pop     de
        pop     af
        dec     a
        jr      nz,draw_brick_outer
        inc     a               ; so that zero flag is clear
        ret
        
#else        
        ld      (smc_offset_1+1),a
        ld      (smc_offset_2+1),a
        ld      (smc_offset_3+1),a
        ld      (smc_offset_4+1),a
        push    hl
        ld      a,e
        add     a,a
        add     a,a
        add     a,a             ; A = pixel Y coordinate of top of brick
        
        ld      h,0
        ld      l,a
        ld      a,$50           ; set minimum Y
        call    Write_Display_Control
        ld      a,$20           ; set current Y
        call    Write_Display_control_C11
        ld      a,d
        add     a,a
        add     a,a
        add     a,a             ; A = brick X * 8
        ld      l,a
        ld      h,0
        add     hl,hl           ; HL = pixel X = brick X * 16
        ld      a,$52           ; set minimum X
        call    Write_Display_Control_C11
        ld      a,$21           ; set current X
        call    Write_Display_Control_C11
        ld      a,l
        add     a,15
        ld      l,a
        ld      a,$53           ; set maximum X
        call    Write_Display_Control_C11
        ld      a,$22
        out     ($10),a
        out     ($10),a
        pop     de              ; DE -> brick image
        
        ld      b,(32*(1+8))&255        ; loop 32 times, but 8 outis per loop
        ld      hl,brick_palettes
loop_draw_brick:

        ld      a,(de)
        rlca
        rlca
        rlca
        and     %110
smc_offset_1:
        or      %11
        ld      l,a
        outi
        outi

        ld      a,(de)
        rra
        rra
        rra
        and     %110
smc_offset_2:
        or      %11
        ld      l,a
        outi
        outi
        
        ld      a,(de)
        rra
        and     %110
smc_offset_3:
        or      %11
        ld      l,a
        outi
        outi
        
        ld      a,(de)
        add     a,a
        and     %110
smc_offset_4:
        or      %11
        ld      l,a
        outi
        outi

        inc     de
        djnz    loop_draw_brick
#endif
        ret