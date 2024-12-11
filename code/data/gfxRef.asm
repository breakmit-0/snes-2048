;writes a reference of the GFX file offset to ROM as pointers
;for easy acess with indexing when they need to be moved
;and provides macros for doning ift with X and Y
;the 3 tables are $00 terminated bc macros are shit

GFX_REF:

.lo
db !GFX_RefAcc_lo$00
.hi
db !GFX_RefAcc_hi$00
.bk
dw !GFX_RefAcc_bk$00
