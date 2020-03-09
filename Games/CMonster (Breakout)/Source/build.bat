for /F %%a in ('wmic os get LocalDateTime /value ^| findstr Local') do set "DATETIME=%%a"
set "DATETIME=%DATETIME:~14,17%"
md "old\%DATETIME%"
copy *.asm "old\%DATETIME%"
copy *.i "old\%DATETIME%"
copy *.txt "old\%DATETIME%"
copy *.bat "old\%DATETIME%"

spasm64 zoom.asm zoom.bin -E -T
spasm64 editorce.asm -T -E
lite86 editorce.bin compressedce.bin
spasm64 loaderce.asm cmeditor.8xp -E -T
spasm64 ti84ce.asm -T -E
lite86 ti84ce.bin compressedce.bin
spasm64 loaderce.asm cmonster.8xp -E -T
del cmonster-ti84ce.zip
7za a -bd -tzip cmonster-ti84ce.zip *.asm *.bat *.txt *.i *.gst *.py *.png cmonster.8xp cmeditor.8xp > nul

spasm ti84cse.asm -T
lite86 ti84cse.bin compressed.bin
spasm64 loader.asm loader.bin -T 
rabbitsign -t 8xk -g -b -f loader.bin -k 010F.key -o cmonster.8ck
del cmonster-ti8c.zip
7za a -bd -tzip cmonster-ti8c.zip *.asm *.bat *.txt *.i *.gst *.py *.png cmonster.8ck > nul