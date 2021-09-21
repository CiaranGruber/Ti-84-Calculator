;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Change List Routines                                          ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; clearChangeList - Clear changeList
;   input:  none
;   output: none
;------------------------------------------------
clearChangeList:
        ld      hl,changeList
        ld      bc,MAX_CHANGES*3
clearChangeListLoop:
        ld      (hl),255
        inc     hl
        dec     bc
        ld      a,b
        or      c
        jr      nz,clearChangeListLoop
        ret

;------------------------------------------------
; addToChangeList - Add an entry to changeList
;   input:  A = Map
;           B = Tile
;           C = Offset
;   output: none
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
;   input:  none
;   output: none
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
__changeListPtr         = $+1
        ld      hl,$000000
        add     hl,de
        ld      (hl),a
        pop     hl
afterDoneChangeListEntry:
        inc     hl
        inc     hl
        djnz    executeChangeListLoop
        ret

.end
