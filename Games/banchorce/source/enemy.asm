;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Enemy Routines                                                ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; clearEnemyTable - Clear enemyTable
;   input:  none
;   output: none
;------------------------------------------------
clearEnemyTable:
        ld      hl,enemyTable
        ld      b,MAX_ENEMIES*ENEMY_ENTRY_SIZE
        jp      _ld_hl_bz

;------------------------------------------------
; clearBulletTable - Clear bulletTable
;   input:  none
;   output: none
;------------------------------------------------
clearBulletTable:
        ld      hl,bulletTable
        ld      b,MAX_BULLETS*BULLET_ENTRY_SIZE
        jp      _ld_hl_bz

;------------------------------------------------
; makeEnemy - try to spawn an enemy
;   input:  none
;   output: none
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
        ld      b,COLS-2
        call    random
        inc     a
        ld      h,a
        add     a,a
        add     a,a
        add     a,a
        ld      (ix+E_X),a
        ld      b,ROWS-2
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
__enemyHealth           = $+1
        ld      de,enemyHealth
        add     hl,de
        ld      a,(hl)
        ld      (ix+E_HEALTH),a
        pop     hl
        ld      de,enemySpeed
        add     hl,de
        ld      a,(hl)
        ld      (ix+E_FRAME),0
        ld      (ix+E_PAUSECNT),0
        ld      (ix+E_JUMPCNT),0
        ld      (ix+E_SPEED),0
        ld      (ix+E_FLAGS),0
        ld      (ix+E_HURT),0
        ret

;------------------------------------------------
; drawEnemies - Draw enemies
;   input:  none
;   output: none
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
        ld      l,(ix+E_FRAME)
        ld      h,3
        mlt     hl
        add     hl,de
        ld      de,enemySpriteTable
        add     hl,de
        ld      de,(hl)
        ex      de,hl                           ; HL => Sprite to display
drawEnemy:
        ld      e,(ix+E_X)
        ld      d,(ix+E_Y)
        call    drawSprite
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
        ld      hl,sprSpawn
        jr      z,drawEnemy
        ld      hl,sprSpawn+64
        jr      drawEnemy

;------------------------------------------------
; moveEnemies - Run AI scripts for enemies
;   input:  none
;   output: none
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
__enemyAI               = $+1
        call    $000000
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
; getEmptyBulletEntry - Try to find an empty entry in bulletTable
;   input:  none
;   output: HL => Start of entry (if one was found)
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
;   input:  none
;   output: none
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
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        ld      hl,sprBullet
        call    drawSprite
endDrawBulletsLoop:
        pop     bc
        pop     hl
        ld      de,BULLET_ENTRY_SIZE
        add     hl,de
        djnz    drawBulletsLoop
        ret

;------------------------------------------------
; moveBullets - Move enemy bullets
;   input:  none
;   output: none
;------------------------------------------------
moveBullets:
        ld      ix,bulletTable
        ld      b,MAX_BULLETS
moveBulletsLoop:
        push    bc
        ld      a,(ix+B_DIR)
        or      a
        jr      z,endMoveBulletsLoop
        and     %01111111                       ; mask out bit 7 (used as shield deflection flag)
        dec     a
        ld      b,1
        call    moveDir16
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
; moveDir16 - move an enemy, bullet, etc. based off dir16Offsets
;   input:  A = angle
;           B = delay (0=fast, 1=normal (default for bullets, etc.), 2=slow)
;           IX => object entry
;   output: IX => object entry
;------------------------------------------------
moveDir16:
        ld      e,a
        ld      d,2
        mlt     de
        ; do speed modification
        ld      a,b
        or      a
        jr      nz,md16NotFast
md16Fast:
        ld      hl,md16CalcFast
        jr      md16Move
md16NotFast:
        dec     a
        jr      nz,md16Slow
md16Normal:
        ld      hl,md16CalcNormal
        jr      md16Move
md16Slow:
        ld      hl,md16CalcSlow
md16Move:
        ld      (__md16CalcY),hl
        ld      (__md16CalcX),hl
        ld      hl,dir16Offsets
        add     hl,de
        ex      de,hl
        ld      hl,frame
        ld      a,(de)
__md16CalcY             = $+1
        call    $000000
        add     a,(ix+E_Y)
        ld      (ix+E_Y),a
        inc     de
        ld      a,(de)
__md16CalcX             = $+1
        call    $000000
        add     a,(ix+E_X)
        ld      (ix+E_X),a
        ret
md16CalcSlow:
        bit     0,(hl)
        pop     bc
        ret     z
        push    bc
        sra     a
        bit     1,(hl)
        ret     z
        adc     a,0
        ret
md16CalcNormal:
        sra     a
        bit     0,(hl)
        ret     z
        adc     a,0
        ret
md16CalcFast:
        ret

;------------------------------------------------
; getAngle - get the angle between the player and an enemy
;   input:  IX => Start of enemy entry
;   output: IX => Start of enemy entry
;           A = Angle
;------------------------------------------------
getAngle:
        ; first find the dir16Lookup entry we want
        ld      a,(x)
        sub     (ix+E_X)
        ld      b,a                             ; save for quadrant check
        ABSA()
        ADIV8()
        ld      e,a
        ld      d,12
        mlt     de
        ld      a,(y)
        sub     (ix+E_Y)
        ld      c,a                             ; save for quadrant check
        ABSA()
        ADIV8()
        LDHLA()
        add     hl,de
        ld      de,dir16Lookup
        add     hl,de                           ; HL => dir16Lookup entry
        ld      a,(hl)                          ; A = value within quadrant
        ; now work out quadrant and calculate final angle value
        bit     7,c
        jr      z,gaYPos
gaYNeg:
        bit     7,b
        jr      z,gaDone                        ; Q1 needs no modification
gaQ2:
        sub     8
        neg
        jr      gaDone
gaYPos:
        add     a,8
        bit     7,b
        jr      nz,gaDone
gaQ4:
        sub     8
        neg
gaDone:
        and     $0F
        ret

;------------------------------------------------
; getAngleCardinal - get the angle between the player and an enemy and convert to a cardinal direction
;   input:  IX => Start of enemy entry
;   output: IX => Start of enemy entry
;           A = direction
;------------------------------------------------
getAngleCardinal:
        call    getAngle
        LDHLA()
        ld      de,cardinalTable
        add     hl,de
        ld      a,(hl)
        ret

;------------------------------------------------
; checkEnemyOnScreen - Check to ensure an enemy is still on the screen
;   input:  IX => Start of enemy entry
;   output: IX => Start of enemy entry
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
;   input:  IX => Start of enemy entry
;   output: IX => Start of enemy entry
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
;   input:  IX => Start of bullet entry
;   output: IX => Start of bullet entry
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
