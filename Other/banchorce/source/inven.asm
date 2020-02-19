;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Inventory Screen Routines                                     ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; showInventoryScreen - Show the inventory screen
;
; Input:    None
; Output:   None
;------------------------------------------------
showInventoryScreen:
        ld      hl,invenMap
        call    grayDrawTileMap

        ld      de,37*256+34                    ; HL = New cursor coords
        ld      hl,strGold                      ; HL => String
        call    putString                       ; Write "GOLD:"
        ld      b,5                             ; B = Number of characters to show
        ld      de,44*256+38                    ; DE = New cursor coords
        ld      hl,(gold)                       ; HL = Gold
        call    showHL                          ; Show gold

        call    copyBuffers

; Draw hearts
        ld      a,(maxHearts)
        ld      b,a
        ld      c,1
        ld      hl,heartTable
drawHearts:
        push    bc
        ld      de,sprFullHeart
        ld      a,(hearts)
        cp      c
        jr      nc,drawHeart
        ld      de,sprEmptyHeart
drawHeart:
        ld      b,(hl)
        inc     hl
        ld      c,(hl)
        inc     hl
        push    hl
        ex      de,hl
        call    graySprite
        pop     hl
        pop     bc
        inc     c
        djnz    drawHearts

; Draw other items
        ld      b,NUM_ITEMS
        ld      de,items
        ld      hl,itemCoords
        ld      ix,sprBluntSword
drawItems:
        push    bc
        ld      a,(de)
        or      a
        jr      z,afterPutItem
        push    de
        push    hl
        ld      b,(hl)
        inc     hl
        ld      c,(hl)
        push    ix
        push    ix
        pop     hl
        call    GraySprite
        pop     ix
        pop     hl
        pop     de
afterPutItem:
        inc     hl
        inc     hl
        inc     de
        ld      bc,24
        add     ix,bc
        pop     bc
        djnz    drawItems

        call    showGray
invenKeyLoop:
        call    waitKey
        cp      GK_2ND
        jr      z,invenDone
        cp      GK_ENTER
        jr      nz,invenKeyLoop
invenDone:
        call    grayDrawMap
        jp      mainLoop

;------------------------------------------------
; updateItems - Update code to suit what items player has
;
; Input:    None
; Output:   None
;------------------------------------------------
updateItems:
; First, check sword strength
        ld      a,(legendarySword)
        ld      b,SWORD_L_STR
        or      a
        jr      nz,setAttackStrength
        ld      a,(superiorSword)
        ld      b,SWORD_S_STR
        or      a
        jr      nz,setAttackStrength
        ld      b,SWORD_B_STR
setAttackStrength:
        ld      a,b
        ld      (attackStrength),a
; Next, check what player can walk over
        ld      a,(wingedBoots)
        or      a
        jr      z,checkAquaBoots
        ld      a,CANT_WALK_OVER
        ld      (__canWalkOver),a
        ret
checkAquaBoots:
        ld      a,(aquaBoots)
        or      a
        jr      z,noWalkOverItems
        ld      a,NEED_WINGED
        ld      (__canWalkOver),a
        ret
noWalkOverItems:
        ld      a,NEED_AQUA
        ld      (__canWalkOver),a
        ret

.end
