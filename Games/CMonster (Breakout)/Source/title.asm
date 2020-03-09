;############# CMonster by Patrick Davidson - title screen

title_show_highscore:
        call    show_highscores

Show_Title_Screen:       
        call    Clear_Screen
         
        ld      hl,levelData
        ld      de,map
        ld      bc,160
        ldir
        
        ld      a,18
        ld      (delay_amount),a
        call    timer_init
        
        ld      c,3
        call    Draw_Map_Partial
        
        ld      hl,title_screen
        call    Draw_Strings  
        ld      hl,$b000
        ld      (wait_count),hl
        ld      h,l
        ld      (title_count),hl
        xor     a        
        ld      (hard_flag),a
        ld      a,sk1
        jp      before_search_speed
        
loop_title:
        ld      hl,(wait_count)
        inc     hl
        ld      (wait_count),hl
        ld      a,h
        or      l
        ld      c,1
        ret     z
        ld      hl,(title_count)
        inc     hl
        inc     hl
        ld      a,h
        and     31                      ; for 32 * 256 = 8192 pixels (1024 chars) in length
        ld      h,a
        ld      (title_count),hl
        ld      hl,0                    ; HL = X coordinate of segment of scroll being drawn
        
loop_scroll_message:
        push    hl
        
        push    hl
        ld      a,(title_count)
        sub     l
        ld      hl,scroll_table
#ifdef  TI84CE
        ld      de,0
#else
        ld      d,0
#endif
        ld      e,a
        add     hl,de
        ld      b,(hl)                  ; B = Y coordinate for character
        pop     hl                      ; HL = X coordinate for character
        
        push    hl
        ld      hl,(title_count)
        pop     de                      ; DE = X coordinate for character
        add     hl,de
        ex      de,hl                   ; HL = X coordinate, DE = X coordinate + adjust amount
        
        ld      a,e
        and     7
        ld      c,a                     ; C = X coordinate within character
   
        srl     d
        rr      e
        srl     d
        rr      e
        srl     d
        rr      e
                
        push    hl
        ld      hl,scroll_message
        add     hl,de
        ld      a,(hl)
        pop     hl
        
        call    Draw_Vertical_Subchar
        pop     hl
        inc     hl
        ld      a,h
        dec     a
        jr      nz,loop_scroll_message
        ld      a,l
        cp      64
        jr      nz,loop_scroll_message
        
        call    GET_KEY       
        cp      skPrgm
        jr      z,preview_levels
#ifdef  TI84CE
        ld      c,1
#else
        ld      c,2
        cp      skCos
        ret     z
        dec     c
#endif
        cp      skDel
        ret     z
        cp      skClear
        ret     z
        dec     c
        cp      skVars
        jp      z,Load_External_Levels
        cp      sk2nd
        ret     z
        cp      skAdd
        jr      z,easy_selected
        cp      skSub
        jr      z,hard_selected
        cp      skAlpha
        jp      z,title_show_highscore   

before_search_speed:        
        ld      b,9
        ld      hl,speed_table
loop_search_speed:
        cp      (hl)
        inc     hl
        jr      z,speed_match
        inc     hl
        djnz    loop_search_speed
        jp      loop_title

easy_selected:
        xor     a
        ld      hl,easy
        jr      difficulty_selected
        
hard_selected:
        ld      a,-1
        ld      hl,hard
        
difficulty_selected:
        ld      (hard_flag),a
        ld      bc,(52*256)+110
        call    Draw_String
        jp      loop_title
        
speed_match:
        ld      a,'0'+10
        sub     b
        ld      (score_inc),a
        ld      a,(hl)
        ld      (delay_amount),a
        ld      a,(score_inc)
        ld      bc,(40*256)+120
        call    Draw_Char
        jp      loop_title    
        
preview_levels:
        ld      a,1
        ld      (level),a
        call    Clear_Below_Tiles
preview_show:
        ld      a,(level)
        call    Load_Level
        ld      a,(level)
        ld      de,preview_level + 2
        call    Decode_A_DE_3
        ld      hl,preview_message
        call    Draw_Strings
        call    Draw_Map
        ld      hl,WAIT_RESET
        ld      (wait_count),hl
preview_loop:
        call    timer_wait
        ld      hl,(wait_count)
        inc     hl
        ld      (wait_count),hl
        ld      a,h
        or      l
        ld      c,1
        ret     z
        call    GET_KEY
        cp      skUp
        jr      z,preview_previous
        cp      skDown
        jr      z,preview_next
        cp      skClear
        ret     z
        cp      skDel
        ret     z
        cp      skEnter
        jp      z,Show_Title_Screen
        jr      preview_loop
        
preview_next:
        ld      a,(map_name)
        or      a
        ld      a,(level_count)
        jr      nz,preview_ext
        ld      a,NUM_LEVELS
preview_ext:
        ld      hl,level                
        cp      (hl)
        jr      z,preview_loop
        inc     (hl)
        jr      preview_show
        
preview_previous:
        ld      hl,level
        ld      a,(hl)
        dec     a
        jr      z,preview_loop
        dec     (hl)
        jr      preview_show
        
preview_message:
        .db     0,232
        .db     "Previewing level "
preview_level:
        .db     "--- - Use up/down/enter", 0, -1
        
speed_table:   
        .db     sk1,63
        .db     sk2,57
        .db     sk3,51
        .db     sk4,45
        .db     sk5,39
        .db     sk6,33
        .db     sk7,28
        .db     sk8,23
        .db     sk9,18

; ############# Draw a vertical slice of a character
; HL = X coordinate
; A = character
; B = Y coordinate
; C = slice (0 - 7)
        
Draw_Vertical_Subchar:
#ifdef  TI84CE
        push    hl
        sub     32
        ld      hl,0
        add     a,a
        ld      l,a
        add     hl,hl
        add     hl,hl
        ld      de,tileData
        add     hl,de                   ; HL -> start of char
        ex      de,hl
        pop     hl                      ; HL = X coordinate     
        push    de                      ; save character pointer on stack
        push    hl                      ; save X coordinate on stack
        
        ld      a,c
        add     a,a
        add     a,a
        add     a,a
        xor     %01111111
        ld      (smc_bit_selection+1),a
        
        ld      hl,0
        ld      de,0
        ld      e,b
        ld      l,b
        add     hl,hl
        add     hl,hl
        add     hl,de                   ; HL = 5 * Y
        add     hl,hl
        add     hl,hl                   ; HL = 20 * Y
        add     hl,hl
        add     hl,hl                   ; HL = 80 * Y
        add     hl,hl
        add     hl,hl                   ; HL = 320 * Y
        pop     de
        add     hl,de                   ; HL = 320 * Y + X
        add     hl,hl                   ; HL = 640 * Y + 2 * X
        ld      de,$D40000
        add     hl,de
        
        call    blank_6_rows
        pop     de
        
        ld      b,8
loop_char_main_slice:
        ld      a,(de)
        inc     de
smc_bit_selection:
        bit     0,a
        ld      a,$ff
        jr      z,char_slice_set
        xor     a
char_slice_set:
        push    bc
        ld      bc,320*2-1
        ld      (hl),a
        inc     hl
        ld      (hl),a
        add     hl,bc
        ld      (hl),a
        inc     hl
        ld      (hl),a
        add     hl,bc
        pop     bc
        djnz    loop_char_main_slice
        
blank_6_rows:
        ld      bc,320*2-1
        ld      a,6
loop_verticalsub:
        ld      (hl),0
        inc     hl
        ld      (hl),0
        add     hl,bc
        dec     a
        jr      nz,loop_verticalsub
        ret     
#else
        push    af
        push    bc
                       
        ld      a,$52                   ; minimum X
        call    Write_Display_Control
        ld      a,$21                   ; current X
        call    Write_Display_Control
        ld      a,$53                   ; maximum X
        call    Write_Display_Control
        
        pop     bc
        push    bc
        ld      h,0
        ld      l,b
        ld      a,$50                   ; minimum Y
        call    Write_Display_Control
        ld      a,$20                   ; current Y
        call    Write_Display_Control
        ld      a,27
        add     a,l
        ld      l,a
        ld      a,$51                   ; maximum Y
        call    Write_Display_Control
        
        ld      a,$22
        out     ($10),a
        out     ($10),a
        pop     bc
        
        ld      a,c
        add     a,a
        add     a,a
        add     a,a
        xor     %01111111
        ld      (smc_bit_selection+1),a

        call    blank_6_rows
        
        pop     af
        sub     32
        add     a,a
        ld      l,a
        ld      h,0
        ld      de,tileData
        add     hl,hl
        add     hl,hl
        add     hl,de
        ld      b,8
loop_char_main_slice:
        ld      a,(hl)
        inc     hl
smc_bit_selection:
        bit     0,a
        ld      a,$ff
        jr      z,char_slice_set
        xor     a
char_slice_set:
        out     ($11),a
        out     ($11),a
        out     ($11),a
        out     ($11),a
        djnz    loop_char_main_slice
        
blank_6_rows:
        ld      b,3
        xor     a
loop_verticalsub:
        out     ($11),a
        out     ($11),a
        out     ($11),a
        out     ($11),a
        djnz    loop_verticalsub        
        ret
#endif
        
title_screen:
        .db     24,40
        .db     "CMonster by Patrick Davidson",0
        
        .db     40,50
        .db     "eeulplek@hotmail.com",0
        
        .DB     14,60
        .db     "http://www.ocf.berkeley.edu/~pad/",0
        
        .db     6,70
        .db     "IRC: PatrickD on EfNet #ti, #cemetech",0
        
        .db     18,80
        .db     "eeulplek on Twitter and YouTube",0
        
#ifndef TI84CE
        .db     20,100
        .db     "Press COS to open level editor",0
#endif

        .db     4,110
        .db     "Difficulty: "
easy:   .db     "Easy (Select with + and -)",0
        
        .db     12,120
        .db     "Speed: 1 (Select with 1 through 9)",0
     
        .db     26,130
        .db     "Press 2ND to start the game",0

        .db     4,140
        .db     "Arrows move, CLEAR exits, P (8) pauses",0
        
        .db     28,150
        .db     "ENTER saves game and exits",0

        .db     26,160
        .db     "Press PRGM to preview levels",0

        .db     8,170
        .db     "Press VARS to select external levels",0
        
        .db     -1
        
hard:   .db     "Hard",0
        
scroll_message:
        .fill   40,' '
#import "scroll.txt"
        .fill   (scroll_message+1024+40-$),' '
