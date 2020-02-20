======================================================================
				TIMER
======================================================================


This is a very accurate timer for the CE, based on the 32768Hz crystal.
It is very easy to use:
1:Asm(prgmTIMER) - Start the timer
2:Asm(prgmTIMER) - Stop the timer. The time is loaded in Ans. 
You don't need Ans in v1.3. Just call Asm(prgmTIMER) and it will 
automatically start or stop. This is very useful to get the exact time 
how long a BASIC program will run. 
Have fun with it!


======================================================================
Changelog:
======================================================================
v1.0 - 2/20/2016 - Created program
v1.1 - 2/20/2016 - Updated output
v1.2 - 2/20/2016 - Fixed minor bug + optimizations
v1.3 - 2/20/2016 - Fixed bug + removed Ans