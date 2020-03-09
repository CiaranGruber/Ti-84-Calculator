import math
import os
from PIL import Image

sines = open("sines.i", "w")
for x in range(256):
        deg = x * 360.0 / 256.0
        rad = math.radians(deg)
        sines.write(" .db " + str(int(127*math.sin(rad))) + "\n")
        
def process_img(src, dest):
        image = open(dest, "w")
        image_input = Image.open(src)
        last_color_used = -17
        colors = {}

        for y in range(16):
            for x in range(256):
                color = image_input.getpixel((x, y))
                print color
                if color not in colors:
                    last_color_used = last_color_used + 17
                    colors[color] = " .db " + str(last_color_used) + "\n"
                image.write(colors[color])
                
process_img("win.png", "win.i")
process_img("lose.png", "lose.i")