CMonster for TI-84 Plus C Silver Edition / TI-84 Plus CE / TI-83 Premium CE
by Patrick Davidson 

eeulplek@hotmail.com
http://www.ocf.berkeley.edu/~pad/

######## Introduction

This is a breakout-style game for the TI-84 Plus C Silver Edition, TI-84 Plus,
and TI-83 Premium CE calculators.  To install on your calculator, you need only
send the one calculator file in the archive (CMONSTER.8XP for the TI-84 Plus CE 
and TI-83 Premium CE, or CMONSTER.8CK for the TI-84 Plus C Silver Edition) to
your calculator using TI Connect CE (or other software that communicates with 
the calculator).

The TI-84 Plus C Silver Edition version is a flash application.  To run it,
press the APPS key and then select CMonster from the list.

The TI-84 Plus CE / TI-83 Premium CE version is a plain asm program.  Run it by
entering the command Asm(prgmCMONSTER on the home screen.  Press 2nd and then 0
to display the CATALOG menu from which you can select Asm( from near the top.
Then use PRGM to display the programs list and select prgmCMONSTER from it.

If you are using TI-Connect CE to transfer the game, please note that you
should send it using the Calculator Explorer section.  It cannot be opened by
the open menu item or in the Program Editor section.

To use external levels, send the .8XV file for the level from your computer
to the calculator.  External levels are interchangeable among the different
calculator models that run CMonster.  External level files work both in RAM
and in archive.

The level editor is started from the title screen of the app for the TI-84
Plus C Silver Edition version.  For the TI-84 Plus CE / TI-83 Premium CE
version, the level editor is a separate program named CMEDITOR, which must be
transferred and run separately (in the same manner as the game itself).  
External levels can only be edited in RAM.  The editor will attempt to move
levels from flash to enable editing but this will fail if there is not enough
free RAM.  Changes made in the editor are saved immediately.

######## Controls

Title screen controls:

Press number keys from 1 (slowest) to 9 (fastest) to select speed
Press + and - to select easy or hard difficulty
- Note that you will get higher scores with faster speeds and hard mode
Press 2ND to begin the game
CLEAR exits the game
ALPHA skips to the high scores
PRGM allows you to preview what the levels look like
VARS opens the external level selection screen

In-game controls:

Left/right arrows move the paddle
DEL exits the game
P pauses the game, STAT resumes
- Note that the game prevents you from cheating by pausing too often
ENTER saves the game and exits

######## Version history

Version Date    Lines   Bytes   Description

91      08May13 583     1784    First release

152     08May13 788     2670    Increase to 9 levels
                                Added scoring
                                Added multiple lives
                                Fix paddle flicker

195     10May13 997     3187    Added speed selection
                                Added pause button
                                Fixed duplicate paddle when reaching new level
                                Enlarged ball and adjusted/fixed bouncing
                                
196     11May13 999     3191    Includes executable with release
                                Allow exiting while paused
                                Allow assembly with spasm
                                
269     12May13 1409    4744    Clears screen on exit
                                Added power-ups
                                Added save game
                                
309     18May13 1497    3695    Improved bonus collision detection
                                Increased to 10 levels
                                Optimized image storage to save space
                                Implemented clipping on screen bottom
                                
345     29Mar15 1759    4843    Increased to 12 levels
                                Added high score table
                                Now requires Doors CSE
                                Decreased initial lives to 3
                                Increased speed on top 2 speed settings
                                
373     12May15 1924    5911    Increased to 14 levels
                                Added sine scroll message on title screen
                        
477     17May15 2514    5914    Added TI-84 Plus CE version

489     17May15 2569    5911    Fixed 2 speed option
                                Fixed bonus drops on TI-84 Plus CE                              
                                Fixed text erasure on TI-84 Plus CE
                                Enabled saving game on TI-84 Plus CE
                                
518     24May15 2606    6056    Adjusted bonus drops to increase difficulty
                                Speed is now controlled more precisely
                                Increased to 17 levels
 
520     26May15 2632    6183    Increased to 19 levels
                        6528    Scoring now adjusted by bounce count
 
605     9Dec15  2895    6887    Added compression for TI-84 Plus CE version
                        5234    Increased to 23 levels
                                Now auto-exits if idle a few minutes
                                
634     6Jan16  3057    5526    Added compression for TI-84 Plus CSE version
                        5339    Increased to 25 levels
                                Added paddle expansion bonus
                                Fixed pause button
                                Fixed corruption of level 16+

696     13Jan16 3213    5285    Increased to 9 speed selections
                        5149    Added more ball angles with consistent speed
                                Ball can now be displayed at odd pixels
                                
711     14Jan16 3168    5390    Brick images no longer solid color
                        5251    Added sample brick graphics on title screen
                                Paddle is slightly slower relative to ball
                                
773     19Jan16 3532    6442    Added double-hit and invincible bricks
                        6267    Scores over 99999 now allowed
                                Brickthrough duration on a per-ball basis
                                Brick colors now specified in level data

865     28Jan16 3528    6429    Added triple-hit bricks
                        6601    Added more colors of bricks
                                Decreased graphics flickering
                                New unbreakable brick images
                                Added double-size bricks
                                Exit after a while during pause
                                
879     30Jan16 3625    6893    Added quadruple-sized bricks
                        7057    Increased to 28 levels
                                Improved endless bounce loop prevention

1004    14Feb16 4471    16384   Added level preview
                        9513    Added lowercase letters              
                                TI-84 Plus CSE version is now a flash app
                                Added external level support
                                Added extra-tall bricks
                                Added extra-wide bricks
                                Lives bonus with 99 lives now boosts score
                                Increased to 36 built-in levels

1014    17Feb16 4466    16384   Increased to 39 built-in levels
                        9546    Changed external level loading key to VARS
                                Fixed a bug that ended the game too early/late
                                
1160    26Dec16 5456    16384   Added on-calculator level editor
                        12592   Actually fixed the ending bug this time
                        
1173    2Jan17  5618    16384   Level editor can now enlarge level files
                        13595   Level editor can loop back to end
                                Allow lowercase letters/numbers in high scores
                                Increased to 43 built-in levels

1202    12Apr17 5971    16384   Added hard mode
                        15264   Rotate/zoom endgame graphics on 84+CE version
                                
######## Acknowledgements

Thanks to the following:

Kerm Martian for the first TI-84 Plus C program, and the TI-84 Plus C emulator
Lionel Debroux for pointing out some bugs
Brandon Wilson for the useful documentation on WikiTI
Kirk Meyer for Lite86 II which is used to compress the game
Critor for pointing out the TI-83 Premium CE key issue