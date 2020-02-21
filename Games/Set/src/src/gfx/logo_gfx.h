// convpng v6.8
// this file contains all the graphics sources for easy inclusion in a project
#ifndef __logo_gfx__
#define __logo_gfx__
#include <stdint.h>

#define logo_width 195
#define logo_height 90
#define logo_size 17552
extern uint8_t logo_data[17552];
#define logo ((gfx_sprite_t*)logo_data)
#define sizeof_logo_gfx_pal 512
extern uint16_t logo_gfx_pal[256];

#endif
