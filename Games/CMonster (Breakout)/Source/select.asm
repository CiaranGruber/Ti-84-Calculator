;############## CMonster by Patrick Davidson - external level selection

Select_External_Levels:
        push    hl
        call    Clear_Screen
        ld      hl,level_select_message
        ld      bc,0
        call    Draw_String

        ld      hl,WAIT_RESET
        ld      (wait_count),hl
        pop     hl
        
        ld      de,search_name
        ld      bc,9
        ldir
        
        ld      de,0                    ; E = X, D = Y
        ld      (extlev_cursor_x),de
loop_display_level_names:
        push    de
        push    hl
        ld      a,d
        add     a,a
        add     a,a
        add     a,a                     ; Y * 8
        add     a,16                    ; start 16 pixels down
        ld      c,a
        
#ifdef  TI84CE
        ld      d,COLUMN_WIDTH
        mlt     de
        ld      a,e
#else
        ld      a,COLUMN_WIDTH
        bcall(_ATimesE)
        ld      a,l
#endif

        add     a,4
        ld      b,a
        ld      hl,search_name
        call    Draw_String
        pop     hl
        pop     de        
        
        push    de
        ld      c,0
        ld      a,d
        or      e
        jr      z,initial_search
        inc     c
initial_search:
        call    Search_Levels
        pop     de
        jr      z,search_finished
        
        ld      a,e
        cp      MAX_EXTLEV_X
        jr      nz,no_next_row        
        ld      a,d
        cp      MAX_EXTLEV_Y
        jr      z,search_finished       ; out of room at end of row 27         
        inc     d
        ld      e,-1
no_next_row:
        inc     e                       ; increment column
        jr      loop_display_level_names
        
search_finished:
        ld      (extlev_limit_x),de
        
        ld      de,0
        ld      (extlev_cursor_x),de
        di
loop_ext_select:
        ld      a,'>'
        call    draw_extlev_cursor
        call    timer_wait
        ld      hl,(wait_count)
        inc     hl
        ld      (wait_count),hl
        ld      a,h
        or      l
        ld      a,skClear
        ret     z
        call    GET_KEY
        cp      skClear
        ret     z
        cp      skDel
        ret     z
        cp      skRight
        jr      z,extlev_right
        cp      skUp
        jr      z,extlev_up
        cp      skDown
        jr      z,extlev_down
        cp      skLeft
        jr      z,extlev_left
        cp      skEnter   
        jr      z,extlev_selected
        jr      loop_ext_select
        
extlev_right:
        call    erase_extlev_cursor
        ld      hl,extlev_cursor_x
        ld      a,(hl)
        cp      MAX_EXTLEV_X 
        jr      z,loop_ext_select       ; already at last column of screen
        ld      a,(extlev_limit_y)
        inc     hl
        cp      (hl)                    ; check if on bottom row
        dec     hl
        jr      nz,extlev_not_at_end    ; if not, continue
        ld      a,(extlev_limit_x)      ; if so, check against end of row
        cp      (hl)
        jr      z,loop_ext_select
extlev_not_at_end:
        inc     (hl)
to_loop_ext_select:
        jr      loop_ext_select
        
extlev_up:
        call    erase_extlev_cursor
        ld      hl,extlev_cursor_y
extlev_common_dec:
        ld      a,(hl)
        or      a
        jr      z,loop_ext_select
        dec     (hl)
        jr      loop_ext_select
        
extlev_down:
        call    erase_extlev_cursor
        ld      a,(extlev_limit_y)
        ld      hl,extlev_cursor_y      ; check if on very last row
        cp      (hl)
        jr      z,loop_ext_select       ; already on bottom row
        dec     a
        cp      (hl)
        jr      nz,extlev_not_at_end    ; if not on next to last row
        dec     hl
        ld      a,(extlev_limit_x)
        cp      (hl)
        jr      c,to_loop_ext_select
        inc     hl
        jr      extlev_not_at_end
        
extlev_left:
        call    erase_extlev_cursor
        ld      hl,extlev_cursor_x
        jr      extlev_common_dec

extlev_selected:        
        ld      de,(extlev_cursor_x)    ; E = X, D = Y
        ld      a,d
        add     a,a
        add     a,a
        add     a,e
        jr      nz,external_levels
        
        ld      (map_name),a
        ret       

external_levels:        
        ld      b,a
        ld      c,0
loop_to_final_level:
        push    bc
        call    Search_Levels
        pop     bc
        ld      c,1
        djnz    loop_to_final_level
        
        ld      hl,search_name
        ld      de,map_name
        ld      bc,9
        ldir
        ld      de,levels_pointer
        ld      bc,4
        ldir
        ret
        
;############## Redraw cursor on external level screen
        
erase_extlev_cursor:
        ld      a,' '
draw_extlev_cursor:
        push    af
        
        ld      de,(extlev_cursor_x)     ; E = X
#ifdef  TI84CE
        ld      d,COLUMN_WIDTH
        mlt     de
        ld      b,e
#else
        ld      a,COLUMN_WIDTH
        bcall(_ATimesE)
        ld      b,l
#endif

        ld      a,(extlev_cursor_y)     ; A = row number
        add     a,a
        add     a,a
        add     a,a                     ; row * 8
        add     a,16                    ; start 16 pixels down
        ld      c,a

        pop     af
        jp      Draw_Char
        
level_select_message:
        .db     "Select levels with arrow keys and enter",0
       