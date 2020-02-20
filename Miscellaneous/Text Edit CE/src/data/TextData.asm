progSearchHeader:
 .db "MATEO",0 ; Header
PgrmName:
 .db "CE TEXT EDITOR ",VersionMajor+'0','.',VersionMinor+'0',0
ExtraSpace:
 .db "  ",0
DeleteStr:
 .db "DELETE",0
NewStr:
 .db "NEW",0
RenameStr:
 .db "RENAME",0
SaveStr:
 .db "SAVE  ",0
SavedStr:
 .db "SAVED",0
SaveAsStr:
 .db "SAVE AS...",0
FileStr:
 .db "FILE",0
EditStr:
 .db "EDIT",0
ExitStr:
 .db "EXIT",0
YesStr:
 .db "YES",0
NoStr:
 .db "NO",0
DoneStr:
 .db "DONE",0
Arrow:
 .db ">",0
NoFilesStr:
 .db "No Files Found",0
SaveStr2:
 .db "SAVE",0
FileNames:
 .db AppVarObj,"File"
 
FileNames100:
FileNames10: = $+1
FileNames1: =$+2
 .db "000",0

CharTableNormal:
 .db "'WRMH",0,0   		; + - × ÷ ^ undefined
 .db "?",$E9,"VQLG",0,0 	; (-) 3 6 9 ) TAN VARS undefined
 .db ":ZUPKFC",0   		; . 2 5 8 ( COS PRGM STAT
 .db " YTOJEB",0,0		; 0 1 4 7 , SIN APPS XT?n undefined
 .db "XSNIDA"			; STO LN LOG x2 x-1 MATH

CharTableSmall:
 .db "\"wrmh",0,0   		; + - × ÷ ^ undefined
 .db "!",$E9,"vqlg",0,0 	; (-) 3 6 9 ) TAN VARS undefined
 .db ".zupkfc",0   		; . 2 5 8 ( COS PRGM STAT
 .db " ytojeb",0,0		; 0 1 4 7 , SIN APPS XT?n undefined
 .db "xsnida"			; STO LN LOG x2 x-1 MATH
 
CharTableNum:
 .db "+-*/^",0,0   		; + - × ÷ ^ undefined
 .db "_369)",0,0,0 		; (-) 3 6 9 ) TAN VARS undefined
 .db ".258(",0,0,0   		; . 2 5 8 ( COS PRGM STAT
 .db "0147,",0,"X",0,0	; 0 1 4 7 , SIN APPS XT?n undefined
 .db $1A,0,0,$FD,0,0		; STO LN LOG x2 x-1 MATH
 
CharTable2nd:
 .db 0,"][e",$E3,0,0  	 	; + - × ÷ ^ undefined
 .db 0,0,0,0,'}',0,0,0 		; (-) 3 6 9 ) TAN VARS undefined
 .db 'i',0,0,0,'{',0,0,0   	; . 2 5 8 ( COS PRGM STAT
 .db '_',0,0,0,'E',0,0,0,0	; 0 1 4 7 , SIN APPS XT?n undefined
 .db 0,'e',$E4,$FB,0,0		; STO LN LOG x2 x-1 MATH
 