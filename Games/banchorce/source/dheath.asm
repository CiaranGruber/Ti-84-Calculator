;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; King Heath Demon Routines                                     ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; Initialisation
;------------------------------------------------
iniHeath:
        ld      hl,INI_HEATH_HEALTH
        ld      (dHealth),hl
        ld      hl,INI_HEATH_YX
        ld      (dy),hl
        ld      a,HEATH_DAMAGE
        ld      bc,doHeath
        ld      de,drawHeath
        ld      hl,finishedHeath
        ld      ix,0
        ret

;------------------------------------------------
; Implementation
;------------------------------------------------
doHeath:
        ld      a,(frame)
        bit     0,a
        ret     nz                              ; Only move every 2nd frame

        ld      a,(dFlags)
        bit     0,a                             ; Check if moving either horizontally or vertically
        jr      nz,heathUpDown                  ; If NZ, moving vertically

        ld      hl,dCnt
        inc     (hl)                            ; Increment demon counter
        ld      a,(hl)
__heathHorizLimit                       = $+1
        cp      $10                             ; Check to see if ready to move down screen
        jr      nc,startHeathDown               ; If so, set up for it
        ld      a,(dx)                          ; A = Demon X pos
        add     a,4
        ld      hl,x                            ; HL => Player X pos
        cp      (hl)                            ; Compare them
        ret     z
        jr      c,moveHeathRight                ; If (Demon X pos + 4) less than Player X pos, try to move right
        cp      16+8+4                          ; Check if can move left any more
        ret     z
        sub     5                               ; -4 for actual Demon X, then -1 to move left 1
        ld      (dx),a
        ret
moveHeathRight:
        cp      128-16-16-8+4                   ; Check if can move right any more
        ret     z
        sub     3                               ; -4 for actual Demon X, then +1 to move right 1
        ld      (dx),a
        ret

startHeathDown:
        ld      a,%00000001                     ; New flags value
        ld      (dFlags),a                      ; Save for next time
        ret

heathUpDown:
        ld      hl,dy                           ; HL => Demon Y pos
        bit     1,a                             ; Check if moving either up or down
        jr      z,moveHeathDown                 ; If Z, moving down
        dec     (hl)                            ; Decrement demon Y pos to move up
        ld      a,(hl)
        cp      8                               ; Check if at top of screen
        ret     nz                              ; If not, leave for now
        xor     a                               ; Otherwise prepare to move horizontally again next time
        ld      (dCnt),a                        ; Reset counter
        ld      (dFlags),a                      ; Save flags
        ld      b,8
        call    random                          ; 0 <= A < 8
        add     a,12                            ; 12 <= A < 20
        ld      (__heathHorizLimit),a            ; Save new limit for how much to move horizontally next time
        ret                                     ; Leave now, next time demon will move horizontally
moveHeathDown:
        inc     (hl)                            ; Increment demon Y pos to move down
        inc     (hl)                            ; Do it twice to move fast!
        ld      a,(hl)
        cp      48                              ; Check if at bottom of screen
        ret     nz                              ; If not, leave for now
        ld      a,%00000011                     ; Next time, move up
        ld      (dFlags),a                      ; Save flags
        ret

;------------------------------------------------
; Graphics
;------------------------------------------------
drawHeath:
        ld      a,(dFlags)                      ; Get flags
        bit     0,a
        jr      z,drawHeathNotAttacking         ; If moving horizontally, draw not attacking
        bit     1,a
        jr      nz,drawHeathNotAttacking        ; If moving up, draw not attacking
        ld      hl,sprHeath3
        jp      drawDemon
drawHeathNotAttacking:
        ld      hl,sprHeath1
        ld      a,(frame)
        bit     4,a
        jp      z,drawDemon
        ld      hl,sprHeath2
        jp      drawDemon

;------------------------------------------------
; Finished
;------------------------------------------------
finishedHeath:
        ld      bc,104*256+48
        ld      de,HEATH_GOLD
        ld      ix,heathChangeList
        ld      a,23
        ret

;------------------------------------------------
; dFlags settings
;------------------------------------------------
; bit 0 -> Z = moving horizontally, NZ = vertically
; bit 1 -> Z = moving down, NZ = moving up

.end
