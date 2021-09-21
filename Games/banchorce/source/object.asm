;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Object Routines                                               ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; checkObjectOnScreen - Check to see if an object is on the screen
;   input:  HL => X, Y Coords
;           A = -(Width-1)
;           B = -(Height-1)
;   output: CA = 1 if object isn't on the screen
;------------------------------------------------
checkObjectOnScreen:
        ld      (__objectWidth),a
        ld      a,b
        ld      (__objectHeight),a
        ld      a,(hl)
        cp      COLS*8-1
        jr      c,objectXOK
__objectWidth                           = $+1
        cp      $00
        jr      c,objectNotOnScreen
objectXOK:
        inc     hl
        ld      a,(hl)
        cp      ROWS*8-1
        jr      c,objectOnScreen
__objectHeight                          = $+1
        cp      $00
        jr      c,objectNotOnScreen
objectOnScreen:
        or      a
        ret
objectNotOnScreen:
        scf
        ret

;------------------------------------------------
; checkCollision - Check for collisions between two objects
;   author: Patrick Davidson
;           Modified slightly by James Vernon
;   input:  (collide1) = Object 1 [x, width, y, height]
;           (collide2) = Object 2 [x, width, y, height]
;   output: CA = 1 if they are colliding
;------------------------------------------------
checkCollision:
        ld      hl,collide1
        ld      de,(collide2)
        ld      a,(hl)
        sub     e
        jr      c,checkCollision1
        cp      d
        ret     nc
        inc     hl
        jr      checkCollision2
checkCollision1:
        neg
        inc     hl
        cp      (hl)
        ret     nc
checkCollision2:
        ld      de,(collide2+2)
        inc     hl
        ld      a,(hl)
        sub     e
        jr      c,checkCollision3
        cp      d
        ret
checkCollision3:
        neg
        inc     hl
        cp      (hl)
        ret

;------------------------------------------------
; checkPlayerEnemyCollisions - Check for collisions between the player and the enemies
;   input:  none
;   output: none
;------------------------------------------------
checkPlayerEnemyCollisions:
        call    loadPlayerToCollide1
        ld      b,MAX_ENEMIES
        ld      ix,enemyTable
checkPECollisions:
        push    bc
        ld      a,(ix+E_DIR)
        or      a
        jr      z,endCheckPECollisions
        call    loadEnemyToCollide2
        call    checkCollision
        jr      nc,endCheckPECollisions
        ld      l,(ix+E_DIR)
        bit     7,l
        jr      nz,stopEnemySpawning
#ifndef INVINCIBLE
        ld      a,(hurt)
        or      a
        jr      nz,endCheckPECollisions
        ld      a,(enemyType)
        dec     a
        or a \ sbc hl,hl \ ld l,a
        ld      de,enemyDamage
        add     hl,de
        ld      b,(hl)
        call    calculateDamage
        call    decPlayerHearts
        ld      a,INI_HURT
        ld      (hurt),a
#endif
endCheckPECollisions:
        pop     bc
        ld      de,ENEMY_ENTRY_SIZE
        add     ix,de
        djnz    checkPECollisions
        ret
stopEnemySpawning:
        ld      (ix+E_DIR),0
        jr      endCheckPECollisions

;------------------------------------------------
; checkPlayerBulletCollisions - Check for collisions between player and any bullets
;   input:  none
;   output: none
;------------------------------------------------
checkPlayerBulletCollisions:
        call    loadPlayerToCollide1
        ld      b,MAX_BULLETS
        ld      ix,bulletTable
checkPBCollisions:
        push    bc
        ld      a,(ix+B_DIR)
        or      a
        jr      z,endCheckPBCollisions
        bit     7,a
        jr      nz,endCheckPBCollisions
        call    loadBulletToCollide2
        call    checkCollision
        jr      nc,endCheckPBCollisions
        ld      a,(hurt)
        or      a
        jr      nz,endCheckPBCollisions
        ld      a,(ironShield)
        or      a
        jr      nz,blockBullet
        ld      a,(woodenShield)
        or      a
        jr      z,noShield
        ld      a,(enemyType)
        ld      hl,woodenBlock
        ld      bc,NUM_WOODEN
        cpir
        jr      z,blockBullet
noShield:
#ifndef INVINCIBLE
        ld      b,BULLET_DAMAGE
        call    calculateDamage
        call    decPlayerHearts
        ld      a,INI_HURT
        ld      (hurt),a
#endif
endCheckPBCollisions:
        pop     bc
        ld      de,BULLET_ENTRY_SIZE
        add     ix,de
        djnz    checkPBCollisions
        ret
blockBullet:
        ld      a,(ix+B_DIR)
        bit     7,a
        jr      nz,endCheckPBCollisions
        dec     a
        add     a,8
        and     $0F
        inc     a
        or      %10000000                       ; set bit 7 which means bullet has been deflected (can only be deflected once)
        ld      (ix+B_DIR),a
        jr      endCheckPBCollisions

;------------------------------------------------
; checkPlayerOrbCollisions - check for collisions between player and health orbs
;   input:  none
;   output: none
;------------------------------------------------
checkPlayerOrbCollisions:
        call    loadPlayerToCollide1
        ld      b,MAX_HEALTH_ORBS
        ld      ix,orbTable
checkPOCollisions:
        push    bc
        ld      a,(ix+O_COUNT)
        or      a
        jr      z,endCheckPOCollisions
        call    loadBulletToCollide2            ; health orbs and bullets are same size and store their x/y the same
        call    checkCollision
        jr      nc,endCheckPOCollisions
        ld      (ix+O_COUNT),0
        call    healHalfHeart
endCheckPOCollisions:
        pop     bc
        ld      de,ORB_ENTRY_SIZE
        add     ix,de
        djnz    checkPOCollisions
        ret

;------------------------------------------------
; checkSwordEnemyCollisions - Check for collisions between player's sword and his enemies
;   input:  none
;   output: none
;------------------------------------------------
checkSwordEnemyCollisions:
        call    loadSwordToCollide1
        ld      b,MAX_ENEMIES
        ld      ix,enemyTable
checkSECollisions:
        push    bc
        ld      a,(ix+E_DIR)
        or      a
        jr      z,endCheckSECollisions
        ld      a,(attacking)
        or      a
        jr      z,notHurtingEnemy
        inc     a
        jr      z,notHurtingEnemy
        call    loadEnemyToCollide2
        call    checkCollision
        jr      nc,notHurtingEnemy
        bit     7,(ix+E_DIR)
        jr      nz,killEnemy                    ; if enemy is spawning, kill it with no explosion animation
        ld      (ix+E_HURT),1
        ld      hl,attackStrength
        ld      a,(ix+E_HEALTH)
        sub     (hl)
        ld      (ix+E_HEALTH),a
        jr      nc,endCheckSECollisions
        ld      a,(enemyType)
        dec     a
        or a \ sbc hl,hl \ ld l,a
        ld      de,enemyGold
        add     hl,de
        ld      l,(hl)
        ld      h,10
        mlt     hl
        call    addGold
        ld      b,(ix+E_X)
        ld      c,(ix+E_Y)
        call    newAnim
        ; random chance for health orb to spawn
        ld      b,ORB_CHANCE
        call    random
        or      a
        jr      nz,killEnemy
        call    getEmptyOrbEntry
        jr      c,killEnemy
        ld      (hl),INI_ORB_COUNT
        inc     hl
        ld      a,(ix+E_X)
        inc     a
        ld      (hl),a
        inc     hl
        ld      a,(ix+E_Y)
        inc     a
        ld      (hl),a
killEnemy:
        ld      (ix+E_DIR),0
        jr      endCheckSECollisions
notHurtingEnemy:
        ld      (ix+E_HURT),0
endCheckSECollisions:
        pop     bc
        ld      de,ENEMY_ENTRY_SIZE
        add     ix,de
        dec     b
        jp      nz,checkSECollisions
        ret

.end
