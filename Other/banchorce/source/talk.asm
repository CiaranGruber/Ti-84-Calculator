;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Talking Routines                                              ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; checkPeople - Check to see if player can talk to a person
;
; Input:    None
; Output:   None
;------------------------------------------------
checkPeople:
        ld      a,(playerDir)
        or      a
        ret     nz                              ; If player not facing up, can't talk to a person
        ld      a,(numPeople)
        or      a
        ret     z                               ; If there's no people on this screen, leave
        ld      b,a                             ; B = Number of ppl on screen

        ld      a,(playerOffset)
        sub     16
        ld      c,a                             ; C = Offset in map
        ld      hl,people                       ; HL => People data
checkPeopleLoop:
        ld      a,c
        cp      (hl)                            ; Check offset
        jr      nz,notTalkingToPerson           ; If not equal, player isn't talking to this person
        inc     hl
        ld      a,(hl)                          ; A = Text message number
        pop     de                              ; Remove now-redundant stack data
        call    textMessage                     ; Talk to the person
        call    grayDrawMap                     ; Re-draw the screen
        jp      mainLoop                        ; And proceed with the game
notTalkingToPerson:
        inc     hl
        inc     hl                              ; HL => Next person
        djnz    checkPeopleLoop
        ret

;------------------------------------------------
; textMessage - Show a text message
;
; Input:    A = Text message to show
; Output:   NZ = 1 if a "YES" choice was made
;------------------------------------------------
textMessage:
        ld      hl,endTextMessage               ; HL => Where to RET to after finished talking
        push    hl                              ; Put address on stack
        ld      hl,talkText
        or      a
        jr      z,textMessageFound
        ld      b,a
findTextMessage:
        ld      a,(hl)
        inc     hl
        inc     a
        jr      nz,findTextMessage
        djnz    findTextMessage
textMessageFound:
        push    hl
        ld      hl,talkMap
        call    grayDrawTileMap
        pop     hl

        ld      de,5*256+6
        ld      b,0
writeTextLine:
        ld      a,(hl)
        inc     a
        jr      z,textMessageFinished
        inc     a
        jr      z,prepareForTextChoice
        push    bc
        call    putString
        pop     bc
        inc     b
        ld      a,b
        cp      8
        jr      z,waitNextTextPage
        ld      a,d
        add     a,6
        ld      d,a
        ld      e,6
        jr      writeTextLine
prepareForTextChoice:
        ld      de,53*256+6                     ; DE = New cursor position
        ld      hl,strYesNo
        call    putString                       ; Write "YES"
        ld      e,114                           ; E = New _pencol position
        call    putString                       ; Write "NO"
        ld      a,$80
textMessageFinished:
        add     a,$37
        ld      (__textChoice),a                ; Load either OR A or SCF
        nop \ nop
__textChoice                            = $
        nop
        jr      c,noTextChoice
        xor     a
        ld      (choice),a
        call    copyBuffers
        call    showGray
textChoiceLoop:
        call    waitKey
        cp      GK_F5                           ; Was [F5] pressed?
        ret     z                               ; If so, return Z for "NO"
        cp      GK_F1                           ; Was [F1] pressed?
        jr      nz,textChoiceLoop               ; If not, loop again
        inc     a                               ; Set NZ
        ret
waitNextTextPage:
        push    hl
        xor     a
        call    textMessageFinished
        pop     hl
        jp      textMessageFound
noTextChoice:
        call    copyBuffers
        call    showGray
        call    waitKey                         ; Wait for a keypress
        cp      GK_2ND
        ret     z
        cp      GK_ENTER                        ; Was it [ENTER]
        jr      nz,noTextChoice                 ; If not, loop again
        ret
endTextMessage:
        ret

.end
