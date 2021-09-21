;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Player Routines                                               ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; playerUp - Move player up
;   input:  none
;   output: none
;------------------------------------------------
playerUp:
        xor     a
        ld      (playerDir),a
        ld      hl,y
        ld      a,(hl)
        or      a
        jp      z,upMap
#ifndef NO_CLIP
        ld      l,a
        ld      a,(x)
        inc     a
        call    checkTile
        ret     nc
        ld      hl,(y)
        ld      a,h
        add     a,6
        call    checkTile
        ret     nc
#endif
        ld      hl,y
        dec     (hl)
        ret

;------------------------------------------------
; playerDown - Move player down
;   input:  none
;   output: none
;------------------------------------------------
playerDown:
        ld      a,1
        ld      (playerDir),a
        ld      hl,y
        ld      a,(hl)
        cp      8*(ROWS-1)
        jp      z,downMap
#ifndef NO_CLIP
        add     a,7
        ld      l,a
        ld      a,(x)
        inc     a
        call    checkTile
        ret     nc
        ld      hl,(y)
        ld      a,l
        add     a,7
        ld      l,a
        ld      a,h
        add     a,6
        call    checkTile
        ret     nc
#endif
        ld      hl,y
        inc     (hl)
        ret

;------------------------------------------------
; playerLeft - Move player left
;   input:  none
;   output: none
;------------------------------------------------
playerLeft:
        ld      a,2
        ld      (playerDir),a
        ld      hl,x
        ld      a,(hl)
        or      a
        jp      z,leftMap
#ifndef NO_CLIP
        ld      hl,(y)
        inc     l
        call    checkTile
        ret     nc
        ld      hl,(y)
        ld      a,l
        add     a,6
        ld      l,a
        ld      a,h
        call    checkTile
        ret     nc
#endif
        ld      hl,x
        dec     (hl)
        ret

;------------------------------------------------
; playerRight - Move player right
;   input:  none
;   output: none
;------------------------------------------------
playerRight:
        ld      a,3
        ld      (playerDir),a
        ld      hl,x
        ld      a,(hl)
        cp      8*(COLS-1)
        jp      z,rightMap
#ifndef NO_CLIP
        ld      hl,(y)
        add     a,7
        inc     l
        call    checkTile
        ret     nc
        ld      hl,(y)
        ld      a,l
        add     a,6
        ld      l,a
        ld      a,h
        add     a,7
        call    checkTile
        ret     nc
#endif
        ld      hl,x
        inc     (hl)
        ret

;------------------------------------------------
; dPlayerUp - Move player up when fighting a demon
;   input:  none
;   output: none
;------------------------------------------------
dPlayerUp:
        xor     a
        ld      (playerDir),a
        ld      hl,y
        ld      a,(hl)
        cp      8
        ret     z
        dec     (hl)
        ret

;------------------------------------------------
; dPlayerDown - Move player down when fighting a demon
;   input:  none
;   output: none
;------------------------------------------------
dPlayerDown:
        ld      a,1
        ld      (playerDir),a
        ld      hl,y
        ld      a,(hl)
        cp      ROWS*8-8
        ret     z
        inc     (hl)
        ret

;------------------------------------------------
; dPlayerLeft - Move player left when fighting a demon
;   input:  none
;   output: none
;------------------------------------------------
dPlayerLeft:
        ld      a,2
        ld      (playerDir),a
        ld      hl,x
        ld      a,(hl)
        cp      8
        ret     z
        dec     (hl)
        ret

;------------------------------------------------
; dPlayerRight - Move player right when fighting a demon
;   input:  none
;   output: none
;------------------------------------------------
dPlayerRight:
        ld      a,3
        ld      (playerDir),a
        ld      hl,x
        ld      a,(hl)
        cp      COLS*8-16
        ret     z
        inc     (hl)
        ret

;------------------------------------------------
; checkTile - Check a tile to see if player can walk on it
;   input:  A = X
;           L = Y
;   output: HL => Tile
;           A = Tile
;           CA = Player can walk on it
;------------------------------------------------
checkTile:
        call    getTile
__canWalkOver                           = $+1
        cp      NEED_AQUA
        ret

;------------------------------------------------
; drawPlayer - Draw Rex
;   input:  none
;   output: none
;------------------------------------------------
drawPlayer:
        ld      de,0
        ld      bc,(y)
        ld      hl,(playerDir)
        ld      a,(attacking)
        or      a
        jr      z,drawPlayerNotAttacking
        inc     a
        jr      nz,drawPlayerAttacking
drawPlayerNotAttacking:
        ld      h,SPRITE_SIZE
        mlt     hl
        ld      e,l
        ld      a,(hurt)
        cp      INI_HURT
        jr      z,drawPlayerHurt
        ld      hl,sprPlayer1
        ld      a,(walkCnt)
        bit     2,a
        jr      z,drawPlayerNow
        ld      hl,sprPlayer2
drawPlayerNow:
        add     hl,de
        ld      e,b
        ld      d,c
        jp      drawSprite
drawPlayerAttacking:
        ld      h,SPRITE_SIZE*2
        mlt     hl
        ex      de,hl
        ld      hl,sprAttacking
        add     hl,de
        ld      e,b
        ld      d,c
        push    de
        push    hl
        call    drawSprite
        pop     hl
        ld      bc,SPRITE_SIZE
        add     hl,bc
        pop     de
        ld      a,(playerDir)
        ld      b,a
        ld      a,8
        bit     0,b
        jr      nz,drawPlayerAfterNeg
        neg
drawPlayerAfterNeg:
        bit     1,b
        jr      nz,dpaHorizontal
        add     a,d
        ld      d,a
        jp      drawSprite
dpaHorizontal:
        add     a,e
        ld      e,a
        jp      drawSprite
drawPlayerHurt:
        ld      hl,sprPlayerHurt
        jr      drawPlayerNow

;------------------------------------------------
; decPlayerHearts - Take away some of the player's hearts
;   input:  B = How many bits of heart to take
;   output: none
;------------------------------------------------
decPlayerHearts:
        REDRAW_HUD()
__decPlayerHearts       = $
        nop                                     ; will be set to SCF for Hard/Hell difficulty
        jr      nc,decPlayerHeartsLoop
        ld      a,b
        srl     a
        add     a,b
        ld      b,a                             ; damage x 1.5 on Hard/Hell
decPlayerHeartsLoop:
        ld      hl,heartLevel
        dec     (hl)
        jr      nz,endDecPlayerHearts
        ld      a,(hearts)
        or      a
        ret     z
        ld      (hl),INI_HEART_LEVEL
        ld      hl,hearts
        dec     (hl)
endDecPlayerHearts:
        djnz    decPlayerHeartsLoop
        ret

;------------------------------------------------
; healOneHeart - heal one heart for player
;   input:  none
;   output: none
;------------------------------------------------
healOneHeart:
        REDRAW_HUD()
        ld      hl,hearts
        ld      a,(maxHearts)
        cp      (hl)
        ret     z
        inc     (hl)
        ret

;------------------------------------------------
; healHalfHeart - heal half a heart for player
;   input:  none
;   output: none
;------------------------------------------------
healHalfHeart:
        REDRAW_HUD()
        ld      a,(heartLevel)
        add     a,ONE_HEART/2
        cp      ONE_HEART+1
        jr      c,healHalfHeartFinish
        ld      c,a
        ld      hl,hearts
        ld      a,(maxHearts)
        cp      (hl)
        jr      z,healHalfHeartMax
        inc     (hl)
        ld      a,c
        sub     ONE_HEART
healHalfHeartFinish:
        ld      (heartLevel),a
        ret
healHalfHeartMax:
        ld      a,ONE_HEART
        jr      healHalfHeartFinish

;------------------------------------------------
; addGold - Add to player's gold
;   input:  HL = Gold to add
;   output: none
;------------------------------------------------
addGold:
        REDRAW_HUD()
        ld      de,(gold)
        add     hl,de
        ld      (gold),hl
        ld      de,GOLD_MAX
        call    _cphlde
        ret     c
        ld      (gold),de
        ret

#ifdef GOLD_GIVE
goldGive:
        push    af
        ld      hl,2000
        call    addGold
        pop     af
        ret
#endif

;------------------------------------------------
; playerDead - Ouchie
;   input:  none
;   output: none
;------------------------------------------------
playerDead:
        xor     a
        ld      (hurt),a
        ld      (frame),a
        ; pause for a bit
        ld      bc,50000
        call    waitBC
        ; show explosion
        call    clearAnimTable
        ld      bc,(y)
        call    newAnim
        ld      b,8
playerExplode:
        push    bc
        call    drawMap
        ld      a,HUD_COUNT_MAX
        call    drawHud
        call    drawAnims
        call    vramFlip
        call    updateAnims
        ld      bc,15000
        call    waitBC
        pop     bc
        djnz    playerExplode
        ; pause again
        ld      bc,100000
        call    waitBC
        ; find map to revive player at (or if HELL difficulty, don't revive, it's game over!)
        ld      a,(difficulty)
        sub     3
        jp      z,gameOver
        inc     a
        jr      nz,normalRevive                 ; if EASY or NORMAL, revive at a well
        ; otherwise on HARD, revive either at Rex's house if the wooden shield has been obtained, or at the dungeon
        ld      a,(woodenShield)
        or      a
        jr      nz,reviveAtHouse
reviveAtDungeon:
        xor     a
        ld      hl,INI_YX_POS
        jr      setHardRevive
reviveAtHouse:
        ld      a,MAP_REX_HOUSE
        ld      hl,INI_YX_POS_REX_HOUSE
setHardRevive:
        ld      (mapNo),a
        ld      (enterMapCoords),hl
        jr      calcReviveHearts
normalRevive:
        ld      a,(mapNo)
        or a \ sbc hl,hl \ ld l,a
        ld      de,reviveMapTable
        inc     a                               ; map #255? if so, we're fighting a boss
        jr      nz,findReviveTable
        ld      a,(demon)
        dec     a
        LDHLA()
        ld      de,reviveBossTable
findReviveTable:
        add     hl,de
        ld      a,(hl)
        ld      (mapNo),a
        ld      hl,reviveRefTable-1
        ld      e,-1
findReviveCoords:
        inc     hl
        inc     e
        cp      (hl)
        jr      nz,findReviveCoords
        ld      d,3
        mlt     de
        ld      hl,reviveCoordsTable
        add     hl,de
        ld      hl,(hl)
        ld      (enterMapCoords),hl
calcReviveHearts:
        ld      a,1
        ld      (playerDir),a
        ld      a,(maxHearts)
        ld      b,INI_HEART_LEVEL
        srl     a
        jr      nc,setReviveHearts
        inc     a
        srl     b
setReviveHearts:
        ld      (hearts),a
        ld      a,b
        ld      (heartLevel),a
        ld      hl,(gold)
        push hl \ pop de
        call    _setAtoHLU
        ld      b,a
        ld      a,(difficulty)
        cp      2
        ld      a,b
        jr      nc,highGoldPenalty
        srl a \ rr d \ rr e
highGoldPenalty:
        srl a \ rr d \ rr e
        call    _setDEUtoA
        or      a
        sbc     hl,de                           ; lose 1/4 Gold (or 1/2 on HARD)
        ld      (gold),hl
        ld      a,TXT_DEAD
        call    textMessage
        call    fadeOut
        xor     a
        ld      (hurt),a
        ld      (attacking),a
        ld      (areaNum),a
        ld      (demon),a
        ld      hl,(enterMapCoords)
        ld      (y),hl                          ; Load Player X & Y coords
        call    loadStdGfx
        ld      de,map
        call    newMap
        call    drawMap
        call    vramFlip
        REDRAW_HUD()
        call    fadeIn
        jp      checkAreaName

;------------------------------------------------
; calculateDamage - Calculate damage to player according to armor player has (and difficulty)
;   input:  B = Full value
;   output: B = How much to hurt player
;------------------------------------------------
calculateDamage:
        ld      a,(difficulty)
        or      a
        jr      nz,calcArmorReduction
        srl     b
calcArmorReduction:
        ld      a,(lightArmor)
        or      a
        ret     z
        ld      a,(heavyArmor)
        or      a
        ld      a,b
        jr      nz,reduceDamageByHalf
reduceDamageByQuarter:
        srl     b
reduceDamageByHalf:
        srl     b
        sub     b
        ld      b,a
        ret

;------------------------------------------------
; tryAttacking - Try to attack
;   input:  HL => Where to RET to
;   output: none
;------------------------------------------------
tryAttacking:
        push    hl
        ld      a,(bluntSword)
        or      a
        ret     z
        ld      hl,attacking
        ld      a,(hl)
        or      a
        jr      nz,continueAttack
        ld      (hl),INI_ATTACK
        ret
continueAttack:
        inc     a
        ret     z
        dec     (hl)
        ret     nz
        dec     (hl)
        ret

;------------------------------------------------
; updateItems - Update code to suit what items player has
;   input:  none
;   output: none
;------------------------------------------------
updateItems:
        REDRAW_HUD()
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

;------------------------------------------------
; loadPlayerToCollide1 - Load player info into (collide1)
;   input:  none
;   output: none
;------------------------------------------------
loadPlayerToCollide1:
        ld      hl,collide1
        ld      bc,(y)
        ld      (hl),b
        inc     hl
        ld      (hl),8
        inc     hl
        ld      (hl),c
        inc     hl
        ld      (hl),8
        ret

;------------------------------------------------
; loadSwordToCollide1 - Load sword into (collide1)
;   input:  none
;   output: none
;------------------------------------------------
loadSwordToCollide1:
        ld      de,(playerDir)
        ld      d,2
        mlt     de
        ld      hl,swordCoords
        add     hl,de
        ld      de,collide1
        ex      de,hl
        ld      bc,(y)
        ld      a,(de)
        add     a,b
        ld      (hl),a
        inc     de
        inc     hl
        ld      (hl),3
        inc     hl
        ld      a,(de)
        add     a,c
        ld      (hl),a
        inc     hl
        ld      (hl),3
        ret

;------------------------------------------------
; clearOrbTable - clear orbTable
;   input:  none
;   output: none
;------------------------------------------------
clearOrbTable:
        ld      hl,orbTable
        ld      b,MAX_HEALTH_ORBS*ORB_ENTRY_SIZE
        jp      _ld_hl_bz

;------------------------------------------------
; drawOrbs - draw health orbs
;   input:  none
;   output: none
;------------------------------------------------
drawOrbs:
        ld      hl,orbTable
        ld      b,MAX_HEALTH_ORBS
drawOrbsLoop:
        push    hl
        push    bc
        ld      a,(hl)
        or      a
        jr      z,endDrawOrbsLoop
        inc     hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        ld      hl,sprOrb
        call    drawSprite
endDrawOrbsLoop:
        pop     bc
        pop     hl
        ld      de,ORB_ENTRY_SIZE
        add     hl,de
        djnz    drawOrbsLoop
        ret

;------------------------------------------------
; getEmptyOrbEntry - try to find an empty entry in orbTable
;   input:  none
;   output: HL => Start of entry (if one was found)
;           CA = 1 if no entry was empty
;------------------------------------------------
getEmptyOrbEntry:
        ld      hl,orbTable
        ld      b,MAX_HEALTH_ORBS
        ld      de,ORB_ENTRY_SIZE
findEmptyOrbEntry:
        ld      a,(hl)
        or      a
        ret     z
        add     hl,de
        djnz    findEmptyOrbEntry
        scf
        ret

.end
