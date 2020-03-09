;############## CMonster by Patrick Davidson (data structures)

#define rs(size) =rscount \ #define rscount eval(rscount + size)

;############## High score storage definitions

SCORELEN        =6
NAME_LEN        =26
SCORE_COUNT     =12
ENTRYLEN        =SCORELEN + NAME_LEN + 1
TABLE_SIZE      =ENTRYLEN * SCORE_COUNT
     
#ifdef  TI84CE
high_scores     =saveSScreen+21945-TABLE_SIZE     
#else
high_scores     =plotSScreen
#endif
high_scores_end =high_scores + TABLE_SIZE
last_score      =high_scores_end - ENTRYLEN

;############## Ball data structures for objects in arrays

#define rscount 0
ball_type       rs(     1)      ; player bullet structure
ball_x          rs(     1)
ball_y          rs(     1)
ball_dir        rs(     1)
ball_xfrac      rs(     1)
ball_yfrac      rs(     1)
ball_size       rs(     0)
ball_count      =3

;############## Allocation of storage within saveSScreen

#ifdef  TI84CE
#define rscount $D10000          ; inside saveSScreen
#define datamax high_scores
#else
#define rscount saveSScreen
#define datamax saveSScreen+768
#endif

saved_flag      rs(     1)
data_start      rs(     0)
delay_amount    rs(     1)      
bounce_count    rs(     1)
expanded_flag   rs(     1)
p_x             rs(     1)
bonus_type      rs(     1)
bonus_x         rs(     1)
bonus_y         rs(     1)
plimit          rs(     1)
balls           rs(     ball_size*ball_count)
map             rs(     320)
rand_inc        rs(     1)
rand_counter    rs(     1)
score_inc       rs(     1)
lives           rs(     1)
level           rs(     1)
hit_corner      rs(     1)
score           rs(     7)
map_name        rs(     8)
hard_flag       rs(     1)
data_end        rs(     0)
wait_count      rs(     WORDLEN)
brick_count     rs(     WORDLEN)
since_bounce    rs(     1)
levels_pointer  rs(     3)
level_count     rs(     1)
already_count   rs(     1)
already_hit     rs(     ball_count*4*5*WORDLEN)
title_count     rs(     3)
all_data_end    rs(     0)

;############## Temporary variables used in external level search

search_pos      rs(     WORDLEN)
search_name     rs(     9)
search_ptr      rs(     3)
search_size     rs(     1)
search_test     rs(     10)
search_end      rs(     0)
getkeylastdata  rs(     7)

#define extlev_cursor_x balls
#define extlev_cursor_y balls+1
#define extlev_limit_x  balls+3
#define extlev_limit_y  balls+4

#define MAX_EXTLEV_X    3
#define COLUMN_WIDTH    41
#define MAX_EXTLEV_Y    27

#ifndef TI84CSE_LOADER
#if     rscount > datamax
        .echo   "Overflow of available variable space by ",eval(rscount - datamax)
        .error  "!!!!!!!!!!!!!!!!!!!! DISASTER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#endif
#else
        .echo   "Remaining bytes for variables: ",eval(datamax - rscount)
#endif

#define WAIT_RESET      $e000   