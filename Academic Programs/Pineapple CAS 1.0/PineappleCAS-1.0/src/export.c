#include "parser.h"

/*I don't really like this dependency on cas.h but it only needs it for the absolute_val function
which could be easily copied here. */
#include "cas/cas.h"

#include <string.h>

#define add_byte(byte) do {if(data != NULL) data[index] = (byte); index++;} while(0)
#define add_token(token) do {uint8_t _tmp_i; for(_tmp_i = 0; _tmp_i < lookup[(token)].length; _tmp_i++) add_byte(lookup[token].bytes[_tmp_i]);} while(0)

static uint8_t precedence_type(OperatorType type) {
    switch(type) {
    case OP_ADD:
        return 5;
    case OP_MULT: case OP_DIV:
        return 10;
    case OP_POW: case OP_ROOT:
        return 15;
    default:
        return 20;
    }
}

static uint8_t precedence(pcas_ast_t *e) {
    if(e->type == NODE_OPERATOR)
        return precedence_type(optype(e));
    return 255;
}

#define is_right_operator_type(type) ((type) == OP_FACTORIAL)

#define need_paren(parent, child) ( (((parent)->type == NODE_OPERATOR && is_op_operator(optype(parent)) && !is_op_commutative(optype(parent)) && precedence(child) <= precedence(parent)) \
                                    || precedence(child) < precedence(parent)) \
                                    || (is_right_operator_type(optype(parent)) && (child)->type == NODE_NUMBER && mp_rat_compare_zero((child)->op.num) < 0) )

pcas_ast_t *rightmost(pcas_ast_t *e) {
    if(e->type == NODE_OPERATOR) {
        switch(optype(e)) {
        case OP_POW:
            return rightmost(ast_ChildGetLast(e));
        default:
            break;
        }
    }

    return e;
}
pcas_ast_t *leftmost(pcas_ast_t *e) {

    if(e->type == NODE_OPERATOR) {
        switch(optype(e)) {
        case OP_POW:
        case OP_ROOT:
            /*For the sqrt special case*/
            if(is_ast_int(ast_ChildGet(e, 0), 2))
                return e;
            /*FALLTHROUGH*/
        case OP_LOG:
        case OP_FACTORIAL:
            return leftmost(opbase(e));
        default:
            break;
        }
    }

    return e;
}

/*Returns length of buffer. Writes to buffer is buffer != NULL*/
static unsigned _to_binary(pcas_ast_t *e, uint8_t *data, unsigned index, struct Identifier *lookup, pcas_error_t *err) {

    switch(e->type) {
    case NODE_NUMBER: {
        char *buffer;
        unsigned i;

        buffer = num_ToString(e->op.num, 6);

        for(i = 0; i < strlen(buffer); i++) {
            uint8_t c = (uint8_t)buffer[i];
            if(c == '.')
                c = lookup[TOK_PERIOD].bytes[0];
            else if(c == '-')
                c = lookup[TOK_NEGATE].bytes[0];
            add_byte(c);
        }

        free(buffer);
        break;
    } case NODE_SYMBOL:

        switch(e->op.symbol) {
        case SYM_IMAG:  add_token(TOK_IMAG);     break;
        case SYM_PI:    add_token(TOK_PI);       break;
        case SYM_EULER: add_token(TOK_EULER);    break;
        case SYM_THETA: add_token(TOK_THETA);    break;
        default:        add_byte(e->op.symbol);  break;
        }

        break;
    case NODE_OPERATOR: {
        unsigned i;

        switch(optype(e)) {
        case OP_ADD: {
            pcas_ast_t *child;
            pcas_ast_t *e_copy = ast_Copy(e);

            for(i = 0; i < ast_ChildLength(e_copy) - 1; i++) {
                pcas_ast_t *next;

                child = ast_ChildGet(e_copy, i);
                next = child->next;

                if(need_paren(e_copy, child)) add_token(TOK_OPEN_PAR);
                index = _to_binary(child, data, index, lookup, err);
                if(need_paren(e_copy, child)) add_token(TOK_CLOSE_PAR);

                if(absolute_val(next))
                    add_token(TOK_MINUS);
                else
                    add_token(TOK_PLUS);
            }

            child = ast_ChildGetLast(e_copy);

            if(need_paren(e_copy, child)) add_token(TOK_OPEN_PAR);
            index = _to_binary(child, data, index, lookup, err);
            if(need_paren(e_copy, child)) add_token(TOK_CLOSE_PAR);

            ast_Cleanup(e_copy);

            break;
        }
        case OP_MULT: {
            pcas_ast_t *child;
            bool needs_mult;
            bool root_special_case;

            for(i = 0; i < ast_ChildLength(e) - 1; i++) {
                pcas_ast_t *next;

                child = ast_ChildGet(e, i);
                next = child->next;

                /*Always put parentheses around root operator unless it is sqrt(
                For example, -1 * 3root2 should be -(3root2) */
                root_special_case = isoptype(child, OP_ROOT) && !is_ast_int(ast_ChildGet(child, 0), 2);

                if(is_ast_int(child, -1)) {
                    add_token(TOK_NEGATE);
                } else if(is_ast_int(child, 1)) {
                    /*You'd think this would be fixed by the simplifier, but
                    the problem is reintroduced when we abs(-1) during addition exporting*/
                    continue;
                } else {
                    /*For example, */
                    if(need_paren(e, child) || root_special_case) add_token(TOK_OPEN_PAR);
                    index = _to_binary(child, data, index, lookup, err);
                    if(need_paren(e, child) || root_special_case) add_token(TOK_CLOSE_PAR);
                }

                needs_mult = !need_paren(e, child) && !root_special_case &&
                        ((rightmost(child)->type == NODE_NUMBER && !is_ast_int(rightmost(child), -1) && leftmost(next)->type == NODE_NUMBER)
                        /*Should never happen, because the tree should have been flattened. This is just in case*/
                        || isoptype(child, OP_MULT));

                if(needs_mult && !isoptype(next, OP_ROOT))
                    add_token(TOK_MULTIPLY);

            }

            child = ast_ChildGetLast(e);
            root_special_case = isoptype(child, OP_ROOT) && !is_ast_int(ast_ChildGet(child, 0), 2);

            if(!is_ast_int(child, 1)) {
                if(need_paren(e, child) || root_special_case) add_token(TOK_OPEN_PAR);
                index = _to_binary(child, data, index, lookup, err);
                if(need_paren(e, child) || root_special_case) add_token(TOK_CLOSE_PAR);
            }

            break;
        } case OP_DIV:
          case OP_POW: {
            pcas_ast_t *a, *b;

            a = ast_ChildGet(e, 0);
            b = ast_ChildGet(e, 1);

            if(need_paren(e, a)) add_token(TOK_OPEN_PAR);
            index = _to_binary(a, data, index, lookup, err);
            if(need_paren(e, a)) add_token(TOK_CLOSE_PAR);

            add_token(optype(e) == OP_DIV ? TOK_FRACTION : TOK_POWER);

            if((optype(e) == OP_POW && b->type != NODE_NUMBER && b->type != NODE_SYMBOL) || need_paren(e, b)) add_token(TOK_OPEN_PAR);
            index = _to_binary(b, data, index, lookup, err);
            if((optype(e) == OP_POW && b->type != NODE_NUMBER && b->type != NODE_SYMBOL) || need_paren(e, b)) add_token(TOK_CLOSE_PAR);

            break;
        } case OP_ROOT: {
            pcas_ast_t *a, *b;

            a = ast_ChildGet(e, 0);
            b = ast_ChildGet(e, 1);

            if(is_ast_int(a, 2)) {
                add_token(TOK_SQRT);

                if(need_paren(e, b)) add_token(TOK_OPEN_PAR);
                index = _to_binary(b, data, index, lookup, err);
                if(need_paren(e, b)) add_token(TOK_CLOSE_PAR);

                add_token(TOK_CLOSE_PAR);
            } else {
                if(need_paren(e, a)) add_token(TOK_OPEN_PAR);
                index = _to_binary(a, data, index, lookup, err);
                if(need_paren(e, a)) add_token(TOK_CLOSE_PAR);

                add_token(TOK_ROOT);

                if(need_paren(e, b)) add_token(TOK_OPEN_PAR);
                index = _to_binary(b, data, index, lookup, err);
                if(need_paren(e, b)) add_token(TOK_CLOSE_PAR);
            }

            break;
        }
        case OP_LOG: {
            pcas_ast_t *a, *b;

            a = ast_ChildGet(e, 0);
            b = ast_ChildGet(e, 1);

            if(a->type == NODE_SYMBOL && a->op.symbol == SYM_EULER) {
                add_token(TOK_LN);
                index = _to_binary(b, data, index, lookup, err);
                add_token(TOK_CLOSE_PAR);
                break;
            } else if(a->type == NODE_NUMBER && mp_rat_compare_value(a->op.num, 10, 1) == 0) {
                add_token(TOK_LOG);
                index = _to_binary(b, data, index, lookup, err);
                add_token(TOK_CLOSE_PAR);
                break;
            }

            add_token(TOK_LOG_BASE);
            index = _to_binary(b, data, index, lookup, err);
            add_token(TOK_COMMA);
            index = _to_binary(a, data, index, lookup, err);
            add_token(TOK_CLOSE_PAR);

            break;
        }  case OP_DERIV: {
            pcas_ast_t *a, *b, *c;

            a = ast_ChildGet(e, 0);
            b = ast_ChildGet(e, 1);
            c = ast_ChildGet(e, 2);

            add_token(TOK_DERIV);
            index = _to_binary(a, data, index, lookup, err);
            add_token(TOK_COMMA);
            index = _to_binary(b, data, index, lookup, err);
            add_token(TOK_COMMA);
            index = _to_binary(c, data, index, lookup, err);
            add_token(TOK_CLOSE_PAR);

            break;
        } case OP_FACTORIAL: {

            pcas_ast_t *a;

            a = ast_ChildGet(e, 0);

            if(need_paren(e, a)) add_token(TOK_OPEN_PAR);
            index = _to_binary(a, data, index, lookup, err);
            if(need_paren(e, a)) add_token(TOK_CLOSE_PAR);

            add_token(TOK_FACTORIAL);

            break;
        } default:

            switch(optype(e)) {
                case OP_INT:        add_token(TOK_INT);      break;
                case OP_ABS:        add_token(TOK_ABS);      break;
                case OP_SIN:        add_token(TOK_SIN);      break;
                case OP_SIN_INV:    add_token(TOK_SIN_INV);  break;
                case OP_COS:        add_token(TOK_COS);      break;
                case OP_COS_INV:    add_token(TOK_COS_INV);  break;
                case OP_TAN:        add_token(TOK_TAN);      break;
                case OP_TAN_INV:    add_token(TOK_TAN_INV);  break;
                case OP_SINH:       add_token(TOK_SINH);     break;
                case OP_SINH_INV:   add_token(TOK_SINH_INV); break;
                case OP_COSH:       add_token(TOK_COSH);     break;
                case OP_COSH_INV:   add_token(TOK_COSH_INV); break;
                case OP_TANH:       add_token(TOK_TANH);     break;
                case OP_TANH_INV:   add_token(TOK_TANH_INV); break;
                default: break;
            }

            index = _to_binary(ast_ChildGet(e, 0), data, index, lookup, err);
            add_token(TOK_CLOSE_PAR);
            break;
        }

        break;
    }
    }

    return index;
}

uint8_t *export_to_binary(pcas_ast_t *e, unsigned *len, struct Identifier *lookup, pcas_error_t *err) {
    uint8_t *data;

    *err = E_SUCCESS;

    *len = _to_binary(e, NULL, 0, lookup, err);

    if(*err != E_SUCCESS) {
        *len = 0;
        return NULL;
    }

    data = malloc(*len);
    _to_binary(e, data, 0, lookup, err);

    return data;
}
