Independent C Project #7 -- SCOGGERC - Developer's ReadME
-----------------------------------------------------------------------------
_______________________________________
 ..:: Warning ::..

This program is only for the TI-84 Plus CE.
There is another version in the Cemetech archive that will work on the CSE.
This will not work on any monochrome calculator.

_______________________________________
 ..:: About ::..

This short readme details how to rebuild SCOGGERC for yourself since it
really isn't as simple as typing "make". Yet.

_______________________________________
 ..:: How to Build ::..
 
First of all, you'll want to download the CE Programming toolchain.
https://github.com/CE-Programming/toolchain/releases/tag/v7.3

Once you have all that set up, if you've modified any of the graphics
you'll need to manually run convpng from the src/gfx folder. On my
Win7 system, I would open an explorer window up to that folder,
Shift-RightClick then select "Open command window here".
Then simply type "convpng" (no quotes) and push ENTER.

Type "make" in a command line prompt open to the same folder as the
makefile is and push ENTER. The result should be output to the bin
folder.

IF YOU DO NOT WANT TO CHANGE THE FONT OR LEVEL SET DATA,
DO NOT CONTINUE PAST THIS POINT.

----

If you want to build the font tables, you'll also need to download
and install Python 2.7.x. Don't attempt to use Python 3 or higher,
or the build process will end in failure.

After modifying pf_tempestra_seven_condensed_modified.png to your
liking, run "fontconv.py" and the appropriate files will be output
in the src/ folder.

Run make to rebuild.

----

If you want to use the level editor and build them, you will, in
addition to Python 2.7.x, need to install AutoHotkey in order
to run "scedit.ahk".

After using the level editor to modify either "LevelSetModified.sls"
or "LevelSetPlus.sls", run "levelconv.py" and the appropriate files
will be output in the src/ folder.

Run make to rebuild.

