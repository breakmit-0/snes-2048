hirom

incsrc "macros.asm"
incsrc "defines.asm"


;routines, bank by bank
org $C10000


print "before routines, pc at: $", pc

incsrc "code/routines/generic.asm"
incsrc "code/routines/random.asm"
incsrc "code/routines/PPU_upload.asm"
incsrc "code/routines/clear_OAM.asm"
incsrc "code/routines/init_PPU.asm"
incsrc "code/routines/OAM.asm"
incsrc "code/routines/game.asm"
incsrc "code/routines/game_modes.asm"
incsrc "code/routines/save.asm"
incsrc "code/sound/upload.asm"

print "after routines,  pc at: $", pc

;snes header
org $00FFC0
	db "GAME TITLE  " ;exactly 12 chars

org $00FFD5
	db $31  	;fast hiROM
	db $02  	;ROM + RAM + S-RAM
	db $0C  	;ROM size, 4MB -> activates ExLoROM
	db $05  	;32KB RAM
	db $01  	;NTSC
	db $00  	;dev ID, $00 = homebrew
	db $00		;ROM version
	dw $FFFF  	;checksum complement
	dw $0000  	;checksum


;interrupt vectors (in bank $00)
org $00FFE0
	dd $FFFFFFFF	; 4 blank bytes
	dw $8000		; (65c816) COP vector
	dw INT.BRK		; (65c816) BRK vector
	dw $FFFF		; (65c816) ABORT vector - unused
	dw INT.NMI		; (65c816) NMI vector - V-blank
	dw $FFFF		; (65c816) RESET vector - unused
	dw INT.IRQ		; (65c816) IRQ vector

	dd $FFFFFFFF	;
	dw $8000		; (6502) COP vector
	dw $FFFF		; (6502) BRK vector -unused
	dw $8000		; (6502) ABORT vector - unused
	dw $8000		; (6502) NMI vector
	dw INT.RESET	; (6502) RESET vector - entry point
	dw $8000		; (6502) IRQ/BRK vector


print "brk ->", hex(INT.BRK)

;main code, orgs included
incsrc "code/interrupt.asm"
incsrc "code/boot.asm"
incsrc "code/main.asm"
incsrc "code/nmi.asm"



; data segment, from back to front

org $FF0000

;start values for the refernces, aslo the first GFX location
!GFX_RefAcc_lo = ""
!GFX_RefAcc_hi = ""
!GFX_RefAcc_bk = ""

%incgfx("assets/sprite/SP0.gfx", SP0)
%incgfx("assets/sprite/SP1.gfx", SP1)
%incgfx("assets/sprite/SP2.gfx", SP2)
%incgfx("assets/sprite/SP3.gfx", SP3)
%incgfx("assets/bg/BG0.gfx", BG0)
%incgfx("assets/bg/BG3.gfx", BG3)

%inctmap("assets/tilemap/bg.tmap", MAIN)
%inctmap("assets/tilemap/won.tmap", WON)
%inctmap("assets/tilemap/lost.tmap", LOST)
%inctmap("assets/tilemap/pause.tmap", PAUSE)
%inctmap("assets/tilemap/begin.tmap", BEGIN)

warnpc $FFFFFF-2048

incsrc "code/data/gfxRef.asm"


org $FE0000 ;>can be put anywhere
PAL_BASE:
incbin "assets/palettes/Example.pal.spl"

;org $FC0000
;incsrc "code/sound/driver.asm"
