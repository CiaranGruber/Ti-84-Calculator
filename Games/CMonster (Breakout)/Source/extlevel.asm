;############## CMonster by Patrick Davidson - external levels

Load_External_Levels:
        ld      hl,built_in_message     ; built-in levels shown before search

        call    Select_External_Levels

        jp      Show_Title_Screen
        
;############## Restore game when external level was used to save

restore_external_level:
        ld      c,0
restore_search_loop:
        call    Search_Levels
        jr      z,restore_failed
        ld      de,map_name
        ld      hl,search_name
        ld      bc,(8<<8)+1
restore_check_name:
        ld      a,(de)
        cp      (hl)
        jr      nz,restore_search_loop
        inc     de
        inc     hl
        djnz    restore_check_name
        
        inc     hl
        ld      de,levels_pointer
        ld      bc,4
        ldir
        xor     a
        ld      (saved_flag),a
        jp      play_game_resumed
        
restore_failed:
        ld      hl,restore_fail_message
        call    Draw_Strings        
        xor     a
        ld      (wait_count),a
        ld      hl,map_name
        ld      bc,(4*27*256) + 60
        call    Draw_String
        
        ld      hl,saved_flag
        set     7,(hl)
        
        ld      hl,WAIT_RESET
        ld      (wait_count),hl
restore_fail_loop:
        call    timer_wait
        ld      hl,(wait_count)
        inc     hl
        ld      (wait_count),hl
        ld      a,h
        or      l
        ld      c,1
        ret     z
        call    GET_KEY
        cp      skClear
        ret     z
        cp      skDel
        ret     z
        cp      skEnter
        ret     z
        cp      skSub
        jr      nz,restore_fail_loop
        ld      hl,saved_flag
        ld      (hl),0
        jp      no_saved_game
        
restore_fail_message:        
        .db     0,50
        .db     "Error restoring CMonster saved game",0
        .db     0,60
        .db     "Could not find level file:",0
        .db     0,100
        .db     "Press - to erase saved game and continue",0
        .db     0,110
        .db     "Press ENTER to exit",0
        .db     -1
        
built_in_message:
        .db     "Built-in",0