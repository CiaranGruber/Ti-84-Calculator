;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; HUD data                                                      ;
;                                                               ;
;---------------------------------------------------------------;

heartTable:
.db     16,0,24,0,32,0,40,0,48,0,56,0,64,0,72,0,80,0,88,0,96,0,104,0
.db     16,8,24,8,32,8,40,8,48,8,56,8,64,8,72,8,80,8,88,8,96,8,104,8

GOLD_SPR_X              = 115
GOLD_SPR_Y              = 4
GOLD_TXT_X              = 249
GOLD_TXT_Y              = 13

ITEM_SPR_Y              = 112

SWORD_SPR_X             = 16
SWORD_SPR_Y             = ITEM_SPR_Y

SHIELD_SPR_X            = SWORD_SPR_X+8
SHIELD_SPR_Y            = ITEM_SPR_Y

ARMOR_SPR_X             = SHIELD_SPR_X+8
ARMOR_SPR_Y             = ITEM_SPR_Y

BOOTS_SPR_X             = ARMOR_SPR_X+8
BOOTS_SPR_Y             = ITEM_SPR_Y

RING_SPR_X              = BOOTS_SPR_X+8
RING_SPR_Y              = ITEM_SPR_Y

HEARTPIECE_SPR_X        = RING_SPR_X+8
HEARTPIECE_SPR_Y        = ITEM_SPR_Y

crystalTable:
.db     88,ITEM_SPR_Y
.db     96,ITEM_SPR_Y
.db     104,ITEM_SPR_Y
.db     112,ITEM_SPR_Y
.db     120,ITEM_SPR_Y
.db     128,ITEM_SPR_Y
.db     136,ITEM_SPR_Y
NUM_CRYSTALS            = ($-crystalTable)/2

.end
