#ifndef H_COMMANDS
#define H_COMMANDS

#include <intce.h>

enum CommandTypes {
	HANDSHAKE,
	RESPONSE,
	MOVE_CURSOR,
	REMOVE_PAIR,
	UNDO,
	SEND_TILES,
	START_GAME,
	SEND_SCORE
};

typedef struct Command {
	char type;
	uint24_t length;
	uint8_t data[1];
} command_t;

#endif