@ECHO OFF

ECHO ----- Assembling Banchor: The Hellspawn for the TI-84+CE...
ECHO -- Assembling maps...
SPASM64 -E bancmaps.asm bancmaps.8xv
ECHO -- Assembling save file...
SPASM64 -E bancsav.asm bancsav.8xv
ECHO -- Assembling game...
SPASM64 -L -E banchor.asm banchor.8xp
ECHO.

PAUSE
