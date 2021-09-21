;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Talking Routines                                              ;
;                                                               ;
;---------------------------------------------------------------;

;------------------------------------------------
; checkPeople - check to see if player can talk to a person
;   input:  none
;   output: none
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
        sub     COLS
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
        jp      mainLoop                        ; And proceed with the game
notTalkingToPerson:
        inc     hl
        inc     hl                              ; HL => Next person
        djnz    checkPeopleLoop
        ret

;------------------------------------------------
; textMessage - show a text message
;   input:  A = Text message to show
;   output: NZ = 1 if a "YES" choice was made
;   notes:  if HL already points to text data, call "textMessageFound"
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
        push    hl                              ; HL => text data
        call    vramCopy
        ld      de,60*256+0
        ld      bc,160*256+120
        ld      a,COLOUR_GREENGREY
        call    drawWindow
        call    vramFlip
        call    vramCopy
        pop     hl
        ld      c,70
writeTextLine:
        ld      de,16
        ld      a,(hl)
        inc     a
        jr      z,textMessageFinished
        inc     a
        jr      z,prepareForTextChoice
        push    bc
        call    drawString
        pop     bc
        ld      a,10
        add     a,c
        cp      165
        jr      nc,waitNextTextPage
        ld      c,a
        jr      writeTextLine
        
prepareForTextChoice:
        ld      de,8
        ld      c,166
        ld      hl,strYes
        call    drawString
        ld      de,297
        ld      c,166
        call    drawString
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
        call    vramFlip
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
        call    vramFlip
noTextChoiceWait:
        call    waitKey                         ; Wait for a keypress
        cp      GK_2ND
        ret     z
        cp      GK_ENTER                        ; Was it [ENTER]
        jr      nz,noTextChoiceWait             ; If not, loop again
        ret
endTextMessage:
        push    af                              ; Z/NZ flag needs to be preserved
        ; clear the text box (twice, to get both buffers)
        ld      de,60*256+0
        ld      bc,160*256+120
        ld      a,COLOUR_BLACK
        call    fillRect
        call    vramFlip
        ld      de,60*256+0
        ld      bc,160*256+120
        ld      a,COLOUR_BLACK
        call    fillRect
        pop     af
        ret

.end
