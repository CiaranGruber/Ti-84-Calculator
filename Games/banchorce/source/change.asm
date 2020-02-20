;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Change List Routines                                          ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; clearChangeList - Clear changeList
;
; Input:    None
; Output:   None
;------------------------------------------------
clearChangeList:
        ld      hl,changeList
        ld      b,MAX_CHANGES*3
clearChangeListLoop:
        ld      (hl),255
        inc     hl
        djnz    clearChangeListLoop
        ret

;------------------------------------------------
; addToChangeList - Add an entry to changeList
;
; Input:    A = Map
;           B = Tile
;           C = Offset
; Output:   None
;------------------------------------------------
addToChangeList:
        ld      e,a                             ; E = Map
        ld      d,b                             ; D = Tile
        ld      hl,changeList
        ld      b,MAX_CHANGES
findChangeListEntry:
        ld      a,(hl)
        inc     a
        jr      z,changeListEntryFound
        inc     hl
        inc     hl
        inc     hl
        djnz    findChangeListEntry
        ret
changeListEntryFound:
        ld      (hl),e
        inc     hl
        ld      (hl),c
        inc     hl
        ld      (hl),d
        ret

;------------------------------------------------
; executeChangeList - Run the change list
;
; Input:    None
; Output:   None
;------------------------------------------------
executeChangeList:
        ld      a,(mapNo)
        ld      c,a
        ld      hl,changeList
        ld      b,MAX_CHANGES
        ld      de,0
executeChangeListLoop:
        ld      a,(hl)
        inc     hl
        cp      c
        jr      nz,afterDoneChangeListEntry
        push    hl
        ld      e,(hl)
        inc     hl
        ld      a,(hl)
        ld      hl,map
        add     hl,de
        ld      (hl),a
        pop     hl
afterDoneChangeListEntry:
        inc     hl
        inc     hl
        djnz    executeChangeListLoop
        ret

.end
