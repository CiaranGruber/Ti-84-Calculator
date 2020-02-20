;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Main Game Loop                                                ;
;                                                               ;
;---------------------------------------------------------------;

checkAreaName:
        ld      a,(area)                        ; A = New area number
        ld      hl,areaNum                      ; HL => Last area number
        ld      b,(hl)                          ; B = Last area number
        ld      (hl),a                          ; Save new area number
        or      a                               ; Check if it's 0
        jr      z,mainLoop                      ; If so, no area name
        cp      b                               ; Check to see if still in same area
        call    nz,showAreaName                 ; If not, show area name

mainLoop:
        ld      a,(demon)                       ; Check if player is abt to fight a demon
        or      a
        jp      nz,iniDemon                     ; If so, initialise and DO IT!

        ld      hl,frame
        inc     (hl)
        
        ld      hl,hurt
        ld      a,(hl)
        or      a
        jr      z,$+3
        dec     (hl)

        call    animateMap

        call    copyBuffers

        call    keyScan                         ; do a key scan

        ld      a,(y)
        add     a,3
        and     %11111000
        add     a,a
        ld      b,a
        ld      a,(x)
        add     a,3
        srl     a
        srl     a
        srl     a
        add     a,b
        ld      (playerOffset),a                ; Save offset in map of player

        ld      a,(attacking)
        or      a
        jr      z,checkPlayerMovement
        inc     a
        jr      nz,afterPlayerMovement          ; Can't move if attacking!
checkPlayerMovement:
        ld      a,(kbdG7)
        push    af
        bit     kbitUp,a
        call    nz,playerUp
        pop     af
        push    af
        bit     kbitDown,a
        call    nz,playerDown
        pop     af
        push    af
        bit     kbitLeft,a
        call    nz,playerLeft
        pop     af
        push    af
        bit     kbitRight,a
        call    nz,playerRight
        pop     af
        or      a
        jr      z,afterPlayerMovement
        ld      hl,walkCnt
        inc     (hl)
afterPlayerMovement:
        ld      a,(kbdG2)
        bit     kbitAlpha,a
        jr      z,afterCheckPeopleChests
        call    checkPeople                     ; Check to see if there's a person to talk to
        call    checkChests                     ; Check to see if there's a chest to open
afterCheckPeopleChests:
        ld      a,(kbdG6)
        bit     kbitClear,a
        jp      nz,quit
        ld      a,(kbdG1)
        bit     kbitMode,a
        jp      nz,showInventoryScreen
        bit     kbit2nd,a
        ld      hl,afterAttacking
        jp      nz,tryAttacking
        xor     a
        ld      (attacking),a

afterAttacking:
        ld      a,(attacking)
        or      a
        jr      z,afterCheckStones
        inc     a
        jr      z,afterCheckStones
        ld      a,(ringOfMight)                 ; Check if player has Ring Of Might
        or      a
        jr      z,afterCheckStones              ; If not, can't crush anything
        ld      bc,3                            ; BC = 3 tiles to check
        ld      a,(ringOfThunder)               ; Check if player has Ring Of Thunder
        or      a
        jr      z,checkStones                   ; If not, only check stone tiles
        ld      bc,6                            ; Otherwise, 6 tiles to check (3 stone, 3 rock)
checkStones:
        push    bc                              ; Save for later usage
        ld      a,(playerDir)
        add     a,a
        ld de,0 \ ld e,a
        ld      hl,swordCoords
        add     hl,de
        ld      bc,(y)
        call    _setBCUTo0
        ld      a,b
        add     a,(hl)
        ld      b,a
        ld      a,c
        inc     hl
        add     a,(hl)
        ld      c,a
        ld      (__stoneCoords),bc
        ld      l,a
        ld      a,b
        call    getTile
        ex      de,hl
        ld      hl,stoneRockTiles
        pop     bc                              ; BC = Number of tiles to check, depending on which Ring player has
        cpir
        jr      nz,afterCheckStones
        ld      hl,replaceStoneRockTiles
        add     hl,bc
        ld      a,(hl)
        ld      (de),a
        ld      b,a
__stoneCoords                           = $+1
        ld      hl,$000000
        srl     h
        srl     h
        srl     h
        srl     l
        srl     l
        srl     l
        ld      a,l
        add     a,a
        add     a,a
        add     a,a
        add     a,a
        add     a,h
        ld      c,a
        ld      a,b
        call    animateMapSprite
afterCheckStones:
; Check warps
        ld      a,(numWarps)
        or      a
        jr      z,afterCheckWarps
        ld      b,a
        ld      hl,warps
        ld      a,(playerOffset)
        ld      de,4
checkWarps:
        cp      (hl)                            ; Compare playerOffset to warp offset
        jp      z,warpToMap
        add     hl,de
        djnz    checkWarps
afterCheckWarps:
        ld      a,(frame)                       ; Get frame counter
        and     $0F                             ; Only try this on every 16th frame
        call    z,makeEnemy                     ; Try making an enemy

        ld      a,(frame)
        bit     0,a
        call    z,moveBullets                   ; Move enemy bullets (every 2nd frame)
        call    moveEnemies                     ; Move enemies
        call    updateAnims                     ; Update animations

        call    checkPlayerEnemyCollisions      ; Check player/enemy collisions
        call    checkPlayerBulletCollisions     ; Check player/bullet collisions
        call    checkSwordEnemyCollisions       ; Check sword/enemy collisions

        call    drawBullets                     ; Draw enemy bullets
        call    drawEnemies                     ; Draw enemies
        call    drawAnims                       ; Draw animations
        call    drawPlayer                      ; Draw player

        call    showGray                        ; Copy finished frame to LCD

        ld      a,(hearts)
        or      a
        jp      nz,mainLoop                     ; Can only keep playing if still alive!
        jp      playerDead

.end
