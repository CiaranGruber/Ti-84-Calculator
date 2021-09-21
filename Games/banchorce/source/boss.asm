;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Boss Routines                                                 ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; iniBoss - start a boss encounter
;   input:  HL => x coord entry in warp
;------------------------------------------------
iniBoss:
        ld      a,(hl)
        srl     a
        srl     a
        srl     a
        ld      (demon),a
        dec     a
        push    af
        call    loadBossGfx
        call    clearAnimTable
        call    clearBulletTable
        call    clearDemonTable
        call    clearEnemyTable
        REDRAW_HUD()
        xor     a
        ld      (hurt),a
        ld      (playerDir),a
        ld      (dCnt),a
        ld      (dFlags),a
        ld      (dHurt),a
        ld      hl,B_INI_YX
        ld      (y),hl
        pop     hl
        ld      l,3
        mlt     hl
        ld      de,bossIniTable
        add     hl,de
        ld      de,(hl)
        ex      de,hl
        ld      de,finishIniBoss
        push    de
        jp      (hl)
finishIniBoss:
#ifndef INVINCIBLE
        ld      (__demonDamage),a
        ld      a,b
        ld      (__demonBulletDamage),a
#endif
        ld      (__doDemon),ix
        ld      (__drawDemon),de
        ld      (__finishedDemon),hl
        ; do warp animation
        call    fadeOut
        call    drawMap
        call    vramFlip
        call    fadeIn
        ; fall through to mainBossLoop

;------------------------------------------------
; main boss loop
;------------------------------------------------
mainBossLoop:
        ld      hl,frame
        inc     (hl)
        
        ld      hl,mainBossLoop
        ld      (__pauseJump),hl

        call    keyScan

        ld      hl,hurt
        ld      a,(hl)
        or      a
        jr      z,mdlAfterHurt
        dec     (hl)

mdlAfterHurt:
        ld      a,(attacking)
        or      a
        jr      z,checkPlayerMovementD
        inc     a
        jr      nz,afterPlayerMovementD
checkPlayerMovementD:
        ld      a,(kbdG7)
        push    af
        bit     kbitUp,a
        call    nz,dPlayerUp
        pop     af
        push    af
        bit     kbitDown,a
        call    nz,dPlayerDown
        pop     af
        push    af
        bit     kbitLeft,a
        call    nz,dPlayerLeft
        pop     af
        push    af
        bit     kbitRight,a
        call    nz,dPlayerRight
        pop     af
        or      a
        jr      z,afterPlayerMovementD
        ld      hl,walkCnt
        inc     (hl)
afterPlayerMovementD:
        ld      a,(kbdG1)
        bit     kbitMode,a
        jp      nz,pauseGame
#ifdef BOSS_ESCAPE
        ; demon escape key for debugging purposes
        bit     kbitGraph,a
        jp      nz,demonFinished
#endif
        bit     kbit2nd,a
        ld      hl,afterAttackingDemon
        jp      nz,tryAttacking
        xor     a
        ld      (attacking),a
afterAttackingDemon:

; Move demon
__doDemon                               = $+1
        call    $000000

; Check sword/demon collisions
        call    loadDemonToCollide2
        ld      hl,dHurt
        ld      a,(attacking)
        or      a
        jr      z,playerNotAttackingDemon
        inc     a
        jr      z,playerNotAttackingDemon
        push    hl
        call    loadSwordToCollide1
        call    checkCollision
        pop     hl
        jr      nc,playerNotAttackingDemon
        inc     (hl)
        ld      a,(attackStrength)
        ld de,0 \ ld e,a
        ld      hl,(dHealth)
        or      a
        sbc     hl,de
        ld      (dHealth),hl
        jp      c,demonFinished
        jr      afterCheckSDCollision
playerNotAttackingDemon:
        ld      (hl),0
afterCheckSDCollision:
; Check player/demon collisions
        call    loadPlayerToCollide1
        call    checkCollision
        jr      nc,afterCheckPDCollision
        ld      a,(hurt)
        or      a
        jr      nz,afterCheckPDCollision
#ifndef INVINCIBLE
__demonDamage           = $+1
        ld      b,$00
        call    calculateDamage
        call    decPlayerHearts
        ld      a,INI_HURT
        ld      (hurt),a
#endif
afterCheckPDCollision:
; Check player/demon object collisions
        ld      b,MAX_DEMON_OBJECTS
        ld      ix,demonTable
checkPDCollisions:
        push    bc
        ld      a,(ix+D_DIR)
        or      a
        jr      z,endCheckPDCollisions
        call    loadBulletToCollide2
        call    checkCollision
        jr      nc,endCheckPDCollisions
        ld      a,(hurt)
        or      a
        jr      nz,endCheckPDCollisions
#ifndef INVINCIBLE
__demonBulletDamage     = $+1
        ld      b,$00
        call    calculateDamage
        call    decPlayerHearts
        ld      a,INI_HURT
        ld      (hurt),a
#endif
endCheckPDCollisions:
        pop     bc
        ld      de,DEMON_ENTRY_SIZE
        add     ix,de
        djnz    checkPDCollisions

        call    drawMap
__drawDemon                             = $+1
        call    $000000
        call    drawDemonObjects
        call    drawPlayer

        ld      a,(__redrawHud)
        or      a
        call    nz,drawHud

        call    vramFlip

        ld      a,(hearts)
        or      a
        jp      nz,mainBossLoop
        jp      playerDead

;------------------------------------------------
; Finished
;------------------------------------------------
demonFinished:
        xor     a
        ld      (attacking),a
        ld      (demon),a
        ld      (frame),a
        ld      hl,(__drawDemon)
        ld      (__drawDemonDeath),hl

        ; boss death animation
        ; first, pause for a bit
        call    drawMap
__drawDemonDeath        = $+1
        call    $000000
        call    drawPlayer
        call    vramFlip
        ld      bc,100000
        call    waitBC
        ; do some explosions
        call    clearAnimTable
        ld      bc,16*256+0
        ld      hl,bossExplodeTable
bossExplodeLoop:
        bit     0,b
        jr      nz,noNewBossExplosion
        ld      a,c
        cp      4
        jr      nc,noNewBossExplosion
        inc     c
        push    bc
        ld      bc,(dy)
        add     a,(hl)
        add     a,b
        ld      b,a
        inc     hl
        ld      a,(hl)
        add     a,c
        ld      c,a
        inc     hl
        push    hl
        call    newAnim
        pop     hl
        pop     bc
noNewBossExplosion:
        push    bc
        push    hl
        call    drawMap
        call    drawPlayer
        call    drawAnims
        call    vramFlip
        call    updateAnims
        ld      bc,10000
        call    waitBC
        pop     hl
        pop     bc
        djnz    bossExplodeLoop
        ld      bc,100000
        call    waitBC

        ; run routine to get all demon finished values (different for each demon)
__finishedDemon                         = $+1
        call    $000000
        ld      hl,demonWarp
        ld      (hl),a
        inc     hl
        ld      (hl),b
        inc     hl
        ld      (hl),c
        ex      de,hl
        call    addGold
        ld      a,(ix)                          ; A = Number of change list entries to add
        or      a
        jr      z,noDemonChanges
        ld      b,a
        inc     ix
doDemonChanges:
        push    bc
        ld      a,(ix+0)
        ld      b,(ix+1)
        ld      c,(ix+2)
        call    addToChangeList
        pop     bc
        ld      de,3
        add     ix,de
        djnz    doDemonChanges
noDemonChanges:

        ; player health to max
        ld      a,(maxHearts)
        ld      (hearts),a
        ld      a,INI_HEART_LEVEL
        ld      (heartLevel),a
        ; open top of boss room
        ld      hl,map+COLS+COLS+1
        ld      de,map+1
        ld      bc,COLS-2
        ldir
        ; walk the player out of the room
        xor     a
        ld      (playerDir),a
bossVictoryWalk:
        call    drawMap
        ld      a,HUD_COUNT_MAX
        call    drawHud
        call    drawPlayer
        call    vramFlip
        ld      hl,walkCnt
        inc     (hl)
        ld      a,(y)
        dec     a
        ld      (y),a
        jr      nz,bossVictoryWalk

        ; reload standard tileset
        call    loadStdGfx

        ; warp back to dungeon
        ld      hl,demonWarp-1
        jp      warpToMap

;------------------------------------------------
; drawBoss - Draw 16x16 demon sprite
;   input:  HL => Sprite
;   output: none
;------------------------------------------------
drawBoss:
        ld      a,(dHurt)
        or      a                               ; is the boss being attacked?
        jr      z,drawBossStart                 ; if not, draw normally
        ld      a,(frame)
        and     %00000001
        jr      z,drawBossStart                 ; only flash boss white every 2nd frame
        ; modify the boss sprite to be all white
        ld      de,tempSprite
        push    de
        ld      b,0                             ; actually 256 LOL
drawBossModify:
        ld      a,(hl)
        or      a
        jr      z,drawBossModifyWrite
        ld      a,COLOUR_WHITE
drawBossModifyWrite:
        ld      (de),a
        inc     hl
        inc     de
        djnz    drawBossModify
        pop     hl
drawBossStart:
        ld      b,4
        ld      de,(dy)
        ld      ix,bossDrawTable
drawBossLoop:
        push    bc
        push    hl
        push    de
        push    ix
        ld      b,d
        ld      d,e
        ld      e,b
        call    drawSprite
        pop     ix
        pop     de
        ld      a,d
        add     a,(ix)
        ld      d,a
        ld      a,e
        add     a,(ix+1)
        ld      e,a
        inc     ix
        inc     ix
        pop     hl
        ld      bc,64
        add     hl,bc
        pop     bc
        djnz    drawBossLoop
        ret

;------------------------------------------------
; drawDemonObjects - Draw demon objects
;   input:  none
;   output: none
;------------------------------------------------
drawDemonObjects:
        ld      ix,demonTable
        ld      b,MAX_DEMON_OBJECTS
drawDemonObjectsLoop:
        push    bc
        push    ix
        ld      a,(ix+D_DIR)
        or      a
        jr      z,endDrawDemonObjectsLoop
        ld      e,(ix+D_X)
        ld      d,(ix+D_Y)
        ld      hl,sprBossBullet
        call    drawSprite
endDrawDemonObjectsLoop:
        pop     ix
        pop     bc
        ld      de,DEMON_ENTRY_SIZE
        add     ix,de
        djnz    drawDemonObjectsLoop
        ret

;------------------------------------------------
; loadDemonToCollide2 - Load demon info to (collide2)
;   input:  none
;   output: none
;------------------------------------------------
loadDemonToCollide2:
        ld      hl,collide2
        ld      a,(dx)
        ld      (hl),a
        inc     hl
        ld      (hl),16
        inc     hl
        ld      a,(dy)
        ld      (hl),a
        inc     hl
        ld      (hl),16
        ret

;------------------------------------------------
; clearDemonTable - Clear demonTable
;   input:  none
;   output: none
;------------------------------------------------
clearDemonTable:
        ld      hl,demonTable
        ld      b,MAX_DEMON_OBJECTS*DEMON_ENTRY_SIZE
        jp      _ld_hl_bz

;------------------------------------------------
; getEmptyDemonEntry - Try to find an empty entry in demonTable
;   input:  none
;   output: HL => Start of entry (if one was found)
;           CA = 1 if no entry was empty
;------------------------------------------------
getEmptyDemonEntry:
        ld      hl,demonTable
        ld      b,MAX_DEMON_OBJECTS
        ld      de,DEMON_ENTRY_SIZE
findEmptyDemonEntry:
        ld      a,(hl)
        or      a
        ret     z
        add     hl,de
        djnz    findEmptyDemonEntry
        scf
        ret

;------------------------------------------------
; getNumBossObjects - check the number of active boss objects/bullets
;   input:  none
;   output: A = result
;------------------------------------------------
getNumBossObjects:
        ld      hl,demonTable
        ld      bc,MAX_DEMON_OBJECTS*256+0
        ld      de,DEMON_ENTRY_SIZE
countBossObjects:
        ld      a,(hl)
        or      a
        jr      z,countBossObjectsNext
        inc     c
countBossObjectsNext:
        add     hl,de
        djnz    countBossObjects
        ld      a,c
        ret

;------------------------------------------------
; moveDemonObjectsNormal - Move all demon objects with standard angle code
;   input:  C = speed (same as values used in moveDir16)
;   output: none
;------------------------------------------------
moveDemonObjectsNormal:
        ld      b,MAX_DEMON_OBJECTS
        ld      ix,demonTable
moveDemonObjectsLoop:
        push    bc
        ld      b,c
        ld      a,(ix+D_DIR)
        or      a
        jr      z,endMoveDemonObjectsLoop
        call    moveDemonObject
endMoveDemonObjectsLoop:
        pop     bc
        ld      de,DEMON_ENTRY_SIZE
        add     ix,de
        djnz    moveDemonObjectsLoop
        ret

;------------------------------------------------
; moveDemonObject - Move a demon object
;   input:  IX => Start of object entry
;           B = speed (same as values used in moveDir16)
;   output: IX => Start of object entry
;------------------------------------------------
moveDemonObject:
        ld      a,(ix+D_DIR)
        dec     a
        call    moveDir16
        ld      a,(ix+E_X)
        cp      COLS*8
        jr      c,demonObjectCheckY
        cp      -8
        jr      c,demonObjectOffScreen
demonObjectCheckY:
        ld      a,(ix+D_Y)
        cp      ROWS*8
        ret     c
        cp      -8
        ret     nc
demonObjectOffScreen:
        ld      (ix+D_DIR),0
        ret

;------------------------------------------------
; getDemonAngle - Get angle between demon & player
;   input:  none
;   output: A = Angle
;------------------------------------------------
getDemonAngle:
        call    swapDemonXY
        ld      ix,dy-1
        call    getAngle
; Fall through to swapDemonXY and return

;------------------------------------------------
; swapDemonXY - Swap Demon X & Y coordinates
;   input:  none
;   output: none
;------------------------------------------------
swapDemonXY:
        ld      hl,(dy)
        ld      e,l
        ld      l,h
        ld      h,e
        ld      (dy),hl
        ret

;------------------------------------------------
; checkBossOnScreen - check to make sure boss is properly on-screen
;   input:  none
;   output: none
;------------------------------------------------
checkBossOnScreen:
        ld      hl,dy
        ld      a,(hl)
        cp      (ROWS*8)-16
        jr      c,bossOnScreen1
        ld      (hl),(ROWS*8)-16
bossOnScreen1:
        cp      8
        jr      nc,bossOnScreen2
        ld      (hl),8
bossOnScreen2:
        inc     hl                              ; HL => Demon X pos
        ld      a,(hl)
        cp      (COLS*8)-16-8
        jr      c,bossOnScreen3
        ld      (hl),(COLS*8)-16-8
bossOnScreen3:
        cp      8
        ret     nc
        ld      (hl),8
        ret

;------------------------------------------------
; loadBossGfx - load the tile data, load the boss sprites, load the boss room to (map)
;   input:  A = boss #
;   output: none
;------------------------------------------------
loadBossGfx:
        push    af
        add     a,GFX_FILE_BOSS_FLOORS
        push    af
        call    getGfxFile
        pop     bc
        ld      hl,tileset
        ex      de,hl
        push    hl
        ld      ix,huffTree
        call    huffExtr                        ; unpack floor tiles
        pop     hl
        ld      de,tileset+(4*64)
        ld      b,GFX_FILE_BOSS_WALLS
        ld      ix,huffTree
        call    huffExtr                        ; unpack wall tiles
        pop     af
        
        add     a,GFX_FILE_BOSS_SPRITES
        push    af
        call    getGfxFile
        pop     bc
        ld      hl,sprBoss
        ex      de,hl
        ld      ix,huffTree
        call    huffExtr                        ; unpack boss sprites

        ld      hl,bossRoom
        ld      de,map
        ld      bc,TILE_DATA_SIZE
        ldir
        ret

;------------------------------------------------
; Initialisation routine pointers
;------------------------------------------------
bossIniTable:
.dl     iniHeath,iniDezemon,iniWendeg,iniBelkath,iniAnazar,iniMargoth,iniDurcrux,iniBanchor

.end
