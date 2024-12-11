;this routines resets all the OAM tiles
;   X:    -128 (middle of the offscreen area)
;   Y:    0
;   TILE: 0
;   PROP: 0
;   SIZE: small

;> ram $7E0000 to $7E1FFF is mirrored

OAM_RESET:
    phb         ; go to a bank w/ RAM access
    lda #$00    ;
    pha         ;
    plb         ;

    rep #$30 ;> a16i16, to do all of OAM in a single pass

    ldy.w #$0200
    .loop
        dey #4

        lda.w #$007F      ;> 0xFF to X 
        sta !OAM_x,y       ;> 0x00 to Y
        lda.w #$0000      ;> 0x00 to TILE
        sta !OAM_gfx,y       ;> 0x00 to PROP

    cpy #$0000
    bne .loop

    ;set extras
    ldy.w #$0020
    .loop2
        dey #2
        lda.w #$5555    ;> small and negative X
        sta !OAM_ex,y
    cpy #$0000
    bne .loop2

    sep #$30

    ;reset counters
    stz !OAMX_index
    stz !OAM_index
    stz !OAM_index+1

    plb
rtl