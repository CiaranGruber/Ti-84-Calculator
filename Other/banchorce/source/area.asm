;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Area Name Routines                                            ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; showAreaName - Show the current area name
;
; Input:    None
; Output:   None
;------------------------------------------------
showAreaName:
        ld      hl,graymem1+(28*16)
        ld      b,16*7
        call    _ld_hl_bz
        ld      hl,graymem2+(28*16)
        ld      b,16*7
        call    _ld_hl_bz
        
        ld      hl,graymem1
        ld      (__psLoc),hl

        ld      de,28*256+1
        ld      hl,strEntering                  ; HL => String
        call    putString                       ; Write "ENTERING "
        push    de
        ld      hl,(areaNum)                    ; L = Area number
        dec     l
        ld      h,3
        mlt     hl                              ; HL = Offset in areaNames
        ld      de,areaNames
        add     hl,de                           ; HL => Pointer to area name string
        ld      de,(hl)
        ex      de,hl                           ; HL => Area name string
        pop     de
        call    putString                       ; Write area name

        ld      hl,buffer1
        ld      (__psLoc),hl
        
        call    showGray
        ld      bc,AREA_WAIT
        jp      waitBC                          ; Wait a bit

.end
