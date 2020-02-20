Advanced Wait State Changer
v2.20
By: TheLastMillennial

**DISCLAIMER:
By using this program, you agree that YOU are responsible for following all safety instructions and features
and YOU are responsible for ANY AND ALL results (whether intended or unintended) of this program. 
Messing around with Wait States is NOT SAFE and you run a huge chance of crashing your calculator unless
you follow all safety features and tips. (Tips below) If you do not agree to this disclaimer, then don't use
this program (duh). If you would like to express any concerns, please post to the topic linked at the very
bottom of this ReadMe.

**Compatibility:
Compatible with
TI-84 Plus CE older than revision M*
TI-84 Plus CE -t older than revision M*
TI-83 Premium CE

NOT compatible with
TI-84 Plus CE revision M or newer*
TI-84 Plus CE -t revision M or newer*
TI-83 Premium CE Edition Python*
TI-84 Plus C Silver Edition
Any monochrome calculator

*To see what revision your calculator is, look on the back of it. 
Look for a code that is formatted as <letter> - <number> <number> <number> <number> <letter (optional)> 
For example:
L-0315 or L-519M
If you see an M or a later letter at the end, then your calculator is revision M or newer. If you do not have an M or a latter letter OR 
you do not see a letter at all then you have a compatible calculator. (More information: www.ceme.tech/t14663 )

**About:
This program gives you near full control over the Wait States! 
*You can now speed or slow down the calculator beyond the OS limits. 
*You can quickly get the current Wait State value simply by starting the program!
*You can quickly set a custom speed for your calculator by using the hotkey!
*Tons of safety features so you are less likely to freeze your calculator.

**Safety Tips:
1. Install Cesium.
   a. Install Cesium onto your calculator (Download: https://www.cemete.ch/DL1372 )
   b. Run prgmCesium, then press [Apps]
   c. Execute the Cesium App and press [mode]
   d. Make sure the squares next to 'Backup RAM before executing programs' and 'Enable keypad shortcuts' are filled.
   e. press [clear] to exit to the Cesium main screen, then press [clear] again to exit Cesium.
   f. Press [on]+[8] . This will backup your files so everything will be protected if you are forced to reset your calculator.
   g. YOU MUST RE-BACKUP EVERY TIME YOUR CALCULATOR RAM RESETS
   h. You can view a video that spotlights all of Cesium's many backup features here: https://youtu.be/hZDzV1CDN3k

2. Archive all programs you aren’t using, unless you have OS 5.3 or above, then you should Archive all programs.

3. Back up your calculator to your computer. This way you can restore your files if something breaks your calculator
   a. Connect your calculator to your computer, open TI Connect CE, go to 'calculator explorer'
   b. Press ctrl+a to select all, then click 'send to computer'
   c. Select a location to store all your files and click 'save'.

OK enough of the scary stuff, here's the rest of this ReadMe!

**About:
So, what is a Wait State? (Thank you to Mr Womp Womp for this explanation!)
When a processor asks for data from memory, it must wait for it to come back because memory can't fetch data as fast as the CPU can process it. 
The number of wait states is just the amount of clock cycles that the processor waits when fetching things from memory, 
which is why it is directly correlated to the amount of instructions that you can do in a time slice, 
and therefore, how fast the device runs.

**Instructions:
Unplug all USB peripherals. (Or else restrictions will be applied)
Run prgmADVSPEED
Leave prgmGETBUSPR , prgmSETSTATE and prgmGETSTATE alone. (How they can be used separately is described below)
NOTE: Maximum speed at value 1, minimum speed at value 255 (This will most likely make your calcualtor unusable, safest slowest speed is about 40).

[^],[v]------------Increase and decrease (respectively) Waits States by 1 
[<],[>]------------Increase and decrease (respectively) Wait States by 10 
[Clear]------------Save and quit to home screen
[Enter]------------Go to the custom Wait State input screen
[Mode]-------------Define value for the [+] hotkey to use
[+]----------------Hotkey to set wait states to a certian value

**Advanced Instructions
Asm(prgmGETSTATE) will store the current Wait State value into Ans.
Asm(prgmSETSTATE) will set the current Wait State value to whatever is stored in Ans.
Asm(prgmGETBUSPR) will store 1 in Ans if there is something in the USB port. Returns 0 in Ans otherwise.
You may use these programs in your own programs as much as you'd like. Please credit TheLastMillennial in the ReadMe though.

**Installation:
1. Open TI-Connect CE
2. Connect calculator to computer
3. Go to the Calculator Explorer tab
4. Click on the icon with the arrow pointing out of the computer
5. Send all 4 .8xp files to your calculator
6. Send the C Libraries if they are not already installed. Get them at: tiny.cc/clibs
Never done this before? Here is a complete tutorial on how to send any file to your calculator: 
https://www.youtube.com/watch?v=gwctk-E0XXc
Having issues? Here is a troubleshooting video that helps fix most errors:
https://youtu.be/-TweNnHuFCQ

**Uninstallation:
1. Press [2nd]>[+]>[2]>[7]
2. Scroll down and delete (with [del]) ADVSPEED , GETBUSPR , SETSTATE , and GETSTATE
(note a few of my other programs may require GETBUSPR , SETSTATE and/ or GETSTATE)

**Thank you:
MateoConLechuga for greatly assisting with my subprograms
Jacobly for assisting with my subprograms
DrDnar for testing this on the Edition Python
Adriweb for helping me translate my error message to French

**Bugs:
Report any bugs, anomalies, unmined copper deposits, or typos you encounter to this topic: https://www.cemete.ch/t14663
Suggestions are welcome as well.

**Change log:
v2.20
Rewrote how incompatible calculators are detected
Added protection against running on a revision M calculator or newer
Rephrased error message

v2.14
Added protection against running on TI-83 Premium CE Edition Python
Added hotkey
Adjusted saftey restrictions from a max of 50 down to 40
Archived list SPED after execution

v2.05
Initial release