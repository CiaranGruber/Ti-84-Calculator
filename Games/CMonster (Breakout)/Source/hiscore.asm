;############# CMonster by Patrick Davidson - high scores

win_message:
        .db     "YOU WIN!",0
lose_message:
        .db     "GAME OVER",0
view_message:
        .db     "All-Time High Scores",0
no_message:
        .db     "You don't have a high score",0
yes_message:
        .db     "You have a high score!  Enter your name:",0       
hs_instructions:
        .db     "Press ALPHA to switch upper/lower/digits",0
       
;############# Show final score and check for high score
        
check_highscore:
#ifdef  TI84CE
        di
        ld      a,(hl)
        push    hl
        call    Clear_Screen
        
        ld      hl,win_image
        cp      'Y'
        jr      z,chs_won
        ld      hl,lose_image
chs_won:             
        ld	a,$25
	ld	($E30018),a                     ; set to 16 color mode
        
        ld      de,$D60000
        ld      bc,256*16
        ldir                  

        ld      hl,Draw_Char_16
        ld      (to_draw_char+1),hl
        ld      hl,PRGM_continue
        ld      bc,0
        call    Draw_String
        ld      hl,Draw_Char
        ld      (to_draw_char+1),hl
        
        ld      hl,zoom_code                    ; copy and run main code
        ld      de,$E30200
        ld      bc,512
        ldir
        call    $E30200
        
        ld	a,$2D                           ; back to 65536 color mode    
	ld	($E30018),a
        pop     hl
        ei
        call    GET_KEY
        call    GET_KEY
#endif        
        
        push    hl
        ld      a,(lives)
        or      a
        jr      z,no_lives_bonus
        ld      b,a
        ld      a,'1'
        ld      (score_increment+3),a
        ld      a,(hard_flag)
        or      a
        jr      z,loop_bonus
        sla     b
loop_bonus:
        push    bc
        ld      hl,score+4              ; and increment the score
        ld      de,score_increment+4
        ld      b,4
        call    loop_add_nocarry
        pop     bc
        djnz    loop_bonus
no_lives_bonus:
        
        ld      hl,score
#ifdef  TIME_INDICATOR
        ld      (hl),'0'
#endif
        call    Clear_Screen
        pop     hl
        
        ld      bc,0
        call    Draw_String
        ld      hl,score
        ld      bc,256*4*(40-6)
        call    Draw_String
        
        ld      hl,last_score+NAME_LEN
        ld      de,score
        call    CP_SCORE
        jp      c,no_score
        
;############## Player has a high score, first fill in the bottom entry
        
        ld      hl,last_score
        ld      b,NAME_LEN
loop_space:
        ld      (hl),' '
        inc     hl
        djnz    loop_space
        ex      de,hl
        ld      hl,score
        ld      bc,SCORELEN
        ldir
        
;############## Bubble up the high score

        ld      b,SCORE_COUNT-1                 ; Bubble it towards the top
        ld      de,last_score+NAME_LEN          ; DE = score of entry to move
loop_bubble:                             
        ld      hl,-(ENTRYLEN)
        add     hl,de                           ; HL = score of previous item

        push    bc
        push    de
        call    CP_SCORE
        pop     de
        pop     bc

        jr      z,bubble_up
        jr      c,no_bubble_up
bubble_up:

        push    bc
        ld      hl,SCORELEN
        add     hl,de
        ex      de,hl                           ; DE = last byte of new entry
        ld      hl,-(ENTRYLEN)
        add     hl,de                           ; HL = last byte of previous
        ld      b,0+ENTRYLEN
loop_exchange:
        ld      a,(de)
        ld      c,a
        ld      a,(hl)
        ld      (de),a
        ld      (hl),c
        dec     hl
        dec     de                              
        djnz    loop_exchange                   
        pop     bc                              ; DE = last byte of new
        ld      hl,-(SCORELEN)
        add     hl,de
        ex      de,hl                           ; DE = score of new position

        djnz    loop_bubble

no_bubble_up:

;############## Bubbling is done, show the table

        ld      hl,-NAME_LEN
        add     hl,de                           ; HL -> score entry position
        push    hl
        push    bc
        
        ld      hl,saved_flag
        set     1,(hl)
        ld      hl,yes_message
        ld      bc,20
        call    Draw_String
        ld      hl,hs_instructions
        ld      bc,30
        call    Draw_String
        call    show_scores_list
        
        pop     bc
        pop     ix
        
        call    input_name
        jp      show_highscores
        
;############## Show high score table if you didn't get a high score

no_score:
        ld      hl,no_message
        ld      bc,26*256+25
        call    Draw_String
        call    show_scores_and_wait

;############## Display high score table (from title screen)    

show_highscores:
        call    Clear_Screen
        ld      hl,view_message
        ld      bc,40*256
        call    Draw_String
        
show_scores_and_wait:
        call    show_scores_list
        
;############## Wait to exit table display

wait_key:
        call    GET_KEY
        ld      hl,0
wait_loop_hs:
        inc     hl
        ld      a,h
        or      l
        ret     z
        call    GET_KEY
        cp      skClear
        ret     z
        cp      skEnter
        jr      nz,wait_loop_hs
        ret
        
;############## Display list of high scores
        
show_scores_list:
        ld      bc,SCORE_COUNT*256+60
        ld      hl,high_scores
loop_show_highscore:
        push    bc
        ld      b,16
        call    Draw_String
        pop     bc
        ld      a,15
        add     a,c
        ld      c,a
        inc     hl
        djnz    loop_show_highscore
        ret
        
;############## Compares ASCII numbers
;
; HL ->number to subtract from other
; DE ->number
; B = number of bytes
;
; Returns with flags indicating comparison results.  Changes A, B, DE, HL.
; Zero set if equal, carry if HL > DE.

CP_SCORE:
        ld      b,6
CP_ASCII: 
cmpl:   ld      a,(de)
        cp      (hl)
        ret     nz
        inc     de
        inc     hl
        djnz    cmpl
        ret
        
;############## Prompt for name entry

input_name:
        ld      a,19
        ld      (delay_amount),a   
        xor     a
        ld      (score_inc),a                   ; used as input type
        
        ld      a,b
        add     a,a
        add     a,a
        add     a,a
        add     a,a
        sub     b                               ; A = 15 * row
        add     a,60
        ld      (Draw_Score_Char+2),a           ; store Y coordinate
        
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
        
        call    timer_wait
        ld      a,(wait_count)
        bit     6,a
        ld      a,' '
        jr      z,clear_cursor
        ld      a,(score_inc)
        add     a,127
clear_cursor:
        call    Draw_Score_Char
        
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
        cp      skAlpha
        jr      z,new_cursor
        ld      c,a
        ld      a,NAME_LEN-1
        cp      b
        jr      z,enter_name_loop
        
        ld      de,(score_inc)          ; select upper/lower/number chars
        ld      hl,chartable-10
        dec     e
        jr      nz,not_lower
        ld      hl,chartable_lower-10
not_lower:
        dec     e
        jr      nz,not_number
        ld      hl,chartable_number-10
not_number:

#ifdef  TI84CE
        ld      de,0
#else
        ld      d,0
#endif
        ld      e,c
        add     hl,de
        ld      a,(hl)
        ld      (ix),a
        call    Draw_Score_Char
        inc     b
        inc     ix
to_enter_name_loop:
        jr      enter_name_loop
backup: xor     a
        cp      b
        jr      z,enter_name_loop
        ld      a,' '
        call    Draw_Score_Char
        dec     b
        dec     ix
        ld      (ix),32
        ld      a,' '
        call    Draw_Score_Char
        jr      to_enter_name_loop
new_cursor:
        ld      hl,score_inc
        ld      a,(hl)
        inc     a
        cp      3
        jr      nz,no_cursor_restart
        xor     a
no_cursor_restart:
        ld      (hl),a
        jr      to_enter_name_loop

Draw_Score_Char:
        push    bc
        ld      c,0                             ;Y filled in by self modifying
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
        
chartable:
        .db     ":WRMH."
        .db     "..0VQLG!..ZUPKFC"
        .db     ". YTOJEBX.XSNIDA"
        .db     ".12345.."
        
chartable_lower:
        .db     ":wrmh."
        .db     "..0vqlg!..zupkfc"
        .db     ". ytojebx.xsnida"
        .db     ".12345.."

chartable_number:
        .db     ":+-/^."
        .db     "..369LG!..258KFC"
        .db     ".0147JEBX.>SNIDA"
        .db     ".12345.."
        
;############## Rotate/zoom special text rendering and data

#ifdef TI84CE     

Draw_Char_16:
        sub     32
        add     a,a

        ld      de,0
        ld      e,a
        ld      hl,tileData
        add     hl,de
        add     hl,de
        add     hl,de
        add     hl,de                   ; HL -> start of char
        push    hl
        
        ld      hl,0
        ld      e,c
        ld      l,c
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
        
        ld      de,$D40000
        add     hl,de
        
        pop     de
        
        ld      c,8
outer_char_loop_16:
        ld      a,(de)
        inc     de
        ld      b,4
inner_char_loop_16:
        ld      (hl),0
        rlca
        jr      c,inner_16_start_clear
        ld      (hl),8
inner_16_start_clear:
        rlca
        jr      c,inner_16_second_clear
        set     7,(hl)
inner_16_second_clear:
        inc     hl
        djnz    inner_char_loop_16
        push    de
        ld      de,160-4
        add     hl,de
        pop     de
        dec     c
        jr      nz,outer_char_loop_16
        ret
        
zoom_code:
#import zoom.bin

win_image:
#include        win.i

lose_image:
#include        lose.i

PRGM_continue:
        .db     "Press PRGM to continue",0

#endif