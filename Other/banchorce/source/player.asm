;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Player Routines                                               ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; playerUp - Move player up
;
; Input:    None
; Output:   None
;------------------------------------------------
playerUp:
        xor     a
        ld      (playerDir),a
        ld      hl,y
        ld      a,(hl)
        or      a
        jp      z,upMap
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
        ld      hl,y
        dec     (hl)
        ret

;------------------------------------------------
; playerDown - Move player down
;
; Input:    None
; Output:   None
;------------------------------------------------
playerDown:
        ld      a,1
        ld      (playerDir),a
        ld      hl,y
        ld      a,(hl)
        cp      7*8
        jp      z,downMap
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
        ld      hl,y
        inc     (hl)
        ret

;------------------------------------------------
; playerLeft - Move player left
;
; Input:    None
; Output:   None
;------------------------------------------------
playerLeft:
        ld      a,2
        ld      (playerDir),a
        ld      hl,x
        ld      a,(hl)
        or      a
        jp      z,leftMap
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
        ld      hl,x
        dec     (hl)
        ret

;------------------------------------------------
; playerRight - Move player right
;
; Input:    None
; Output:   None
;------------------------------------------------
playerRight:
        ld      a,3
        ld      (playerDir),a
        ld      hl,x
        ld      a,(hl)
        cp      15*8
        jp      z,rightMap
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
        ld      hl,x
        inc     (hl)
        ret

;------------------------------------------------
; dPlayerUp - Move player up when fighting a demon
;
; Input:    None
; Output:   None
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
;
; Input:    None
; Output:   None
;------------------------------------------------
dPlayerDown:
        ld      a,1
        ld      (playerDir),a
        ld      hl,y
        ld      a,(hl)
        cp      64-8
        ret     z
        inc     (hl)
        ret

;------------------------------------------------
; dPlayerLeft - Move player left when fighting a demon
;
; Input:    None
; Output:   None
;------------------------------------------------
dPlayerLeft:
        ld      a,2
        ld      (playerDir),a
        ld      hl,x
        ld      a,(hl)
        cp      DSXMIN+8
        ret     z
        dec     (hl)
        ret

;------------------------------------------------
; dPlayerRight - Move player right when fighting a demon
;
; Input:    None
; Output:   None
;------------------------------------------------
dPlayerRight:
        ld      a,3
        ld      (playerDir),a
        ld      hl,x
        ld      a,(hl)
        cp      DSXMAX-16
        ret     z
        inc     (hl)
        ret

;------------------------------------------------
; checkTile - Check a tile to see if player can walk on it
;
; Input:    A = X
;           L = Y
; Output:   HL => Tile
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
;
; Input:    None
; Output:   None
;------------------------------------------------
drawPlayer:
        ld      de,0
        ld      hl,(playerDir)
        ld      h,24
        mlt     hl
        ld      e,l
        ld      bc,(y)
        ld      a,(hurt)
        cp      INI_HURT
        jr      z,drawPlayerHurt
        ld      a,(attacking)
        or      a
        jr      z,drawPlayerNormal
        inc     a
        jr      nz,drawPlayerAttacking
drawPlayerNormal:
        ld      hl,sprPlayer1
        ld      a,(walkCnt)
        bit     2,a
        jr      z,drawPlayerNow
        ld      hl,sprPlayer2
drawPlayerNow:
        add     hl,de
        jp      graySprite
drawPlayerAttacking:
        ld      a,e
        add     a,a
        ld      e,a
        ld      hl,sprAttacking
        add     hl,de
        push    hl
        call    graySprite
        pop     de
        ld      hl,24
        add     hl,de
        ld      a,(playerDir)
        ld      d,a
        ld      a,8
        bit     0,d
        jr      nz,$+4
        neg
        ld      e,a
        bit     1,d
        ld      bc,(y)
        jr      nz,dpaHorizontal
        add     a,c
        ld      c,a
        jp      graySpriteClip
dpaHorizontal:
        add     a,b
        ld      b,a
        jp      graySpriteClip
drawPlayerHurt:
        ld      hl,sprPlayerHurt
        jr      drawPlayerNow

;------------------------------------------------
; decPlayerHearts - Take away some of the player's hearts
;
; Input:    B = How many bits of heart to take
; Output:   None
;------------------------------------------------
decPlayerHearts:
        ld      hl,heartLevel
        dec     (hl)
        ld      a,(hl)
        or      a
        jr      nz,endDecPlayerHearts
        ld      a,(hearts)
        or      a
        jr      z,noDecPlayerHearts
        ld      (hl),INI_HEART_LEVEL
        ld      hl,hearts
        dec     (hl)
endDecPlayerHearts:
        djnz    decPlayerHearts
        ret
noDecPlayerHearts:
        ld      (hl),a
        ret

;------------------------------------------------
; healOneHeart - Heal one heart for player
;
; Input:    None
; Output:   None
;------------------------------------------------
healOneHeart:
        ld      hl,hearts
        ld      a,(maxHearts)
        cp      (hl)
        ret     z
        inc     (hl)
        ret

;------------------------------------------------
; addGold - Add to player's gold
;
; Input:    HL = Gold to add
; Output:   None
;------------------------------------------------
addGold:
        ld      de,(gold)
        add     hl,de
        ld      (gold),hl
        ld      de,GOLD_MAX
        call    _cphlde
        ret     c
        ld      (gold),de
        ret

;------------------------------------------------
; playerDead - Duh
;
; Input:    None
; Output:   None
;------------------------------------------------
playerDead:
        xor     a
        ld      (hurt),a
        ld      (frame),a
; pause for a bit
        call    copyBuffers
        call    drawPlayer
        call    showGray
        ld      bc,200000
        call    waitBC
; show explosion
        call    clearAnimTable
        ld      bc,(y)
        call    newAnim
        ld      b,8
playerExplode:
        push    bc
        call    copyBuffers
        call    drawAnims
        call    showGray
        call    updateAnims
        ld      bc,15000
        call    waitBC
        pop     bc
        djnz    playerExplode
; pause again
        ld      bc,300000
        call    waitBC

        ld      a,(mapNo)
        or a \ sbc hl,hl \ ld l,a
        ld      de,reviveMapTable
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
        ld      a,1
        ld      (playerDir),a
        ld      a,(maxHearts)
        srl     a
        adc     a,0
        ld      (hearts),a
        ld      hl,(gold)
        push hl \ pop de
        srl d \ rr e
        srl d \ rr e
        or      a
        sbc     hl,de                           ; lose 1/4 Gold
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
        call    newMap
        call    grayDrawMap
        call    copyBuffers
        call    showGray
        call    fadeIn
        jp      checkAreaName

;------------------------------------------------
; calculateDamage - Calculate damage to player according to armor player has
;
; Input:    B = Full value
; Output:   B = How much to hurt player
;------------------------------------------------
calculateDamage:
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
;
; Input:    HL => Where to RET to
; Output:   None
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
; loadPlayerToCollide1 - Load player info into (collide1)
;
; Input:    None
; Output:   None
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
;
; Input:    None
; Output:   None
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

.end
