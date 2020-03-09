;############## Cmonster by Patrick Davidson - routines shared with editor               

;############## Keyboard input
        
GET_KEY:
        push    hl
        push    de
        push    bc
        ld      e,0                     ; E = GET_KEY result
        ld      hl,getkeylastdata       ; HL = ptr to last read's table
        ld      a,$fe                   ; A = key port mask
        ld      c,e                     ; C = key number counter
        
gkol:   out     (1),a                   ; select row to read
        rlca                            ; next row to read
        ld      b,20
key_wait:
        nop
        djnz    key_wait
        ld      b,8                         
        push    af
        ld      d,(hl)                  ; D = old mask
        in      a,(1)                   ; A = new mask
        ld      (hl),a
        
gkl:    inc     c                       ; increment current key number
        rrca
        jr      c,nokey                 ; not pressed now
        bit     0,d
        jr      z,nokey                 ; already pressed
        ld      e,c                     ; newly pressed
nokey:  rr      d
        djnz    gkl
        
        pop     af
        inc     hl
        cp      $7F                     ; final row not present
        jr      nz,gkol
        ld      a,e
        pop     bc
        pop     de
        pop     hl
        ret
        
;############## Clear the screen (in black, of course!)

Clear_Screen:   
        call    Full_Window
        
        ld      a,$20
        ld      hl,0            ; set write Y coordinate
        call    Write_Display_Control
        ld      a,$21           ; set write X coordinate
        call    Write_Display_Control
        
        ld      a,$22
        out     ($10),a
        out     ($10),a

        ld      bc,320*240*2/4
blank_loop:
        xor     a
        out     ($11),a
        out     ($11),a
        out     ($11),a
        out     ($11),a
        dec     bc
        ld      a,b
        or      c
        jr      nz,blank_loop
        ret
        
Full_Window:
        ld      a,$50           ; Set minimum Y
        ld      hl,0
        call    Write_Display_Control
        
        inc     a               ; Set maximum Y
        ld      l,239
        call    Write_Display_Control   
        
        ld      hl,0            ; Set minimum X
        inc     a
        call    Write_Display_Control
        
        inc     a               ; Set maximum X
        ld      hl,319  
        jp      Write_Display_Control
        
;############## Timer handling

timer_wait:
#ifdef  TIME_INDICATOR
        in      a,(4)
        bit     5,a
        jr      z,timer_loop
        ld      hl,score
        inc     (hl)
        ret
#endif
timer_loop: 
        in      a,(4)
        bit     5,a
        jr      z,timer_loop
timer_init:
        xor     a
        out     ($31),a
        ld      a,(delay_amount)
        out     ($32),a          ; restart timer
        ret