;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Tile Animation data                                           ;
;                                                               ;
;---------------------------------------------------------------;

animationTable:
; Waterfall
.db     WATERFALL_1,WATERFALL_2, WATERFALL_2,WATERFALL_3, WATERFALL_3,WATERFALL_4, WATERFALL_4,WATERFALL_1
; Waterfall Splash
.db     WATERFALL_SPLASH_1,WATERFALL_SPLASH_2, WATERFALL_SPLASH_2,WATERFALL_SPLASH_1
; Person on stone
.db     PERSON_STONE_L,PERSON_STONE_R, PERSON_STONE_R,PERSON_STONE_L
; Person on sand
.db     PERSON_SAND_L,PERSON_SAND_R, PERSON_SAND_R,PERSON_SAND_L
; Person on grass
.db     PERSON_GRASS_L,PERSON_GRASS_R, PERSON_GRASS_R,PERSON_GRASS_L
; Person on dirt
.db     PERSON_DIRT_L,PERSON_DIRT_R, PERSON_DIRT_R,PERSON_DIRT_L
; Sapphira on stone
.db     SAPPHIRA_STONE_U,SAPPHIRA_STONE_D, SAPPHIRA_STONE_D,SAPPHIRA_STONE_U
; Sapphira on sand
.db     SAPPHIRA_SAND_U,SAPPHIRA_SAND_D, SAPPHIRA_SAND_D,SAPPHIRA_SAND_U
; Sapphira on grass
.db     SAPPHIRA_GRASS_U,SAPPHIRA_GRASS_D, SAPPHIRA_GRASS_D,SAPPHIRA_GRASS_U
; Sapphira on dirt
.db     SAPPHIRA_DIRT_U,SAPPHIRA_DIRT_D, SAPPHIRA_DIRT_D,SAPPHIRA_DIRT_U
; Well
.db     LIFEWELL_1,LIFEWELL_2, LIFEWELL_2,LIFEWELL_1
; Teleport used in pyramid dungeon
.db     TELEPORT_1,TELEPORT_2, TELEPORT_2,TELEPORT_3, TELEPORT_3,TELEPORT_1
; Hell Portal
.db     PORTAL_1,PORTAL_2, PORTAL_2,PORTAL_3, PORTAL_3,PORTAL_4, PORTAL_4,PORTAL_1
ANIM_TABLE_SIZE         = ($-animationTable)/2

.end
