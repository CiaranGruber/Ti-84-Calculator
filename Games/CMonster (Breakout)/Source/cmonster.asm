;############## CMonster by Patrick Davidson
     
;#define TIME_INDICATOR

;############## Hardware initialization        

main:   call    Clear_Screen     
        
        ld      hl,saved_flag
        ld      a,(hl)
        or      a
        jr      z,no_saved_game
        ld      a,(map_name)
        or      a
        jp      nz,restore_external_level
        ld      (hl),0
        jr      play_game_resumed

no_saved_game:       
        ld      a,3
        ld      (lives),a
        ld      hl,score
        ld      b,6
loop_zero_score:
        ld      (hl),'0'
        inc     hl
        djnz    loop_zero_score
        
        call    Show_Title_Screen
        ld      a,1
        ld      (level),a
        dec     c
        ret     z
#ifndef TI84CE
        dec     c
        jr      nz,no_launch_level_editor
        ld      (saved_flag),a
        ret
no_launch_level_editor
#endif
        
prepare_level:
        ld      a,(map_name)
        or      a
        jr      nz,not_built_in
        ld      a,NUM_LEVELS
        ld      (level_count),a  
not_built_in:
        ld      hl,level
        ld      a,(level_count)
        cp      (hl)
        ld      hl,win_message
        jp      c,check_highscore
        ld      a,(level)
        call    Load_Level
        
play_game:      
        ld      hl,initial_data         ; initial object positions
        ld      de,bounce_count
        ld      bc,map-bounce_count
        ldir
        
play_game_resumed:
        xor     a
        ld      (since_bounce),a
        ld      hl,WAIT_RESET
        ld      (wait_count),hl
        call    Draw_Map    
        call    Clear_Below_Tiles
        
        ld      a,(lives)
        or      a
        ld      hl,lose_message
        jp      z,check_highscore
        
        ld      a,(level)
        ld      de,levelm+2
        call    Decode_A_DE_3        
        ld      a,(lives)
        ld      de,livesm+1
        call    Decode_A_DE
        ld      hl,title_messages        
        call    Draw_Strings
        
        ld      hl,0
        ld      de,map
        ld      bc,320
loop_count_bricks:
        ld      a,(de)
        and     %1111
        jr      z,no_brick_to_count
        cp      3
        jr      z,no_brick_to_count
        cp      5
        jr      z,no_brick_to_count
        cp      6
        jr      z,no_brick_to_count
        inc     hl
no_brick_to_count:
        inc     de
        dec     bc
        ld      a,b
        or      c
        jr      nz,loop_count_bricks
        ld      (brick_count),hl
        call    timer_init

;############## Main loop, beginning with timer synchronization
        
main_loop:    
        ld      hl,since_bounce
        ld      a,(hl)
        cp      5
        jr      c,no_adjust_direction
        
        ld      (hl),0
        ld      hl,balls+ball_dir        ; change ball direction if too long
        ld      b,3
        ld      de,ball_size
update_directions_random_loop:
        push    hl
        call    get_rand
        pop     hl
        and     %11
        xor     (hl)
        ld      (hl),a
        add     hl,de
        djnz    update_directions_random_loop        
no_adjust_direction:

        ld      hl,(wait_count)
        inc     hl
        ld      (wait_count),hl
        ld      a,h
        or      l
        jp      z,save_game
        ld      a,(score+4)
        or      1
        ld      hl,rand_inc
        add     a,(hl)
        ld      (hl),a

        call    timer_wait   
        ld      bc,34*4*256+232
        ld      hl,score
        call    Draw_String
        
#ifdef  TI84CE
        call    GET_KEY
#else
        ld      a,%11111110     ; mask out most keys (allow arrows)
        out     (1),a
#endif
        
        call    Show_Bonus

        ld      hl,p_x          ; move paddle
#ifdef  TI84CE
        ld      a,(getkeylastdata)
        cpl
#else
        in      a,(1)
#endif
        bit     1,a
        jr      nz,no_left
        ld      a,(hl)
        sub     3
        ld      (hl),a
        cp      140
        jr      c,no_leftedge
        ld      (hl),0  
no_leftedge:
        ld      a,(expanded_flag)
        add     a,20                            ; A = width of paddle
        add     a,(hl)
        ld      b,a
        ld      l,224
        ld      de,img_fake_paddle
        call    Erase_Sprite
        ld      hl,WAIT_RESET
        ld      (wait_count),hl
        jr      no_right
no_left:
        bit     2,a
        jr      nz,no_right
        
        ld      a,(expanded_flag)
        neg
        add     a,140                           
        ld      b,a                             ; B = maximum X coordinate
        
        ld      a,(hl)
        add     a,3
        ld      (hl),a
        cp      b
        jr      c,no_rightedge
        ld      (hl),b
no_rightedge:
        ld      a,-3
        add     a,(hl)
        ld      b,a
        ld      l,224
        ld      de,img_fake_paddle
        call    Erase_Sprite
        ld      hl,WAIT_RESET
        ld      (wait_count),hl
no_right:       

        ld      bc,(p_x-1)      ; redraw paddle
        ld      l,224
        ld      de,img_player_paddle_expanded
        ld      a,(expanded_flag)
        or      a
        jr      nz,paddle_is_expanded
        ld      de,img_player_paddle
paddle_is_expanded:
        call    Draw_Sprite_16  
        
        call    Process_Balls
        
        ld      hl,balls
        ld      b,ball_count
        xor     a
        ld      de,ball_size
count_remaining:
        or      (hl)
        add     hl,de
        djnz    count_remaining
        jr      nz,not_dead
        ld      hl,lives
        dec     (hl)
        call    Erase_Paddle
        jp      play_game
        
not_dead:

#ifndef TI84CE
        ld      a,%11110101     ; mask out most keys (allow P, STAT, clear)
        out     (1),a   
#endif
        ld      hl,plimit
        ld      a,(hl)
        or      a
        jr      nz,no_pause
check_pause:
#ifdef  TI84CE
        ld      a,(getkeylastdata+3)
        bit     3,a
        jr      z,no_pause
#else
        in      a,(1)
        bit     3,a
        jr      nz,no_pause
#endif
        ld      (hl),2
        ld      hl,WAIT_RESET
        ld      (wait_count),hl
        ld      hl,pause_message
        call    Draw_Strings
paused: call    timer_wait
        ld      hl,(wait_count)
        inc     hl
        ld      (wait_count),hl
        ld      a,h
        or      l
        jp      z,save_game
#ifdef  TI84CE
        call    GET_KEY
        cp      skClear
        ret     z
        cp      skStat
        jr      nz,paused
#else
        in      a,(1)
        bit     6,a
        ret     z
        add     a,a
        jr      c,paused
#endif
        jp      play_game_resumed
no_pause:
        
#ifndef TI84CE
        ld      a,%1111101      ; mask out most keys (allows clear and mode)
        out     (1),a
#endif

        ld      hl,(brick_count)
        
#ifdef  TI84CE
        ld      a,(getkeylastdata+1)
        bit     0,a
        jr      nz,save_game
        bit     6,a             ; check for clear
        ret     nz 
#else
        in      a,(1)           
        bit     0,a
        jr      z,save_game
        bit     6,a             ; check for clear
        ret     z  
#endif

        ld      a,h
        or      l
        jp      nz,main_loop
        
        ld      hl,level
        inc     (hl)
        call    Erase_Paddle
        jp      prepare_level

save_game:
        ld      hl,saved_flag
        set     7,(hl)
        ret
        
Erase_Paddle:
        ld      l,224           ; erase paddle
        ld      a,(p_x)
        ld      b,a
        ld      de,img_player_paddle
        jp      Erase_Sprite
        
;############## Images (of sorts)
        
img_player_paddle:
        SPRITE(40,8)        
        .db     $03,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$30
        .db     $32,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$23
        .db     $32,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$23
        .db     $32,$22,$22,$22,$22,$22,$22,$22,$11,$11,$11,$11,$22,$22,$22,$22,$22,$22,$22,$23
        .db     $32,$22,$22,$22,$22,$22,$22,$22,$11,$11,$11,$11,$22,$22,$22,$22,$22,$22,$22,$23
        .db     $32,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$23
        .db     $32,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$23
        .db     $03,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$30
        
        
img_player_paddle_expanded:
        SPRITE(56,8)        
        .db     $03,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$30
        .db     $32,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$23
        .db     $32,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$23
        .db     $32,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$11,$11,$11,$11,$11,$11,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$23
        .db     $32,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$11,$11,$11,$11,$11,$11,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$23
        .db     $32,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$23
        .db     $32,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$23
        .db     $03,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$30
        
img_ball:
        SPRITE(6,5)
        .db     $04,$44,$00
        .db     $43,$33,$40
        .db     $43,$33,$40
        .db     $43,$33,$40
        .db     $04,$44,$00
        
bonus_images:
        SPRITE(16,8)
        .db     $33,$00,$00,$00,$04,$00,$00,$33
        .db     $33,$00,$00,$00,$00,$40,$00,$33
        .db     $33,$00,$04,$40,$00,$04,$00,$33
        .db     $33,$04,$44,$44,$44,$44,$40,$33
        .db     $33,$04,$44,$44,$44,$44,$40,$33
        .db     $33,$00,$04,$40,$00,$04,$00,$33
        .db     $33,$00,$00,$00,$00,$40,$00,$33
        .db     $33,$00,$00,$00,$04,$00,$00,$33
        SPRITE(16,8)
        .db     $33,$00,$00,$00,$00,$00,$00,$33
        .db     $33,$00,$00,$00,$00,$00,$00,$33
        .db     $33,$00,$44,$00,$00,$44,$00,$33
        .db     $33,$04,$44,$40,$04,$44,$40,$33
        .db     $33,$04,$44,$40,$04,$44,$40,$33
        .db     $33,$00,$44,$00,$00,$44,$00,$33
        .db     $33,$00,$00,$00,$00,$00,$00,$33
        .db     $33,$00,$00,$00,$00,$00,$00,$33 
        SPRITE(16,8)
        .db     $33,$00,$00,$00,$00,$00,$00,$33
        .db     $33,$00,$00,$04,$40,$00,$00,$33
        .db     $33,$00,$00,$04,$40,$00,$00,$33
        .db     $33,$00,$04,$44,$44,$40,$00,$33
        .db     $33,$00,$04,$44,$44,$40,$00,$33
        .db     $33,$00,$00,$04,$40,$00,$00,$33
        .db     $33,$00,$00,$04,$40,$00,$00,$33
        .db     $33,$00,$00,$00,$00,$00,$00,$33
        SPRITE(16,8)
        .db     $33,$00,$04,$40,$04,$40,$00,$33
        .db     $33,$00,$40,$04,$40,$04,$00,$33
        .db     $33,$00,$40,$00,$00,$04,$00,$33
        .db     $33,$00,$40,$00,$00,$04,$00,$33
        .db     $33,$00,$40,$00,$00,$04,$00,$33
        .db     $33,$00,$04,$00,$00,$40,$00,$33
        .db     $33,$00,$00,$40,$04,$00,$00,$33
        .db     $33,$00,$00,$04,$40,$00,$00,$33
        SPRITE(16,8)
        .db     $33,$00,$00,$00,$00,$00,$00,$33 ; expander
        .db     $33,$00,$04,$00,$00,$40,$00,$33
        .db     $33,$00,$40,$00,$00,$04,$00,$33
        .db     $33,$04,$44,$44,$44,$44,$40,$33
        .db     $33,$04,$44,$44,$44,$44,$40,$33
        .db     $33,$00,$40,$00,$00,$04,$00,$33
        .db     $33,$00,$04,$00,$00,$40,$00,$33
        .db     $33,$00,$00,$00,$00,$00,$00,$33

#ifdef  TI84CE
img_fake_paddle:
        .db     3,8   
img_fake_bonus  =bonus_images
img_fake_ball   =img_ball
#else
img_fake_paddle:
        .db     5,6*8/2
        
img_fake_bonus:
        .db     15,8*16/2
        
img_fake_ball:  
        .db     5,6*5/2
#endif
        
;############## Data storage

title_messages:
        .db     0,232
title_message:
        .db     "CMonster Lives "
livesm: .db     "-- Level "
levelm: .db     "--- Score ",0
        .db     -1

initial_data:
        .db     0,0,80,0,0,0,0        
        .db     1,80,210,%11000011,0,0
        .fill   ball_size-1,0
        
pause_message:
        .db     0,0,"PAUSED: PRESS STAT TO RESUME",0,-1
        
ball_directions_x:
        .db     46,57,67,78,87,96,104,111,117,123,127,131
ball_directions_y:
        .db     255,246,235,222,208,192,174,156,136,114,93,70   
        
score_bonus:
        .db     "000025"             
        
        .end