;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Enemy AI Scripts                                              ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; All enemy AI scripts follow
;   input:  IX => Start of enemy entry
;   output: IX => Start of enemy entry
;------------------------------------------------

;------------------------------------------------
; aiKnightNoShoot - early version of the Knight that just wanders (no shooting)
;   uses:   enemyWander
;------------------------------------------------
aiKnightNoShoot:
        call    despawnOffScreen
        ret     c
        ld      a,(frame)
        bit     0,a
        call    z,enemyWander
        ret

;------------------------------------------------
; aiKnight - standard Knight that wanders and occasionally pauses to shoot in a cardinal direction
; aiTroll has identical behaviour
;   uses:   enemyWander
;           enemyShoot
;           E_PAUSECNT (counter for pausing to shoot)
;------------------------------------------------
aiKnight:
aiTroll:
        call    despawnOffScreen
        ret     c
        ld      hl,getAngleCardinal
        ld      de,enemyWander
        ld      a,50
aiKnightCommon:
        ld      (__enemyShootAngle),hl
        ld      (__knightWander),de
        ld      (__knightPauseCeiling),a
        ld      a,(ix+E_PAUSECNT)
        or      a
        jr      nz,aiKnightPaused               ; enemy currently paused
        call    checkEnemyTileAligned
        jr      nz,aiKnightContinueWander       ; if not tile aligned, continue the wandering
__knightPauseCeiling    = $+1
        ld      b,$00
        call    random
        or      a
        jr      nz,aiKnightContinueWander       ; 1-in-B chance of starting a pause, otherwise continue wandering
aiKnightStartPause:
        ld      (ix+E_PAUSECNT),50
aiKnightPaused:
        dec     (ix+E_PAUSECNT)
        ret     nz
        jp      enemyShoot
aiKnightContinueWander:
        ld      a,(frame)
        bit     0,a
__knightWander          = $+1
        call    z,$000000
        call    enemyDirToFrame
        ret

;------------------------------------------------
; aiKnightAim - endgame Knight that wanders and occasionally pauses to shoot
;   uses:   aiKnight
;------------------------------------------------
aiKnightAim:
        call    despawnOffScreen
        ret     c
        ld      hl,getAngle
        ld      de,enemyWander
        ld      a,50
        jr      aiKnightCommon

;------------------------------------------------
; aiOctopus - jump on the spot and occasionally shoot at player
;   uses:   enemyJump
;           enemyShoot
;------------------------------------------------
aiOctopus:
        call    enemyJump
        ld      hl,getAngle
        ld      (__enemyShootAngle),hl
        ld      a,(ix+E_JUMPCNT)
        or      a
        ret     nz                              ; don't shoot if mid-jump
        ld      b,200
        call    random
        or      a
        ret     nz
        jp      enemyShoot

;------------------------------------------------
; aiPotatoBug - chase the player every 2nd frame
; aiMummy has identical behaviour
;   uses:   enemyFollow
;------------------------------------------------
aiPotatoBug:
aiMummy:
        call    despawnOffScreen
        ret     c
        ld      a,(frame)
        bit     0,a
        call    z,enemyFollow
        call    enemyDirToFrame
        ret

;------------------------------------------------
; aiJellyfish - chase the player, but pause between each tile
;   uses:   enemyFollow
;           E_PAUSECNT (counter for pausing between tiles)
;------------------------------------------------
aiJellyfish:
        call    despawnOffScreen
        ret     c
        ld      a,20
        ld      c,OP_CALLZ
aiJellyfishCommon:
        ld      (__jellyfishPause),a
        ld      a,c
        ld      (__jellyfishSpeed),a
        ld      a,(ix+E_PAUSECNT)
        or      a
        jr      nz,aiJellyfishPaused
        call    checkEnemyTileAligned
        jr      nz,aiJellyfishFollow
__jellyfishPause        = $+1
        ld      b,20
        call    random
        add     a,30
        ld      (ix+E_PAUSECNT),a
aiJellyfishPaused:
        dec     (ix+E_PAUSECNT)
        ld      a,(ix+E_PAUSECNT)
        and     %11111110
        ret     nz
aiJellyfishFollow:
        ld      a,(frame)
        bit     0,a
__jellyfishSpeed        = $
        call    z,enemyFollow
        call    enemyDirToFrame
        ret

;------------------------------------------------
; aiBat - chase player using the 16 directions in arc patterns by slowing down when it needs to alter it's trajectory and speeding up when it's on course
;       this is a unique behaviour used only by Bats
;   uses:   E_SPEED (used to keep track of how fast the Bat is moving
;------------------------------------------------
aiBat:
        call    despawnOffScreen
        ret     c
        ; first, check if E_SPEED has been initialised (only happens once per Bat)
        ld      a,(ix+E_SPEED)
        or      a
        jr      nz,aiBatSpeedSet
        ; it's a brand new Bat, initialise E_SPEED and E_DIR
        ld      (ix+E_SPEED),32
        call    getAngle
        inc     a
        ld      (ix+E_DIR),a
aiBatSpeedSet:
        ; first, check if the Bat is heading towards the player already
        call    getAngle
        ld      b,(ix+E_DIR)
        dec     b
        call    aiBatCalcAngleDiff
        cp      2
        jr      c,aiBatSpeedUp                  ; if angle is off by 1 or less, speed up and keep current direction
        cp      4
        jr      c,aiBatAlterDir                 ; if angle is only off by 3 or less, maintain current speed and adjust angle by 1
        ; otherwise, slow down before adjusting angle
aiBatSlowDown:
        ld      a,(frame)
        and     %00000001
        jr      nz,aiBatAlterDir                ; can only slow down every 2nd frame
        ld      a,(ix+E_SPEED)
        cp      32
        jr      z,aiBatAlterDir                 ; already at min speed
        inc     a
        ld      (ix+E_SPEED),a
aiBatAlterDir:
        ld      a,(frame)
        and     %00000011
        jr      nz,aiBatMove                    ; can only alter direction every 4th frame
        ld      e,(ix+E_DIR)
        dec     e
        ld      d,16
        mlt     de                              ; dir16Turn row offset
        ld      hl,0
        ld      l,c
        add     hl,de
        ld      de,dir16Turn
        add     hl,de
        ld      a,(hl)                          ; A = new direction
        inc     a
        ld      (ix+E_DIR),a
        jr      aiBatMove
aiBatSpeedUp:
        ld      a,(ix+E_SPEED)
        cp      8
        jr      z,aiBatMove                     ; already at max speed
        dec     a
        ld      (ix+E_SPEED),a
aiBatMove:
        ld      a,(ix+E_DIR)
        dec     a
        ld      b,(ix+E_SPEED)
        srl     b
        srl     b
        srl     b
        dec     b
        call    moveDir16
        ret
aiBatCalcAngleDiff:
        ld      c,a
        sub     b
        ABSA()
        cp      8
        ret     c
        sub     16
        ABSA()
        ret

;------------------------------------------------
; aiSnake - chase the player and occasionally jump
;   uses:   enemyFollow
;           enemyJump
;------------------------------------------------
aiSnake:
        call    despawnOffScreen
        ret     c
        call    enemyJump
        ld      a,(ix+E_JUMPCNT)
        or      a
        ret     nz                              ; don't follow if mid-jump
        ld      a,(frame)
        bit     0,a
        call    z,enemyFollow
        call    enemyDirToFrame
        ret

;------------------------------------------------
; aiBee - move around in a circle either clockwise or counter clockwise, and in one of 3 radii
;       this is a unique behaviour used only by Bees
;   uses:   E_SPEED (used to determine the circle radius by how often the Bee changes it's angle)
;           E_FLAGS (bit 0 is the circle direction, either CW or CCW)
;------------------------------------------------
aiBee:
        call    despawnOffScreen
        ret     c
        ; first, check if E_SPEED has been set (not zero), this only happens once per Bee
        ld      a,(ix+E_SPEED)
        or      a
        ld      c,a
        jr      nz,aiBeeSpeedSet                ; if so, skip this next bit
        ; choose a random speed value (will either be %00000001, %00000011 or %00000111)
        ; this value will cause the Bee to change it's direction every 2nd, 4th or 8th frame, to get the "random" circle radii
        ld      b,3
        call    random
        inc     a
        ld      b,a
        xor     a
        ld      c,1
aiBeeCalcSpeed:
        or      c
        rlc     c
        djnz    aiBeeCalcSpeed
        ld      c,a
        ld      (ix+E_SPEED),c
        ; choose either CW or CCW direction
        ld      b,2
        call    random
        ld      (ix+E_FLAGS),a
aiBeeSpeedSet:
        ld      c,-1
        bit     0,(ix+E_FLAGS)
        jr      z,aiBeeCheckFrame
        ld      c,1
aiBeeCheckFrame:
        ld      a,(frame)
        and     (ix+E_SPEED)
        ld      a,(ix+E_DIR)
        jr      nz,aiBeeMove
        dec     a
        add     a,c
        and     $0F
        inc     a
        ld      (ix+E_DIR),a
aiBeeMove:
        dec     a
        ld      b,1
        call    moveDir16
aiBeeShoot:
        ld      b,200
        call    random
        or      a
        ret     nz
        ld      hl,getAngle
        ld      (__enemyShootAngle),hl
        jp      enemyShoot

;------------------------------------------------
; aiFrog - jump across the screen either left or right
;       this is a unique behaviour used only by Frogs
;   uses:   E_JUMPCNT (counter for the various tables used to calculate the jump)
;------------------------------------------------
aiFrog:
        ld      a,(frame)
        bit     0,a
        ret     nz
        call    despawnOffScreen
        ret     c
        ld      a,(ix+E_JUMPCNT)
        or      a
        jr      nz,aiFrogContinue
        inc     (ix+E_JUMPCNT)
        ld      a,(x)
        sub     (ix+E_X)
        jr      c,aiFrogLeft
aiFrogRight:
        ld      (ix+E_DIR),3
        jr      aiFrogContinue
aiFrogLeft:
        ld      (ix+E_DIR),1
aiFrogContinue:
        ld      bc,0
        ld      c,(ix+E_JUMPCNT)
        dec     c
        push    bc
        ld      hl,frogYTable
        add     hl,bc
        ld      a,(hl)
        add     a,(ix+E_Y)
        ld      (ix+E_Y),a
        ld      a,(ix+E_DIR)
        cp      3
        ld      a,$80
        ld      b,2
        jr      nc,aiFrogCalcValues
        ld      a,$90
        ld      b,0
aiFrogCalcValues:
        ld      (__aiFrogAddSub),a
        ld      a,b
        ld      (__aiFrogDir),a
        pop     bc
        push    bc
        ld      hl,frogXTable
        add     hl,bc
        ld      b,(hl)
        ld      a,(ix+E_X)
__aiFrogAddSub          = $
        nop
        ld      (ix+E_X),a
__aiFrogDir             = $+1
        ld      a,$00
        pop     bc
        ld      hl,frogDirTable
        add     hl,bc
        add     a,(hl)
        ld      (ix+E_DIR),a
        call    enemyDirToFrame
        inc     (ix+E_JUMPCNT)
        ld      a,(ix+E_JUMPCNT)
        cp      FROG_CNT_MAX+1
        ret     c
        ld      (ix+E_JUMPCNT),1
        ret

;------------------------------------------------
; aiSpider - wanders with no clipping and occasionally pauses to shoot
;   uses:   aiKnight
;------------------------------------------------
aiSpider:
        call    despawnOffScreen
        ret     c
        ld      hl,getAngle
        ld      de,enemyWanderNoClip
        ld      a,100
        jp      aiKnightCommon

;------------------------------------------------
; aiPigmySkeleton - chase the player fast
;   uses:   enemyFollow
;------------------------------------------------
aiPigmySkeleton:
        call    despawnOffScreen
        ret     c
        call    enemyFollow
        call    enemyDirToFrame
        ret

;------------------------------------------------
; aiPigmySkeletonJump - chase the player fast and occasionally jump
;   uses:   enemyFollow
;           enemyJump
;------------------------------------------------
aiPigmySkeletonJump:
        call    despawnOffScreen
        ret     c
        call    enemyJump
        ld      a,(ix+E_JUMPCNT)
        or      a
        call    z,enemyFollow                   ; don't follow if mid-jump
        call    enemyDirToFrame
        ret

;------------------------------------------------
; aiMudman - chase the player every 2nd frame with no wall clipping
; aiShadowBeast has identical behaviour
;   uses:   enemyFollow
;------------------------------------------------
aiMudman:
aiShadowBeast:
        ld      a,(frame)
        bit     0,a
        call    z,enemyFollowNoClip
        call    enemyDirToFrame
        ret

;------------------------------------------------
; aiTreeMonster - chase the player like Jellyfish but walks faster and has potential for longer pauses between each tile
;   uses:   aiJellyfish
;------------------------------------------------
aiTreeMonster:
        call    despawnOffScreen
        ret     c
        ld      a,80
        ld      c,OP_CALL
        jp      aiJellyfishCommon

;------------------------------------------------
; aiDeathLord - swoop up/down and left/right around the screen
;   uses:   E_JUMPCNT (to keep track of the horizontal movement)
;           E_SPEED (assigned a random number after spawn to use as an offset for frame counter to track vertical movement)
;           E_FLAGS (to track up/down and left/right directions)
;------------------------------------------------
aiDeathLord:
        call    despawnOffScreen
        ret     c
        ; first, check if E_SPEED has been set (not zero), this only happens once per Death Lord
        ld      a,(ix+E_SPEED)
        or      a
        jr      nz,aiDeathLordSpeedSet
        ; choose a random speed value between 1-16
        ld      b,16
        call    random
        inc     a
        ld      (ix+E_SPEED),a
aiDeathLordSpeedSet:
        ; horizontal movement, works off E_JUMPCNT
        ld      a,(ix+E_JUMPCNT)
        LDHLA()
        ld      de,deathLordHoriz
        add     hl,de
        inc     a
        cp      DEATHLORD_HORIZ_MAX
        jr      nz,aiDeathLordSaveCount
        ld      a,(ix+E_FLAGS)
        xor     %00000001
        ld      (ix+E_FLAGS),a
        xor     a
aiDeathLordSaveCount:
        ld      (ix+E_JUMPCNT),a
        bit     0,(ix+E_FLAGS)
        ld      a,(hl)
        jr      nz,aiDeathLordHoriz
        neg
aiDeathLordHoriz:
        add     a,(ix+E_X)
        ld      (ix+E_X),a
        ; vertical movement, works off the frame counter with E_SPEED being a random offset for each Death Lord
        ld      a,(frame)
        add     a,(ix+E_SPEED)
        and     %00011111
        jr      nz,aiDeathLordAfterToggle
        ld      c,a
        ld      a,(ix+E_FLAGS)
        xor     %00000010
        ld      (ix+E_FLAGS),a
        ld      a,c
aiDeathLordAfterToggle:
        LDHLA()
        ld      de,deathLordVert
        add     hl,de
        bit     1,(ix+E_FLAGS)
        ld      a,(hl)
        jr      nz,aiDeathLordVert
        neg
aiDeathLordVert:
        add     a,(ix+E_Y)
        ld      (ix+E_Y),a
        ret

;------------------------------------------------
; aiKoranda - chase the player every 2nd frame with no wall clipping, and occasionally shoot
;   uses:   enemyFollow
;           enemyShoot
;------------------------------------------------
aiKoranda:
        ld      a,(frame)
        bit     0,a
        call    z,enemyFollowNoClip
        ld      b,200
        call    random
        or      a
        ret     nz
        ld      hl,getAngle
        ld      (__enemyShootAngle),hl
        jp      enemyShoot




; below are common routines used by various AI scripts

;------------------------------------------------
; enemyWander - enemy wanders around in any cardinal direction
;------------------------------------------------
enemyWander:
        call    enemySetClip
enemyWanderCommon:
        xor     a
        ld      (dirFlags),a
        call    checkEnemyTileAligned
        jp      nz,moveEnemyDir                 ; if enemy is not tile aligned, continue moving in the direction they're facing
        ; pick a new direction and try to move in it (with a chance enemy will decide to stay idle)
        ld      b,6
        call    random                          ; 0 <= A <= 5
        or      a
        jp      z,moveEnemyUp
        dec     a
        jp      z,moveEnemyDown
        dec     a
        jp      z,moveEnemyLeft
        dec     a
        jp      z,moveEnemyRight
        ret

;------------------------------------------------
; enemyWanderNoClip - enemy wanders around in any cardinal direction without wall clipping
;------------------------------------------------
enemyWanderNoClip:
        call    enemySetNoClip
        jr      enemyWanderCommon

;------------------------------------------------
; enemyFollow - enemy follows the player
;------------------------------------------------
enemyFollow:
        call    enemySetClip
enemyFollowCommon:
        xor     a
        ld      (dirFlags),a
        call    checkEnemyTileAligned
        jp      nz,moveEnemyDir                 ; if enemy is not tile aligned, continue moving in the direction they're facing
        ; pick a new direction based on player position
        ; get x-axis position difference
        ld      a,(x)
        sub     (ix+E_X)
        ld      d,a
        ABSA()
        ld      b,a
        ; get y-axis position difference
        ld      a,(y)
        sub     (ix+E_Y)
        ld      e,a
        ABSA()
        ; which is bigger?
        push    de                              ; save x & y differences for later
        ld      hl,enemyFollow1stAttempt        ; RET location for first move attempt
        cp      b
        jr      nc,enemyFollowVert              ; if y difference is bigger, try to move vertical
enemyFollowHoriz:
        ; going to try to move horizontally, check if left or right
        ld      b,0                             ; B = moving horizontally
        push    bc                              ; save it
        bit     7,d
        ld      a,3
        jr      z,enemyFollowTryMove
        ld      a,2
        jr      enemyFollowTryMove
enemyFollowVert:
        ; going to try to move vertically, check if up or down
        ld      b,1                             ; B = moving vertically
        push    bc
        bit     7,e
        ld      a,1
        jr      z,enemyFollowTryMove
        xor     a

enemyFollowTryMove:
        push    hl                              ; where to RET to after trying to move
        or      a
        jp      z,moveEnemyUp
        dec     a
        jp      z,moveEnemyDown
        dec     a
        jp      z,moveEnemyLeft
        jp      moveEnemyRight

enemyFollow1stAttempt:
        pop     bc                              ; B = axis flag
        pop     de                              ; D = x diff, E = y diff
        ret     nc                              ; if moved successfully, nothing else to do
        ld      hl,enemyFollow2ndAttempt
        push    hl                              ; where to RET to after trying to move a 2nd time
        ld      a,b
        or      a
        jr      z,enemyFollowVert
        jr      enemyFollowHoriz

enemyFollow2ndAttempt:
        pop     bc                              ; clear stack
        ret     nc                              ; if moved successfully, nothing else to do
        ; if execution gets here, the enemy has tried and failed to move closer to the player on both axes
        ; whichever two directions were attemped will have had their bits set in dirFlags
        call    moveEnemyUp
        call    c,moveEnemyDown
        call    c,moveEnemyLeft
        call    c,moveEnemyRight
        ret

;------------------------------------------------
; enemyFollowNoClip - enemy follows the player without wall clipping
;------------------------------------------------
enemyFollowNoClip:
        call    enemySetNoClip
        jp      enemyFollowCommon

;------------------------------------------------
; enemyShoot - try to shoot at the player
;   uses:   (__enemyShootAngle) should be either getAngle or getAngleCardinal
;------------------------------------------------
enemyShoot:
        call    getEmptyBulletEntry
        ret     c
        push    hl
__enemyShootAngle       = $+1
        call    $000000
        pop     hl
        inc     a
        ld      (hl),a
        inc     hl
        ld      a,(ix+E_X)
        inc     a
        ld      (hl),a
        inc     hl
        ld      a,(ix+E_Y)
        inc     a
        ld      (hl),a
        ret

;------------------------------------------------
; enemyJump - occasionally jump in place (used by snakes, octopii and endgame pigmy skeletons
;   uses:   E_JUMPCNT (counter for jumpTable)
;------------------------------------------------
enemyJump:
        ld      a,(ix+E_JUMPCNT)
        or      a
        jr      nz,enemyJumpContinue
        ld      b,40
        call    random
        or      a                               ; 1-in-B chance of jumping
        ret     nz
        ; A = 0 here for the first jump frame
enemyJumpContinue:
        LDHLA()
        ld      de,jumpTable
        add     hl,de
        ld      a,(hl)
        add     a,(ix+E_Y)
        ld      (ix+E_Y),a
        inc     (ix+E_JUMPCNT)
        ld      a,(ix+E_JUMPCNT)
        cp      JUMP_MAX
        ret     c
        ld      (ix+E_JUMPCNT),0
        ret

;------------------------------------------------
; checkEnemyTileAligned - check if enemy is tile aligned
;   input:  IX => enemy entry
;   output: IX => enemy entry
;           Z if tile aligned, NZ if not
;------------------------------------------------
checkEnemyTileAligned:
        ld      a,(ix+E_X)
        and     %00000111
        ret     nz
        ld      a,(ix+E_Y)
        and     %00000111
        ret

;------------------------------------------------
; moveEnemyDir - move enemy in a cardinal direction according to direction value
;   input:  IX => enemy entry
;   output: IX => enemy entry
;------------------------------------------------
moveEnemyDir:
        ld      a,(ix+E_DIR)
        dec     a
        jp      z,moveEnemyUp
        dec     a
        jp      z,moveEnemyDown
        dec     a
        jp      z,moveEnemyLeft
        dec     a
        jp      z,moveEnemyRight
        ret

;------------------------------------------------
; moveEnemyUp - try to move an enemy up
;   input:  IX => Start of enemy entry
;   output: IX => Start of enemy entry
;           CA = 1 if couldn't move
;------------------------------------------------
moveEnemyUp:
        ld      hl,dirFlags
        bit     0,(hl)
        scf
        set     0,(hl)
        ret     nz                              ; leave if this direction has already been attempted, with carry set to signify move failed
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
; moveEnemyDown - try to move an enemy down
;   input:  IX => Start of enemy entry
;   output: IX => Start of enemy entry
;           CA = 1 if couldn't move
;------------------------------------------------
moveEnemyDown:
        ld      hl,dirFlags
        bit     1,(hl)
        scf
        set     1,(hl)
        ret     nz
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
; moveEnemyLeft - try to move an enemy left
;   input:  IX => Start of enemy entry
;   output: IX => Start of enemy entry
;           CA = 1 if couldn't move
;------------------------------------------------
moveEnemyLeft:
        ld      hl,dirFlags
        bit     2,(hl)
        scf
        set     2,(hl)
        ret     nz
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
; moveEnemyRight - try to move an enemy right
;   input:  IX => Start of enemy entry
;   output: IX => Start of enemy entry
;           CA = 1 if couldn't move
;------------------------------------------------
moveEnemyRight:
        ld      hl,dirFlags
        bit     3,(hl)
        scf
        set     3,(hl)
        ret     nz
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
; enemySetClip - modify enemyGetTile for wall clipping
;   input:  none
;   output: none
;------------------------------------------------
enemySetClip:
        xor     a
        ld      (__enemyGetTile),a              ; load "nop"
        ret

;------------------------------------------------
; enemySetNoClip - modify enemyGetTile for NO wall clipping
;   input:  none
;   output: none
;------------------------------------------------
enemySetNoClip:
        ld      a,OP_XOR_A
        ld      (__enemyGetTile),a              ; load "xor a"
        ret

;------------------------------------------------
; enemyGetTile - same as getTile, but can be hacked for flying enemies
;   input:  A = X Coord
;           L = Y Coord
;   output: HL => Tile
;           A = Tile
;------------------------------------------------
enemyGetTile:
        call    getTile
__enemyGetTile          = $
        nop                                     ; this instruction can be changed to "xor a" for flying enemies
        ret

;------------------------------------------------
; despawnOffScreen - despawn enemy if off screen
;   input:  IX => enemy entry
;   output: IX => enemy entry
;           CA = 1 if enemy was despawned
;------------------------------------------------
despawnOffScreen:
        call    checkEnemyOnScreen
        ret     nc
        ld      (ix+E_DIR),0
        ret

;------------------------------------------------
; enemyDirToFrame - convert E_DIR value to E_FRAME value
;   input:  IX => enemy entry
;   output: IX => enemy entry
;------------------------------------------------
enemyDirToFrame:
        ld      a,(ix+E_DIR)
        dec     a
        ld      (ix+E_FRAME),a
        ret

.end
