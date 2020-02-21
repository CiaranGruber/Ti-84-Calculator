**Please turn off Word Wrapping [Format menu]

2060: Nuclear Reactor Simulator [TI84+CE]
Version 1.6.0.1
(C) SM84CE

See the annotated screenshots for an explanation of what all the numbers
mean!
(Reactor_MAIN.png and Reactor_UPGRADES.png)
(Reactor_UPGRADES_2.png has an example of upgrade conditions not being met)

Overview
  It is the year 2060, and nuclear power is becoming cheaper than ever.
  So cheap that you've decided to get that basement reactor approved and
  up and running.  Did I forget to mention that these reactors are easily
  upgradable and run hotter than ever?  Also, there's no radioactive
  water that the reactor spits out -- it's all in the coolant.
  When you start the simulator for the first time, your reactor will
  begin to cool down to a chilly -1000 degrees Fahrenheit.
  It is up to you to manage your power output (in Electrical Units or
  Electricity Units per tick ([EU/t])) and your core temperature, because
  if the core temperature gets too hot, the fuel rods will start taking
  a HUGE hit...
  You'll also have to manage your reactor health.  If it hits 0, well...

  Note: 1 tick is defined in this game as one cycle of the main loop, which
  happens to be ~1 second.
------------------------------------------------------------------------------
Reactor Physics 101: Must read for success!!
  WARNING: THIS WAS MADE AS CLOSE AS POSSIBLE TO ACTUAL REACTOR WORKINGS,
  BUT IS *NOT* 100% ACCURATE.  THIS SHOULD NOT BE USED AS AN OPERATING
  MANUAL FOR NUCLEAR POWERPLANTS -- SERIOUS INJURY OR LOSS OF
  LIFE MAY OCCUR
  **ONLY CONTINUE IF YOU UNDERSTAND THE PRECEDING STATEMENT**

  Assuming you understand the disclaimer, let's get started!
  In order to get Energy (EU) production started, you need to raise
  the control rods.  You'll have to raise them a little, and you will also
  have to keep an eye on your core temperature when raising the rods up a lot.

  The default "Damage" temperature is 26K (26,000) degrees Fahrenheit
  (remember what I said about the hot reactors?).  Your fuel rod life will
  decrease at (.0001*C)% per tick, where C is the control rod status,
  measured from 0-100.  If you exceed the damage temperature (indicated on
  the "Core Temperature" line, It'll look something like this
  "CORE TEMPERATURE: -1000 °F, D: 26K, M: 35K"), your fuel rod life will
  decrease at an ADDITIONAL -.25% per tick.  This is important because if
  you don't have enough EU to buy another fuel rod (10,000K or 10 million EU)
  by the time your first one reaches 0%, it's GAME OVER!
  There is also a bigger GAME OVER if you let the reactor health reach 0, 
  The reactor can be repaired from the upgrades screen, it will tell you the
  temperature that your reactor has to be at.

  Also, the Core Temperature line is green when the temperature is is a good
  range, orange when it starts to reach or has slightly passed the Damage
  range, and red everywhere above the orange zone.

  If you hit the MAXIMUM Temperature (default: 35K), Your control rods will
  automatically be set to 0%.  It's best for you to wait until the reactor has
  cooled to or below the damage temperature before starting up again.

    Cooling:
  When the control rods are set to 0%, and the coolant boost pumps
  are off, the reactor will cool at -100°F/t [°F per tick].  When the control
  rods are at 100%, (coolant boost pumps off) the reactor will heat up at
  1000°F/t.  The coolant boost pumps can be toggled on and off, regardless of
  the core temperature, and WILL NOT automatically turn on/off!!

  With the coolant pumps on, the reactor will cool at -5°F/tick.  This can be
  upgraded in the Upgrades menu.  Upgrading the coolant will allow your
  control rods to be set higher with a lower risk of a reactor overheat.

    Fuel Rod replacement
  Will happen automatically if you have 1 or more fuel rods in the inventory,
  and the temperature is less than or equal to ((DamageTemp)-20000)°F.
  The default is ((26000)-20000) => 6000°F.  This is also displayed at the 
  bottom of the screen.

    Game end mechanics
  If you have the funds to buy another fuel rod, but currently have none,
  the game won't end.  If you DO NOT have 10000K EU and no fuel rods,
  the game will end...
  This simulates an inability to properly manage a virtual reactor, and you
  going bankrupt (because you get so much from selling to the power companies)
  Did I mention that the huge excess energy that you produce is sold to
  power companies? That's how you gain EU to buy your upgrades!
  The game will also end if your reactor health reaches 0...
------------------------------------------------------------------------------

               Controls
        KEY        |              Action
-------------------+-----------------------------------
[^] (up arrow)     | Raise control rods by 1%
[>] (right arrow)  | Raise control rods by 10%
[v] (down arrow)   | Lower control rods by 1%
[<] (left arrow)   | Lower control rods by 10%
[mode]             | Upgrades menu / Shop
[graph]            | Set control rods to 100%
[vars]             | Set control rods to 0%
[stat]             | Toggle Coolant Boost Pumps
[clear]            | Save and exit the game
[math]             | Pause the game, useful to update
                   | brightness in the middle
[Enter] | Un Pause and continue the game

  Shop (formerly the Upgrade Menu) controls:
[mode]: open upgrades menu
[1]: Buy Upgrade 1
[2]: Buy Upgrade 2
[n]: Buy upgrade/ item n, where n is MAX 7.
[del]: exit upgrades menu
LEFT and RIGHT arrow keys: move through the 2 pages
[prgm] on any page: Open Auto Control configuration (Auto Control must
       be purchased first)

**Note: on the bottom, there will be a "1", "2", "3", etc.  They will be green
  if the option is within your budget, red otherwise.
  **Available funds are shown at the top.
  For temperature-related upgrades, the line that indicates temperature will
  be green (if there is one) when your temperature is below the allowed value.

Auto Control Configuration Controls
[enter]: Save entered temperature and go back to the shop
[prgm]: Turn the "Specific Temerature" feature on and off
        Shown by "System Status" line, green = on, red = off
Use [0] - [9] to enter the hold temperature
[Vars]: Set to "default settings", this will set the hold to the highest
        temperature that you reactor can sustain without taking damage.

Sending:
  Send **ALL** 3 programs in this ZIP to your TI-84 Plus CE using a
    calculator linking program.
  If you are using a shell and OS 5.2, send prgmREACTOR to the Archive,
    and the other prgms to RAM
  If using OS 5.2 and NO shell, send *ALL* prgms to the RAM.
  If using OS 5.3+, send to EITHER RAM or Archive (Archive's better :P)

Running:
  Run prgmREACTOR from the homescreen or a shell, depending on if you
    have a shell and where you sent the program.
  Errors? 
    See this video, made by TheLastMillennial, a fellow Cemetech member
    cemete.ch./t14046

Changelog
  NOTE: SAVE FILES WILL NOT WORK ACROSS OTHER VERSIONS UNLESS OTHERWISE
    STATED
  V1.1.0   - Initial Release
  V1.4.0   - Added meltdowns and reactor health, reformatted Upgrades menu
  V1.6.0   - Added Auto Control feature
  V1.6.0.1 - Updated Controls Screen to reflect Pause feature
             V1.6.0 saves will still be compatible
             Added changelog to readme

Thanks for downloading!
Post feedback/ bug reports here:
  https://www.cemetech.net/forum/viewtopic.php?t=15191