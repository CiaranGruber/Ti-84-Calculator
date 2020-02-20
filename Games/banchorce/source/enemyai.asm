;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Enemy AI Scripts                                              ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; All enemy AI scripts follow
;
; Input:    IX => Start of enemy entry
; Output:   IX => Start of enemy entry
;------------------------------------------------

;------------------------------------------------
; aiFollowPlayer - Follow the player (can walk over walls)
;------------------------------------------------
aiFollowPlayer:
        call    checkEnemySpeed
        ret     nz
        ld      a,(aiCnt)
        cp      8
        jr      nc,aifpTryVFirst
aifpTryHFirst:
        call    tryMoveEnemyHorizontal
        jr      nc,aifpDone
        call    tryMoveEnemyVertical
        jr      aifpDone
aifpTryVFirst:
        call    tryMoveEnemyVertical
        jr      nc,aifpDone
        call    tryMoveEnemyHorizontal
aifpDone:
        ld      a,(aiCnt)
        inc     a
        and     $0F
        ld      (aiCnt),a
        ret

;------------------------------------------------
; aiFollowPlayerHitWalls - Follow the player (can't walk over walls)
;------------------------------------------------
aiFollowPlayerHitWalls:
        xor     a
        ld      (__enemyGetTile),a
        call    aiFollowPlayer
        ld      a,$AF                           ; A = "xor a"
        ld      (__enemyGetTile),a
        ret

;------------------------------------------------
; aiCircular - Move in a circle
;------------------------------------------------
aiCircular:
        call    checkEnemySpeed
        ret     nz
        ld      hl,(aiCnt)
        ld      h,2
        mlt     hl
        ld      de,circleTable
        add     hl,de
        ld      a,(hl)
        add     a,(ix+E_Y)
        ld      (ix+E_Y),a
        inc     hl
        ld      a,(hl)
        add     a,(ix+E_X)
        ld      (ix+E_X),a
        ld      a,(aiCnt)
        inc     a
        cp      CIRCLE_MAX
        jr      nz,saveCircleCnt
        xor     a
saveCircleCnt:
        ld      (aiCnt),a
        ret

;------------------------------------------------
; aiShoot - Shoot at player
;------------------------------------------------
aiShoot:
        ld      b,100
        call    random
        cp      98
        ret     c
        call    getEmptyBulletEntry
        ret     c
        push    hl
        call    getAngle
        pop     hl
        inc     a
        ld      (hl),a
        inc     hl
        ld      a,(ix+E_X)
        ld      (hl),a
        inc     hl
        ld      a,(ix+E_Y)
        ld      (hl),a
        ret

;------------------------------------------------
; aiJump - Jump
;------------------------------------------------
aiJump:
        ld      a,(aiOff)
        or      a
        jr      nz,continueJump
        ld      b,30
        call    random
        cp      29
        ret     c
        xor     a
        ld      (aiCnt),a
        inc     a
        ld      (aiOff),a
continueJump:
        ld      a,(aiCnt)
        or a \ sbc hl,hl \ ld l,a
        ld      de,jumpTable
        add     hl,de
        ld      a,(hl)
        add     a,(ix+E_Y)
        ld      (ix+E_Y),a
        ld      hl,aiCnt
        inc     (hl)
        ld      a,(hl)
        cp      JUMP_MAX
        ret     c
        xor     a
        ld      (aiOff),a
        ret

;------------------------------------------------
; aiRandomMovement - Move enemy in random directions (only 4 directions)
;------------------------------------------------
aiRandomMovement:
        call    checkEnemySpeed
        ret     nz
        call    checkEnemyOnScreen
        jr      nc,doRandomMovement
        ld      (ix+E_DIR),0
        ret
doRandomMovement:
        ld      a,(aiCnt)
        or      a
        jr      nz,randomMoveContinue
        ld      b,4
        call    random
        inc     a
        ld      (ix+E_DIR),a
        ld      a,8
        ld      (aiCnt),a
        ret
randomMoveContinue:
        dec     a
        ld      (aiCnt),a
        ld      e,(ix+E_DIR)
        dec     e
        ld      d,3
        mlt     de
__randomDirTable        = $+1
        ld      hl,randomDirTable
        add     hl,de
        ld      de,(hl)
        ex      de,hl
        jp      (hl)
randomDirUp:
        dec     (ix+E_Y)
        ret
randomDirDown:
        inc     (ix+E_Y)
        ret
randomDirLeft:
        dec     (ix+E_X)
        ret
randomDirRight:
        inc     (ix+E_X)
        ret
randomDirTable:
.dl     randomDirUp, randomDirDown, randomDirLeft, randomDirRight

;------------------------------------------------
; aiRandomMovementHitWalls - Same as aiRandomMovement but enemy hits walls
;------------------------------------------------
aiRandomMovementHitWalls:
        xor     a
        ld      (__enemyGetTile),a
        ld      hl,randomDirTableHitWalls
        ld      (__randomDirTable),hl
        call    aiRandomMovement
        ld      hl,randomDirTable
        ld      (__randomDirTable),hl
        ld      a,$AF
        ld      (__enemyGetTile),a
        ret
randomDirTableHitWalls:
.dl     moveEnemyUp, moveEnemyDown, moveEnemyLeft, moveEnemyRight

;------------------------------------------------
; aiFrogMove - Do Frog movement
;------------------------------------------------
aiFrogMove:
        call    checkEnemySpeed
        ret     nz
        call    checkEnemyOnScreen
        jr      nc,okFrogMove
        ld      (ix+E_DIR),0
        ret
okFrogMove:
        ld      hl,aiCnt
        ld      a,(hl)
        or      a
        jr      nz,doFrogMove
        inc     (hl)
        ld      a,(x)
        sub     (ix+E_X)
        jr      c,frogLeft
        ld      (ix+E_DIR),3
        jr      doFrogMove
frogLeft:
        ld      (ix+E_DIR),1
doFrogMove:
        ld      bc,0
        ld      c,(hl)
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
        jr      nc,doCalcFrogValues
        ld      a,$90
        ld      b,0
doCalcFrogValues:
        ld      (__frogAddSub),a
        ld      a,b
        ld      (__frogDir),a
        pop     bc
        push    bc
        ld      hl,frogXTable
        add     hl,bc
        ld      b,(hl)
        ld      a,(ix+E_X)
__frogAddSub    = $
        nop
        ld      (ix+E_X),a
__frogDir       = $+1
        ld      a,$00
        pop     bc
        ld      hl,frogDirTable
        add     hl,bc
        add     a,(hl)
        ld      (ix+E_DIR),a
        ld      hl,aiCnt
        inc     (hl)
        ld      a,(hl)
        cp      FROG_CNT_MAX+1
        ret     c
        ld      (hl),1
        ret

;------------------------------------------------
; aiShoot4Dir - Shoot in one of 4 directions
;------------------------------------------------
aiShoot4Dir:
        ld      b,100
        call    random
        cp      98
        ret     c
        call    getEmptyBulletEntry
        ret     c
        ld      a,(x)
        sub     (ix+E_X)
        jr      nc,ais4AbsX
        neg
ais4AbsX:
        cp      10
        jr      nc,ais4TryY
        ld      a,(y)
        sub     (ix+E_Y)
        ld      a,16
        jr      nc,ais4IniShoot
        ld      a,15
        jr      ais4IniShoot
ais4TryY:
        ld      a,(y)
        sub     (ix+E_Y)
        jr      nc,ais4AbsY
        neg
ais4AbsY:
        cp      10
        ret     nc
        ld      a,(x)
        sub     (ix+E_X)
        ld      a,14
        jr      nc,ais4IniShoot
        ld      a,13
ais4IniShoot:
        ld      (hl),a
        inc     hl
        ld      a,(ix+E_X)
        ld      (hl),a
        inc     hl
        ld      a,(ix+E_Y)
        ld      (hl),a
        ret

;------------------------------------------------
; aiHorizMove - Horizontal swaying movement
;------------------------------------------------
aiHorizMove:
        call    checkEnemySpeed
        ret     nz
        ld      a,(aiCnt)
        or      a
        jr      z,newHorizFin
        call    checkEnemyOnScreen
        jr      nc,horizOnScreen
        ld      (ix+E_DIR),0
        ret
horizOnScreen:
        ld      c,(ix+E_DIR)
        dec     c
        bit     1,c
        ld      a,1
        jr      z,afterNegHorizX
        neg
afterNegHorizX:
        add     a,(ix+E_X)
        ld      (ix+E_X),a
        ld      de,horizMoveTable1
        ld      b,HORIZ_MAX_1+1
        bit     0,c
        jr      z,afterSelectHorizTable
        ld      de,horizMoveTable2
        ld      b,HORIZ_MAX_2+1
afterSelectHorizTable:
        ld      a,(aiCnt)
        dec     a
        or a \ sbc hl,hl \ ld l,a
        add     hl,de
        ld      a,(hl)
        add     a,(ix+E_Y)
        ld      (ix+E_Y),a
        ld      hl,aiCnt
        inc     (hl)
        ld      a,(hl)
        cp      b
        ret     c
        ld      (hl),1
        ret
newHorizFin:
        ld      a,1
        ld      (aiCnt),a
        ld      b,2
        call    random
        ld      c,a
        ld      a,(x)
        sub     (ix+E_X)
        jr      nc,setNewHoriz
        set     1,c
setNewHoriz:
        inc     c
        ld      (ix+E_DIR),c
        ret

;------------------------------------------------
; aiWait - Pause enemy for a few moments
;------------------------------------------------
aiWait:
        ld      a,(frame)
        and     (ix+E_SPEED)
        ret     nz
        ld      a,(aiOff)
        or      a                               ; Has other AI slot already been disabled?
        jr      z,checkReadyWait                ; If not, check to see if it's time to wait ;)
        ld      hl,aiCnt
        inc     (hl)                            ; Increment AI counter
        ld      a,(hl)
        cp      8                               ; Have we waited long enough?
        ret     c                               ; If not, don't re-enable other AI slot
        xor     a
        ld      (aiOff),a                       ; Otherwise, re-enable other AI slot
        ret                                     ; And leave
checkReadyWait:
        ld      a,(aiCntOther)                  ; Get other AI counter
        and     %00000111
        ret     nz                              ; If it isn't evenly divisible by 8, don't start waiting
        ld      (aiCnt),a                       ; Reset this AI counter
        inc     a
        ld      (aiOff),a                       ; Disable other AI slot
        ret

;------------------------------------------------
; Pointers to all AI scripts
;------------------------------------------------
aiTable:
.dl     aiFollowPlayer,aiFollowPlayerHitWalls,aiCircular,aiShoot,aiJump
.dl     aiRandomMovement,aiRandomMovementHitWalls,aiFrogMove,aiShoot4Dir,aiHorizMove
.dl     aiWait

.end
