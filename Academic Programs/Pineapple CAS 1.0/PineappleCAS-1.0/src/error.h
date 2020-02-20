#ifndef ERROR_H_
#define ERROR_H_

typedef enum {
    E_SUCCESS,

    /*Because of bad programming*/
    E_GENERIC,

    /*trying to add nodes to a NODE_NUMBER for instance*/
    E_AST_NOT_ALLOWED,
    E_AST_OUT_OF_BOUNDS,

    /*Tokenizing and parsing*/
    E_TOK_INVALID,

    E_PARSE_BAD_OPERATOR,
    E_PARSE_UNMATCHED_CLOSE_PAR,
    E_PARSE_BAD_COMMA,

    E_EVAL_NO_MAPPING,

    AMOUNT_ERRORS
} pcas_error_t;

extern const char *error_text[AMOUNT_ERRORS];

#endif