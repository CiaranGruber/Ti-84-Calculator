;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Map Routines                                                  ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; newMap - set up for new map
;   input:  DE => where to load map to (map meta data will always be written to same location)
;   output: none
;------------------------------------------------
newMap:
        ld      a,(mapNo)
        call    loadMap
        call    clearAnimTable
        call    clearBulletTable
        call    clearEnemyTable
        call    clearOrbTable
        xor     a
        ld      (hurt),a
        ld      a,(enemyType)
        or      a
        ret     z
        dec     a
        ld      l,a
        ld      h,3
        mlt     hl
        ld      de,enemyAI
        add     hl,de
        ld      de,(hl)
        ld      (__enemyAI),de
        ret

;------------------------------------------------
; loadMap - loads a map
;   input:  A = map to load
;           DE => where to load tile data to
;   output: none
;------------------------------------------------
loadMap:
        ld      (__changeListPtr),de
        push    de
        push    af
        ld      hl,mapsFileName
        MOVE9()
        call    _chkfindsym
        call    getDataPtr                      ; DE => start of maps file
        ld      hl,MAPS_OFFSET
        add     hl,de                           ; HL => start of huffman packed map files
        ld      de,nextMap
        pop     bc                              ; B = map number (file number)
        ld      ix,huffTree
        call    huffExtr
        pop     de                              ; DE => where to load unpacked tile data to
        ld      hl,nextMap                      ; HL => unpacked map
        ld      bc,TILE_DATA_SIZE
        ldir                                    ; load tiles
        ld      de,map+TILE_DATA_SIZE
        ld      bc,MAP_META_SIZE
        ldir                                    ; load map meta data
        jp      executeChangeList

;------------------------------------------------
; drawMap - draw the current map
;   input:  none
;   output: none
;------------------------------------------------
drawMap:
        ; set up drawTile for game window
        ld      a,WIN_Y/2
        ld      (__dtY),a
        ld      a,WIN_X/2
        ld      (__dtX),a
        
        push    iy
        ld      iy,map
        ld      d,0
        ld      c,ROWS
dmRow:
        ld      e,0
        ld      b,COLS
dmCol:
        push    bc
        push    de
        ld      l,(iy)
        ld      h,64
        mlt     hl
        ld      bc,tileset
        add     hl,bc                           ; HL => sprite
        call    drawTile
        pop     de
        ld      a,8
        add     a,e
        ld      e,a                             ; E = x position of next column
        inc     iy
        pop     bc
        djnz    dmCol
        ld      a,8
        add     a,d
        ld      d,a                             ; D = y position of next tile
        dec     c
        jr      nz,dmRow
        pop     iy
        ret

;------------------------------------------------
; animateMap - animates tiles on current map
;   input:  none
;   output: none
;------------------------------------------------
animateMap:
        ld      a,(frame)
        and     %00000111
        ret     nz
        ld      de,map
        ld      c,ROWS*COLS
animateMapLoop:
        ld      a,(de)
        ld      b,ANIM_TABLE_SIZE
        ld      hl,animationTable
animateMapSearch:
        cp      (hl)
        inc     hl
        jr      nz,animateMapSearchNext
        ld      a,(hl)
        ld      (de),a
        jr      animateMapNext
animateMapSearchNext:
        inc     hl
        djnz    animateMapSearch
animateMapNext:
        inc     de
        dec     c
        jr      nz,animateMapLoop
        ret

;------------------------------------------------
; upMap - Move up a map
;   input:  none
;   output: none
;------------------------------------------------
upMap:
        ld      a,(upEdge)
        cp      $FF
        ret     z
        ld      (mapNo),a
        ld      de,nextMap
        call    newMap
        pop     hl
        pop     hl
        call    scrollUp
        jp      checkAreaName

;------------------------------------------------
; downMap - Move down a map
;   input:  none
;   output: none
;------------------------------------------------
downMap:
        ld      a,(downEdge)
        cp      $FF
        ret     z
        ld      (mapNo),a
        ld      de,nextMap
        call    newMap
        pop     hl
        pop     hl
        call    scrollDown
        jp      checkAreaName

;------------------------------------------------
; leftMap - Move left a map
;   input:  none
;   output: none
;------------------------------------------------
leftMap:
        ld      a,(leftEdge)
        cp      $FF
        ret     z
        ld      (mapNo),a
        ld      de,nextMap
        call    newMap
        pop     hl
        pop     hl
        call    scrollLeft
        jp      checkAreaName

;------------------------------------------------
; rightMap - Move right a map
;   input:  none
;   output: none
;------------------------------------------------
rightMap:
        ld      a,(rightEdge)
        cp      $FF
        ret     z
        ld      (mapNo),a
        ld      de,nextMap
        call    newMap
        pop     hl
        pop     hl
        call    scrollRight
        jp      checkAreaName

;------------------------------------------------
; scrollUp - scroll up a map one tile at a time
;   input:  none
;   output: none
;------------------------------------------------
scrollUp:
        ld      b,ROWS
        ld      hl,nextMap+TILE_DATA_SIZE-1
        ld      ix,scrollYTable
suLoop:
        push    bc
        push    ix
        push    hl
        ld      hl,map+TILE_DATA_SIZE-1-COLS
        ld      de,map+TILE_DATA_SIZE-1
        ld      bc,TILE_DATA_SIZE-COLS
        lddr
        pop     hl
        ld      bc,COLS
        lddr
        push    hl
        ld      a,(y)
        add     a,(ix)
        ld      (y),a
        ld      hl,walkCnt
        inc     (hl)
        call    drawMap
        call    drawPlayer
        call    vramFlip
        ld      bc,SCROLL_DELAY
        call    waitBC
        pop     hl
        pop     ix
        inc     ix
        pop     bc
        djnz    suLoop
        jr      scrollFinish

;------------------------------------------------
; scrollDown - scroll down a map one tile at a time
;   input:  none
;   output: none
;------------------------------------------------
scrollDown:
        ld      b,ROWS
        ld      hl,nextMap
        ld      ix,scrollYTable

sdLoop:
        push    bc
        push    ix
        push    hl
        ld      hl,map+COLS
        ld      de,map
        ld      bc,TILE_DATA_SIZE-COLS
        ldir
        pop     hl
        ld      bc,COLS
        ldir
        push    hl
        ld      a,(y)
        sub     (ix)
        ld      (y),a
        ld      hl,walkCnt
        inc     (hl)
        call    drawMap
        call    drawPlayer
        call    vramFlip
        ld      bc,SCROLL_DELAY
        call    waitBC
        pop     hl
        pop     ix
        inc     ix
        pop     bc
        djnz    sdLoop
; fall through to scrollFinish

;------------------------------------------------
; scrollFinish - end screen scrolling
;   input:  none
;   output: none
;------------------------------------------------
scrollFinish:
        ld      hl,(y)
        ld      (enterMapCoords),hl
        ret

;------------------------------------------------
; scrollLeft - scroll left a map one tile at a time
;   input:  none
;   output: none
;------------------------------------------------
scrollLeft:
        ld      b,COLS
        ld      hl,nextMap+COLS-1
        ld      ix,scrollXTable
slLoop:
        push    bc
        push    ix
        push    hl
        ld      hl,map+TILE_DATA_SIZE-2
        ld      de,map+TILE_DATA_SIZE-1
        ld      bc,TILE_DATA_SIZE-1
        lddr
        pop hl \ push hl
        ld      b,ROWS
slCopy:
        ld      a,(hl)
        ld      (de),a
        push    de
        ld      de,COLS
        add     hl,de
        ex      (sp),hl
        add     hl,de
        ex      (sp),hl
        pop     de
        djnz    slCopy
        ld      a,(x)
        add     a,(ix)
        ld      (x),a
        ld      hl,walkCnt
        inc     (hl)
        call    drawMap
        call    drawPlayer
        call    vramFlip
        ld      bc,SCROLL_DELAY
        call    waitBC
        pop     hl
        dec     hl
        pop     ix
        inc     ix
        pop     bc
        djnz    slLoop
        jr      scrollFinish

;------------------------------------------------
; scrollRight - scroll right a map one tile at a time
;   input:  none
;   output: none
;------------------------------------------------
scrollRight:
        ld      b,COLS
        ld      hl,nextMap+TILE_DATA_SIZE-COLS
        ld      ix,scrollXTable
srLoop:
        push    bc
        push    ix
        push    hl
        ld      hl,map+1
        ld      de,map
        ld      bc,TILE_DATA_SIZE-1
        ldir
        pop hl \ push hl
        ld      b,ROWS
srCopy:
        ld      a,(hl)
        ld      (de),a
        push    de
        ld      de,-COLS
        add     hl,de
        ex      (sp),hl
        add     hl,de
        ex      (sp),hl
        pop     de
        djnz    srCopy
        ld      a,(x)
        sub     (ix)
        ld      (x),a
        ld      hl,walkCnt
        inc     (hl)
        call    drawMap
        call    drawPlayer
        call    vramFlip
        ld      bc,SCROLL_DELAY
        call    waitBC
        pop     hl
        inc     hl
        pop     ix
        inc     ix
        pop     bc
        djnz    srLoop
        jp      scrollFinish

scrollYTable:
.db 8,7,7,8,7,7,8,7,7,8,7,7
scrollXTable:
.db 8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7

;------------------------------------------------
; warpToMap - warp to a new location
;   input:  HL => Warp details
;   output: none
;------------------------------------------------
warpToMap:
        inc     hl
        ld      a,(hl)
        ld      (mapNo),a
        inc     hl
        inc     a                               ; check if map #255 (boss encounter)
        jp      z,iniBoss                       ; if so, DEW IT!
        ld      b,(hl)
        inc     hl
        ld      c,(hl)
warpToMapLoadMap:
        ld      (y),bc
        ld      (enterMapCoords),bc
        ld      de,map
        call    newMap
        call    fadeOut
        call    drawMap
        call    vramFlip
        call    fadeIn
        jp      checkAreaName

;------------------------------------------------
; getTile - Get a tile from current map
;   input:  A = X
;           L = Y
;   output: HL => Tile
;           A = Tile
;------------------------------------------------
getTile:
        srl     a
        srl     a
        srl     a                               ; A = A / 8
        srl     l
        srl     l
        srl     l                               ; L = L / 8, flow into next routine

;------------------------------------------------
; getBlock - Get a tile from current map
;   input:  A = X / 8
;           L = Y / 8
;   output: HL => Tile
;           A = Tile
;           C = Offset of tile in map data
;------------------------------------------------
getBlock:
        ld      h,16
        mlt     hl
        ld bc,0 \ ld c,a
        add     hl,bc
        ld      c,l                             ; C = Offset
        ld      de,map
        add     hl,de
        ld      a,(hl)
        ret

.end
