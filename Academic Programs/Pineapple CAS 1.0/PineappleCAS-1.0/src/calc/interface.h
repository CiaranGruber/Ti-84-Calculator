#ifndef COMPILE_PC

#ifndef INTERFACE_H_
#define INTERFACE_H_

#include <stdbool.h>

#include <tice.h>
#include <fileioc.h>

#include "../ast.h"

/*Checks if Ans is trying to call a function of PCAS*/
bool interface_Valid();
/*Run function specified by Ans variable without gui*/
void interface_Run();

/*Helper functions*/
pcas_ast_t *parse_from_tok(uint8_t *tok, pcas_error_t *err);
void write_to_tok(uint8_t *tok, pcas_ast_t *expression, pcas_error_t *err);
/*Expects var to be properly opened*/
bool is_var_string_type(ti_var_t var);

#endif

#endif