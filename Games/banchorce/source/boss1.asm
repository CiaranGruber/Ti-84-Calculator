;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; King Heath Boss Routines                                      ;
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
        ld      b,0
        ld      ix,doHeath
        ld      de,drawHeath
        ld      hl,finishedHeath
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

        ld      a,(dx)                          ; A = Demon X pos
        add     a,4
        ld      c,a                             ; save it to C
        ld      hl,x                            ; HL => Player X pos
        ; if player x and boss x are close enough, start the charge
        sub     (hl)
        jr      z,startHeathDown
        inc     a
        jr      z,startHeathDown
        sub     2
        jr      z,startHeathDown
        ; otherwise, work out if should be moving left or right
        ld      a,c
        cp      (hl)
        jr      c,moveHeathRight                ; If (Demon X pos + 4) less than Player X pos, try to move right
        cp      8+4                             ; check if can move left any more
        ret     z
        sub     5                               ; -4 for actual Demon X, then -1 to move left 1
        ld      (dx),a
        ret
moveHeathRight:
        cp      (COLS*8)-16-8+4                 ; check if can move right any more
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
        ld      (dFlags),a                      ; Save flags
        ret                                     ; Leave now, next time demon will move horizontally
moveHeathDown:
        inc     (hl)                            ; Increment demon Y pos to move down
        inc     (hl)                            ; Do it twice to move fast!
        ld      a,(hl)
        cp      (ROWS*8)-16                     ; Check if at bottom of screen
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
        ld      hl,sprBoss3
        ld      a,(frame)
        bit     3,a
        jp      z,drawBoss
        ld      hl,sprBoss4
        jp      drawBoss
drawHeathNotAttacking:
        ld      hl,sprBoss1
        ld      a,(frame)
        bit     4,a
        jp      z,drawBoss
        ld      hl,sprBoss2
        jp      drawBoss

;------------------------------------------------
; Finished
;------------------------------------------------
finishedHeath:
        ld      a,23                            ; A = map to warp to
        ld      bc,104*256+48                   ; B = x pos, C = y pos to warp to
        ld      de,HEATH_GOLD                   ; DE = gold to give player
        ld      ix,heathChangeList              ; IX => change list entries to add
        ret

;------------------------------------------------
; dFlags settings
;------------------------------------------------
; bit 0 -> Z = moving horizontally, NZ = vertically
; bit 1 -> Z = moving down, NZ = moving up

.end
