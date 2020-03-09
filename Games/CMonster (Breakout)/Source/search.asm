;############## CMonster by Patrick Davidson - external level variable access    

;############## Read in external level data
;
; HL = offset into the level data (level * 320)

Read_Ext_Level:
        ld      de,10
        add     hl,de           ; add 10 to skip level header
        ld      de,(levels_pointer)
        
#ifdef  TI84CE
        add     hl,de
        ld      de,map
        ld      bc,320
        ldir
        ret
#else
        in      a,(5)
        or      a
        ld      bc,(levels_pointer+2)   ; C = bank number
        jr      z,read_main
        
        xor     a               ; restore normal RAM at $C000
        out     (5),a   
        ld      a,$81           ; restore normal RAM at $8000
        out     (7),a   
        
        call    read_main
        
        ld      a,7             ; set our first data page at $C000
        out     (5),a
        ld      hl,map          ; copy the results
        ld      de,map+$4000
        ld      bc,320
        ldir
        ld      a,6             ; set our data page at $C000
        out     (5),a
        ld      a,$87           ; set our data page at $8000
        out     (7),a
        ret       
        
read_main:                      ; C = page, DE = file start, HL = offset
        ld      a,c
        or      a
        jr      nz,read_levels_from_flash
        add     hl,de
        ld      de,map
        ld      bc,320
        ldir
        ret
        
read_levels_from_flash:
        add     hl,de 
        ld      de,map
        ld      bc,320
        jr      c,overflow_address
        bit     7,h
        jr      z,no_next_page
        res     7,h
        inc     a
        bit     6,h
        set     6,h
        jr      z,no_next_page
        inc     a
no_next_page:
        bcall(_FlashToRam)
        ret

overflow_address:
        add     a,4
        bit     6,h
        jr      nz,no_next_page
        dec     a
        set     6,h
        jr      no_next_page
#endif

;############## Search for and return the next valid level
;
; if C = 0, searches from beginning
; if C = 1, searches from last position
; zero flag set if not found, clear if found
; if found, results in search_name, search_size, search_ptr

Search_Levels:   
#ifndef TI84CE
        in      a,(5)
        or      a
        jr      z,main_search
        xor     a               ; restore usual RAM at $C000
        out     (5),a   
        ld      a,$81           ; restore usual RAM at $8000
        out     (7),a  
        
        call    main_search

        ld      a,7             ; set our first data page at $C000
        out     (5),a    
        ld      de,search_pos+$4000  
        ld      hl,search_pos   ; copy the search results
        ld      bc,search_end-search_pos
        ldir
        ld      a,6             ; set our data page at $C000
        out     (5),a
        ld      a,$87           ; set our data page at $8000
        out     (7),a
        ret
#endif
        
main_search:
        ld      hl,(search_pos)
        dec     c
        jr      z,search_loop
        ld      hl,(progptr)    ; start of variable section to search

;############## Main search loop (HL -> first VAT entry to search)

search_loop:        
        ld      de,(ptemp)
        bcall(_cpHLDE)
        ld      (search_pos),hl
        ret     z
        ld      a,(hl)          ; level file must be appvar, ignore others 
        cp      AppVarObj    
        jr      z,found_appvar   
        
search_not_found:        
        ld      de,-6
        add     hl,de           ; HL -> variable name length byte   
        ld      a,(hl)
        neg
        ld      e,a
        add     hl,de           ; HL -> first byte of name
        dec     hl              ; HL -> next VAT entry
        jr      search_loop
        
;############## Check if the appvar is valid (HL -> last byte of VAT entry)
   
found_appvar:        
        push    hl
        dec     hl
        dec     hl      ; HL -> 1 byte before address
        ld      b,3
        ld      de,search_ptr
loop_copy_address:
        dec     hl
        ld      a,(hl)
        ld      (de),a
        inc     de
        djnz    loop_copy_address
        
;############## Copy first 10 bytes of variable into out temporary space
        
#ifdef  TI84CE
        ld      a,(search_ptr+2)
        ld      hl,(search_ptr)
        add     a,a
        jr      c,copy10_not_flash              
        ld      de,9
        add     hl,de                           ; DE -> flash header name size
        ld      a,(hl)
        inc     a                               ; skip name size + 1 (length byte)
        ld      e,a
        add     hl,de                           
        ld      (search_ptr),hl                 ; save actual variable start
copy10_not_flash:
        ld      de,search_test
        ld      bc,10
        ldir
#else
        ld      a,(search_ptr+2)
        ld      hl,(search_ptr)
        ld      bc,10
        ld      de,search_test
        or      a
        jr      z,copy10_in_ram
        bcall(_FlashToRam)                      ; copies the special flash header
        ld      bc,(search_test+9)
        ld      b,0
        bcall(_FlashToRam)                      ; copies the name
        ld      (search_ptr+2),a                ; copies the advanced pointer
        ld      (search_ptr),hl
        ld      c,11
        ld      de,search_test
        bcall(_FlashToRam)
        jr      copy10_done
copy10_in_ram:
        ldir
copy10_done:
#endif
        
;############## Calculate number of levels
        
        ld      hl,level_identifier
        ld      de,search_test+2
        ld      b,8
loop_check_level:
        ld      a,(de)
        cp      (hl)
        jr      nz,invalid_appvar
        inc     hl
        inc     de
        djnz    loop_check_level

        ld      hl,8                            ; HL = initial size (header)
#ifdef  TI84CE
        xor     a
        ld      (search_test+2),a
#endif
        ld      de,(search_test)                ; DE = length of variable
        ld      bc,320                          ; size per level
        xor     a
loop_count_level:
        inc     a
        add     hl,bc
        bcall(_cpHLDE)
        jr      z,found_size
        cp      205                             ; 204 is largest valid length
        jr      nz,loop_count_level
invalid_appvar:
        pop     hl
        jr      search_not_found
        
found_size:
        ld      (search_size),a
          
        pop     hl

;############## Copy name followed by zeros
        
        ld      de,-6
        add     hl,de
        ld      b,(hl)        
        ld      de,search_name
        dec     hl
search_copy_name:
        ld      a,(hl)
        ld      (de),a
        inc     de
        dec     hl
        djnz    search_copy_name
        
        push    hl        
        ld      hl,search_name+8
        xor     a
search_clear_after:
        ld      (de),a
        bcall(_cpHLDE)
        inc     de
        jr      nz,search_clear_after
        pop     hl
       
        ld      (search_pos),hl
        inc     a               ; clear zero flag
        ret
        
level_identifier:
        .db     "CMonLvls"