;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Chest Routines                                                ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; checkChests - Check to see if player can open a chest
;   input:  none
;   output: none
;------------------------------------------------
checkChests:
        ld      a,(playerDir)
        or      a
        ret     nz                              ; If player not facing up, can't open a chest
        ld      a,(playerOffset)
        sub     COLS
        ld      c,a                             ; C = Offset in map
        ld      b,100                           ; B = # chest entries to check
        ld      hl,chests
checkChestsLoop:
        ld      a,(mapNo)
        cp      (hl)                            ; Check map number
        jr      nz,notOpeningChest1
        inc     hl
        ld      a,c
        cp      (hl)                            ; Check offset
        jr      nz,notOpeningChest2
        inc     hl
        pop     de                              ; Remove now-redundant stack data
        ld      e,(hl)
        dec     hl
        dec     hl
        call    openChest
        call    updateItems
        ld      hl,map
        ld      (__changeListPtr),hl
        call    executeChangeList
        jp      mainLoop
notOpeningChest1:
        inc     hl
notOpeningChest2:
        inc     hl
        inc     hl
        djnz    checkChestsLoop
        ret

;------------------------------------------------
; openChest - Open a chest
;   input:  C = Offset to tile in map data
;           E = Chest item
;           HL => Chest entry
;   output: DE => Chest entry
;------------------------------------------------
openChest:
        push    hl
; Check for open chest animation thingy
        ld      b,0
        ld      hl,map
        add     hl,bc
        ld      a,(hl)
        cp      CHEST_CLOSED
        jr      nz,afterOpenChestAnim
        ld      a,(mapNo)
        ld      b,CHEST_OPEN
        push    de
        call    addToChangeList
        pop     de
afterOpenChestAnim:
; Find chest scripts to run
        ld      h,3
        ld      l,e
        mlt     hl
        ld      de,chestItems
        add     hl,de
        ld      de,(hl)
        ex      de,hl
        pop     de
        jp      (hl)

chestItems:
.dl     chestEmpty,chestBluntSword,chestSuperiorSword,chestLegendarySword,chestWoodenShield
.dl     chestIronShield,chestLightArmor,chestHeavyArmor,chestAquaBoots,chestWingedBoots
.dl     chestRingOfMight,chestRingOfThunder,chestHeartPiece,chestCrystal1,chestCrystal2
.dl     chestCrystal3,chestCrystal4,chestCrystal5,chestCrystal6,chestCrystal7
.dl     chestHeartContainer1,chestHeartContainer2,chestHeartContainer3,chest1000Gold,chest5000Gold
.dl     chest10000Gold,chestLifeRefill,chestWell

;------------------------------------------------
; All chest scripts follow
;   input:  C = Offset to tile in map data
;           DE => Chest entry
;   output: none
;------------------------------------------------
chestSuperiorSword:
        ld      a,1
        ld      bc,COST_SUPERIOR_SWORD
        ld      hl,superiorSword
        jr      chestBuyItem

chestLegendarySword:
        ld      a,2
        ld      bc,COST_LEGENDARY_SWORD
        ld      hl,legendarySword
        jr      chestBuyItem

chestIronShield:
        ld      a,4
        ld      bc,COST_IRON_SHIELD
        ld      hl,ironShield
        jr      chestBuyItem

chestLightArmor:
        ld      a,5
        ld      bc,COST_LIGHT_ARMOR
        ld      hl,lightArmor
        jr      chestBuyItem

chestHeavyArmor:
        ld      a,6
        ld      bc,COST_HEAVY_ARMOR
        ld      hl,heavyArmor
        jr      chestBuyItem

chestAquaBoots:
        ld      a,7
        ld      bc,COST_AQUA_BOOTS
        ld      hl,aquaBoots
        jr      chestBuyItem

chestWingedBoots:
        ld      a,8
        ld      bc,COST_WINGED_BOOTS
        ld      hl,wingedBoots
        jr      chestBuyItem

chestRingOfMight:
        ld      a,9
        ld      bc,COST_RING_OF_MIGHT
        ld      hl,ringOfMight
        jr      chestBuyItem

chestRingOfThunder:
        ld      a,10
        ld      bc,COST_RING_OF_THUNDER
        ld      hl,ringOfThunder
        jr      chestBuyItem

chestBuyItem:
        call    commonPurchaseCode
        ld      a,1
        ld      (hl),a
        ret

chestBluntSword:
        ld      a,255
        ld      (de),a
        xor     a
        call    textMessage
        ld      a,1
        ld      (bluntSword),a
        ret

chestWoodenShield:
        ld      a,255
        ld      (de),a
        ld      a,3
        call    textMessage
        ld      a,1
        ld      (woodenShield),a
        ret

chestHeartPiece:
        ld      a,255
        ld      (de),a
        ld      a,11
        call    textMessage
        ld      hl,heartPiece
        ld      a,(hl)
        or      a
        jr      nz,twoHeartPieces
        inc     (hl)
        ret
twoHeartPieces:
        ld      (hl),0
addHeartContainer:
        ld      hl,maxHearts
        inc     (hl)
        jp      healOneHeart

chestHeartContainer1:
        ld      a,13
        ld      bc,COST_HEART_CONTAINER_1
        call    commonPurchaseCode
        jr      addHeartContainer
chestHeartContainer2:
        ld      a,64
        ld      bc,COST_HEART_CONTAINER_2
        call    commonPurchaseCode
        jr      addHeartContainer
chestHeartContainer3:
        ld      a,65
        ld      bc,COST_HEART_CONTAINER_3
        call    commonPurchaseCode
        jr      addHeartContainer

chestLifeRefill:
        ld      a,255
        ld      (de),a
        ld      a,16
        call    textMessage
        ld      a,(maxHearts)
        ld      (hearts),a
        ld      a,INI_HEART_LEVEL
        ld      (heartLevel),a
        ret

chestWell:
        ld      a,17
        call    textMessage
        ret     z
        ld      bc,COST_WELL
        ld      a,19
        call    tryPurchaseItem
        ret     c
        ld      a,(maxHearts)
        ld      (hearts),a
        ld      a,INI_HEART_LEVEL
        ld      (heartLevel),a
        ret

chestCrystal1:
        ld      hl,crystals
        jr      chestCrystal
chestCrystal2:
        ld      hl,crystals+1
        jr      chestCrystal
chestCrystal3:
        ld      hl,crystals+2
        jr      chestCrystal
chestCrystal4:
        ld      hl,crystals+3
        jr      chestCrystal
chestCrystal5:
        ld      hl,crystals+4
        jr      chestCrystal
chestCrystal6:
        ld      hl,crystals+5
        jr      chestCrystal
chestCrystal7:
        ld      hl,crystals+6

chestCrystal:
        ld      (hl),1
        ld      a,255
        ld      (de),a
; Check if player has all 7 crystals
        ld      hl,crystals                     ; HL => Start of crystal data
        xor     a                               ; Continue until we find an empty crystal slot
        ld      b,7                             ; 7 crystals to check
checkCrystalsLoop:
        add     a,(hl)                          ; If we have this crystal, add 1 to A
        inc     hl                              ; HL => Next crystal
        djnz    checkCrystalsLoop               ; Loop
        cp      7                               ; Do we have 7 crystals?
        jr      nz,after7Crystals               ; If not, player still hasn't gotten all 7 crystals
        ; add entries to change list to turn on portal from Ancient Chamber to Hell
        ld      a,218
        ld      bc,PORTAL_1*256+39
        call    addToChangeList
        ld      a,218
        ld      bc,PORTAL_1*256+40
        call    addToChangeList
        ld      a,218
        ld      bc,PORTAL_1*256+55
        call    addToChangeList
        ld      a,218
        ld      bc,PORTAL_1*256+56
        call    addToChangeList
after7Crystals:
        ld      a,12
        jp      textMessage

chest1000gold:
        ld      b,14
        ld      hl,1000
        jr      chestGold
chest5000gold:
        ld      b,15
        ld      hl,5000
        jr      chestGold
chest10000gold:
        ld      b,63
        ld      hl,10000

chestGold:
        ld      a,255
        ld      (de),a
        call    addGold
        ld      a,b
        jp      textMessage

chestEmpty:
        ld      a,18
        jp      textMessage

;------------------------------------------------
; tryPurchaseItem - Try to purchase an item
;   input:  A = Text message to show if item can't be purchased
;           BC = Cost of item
;   output: CA = 1 if item couldn't be purchased
;------------------------------------------------
tryPurchaseItem:
        ld      hl,(gold)
        or      a
        sbc     hl,bc
        jr      c,cantPurchaseItem
        ld      (gold),hl
        ret
cantPurchaseItem:
        call    textMessage
        scf
        ret

;------------------------------------------------
; commonPurchaseCode - Common set of code used in some of the chest scripts
;   input:  BC = Cost of item
;           DE => Chest entry
;           HL = Misc data
;   output: DE => (Chest entry +2)
;           HL = Misc data
;------------------------------------------------
commonPurchaseCode:
        push    bc
        push    de
        push    hl
        call    textMessage
        pop     hl
        pop     de
        pop     bc
        jr      z,dontPurchase
        push    hl
        ld      a,19
        call    tryPurchaseItem
        pop     hl
        jr      c,dontPurchase
        xor     a                               ; set chest to "nothing left to sell"
        inc     de
        inc     de
        ld      (de),a
        ret
dontPurchase:
        pop     bc
        ret

.end
