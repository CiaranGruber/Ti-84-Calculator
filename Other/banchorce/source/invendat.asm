;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Inventory Screen Data                                         ;
;                                                               ;
;---------------------------------------------------------------;

I_GRY                                   = (sprLGray-startMapSprites)/16
I_BLK                                   = (sprCrevice-startMapSprites)/16
I_ITL                                   = (sprBorderTL-startMapSprites)/16
I_ITR                                   = (sprBorderTR-startMapSprites)/16
I_IBL                                   = (sprBorderBL-startMapSprites)/16
I_IBR                                   = (sprBorderBR-startMapSprites)/16
I_ITT                                   = (sprBorderT-startMapSprites)/16
I_IBB                                   = (sprBorderB-startMapSprites)/16
I_ILL                                   = (sprBorderL-startMapSprites)/16
I_IRR                                   = (sprBorderR-startMapSprites)/16
I_WHT                                   = 0

;------------------------------------------------
; Tile map for Inventory Screen
;------------------------------------------------
invenMap:
.db     I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK
.db     I_BLK,I_BLK,I_BLK,I_GRY,I_GRY,I_GRY,I_GRY,I_GRY,I_GRY,I_GRY,I_GRY,I_GRY,I_GRY,I_BLK,I_BLK,I_BLK
.db     I_BLK,I_BLK,I_BLK,I_GRY,I_GRY,I_GRY,I_GRY,I_GRY,I_GRY,I_GRY,I_GRY,I_GRY,I_GRY,I_BLK,I_BLK,I_BLK
.db     I_BLK,I_BLK,I_BLK,I_GRY,I_GRY,I_GRY,I_GRY,I_GRY,I_ITL,I_ITT,I_ITT,I_ITT,I_ITR,I_BLK,I_BLK,I_BLK
.db     I_BLK,I_BLK,I_BLK,I_GRY,I_GRY,I_GRY,I_GRY,I_GRY,I_ILL,I_WHT,I_WHT,I_WHT,I_IRR,I_BLK,I_BLK,I_BLK
.db     I_BLK,I_BLK,I_BLK,I_GRY,I_GRY,I_GRY,I_GRY,I_GRY,I_ILL,I_WHT,I_WHT,I_WHT,I_IRR,I_BLK,I_BLK,I_BLK
.db     I_BLK,I_BLK,I_BLK,I_GRY,I_GRY,I_GRY,I_GRY,I_GRY,I_IBL,I_IBB,I_IBB,I_IBB,I_IBR,I_BLK,I_BLK,I_BLK
.db     I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK,I_BLK

heartTable:
.db     28,10,34,10,40,10,46,10,52,10,58,10
.db     28,16,34,16,40,16,46,16,52,16,58,16
.db     28,22,34,22,40,22,46,22,52,22,58,22
.db     28,28,34,28,40,28,46,28,52,28,58,28

itemCoords:
.db     70,31,70,31,70,31,80,31,80,31
.db     90,31,90,31,70,41,70,41,80,41
.db     80,41,90,41
.db     70,9,80,9,90,9,75,18,85,18
;NUM_ITEMS                               = ($-itemCoords)/2

strGold:
.db     "GOLD:",0

.end
