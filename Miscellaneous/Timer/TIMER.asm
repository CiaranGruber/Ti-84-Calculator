.nolist
#include "includes\ti84pce.inc"
.list

.org userMem-2
.db tExtTok,tAsm84CeCmp

.assume ADL=1
	
	ld hl, $F20030
	bit 0, (hl)
	jp z, start
	jp stop
	
stop:
	ld hl, $F20030
	res 0, (hl)
	ld hl, ($F20000)
	call _SetxxxxOP2
	call _OP2toOP1
	ld hl, 32768
	call _SetxxxxOP2
	call _FPDiv
	ld hl, ($F20002)
	call _SetxxxxOP2
	call _FPAdd
	call _FPAdd
	jp _StoAns
	
start:
	or a, a
	sbc hl, hl
	ex de, hl
	ld hl, $F20030
	res 0, (hl)
	set 1, (hl)
	res 2, (hl)
	inc hl
	set 1, (hl)
	ld l, 0
	ld (hl), de
	inc l
	ld (hl), de
	ld l, $30
	set 0, (hl)
	ret