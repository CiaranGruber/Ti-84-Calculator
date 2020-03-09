        .org    $E30200
        
        ld      hl,sine_table
        ld      de,1000

;############## Advance rotate, calculate new deltax / deltay in texture

next_frame:  
        ld      a,2
        ld      ($F50000),a                     ; trigger keypad read
                
        push    de
        push    hl
        ld      a,l
        add     a,a
        add     a,l                             ; zooming 3x as fast as rotating
        ld      l,a
        ld      a,(hl)                          
        sra     a                               ; range -63 to 63
        add     a,105                           ; range 42 to 168
        ld      (Multiply_Zoom+1),a
        pop     hl
        
        ld      a,(hl)                          ; A = sine of horizontal angle
        inc     l
        push    hl                              ; push pointer into sine table
        call    Multiply_Zoom           
        push    hl
        add     hl,hl                           ; double for the column deltaY
        ld      (load_y_delta+1),hl
        call    Mul_HL_Neg_80                               
        ld      (line_y_coord+1),hl 
        pop     de                              ; also the inverse of row deltaX
        ld      hl,0
        xor     a
        sbc     hl,de
        ld      (line_x_delta+1),hl     
        pop     hl                              
        
        push    hl
        ld      a,l
        add     a,63                            ; cosine is sine of 90 degrees ahead
        ld      l,a
        ld      a,(hl)                          ; A = cosine horiz angle, sine vertical        
        call    Multiply_Zoom
        ld      (line_y_delta+1),hl
        add     hl,hl
        ld      (load_x_delta+1),hl
        call    Mul_HL_Neg_80                       
        ld      (line_X_coord+1),hl     

;############## Line loop, advances down one pixel per iteration
        
        ld      ix,$d40000+1600                 ; start of display       
next_line:        
        ld      bc,$D60000                      ; BC1 = source image pointer
               
line_y_coord:
        ld      hl,0
line_y_delta:
        ld      de,-3
        add     hl,de                           ; HL1 = Y coordinate
        ld      (line_y_coord+1),hl             
load_y_delta:
        ld      de,32                           ; DE1 = delta Y
        
        exx                                     ; switch to bank 2

line_x_coord:
        ld      hl,0
line_x_delta:
        ld      de,16
        add     hl,de                           ; HL2 = Y coordinate
        ld      (line_x_coord+1),hl             
load_x_delta:
        ld      de,32                           ; DE2 = delta              

;############## Inner loop, advances two double pixels per iteration
        
        ld      b,80                            ; B2 = loop counter
next_pixel:
        add     hl,de                           ; HL2 = new X coord
        ld      a,h                             ; A = X coord (discarding fraction)
        exx                                     ; switch to bank 1
        ld      c,a                             ; X coordinate becomes low byte of image address
        add     hl,de                           ; HL1 = new Y coord
        ld      a,h                             ; A = Y coord (discarding fraction)
        and     15
        ld      b,a                             ; Y coordinate becomes middle byte of address
        ld      a,(bc)                          ; read one double pixel from texture
        ld      (ix),a                          ; write one double pixel to display
        inc     ix
        exx                                     ; switch to bank 2
        add     hl,de                           ; HL2 = new X coord
        ld      a,h                             ; A = X coord (discarding fraction)
        exx                                     ; switch to bank 1
        ld      c,a                             ; X coordinate becomes low byte of image address
        add     hl,de                           ; HL1 = new Y coord
        ld      a,h                             ; A = Y coord (discarding fraction)
        and     15
        ld      b,a                             ; Y coordinate becomes middle byte of address
        ld      a,(bc)                          ; read one double pixel from texture
        ld      (ix),a                          ; write one double pixel to display
        inc     ix
        exx                                     ; switch to bank 2
        djnz    next_pixel

;############## Advance to next line
        
        ld      a,ixh                           
        cp      150
        jr      nz,next_line

;############## Advance to next frame and check for exit
        
        pop     hl
        pop     de
        ld      a,($F50018)
        bit     6,a                             ; check PRGM key 
        ret     nz
        dec     de
        ld      a,d
        or      e
        jp      nz,next_frame
        ret

;############## Multiply A by E, with A signed, sign extended result in HL, shifted right 6

Multiply_Zoom:
        ld      e,55
        
Mul_Signed_A_E_Shift:
        or      a
        jp      p,mul_positive
        neg
        call    mul_positive
        ex      de,hl
        xor     a
        ld      hl,0
        sbc     hl,de
        ret
        
mul_positive:
        ld      d,a
        mlt     de
        ld      hl,0
        ld      l,d
        ld      b,2
mul_loop:
        rl      e
        rl      l
        rl      h
        djnz    mul_loop
        ret
        
Mul_HL_Neg_80:        
        xor     a
        ex      de,hl
        ld      hl,0
        sbc     hl,de                           ; *-1
        add     hl,hl
        add     hl,hl                           ; *-4
        push    hl
        pop     de
        add     hl,hl
        add     hl,hl                           ; *-16
        add     hl,de                           ; *-20
        add     hl,hl
        add     hl,hl   
        ret

;############## Table of sines on 256 byte boundary

        .fill   $E30300-$

sine_table:
#include        sines.i