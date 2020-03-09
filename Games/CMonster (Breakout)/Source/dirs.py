#/usr/bin/python

import math

x_dir = ''
y_dir = ''
for x in range(12):
	deg = 5 * (float(x) + 4)
	rad = math.radians(deg)
	if x_dir != '':
		x_dir = x_dir + ','
	if y_dir != '':
		y_dir = y_dir + ','
		
	x_dir = x_dir + str(int(136.0 * math.sin(rad)))
	y_dir = y_dir + str(int(272.0 * math.cos(rad)))
	
print "ball_directions_x:"
print "        .db     " + x_dir
print "ball_directions_y:"
print "        .db     " + y_dir