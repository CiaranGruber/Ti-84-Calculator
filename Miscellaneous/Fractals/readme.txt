 --F1C by LogicalJoe--
  joseph@rrysavy.com
  Written in C
  Jul 5-8 2017; Dec 27-29 2017


F1C is the best Fractal grapher ever made for the TI-84 plus CE (and the TI-83 Premium CE, but no-one cares about that).
F1C is the third C program I ever wrote from scratch;
And is the fastest fractal grapher for the TI-84 Plus CE.

 --The included files--

fractals		- Main folder
 F1C.8xp		- The compiled program
 readme.txt		- This txt file
 ScreenShots		- Folder with (PNG) screen shots

 --Features--
- Fast Fractal Renderer
- Julia and Mandelbrot fractals
- Max and minimum Iterations
- Zoom max installed so you don't break your calc


 --Installation--

Follow the instructions from some other program or guide book.
TiLP and TI Connect CE should both work fine.

You also need the latest C Libraries on your calculator, that you can download here:

 https://github.com/CE-Programming/libraries/releases/latest

This program requires the libraries:
	GRAPHX
	KEYPADC
	LibLoad


 --How to use F1C--

Shell is recommended.

If you are using a 5.3 os or above, then:
After sending F1C.8xp to your calculator (RAM or ROM):
Press 'prgm', scroll to 'F1C', 'enter', 'enter'.

If you are not using a 5.3 os or above, then:
After sending F1C.8xp to your calculator's RAM:
Press '2nd', '0', scroll to 'asm(', 'enter', 'prgm', scroll to 'F1C', 'enter', 'enter',
And finally, update your os.


This should be self-explanatory:
Enter the program and it automatically graphs the Mandelbrot set,
Use the arrow keys to pan,
Use + and - to zoom,
Use * and / to change iterations for the next operation
(Please note that this will not affect Julia Rendering)
Use the number pad (9-0) to change pixilation for the next operation,
Force redraw by pressing enter,
Stop drawing by pressing del,
exit by pressing clear,
While in Mandelbrot mode, press ln to draw the associated Julia set,
(You can use the Julia set grapher the same way you use the Mandelbrot grapher)
Press log to see which Julia set you are graphing,
And press ln again to instantly return to the Mandelbrot grapher.

All referenced points are at the center of the screen!
Suggestion: keep the pixilation and iterations low until something interesting is found.

Initial picture at 20 iterations took ~8 minutes at full resolution, while
Initial picture at 200 iterations took ~40 minutes at full resolution.
	(Hey, it's better then F15's time of: ~20 hours!)

 --Special Thanks To--

* MateoConLechuga
 For the C SDK tools

And:
* MateoC
* Adriweb
* Jacobly
 For their patients and help putting the C compiler on my computer.


 --Notes--

If this program doesn't work for you,
 * Make sure you have the latest C libraries
 * try updating the tiOS; it was tested using tiOS 5.3.0.0037

Contact me if:
 * You find any bugs; I will do my best to fix them.
 * You have any problems; I will do my best to assist you.
 * You wish for me to post this program on another free-ware site.
 * You have any updates you would like to see in the future.


 --Last words--

Thank you for downloading. I hope you enjoy F1C.
Source is not included, but will be found on GitHub when it becomes available

 --Enjoy--