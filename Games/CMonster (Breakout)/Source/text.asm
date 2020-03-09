;############## CMonster by Patrick Davidson - text rendering routines

;####### Display a string
; HL -> Null-terminated string
; B = X coordinate / 2
; C = Y coordinate

Draw_String:
        ld      a,(hl)
        or      a
        ret     z
        inc     hl
        push    bc
        push    hl
to_draw_char:
        call    Draw_Char
        pop     hl
        pop     bc
        inc     b
        inc     b
        inc     b
        inc     b
        jr      Draw_String

;####### Display a single character

Draw_Char:
        sub     32
        add     a,a

#ifdef  TI84PCE
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
        add     hl,hl
        add     hl,hl                   ; HL = 640 * Y + 4 * X
        
        ld      de,$D40000
        add     hl,de
        
        pop     de
        
        ld      c,8
outer_char_loop:
        ld      a,(de)
        inc     de
        call    Draw_Char_Line
        dec     c
        jr      nz,outer_char_loop
        ret
        
Draw_Char_Line:
        ld      b,8
inner_char_loop:
        rlca
        jr      c,char_black
        ld      (hl),-1
        inc     hl
        ld      (hl),-1
        inc     hl
        djnz    inner_char_loop
        push    de
        ld      de,(320-8)*2
        add     hl,de
        pop     de
        ret     

char_black:
        ld      (hl),0
        inc     hl
        ld      (hl),0
        inc     hl
        djnz    inner_char_loop
        push    de
        ld      de,(320-8)*2
        add     hl,de
        pop     de
        ret
#else
        ld      e,a
        ld      d,0
        ld      hl,tileData
        add     hl,de   
        add     hl,de
        add     hl,de
        add     hl,de

        push    hl
        ld      de,string_size
        ld      l,c
        call    Set_Sprite_Boundary
        pop     hl
        
        ld      c,$11   
        ld      e,8
outer_char_loop:
        ld      a,(hl)
        inc     hl
        call    Draw_Char_Line
        dec     e
        jr      nz,outer_char_loop
        ret
        
string_size:
        .db     7
        
Draw_Char_Line:
        ld      b,8
inner_char_loop:
        ld      d,-1
        rlca
        jr      nc,char_black
        ld      d,0
char_black:
        out     (c),d
        out     (c),d
        djnz    inner_char_loop
        ret        
#endif
        
;###### Display multiple strings
; HL points to list of X, Y, string, X, Y, string, ...., -1

Draw_Strings:
        ld      a,(hl)
        cp      -1
        ret     z
        ld      b,a
        inc     hl
        ld      c,(hl)
        inc     hl
        call    Draw_String
        inc     hl
        jr      Draw_Strings
        
Decode_A_DE_3:
        ld      l,a
        ld      h,0
        bcall(_DivHLBy10)
        add     a,'0'
        ld      (de),a
        dec     de
        ld      a,l
Decode_A_DE:
        ld      l,a
        ld      h,0
        bcall(_DivHLBy10)
        add     a,'0'
        ld      (de),a
        ld      a,l
        add     a,'0'
        dec     de
        ld      (de),a
        ret