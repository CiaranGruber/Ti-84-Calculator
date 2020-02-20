for /F %%a in ('wmic os get LocalDateTime /value ^| findstr Local') do set "DATETIME=%%a"
set "DATETIME=%DATETIME:~14,17%"
md "old\%DATETIME%"
copy *.asm "old\%DATETIME%"
copy *.i "old\%DATETIME%"
copy *.txt "old\%DATETIME%"
copy *.py "old\%DATETIME%"

spasm64 main.asm main.bin -E -T
spasm64 rotzoom.asm rotzoom.8xp -E -T
del rotzoom-ti84ce.zip
7za a -bd -tzip rotzoom-ti84ce.zip *.asm *.bat *.txt *.i *.8xp *.py *.png > nul