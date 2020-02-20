;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Demon Routines                                                ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; Initialisation
;------------------------------------------------
iniDemon:
        call    clearDemonTable
        ld      hl,D_INI_YX
        ld      (y),hl
        xor     a
        ld      (playerDir),a
        ld      (dCnt),a
        ld      (dFlags),a
        ld      (dHurt),a
        ld      hl,(demon)
        dec     l
        ld      h,3
        mlt     hl
        ld      de,demonIniTable
        add     hl,de
        ld      de,(hl)
        ex      de,hl
        ld      de,finishIniDemon
        push    de
        jp      (hl)
finishIniDemon:
#ifndef INVINCIBLE
        ld      (__demonDamage),a
#endif
        ld      (__doDemon),bc
        ld      (__drawDemon),de
        ld      (__finishedDemon),hl
        ld      (__demonBullet),ix

;------------------------------------------------
; Main Loop
;------------------------------------------------
mainDemonLoop:
        ld      hl,frame
        inc     (hl)
        
        call    keyScan

        ld      hl,hurt
        ld      a,(hl)
        or      a
        jr      z,mdlAfterHurt
        dec     (hl)
mdlAfterHurt:

        call    copyBuffers

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
;;; Demon escape key
        ;bit     kbitGraph,a
        ;jp      nz,demonFinished
;;;
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
__demonDamage                           = $+1
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
checkPOCollisions:
        push    bc
        ld      a,(ix+D_DIR)
        or      a
        jr      z,endCheckPOCollisions
        call    loadBulletToCollide2
        call    checkCollision
        jr      nc,endCheckPOCollisions
        ld      a,(hurt)
        or      a
        jr      nz,endCheckPOCollisions
#ifndef INVINCIBLE
        ld      b,ONE_HEART
        call    calculateDamage
        call    decPlayerHearts
        ld      a,INI_HURT
        ld      (hurt),a
#endif
endCheckPOCollisions:
        pop     bc
        ld      de,DEMON_ENTRY_SIZE
        add     ix,de
        djnz    checkPOCollisions

; Draw demon
__drawDemon                             = $+1
        call    $000000
; Draw demon objects
        call    drawDemonObjects
; Clear left and right sides
        ld      hl,grayMem1
        call    fillSide
        ld      hl,grayMem1+14
        call    fillSide
; Draw player
        call    drawPlayer

        call    showGray

        ld      a,(hearts)
        or      a
        jp      nz,mainDemonLoop
        jp      playerDead

;------------------------------------------------
; Finished
;------------------------------------------------
demonFinished:
        xor     a
        ld      (attacking),a
        ld      (demon),a
        ld      (frame),a
        ld      a,(maxHearts)
        ld      (hearts),a
        ld      hl,(__drawDemon)
        ld      (__drawDemonDeath),hl

; Do demon death animation
        ld      b,60
demonDeathAnimLoop:
        push    bc
        ld      a,b
        cp      30
__drawDemonDeath                        = $+1
        call    nc,$000000                      ; Only draw demon for first half of animation
        pop     bc
        push    bc
        bit     0,b
        jr      nz,noNewDemonExplosion          ; Only do a new explosion animation every 2nd frame
; Start another explosion animation
        ld      b,9
        call    random
        ld      hl,dX
        add     a,(hl)
        push    af
        ld      b,9
        call    random
        ld      hl,dY
        add     a,(hl)
        pop     bc
        ld      c,a
        call    newAnim
noNewDemonExplosion:
        call    drawPlayer
        call    drawAnims
        call    showGray
        call    copyBuffers
        call    updateAnims
        ld      bc,5000
        call    waitBC
        pop     bc
        djnz    demonDeathAnimLoop

; Run routine to get all demon finished values (different for each demon)
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
        ld      hl,demonWarp-1
        jp      warpToMap

;------------------------------------------------
; drawDemon - Draw 16x16 demon sprite
;
; Input:    HL => Sprite
; Output:   None
;------------------------------------------------
drawDemon:
        ld      a,(dHurt)
        or      a
        jr      z,drawDemonStart
        ld      a,(frame)
        bit     0,a
        jr      z,drawDemonStart
        ld      a,OP_SCF
        ld      (__GraySpriteWhite),a
drawDemonStart:
        ld      b,4
        ld      de,(dy)
        ld      ix,demonDrawTable
drawDemonLoop:
        push    bc
        push    hl
        push    de
        push    ix
        ld      b,d
        ld      c,e
        call    graySprite
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
        ld      bc,24
        add     hl,bc
        pop     bc
        djnz    drawDemonLoop
        ld      a,OP_OR_A
        ld      (__GraySpriteWhite),a
        ret

;------------------------------------------------
; drawDemonObjects - Draw demon objects
;
; Input:    None
; Output:   None
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
        ld      b,(ix+D_X)
        ld      c,(ix+D_Y)
__demonBullet                           = $+1
        ld      hl,$000000
        call    graySpriteClip
endDrawDemonObjectsLoop:
        pop     ix
        pop     bc
        ld      de,DEMON_ENTRY_SIZE
        add     ix,de
        djnz    drawDemonObjectsLoop
        ret

;------------------------------------------------
; loadDemonToCollide2 - Load demon info to (collide2)
;
; Input:    None
; Output:   None
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
;
; Input:    None
; Output:   None
;------------------------------------------------
clearDemonTable:
        ld      hl,demonTable
        ld      b,MAX_DEMON_OBJECTS*DEMON_ENTRY_SIZE
        jp      _ld_hl_bz

;------------------------------------------------
; getEmptyDemonEntry - Try to find an empty entry in demonTable
;
; Input:    None
; Output:   HL => Start of entry (if one was found)
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
; moveDemonObjectsNormal - Move all demon objects with standard angle code
;
; Input:   None
; Output:  None
;------------------------------------------------
moveDemonObjectsNormal:
        ld      b,MAX_DEMON_OBJECTS
        ld      ix,demonTable
moveDemonObjectsLoop:
        ld      a,(ix+D_DIR)
        or      a
        jr      z,endMoveDemonObjectsLoop
        call    moveDemonObject
endMoveDemonObjectsLoop:
        ld      de,DEMON_ENTRY_SIZE
        add     ix,de
        djnz    moveDemonObjectsLoop
        ret

;------------------------------------------------
; moveDemonObject - Move a demon object
;
; Input:    IX => Start of object entry
; Output:   IX => Start of object entry
;------------------------------------------------
moveDemonObject:
        ld      l,(ix+D_DIR)
        dec     l
        ld      h,2
        mlt     hl
        ld      de,bulletOffsets
        add     hl,de
        ld      a,(hl)
        add     a,(ix+D_Y)
        ld      (ix+D_Y),a
        inc     hl
        ld      a,(hl)
        add     a,(ix+D_X)
        ld      (ix+D_X),a
        cp      DSXMIN-5
        jr      c,demonObjectOffScreen
        cp      DSXMAX
        jr      nc,demonObjectOffScreen
        ld      a,(ix+E_Y)
        cp      64
        ret     c
        cp      -5
        ret     nc
demonObjectOffScreen:
        ld      (ix+D_DIR),0
        ret

;------------------------------------------------
; getDemonAngle - Get angle between demon & player
;
; Input:   None
; Output:  A = Angle
;------------------------------------------------
getDemonAngle:
        call    swapDemonXY
        ld      ix,dy-1
        call    getAngle
; Fall through to swapDemonXY and return

;------------------------------------------------
; swapDemonXY - Swap Demon X & Y coordinates
;
; Input:   None
; Output:  None
;------------------------------------------------
swapDemonXY:
        ld      hl,(dy)
        ld      e,l
        ld      l,h
        ld      h,e
        ld      (dy),hl
        ret

;------------------------------------------------
; checkDemonOnScreen - Check to make sure Demon is on-screen properly
;
; Input:   None
; Output:  None
;------------------------------------------------
checkDemonOnScreen:
        ld      hl,dy
        ld      a,(hl)
        cp      6*8
        jr      c,demonOnScreen1
        ld      (hl),6*8
demonOnScreen1:
        cp      8
        jr      nc,demonOnScreen2
        ld      (hl),8
demonOnScreen2:
        inc     hl                              ; HL => Demon X pos
        ld      a,(hl)
        cp      128-16-16-8
        jr      c,demonOnScreen3
        ld      (hl),128-16-16-8
demonOnScreen3:
        cp      16+8
        ret     nc
        ld      (hl),16+8
        ret

;------------------------------------------------
; Initialisation routine pointers
;------------------------------------------------
demonIniTable:
.dl     iniHeath,iniDezemon,iniWendeg,iniBelkath,iniAnazar,iniBanchor

.end
