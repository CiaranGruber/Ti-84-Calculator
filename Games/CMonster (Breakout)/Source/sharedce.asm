GET_KEY:
        push    hl
        push    de
        push    bc
        di
        ld      hl,$F50004
        ld      (hl),8
        inc     hl
        ld      (hl),8
        ld      l,0
        ld      (hl),2
        xor     a
wait_for_keys:
        cp      (hl)
        jr      nz,wait_for_keys
        
        ld      e,0                     ; E = GET_KEY result
        ld      d,e                     ; D = current key counter
        ld      hl,getkeylastdata
        ld      bc,$F5001E              ; pointer to key input data
        
scan_next_row:
        ld      a,(bc)                  ; A = one row of key data
        
        push    bc
        ld      c,(hl)                  ; C = previous scan results
        ld      (hl),a                  ; save the new results
        inc     hl
        
        cpl                             ; bits set to 0 for pressed keys
        or      c                       ; now 0 for newly pressed only
        ld      b,8
scan_next_column:
        inc     d                       ; D = next char value
        rrca
        jr      c,key_not_pressed
        ld      e,d
key_not_pressed:
        djnz    scan_next_column
        
        pop     bc
        dec     bc
        dec     bc
        ld      a,c                     
        cp      $10                      ; check if at port $F50010
        jr      nz,scan_next_row         ; if so, done
        
        ei
        ld      a,e
        pop     bc
        pop     de
        pop     hl
        ret
        
;############## Timer handling

timer_wait:
#ifdef  TIME_INDICATOR
        ld      a,($F20001)
        or      a
        jr      nz,timer_loop
        ld      hl,score
        inc     (hl)
        ret
#endif
timer_loop:
        ld      a,($F20001)
        or      a
        jr      nz,timer_loop
timer_init:
        ld      hl,$F20030
        res     0,(hl)          ; disable timer
        set     1,(hl)          ; set frequency to 32768Hz
        res     2,(hl)          ; no interrupt
        inc     hl
        res     1,(hl)          ; count down
        ld      a,(delay_amount)
        ld      hl,2
        ld      ($F20004),hl
        ld      l,a
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl
        inc     h
        ld      ($F20000),hl    ; value to count down from
        xor     a
        ld      ($F20003),a
        ld      ($F20006),a
        ld      hl,$F20030
        set     0,(hl)          ; re-enable timer
        ret

;############## Clear the screen (in black, of course!)

Clear_Screen:   
        ld      hl,$D40000
        ld      (hl),0
        ld      de,$D40001
        ld      bc,320*240*2-1
        ldir
        ret
        
        .block  (256-($ & 255))
        
        ;       %RRRRRGGG,%GGGBBBBB
color_table:
        .db     %00000000,%00000000     ; 0 = black
        .db     %11111000,%00000000     ; 1 = red
        .db     %11000110,%00011000     ; 2 = light gray
        .db     %11111111,%11111111     ; 3 = white
        .db     %11111100,%11111111     ; 4 = bright purple 
        
Clear_Below_Tiles:
        ld      hl,$D40000+(320*128*2)
        ld      de,$D40001+(320*128*2)
        ld      (hl),0
        ld      bc,320*104*2-1
        ldir
        ret     