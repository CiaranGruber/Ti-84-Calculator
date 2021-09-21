;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; HUD routines                                                  ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; drawHud - draw the HUD
;   input:  A = __redrawHud value (will always be NZ)
;   output: none
;------------------------------------------------
drawHud:
        ; update __redrawHud
        dec     a
        ld      (__redrawHud),a

drawHudGameSelect:
        call    clearHud
        ; modify drawTile to start from top left of lcd
        xor     a
        ld      (__dtY),a
        ld      (__dtX),a
        
        ; draw hearts
        ld      bc,(hearts)                     ; C = hearts, B = max hearts
        ld      hl,heartTable
        dec     c
dhHearts:
        push    bc
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
__dhHeartC              = $
        or      a
        jr      nc,dhHeartY
__dhHeartY              = $+1
        ld      a,$00
        add     a,d
        ld      d,a
dhHeartY:
        push    hl
        ld      hl,sprEmptyHeart
        bit     7,c
        jr      nz,drawHeart                    ; if no more hearts, draw empty heart
        ld      hl,sprFullHeart
        ld      a,c
        or      a
        jr      nz,drawHeart                    ; if not last heart, draw full heart
        ld      a,(heartLevel)
        cp      (ONE_HEART/2)+1
        jr      nc,drawHeart                    ; if last heart more than half full, draw full heart
        ld      hl,sprHalfHeart                 ; draw half heart
drawHeart:
        call    drawTile
        pop     hl
        pop     bc
        dec     c
        djnz    dhHearts
        
        ; draw gold
        ld      a,COLOUR_BLACK
__dhGoldRect            = $+2
        ld      de,GOLD_TXT_Y*256+(GOLD_TXT_X/2)
        ld      bc,20*256+7
        call    fillRect
__dhGoldSpr             = $+2
        ld      de,GOLD_SPR_Y*256+GOLD_SPR_X
        ld      hl,sprGold
        call    drawTile
        ld      hl,(gold)
        ld      de,GOLD_TXT_X
__dhGoldTxt             = $+1
        ld      bc,5*256+GOLD_TXT_Y
        call    drawHL
        
        ; draw sword
        ld      hl,sprLegendarySword
        ld      a,(legendarySword)
        or      a
        jr      nz,drawSword
        ld      hl,sprSuperiorSword
        ld      a,(superiorSword)
        or      a
        jr      nz,drawSword
        ld      hl,sprBluntSword
        ld      a,(bluntSword)
        or      a
        jr      z,afterDrawSword
drawSword:
__dhSwordY              = $+2
        ld      de,SWORD_SPR_Y*256+SWORD_SPR_X
        call    drawTile
afterDrawSword:

        ; draw shield
        ld      hl,sprIronShield
        ld      a,(ironShield)
        or      a
        jr      nz,drawShield
        ld      hl,sprWoodenShield
        ld      a,(woodenShield)
        or      a
        jr      z,afterDrawShield
drawShield:
__dhShieldY             = $+2
        ld      de,SHIELD_SPR_Y*256+SHIELD_SPR_X
        call    drawTile
afterDrawShield:
        
        ; draw armor
        ld      hl,sprHeavyArmor
        ld      a,(heavyArmor)
        or      a
        jr      nz,drawArmor
        ld      hl,sprLightArmor
        ld      a,(lightArmor)
        or      a
        jr      z,afterDrawArmor
drawArmor:
__dhArmorY              = $+2
        ld      de,ARMOR_SPR_Y*256+ARMOR_SPR_X
        call    drawTile
afterDrawArmor:
        
        ; draw boots
        ld      hl,sprWingedBoots
        ld      a,(wingedBoots)
        or      a
        jr      nz,drawBoots
        ld      hl,sprAquaBoots
        ld      a,(aquaBoots)
        or      a
        jr      z,afterDrawBoots
drawBoots:
__dhBootsY              = $+2
        ld      de,BOOTS_SPR_Y*256+BOOTS_SPR_X
        call    drawTile
afterDrawBoots:
        
        ; draw ring
        ld      hl,sprRingOfThunder
        ld      a,(ringOfThunder)
        or      a
        jr      nz,drawRing
        ld      hl,sprRingOfMight
        ld      a,(ringOfMight)
        or      a
        jr      z,afterDrawRing
drawRing:
__dhRingY               = $+2
        ld      de,RING_SPR_Y*256+RING_SPR_X
        call    drawTile
afterDrawRing:

        ; draw heart piece
        ld      hl,sprHeartPiece
        ld      a,(heartPiece)
        or      a
        jr      nz,drawHeartPiece
        ld      a,COLOUR_BLACK
        ld      de,HEARTPIECE_SPR_Y*2*256+HEARTPIECE_SPR_X
        ld      bc,8*256+16
        call    fillRect
        jr      afterDrawHeartPiece
drawHeartPiece:
__dhHeartPieceY         = $+2
        ld      de,HEARTPIECE_SPR_Y*256+HEARTPIECE_SPR_X
        call    drawTile
afterDrawHeartPiece:

        ; draw crystals
        ld      b,NUM_CRYSTALS
        ld      de,crystals
        ld      hl,crystalTable
drawCrystals:
        push    bc
        push    de
        ld      a,(de)
        ld      b,a
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
__dhCrystalC            = $
        or      a
        jr      nc,dhCrystalY
__dhCrystalY            = $+1
        ld      a,$00
        add     a,d
        ld      d,a
dhCrystalY:
        push    hl
        ld      a,b
        or      a
        jr      z,afterDrawCrystal
        ld      hl,sprCrystal
        call    drawTile
afterDrawCrystal:
        pop     hl
        pop     de
        inc     de
        pop     bc
        djnz    drawCrystals
        
        ret

;------------------------------------------------
; clearHud - clear the HUD area at bottom of screen
;   input:  none
;   output: none
;   notes:  A preserved
;------------------------------------------------
clearHud:
        ld      hl,(pVbuf)
        ld      de,320*(240-16)
        ld      de,320*(240-16)
        add     hl,de
        ld      (hl),COLOUR_BLACK
        push    hl
        pop     de
        inc     de
        ld      bc,320*16-1
        ldir
        ret

.end
