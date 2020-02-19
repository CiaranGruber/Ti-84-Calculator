;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Enemy Routines                                                ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; clearEnemyTable - Clear enemyTable
;
; Input:    None
; Output:   None
;------------------------------------------------
clearEnemyTable:
        ld      hl,enemyTable
        ld      b,MAX_ENEMIES*ENEMY_ENTRY_SIZE
        jp      _ld_hl_bz

;------------------------------------------------
; clearBulletTable - Clear bulletTable
;
; Input:    None
; Output:   None
;------------------------------------------------
clearBulletTable:
        ld      hl,bulletTable
        ld      b,MAX_BULLETS*BULLET_ENTRY_SIZE
        jp      _ld_hl_bz

;------------------------------------------------
; makeEnemy - Make an enemy
;
; Input:    None
; Output:   None
;------------------------------------------------
makeEnemy:
        ld      a,(enemyType)
        or      a
        ret     z
        ld      b,MAX_ENEMIES
        ld      ix,enemyTable
        ld      de,ENEMY_ENTRY_SIZE
findEmptyEnemyEntry:
        ld      a,(ix+E_DIR)
        or      a
        jr      z,foundEmptyEnemyEntry
        add     ix,de
        djnz    findEmptyEnemyEntry
        ret
foundEmptyEnemyEntry:
        ld      b,14
        call    random
        inc     a
        ld      h,a
        add     a,a
        add     a,a
        add     a,a
        ld      (ix+E_X),a
        ld      b,6
        call    random
        inc     a
        ld      l,a
        add     a,a
        add     a,a
        add     a,a
        ld      (ix+E_Y),a
        ld      a,(enemyType)
        push    hl
        ld de,0 \ ld e,a
        dec     e
        ld      hl,enemyFlying
        add     hl,de
        ld      a,(hl)
        pop     hl
        or      a
        jr      nz,afterCheckEnemyPosValid
        ld      a,h
        call    getBlock
        cp      ENEMY_WALL
        ret     nc
afterCheckEnemyPosValid:
        ld      (ix+E_DIR),-24
        ld      a,(enemyType)
        or a \ sbc hl,hl \ ld l,a
        dec     l
        push    hl
        ld      de,enemyHealth
        add     hl,de
        ld      a,(hl)
        ld      (ix+E_HEALTH),a
        pop     hl
        ld      de,enemySpeed
        add     hl,de
        ld      a,(hl)
        ld      (ix+E_SPEED),a
        ld      (ix+E_AI1CNT),0
        ld      (ix+E_AI1OFF),0
        ld      (ix+E_AI2CNT),0
        ld      (ix+E_AI2OFF),0
        ld      (ix+E_HURT),0
        ret

;------------------------------------------------
; drawEnemies - Draw enemies
;
; Input:    None
; Output:   None
;------------------------------------------------
drawEnemies:
        ld      b,MAX_ENEMIES
        ld      ix,enemyTable
drawEnemiesLoop:
        push    bc
        push    ix
        ld      a,(ix+E_DIR)
        or      a
        jr      z,endDrawEnemiesLoop
        bit     7,a
        jr      nz,drawEnemyBeingMade
        ld      hl,(enemyType)
        ld      h,12
        dec     l
        mlt     hl
        ex      de,hl
        ld      l,a
        dec     l
        ld      h,3
        mlt     hl
        add     hl,de
        ld      de,enemySpriteTable
        add     hl,de
        ld      de,(hl)
        ex      de,hl                           ; HL => Sprite to display
drawEnemy:
        ld      b,(ix+E_X)
        ld      c,(ix+E_Y)
        call    graySpriteClip
endDrawEnemiesLoop:
        pop     ix
        pop     bc
        ld      de,ENEMY_ENTRY_SIZE
        add     ix,de
        djnz    drawEnemiesLoop
        ret
drawEnemyBeingMade:
        neg
        bit     2,a
        ld      hl,sprMakeEnemy1
        jr      z,drawEnemy
        ld      hl,sprMakeEnemy2
        jr      drawEnemy

;------------------------------------------------
; moveEnemies - Run AI scripts for enemies
;
; Input:    None
; Output:   None
;------------------------------------------------
moveEnemies:
        ld      b,MAX_ENEMIES
        ld      ix,enemyTable
moveEnemiesLoop:
        push    bc
        ld      a,(ix+E_DIR)
        or      a
        jr      z,endMoveEnemiesLoop
        bit     7,a
        jr      nz,updateMakingEnemy
        ld      a,(ix+E_HURT)
        or      a
        jr      nz,endMoveEnemiesLoop
        ld      a,(ix+E_AI1CNT)
        ld      (aiCnt),a
        ld      a,(ix+E_AI2CNT)
        ld      (aiCntOther),a
        ld      a,(ix+E_AI2OFF)
        ld      (aiOff),a
        ld      bc,endAIScript1
        ld      a,(ai1)
        ld      l,a
        ld      a,(ix+E_AI1OFF)
        jr      runAIScript
endAIScript1:
        ld      a,(aiCnt)
        ld      (ix+E_AI1CNT),a
        ld      a,(aiOff)
        ld      (ix+E_AI2OFF),a
        ld      a,(ix+E_AI2CNT)
        ld      (aiCnt),a
        ld      a,(ix+E_AI1CNT)
        ld      (aiCntOther),a
        ld      a,(ix+E_AI1OFF)
        ld      (aiOff),a
        ld      bc,endAIScript2
        ld      a,(ai2)
        ld      l,a
        ld      a,(ix+E_AI2OFF)
        jr      runAIScript
endAIScript2:
        ld      a,(aiCnt)
        ld      (ix+E_AI2CNT),a
        ld      a,(aiOff)
        ld      (ix+E_AI1OFF),a
endMoveEnemiesLoop:
        pop     bc
        ld      de,ENEMY_ENTRY_SIZE
        add     ix,de
        djnz    moveEnemiesLoop
        ret
updateMakingEnemy:
        inc     a
        ld      (ix+E_DIR),a
        jr      nz,endMoveEnemiesLoop
        ld      (ix+E_DIR),1
        jp      endMoveEnemiesLoop

;------------------------------------------------
; runAIScript - Run an enemy AI script for an enemy
;
; Input:    IX => Start of enemy entry
;           BC => Where to RET to
;           L = AI script to run
;           A = aiOff value for this script
; Output:   IX => Start of enemy entry
;------------------------------------------------
runAIScript:
        push    bc
        or      a
        ret     nz
        ld      a,l
        or      a
        ret     z
        dec     l
        ld      h,3
        mlt     hl
        ld      de,aiTable
        add     hl,de
        ld      de,(hl)
        ex      de,hl
        jp      (hl)

;------------------------------------------------
; checkEnemySpeed - Check to see if enemy should move this frame
;
; Input:    None
; Output:   Z = 1 if enemy should move
;------------------------------------------------
checkEnemySpeed:
        ld      a,(frame)
        and     (ix+E_SPEED)
        ret

;------------------------------------------------
; tryMoveEnemyVertical - Try to move enemy closer to player on vertical axis
;
; Input:    IX => Start of enemy entry
; Output:   IX => Start of enemy entry
;           CA = 1 if couldn't move
;------------------------------------------------
tryMoveEnemyVertical:
        ld      a,(y)
        cp      (ix+E_Y)
        jp      c,moveEnemyUp
        jp      nz,moveEnemyDown
        scf
        ret

;------------------------------------------------
; tryMoveEnemyHorizontal - Try to move enemy closer to player on horizontal axis
;
; Input:    IX => Start of enemy entry
; Output:   IX => Start of enemy entry
;           CA = 1 if couldn't move
;------------------------------------------------
tryMoveEnemyHorizontal:
        ld      a,(x)
        cp      (ix+E_X)
        jp      c,moveEnemyLeft
        jp      nz,moveEnemyRight
        scf
        ret

;------------------------------------------------
; moveEnemyUp - Move an enemy up
;
; Input:    IX => Start of enemy entry
; Output:   IX => Start of enemy entry
;           CA = 1 if couldn't move
;------------------------------------------------
moveEnemyUp:
        ld      a,(ix+E_X)
        ld      l,(ix+E_Y)
        dec     l
        call    enemyGetTile
        cp      ENEMY_WALL
        ccf
        ret     c
        ld      a,(ix+E_X)
        add     a,7
        ld      l,(ix+E_Y)
        dec     l
        call    enemyGetTile
        cp      ENEMY_WALL
        ccf
        ret     c
        dec     (ix+E_Y)
        ld      (ix+E_DIR),1
        or      a
        ret

;------------------------------------------------
; moveEnemyDown - Move an enemy down
;
; Input:    IX => Start of enemy entry
; Output:   IX => Start of enemy entry
;           CA = 1 if couldn't move
;------------------------------------------------
moveEnemyDown:
        ld      a,(ix+E_Y)
        add     a,8
        ld      l,a
        ld      a,(ix+E_X)
        call    enemyGetTile
        cp      ENEMY_WALL
        ccf
        ret     c
        ld      a,(ix+E_Y)
        add     a,8
        ld      l,a
        ld      a,(ix+E_X)
        add     a,7
        call    enemyGetTile
        cp      ENEMY_WALL
        ccf
        ret     c
        inc     (ix+E_Y)
        ld      (ix+E_DIR),2
        or      a
        ret

;------------------------------------------------
; moveEnemyLeft - Move an enemy left
;
; Input:    IX => Start of enemy entry
; Output:   IX => Start of enemy entry
;           CA = 1 if couldn't move
;------------------------------------------------
moveEnemyLeft:
        ld      a,(ix+E_X)
        dec     a
        ld      l,(ix+E_Y)
        call    enemyGetTile
        cp      ENEMY_WALL
        ccf
        ret     c
        ld      a,(ix+E_Y)
        add     a,7
        ld      l,a
        ld      a,(ix+E_X)
        dec     a
        call    enemyGetTile
        cp      ENEMY_WALL
        ccf
        ret     c
        dec     (ix+E_X)
        ld      (ix+E_DIR),3
        or      a
        ret

;------------------------------------------------
; moveEnemyRight - Move an enemy right
;
; Input:    IX => Start of enemy entry
; Output:   IX => Start of enemy entry
;           CA = 1 if couldn't move
;------------------------------------------------
moveEnemyRight:
        ld      a,(ix+E_X)
        add     a,8
        ld      l,(ix+E_Y)
        call    enemyGetTile
        cp      ENEMY_WALL
        ccf
        ret     c
        ld      a,(ix+E_Y)
        add     a,7
        ld      l,a
        ld      a,(ix+E_X)
        add     a,8
        call    enemyGetTile
        cp      ENEMY_WALL
        ccf
        ret     c
        inc     (ix+E_X)
        ld      (ix+E_DIR),4
        or      a
        ret

;------------------------------------------------
; enemyGetTile - Same as getTile, but you can hack into it ;)
;
; Input:    A = X Coord
;           L = Y Coord
; Output:   HL => Tile
;           A = Tile
;------------------------------------------------
enemyGetTile:
        call    getTile
__enemyGetTile                          = $
        xor     a
        ret

;------------------------------------------------
; getEmptyBulletEntry - Try to find an empty entry in bulletTable
;
; Input:    None
; Output:   HL => Start of entry (if one was found)
;           CA = 1 if no entry was empty
;------------------------------------------------
getEmptyBulletEntry:
        ld      hl,bulletTable
        ld      b,MAX_BULLETS
        ld      de,BULLET_ENTRY_SIZE
findEmptyBulletEntry:
        ld      a,(hl)
        or      a
        ret     z
        add     hl,de
        djnz    findEmptyBulletEntry
        scf
        ret

;------------------------------------------------
; drawBullets - Draw enemy bullets
;
; Input:    None
; Output:   None
;------------------------------------------------
drawBullets:
        ld      hl,bulletTable
        ld      b,MAX_BULLETS
drawBulletsLoop:
        push    hl
        push    bc
        ld      a,(hl)
        or      a
        jr      z,endDrawBulletsLoop
        inc     hl
        ld      b,(hl)
        inc     hl
        ld      c,(hl)
        ld      hl,sprBullet
        call    graySpriteClip
endDrawBulletsLoop:
        pop     bc
        pop     hl
        ld      de,BULLET_ENTRY_SIZE
        add     hl,de
        djnz    drawBulletsLoop
        ret

;------------------------------------------------
; moveBullets - Move enemy bullets
;
; Input:    None
; Output:   None
;------------------------------------------------
moveBullets:
        ld      ix,bulletTable
        ld      b,MAX_BULLETS
moveBulletsLoop:
        push    bc
        ld      a,(ix+B_DIR)
        or      a
        jr      z,endMoveBulletsLoop
        dec     a
        ld      l,a
        ld      h,2
        mlt     hl
        ld      de,bulletOffsets
        add     hl,de
        ld      a,(hl)
        add     a,(ix+E_Y)
        ld      (ix+E_Y),a
        inc     hl
        ld      a,(hl)
        add     a,(ix+E_X)
        ld      (ix+E_X),a
        push    ix
        pop     hl
        inc     hl
        ld      a,-4
        ld      b,-4
        call    checkObjectOnScreen
        jr      nc,endMoveBulletsLoop
        ld      (ix+B_DIR),0
endMoveBulletsLoop:
        pop     bc
        ld      de,BULLET_ENTRY_SIZE
        add     ix,de
        djnz    moveBulletsLoop
        ret

;------------------------------------------------
; getAngle - Get the angle between the player and an enemy
;
; Input:    IX => Start of enemy entry
; Output:   IX => Start of enemy entry
;           A = Angle
;------------------------------------------------
getAngle:
        ld      bc,0
        ld      a,(y)
        sub     (ix+E_Y)
        jr      z,angleHorizontal
        jr      nc,pyeyPos
        neg
        ld      c,6
pyeyPos:
        ld      l,a
        ld      h,b
        ld      a,b
        add     a,c
        ld      b,a
        ld      a,(x)
        sub     (ix+E_X)
        jr      z,angleVertical
        ld      c,0
        jr      nc,pxexPos
        neg
        ld      c,3
pxexPos:
        ld      d,a
        ld      a,b
        add     a,c
        ld      b,a
        ld      a,d
        call    _divhlbya_s
        ld      a,l
        cp      3
        jr      c,angleNoSet2
        ld      a,2
angleNoSet2:
        ld      c,a
        ld      a,b
        or      a
        jr      z,angleModGradient
        cp      9
        jr      nz,angleAfterModGradient
angleModGradient:
        bit     0,c
        jr      nz,angleAfterModGradient
        ld      b,a
        ld      a,c
        xor     2
        ld      c,a
        ld      a,b
angleAfterModGradient:
        add     a,c
        ret
angleHorizontal:
        ld      a,(x)
        sub     (ix+E_X)
        ld      a,14
        ret     c
        inc     a
        ret
angleVertical:
        ld      a,(y)
        sub     (ix+E_Y)
        ld      a,12
        ret     c
        inc     a
        ret

;------------------------------------------------
; checkEnemyOnScreen - Check to ensure an enemy is still on the screen
;
; Input:    IX => Start of enemy entry
; Output:   IX => Start of enemy entry
;           CA = 1 if enemy isn't on the screen
;------------------------------------------------
checkEnemyOnScreen:
        push    ix
        pop     hl
        inc     hl
        ld      a,-7
        ld      b,-7
        jp      checkObjectOnScreen

;------------------------------------------------
; loadEnemyToCollide2 - Load an enemy's info into (collide2)
;
; Input:    IX => Start of enemy entry
; Output:   IX => Start of enemy entry
;------------------------------------------------
loadEnemyToCollide2:
        ld      hl,collide2
        ld      a,(ix+E_X)
        ld      (hl),a
        inc     hl
        ld      (hl),8
        inc     hl
        ld      a,(ix+E_Y)
        ld      (hl),a
        inc     hl
        ld      (hl),8
        ret

;------------------------------------------------
; loadBulletToCollide2 - Load a bullet's info into (collide2)
;
; Input:    IX => Start of bullet entry
; Output:   IX => Start of bullet entry
;------------------------------------------------
loadBulletToCollide2:
        ld      hl,collide2
        ld      a,(ix+B_X)
        ld      (hl),a
        inc     hl
        ld      (hl),5
        inc     hl
        ld      a,(ix+B_Y)
        ld      (hl),a
        inc     hl
        ld      (hl),5
        ret

.end
