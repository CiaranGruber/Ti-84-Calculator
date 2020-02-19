/* Keep these headers */
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <tice.h>

/* Standard headers - it's recommended to leave them included */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* C CE Graphics library */
#include <graphx.h>
#include <fileioc.h>

#include "main.h"

#define VERSION 2

/* Global variables */
uint8_t ring[19]; //The ring of atoms
uint8_t highest_atom = 0, lastRedPlus = 1;
uint24_t score, moves;
uint8_t gamemode, seconds;

/* Put all your code here */
void main(void) {
	ti_var_t file;

	uint8_t ring_GM[19][4]; //The ring of atoms
	uint8_t highest_atom_GM[4];
	uint24_t score_GM[4], moves_GM[4];

	uint24_t Hscore[4] = 0;
	uint8_t Hatom[4] = 1;
	
	uint8_t key = 1;
	
	char str[14];
	const char *mode[4] = { "Classic","Time Attack","zen","Geneva" };
	
	srand(rtc_Time());

	memset(ring_GM, 0, sizeof(ring_GM));
	memset(Hscore, 0, sizeof(Hscore));
	memset(Hatom, 1, 4);

	/* Try to load the save file */
	ti_CloseAll();
	file = ti_Open("ATOMAS", "r");
	if ( file ) {
		if (ti_GetC(file) == VERSION) {
			ti_Read(&ring_GM, sizeof(uint8_t), sizeof(ring_GM) / sizeof(uint8_t), file);
			ti_Read(&score_GM, sizeof(uint24_t), sizeof(score_GM) / sizeof(uint24_t), file);
			ti_Read(&Hscore, sizeof(uint24_t), sizeof(Hscore) / sizeof(uint24_t), file);
			ti_Read(&Hatom, sizeof(uint8_t), sizeof(Hatom) / sizeof(uint8_t), file);
			ti_Read(&highest_atom_GM, sizeof(uint8_t), sizeof(highest_atom_GM) / sizeof(uint8_t), file);
			ti_Read(&moves_GM, sizeof(uint24_t), sizeof(moves_GM) / sizeof(uint24_t), file);
			ti_Read(&seconds, sizeof(uint8_t), sizeof(seconds) / sizeof(uint8_t), file);
		}
	} ti_CloseAll();

	gfx_Begin(gfx_8bpp);
	gfx_SetPalette(colors_pal, sizeof colors_pal, 0);
	gfx_SetTextFGColor(0x01);

	/* some timer things for TIME ATTACK */
	boot_SetTimersControlRegister(0);
	// By using the 32768 kHz clock, we can count for exactly 1 second here, or a different interval of time 
	boot_SetTimer1ReloadValue(32768);
	boot_SetTimer1Counter(32768);
	// Enable the timer, set it to the 32768 kHz clock, enable an interrupt once it reaches 0, and make it count down 
	boot_SetTimersControlRegister(TIMER1_ENABLE | TIMER1_32K | TIMER1_INT | TIMER1_DOWN);

	while ( key != sk_Clear ) {
		if ( key ) {
			sprintf(str, "<%s>", mode[gamemode]);
			gfx_SetDrawBuffer();
			gfx_FillScreen(0x00);
			gfx_SetColor(Hatom[gamemode] + 5);
			gfx_Circle(160, 120, 110);

			draw_atom(160, 120, Hatom[gamemode]);
			
			gfx_PrintStringXY(str, 160 - gfx_GetStringWidth(str) / 2, 58);

			gfx_PrintStringXY("Highscore:", 124, 68);
			gfx_SetTextXY(132, 82);gfx_PrintUInt(Hscore[gamemode], 7);

			gfx_PrintStringXY("Press the any key to start", 71, 152);
			
			gfx_PrintStringXY("By Rico", 1, 231);
			gfx_PrintStringXY("v2.0", 294, 231);
			
			gfx_SwapDraw();
		}

		key = os_GetCSC();

		/* left key pressed */
		if ( key == sk_Left ) {
			if ( gamemode > 0 ) gamemode--;
			continue;
		}

		/* right key pressed */
		if ( key == sk_Right ) {
			if ( gamemode < 3 ) gamemode++;
			continue;
		}

		if (key && key != sk_Clear) {
			memcpy(ring, (*ring_GM + gamemode*19), sizeof(ring));

			if (!ring[0])
				init_ring();
			else {
				highest_atom = highest_atom_GM[gamemode];
				score = score_GM[gamemode];
				moves = moves_GM[gamemode];
			}

			game_loop();
		
			highest_atom_GM[gamemode] = highest_atom;
			score_GM[gamemode] = score;
			moves_GM[gamemode] = moves;

			memcpy((*ring_GM + gamemode*19), ring, sizeof(ring));

			if (score > Hscore[gamemode])
				Hscore[gamemode] = score;
			if (highest_atom > Hatom[gamemode])
				Hatom[gamemode] = highest_atom;

			file = ti_Open("ATOMAS", "w");
			if (file) {
				ti_PutC(VERSION, file);
				ti_Write(&ring_GM, sizeof(uint8_t), sizeof(ring_GM) / sizeof(uint8_t), file);
				ti_Write(&score_GM, sizeof(uint24_t), sizeof(score_GM) / sizeof(uint24_t), file);
				ti_Write(&Hscore, sizeof(uint24_t), sizeof(Hscore) / sizeof(uint24_t), file);
				ti_Write(&Hatom, sizeof(uint8_t), sizeof(Hatom) / sizeof(uint8_t), file);
				ti_Write(&highest_atom_GM, sizeof(uint8_t), sizeof(highest_atom_GM) / sizeof(uint8_t), file);
				ti_Write(&moves_GM, sizeof(uint24_t), sizeof(moves_GM) / sizeof(uint24_t), file);
				ti_Write(&seconds, sizeof(uint8_t), sizeof(seconds) / sizeof(uint8_t), file);
			}
			ti_SetArchiveStatus(true, file);
		}
	}

	gfx_End();
	pgrm_CleanUp();
}

/* This is the main game loop */
void game_loop() {
	/* This are variables */
	uint8_t num_atoms, current_atom, next_atom = 1, selected = 0, key = 1;
	int8_t i, j;
	double spacing = 1.8, angle;
	bool prev_was_minus = false;

	/* Find the amount of atoms in the ring */
	for (num_atoms = 0; ring[num_atoms]; num_atoms++) {}

	current_atom = getNewAtom(num_atoms);
	draw_all(num_atoms, current_atom, spacing);

	while (key != 0x0F) {
		if (key) {
			draw_pointer(num_atoms, selected, spacing, current_atom);
		}

		key = os_GetCSC();

		/* left key pressed */
		if (key == 0x02) selected = (num_atoms+selected-1)%num_atoms;
		/* right key pressed */
		if (key == 0x03) selected = (selected + 1) % num_atoms;

		/* mode key pressed(convert atom in plus atom, if the previous atom was a minus atom) */
		if (key == 0x37 && prev_was_minus) {
			current_atom = 126;
			prev_was_minus = 0;
		}

		/* enter or 2nd key pressed */
		if (key == 0x09 || key == 0x36) {
			/* if the current atom is a plus atom, or a normal atom; move the atom inside the loop */
			if (current_atom != MINUS_ATOM && current_atom != NEUTRINO) {
				double cosx, siny;

				if (current_atom != LUXON) {
					num_atoms++; selected++;
					spacing -= (M_TAU / num_atoms)*(selected) -(M_TAU / (num_atoms - 1)*(selected - 1) + M_PI / (num_atoms - 1));

					for (i = num_atoms; i > selected; i--)
						ring[i] = ring[i - 1];
					ring[selected] = 0;
				}

				next_atom = getNewAtom(num_atoms);

				/* code animation insert atom in ring 1097*/
				draw_all(num_atoms, next_atom, spacing);

				ring[selected] = (current_atom == LUXON)? PLUS_ATOM : current_atom;

				angle = M_TAU / num_atoms*(selected) + spacing;
				cosx = cos(angle); 
				siny = sin(angle);

				for (i = 0; i <= 90; i += 15) {
					gfx_SetColor(current_atom + 5);
					draw_atom(RING_X + i * cosx, 120 + i * siny, current_atom);
					gfx_SwapDraw();
					if (i > 0) {
						gfx_SetColor(0);
						gfx_FillCircle(RING_X + (i - 15) * cosx, 120 + (i - 15) * siny, 14);
					}
					if (i <= 42) {
						gfx_SetColor(next_atom + 5);
						draw_atom(RING_X, 120, next_atom);
					}
				}

				
				/* animation code end */
				gfx_BlitBuffer();
			}
			else if (current_atom == MINUS_ATOM) {/* current atom is a minus atom */
				next_atom = ring[selected];
				remove_atom(&num_atoms, selected, &spacing, 0);
				draw_all(num_atoms, next_atom, spacing);
				prev_was_minus = true;
				if (!selected)
					selected = num_atoms;
				selected--;
			}
			else if (current_atom == NEUTRINO) { /* current atom is a neutrino atom */
				next_atom = ring[selected];
			}

			/* checks the whole ring for Plus atoms */
			for (i = 0; i < num_atoms; i++) {
				if (ring[i] == PLUS_ATOM || ring[i] == BLACK_PLUS) {
					j = combine_atoms(&num_atoms, i, &spacing, next_atom);
					i -= j;
					selected = (num_atoms+selected-j)%num_atoms;
				}
			}

			moves++;
			current_atom = next_atom;
		}

		/* Pressed del key, so show reset menu */
		if (key == 0x38) {
			uint8_t choice = 0;
			
			gfx_SetDrawScreen();
			gfx_SetColor(0x27);
			gfx_SetTextFGColor(0x01);
			gfx_FillRectangle(61, 100, 118, 40);
			gfx_PrintStringXY("Start a New Game?", 61, 109);

			while (key != 0x09 && key != 0x36) {
				key = os_GetCSC();
				if (key == 0x03 || key == 0x02) { choice ^= 1; }
				gfx_SetTextFGColor(choice==0 ? 0x46 : 0x01);
				gfx_PrintStringXY("Yes", 125, 124);
				gfx_SetTextFGColor(choice==1 ? 0x46 : 0x01);
				gfx_PrintStringXY("No", 160, 124);
			}
			gfx_SetTextFGColor(0x01);
			if (!choice) { //You chose yes, so reset everything and that is easier if I return to the main menu.
				init_ring();
				return;
			}
			gfx_SetDrawBuffer();
			draw_all(num_atoms, current_atom, spacing);
		}

		/* This is for Time Attack */
		if (gamemode == TIME_ATTACK) {
			timer();
			gfx_BlitArea(gfx_buffer, 280, 116, 16, 8);
		}

		/* Gameover! */
		if (num_atoms >= 19 || seconds < 1) {
			while (num_atoms) {
				remove_atom(&num_atoms, rand() % num_atoms, &spacing, highest_atom);
				draw_all(num_atoms, highest_atom, spacing);
			}
			init_ring();
			return;
		}

	}
}

/* Does what is says it does, returns the amount of chain reactions */
uint8_t combine_atoms(uint8_t *num_atoms, uint8_t selected, double *spacing, uint8_t next_atom) {
	uint8_t* RingSelected = &ring[selected];
	uint8_t i, j;
	uint8_t chain = 1;
	double slice, angle, angle_mid;

	//For(i = 0; i < *num_atoms; i++) here, maybe.......?
	gfx_BlitBuffer();

	while (((ring[(*num_atoms + selected - chain) % *num_atoms] == ring[(selected + chain) % *num_atoms] && (*num_atoms - (chain - 1) * 2) != 2 && ring[(selected + chain) % *num_atoms] != PLUS_ATOM) || (*RingSelected == BLACK_PLUS)) && (*num_atoms - (chain - 1) * 2) > 1) {
		uint8_t* plus_pos = &ring[(selected + chain) % *num_atoms];
		uint8_t* min_pos = &ring[(*num_atoms + selected - chain) % *num_atoms];

		/*chain reaction animation variable intialization (OLD ONE(Newer one is faster(Why don't I remove this)))
		slice = M_TAU / *num_atoms;
		angle_mid = slice*((*num_atoms + selected - chain) % *num_atoms) + *spacing;
		angle_plus = slice*((selected + chain) % *num_atoms) + *spacing;

		// chain reaction animation drawing
		for (angle = 0; angle < slice*chain - slice / 6; angle += slice / 5) {
			gfx_SetColor(ring[(selected + chain) % *num_atoms] + 5);
			draw_atom(RING_X + 90 * cos(angle_mid + angle), 120 + 90 * sin(angle_mid + angle), ring[(selected + chain) % *num_atoms]);
			draw_atom(RING_X + 90 * cos(angle_plus - angle), 120 + 90 * sin(angle_plus - angle), ring[(selected + chain) % *num_atoms]);
			gfx_SwapDraw();
			gfx_SetColor(0x00);
			gfx_FillCircle(RING_X + 90 * cos(angle_mid + angle - ((angle == 0) ? 0 : slice / 5)), 120 + 90 * sin(angle_mid + angle - ((angle == 0) ? 0 : slice / 5)), 14);
			gfx_FillCircle(RING_X + 90 * cos(angle_plus - angle + ((angle == 0) ? 0 : slice / 5)), 120 + 90 * sin(angle_plus - angle + ((angle == 0) ? 0 : slice / 5)), 14);
		}*/

		slice = (M_TAU / (*num_atoms - (chain - 1) * 2)) / 5;
		angle_mid = (M_TAU / *num_atoms) * selected + *spacing;

		// chain reaction animation drawing 
		for (angle = (M_TAU / *num_atoms) * chain; angle > 0; angle -= slice) {
			gfx_SetColor(*plus_pos + 5);
			draw_atom(RING_X + 90 * cos(angle_mid + angle), 120 + 90 * sin(angle_mid + angle), *plus_pos);
			draw_atom(RING_X + 90 * cos(angle_mid - angle), 120 + 90 * sin(angle_mid - angle), *plus_pos);
			gfx_SwapDraw();
			gfx_SetColor(0x00);
			if (angle == (M_TAU / *num_atoms) * chain) slice = 0;
			gfx_FillCircle(RING_X + 90 * cos(angle_mid + angle + slice), 120 + 90 * sin(angle_mid + angle + slice), 14);
			gfx_FillCircle(RING_X + 90 * cos(angle_mid - angle - slice), 120 + 90 * sin(angle_mid - angle - slice), 14);
			if (slice == 0)slice = (M_TAU / *num_atoms) / 5;
		}

		/* calculates the value to add to the score */
		if ( chain == 1 ){
			score += 1.5*(*plus_pos < *min_pos ? *min_pos : *plus_pos) + 1.25; //This works for black plus and red plus, may be slower for red plus.
		}
		else {
			score += (-1 * *RingSelected + (*plus_pos < *RingSelected - 1 ? *RingSelected - 1 : *plus_pos) + 3) * (chain - 1) - *RingSelected + 3 * (*plus_pos < *RingSelected - 1 ? *RingSelected - 1 : *plus_pos) + 3;
		}

		/* Changes the atom value and deletes the combined atoms */
		*RingSelected = (*RingSelected > 125) ? 
							(*RingSelected == PLUS_ATOM ?
								*plus_pos + 1 : (*plus_pos < *min_pos ? 
									*min_pos + 3 : *plus_pos + 3)) : 
							(*plus_pos >= *RingSelected ?
								*plus_pos + 2 : *RingSelected + 1);
		*min_pos = 0;
		*plus_pos = 0;

		if(gamemode == TIME_ATTACK) //add seconds to time in time_attack
			seconds += chain + 1;
		
		chain++;

		/* Draws an slightly larger atom, this has to be replaced with a better algorithm later */
		gfx_SetColor(0);
		gfx_FillCircle(RING_X + 90 * cos(angle_mid), 120 + 90 * sin(angle_mid), 18);
		gfx_SetColor(*RingSelected + 5);
		draw_atom(RING_X + 90 * cos(angle_mid), 120 + 90 * sin(angle_mid), *RingSelected);

		gfx_SwapDraw();
		gfx_BlitBuffer();
	}

	/* This closes the loop of atoms again */
	*spacing += ((M_TAU / *num_atoms)*selected) - ((M_TAU / (*num_atoms - (chain - 1) * 2)))*((selected - (chain - 1) < 0) ? 0 : (selected + (chain - 1) >= *num_atoms) ? (*num_atoms - (chain - 1) * 2) - 1 : selected - (chain - 1));
	for ( i = 1; i < *num_atoms; i++ ) {
		for ( j = i; j && ring[j] && !ring[j - 1]; j-- ) {
			ring[j - 1] = ring[j];
			ring[j] = 0;
		}
	}
	*num_atoms -= (chain - 1) * 2;

	draw_all(*num_atoms, next_atom, *spacing);
	return chain-1;
}

/* This gives a new atom. This algorithm is based of Nextlight's Atomoos */
uint8_t getNewAtom(uint8_t num_atoms) {
	uint8_t atom = 0;
	uint24_t startRange = 1 + moves / 40;

	lastRedPlus *= 2;
	if (moves % 20 == 0) {
		atom = MINUS_ATOM;
	}
	else if ((rand()%33 < lastRedPlus) || (gamemode == ZEN && num_atoms == 18 && rand()%2)) {
		atom = (gamemode == GENEVA)? LUXON : PLUS_ATOM;
		lastRedPlus = 1;
	}
	else if (score > 750 && rand()%80 == 0) {
		atom = BLACK_PLUS;
	}
	else if (score > 1500 && rand()%60 == 0) {
		atom = NEUTRINO;
	}

	if (!atom) {
		uint8_t i;
		atom = startRange + rand()%4;
		for (i = 0; i < num_atoms; i++) if (ring[i]<126 && ring[i]>=atom && ring[i]<startRange)
			if (rand()%(num_atoms - 1) == 0) {
				atom = ring[i];
				break;
			}
	}

	return atom;
}

/* Draws everything to the buffer, then swaps the buffer with the screen and then copies the screen to the buffer. */
void draw_all(uint8_t num_atoms, uint8_t current_atom, double spacing) {
	gfx_FillScreen(0x00);
	draw_score();
	gfx_SetColor(current_atom + 5);
	gfx_Circle(RING_X, 120, 110);
	draw_atom(RING_X, 120, current_atom);
	draw_atom_ring(num_atoms, spacing);
	if (gamemode == TIME_ATTACK)
		timer();
	if (num_atoms >= 16) {
		uint8_t i;
		if (num_atoms == 16) {
			gfx_SetColor(70); //green
		}
		else if (num_atoms == 17) {
			gfx_SetColor(92); //orange
		}
		else gfx_SetColor(128); //red
		for (i = 0; i < 19 - num_atoms; i++) {
			gfx_FillCircle(239, 123 + i * 8 - (19-num_atoms)*4, 3);
		}
	}
	gfx_SwapDraw();
	gfx_BlitBuffer();
}

/* Draws all the atoms equally spaced in a circle */
void draw_atom_ring(uint8_t num_atoms, double spacing) {
	uint8_t *atom = &ring[0];
	double angle, theta = M_TAU/num_atoms;

	for (angle = spacing; angle < M_TAU + spacing; angle += theta) {
		gfx_SetColor(*atom + 5);
		draw_atom(RING_X + 90 * cos(angle), 120 + 90 * sin(angle), *atom);
		atom++;
	}
}

/* Draws the pointer */
void draw_pointer(uint8_t num_atoms, int8_t selected, double spacing, uint8_t current_atom) {
	/* Calculates the pointers position */
	double slice = M_TAU / num_atoms;
	double angle = slice * selected + spacing;
	if ( current_atom != MINUS_ATOM && current_atom != NEUTRINO && current_atom != LUXON)
		angle += slice / 2;
	/* Removes the old pointer */
	gfx_SetColor(0x00);
	gfx_FillCircle(RING_X, 120, 46);
	/* Draws the new pointer and the middle atom */
	gfx_SetColor(current_atom + 5);
	gfx_Line(RING_X, 120, RING_X + 45 * cos(angle), 120 + 45 * sin(angle));
	draw_atom(RING_X, 120, current_atom);

	gfx_SwapDraw();
}

/* Draws an atom */
void draw_atom(int16_t x, int16_t y, uint8_t num_atom) {
	if (num_atom) {
		gfx_FillCircle(x, y, 14); //_NoClip is faster I think, but that crashes your calculator.
		if (num_atom < 126) {
			char snum_atom[4];
			sprintf(snum_atom, "%d", num_atom);
			gfx_PrintStringXY(atom[num_atom-1], x - gfx_GetStringWidth(atom[num_atom-1]) / 2, y - 6);
			gfx_PrintStringXY(snum_atom, x - gfx_GetStringWidth(snum_atom) / 2, y + 4);
		}
		else if (num_atom == PLUS_ATOM || num_atom == BLACK_PLUS) {
			gfx_SetColor(0x01);
			gfx_FillRectangle(x - 3, y, 7, 1);
			gfx_FillRectangle(x, y - 3, 1, 7);
			//gfx_SetColor(131);
		}
		else if (num_atom == MINUS_ATOM) {
			gfx_SetColor(0x01);
			gfx_FillRectangle(x - 3, y, 7, 1);
			//gfx_SetColor(132);
		}
	}
}

/* Searches the ring for an higher atom than the current highest atom */
void get_highest_atom() {
	uint8_t i;
	for (i = 0; i < 19 && ring[i]; i++) {
		if (ring[i] > highest_atom && ring[i] < PLUS_ATOM) {
			highest_atom = ring[i];
		}
	}
}

/* Draws the scores */
void draw_score() {
	char sscore[8];
	sprintf(sscore, "%d", score);
	gfx_PrintStringXY(sscore, 280 - gfx_GetStringWidth(sscore)/2, 30);
	get_highest_atom();
	gfx_SetTextFGColor(highest_atom + 5);
	gfx_PrintStringXY(atom[highest_atom-1], 280 - gfx_GetStringWidth(atom[highest_atom-1]) / 2, 42);
	gfx_SetTextFGColor(0x01);
}

/* Removes one atom out of the ring */
void remove_atom(uint8_t *num_atoms, uint8_t selected, double *spacing, uint8_t middle_atom) {
	uint8_t i;
	double angle;

	draw_all(*num_atoms, middle_atom, *spacing);

	angle = M_TAU / *num_atoms * selected + *spacing;
	for (i = 90; i > 0; i -= 15) {
		gfx_SetColor(ring[selected] + 5);
		draw_atom(RING_X + i * cos(angle), 120 + i * sin(angle), ring[selected]);
		gfx_SwapDraw();
		gfx_SetColor(0);
		gfx_FillCircle(RING_X + (i + (i < 90 ? 15 : 0)) * cos(angle), 120 + (i + (i < 90 ? 15 : 0)) * sin(angle), 14);
	}

	--*num_atoms;
	*spacing += (M_TAU / (*num_atoms + 1))*selected - (M_TAU / *num_atoms * selected - M_PI / *num_atoms);
	for (i = selected; i < *num_atoms + 1; i++)ring[i] = ring[i + 1];
}

void init_ring() {
	uint8_t i;
	moves = 1;
	seconds = 10;
	score = 0; highest_atom = 0;
	memset(ring, 0, sizeof ring);
	for (i = 0; i < 6; i++) ring[i] = rand() % 3 + 1;
}

void timer() { //This is for TimeAttack

	if ( boot_GetTimersInterruptStatus() & TIMER1_RELOADED && seconds > 0) {
		seconds--;

		gfx_SetColor(0x00);
		gfx_FillRectangle(280, 116, 16, 8);
		
		/* Acknowledge the reload */
		boot_SetTimersInterruptStatus(TIMER1_RELOADED);
	}

	gfx_SetTextXY(280, 116);
	gfx_PrintUInt(seconds, 2);

}