; ------------------------------> HUFFEXTR.H <------------------------------
;
; Huffman Decompression by Jimmy Mårdell
;
; 'Odd address' bug fixed by Florent Dhordain 02/07/98 DDMMYY
;
; 'More than 42 files' bug fixed by James Vernon 26/10/2000 DDMMYYYY
;
; Removed 'treeaddr' 2 byte location from the code, now defined elsewhere
;  in code, so that routine is compatible in an application (no code
;  writeback) by James Vernon 25/04/2013 DDMMYYYY
;
; Updated for TI-84+CE compatibility by James Vernon 19/12/2015 DDMMYYYY
;  Note that 'treeaddr' needs to be a 3 byte location for TI-84+CE
;  #define HUFF84PCE if compiling for the TI-84+CE
;
; If you make any changes to the source, please tell us what and why.
; And you are NOT allowed to distribute a modified source, nor the
; compiled version of it. Any changes should be made for personal use only.
;
; Please notify changes to :
; Jimmy Mårdell      <mja@algonet.se>
; Florent Dhordain   <flo.dh@usa.net>
; James Vernon       <jamesv82@live.com.au>
;
; ------------------------------> HUFFEXTR.H <------------------------------

;------------------------------------------------
; HuffExtr - Huffman Extraction Routine
;
; Input:    HL => Start of compressed file
;           DE => Where to extract to
;           IX => 1024 bytes of mem for HuffLib
;           B = File number to extract
; Output:   None
;------------------------------------------------
HuffExtr:
        push    de
        push    de
        push    hl
        inc     hl
        ld      a,(hl)
        cp      1
        jr      nz,MultiFile
        ld      b,0
MultiFile:
        push    bc
        inc     hl
        ld      de,0                            ; to allow for eZ80 24-bit (reset upper byte of DE)
        ld      d,(hl)
        inc     hl
        ld      e,(hl)                          ; DE = noDifChars
        inc     hl
        push    hl
; -- James -- ;
        ld      hl,0
        ld      l,a                             ; HL = A
        add     hl,hl                           ; HL = 2A
        push hl \ pop bc                        ; BC = 2A
        add     hl,hl                           ; HL = 4A
        add     hl,bc                           ; HL = 6A
        push hl \ pop bc                        ; BC = 6A
        pop     hl
        push    hl
; -- James -- ;
; add a,a
; ld c,a
; add a,a
; add a,c
; ld b,0
; ld c,a
        add     hl,bc                           ; HL -> chars
        ld      b,e
        dec     b                               ; B = noDifChars-1
        push    hl
        add     hl,de
        pop     de                              ; DE -> chars, HL -> tree, IX -> treeaddr
        ld      (treeaddr),ix
        ld      a,1
UncrunchTree:
        ld      c,a
        and     (hl)
        jr      z,NoBranch
        push    ix
        inc     ix
        inc     ix
NextTreeBit:
        ld      a,c
        rlca
        jr      nc,UncrunchTree
        inc     hl
        jr      UncrunchTree
NoBranch:
        ld      a,(de)
        inc     de
        ld      (ix),0
        ld      (ix+1),a
        inc     ix
        inc     ix
        ld      a,b
        or      a
        jr      z,TreeBuilt
        ex      (sp),hl
        push    de
        push    ix
        pop     de
;
        ld      (hl),d
        inc     hl
        ld      (hl),e                          ; MSB 1st order
;
        pop     de
        ex      (sp),hl
        inc     sp
        inc     sp
#ifdef HUFF84PCE
        inc     sp                              ; stack entries are 3 bytes on TI-84+CE
#endif
        dec     b
        jr      NextTreeBit
TreeBuilt:
        pop     ix                              ; IX -> fileInfo
        pop     af                              ; A = file no
; -- James -- ;
        ld      hl,0
        ld      l,a                             ; HL = A
        add     hl,hl                           ; HL = 2A
        push hl \ pop bc                        ; BC = 2A
        add     hl,hl                           ; HL = 4A
        add     hl,bc                           ; HL = 6A
        push hl \ pop bc                        ; BC = 6A
; -- James -- ;
        pop     hl                              ; HL -> noFiles
; add a,a
; ld c,a
; add a,a
; add a,c
; ld b,0
; ld c,a
        add     ix,bc                           ; IX -> fileInfo[file no]
        ld      de,0
        ld      d,(ix)
        ld      e,(ix+1)
        add     hl,de                           ; HL -> data
        ld      b,(ix+3)                        ; B = start bit
        ld      a,1
Shift:
        rlca
        djnz    Shift
        ld      c,a                             ; C = start bit vlaue
        ld      d,(ix+4)
        ld      e,(ix+5)                        ; DE = length of uncompressed data
        pop     ix                              ; HL -> Data, C = bitval, DE = length, IX -> Storage
UncrunchData:
        push    de
        ld      de,(treeaddr)
CheckTree:
        ld      a,(de)                          ; cause of this, we need to store in MSB 1st order
        or      a
        jr      z,EndOfBranch
        ld      a,c
        and     (hl)
        jr      nz,RightBranch
        inc     de
        inc     de
        jr      NextDataBit
RightBranch:
        ex      de,hl
;
        ld      a,(hl)
        inc     hl
        ld      l,(hl)
        ld      h,a                             ; H = (HL), L = (HL+1) : MSB 1st order
;
        ex      de,hl
NextDataBit:
        rlc     c
        jr      nc,CheckTree
        inc     hl
        jr      CheckTree
EndOfBranch:
        inc     de
        ld      a,(de)
        ld      (ix),a
        inc     ix
        pop     de
        dec     de
        ld      a,d
        or      e
        jr      nz,UncrunchData
        pop     de
        ret
        
HUFFEXTR_LEN            = $-huffExtr

;treeaddr:
;.dw     0

.end
