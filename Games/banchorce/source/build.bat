@ECHO OFF

ECHO ----- Assembling Banchor: The Hellspawn for the TI-84+CE...
ECHO.

ECHO -- Converting graphics...
CD GFX
CONVIMG
ECHO.

ECHO -- Compressing graphics...
COPY /B tileset.bin + sprplayer.bin + sprknight.bin + sproctopus.bin + sprpotatobug.bin + sprjellyfish.bin + sprbat.bin + sprsnake.bin + sprbee.bin + sprfrog.bin + sprspider.bin + sprmummy.bin + sprpigmy.bin + sprtroll.bin + sprmudman.bin + sprtreemonster.bin + sprshadow.bin + sprdeathlord.bin + sprkoranda.bin + sprspawn.bin + sprbullet.bin + sprexplosion.bin + sprorb.bin + sprhud.bin bancgfx.bin > NUL
HUFFMAN title.bin bancgfx.bin tiles_boss_walls.bin tiles_boss_1.bin tiles_boss_2.bin tiles_boss_3.bin tiles_boss_4.bin tiles_boss_5.bin tiles_boss_6.bin tiles_boss_7.bin tiles_boss_8.bin sprboss1.bin sprboss2.bin sprboss3.bin sprboss4.bin sprboss5.bin sprboss6.bin sprboss7.bin sprboss8.bin bancgfx.huf
HUFFMAN fontarc.bin fontarc.huf
DEL title.bin > NUL
DEL tile*.bin > NUL
DEL spr*.bin > NUL
DEL bancgfx.bin > NUL
DEL font*.bin > NUL
DEL gfx.txt > NUL
CD..
ECHO.

ECHO -- Assembling graphics..
SPASM64 -E -I gfx bancgfx.asm bancgfx.8xv
ECHO.

ECHO -- Assembling maps...
SPASM64 -E -I gfx bancmaps.asm bancmaps.8xv
ECHO.

ECHO -- Assembling save file...
SPASM64 -E -I gfx bancsav.asm bancsav.8xv
ECHO.

ECHO -- Assembling game...
SPASM64 -L -E -I gfx banchor.asm banchor.8xp
ECHO.

PAUSE
