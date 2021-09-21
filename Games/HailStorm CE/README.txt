  _    _   *           *     _____  *               *
 | |  | |        *         |  ___|  ____*  ___   ___     *
*| |__| |*   ^    || ||*   | |___  |_  _| | _ | | _ \ |\  /|
 |  __  |   /_\ * || ||    |___  |*  ||   || ||*||_|| | \/ |
 | |  | |  /___\  || ||__   ___| |   ||   ||_|| | _ / ||\/||
 |_|* |_| //   \\ || |___| |_____|   ||*  |___| || \\ ||  ||            epsilon5


 INTRODUCTION
 ============
 HailStorm is a space shooter for the TI-84 Plus CE/ TI-83 Premium CE calculators, aimed at being the best asteroids-type
 game on the market. Featuring smooth gameplay (30+ FPS!), 10 ships to unlock through the playing of the game, over
 650,000 ship/color combinations, and lots of smooth graphics and animations, HailStorm CE should be a fun program to 
 play in math class or anywhere. In addition to this, it also features an intuitive and visually appealing UI that is the 
 first of its kind and the ability to save your statistics and view them at any time within the statistics page. 

 INSTALLATION
 ============
 Installing this game is very easy. Here's what you'll need to get started: 
 -TI Connect CE or other software that enables you to send files to your calculator
 -a copy of HailStorm CE
 -your calculator
 -a USB->calculator link cable
 Once you have acquired these materials, follow the following steps to send HailStorm CE to your calculator:
 1. unzip the folder "HailStormCE1.0.0"
 2. open TI Connect CE or other connectivity software
 3. make sure you have the latest C libraries on your calculator (download here if you don't: 
    https://github.com/CE-Programming/libraries/releases/tag/v8.7)
 4. send HailStorm CE to your calculator (you won't need any more appvars or anything, as everything is packaged within 
    this main program)
 5. run HailStorm CE from the [pgrm] menu or from your favorite shell
 
 CONTROLS
 ========
 The controls, as always, are pretty simple:
 MENUS:
 [y=] to [graph]: interact with the bottom toolbar, which will usually have some options available above it
 [<], [>], [^], and [v]: change the selected option when applicable
 [2nd] or [enter]: select
 GAMEPLAY:
 [<]: move your ship to the left
 [>]: move your ship to the right
 [2nd]: fire a bullet
 [alpha]: activate your shield
 [y=]: pause the game

 GAMEPLAY
 ========
 The gameplay in HailStorm CE is fairly simple. All you have to do is dodge the asteroids, using your guns or your shield
 to get you out of tight spaces as necessary. With that said, there are a few things to remember, things that will change
 up the seemingly simple gameplay:
 SHIELD: the shield will give you temporary invulnerability against the asteroids, enabling you to get out of any tight
         position you may be in. This does have to recharge before you can use it. When it's ready to be used, you will 
         see that the shield countdown bar is filled up all the way and green. When it is being used, it gives indication 
         of how much time is left with a blue bar, and when it is recharging, the bar will be red. 
 BULLETS: you are also able to shoot down asteroids with your guns. When the guns are ready, the gun countdown bar,
          located in the bottom left hand corner of the display, will be green. When it is recharging, the bar will be red.
          NOTE: you can fire 5 bullets in each recharge cycle, as in Tanks! on the Wii
 POWERUPS: sometimes, when you shoot down asteroids, you may notice that a powerup is spawned. There are three types of 
           powerups: health, shield, and gun. The health powerup will recharge your health by a certain amount, the gun
           powerup will reset your gun timer, enabling you to fire again, and the shield powerup will reset your shield 
           timer, enabling you to reactivate your shield. You can activate any one of these powerups by running into it
           with your ship, and it will be activated instantaneously after this is done. 

 BOSSFIGHTS
 ==========
 Version 2.0.0 added the highly requested bossfights to the game. To start a bossfight, just pick up the red star that will
 be randomly dropped from asteroids as for powerups. Bosses have random bullet speed, speed, bullet recharge time, health,
 strength, and ship, all of which is scaled according to your progression in the game (difficulty). They will be difficult,
 but will give you a large points bonus if you manage to beat the boss.

 SHIPS
 =====
 The first option in the menu of the game (accessible by pressing [y=] from the main menu), is the ship selection menu. 
 Here, you can see all of the ships you have currently unlocked, and select a different ship if you so desire. There are
 currently (as of 2.0.0) 14 ships in the game, all of which has a different unlock requirement. You can unlock these ships
 by completing the assignment dictated after "To unlock:". If the ship is unlocked, it will give an option to press [2nd]
 or [enter] to select it, which is shown in a white box below the ship. If the ship is selected, the box will be green and 
 say "SELECTED". 
 NOTE: ship number 8 has the requirement of owning all of previous programs. These programs are as follows:
       1. DR0VE CE
       2. Waver CE
       3. Ace Recon CE
       These programs are all good and worth the download. In order to unlock ship number 8, you will need to complete 1 
       game in each of the games. In the event that you don't have much storage on your calculator, and you want to delete
       any of these programs, you may freely do so with the knowledge that the ship will remained unlocked as long as you
       still have the save file for each of the programs on your calculator (DR0VEDAT, WAVERDAT, and ACRCNDAT,
       respectively). Each of these is around 30 bytes. So, YOU DO NOT NECESSARILY HAVE TO HAVE ALL OF THE PROGRAMS ON 
       YOUR CALCULATOR TO RETAIN THIS ACHIEVEMENT!!
       With that said, check out the other programs here: 
       https://www.cemetech.net/forum/profile.php?mode=viewprofile&u=26533

 OPTIONS
 =======
 Here are all of the options available in the game so far:
  _______________________________________________________________________________________________________________________
 | NAME            | FUNCTION                                                                                            |     
 | ====            | ========                                                                                            |
 | Menu Wrapping   | With this option on, the menus in the game will jump to the opposite end of the menu if they are    |
 |                 | past. So, if you scroll past the first option in the menu, it will jump to the last option, and     |
 |                 | vice versa.                                                                                         | 
 | Show FPS        | Toggles the FPS meter on or off. When on, it will show the current FPS of the game. Note that this  |
 |                 | FPS will only be visible in the main game screen.                                                   |
 | Hard Mode       | Enables the hard mode ingame, which disables all powerups. This was how the game was before         |
 |                 | powerups were added, and was significantly harder than the current version.                         |
 | Starfield Off   | Disables the starfield background to improve performance, but only in the gameplay screen           |
 | Reset statistics| Resets all of your statistics, not including your current color selections.                         |
 | Shield Color    | Change the color of your shield when activated.                                                     |
 | Bullet Color    | Change the color of your bullets.                                                                   |
 | Difficulty      | Change the initial difficulty of the game                                                           |
 |_________________|_____________________________________________________________________________________________________|

 CREDITS
 =======
 Thanks to all of the people who helped out on the project (organized by category):
 GRAPHICS: matkeller19 (who designed the first ship, ship number 1), KingDubDub (who designed ship #14)
 FEEDBACK: tr1p1ea, malagas_fire, Jeffitus, beckadamtheinventor, tr1wrk
 PROGRAMMING HELP/ADVICE: MateoConLechuga, Runer112
 
 CONCLUSION
 ==========
 Thanks again for downloading and playing my game. If you want to check out some of my other programs or submit feature 
 requests or feedback for this game, please visit www.cemetech.net and search for HailStorm CE, or my username, epsilon5.

 CHANGELOG
 =========
  _______________________________________________________________________________________________________________________
 | VERSION        | INFORMATION                                                                                          |
 | =======        | ===========                                                                                          |
 | 1.0.0          | Initial release...                                                                                   |
 | 1.1.0          | [added] ability to save the game and come back to it after exit of the program                       |
 |                | [added] hard mode of higher difficulty than the regular one                                          |
 |                | [added] ability to turn starfield background off if you want                                         |
 |                | [added] three new ships                                                                              |
 |                | [added] a new powerup, which clears the screen of all asteroids when obtained                        |
 |                | [improved] general framerate increases and collision optimizations                                   |
 |                | [improved] bullet recharge reworked                                                                  |
 |		  | [improved] obtaining a shield powerup no longer cancels an existing shield                           |
 |                | [improved] the pause menu now blacks out the screen to discourage cheating                           |
 |                | [improved] bullet fire position is more realistic at extreme angles                                  |
 |                | [improved] asteroid damage is now related to the asteroid's speed rather than just its size          |
 |                | [improved] asteroids now have some basic momentum when they are shot, rather than just stopping      |
 |                |            in the air                                                                                |
 |                | [improved] shield flickers when it is running out                                                    |
 |                | [fixed] fixed the clipping issues                                                                    |
 |                | [fixed] the bug where you could drift left at the beginning of the game by tapping the left arrow    |
 |                |         key                                                                                          |
 |                | [fixed] the bug that would break the game at 38250 points						 |
 |                | [fixed] the bug where your ship wouldn't autocenter when holding a key 				 |
 |                | [fixed] the bug where your accuracy could be displayed as -1%                  			 |
 |                | [fixed] the scroll bar on the about screen now reaches the bottom of the screen                      |
 | 2.0.0          | [added] bossfights                                                                                   |
 |                | [added] 1 new ship                                                                                   |
 |                | [added] time played statistic                                                                        |
 |                | [added] adjustable initial difficulty level                                                          |
 |                | [improved] general performance improvements and optimizations                                        |
 |                | [improved] bullet recharge system                                                                    |
 |                | [fixed] keypress bullet fire bug                                                                     |
 |                | [fixed] the game no longer freezes if you press a key after dying                                    |
 |                | [fixed] an exploit to the game that would allow you to infinitely recharge your health by going      |
 |                |         outside of the screen (does not affect older versions)                                       |
 |                | [fixed] bullet y could overflow                                                                      |
 | 2.0.1          | [fixed] boss bullets deflected with shield now can damage the boss                                   |
 |                | [fixed] deflected boss bullets could overflow when passing the top of the screen                     |
 |                | [improved] boss battles now reward less points to better balance gameplay                            | 
 |________________|______________________________________________________________________________________________________|
