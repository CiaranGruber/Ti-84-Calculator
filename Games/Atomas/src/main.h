#ifndef MAIN_H
#define MAIN_H
#include <stdint.h>

#define M_TAU 2*M_PI 
#define RING_X 120

#define PLUS_ATOM	126
#define MINUS_ATOM	127
#define BLACK_PLUS	128
#define NEUTRINO	129
#define	ANTIMATTER	130 //Not in the game.
#define LUXON		131 //part of geneva mode

#define CLASSIC 0
#define TIME_ATTACK 1
#define ZEN 2
#define GENEVA 3

/* all the functions */
void game_loop();
void init_ring();
void draw_score();
uint8_t getNewAtom(uint8_t num_atoms);
void draw_atom_ring(uint8_t num_atoms, double spacing);
void draw_atom(int16_t x, int16_t y, uint8_t num_atom);
void draw_all(uint8_t num_atoms, uint8_t current_atom, double spacing);
void draw_pointer(uint8_t num_atoms, int8_t n, double spacing, uint8_t current_atom);
void remove_atom(uint8_t *num_atoms, uint8_t selected, double *spacing, uint8_t middle_atom);
uint8_t combine_atoms(uint8_t *num_atoms, uint8_t selected, double *spacing, uint8_t next_atom);

void timer();

/*void insert_atom(uint8_t *num_atoms, uint8_t selected, double *spacing, uint8_t middle_atom);*/

/* all the atoms */
const char *atom[125] = {
	"H",
	"He",
	"Li",
	"Be",
	"B",
	"C",
	"N",
	"O",
	"F",
	"Ne",
	"Na",
	"Mg",
	"Al",
	"Si",
	"P",
	"S",
	"Cl",
	"Ar",
	"K",
	"Ca",
	"Sc",
	"Ti",
	"V",
	"Cr",
	"Mn",
	"Fe",
	"Co",
	"Ni",
	"Cu",
	"Zn",
	"Ga",
	"Ge",
	"As",
	"Se",
	"Br",
	"Kr",
	"Rb",
	"Sr",
	"Y",
	"Zr",
	"Nb",
	"Mo",
	"Tc",
	"Ru",
	"Rh",
	"Pd",
	"Ag",
	"Cd",
	"In",
	"Sn",
	"Sb",
	"Te",
	"I",
	"Xe",
	"Cs",
	"Ba",
	"La",
	"Ce",
	"Pr",
	"Nd",
	"Pm",
	"Sm",
	"Eu",
	"Gd",
	"Tb",
	"Dy",
	"Ho",
	"Er",
	"Tm",
	"Yb",
	"Lu",
	"Hf",
	"Ta",
	"W",
	"Re",
	"Os",
	"Ir",
	"Pt",
	"Au",
	"Hg",
	"Tl",
	"Pb",
	"Bi",
	"Po",
	"At",
	"Rn",
	"Fr",
	"Ra",
	"Ac",
	"Th",
	"Pa",
	"U",
	"Np",
	"Pu",
	"Am",
	"Cm",
	"Bk",
	"Cf",
	"Es",
	"Fm",
	"Md",
	"No",
	"Lr",
	"Rf",
	"Db",
	"Sg",
	"Bh",
	"Hs",
	"Mt",
	"Ds",
	"Rg",
	"Cn",
	"Uut",
	"Fl",
	"Uup",
	"Lv",
	"Uus",
	"Uuo",
	"Bn",
	"Gb",
	"Bb",
	"Tr",
	"Sir",
	"Ea",
	"Ubp"
};

/* all the colors */
uint16_t colors_pal[137] = {
	0x3086,	//00 :: bg color (0x24a5(old))
	0x7fff,	//01 :: white
	0x0000,	//02
	0x0000,	//03
	0x0000,	//04
	0x0000,	//05
			//atom colors
	0x32fa, //Hydrogen
	0x6b32, //Helium
	0x258d, //Lithium
	0x6739, //Beryllium
	0x3d4a, //Boron
	0x1ce7, //Carbon
	0x1716, //Nitrogen
	0x37b3, //Oxygen
	0x770d, //Fluorine
	0x5c10, //Neon
	0x726f, //Sodium
	0x4e1d, //Magnesium
	0x3def, //Aluminum
	0x250e, //Silicon
	0x6907, //Phosphorus
	0x196f, //Sulfur
	0x346f, //Chlorine
	0x4cf4, //Argon
	0x2628, //Potassium
	0x6f7b, //Calcium
	0x2eee, //Scandium
	0x2d6b, //Titanium
	0x2e77, //Vanadium
	0x5236, //Chromium
	0x6d29, //Manganese
	0x564f, //Iron
	0x21dc, //Cobalt
	0x5f12, //Nickel
	0x5d47, //Copper
	0x5ad6, //Zinc
	0x1eee, //Gallium
	0x4a4e, //Germanium
	0x3a13, //Arsenic
	0x2108, //Selenium
	0x69c7, //Bromine
	0x1e9a, //Krypton
	0x68a3, //Rubidium
	0x7e65, //Strontium
	0x58bf, //Yttrium
	0x6b87, //Zirconium
	0x3b7d, //Niobium
	0x4691, //Molybdenum
	0x769c, //Technetium
	0x28e6, //Ruthenium
	0x474f, //Rhodium
	0x4eb7, //Palladium
	0x6f7b, //Silver
	0x2999, //Cadmium
	0x2227, //Indium
	0x5a8f, //Tin
	0x6171, //Antimony
	0x41d3, //Tellurium
	0x7c1f, //Iodine
	0x3e3f, //Xenon
	0x7f4f, //Caesium
	0x7673, //Barium
	0x4777, //Lanthanum
	0x7e45, //Cerium
	0x2b83, //Praseodymium
	0x3231, //Neodymium
	0x17b3, //Promethium
	0x5d8e, //Samarium
	0x3597, //Europium
	0x3451, //Gadolinium
	0x1a6a, //Terbium
	0x21fc, //Dysprosium
	0x71e8, //Holmium
	0x5d30, //Erbium
	0x110d, //Thulium
	0x420a, //Ytterbium
	0x68a5, //Lutetium
	0x4b45, //Hafnium
	0x3e15, //Tantalum
	0x15b4, //Tungsten
	0x28a5, //Rhenium
	0x19cc, //Osmium
	0x660d, //Iridium
	0x2941, //Platinum
	0x770e, //Gold
	0x4295, //Mercury
	0x5611, //Thallium
	0x1dec, //Lead
	0x7c00, //Bismuth
	0x7fe0, //Polonium
	0x03e0,  //Astatine
	0x6fa7, //Radon
	0x7da0, //Francium
	0x03ff,  //Radium
	0x2123, //Actinium
	0x54f0, //Thorium
	0x1eb0, //Protactinium
	0x4fe0, //Uranium
	0x02bf,  //Neptunium
	0x7e40, //Plutonium
	0x40c9, //Americium
	0x7dfa, //Curium
	0x560f, //Berkelium
	0x44f6, //Californium
	0x431b, //Einsteinium
	0x5f70, //Fermium
	0x6e10, //Mendelevium
	0x7f6c, //Nobelium
	0x2c94, //Lawrencium
	0x358e, //Rutherfordium
	0x5946, //Dubnium
	0x1130, //Seaborgium
	0x4eb4, //Bohrium
	0x7d45, //Hassium
	0x6725, //Meitnerium
	0x1de9, //Darmstadtium
	0x0ddd,  //Roentgenium
	0x5512, //Copernicium
	0x4631, //Ununtrium
	0x17bc, //Flerovium
	0x5eac, //Ununpentium
	0x78ad, //Livermorium
	0x3baf, //Ununseptium
	0x7c17, //Ununoctium
	0x778e, //Bananium
	0x1f98, //GravityBlockium
	0x1a48, //BreakingBadium
	0x273c, //TimeRunnerium
	0x7c00, //Sirnicanium
	0x09de, //Earthium
	0x0000, //Unknown
	0x5ce7,	//Plus
	0x1db5, //Minus
	0x0000, //Black Plus
	0x7fff, //Neutrino
	0x0000, //
	0x1acd	//Luxon
};

#endif
