// Converted using ConvPNG
// This file contains all the graphics sources for easier inclusion in a project
#ifndef __sprite_gfx__
#define __sprite_gfx__
#include <stdint.h>

#define sprite_gfx_transparent_color_index 0

extern uint8_t street_data[146];
#define street ((gfx_sprite_t*)street_data)
extern uint8_t street_red_data[146];
#define street_red ((gfx_sprite_t*)street_red_data)
extern uint8_t x_data[66];
#define x ((gfx_sprite_t*)x_data)
extern uint8_t taxi_front_data[66];
#define taxi_front ((gfx_sprite_t*)taxi_front_data)
extern uint8_t taxi_rear_data[66];
#define taxi_rear ((gfx_sprite_t*)taxi_rear_data)
extern uint8_t taxi_right_data[66];
#define taxi_right ((gfx_sprite_t*)taxi_right_data)
extern uint8_t passenger_data[202];
#define passenger ((gfx_sprite_t*)passenger_data)
#define sizeof_sprite_gfx_pal 18
extern uint16_t sprite_gfx_pal[9];

#endif
