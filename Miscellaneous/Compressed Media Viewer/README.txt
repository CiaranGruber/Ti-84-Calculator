To convert Images, double click TICREATE.exe and follow the instructions presented under the EXPORT button.
In order to then view those Images on your calc, unzip the archieve and send them to your calculator using the TI Conncect software. If you do not have it installed, just watch TheLastMillennials tutorial on youtube:
https://youtu.be/gwctk-E0XXc
You also have to send Viewer.8xp to your calculator and clibs.8xg which can be downloaded from
https://github.com/CE-Programming/libraries/releases
The converter scales large images down to a resolution of 240*320, so some Images might be stretched. Rgb16 images automaticly get scaled to a resolution of 240*320. If you want to store images containing only Ttxt, I recommend the 1bpp setting, if you want to store Pictures, the rgb setting gives the best quality. There are lots of settings to archieve a good compromise between picture quality and size. Picture sizes are adjustable from 2kb up to 64kb.
When opening the calculator application, you navigate with the D_PAD and View Media by pressing ENTER. When you have more than 48 Files on your calc, just press The Left Key to be sent to the next Tab of the Menue. You can also use the upmost keys "y=" to "graph" to select a tab.
If you want to watch all your uploaded Images as a movie press the mode key on the calculator, while in the file select menue. Only rgb16 images are supported to be watched as a movie. Use ffmpeg to decode your video files and add all of the produced image files to the converter. Then select the fitting rgb16 compression.
rgb16  	  -> 40  Frames 
rgb16_32k -> 81  Frames
rgb16_16k -> 162 Frames
rgb16_8k  -> 325 Frames  -> 13fps
rgb16_4k  -> 650 Frames
rgb16_2k  -> 1300 Frames
I'd recommend rgb16_8k for video as it is a decent compromise between Image quality and Framerate