;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Talking Data                                                  ;
;                                                               ;
;---------------------------------------------------------------;

T_TTL                                   = (sprBorderTL-startMapSprites)/16
T_TTR                                   = (sprBorderTR-startMapSprites)/16
T_TBL                                   = (sprBorderBL-startMapSprites)/16
T_TBR                                   = (sprBorderBR-startMapSprites)/16
T_TTT                                   = (sprBorderT-startMapSprites)/16
T_TBB                                   = (sprBorderB-startMapSprites)/16
T_TLL                                   = (sprBorderL-startMapSprites)/16
T_TRR                                   = (sprBorderR-startMapSprites)/16
T_WHT                                   = 0

talkMap:
.db     T_TTL,T_TTT,T_TTT,T_TTT,T_TTT,T_TTT,T_TTT,T_TTT,T_TTT,T_TTT,T_TTT,T_TTT,T_TTT,T_TTT,T_TTT,T_TTR
.db     T_TLL,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_TRR
.db     T_TLL,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_TRR
.db     T_TLL,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_TRR
.db     T_TLL,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_TRR
.db     T_TLL,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_TRR
.db     T_TLL,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_WHT,T_TRR
.db     T_TBL,T_TBB,T_TBB,T_TBB,T_TBB,T_TBB,T_TBB,T_TBB,T_TBB,T_TBB,T_TBB,T_TBB,T_TBB,T_TBB,T_TBB,T_TBR

.end
