;---------------------------------------------------------------;
;                                                               ;
; Banchor: The Hellspawn                                        ;
; Version 1.2.1                                                 ;
;                                                               ;
; By James Vernon                                               ;
; jamesv82@live.com.au                                          ;
; http://www.jvti.org                                           ;
;                                                               ;
; You are allowed to use parts of this code as long as you give ;
; credit where it is due :)                                     ;
;                                                               ;
;===============================================================;

;#define INVINCIBLE

;------------------------------------------------
; Include Files
;------------------------------------------------
#include "ti84pce.inc"
#include "get_key.inc"

;------------------------------------------------
; Misc Defines
;------------------------------------------------
#define HUFF84PCE                               ; notify huffextr.asm of TI-84+CE
#define MOVE9() call _Mov9ToOP1
#define LDHLIND() push de \ ld e,(hl) \ inc hl \ ld d,(hl) \ inc hl \ ld a,(hl) \ ex de,hl \ pop de \ call _setHLUtoA

freemem                 = pixelshadow           ; 69090 bytes of available memory to use
treeaddr                = freemem               ; 3 bytes for HuffExtr
graymem1                = treeaddr+3            ; 1024 bytes
graymem2                = graymem1+1024         ; 1024 bytes
videoram                = graymem2+1024         ; 1024 bytes
videoram2               = videoram+1024         ; 1024 bytes
buffer1                 = videoram2+1024        ; 1024 bytes
buffer2                 = buffer1+1024          ; 1024 bytes
huffTree                = buffer2+1024          ; 1024 bytes

datamem                 = freemem+16384         ; place to store map data & variables

#include "vars.asm"                             ; Variables and Other Equates



.org    userMem-2
.db     tExtTok,tAsm84CeCmp

start:
        call    _runindicoff

        ld      hl,mapsFileName                 ; HL => Maps file name
        MOVE9()
        call    _chkfindsym
        ret     c

        ld      hl,saveFileName                 ; HL => Saved game file name
        MOVE9()
        call    _chkfindsym
        ret     c                               ; If saved game file is missing, quit
        call    getDataPtr
        ld      hl,saveGameData
        ex      de,hl
        ld      bc,saveGameSize
        ldir                                    ; load save data from file
        
        call    loadPalette
        
        call    vram8bpp
        call    clearVram

titleScreen:
; Show title screen
        ld      hl,titlePic                     ; HL => Compressed title pic data
        ld      de,buffer1                      ; DE => Where to extract to
        call    extractShowPic                  ; Extract and show title picture

titleLoop:
        call    waitKey                         ; Wait for key press
        cp      GK_F5                           ; Was [F5] pressed?
        jr      z,checkNewGame                  ; If so, confirm to start a new game
        cp      GK_F1                           ; Was [F1] pressed?
        jr      nz,titleLoop                    ; If not, loop again

titleDone:
        ld      a,(mapNo)                       ; A = Map number
        inc     a                               ; Check to see if it's 255
        jr      nz,loadGame                     ; If not, we can load the game
        jr      newGame

checkNewGame:
; Show different bottom section of title pic
        ld      hl,titlePic2                    ; HL => Compressed title pic data
        ld      de,buffer1+((64-8)*16)          ; DE => Where to extract to
        call    extractShowPic                  ; Extract and show new title pic
        call    waitKey                         ; Wait for key press
        cp      GK_ENTER                        ; Was [ENTER] pressed?
        jr      nz,titleScreen                  ; If not, go back to normal title screen

newGame:
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
        ld      a,3
        ld      (maxHearts),a                   ; Start with maximum hearts of 3
        ld      hl,INI_YX_POS                   ; HL = Start X & Y coords
        ld      (enterMapCoords),hl             ; Save it
; Load chests
        ld      hl,mapsFileName
        MOVE9()
        call    _chkfindsym
        call    getDataPtr
        inc     de                              ; skip number of maps
        ex      de,hl                           ; HL => default chest data
        ld      de,chests
        ld      bc,300
        ldir
; Clear changeList
        call    clearChangeList

loadGame:
        call    updateItems                     ; Check what items player has
        xor     a                               ; A = 0
        ld      (hurt),a
        ld      (attacking),a
        ld      (frame),a
        ld      (areaNum),a
        ld      (demon),a
        ld      hl,(enterMapCoords)
        ld      (y),hl                          ; Load Player X & Y coords
        ld      a,INI_HEART_LEVEL
        ld      (heartLevel),a
        call    newMap                          ; Load new map
        call    grayDrawMap                     ; Draw map
        call    copyBuffers                     ; Copy buffers
#include "maingame.asm"                         ; Main Game Loop

quit:
        call    vram16bpp
        call    _clrlcdfull
        call    _homeup
        call    _drawstatusbar
        ei
; Save game
        ld      hl,saveFileName                 ; HL => Saved game file name
        MOVE9()
        call    _chkfindsym
        call    _chkInRam
        push    af
        jr      z,saveInRam
        call    _arc_unarc
saveInRam:
        inc de \ inc de
        ld      hl,saveGameData
        ld      bc,saveGameSize
        ldir
        pop     af
        call    nz,_arc_unarc
        ret

extractShowPic:
        ld      ix,huffTree                     ; IX => Temp compression data
        call    huffExtr                        ; Extract picture data
        call    copyBuffers
        jp      showGray                        ; Show new screen

ClearGray:
        ld      hl,VideoRam
        ld      de,VideoRam+1
        ld      bc,2047
        ld      (hl),0
        ldir
        ret

CopyBuffers:
        ld      hl,Buffer1
        ld      de,GrayMem1
        ld      bc,2048
        ldir
        ret

ClearBuffers:
        ld      hl,Buffer1
        ld      de,Buffer1+1
        ld      bc,2047
        ld      (hl),0
        ldir
        ret

;------------------------------------------------
; keyScan - perform a keyscan
;   input:  none
;   output: none
;------------------------------------------------
keyScan:
        di
        ld      hl,DI_Mode
        ld      (hl),$02
        xor     a
ksWait:
        cp      (hl)
        jr      nz,ksWait
        ret

_ld_hl_bz:
        ld      (hl),0
        inc     hl
        djnz    _ld_hl_bz
        ret

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
#include "anim.asm"                             ; Animation Routines
#include "area.asm"                             ; Area Name Routines
#include "change.asm"                           ; Change List Routines
#include "chests.asm"                           ; Chest Routines
#include "danazar.asm"                          ; Anazar Demon Routines
#include "dbanchor.asm"                         ; Banchor Demon Routines
#include "dbelkath.asm"                         ; Belkath Demon Routines
#include "ddezemon.asm"                         ; Dezemon Demon Routines
#include "demon.asm"                            ; Demon Routines
#include "dheath.asm"                           ; King Heath Demon Routines
#include "dwendeg.asm"                          ; Wendeg Demon Routines
#include "enemy.asm"                            ; Enemy Routines
#include "enemyai.asm"                          ; Enemy AI Scripts
#include "gfxce.asm"                            ; CE Graphics Routines
#include "huffextr.asm"                         ; Huffman Decompression by Jimmy Mårdell
#include "inven.asm"                            ; Inventory Screen Routines
#include "io.asm"                               ; Input/Output Routines
#include "map.asm"                              ; Map Routines
#include "object.asm"                           ; Object Routines
#include "player.asm"                           ; Player Routines
#include "random.asm"                           ; Random Routines
#include "sprite.asm"                           ; Grayscale Sprite Routines
#include "talk.asm"                             ; Talking Routines

;------------------------------------------------
; Saved game data
;------------------------------------------------
saveGameData:

mapNo:                                  .db     255
playerDir:                              .db     0
enterMapCoords:                         .dl     0
hearts:                                 .db     0
maxHearts:                              .db     0
gold:                                   .dl     0
items:                                  .db     0,0,0,0,0,0,0,0,0,0,0,0
crystals:                               .db     0,0,0,0,0
chests:                                 .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
changeList:                             .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                        .db     0,0,0,0,0,0,0,0,0,0

saveGameSize                            = $-saveGameData

bluntSword                              = items+0
superiorSword                           = items+1
legendarySword                          = items+2
woodenShield                            = items+3
ironShield                              = items+4
lightArmor                              = items+5
heavyArmor                              = items+6
aquaBoots                               = items+7
wingedBoots                             = items+8
ringOfMight                             = items+9
ringOfThunder                           = items+10
heartPiece                              = items+11

NUM_ITEMS                               = chests-items

;------------------------------------------------
; External File Names
;------------------------------------------------
mapsFileName:
.db appvarobj,"Bancmaps",0

saveFileName:
.db appvarobj,"Bancsav",0

#include "bancdat.asm"

.end
