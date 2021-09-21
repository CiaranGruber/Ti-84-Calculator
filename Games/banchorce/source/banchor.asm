;---------------------------------------------------------------;
;                                                               ;
; Banchor: Legend of the Hellspawn                              ;
; Version 2.0.0                                                 ;
;                                                               ;
; By James Vernon                                               ;
; jamesv82@live.com.au                                          ;
;                                                               ;
; You are allowed to use parts of this code as long as you give ;
; credit where it is due :)                                     ;
;                                                               ;
;===============================================================;

; debugging flags, should be commented out for normal play
;#define INVINCIBLE
;#define BOSS_ESCAPE
;#define NO_CLIP
;#define PERMA_CHESTS
;#define GOLD_GIVE

#include "defines.asm"                          ; Variables and Other Equates

#define VERSION "2.0.0"

.org    userMem-2
.db     tExtTok,tAsm84CeCmp

header:
        jp      start
        .db     1                               ; for cesium
        .db     16,16
        .db     $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
        .db     $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
        .db     $80,$80,$E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3,$80,$80
        .db     $80,$80,$E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3,$80,$80
        .db     $80,$80,$E3,$E3,$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E3,$E3,$80,$80
        .db     $80,$80,$E3,$E3,$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E3,$E3,$80,$80
        .db     $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
        .db     $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
        .db     $80,$80,$E3,$E3,$E5,$E5,$E1,$E1,$E1,$E1,$E5,$E5,$E3,$E3,$80,$80
        .db     $80,$80,$E3,$E3,$E5,$E5,$E1,$E1,$E1,$E1,$E5,$E5,$E3,$E3,$80,$80
        .db     $80,$80,$E3,$E3,$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E3,$E3,$80,$80
        .db     $80,$80,$E3,$E3,$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E5,$E3,$E3,$80,$80
        .db     $80,$80,$E3,$E3,$E3,$E3,$E5,$E5,$E5,$E5,$E3,$E3,$E3,$E3,$80,$80
        .db     $80,$80,$E3,$E3,$E3,$E3,$E5,$E5,$E5,$E5,$E3,$E3,$E3,$E3,$80,$80
        .db     $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
        .db     $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
        .db     "Banchor: Legend of the Hellspawn v",VERSION,0

start:
        ; check for gfx file and load all tilesets and sprites
        call    loadStdGfx
        ret     c                               ; if gfx file missing, quit
        ; check for maps file
        ld      hl,mapsFileName                 ; HL => Maps file name
        MOVE9()
        call    _chkfindsym
        ret     c
        ; check for save file
        call    getSaveFile
        call    c,newSaveFile
        ret     c                               ; if can't be created, quit

        ; files were located, ok to get started
        call    _clrLCD
        call    _runindicoff
        call    vramClear
        call    loadPalette

        ; initialise lcd and lcd pointers
        call    vram8bpp
        ld      hl,vbuf2
        ld      (pVbuf),hl
        ld      bc,VBUF_WIN_OFFSET
        add     hl,bc
        ld      (pVbufWin),hl

        ; load font
        ld      hl,fontData
        ld      de,font
        ld      ix,huffTree
        call    huffExtr

titleScreen:
        ; show title screen
        call    vramClear
        call    getGfxFile
        ld      hl,(pVbuf)
        ld      bc,320*10
        add     hl,bc
        ex      de,hl
        ld      ix,huffTree
        ld      b,GFX_FILE_TITLE
        call    huffExtr                        ; load splash

        ld      hl,strTitle
        ld      de,0
        ld      c,230
        call    drawString                      ; "BY JAMES VERNON"
        ld      de,72
        ld      c,140
        call    drawString                      ; "PRESS ANY KEY TO START"
        ld      de,270
        ld      c,230
        call    drawString                      ; version

        call    vramFlip
        call    waitKey                         ; Wait for key press
        cp      GK_CLEAR
        jp      z,quit

        xor     a
        ld      (gameNum),a
        ld      a,INI_HEART_LEVEL
        ld      (heartLevel),a

selectGameLoop:
        call    vbufClear

        ; modify drawHud y values
        ld      a,OP_SCF
        ld      (__dhHeartC),a
        ld      (__dhCrystalC),a
        ld      a,24
        ld      (__dhHeartY),a
        ld      a,GOLD_TXT_Y+56
        ld      (__dhGoldRect),a
        ld      (__dhGoldTxt),a
        ld      a,GOLD_SPR_Y+28
        ld      (__dhGoldSpr),a
        ld      a,ITEM_SPR_Y-72
        ld      (__dhSwordY),a
        ld      (__dhShieldY),a
        ld      (__dhArmorY),a
        ld      (__dhBootsY),a
        ld      (__dhRingY),a
        ld      (__dhHeartPieceY),a
        ld      a,-72
        ld      (__dhCrystalY),a
        
        ld      a,48
        ld      (__segY),a
        ld      (__sgDiffY),a

        ld      hl,strSelectGame
        ld      de,92
        ld      c,20
        call    drawString                      ; "SELECT GAME"

        call    getSaveFile
        ex      de,hl
        ld      b,3

showGamesLoop:
        push    bc
        ld      de,gameData
        ld      bc,SAVE_GAME_SIZE
        ldir
        push    hl
        ld      a,(difficulty)
        ld      b,COLOUR_WHITE
        cp      3
        jr      nz,sgDiffColour
        ld      b,COLOUR_RED
sgDiffColour:
        inc     a
        jr      z,showEmptyGame
        dec     a
        ld      l,a
        ld      h,7
        mlt     hl
        ld      de,strEasy
        add     hl,de
        ld      de,241
__sgDiffY               = $+1
        ld      c,$00
        ld      a,b
        call    drawStringColour
        call    drawHudGameSelect
        jr      sglUpdate
showEmptyGame:
        ld      hl,strEmpty                     ; "EMPTY"
        ld      de,50
__segY                  = $+1
        ld      c,$00
        call    drawString
sglUpdate:
        pop     hl
        pop     bc

        ; update modified drawHud y values
        ld      c,30
        ld      a,(__dhHeartY)
        add     a,c
        ld      (__dhHeartY),a
        ld      a,(__dhGoldRect)
        add     a,c
        add     a,c
        ld      (__dhGoldRect),a
        ld      (__dhGoldTxt),a
        ld      a,(__dhGoldSpr)
        add     a,c
        ld      (__dhGoldSpr),a
        ld      a,(__dhSwordY)
        add     a,c
        ld      (__dhSwordY),a
        ld      (__dhShieldY),a
        ld      (__dhArmorY),a
        ld      (__dhBootsY),a
        ld      (__dhRingY),a
        ld      (__dhHeartPieceY),a
        ld      a,(__dhCrystalY)
        add     a,c
        ld      (__dhCrystalY),a
        
        ld      a,(__segY)
        add     a,c
        add     a,c
        ld      (__segY),a
        ld      (__sgDiffY),a

        ;djnz    showGamesLoop
        dec     b
        jp      nz,showGamesLoop
        
        ; draw box around selected game
        ld      de,44*256+14
        ld      a,(gameNum)
        or      a
        jr      z,drawGameRect
        ld      b,a
        ld      a,d
calcGameRect:
        add     a,60
        djnz    calcGameRect
        ld      d,a
drawGameRect:
        ld      bc,131*256+56
        ld      a,COLOUR_BLUEGREY
        call    drawRect

        call    vramFlip
        call    waitKey
        cp      GK_CLEAR
        jp      z,quit
        cp      GK_2ND
        jr      z,selectGameDone
        cp      GK_ENTER
        jr      z,selectGameDone
        cp      GK_DEL
        jr      z,checkDeleteGame
        ld      hl,gameNum
        cp      GK_DOWN
        jr      z,selectGameDown
        cp      GK_UP
        jp      nz,selectGameLoop

selectGameUp:
        dec     (hl)
        ld      a,(hl)
        inc     a
        jp      nz,selectGameLoop
        ld      (hl),2
        jp      selectGameLoop

selectGameDown:
        inc     (hl)
        ld      a,(hl)
        cp      3
        jp      nz,selectGameLoop
        ld      (hl),0
        jp      selectGameLoop

checkDeleteGame:
        ld      hl,strDelete
        call    textMessageFound
        jp      z,selectGameLoop
        ; delete the game (by setting the difficulty to 255)
        ld      hl,saveFileName                 ; HL => Saved game file name
        MOVE9()
        call    _chkfindsym
        call    _chkInRam
        push    af
        jr      z,gameInRam
        call    _arc_unarc
gameInRam:
        inc de \ inc de
        ex      de,hl
        ld      a,(gameNum)
        ld      b,a
        or      a
        jr      z,doDelete
        ld      de,SAVE_GAME_SIZE
findDeleteSlot:
        add     hl,de
        djnz    findDeleteSlot
doDelete:
        ld      (hl),255
        pop     af
        call    nz,_arc_unarc
        jp      selectGameLoop

selectGameDone:
        ; reset drawHud y values
        ld      a,OP_OR_A
        ld      (__dhHeartC),a
        ld      (__dhCrystalC),a
        ld      a,GOLD_TXT_Y
        ld      (__dhGoldRect),a
        ld      (__dhGoldTxt),a
        ld      a,GOLD_SPR_Y
        ld      (__dhGoldSpr),a
        ld      a,ITEM_SPR_Y
        ld      (__dhSwordY),a
        ld      (__dhShieldY),a
        ld      (__dhArmorY),a
        ld      (__dhBootsY),a
        ld      (__dhRingY),a
        ld      (__dhHeartPieceY),a

        call    getSaveFile
        ex      de,hl
        ld      de,SAVE_GAME_SIZE
        ld      a,(gameNum)
        ld      b,a
        or      a
        jr      z,loadGame
findLoadSlot:
        add     hl,de
        djnz    findLoadSlot

loadGame:                                       ; HL => saved game
        ld      de,gameData
        ld      bc,SAVE_GAME_SIZE
        ldir
        ld      a,(difficulty)
        inc     a
        call    z,newGame                       ; difficulty = 255 means it's an empty game file

#ifdef PERMA_CHESTS
        ; reload chests every game for debugging purposes
        ld      hl,mapsFileName
        MOVE9()
        call    _chkfindsym
        call    getDataPtr
        inc     de                              ; skip number of maps
        ex      de,hl                           ; HL => default chest data
        ld      de,chests
        ld      bc,300
        ldir
#endif
        call    updateItems                     ; Check what items player has
        ; make difficulty adjustments
        ld      a,(difficulty)
        ld      hl,enemyHealth
        or      a
        jr      nz,setEnemyHealthPtr            ; standard enemy HP for Normal/Hard/Hell
        ld      hl,enemyHealthEasy              ; otherwise lowered HP for Easy
setEnemyHealthPtr:
        ld      (__enemyHealth),hl
        cp      2                               ; Hard/Hell?
        ld      a,$0F
        ld      b,0
        jr      c,setEnemySpawnMask
        ld      a,$07
        ld      b,OP_SCF
setEnemySpawnMask:
        ld      (__enemySpawn),a                ; set spawn rate
        ld      a,b
        ld      (__decPlayerHearts),a           ; set damage multiplier flag
        ; reset some vars
        xor     a                               ; A = 0
        ld      (hurt),a
        ld      (attacking),a
        ld      (frame),a
        ld      (areaNum),a
        ld      (demon),a
        ; load map & position
        ld      hl,(enterMapCoords)
        ld      (y),hl                          ; Load Player X & Y coords
        ld      de,map
        call    newMap                          ; Load new map
        ; do warp animation and purge vram at the same time
        call    fadeOut
        call    vramClear
        call    drawMap
        call    vramFlip
        call    fadeIn
#include "maingame.asm"                         ; Main Game Loop

newGame:
        ; select difficulty
        call    vramCopy
        ld      de,80*256+16
        ld      bc,128*256+74
        ld      a,COLOUR_ORANGE
        call    drawWindow
        ld      hl,strSelectDiff
        ld      de,40
        ld      c,88
        push    de
        call    drawString
        pop     de
        ld      c,108
        push    de
        call    drawString
        pop     de
        ld      c,118
        push    de
        call    drawString
        pop     de
        ld      c,128
        push    de
        call    drawString
        pop     de
        ld      c,138
        call    drawString
        call    vramFlip

difficultyLoop:
        call    waitKey
        ld      c,0
        cp      GK_1
        jr      z,setDifficulty
        inc     c
        cp      GK_2
        jr      z,setDifficulty
        inc     c
        cp      GK_3
        jr      z,setDifficulty
        inc     c
        cp      GK_4
        jr      nz,difficultyLoop
setDifficulty:
        ; prepare new game variables
        ld      a,c
        ld      (difficulty),a                  ; set difficulty
        ld      hl,items                        ; HL => Item data
        ld      b,NUM_ITEMS                     ; B = Number of items to clear
        call    _ld_hl_bz                       ; Clear all items
        xor     a
        ld      (mapNo),a                       ; Start on map 0
        sbc     hl,hl                           ; HL = 0
        ld      (gold),hl                       ; Reset gold
        inc     a                               ; A = 1
        ld      (playerDir),a                   ; Face player down
        ld      (hearts),a                      ; Start with only 1 heart
        ld      a,INI_HEARTS
        ld      (maxHearts),a                   ; Start with maximum hearts of 3
        ld      hl,INI_YX_POS                   ; HL = Start X & Y coords
        ld      (enterMapCoords),hl             ; Save it
        ; load chests
        ld      hl,mapsFileName
        MOVE9()
        call    _chkfindsym
        call    getDataPtr
        inc     de                              ; skip number of maps
        ex      de,hl                           ; HL => default chest data
        ld      de,chests
        ld      bc,300
        ldir
        ; clear changeList
        call    clearChangeList
        ; do intro and load the new game
        jp      doIntro

saveGame:
        ld      hl,saveFileName                 ; HL => Saved game file name
        MOVE9()
        call    _chkfindsym
        call    _chkInRam
        push    af
        jr      z,saveInRam
        call    _arc_unarc
saveInRam:
        inc de \ inc de
        ex      de,hl
        ld      a,(gameNum)
        ld      b,a
        or      a
        jr      z,doSave
        ld      de,SAVE_GAME_SIZE
findSaveSlot:
        add     hl,de
        djnz    findSaveSlot
doSave:
        ex      de,hl
        ld      hl,gameData
        ld      bc,SAVE_GAME_SIZE
        ldir
        pop     af
        call    nz,_arc_unarc
        ; fall through to quit

quit:
        ld      hl,vram
        ld      (mpLcdBase),hl
        call    vram16bpp
        call    _clrlcdfull
        call    _homeup
        call    _drawstatusbar
        ei
        ret

gameOver:
        ld      a,TXT_GAMEOVER
        call    textMessage
        ld      a,255
        ld      (difficulty),a
        jr      saveGame

;------------------------------------------------
; getSaveFile - get a pointer to the save file app var
;   input:  none
;   output: DE => start of file data if it exists
;           CA set if file missing
;------------------------------------------------
getSaveFile:
        ld      hl,saveFileName
        MOVE9()
        call    _chkfindsym
        ret     c                               ; if file missing, quit
        jr      getDataPtr

;------------------------------------------------
; newSaveFile - create a new "bancsav" file
;   input:  none
;   output: CA set if failed (not enough memory)
;------------------------------------------------
newSaveFile:
        ; check if enough memory
        call    _memChk
        ld      de,SAVE_GAME_SIZE*3
        or      a
        sbc     hl,de
        ret     c                               ; return with carry if failed
        ; create app var
        ld      hl,saveFileName
        MOVE9()
        ld      hl,SAVE_GAME_SIZE*3
        call    _createAppVar
        inc de \ inc de                         ; skip length bytes
        ; set all difficulty values to 255 (empty slot)
        ld      b,3
        ld      hl,SAVE_GAME_SIZE
        ex      de,hl
nsfLoop:
        ld      (hl),255
        add     hl,de
        djnz    nsfLoop
        or      a                               ; clear carry
        ret

;------------------------------------------------
; getGfxFile - get a pointer to the graphics app var
;   input:  none
;   output: DE => start of file data if it exists
;           CA set if file missing
;------------------------------------------------
getGfxFile:
        ld      hl,gfxFileName
        MOVE9()
        call    _chkfindsym
        ret     c                               ; if file missing, quit
        ; fall through to getDataPtr

;------------------------------------------------
; getDataPtr - take DE address from _chkfindsym and update it to point to start of data (whether in RAM or Archive)
;   input:  DE => _chkfindsym result
;   output: DE => start of file data
;------------------------------------------------
getDataPtr:
        call    _SetAToDEU
        cp      $D0
        jr      nc,dataInRam
        push    de
        pop     ix
        ld      a,10
        add     a,(ix+9)
        or a \ sbc hl,hl \ ld l,a
        add     hl,de
        ex      de,hl
dataInRam:
        inc de \ inc de
        ret


;------------------------------------------------
; Include Files (code)
;------------------------------------------------
#include "anim.asm"                             ; Animation routines
#include "area.asm"                             ; Area Name routines
#include "change.asm"                           ; Change List routines
#include "chests.asm"                           ; Chest routines
#include "boss.asm"                             ; boss routines
#include "boss1.asm"                            ; boss #1 specific routines
#include "boss2.asm"                            ; boss #2 specific routines
#include "boss3.asm"                            ; boss #3 specific routines
#include "boss4.asm"                            ; boss #4 specific routines
#include "boss5.asm"                            ; boss #5 specific routines
#include "boss6.asm"                            ; boss #6 specific routines
#include "boss7.asm"                            ; boss #7 specific routines
#include "boss8.asm"                            ; boss #8 specific routines
#include "enemy.asm"                            ; Enemy routines
#include "enemyai.asm"                          ; Enemy AI scripts
#include "gfx.asm"                              ; Graphics routines
#include "hud.asm"                              ; HUD routines
#include "huffextr.asm"                         ; Huffman decompression (by Jimmy Mårdell, ported/updated by JamesV)
#include "intro.asm"                            ; Introduction routines
#include "io.asm"                               ; Input/Output routines
#include "map.asm"                              ; Map routines
#include "object.asm"                           ; Object routines
#include "player.asm"                           ; Player routines
#include "random.asm"                           ; Random routines
#include "talk.asm"                             ; Talking routines

;------------------------------------------------
; External File Names
;------------------------------------------------
gfxFileName:
.db appvarobj,"Bancgfx",0

mapsFileName:
.db appvarobj,"Bancmaps",0

saveFileName:
.db appvarobj,"Bancsav",0

#include "bancdat.asm"

fontData:               #import "fontarc.huf"
fontTable:
.db 00,01,00,00,00,00,02,03,00,00,00,00,04,05,06,00         ; $20-$2F
.db 07,08,09,10,11,12,13,14,15,16,17,00,00,00,00,18         ; $30-$3F
.db 00,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33         ; $40-$4F
.db 34,35,36,37,38,39,40,41,42,43,44,00,00,00,00,00         ; $50-$5F
.db 00,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33         ; $60-$6F
.db 34,35,36,37,38,39,40,41,42,43,44,00,00,00,00,00         ; $70-$7F

.end
