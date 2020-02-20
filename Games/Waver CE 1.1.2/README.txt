__          __          __          __          __         _______
\ \        /  \        / /    /\    \ \        / /   /\    \ _____\
 \ \      / /\ \      / /    /  \    \ \      / /   /__\    \\____\\
  \ \    / /  \ \    / /    / /\ \    \ \    / /             \  __ /
   \ \  / /    \ \  / /    / /  \ \    \ \  / /    ______     \ \ \\
    \ \/ /      \ \/ /    / /    \ \    \ \/ /    /______\     \ \ \\
     \  /        \  /    / /      \ \    \  /    __________     \ \ \\
      \/          \/    /_/        \_\    \/    /__________\     \_\ \\        epsilon5


Introduction
============

Waver CE is a game inspired by Geometry Dash in which the player is tasked with avoiding the top and bottom of the screen
as well as randomly generated boxes. Over time, the game will speed up, making it increasingly difficult. In addition, 
modifiers may appear in the world that reverse gravity or even increase the slope of your line. I (epsilon5) created this
game in about three days as a side project while working on DR1VE. It didn't take that long to complete, but I hope you'll 
like it anyway. Since this game is inspired by Geometry Dash, all respective rights go to its creator for conceiving the 
original idea.

How to play
===========

This game is pretty easy to play: just press the up or down arrow key to go up, or release to go down. Try your best to 
avoid the obstacles. Note that if gravity is reversed, you'll need to release to go up. The modifiers that appear on the 
screen will appear as lines, impacting gameplay after they cross the player's position. Pink lines make the slope of your 
line higher; green resets the slope to normal. Blue lines make gravity normal; yellow lines reverse it. You can view 
your score in the upper left hand corner, and the FPS meter will appear in the bottom left hand corner. Version 1.1 added
a brand new Flappy Bird like mode, which is triggered after you pass through the mustard colored line. The navy blue line
makes gameplay revert to the normal wave mode. As of version 1.1, the game runs at about 44 FPS in the regular wave mode,
and 55+ in the Flappy Bird mode. The wave mode is slower because of a rework in the game engine to support color changes
while the game is running, as well as to work better with transitions between the Flappy Bird and wave modes and the fancy
new smooth double-buffered graphics. 

Customization
=============

Waver CE allows you to customize the background color, player color, and obstacle color. You can change these settings 
from the main menu by selecting either "Change color palette" or "Finetune colors". "Change color palette" lets you choose
between 8 different palettes that I made, in case you can't find a good combination yourself. In "Finetune colors", you 
can change player, background, and obstacle colors separately. You can even select a palette, then edit it in this menu.
As always, your color selection will even be saved, so you don't have to choose your favorite colors every time you run 
the program. 

Settings
========

From the settings menu, accessed from the main menu, the following settings can be accessed.
---------------------------------------------------------------------------|
Night theme       | Toggle the night theme on and off. When enabled,       |
                  | select screens (such as the main menu and completion   |
                  | screen) will have light text and/or selection boxes to |
                  | improve readability with dark backgrounds. This is off |
                  | by default when the background is white, and on by     |
                  | default when the background is black.                  |
---------------------------------------------------------------------------|
Opening animation | Toggle the opening animation on or off. On by default. |
---------------------------------------------------------------------------|
FPS meter         | Toggle the FPS meter on or off. This appears only on   |
                  | the play screen. Off by default.                       |
---------------------------------------------------------------------------|
Reset statistics  | Resets your high score, which can be viewed at any     |
                  | time by selecting "High score" from the main menu.     |
---------------------------------------------------------------------------|
Reset colors      | Restores custom colors to their default values, which  |
                  | are: white background, blue player, red obstacles.     |
---------------------------------------------------------------------------|

Scroll down to "Save and exit" to exit the settings menu once you have changed the settings you want. Settings 
automatically save on exit of the settings menu (by writing everything into the WAVERDAT appvar).  

Installation
============

To install:
1. unzip the folder "Waver CE"
2. open TI Connect CE
3. make sure you have the latest CLibs on your calculator (download it here if you don't: 
   https://github.com/CE-Programming/libraries/releases/tag/v8.4)
3. send the unzipped Waver CE and WAVERSPR appvar to your calculator
4. Enjoy!

NOTE: If you are upgrading from version 1.0 (the launch version), please also send "Waver save file converter" to your 
calculator. This program will convert your old WAVERHS appvar to the new WAVERDAT appvar. Note that only there are some 
new settings and statistics options, so this isn't perfect. Here's what you will retain from 1.0:
-your highscore
-your colors
-your selection for "opening animation"
-your selection for "show FPS meter"
To run, select WAVERCNV from the program menu or from your favorite shell, run it, and it'll do the rest. 

Final word
==========

Thanks for downloading my game. I really appreciate it. You've read long enough. Go play Waver CE (and maybe do something 
more productive afterward)!

Changelog
=========
-------------------------------------------------------------------------------------------------------------------------|
1.0.0      | First release...                                                                                            |
-------------------------------------------------------------------------------------------------------------------------|
1.1.0      | Gameplay                                                                                                    |
           | ========                                                                                                    |
           | [added] new Flappy Bird style mode                                                                          |
           | [added] "Game paused" prompt when you pause the game by pressing [y=]                                       |
           | [improved] general graphics and smoothness with new double-buffered graphics                                |
           | [improved] added border around modifier lines for added visibility                                          |
           | [fixed] "game text is all flickery" issue. See above.                                                       |
           | [fixed] score and FPS meters would sometimes shift during gameplay. See above.                              |
           | [fixed] FPS issue where the FPS would be displayed as 10000+ FPS at start of gameplay                       |
           |                                                                                                             |
           | Main menu                                                                                                   |
           | =========                                                                                                   |
           | [added] new palette options, which can be selected from "Change color palette"                              |
           | [added] "Revert to last" option in the color palette and color finetuning menus. This allows you to revert  |
           |         your colors to that of your last program exit or exit of the settings menu.                         |
           | [added] new options in settings menu                                                                        |
           | [improved] "Background color <>", "Player color <>", and "Obstacle color <>" removed from the main menu,    |
           |            consolidated into the "Finetune colors" menu                                                     |
           | [improved] "Highscore" section now renamed "Statistics", and allows you to view your highscore, games       |
           |            played, and average score.                                                                       |
           | [improved] main menu "WAVER" logo now dynamically changes color to match that of the obstacle color. This   | 
           |            improves readability.                                                                            |
           | [improved] in the opening animation, the box under the "WAVER" logo is now that of the player's color. This |
           |            improves readability, and looks better.                                                          |
           | [improved] you can now toggle menu wrapping on/off from the settings menu. When on, if you scroll past the  | 
           |            top or bottom of a menu, the cursor will jump to the other side.                                 |
           |                                                                                                             |
           | General                                                                                                     |
           | =======                                                                                                     |
           |                                                                                                             |
           | [added] subprogram WAVERCNV, which converts your WAVERHS save files to the new format                       |
           | [added] night mode, which improves readability and aesthetic appeal of the menus when the background color  |
           |         is dark. On by default when the background color is black, off by default when the background color |
           |         is black. Toggle on and off in the settings menu.                                                   |
           | [improved] save file appvar is now automatically archived on program exit to protect against RAM clears     |
           | [improved] main menu "WAVER" logo is now stored in the WAVERSPR appvar to cut down on main program size     |
           | [improved] "New high score!" animation now finishes with black instead of dark green (unless the night mode |
           |            is on, in which case it finishes with white).                                                    |
           | [improved] you can now set the background color to black                                                    |
-------------------------------------------------------------------------------------------------------------------------|                                                                        
1.1.1      | Gameplay                                                                                                    |
           | ========                                                                                                    |
           |                                                                                                             |
           | [improved] the up arrow now works to control the game instead of just the down arrow (should've fixed that  |
           |            earlier, sorry)                                                                                  |
-------------------------------------------------------------------------------------------------------------------------|             
1.1.2      | General                                                                                                     |
           | =======                                                                                                     |
           |                                                                                                             |
           | [improved] took screenshots out of the Waver CE folder to reduce size. They are still viewable in the       |
           |            Cemetech archives, however.                                                                      |
           | [improved] removed old screenshots from the Cemetech archives                                               |
-------------------------------------------------------------------------------------------------------------------------|






