
 ##       #### ######## ######## 
 ##        ##  ##       ##       
 ##        ##  ##       ##       
 ##        ##  ######   ######   
 ##        ##  ##       ##       
 ##        ##  ##       ##       
 ######## #### ##       ######## for TI-84 Plus CE by Pi_Runner

>>>[Description]<<<

This is a quick and simple implementation of Conway’s Game of Life (see https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life). I’ve included the source, which should be pretty clean, though I’d appreciate any tips for optimization.

>>>[Installation]<<<

Using TI Connect CE, send LIFE.8xp to your calculator. The latest C libraries are also necessary. You can find them at https://github.com/CE-Programming/libraries/releases/latest

>>>[Play]<<<

Select "Asm(" from the catalog, then press [prgm] and select “LIFE”, then press enter. However, if you know you have OS 5.3 or later installed on your calculator, you don’t need the “Asm(“ token in front.

>>>[Instructions]<<<

The program begins in edit mode. Use the arrows to move the green cursor. Press [2nd] to generate white (live) cells, and [del] to generate black (dead) cells. Pressing [mode] produces a random state. To begin the simulation, press [enter]. Pressing [enter] again toggles back to edit mode. To exit the program, press [clear].

>>>[Controls]<<<

[enter] - toggles between edit mode and the simulation
[arrows] - moves the edit cursor
[2nd] - generates white (live) cells
[del] - generates black (dead) cells
[mode] - produces a random state
[clear] - exits the program