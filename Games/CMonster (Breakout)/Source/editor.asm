;############## CMonster by Patrick Davidson - level editor

#define edit_b  map+9
#define edit_y  map+10
#define edit_x  map+11
#define e_name  map+30
#define e_len   map+39
#define e_max   map+47
#define e_chars map+48

level_editor:
#ifndef TI84CE
        ld      hl,editor_messages
        ld      de,plotSScreen
        ld      bc,editor_messages_end-editor_messages
        ldir
#define message_offset  plotSScreen-editor_messages
#else
#define message_offset  0
#endif
        ld      hl,new_file_message
        call    Select_External_Levels
        cp      skClear
        ret     z
        cp      skDel
        ret     z
        
;############## Move selected level to RAM (if not there already)

#ifndef TI84CE
        call    Full_Window
#endif
        ld      hl,map_name
        ld      a,(hl)
        or      a
        jr      z,new_level_file
        dec     hl
        ld      (hl),AppVarObj
        bcall(_Mov9ToOP1)
        bcall(_ChkFindSym)
#ifdef  TI84CE
        bcall(_ChkInRam)
#else
        ld      a,b
        or      a
#endif
        jr      z,to_level_file_ready   
        bcall(_Arc_Unarc)
        ld      hl,map_name-1
        bcall(_Mov9ToOP1)
        bcall(_ChkFindSym)    
        ld      (levels_pointer),de
to_level_file_ready:
        jp      level_file_ready
        
;############## Creating a new level file

new_level_file:
        ld      a,8                     ; prompt for file name
        ld      (e_max),a
        ld      hl,chartable_alpha-10
        ld      (e_chars),hl
        ld      hl,prompt_name_cue
        ld      ix,map_name
        call    new_level_prompt
        cp      skEnter
        ret     nz
        
        ld      hl,map_name             
        ld      a,(hl)
        or      a
        ret     z                       ; exit if name is blank
        dec     hl
        ld      a,AppVarObj             ; set type to appvar
        ld      (hl),a
        bcall(_Mov9ToOp1)               ; copy variable name to OP1
        
        bcall(_ChkFindSym)
        ld      de,error_exists
        jp      nc,show_error

        ld      a,2
        ld      (e_max),a
        ld      hl,chartable_num-10
        ld      (e_chars),hl
        ld      hl,prompt_size_cue
        ld      ix,e_len
        call    new_level_prompt
        cp      skEnter
        ret     nz
        
        ld      hl,e_len
        ld      a,(hl)
        or      a
        ret     z                       ; exit if size is blank
        sub     '0'                     ; first digit raw value
        inc     hl
        bit     5,(hl)                  ; zero if only one digit entered
        jr      z,new_length_finished
        add     a,a                     ; A = first digit * 2
        ld      b,a
        add     a,a
        add     a,a                     ; A = first digit * 8
        add     a,b                     ; A = first digit * 10
        add     a,(hl)                  ; add second digit
        sub     '0'                     ; adjust to raw value
new_length_finished:
        ld      (level_count),a
        add     a,a                     ; A = length * 2
#ifdef  TI84CE
        ld      hl,0
#else
        ld      h,0
#endif           
        ld      l,a                     ; HL = length * 2
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl                   ; HL = length * 64
        push    hl
        pop     de
        add     hl,hl
        add     hl,hl                   ; HL = length * 256
        add     hl,de                   ; HL = length * 320 (size of data)
        push    hl
        
        ld      de,8
        add     hl,de                   ; add 8 bytes for header field
        push    hl
        ld      e,25
        add     hl,de
        bcall(_EnoughMem)
        pop     hl
        ld      de,error_mem_create
        jp      c,pop_show_error
        bcall(_CreateAppVar)            ; create the level file
        ld      (levels_pointer),de
        inc     de
        inc     de
        ld      hl,level_identifier
        ld      bc,8
        ldir                            ; copy the initial signature
        
        pop     bc                      ; BC = size of data section
        push    de                      
        pop     hl                      ; HL -> start of data section
        inc     de
        dec     bc
        ld      (hl),0
        ldir                            ; clear out data section
        
;############## Set up editor display

level_file_ready:
        call    Clear_Screen
        ld      hl,(levels_pointer)
        ld      de,10
        add     hl,de
        ld      (map),hl
        ld      a,1
        ld      (level),a
        ld      (edit_b),a
        ld      bc,0
        ld      (edit_y),bc

level_size_ready:
        ld      a,(level_count)
        ld      de,editor_total + 2 + message_offset
        call    Decode_A_DE_3
        
;############## Redraw full map for editor

Redraw_Editor:
        ld      c,15
Draw_Map_Partial_editor:
	ld      b,19
loop_draw_board_editor:
	push	bc
	call	Draw_Brick_editor
	pop	bc
	dec     b
        jp      p,loop_draw_board_editor
        dec     c
        jp      p,Draw_Map_Partial_editor
        
        ld      a,(level)
        ld      de,editor_current + 2 + message_offset
        call    Decode_A_DE_3
        ld      hl,editor_messages + message_offset
        call    Draw_Strings

;############## Main editor loop
        
        ld      hl,WAIT_RESET
        ld      (wait_count),hl

level_editor_loop:        
        call    Draw_Editor_Cursor
        call    timer_wait
        ld      hl,(wait_count)
        inc     hl
        ld      (wait_count),hl
        ld      a,h
        or      l
        ld      c,1
        ret     z

        ld      bc,(edit_y)
        call    Draw_Brick_editor

        ld      de,17
        ld      a,(edit_b)
        call    Draw_Brick_ADE

        call    GET_KEY
        
        ld      hl,edit_x
        cp      skLeft
        jr      z,edit_left
        cp      skRight
        jr      z,edit_right
        dec     hl
        cp      skUp
        jr      z,edit_up
        cp      skDown
        jr      z,edit_down
        cp      sk2nd
        jr      z,place_brick
        cp      skDel
        jr      z,remove_brick
        dec     hl
        cp      skAdd
        jr      z,next_brick
        cp      skSub
        jr      z,prev_brick
        cp      skMul
        jr      z,next_color
        cp      skDiv
        jr      z,prev_color
        ld      hl,level
        cp      skRParen
        jr      z,next_level
        cp      skLParen
        jr      z,prev_level
        
        cp      skClear
        jr      nz,level_editor_loop
        ret

edit_left:
        ld      a,(hl)
        dec     (hl)
        or      a
        jr      nz,level_editor_loop
        ld      (hl),19
to_level_editor_loop:
        jr      level_editor_loop
        
edit_right:
        inc     (hl)
        ld      a,(hl)
        cp      20
        jr      nz,level_editor_loop
        ld      (hl),0
        jr      to_level_editor_loop
        
edit_up:
        ld      a,(hl)
        dec     a
        and     15
        ld      (hl),a
        jr      to_level_editor_loop

edit_down:
        ld      a,(hl)
        inc     a
        and     15
        ld      (hl),a
        jr      to_level_editor_loop
        
place_brick:
        call    Find_Current_Brick_Pointer
        ld      a,(edit_b)
        ld      (hl),a
        jr      to_level_editor_loop

remove_brick:
        call    Find_Current_Brick_Pointer
        ld      (hl),0
        jr      to_level_editor_loop   

next_brick:
        inc     (hl)
        jr      to_level_editor_loop
        
prev_brick:
        dec     (hl)
        jr      to_level_editor_loop

next_color:
        ld      a,(hl)
        add     a,16
        ld      (hl),a
        jr      to_level_editor_loop
        
prev_color:
        ld      a,(hl)
        add     a,-16
        ld      (hl),a
to_to_level_editor_loop:
        jr      to_level_editor_loop
        
prev_level:
        ld      a,(hl)
        dec     a
        jr      nz,no_jump_to_end
        
        ld      a,(level_count)
        ld      (hl),a
        ld      de,320
        ld      hl,(map)
jump_loop:
        add     hl,de
        dec     a
        jr      nz,jump_loop
        ld      (map),hl
        jr      jump_complete
        
no_jump_to_end:
        ld      (hl),a
jump_complete:
        ld      hl,(map)
        ld      de,-320
        add     hl,de
        ld      (map),hl
to_redraw_editor:
        jp      Redraw_Editor

next_level:
        ld      a,(level_count)
        cp      (hl)
        jr      z,try_to_enlarge
        inc     (hl)
        ld      hl,(map)
        ld      de,320
        add     hl,de
        ld      (map),hl
        jr      to_redraw_editor
        
try_to_enlarge:
#ifdef  TI84CE
        cp      204
        jr      z,to_to_level_editor_loop
#endif
        ld      hl,320
        bcall(_EnoughMem)
        jr      c,to_to_level_editor_loop
        
        ld      hl,level_count
        inc     (hl)
        ld      hl,level
        inc     (hl)

        ld      hl,(map)
        ld      de,320
        add     hl,de
        ld      (map),hl
        ex      de,hl
        ld      hl,320
        bcall(_InsertMem)
        
        push    de                      ; clear inserted space
        pop     hl
        ld      (hl),0
        inc     de
        ld      bc,319
        ldir
        
        ld      hl,(levels_pointer)
#ifdef  TI84CE
        ld      de,(hl)
#else
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
#endif
        ex      de,hl
        ld      bc,320
        add     hl,bc
        ex      de,hl
#ifdef  TI84CE
        ld      (hl),de
#else
        ld      (hl),d
        dec     hl
        ld      (hl),e
#endif
        
        jp      level_size_ready
        
;############## Draw editor cursor

Draw_Editor_Cursor:
#ifdef  TI84CE
        ld      bc,(edit_y)
        ld      a,c
        add     a,a
        add     a,a
        add     a,c             ; A = 5 * Y
        add     a,a
        ld      hl,0
        ld      l,a             ; HL = 10 * Y
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl           ; HL = 160 * Y
        
        ld      de,0
        ld      e,b
        add     hl,de           ; HL = 160 * Y + X

        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl           ; HL = 320 * 2 * 8 * Y + 32 * X
        
        ld      de,$D40A0D
        add     hl,de
                
        ld      de,(wait_count)
        ld      (hl),de
        ld      bc,640
        add     hl,bc
        ld      (hl),de
#else
        ld      a,(edit_x)
        add     a,a
        add     a,a
        add     a,a
        ld      l,a
        ld      h,0
        add     hl,hl           ; HL = pixel X coord
        ld      a,l
        add     a,7
        ld      l,a
        ld      a,$52           ; set minimum X
        call    Write_Display_Control
        ld      a,$21           ; set current X
        call    Write_Display_Control_C11
        inc     l
        ld      a,$53           ; set maximum X
        call    Write_Display_Control_C11
        ld      a,(edit_y)
        add     a,a
        add     a,a
        add     a,a             ; A = pixel Y coord
        add     a,3
        ld      l,a
        ld      a,$50           ; set minimum Y
        call    Write_Display_Control_C11
        ld      a,$20           ; set current Y
        call    Write_Display_Control_C11
        ld      a,$22
        out     ($10),a
        out     ($10),a
        ld      a,(wait_count)
        ld      b,8
loop_cursor_draw:
        out     ($11),a
        djnz    loop_cursor_draw
#endif       
        ret

;############## Find location of the brick within map data

Find_Current_Brick_Pointer:
        ld      bc,(edit_y)
Find_Brick_Pointer:
        ld      hl,(map)
#ifdef  TI84CE
        ld      de,0
#else
        ld      d,0
#endif         
        ld      a,c
        add     a,a
        add     a,a               
        add     a,c             ; A = 5 * Y
        add     a,a             ; A = 10 * Y          
        ld      e,a
        add     hl,de
        add     hl,de           ; HL -> map + 20 * Y (start of row)
        ld      e,b
        add     hl,de           ; HL -> relevant brick in map
        ret
       
;############## Redraw a brick for the editor

Draw_Brick_editor: 
        push    bc
        call    Find_Brick_Pointer
        ld      a,(hl)

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
        ld      (bonus_type),a
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
        push    de
        ld      de,(bonus_type)
        or      e
        pop     de
        ld      l,a
        outi
        outi

        ld      a,(de)
        rra
        rra
        rra
        and     %110
        push    de
        ld      de,(bonus_type)
        or      e
        pop     de
        ld      l,a
        outi
        outi
        
        ld      a,(de)
        rra
        and     %110
        push    de
        ld      de,(bonus_type)
        or      e
        pop     de
        ld      l,a
        outi
        outi
        
        ld      a,(de)
        add     a,a
        and     %110
        push    de
        ld      de,(bonus_type)
        or      e
        pop     de
        ld      l,a
        outi
        outi

        inc     de
        djnz    loop_draw_brick
#endif
        ret
        
;############## Name / length entry

new_level_prompt:
        push    hl
        call    Clear_Screen
        pop     hl
        
        ld      bc,0
        call    Draw_String
        
        push    ix
        pop     hl
        ld      a,(e_max)
        inc     a
loop_clear_prompt:
        ld      (hl),0
        inc     hl
        dec     a
        jr      nz,loop_clear_prompt
        
        ld      b,0                             ; B = X coordinate
        ld      hl,0
        ld      (wait_count),hl
enter_name_loop:
        ld      hl,(wait_count)
        inc     hl
        ld      (wait_count),hl
        ld      a,h
        or      l
        ret     z
        call    GET_KEY
        or      a
        jr      z,enter_name_loop
        cp      skDel
        jr      z,backup
        cp      skLeft
        jr      z,backup
        cp      skEnter
        ret     z
        cp      skClear
        ret     z
        ld      c,a
        ld      a,(e_max)
        cp      b
        jr      z,enter_name_loop
        ld      hl,(e_chars)
#ifdef  TI84CE
        ld      de,0
#else
        ld      d,0
#endif
        ld      e,c
        add     hl,de
        ld      a,(hl)
        cp      32
        jr      z,enter_name_loop
        ld      (ix),a
        call    Draw_Score_Char
        inc     b
        inc     ix
        jr      enter_name_loop
backup: xor     a
        cp      b
        jr      z,enter_name_loop
        dec     b
        dec     ix
        ld      (ix),0
        ld      a,32
        call    Draw_Score_Char
        jr      enter_name_loop

Draw_Score_Char:
        push    bc
        ld      c,10                             
        ld      d,a
        ld      a,b
        add     a,a
        add     a,a
        add     a,16
        ld      b,a
        ld      a,d
        call    Draw_Char
        pop     bc
        ret

pop_show_error:
        pop     hl
show_error:
        ex      de,hl        
        ld      bc,30
        call    Draw_String
        
        ld      hl,0
        ld      (wait_count),hl
error_loop:
        ld      hl,(wait_count)
        inc     hl
        ld      (wait_count),hl
        ld      a,h
        or      l
        ret     z
        call    GET_KEY
        or      a
        jr      z,error_loop
        cp      skDel
        ret     z
        cp      skClear
        ret     z
        jp      level_editor
        
chartable_alpha:
        .db     " WRMH "
        .db     "   VQLG   ZUPKFC"
        .db     "  YTOJEBX XSNIDA"
        .db     "        "

chartable_num:
        .db     "      "
        .db     "  369     258   "
        .db     " 0147           "
        .db     "        "
        
prompt_name_cue:
        .db     "Enter name for new level file:",0

prompt_size_cue:
        .db     "Enter number of levels (1-99):",0
        
;############## Editor messages

error_exists:
        .db     "File already exists",0
        
error_mem_create:
        .db     "Insufficient free RAM to create levels",0
editor_title:
        .db     "CMonster Level Editor",0
        
new_file_message:
        .db     "New file",0
        
editor_messages:
        .db     14,136
        .db     "< Selected brick",0
        
        .db     0,153
        .db     "Editing level "
editor_current:
        .db     "001 of "
editor_total:
        .db     "001",0
        
        .db     0,170
        .db     "CMonster editor by Patrick Davidson",0
        .db     0,180
        .db     "Arrow keys move cursor",0
        .db     0,190
        .db     "2ND places selected brick, DEL clears",0
        .db     0,200
        .db     "Press ( and ) to select levels",0
        .db     0,210
        .db     "Press + and - to select brick type ",0
        .db     0,220
        .db     "Press * and / to select brick color",0
        .db     0,230
        .db     "Press CLEAR to exit the editor",0
        .db     -1
editor_messages_end
        
request_name:
        .db     "Enter name of level file to create:",0
request_size:
        .db     "Enter number of levels:",0
        
        .db     -1