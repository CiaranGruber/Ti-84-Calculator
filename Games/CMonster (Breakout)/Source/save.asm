;############## CMonster by Patrick Davidson

;############## Read in the save game and erase it, sets carry if not found

Read_Files:
        ld      hl,saved_flag                    ; clear data
        ld      (hl),0
        ld      de,saved_flag+1
        ld      bc,data_end-data_start
        ldir
        
        ld      hl,save_name
        bcall(_Mov9ToOP1)                       ; copy (HL) to OP1
        bcall(_ChkFindSym)                   
        jr      c,read_scores 
#ifdef  TI84CE
        bcall(_ChkInRam)
#else
        ld      a,b
        or      a
#endif
        jr      z,its_not_archived_so_dont_unarchive_it   
        bcall(_Arc_Unarc)
        ld      hl,save_name
        bcall(_Mov9ToOP1)                       ; copy (HL) to OP1
        bcall(_ChkFindSym)
its_not_archived_so_dont_unarchive_it:
        
        ld      hl,save_identifier
        ld      b,8
        inc     de
        inc     de
compare_identifier:
        ld      a,(de)
        cp      (hl)
        jr      nz,erase_save_file
        inc     hl
        inc     de
        djnz    compare_identifier
        ld      (saved_flag),a
        ex      de,hl
        ld      de,saved_flag+1
        ld      bc,data_end-data_start
        ldir            
        
erase_save_file:
        bcall(_ChkFindSym) 
        bcall(_DelVarArc)      

read_scores:
        ld      de,high_scores
        ld      a,SCORE_COUNT
build_default_loop:
        ld      hl,default_high_score
        ld      bc,ENTRYLEN
        ldir
        dec     a
        jr      nz,build_default_loop    

        ld      b,SCORE_COUNT-1
        ld      de,high_scores+TABLE_SIZE-ENTRYLEN-SCORELEN-1
default_inc_loop:
        push    bc
        ld      hl,ENTRYLEN
        add     hl,de                           ; HL -> next score
        ld      bc,6
        ldir                                    ; copy next score over this one
        ex      de,hl
        call    Add_6_Digits_BCD                ; double it (moves pointer back)
        ld      de,-ENTRYLEN
        add     hl,de
        ex      de,hl
        pop     bc
        djnz    default_inc_loop

        ld      hl,score_name
        bcall(_Mov9ToOP1)                       ; copy (HL) to OP1
        bcall(_ChkFindSym)     
        ret     c
#ifdef  TI84CE
        bcall(_ChkInRam)
#else
        ld      a,b
        or      a
#endif
        jr      z,scores_not_archived_so_dont_unarchive_it
        bcall(_Arc_Unarc)
        ld      hl,score_name
        bcall(_Mov9ToOP1)                       ; copy (HL) to OP1
        bcall(_ChkFindSym)
scores_not_archived_so_dont_unarchive_it:
        ex      de,hl
        inc     hl
        inc     hl
        
        ld      a,SCORE_COUNT
        ld      de,high_scores
read_scores_from_file_loop:
        ld      bc,ENTRYLEN-1
        ldir
        inc     de
        dec     a
        jr      nz,read_scores_from_file_loop
        ret
        
save_name:
        .db     AppVarObj,"CMonSave",0
save_identifier:
        .db     "CMON",5,26,82,7
score_name:
        .db     AppVarObj,"CMonHigh",0
        
default_high_score:
        .db     "PATRICK ANDREW DAVIDSON   000001",0
        
;############## Write out the save game file
        
Write_Files:
        ld      a,(saved_flag)
        add     a,a
        jr      nc,not_saving_game
        ld      hl,save_name
        bcall(_Mov9ToOP1)                       ; copy (HL) to OP1
        ld      hl,8+data_end-data_start
        bcall(_CreateAppVar)    
        ld      hl,save_identifier
        inc     de
        inc     de
        ld      bc,8
        ldir
        ld      hl,saved_flag+1
        ld      bc,data_end-data_start
        ldir
        ret
        
not_saving_game:
        ld      a,(saved_flag)
        rra
        rra
        ret     nc
        
        ld      hl,score_name
        bcall(_Mov9ToOP1)                       ; copy (HL) to OP1
        bcall(_ChkFindSym) 
        jr      c,it_doesnt_exist_so_dont_delete_it
        bcall(_DelVarArc)  
it_doesnt_exist_so_dont_delete_it:
        ld      hl,TABLE_SIZE-SCORE_COUNT
        bcall(_CreateAppVar)
        
        ld      a,SCORE_COUNT
        ld      hl,high_scores
        inc     de
        inc     de
write_score_file_loop:
        ld      bc,ENTRYLEN-1
        ldir
        inc     hl
        dec     a
        jr      nz,write_score_file_loop
        ret