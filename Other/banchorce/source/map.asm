;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Map Routines                                                  ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; newMap - Load new map
;
; Input:    None
; Output:   None
;------------------------------------------------
newMap:
        ld      a,(mapNo)
        call    loadMap
        call    clearAnimTable
        call    clearBulletTable
        call    clearEnemyTable
        xor     a
        ld      (hurt),a
        ld      a,INI_HEART_LEVEL
        ld      (heartLevel),a
        ld      a,(enemyType)
        or      a
        ret     z
        bit     7,a                             ; Check high bit
        jr      nz,newDemonMap                  ; If set, it's a demon map
        dec     a
        ld      l,a
        ld      h,2
        mlt     hl
        ld      de,enemyAI
        add     hl,de
        ld      a,(hl)
        ld      (ai1),a
        inc     hl
        ld      a,(hl)
        ld      (ai2),a
        ret

;------------------------------------------------
; newDemonMap - Set up for a new demon map
;
; Input:    A = -(demon number)
; Output:   None
;------------------------------------------------
newDemonMap:
        neg                                     ; Negate A to get demon number
        ld      (demon),a                       ; Save it
        ret

;------------------------------------------------
; loadMap - Loads a map to temp storage on RAM page 1
;
; Input:    A = Map to load
; Output:   None
;------------------------------------------------
loadMap:
        ld      l,a
        ld      h,MAP_SIZE
        mlt     hl
        ld      de,MAPS_OFFSET
        add     hl,de
        push    hl
        ld      hl,mapsFileName
        MOVE9()
        call    _chkfindsym
        call    getDataPtr
        pop     hl
        add     hl,de                           ; HL => map data to load
        ld      de,map
        ld      bc,MAP_SIZE
        ldir
        jp      executeChangeList

;------------------------------------------------
; GrayDrawMap - Draw current map to buffer memory
;
; Author:   David Phillips <david@acz.org>
; Input:    Map => Tile data
;           startMapSprites => 8x8 non-masked grayscale sprites
; Output:   None
;------------------------------------------------
GrayDrawMap:
        ld      hl,Map

;------------------------------------------------
; GrayDrawTileMap - Draw a tile map in grayscale to buffer memory
;
; Author:   David Phillips <david@acz.org>
; Input:    HL => Tilemap to draw
;           startMapSprites => 8x8 non-masked grayscale sprites
; Output:   None
;------------------------------------------------
GrayDrawTileMap:
        ld      (__GrayDrawMapTileP),hl
        ld      hl,Buffer1
        ld      de,Buffer2
        ld      b,8
GrayDrawMapCol:
        push    bc
        ld      b,16
GrayDrawMapRow:
        push    bc
        push    hl
__GrayDrawMapTileP =$+1
        ld      a,($ffff)
        ld      l,a
        ld      h,16
        mlt     hl
        ld      bc,startMapSprites
        add     hl,bc
        push    hl
        pop     ix
        ld      b,8
        ld      hl,(__GrayDrawMapTileP)
        inc     hl
        ld      (__GrayDrawMapTileP),hl
        pop     hl
GrayDrawMapSpr:
        ld      a,(ix+0)
        ld      (hl),a
        ld      a,(ix+8)
        ld      (de),a
        inc     ix
        push    bc
        ld      bc,16
        add     hl,bc
        ex      de,hl 
        add     hl,bc
        ex      de,hl
        pop     bc
        djnz    GrayDrawMapSpr
        ld      bc,-127
        add     hl,bc
        ex      de,hl
        add     hl,bc
        ex      de,hl
        pop     bc
        djnz    GrayDrawMapRow
        ld      bc,112
        add     hl,bc
        ex      de,hl
        add     hl,bc
        ex      de,hl
        pop     bc
        djnz    GrayDrawMapCol
        ret

;------------------------------------------------
; animateMap - Animates tiles on current map
;
; Author:   David Phillips <david@acz.org>
; Input:    None
; Output:   None
;------------------------------------------------
animateMap:
        ld      a,(frame)
        and     %00000111
        jr      nz,animateMapSkip
        ld      de,map
        ld      c,0
animateMapLoop:
        ld      a,(de)
        ld      b,animationTableSize
        ld      hl,animationTable
animateMapSearch:
        cp      (hl)
        inc     hl
        jr      nz,animateMapSearchNext
        ld      a,(hl)
        ld      (de),a
        call    animateMapSprite
        jr      animateMapNext
animateMapSearchNext:
        inc     hl
        djnz    animateMapSearch
animateMapNext:
        inc     de
        inc     c
        ld      a,c
        cp      128
        jr      nz,animateMapLoop
        jr      animateMapDone

;------------------------------------------------
; animateMapSprite - Change a sprite on screen
;
; Author:   David Phillips <david@acz.org>
; Input:    A = Tile to show
;           C = Offset to tile in map data
; Output:   None
;------------------------------------------------
animateMapSprite:
        push    hl
        push    de
        push    bc
        ld l,c \ ld bc,0 \ ld c,l
        ld      l,a
        ld      h,16
        mlt     hl
        ld      ix,startMapSprites
        ex      de,hl
        add     ix,de
        ld      a,c
        and     %11110000
        add     a,a
        ld      l,a
        ld      h,4
        mlt     hl
        ld      a,c
        and     %00001111
        ld      c,a
        add     hl,bc
        ex      de,hl
        ld      hl,Buffer2
        add     hl,de
        ex      de,hl
        ld      bc,Buffer1
        add     hl,bc
        ld      bc,16
        ld      a,8
animateMapSpriteL:
        ld      (__animateMapSpriteC),a
        ld      a,(ix+0)
        ld      (hl),a
        add     hl,bc
        ex      de,hl
        ld      a,(ix+8)
        ld      (hl),a
        add     hl,bc
        ex      de,hl
        inc     ix
__animateMapSpriteC =$+1
        ld      a,0
        dec     a
        jr      nz,animateMapSpriteL
        pop     bc
        pop     de
        pop     hl
        ret 
animateMapSkip:
        ;ei
;        ld      b,2
;delay:
        ;halt
;        djnz    delay
animateMapDone:
        jp      copyBuffers

;------------------------------------------------
; upMap - Move up a map
;
; Input:    None
; Output:   None
;------------------------------------------------
upMap:
        ld      a,(upEdge)
        ld      (mapNo),a
        ld      a,7*8
        ld      (y),a
        call    newMap
        pop     hl
        pop     hl
        ld      hl,(y)
        ld      (enterMapCoords),hl
        call    grayScrollUp
        jp      checkAreaName

;------------------------------------------------
; downMap - Move down a map
;
; Input:    None
; Output:   None
;------------------------------------------------
downMap:
        ld      a,(downEdge)
        ld      (mapNo),a
        xor     a
        ld      (y),a
        call    newMap
        pop     hl
        pop     hl
        ld      hl,(y)
        ld      (enterMapCoords),hl
        call    grayScrollDown
        jp      checkAreaName

;------------------------------------------------
; leftMap - Move left a map
;
; Input:    None
; Output:   None
;------------------------------------------------
leftMap:
        ld      a,(leftEdge)
        ld      (mapNo),a
        ld      a,15*8
        ld      (x),a
        call    newMap
        pop     hl
        pop     hl
        ld      hl,(y)
        ld      (enterMapCoords),hl
        call    grayScrollLeft
        jp      checkAreaName

;------------------------------------------------
; rightMap - Move right a map
;
; Input:    None
; Output:   None
;------------------------------------------------
rightMap:
        ld      a,(rightEdge)
        ld      (mapNo),a
        xor     a
        ld      (x),a
        call    newMap
        pop     hl
        pop     hl
        ld      hl,(y)
        ld      (enterMapCoords),hl
        call    grayScrollRight
        jp      checkAreaName

;------------------------------------------------
; grayScrollSetup - Prepare to scroll screen
;
; Input:    None
; Output:   None
;------------------------------------------------
grayScrollSetup:
        ld      hl,Buffer1                      ; HL => Map background
        ld      de,GrayMem1                     ; DE => Gray mem
        ld      bc,2048                         ; BC = 2048 bytes to copy
        ldir                                    ; Load map background to video
        call    showGray
        jp      grayDrawMap                     ; Draw new map to buffer mem

;------------------------------------------------
; grayScrollUp - Scroll up a map one tile at a time
;
; Input:    None
; Output:   None
;------------------------------------------------
grayScrollUp:
        call    grayScrollSetup                 ; Setup memory to scroll
        ld      a,8                             ; 8 rows to scroll
        ld      hl,buffer1+1023                 ; HL => Last byte of buffer1 mem
        ld      de,buffer2+1023                 ; DE => Last byte of buffer2 mem
        push    de                              ; Save buffer2 pointer
        push    hl                              ; Save buffer1 pointer
grayScrollUpLoop:
        ld      hl,GrayMem1+895                 ; Start at 2nd from bottom tile
        ld      de,GrayMem1+1023                ; Copy to bottom tile
        ld      bc,896                          ; Copy all but one row of tiles
        lddr                                    ; Copy
        ld      hl,GrayMem2+895                 ; Start at 2nd from bottom tile
        ld      de,GrayMem2+1023                ; Copy to bottom tile
        ld      bc,896                          ; Copy all but one row of tiles
        lddr                                    ; Copy
        pop     hl                              ; Restore buffer1 pointer
        ld      de,GrayMem1+127                 ; DE => Old map on video
        ld      bc,128                          ; BC = Copy 8 rows to show one row of tiles
        lddr                                    ; Copy the row of tiles
        ex      (sp),hl                         ; Save buffer1 pointer and restore buffer2 pointer
        ld      de,GrayMem2+127                ; DE => Old map on video
        ld      bc,128                          ; BC = Copy 8 rows to show one row of tiles
        lddr                                    ; Copy the row of tiles
        ex      (sp),hl                         ; Save buffer2 pointer and restore buffer1 pointer
        push    hl                              ; Save buffer1 pointer
        push    af
        call    showGray
        pop     af
        dec     a                               ; Decrease counter
        jr      nz,grayScrollUpLoop             ; Loop 8 times for all tile rows
        pop     hl                              ; Remove buffer1 pointer from stack
        pop     de                              ; Remove buffer2 pointer from stack
        ret

;------------------------------------------------
; grayScrollDown - Scroll down a map one tile at a time
;
; Input:    None
; Output:   None
;------------------------------------------------
grayScrollDown:
        call    grayScrollSetup                 ; Setup memory to scroll
        ld      a,8                             ; 8 rows to scroll
        ld      hl,buffer1                      ; HL => buffer1 mem
        ld      de,buffer2                      ; DE => buffer2 mem
        push    de                              ; Save buffer2 pointer
        push    hl                              ; Save buffer1 pointer
grayScrollDownLoop:
        ld      hl,GrayMem1+128                 ; Start at 2nd row of tiles
        ld      de,GrayMem1                     ; Copy to top row
        ld      bc,896                          ; Copy all but one row of tiles
        ldir                                    ; Copy
        ld      hl,GrayMem2+128                 ; Start at 2nd row of tiles
        ld      de,GrayMem2                     ; Copy to top row
        ld      bc,896                          ; Copy all but one row of tiles
        ldir                                    ; Copy
        pop     hl                              ; Restore buffer1 pointer
        ld      de,GrayMem1+896                 ; DE => Old map on video
        ld      bc,128                          ; BC = Copy 8 rows to show one row of tiles
        ldir                                    ; Copy the row of tiles
        ex      (sp),hl                         ; Save buffer1 pointer and restore buffer2 pointer
        ld      de,GrayMem2+896                 ; DE => Old map on video
        ld      bc,128                          ; BC = Copy 8 rows to show one row of tiles
        ldir                                    ; Copy the row of tiles
        ex      (sp),hl                         ; Save buffer2 pointer and restore buffer1 pointer
        push    hl                              ; Save buffer1 pointer
        push    af
        call    showGray
        pop     af
        dec     a                               ; Decrease counter
        jr      nz,grayScrollDownLoop           ; Loop 8 times for all tile rows
        pop     hl                              ; Remove buffer1 pointer from stack
        pop     de                              ; Remove buffer2 pointer from stack
        ret

;------------------------------------------------
; grayScrollLeft - Scroll left a map one tile at a time
;
; Input:    None
; Output:   None
;------------------------------------------------
grayScrollLeft:
        call    grayScrollSetup                 ; Setup memory to scroll
        ld      a,16                            ; 16 columns to scroll
        ld      hl,buffer1+15                   ; HL => Right hand column of buffer1 mem
        ld      de,buffer2+15                   ; DE => Right hand column of buffer2 mem
        push    de                              ; Save buffer2 pointer
        push    hl                              ; Save buffer1 pointer
grayScrollLeftLoop:
        ld      hl,GrayMem1+1022                ; Start at second last byte
        ld      de,GrayMem1+1023                ; Copy to next byte
        ld      bc,1023                         ; 1023 bytes to copy
        lddr                                    ; Copy
        ld      hl,GrayMem2+1022                ; Start at second last byte
        ld      de,GrayMem2+1023                ; Copy to next byte
        ld      bc,1023                         ; 1023 bytes to copy
        lddr                                    ; Copy
        pop     hl                              ; Restore buffer1 pointer
        ld      de,GrayMem1                     ; Copy to first column of video
        call    grayScrollHCopy                 ; Copy entire left column
        dec     hl                              ; Next column to copy
        ex      (sp),hl                         ; Save buffer1 pointer and restore buffer2 pointer
        ld      de,Graymem2                     ; Copy to first column of video
        call    grayScrollHCopy                 ; Copy entire left column
        dec     hl                              ; Next column to copy
        ex      (sp),hl                         ; Save buffer2 pointer and restore buffer1 pointer
        push    hl                              ; Save buffer1 pointer
        push    af
        call    showGray
        pop     af
        dec     a                               ; Decrease counter
        jr      nz,grayScrollLeftLoop           ; Loop 16 times for all tile columns
        pop     hl                              ; Remove buffer1 pointer from stack
        pop     de                              ; Remove buffer2 pointer from stack
        ret

;------------------------------------------------
; grayScrollRight - Scroll right a map one tile at a time
;
; Input:    None
; Output:   None
;------------------------------------------------
grayScrollRight:
        call    grayScrollSetup                 ; Setup memory to scroll
        ld      a,16                            ; 16 columns to scroll
        ld      hl,buffer1                      ; HL => buffer1 mem
        ld      de,buffer2                      ; DE => buffer2 mem
        push    de                              ; Save buffer2 pointer
        push    hl                              ; Save buffer1 pointer
grayScrollRightLoop:
        ld      hl,GrayMem1+1                   ; Start at second byte
        ld      de,GrayMem1                     ; Copy to previous byte
        ld      bc,1023                         ; 1023 bytes to copy
        ldir                                    ; Copy
        ld      hl,GrayMem2+1                   ; Start at second byte
        ld      de,GrayMem2                     ; Copy to previous byte
        ld      bc,1023                         ; 1023 bytes to copy
        ldir                                    ; Copy
        pop     hl                              ; Restore buffer1 pointer
        ld      de,GrayMem1+15                  ; Copy to last column of video
        call    grayScrollHCopy                 ; Copy entire right column
        inc     hl                              ; Next column to copy
        ex      (sp),hl                         ; Save buffer1 pointer and restore buffer2 pointer
        ld      de,GrayMem2+15                  ; Copy to last column of video
        call    grayScrollHCopy                 ; Copy entire left column
        inc     hl                              ; Next column to copy
        ex      (sp),hl                         ; Save buffer2 pointer and restore buffer1 pointer
        push    hl                              ; Save buffer1 pointer
        push    af
        call    showGray
        pop     af
        dec     a                               ; Decrease counter
        jr      nz,grayScrollRightLoop          ; Loop 16 times for all tile columns
        pop     hl                              ; Remove buffer1 pointer from stack
        pop     de                              ; Remove buffer2 pointer from stack
        ret

;------------------------------------------------
; grayScrollHCopy - Copy and entire column of tiles
;
; Input:    HL => Source
;           DE => Destination
; Output:   HL => Source
;------------------------------------------------
grayScrollHCopy:
        push    hl                              ; Save source pointer
        push    af                              ; Save AF so it doesn't get trashed
        ld      b,64                            ; 64 rows to copy
grayScrollHCopyLoop:
        push    bc                              ; Save counter
        ld      bc,16                           ; Increment value used for source and destination
        ld      a,(hl)                          ; Get source byte
        ld      (de),a                          ; Copy it to destination
        add     hl,bc                           ; HL => Next row of source
        push    de                              ; Save destination
        ex      (sp),hl                         ; HL => Destination, (SP) => Next row of source
        add     hl,bc                           ; HL => Next row of destination
        ex      (sp),hl                         ; HL => Next row of source, (SP) => Next row of destination
        pop     de                              ; Restore next row of destination
        pop     bc                              ; Restore pointer
        djnz    grayScrollHCopyLoop             ; Repeat 64 times
        pop     af                              ; Restore AF
        pop     hl                              ; Restore source pointer
        ret

;------------------------------------------------
; warpToMap - Warp to a new location
;
; Authors:  David Phillips <david@acz.org>
;           James Vernon <james@calc.org>
; Input:    HL => Warp details
; Output:   None
;------------------------------------------------
warpToMap:
        inc     hl
        ld      a,(hl)
        ld      (mapNo),a
        inc     hl
        ld      b,(hl)
        inc     hl
        ld      c,(hl)
warpToMapLoadMap:
        ld      (y),bc
        ld      (enterMapCoords),bc
        call    newMap
        ld      hl,checkAreaName
        push    hl
        call    fadeOut
        call    grayDrawMap
        call    copyBuffers
        call    showGray
        call    fadeIn
        ret

;------------------------------------------------
; getTile - Get a tile from current map
;
; Input:    A = X
;           L = Y
; Output:   HL => Tile
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
;
; Input:    A = X / 8
;           L = Y / 8
; Output:   HL => Tile
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
