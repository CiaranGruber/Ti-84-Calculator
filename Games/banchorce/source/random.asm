;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Random Routines                                               ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; random - Get a random number
;   author: Joe Wingbermuehle
;   input:  B = Upper limit + 1
;   output: A = 0 <= Random Number < B
;------------------------------------------------
random:
        push    hl
        push    de
        ld      hl,(randData)
        ld      a,r
        ld      d,a
        ld      e,(hl)
        add     hl,de
        add     a,l
        xor     h
        ld      (randData),hl
        sbc     hl,hl
        ld      e,a
        ld      d,h
randomLoop:
        add     hl,de
        djnz    randomLoop
        ld      a,h
        pop     de
        pop     hl
        ret

.end
