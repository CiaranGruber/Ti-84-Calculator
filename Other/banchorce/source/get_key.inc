;#########################################################
; GET_KEY equates for the TI-82/TI-83/TI-83+/TI-85/TI-86
; By James Vernon - Ti-Calculator Programming Alliance
; james@calc.org <> http://tcpa.calc.org <> ICQ#: 71589304
; Created on 11-02-2001 DDMMYYYY
;
; USAGE (TI-82/83/83+):
;  #include "get_key.inc"
;
; USAGE (TI-85/86):
;  #define GETKEY_8586
;  #include "get_key.inc"
;#########################################################

#ifndef GET_KEY
#define GET_KEY _getcsc
#endif

#ifdef GETKEY_8586
GK_F1           = 53
GK_F2           = 52
GK_F3           = 51
GK_F4           = 50
GK_F5           = 49
GK_2ND          = 54
GK_EXIT         = 55
GK_MORE         = 56
#else
GK_Y            = 53
GK_WINDOW       = 52
GK_ZOOM         = 51
GK_TRACE        = 50
GK_GRAPH        = 49
GK_2ND          = 54
GK_MODE         = 55
GK_DEL          = 56
#endif

GK_UP           = 4
GK_DOWN         = 1
GK_LEFT         = 2
GK_RIGHT        = 3
GK_ALPHA        = 48

#ifdef GETKEY_8586
GK_XVAR         = 40
GK_DEL          = 32
GK_GRAPH        = 47
GK_TABLE        = 39
GK_PRGM         = 31
GK_CUSTOM       = 23
#else
GK_XTON         = 40
GK_STAT         = 32
GK_MATH         = 47
GK_MATRX        = 39
GK_PRGM         = 31
GK_VARS         = 23
#endif

GK_CLEAR        = 15

#ifdef GETKEY_8586
GK_LOG          = 46
#else
GK_X1           = 46    ; X^-1
#endif

GK_SIN          = 38
GK_COS          = 30
GK_TAN          = 22
GK_POWER        = 16    ; ^

#ifdef GETKEY_8586
GK_LN           = 45
GK_EE           = 37
#else
GK_X2           = 45    ; X^2
GK_COMMA        = 37    ; ,
#endif

GK_LPAR         = 29    ; (
GK_RPAR         = 21    ; )
GK_DIV          = 13    ; /

#ifdef GETKEY_8586
GK_X2           = 44
#else
GK_LOG          = 44
#endif

GK_7            = 36
GK_8            = 28
GK_9            = 20
GK_MUL          = 12    ; *

#ifdef GETKEY_8586
GK_COMMA        = 43    ; ,
#else
GK_LN           = 43
#endif

GK_4            = 35
GK_5            = 27
GK_6            = 19
GK_MINUS        = 11    ; -
GK_STO          = 42    ; STO->
GK_1            = 34
GK_2            = 26
GK_3            = 18
GK_PLUS         = 10    ; +
GK_0            = 33
GK_DEC          = 25    ; .
GK_NEG          = 17    ; (-)
GK_ENTER        = 9

.end
